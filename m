From: Jiri Pirko <jpirko@redhat.com>
Subject: hypothetical vlan rx path question
Date: Wed, 13 Jul 2011 22:49:46 +0200
Message-ID: <20110713204945.GA1833@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net, greearb@candelatech.com, mirqus@gmail.com,
	bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494Ab1GMUu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 16:50:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys.

Consider following code taken from 8139cp.c


static inline void cp_rx_skb (struct cp_private *cp, struct sk_buff *skb,
			      struct cp_desc *desc)
{
	skb->protocol = eth_type_trans (skb, cp->dev);

	cp->dev->stats.rx_packets++;
	cp->dev->stats.rx_bytes += skb->len;

#if CP_VLAN_TAG_USED
	if (cp->vlgrp && (desc->opts2 & cpu_to_le32(RxVlanTagged))) {
		vlan_hwaccel_receive_skb(skb, cp->vlgrp,
					 swab16(le32_to_cpu(desc->opts2) & 0xffff));
	} else
#endif
		netif_receive_skb(skb);
}


Now my question is why the check for cp->vlgrp is needed here. Because
in hypothetical case it might be possible to receive vlan packet as
non-vlan packet (vlan tag would be lost).

This is present in many drivers.

How about to kill this check entirely and let the later code to deside
what to do with the packet?

Thanks.

Jirka
