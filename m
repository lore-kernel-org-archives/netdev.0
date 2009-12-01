From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] bonding: allow arp_ip_targets to be on a
 separate vlan from bond device
Date: Tue, 01 Dec 2009 10:42:44 +0100
Message-ID: <4B14E514.8070400@trash.net>
References: <20091130201453.GF1639@gospo.rdu.redhat.com> <4B142989.6070207@trash.net> <20091130205333.GG1639@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39212 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711AbZLAJmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 04:42:40 -0500
In-Reply-To: <20091130205333.GG1639@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek wrote:
> On Mon, Nov 30, 2009 at 09:22:33PM +0100, Patrick McHardy wrote:
>> Andy Gospodarek wrote:
>>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>>> index e75a2f3..8d8a778 100644
>>> --- a/net/8021q/vlan_core.c
>>> +++ b/net/8021q/vlan_core.c
>>> @@ -14,6 +14,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
>>>  	if (skb_bond_should_drop(skb))
>>>  		goto drop;
>>>  
>>> +	skb->skb_iif = skb->dev->ifindex;
>>>  	__vlan_hwaccel_put_tag(skb, vlan_tci);
>>>  	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
>>>  
>>> @@ -85,6 +86,7 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
>>>  	if (skb_bond_should_drop(skb))
>>>  		goto drop;
>>>  
>>> +	skb->skb_iif = skb->dev->ifindex;
>>>  	__vlan_hwaccel_put_tag(skb, vlan_tci);
>>>  	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
>>>  
>> How about pulling the skb->iif assignment in netif_receive_skb() up
>> before the vlan_hwaccel_do_receive() call instead?
> 
> I'm not sure how that will help.  My goal with the two changes in
> vlan_core.c was to capture the input device index before we lost it --
> which is precisely what happens when coming up through a driver like
> bnx2 that supports vlan acceleration:
> 
> (NAPI poll)
> bnx2_poll
>   bnx2_poll_work
>     bnx2_rx_int
>       vlan_hwaccel_receive_skb
>         __vlan_hwaccel_rx
>           (skb->dev set to vlan device)
>           netif_receive_skb
> 
> In that case, setting skb_iif in netif_receive_skb would be too late.
> The original dev would no longer be known.

Right, I've misread your patch, sorry.
