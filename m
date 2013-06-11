From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 1/1] net/ipv4: ip_vti clear skb cb before tunneling.
Date: Mon, 10 Jun 2013 18:28:22 -0700
Message-ID: <20130610182822.0f37feb5@nehalam.linuxnetplumber.net>
References: <1370911510-20012-1-git-send-email-saurabh.mohan@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Saurabh Mohan <saurabh@vyatta.com>
To: Saurabh Mohan <saumoh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:61540 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996Ab3FKB21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 21:28:27 -0400
Received: by mail-pd0-f176.google.com with SMTP id t12so3246044pdi.21
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 18:28:26 -0700 (PDT)
In-Reply-To: <1370911510-20012-1-git-send-email-saurabh.mohan@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Jun 2013 17:45:10 -0700
Saurabh Mohan <saumoh@gmail.com> wrote:

> From: Saurabh Mohan <saurabh@vyatta.com>
> 
> If users apply shaper to vti tunnel then it will cause a kernel crash. The
> problem seems to be due to the vti_tunnel_xmit function not clearing
> skb->opt field before passing the packet to xfrm tunneling code.
> 
> Signed-off-by: Saurabh Mohan <saurabh@vyatta.com>
> ---
>  net/ipv4/ip_vti.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
> index 9d2bdb2..c118f6b 100644
> --- a/net/ipv4/ip_vti.c
> +++ b/net/ipv4/ip_vti.c
> @@ -361,8 +361,7 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
>  			tunnel->err_count = 0;
>  	}
>  
> -	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
> -			      IPSKB_REROUTED);
> +	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
>  	skb_dst_drop(skb);
>  	skb_dst_set(skb, &rt->dst);
>  	nf_reset(skb);

Thanks, this applies to 3.9 and earlier kernels. When the tunnel code was unified,
this was fixed in ip_tunnel.c

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
