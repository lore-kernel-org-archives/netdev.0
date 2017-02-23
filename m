From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] vxlan: don't allow overwrite of config src addr
Date: Thu, 23 Feb 2017 17:10:29 +0100
Message-ID: <20170223171029.4c00bb6d@griffin>
References: <1487611528-11468-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Brian Russell <brussell@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53940 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751070AbdBWQU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 11:20:28 -0500
In-Reply-To: <1487611528-11468-1-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Feb 2017 17:25:28 +0000, Brian Russell wrote:
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2019,7 +2019,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  
>  		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
>  		vni = rdst->remote_vni;
> -		src = &vxlan->cfg.saddr;
> +		local_ip = vxlan->cfg.saddr;
>  		dst_cache = &rdst->dst_cache;
>  		md->gbp = skb->mark;
>  		ttl = vxlan->cfg.ttl;
> @@ -2052,7 +2052,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  		dst = &remote_ip;
>  		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
>  		vni = tunnel_id_to_key32(info->key.tun_id);
> -		src = &local_ip;
>  		dst_cache = &info->dst_cache;
>  		if (info->options_len)
>  			md = ip_tunnel_info_opts(info);
> @@ -2061,6 +2060,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  		label = info->key.label;
>  		udp_sum = !!(info->key.tun_flags & TUNNEL_CSUM);
>  	}
> +	src = &local_ip;

Btw, you can simplify this even more, get rid of src completely and
just use local_ip.

And please also add to v2:

Fixes: 272d96a5ab10 ("net: vxlan: lwt: Use source ip address during route lookup.")

 Jiri
