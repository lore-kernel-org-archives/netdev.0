From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: hypothetical vlan rx path question
Date: Wed, 13 Jul 2011 14:11:27 -0700
Message-ID: <20110713141127.23703590@nehalam.ftrdhcpuser.net>
References: <20110713204945.GA1833@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net, greearb@candelatech.com, mirqus@gmail.com,
	bhutchings@solarflare.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45933 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750872Ab1GMVLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 17:11:37 -0400
In-Reply-To: <20110713204945.GA1833@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Jul 2011 22:49:46 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> Hi guys.
> 
> Consider following code taken from 8139cp.c
> 
> 
> static inline void cp_rx_skb (struct cp_private *cp, struct sk_buff *skb,
> 			      struct cp_desc *desc)
> {
> 	skb->protocol = eth_type_trans (skb, cp->dev);
> 
> 	cp->dev->stats.rx_packets++;
> 	cp->dev->stats.rx_bytes += skb->len;
> 
> #if CP_VLAN_TAG_USED
> 	if (cp->vlgrp && (desc->opts2 & cpu_to_le32(RxVlanTagged))) {
> 		vlan_hwaccel_receive_skb(skb, cp->vlgrp,
> 					 swab16(le32_to_cpu(desc->opts2) & 0xffff));
> 	} else
> #endif
> 		netif_receive_skb(skb);
> }
> 
> 
> Now my question is why the check for cp->vlgrp is needed here. Because
> in hypothetical case it might be possible to receive vlan packet as
> non-vlan packet (vlan tag would be lost).
> 
> This is present in many drivers.
> 
> How about to kill this check entirely and let the later code to deside
> what to do with the packet?
> 
> Thanks.
> 
> Jirka

All this is moot with new vlan model. It should always just put
tagged packet up.

I think all drivers with .ndo_vlan_rx_register need to be still converted.
