From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net] vti: remove duplicated code to fix a memory leak
Date: Fri, 28 Jun 2013 22:18:49 -0700
Message-ID: <20130628221849.16c7ca0e@nehalam.linuxnetplumber.net>
References: <1372482057-12412-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Saurabh Mohan <saurabh.mohan@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:46166 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814Ab3F2FSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 01:18:54 -0400
Received: by mail-pb0-f52.google.com with SMTP id xa12so2955679pbc.39
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 22:18:53 -0700 (PDT)
In-Reply-To: <1372482057-12412-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Jun 2013 13:00:57 +0800
Cong Wang <amwang@redhat.com> wrote:

> From: Cong Wang <amwang@redhat.com>
> 
> vti module allocates dev->tstats twice: in vti_fb_tunnel_init()
> and in vti_tunnel_init(), this lead to a memory leak of 
> dev->tstats.
> 
> Just remove the duplicated operations in vti_fb_tunnel_init().
> 
> (candidate for -stable)
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Saurabh Mohan <saurabh.mohan@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
> index c118f6b..17cc0ff 100644
> --- a/net/ipv4/ip_vti.c
> +++ b/net/ipv4/ip_vti.c
> @@ -606,17 +606,10 @@ static int __net_init vti_fb_tunnel_init(struct net_device *dev)
>  	struct iphdr *iph = &tunnel->parms.iph;
>  	struct vti_net *ipn = net_generic(dev_net(dev), vti_net_id);
>  
> -	tunnel->dev = dev;
> -	strcpy(tunnel->parms.name, dev->name);
> -
>  	iph->version		= 4;
>  	iph->protocol		= IPPROTO_IPIP;
>  	iph->ihl		= 5;
>  
> -	dev->tstats = alloc_percpu(struct pcpu_tstats);
> -	if (!dev->tstats)
> -		return -ENOMEM;
> -
>  	dev_hold(dev);
>  	rcu_assign_pointer(ipn->tunnels_wc[0], tunnel);
>  	return 0;

The fix looks correct, looks like an oversight when the generic tunnel infratructure
was added.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
