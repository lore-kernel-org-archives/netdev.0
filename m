From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 2/4] ip_tunnels: record IP version in tunnel
 info
Date: Sat, 29 Aug 2015 00:24:11 +0200
Message-ID: <20150828222411.GB32001@pox.localdomain>
References: <cover.1440787600.git.jbenc@redhat.com>
 <5f1807433565275c8bf699c0495b66c620b274c7.1440787600.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36190 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481AbbH1WYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 18:24:14 -0400
Received: by wicfv10 with SMTP id fv10so18303928wic.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 15:24:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5f1807433565275c8bf699c0495b66c620b274c7.1440787600.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/15 at 08:48pm, Jiri Benc wrote:
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index e2dc9dac59e6..40164037928e 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -587,6 +587,8 @@ int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
>  
>  	if (unlikely(!tun_info))
>  		return -EINVAL;
> +	if (ip_tunnel_info_af(tun_info) != AF_INET)
> +		return -EINVAL;
>  
>  	tun_key = &tun_info->key;

Are you sure this chunk is needed? It looks like OVS_CB()->egress_tun_info
can only be set via execute_set_action() which can only be of a supported
AF type.

Otherwise this looks great.

Acked-by: Thomas Graf <tgraf@suug.ch>
