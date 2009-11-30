From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] bonding: allow arp_ip_targets to be on a
 separate vlan from bond device
Date: Mon, 30 Nov 2009 21:22:33 +0100
Message-ID: <4B142989.6070207@trash.net>
References: <20091130201453.GF1639@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58964 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbZK3UW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 15:22:28 -0500
In-Reply-To: <20091130201453.GF1639@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek wrote:
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index e75a2f3..8d8a778 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -14,6 +14,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
>  	if (skb_bond_should_drop(skb))
>  		goto drop;
>  
> +	skb->skb_iif = skb->dev->ifindex;
>  	__vlan_hwaccel_put_tag(skb, vlan_tci);
>  	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
>  
> @@ -85,6 +86,7 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
>  	if (skb_bond_should_drop(skb))
>  		goto drop;
>  
> +	skb->skb_iif = skb->dev->ifindex;
>  	__vlan_hwaccel_put_tag(skb, vlan_tci);
>  	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
>  

How about pulling the skb->iif assignment in netif_receive_skb() up
before the vlan_hwaccel_do_receive() call instead? I'd actually call
this a bug fix since hardware accelerated devices should not differ
from non-accelerated devices in their iif value.
