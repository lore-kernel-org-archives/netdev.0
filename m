From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: hypothetical vlan rx path question
Date: Thu, 14 Jul 2011 08:31:53 +0200
Message-ID: <20110714063152.GA1822@minipsycho>
References: <20110713204945.GA1833@minipsycho>
 <20110713141127.23703590@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net, greearb@candelatech.com, mirqus@gmail.com,
	bhutchings@solarflare.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47402 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048Ab1GNGcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 02:32:05 -0400
Content-Disposition: inline
In-Reply-To: <20110713141127.23703590@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jul 13, 2011 at 11:11:27PM CEST, shemminger@linux-foundation.org wrote:
>On Wed, 13 Jul 2011 22:49:46 +0200
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>> Hi guys.
>> 
>> Consider following code taken from 8139cp.c
>> 
>> 
>> static inline void cp_rx_skb (struct cp_private *cp, struct sk_buff *skb,
>> 			      struct cp_desc *desc)
>> {
>> 	skb->protocol = eth_type_trans (skb, cp->dev);
>> 
>> 	cp->dev->stats.rx_packets++;
>> 	cp->dev->stats.rx_bytes += skb->len;
>> 
>> #if CP_VLAN_TAG_USED
>> 	if (cp->vlgrp && (desc->opts2 & cpu_to_le32(RxVlanTagged))) {
>> 		vlan_hwaccel_receive_skb(skb, cp->vlgrp,
>> 					 swab16(le32_to_cpu(desc->opts2) & 0xffff));
>> 	} else
>> #endif
>> 		netif_receive_skb(skb);
>> }
>> 
>> 
>> Now my question is why the check for cp->vlgrp is needed here. Because
>> in hypothetical case it might be possible to receive vlan packet as
>> non-vlan packet (vlan tag would be lost).
>> 
>> This is present in many drivers.
>> 
>> How about to kill this check entirely and let the later code to deside
>> what to do with the packet?
>> 
>> Thanks.
>> 
>> Jirka
>
>All this is moot with new vlan model. It should always just put
>tagged packet up.

That's what I thought.
>
>I think all drivers with .ndo_vlan_rx_register need to be still converted.

Yes, I'm kinda on the way to do that.

Thanks Stephen.
