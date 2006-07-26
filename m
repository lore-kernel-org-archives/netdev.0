From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: H/W requirements for NETIF_F_HW_CSUM
Date: Wed, 26 Jul 2006 10:28:00 -0700
Message-ID: <006201c6b0d8$d831ba80$4510100a@pc.s2io.com>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <Steve.Whitaker@neterion.com>, <Mike.Doyle@neterion.com>,
	<Andrew.LaCroix@neterion.com>, <Ananda.Raju@neterion.com>,
	<dave.fenton@neterion.com>,
	"Leonid. Grossman \(E-mail\)" <leonid.grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:44211 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1750772AbWGZR24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 13:28:56 -0400
Received: from guinness.s2io.com (unknown [142.46.210.147])
	by barracuda.mail.s2io.com (Spam Firewall) with ESMTP id 84DC62001D46
	for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 13:28:55 -0400 (EDT)
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
Our current NIC does not provide the actual checksum value on receive path.
Hence we only claim NETIF_F_IP_CSUM instead of the more general
NETIF_F_HW_CSUM.

To support this in a future adapter, we would like to know what exactly are
the requirements (on both Rx and Tx )to claim NETIF_F_HW_CSUM ?

Following are some specific questions:
1. On Tx, our adapter supports checksumming of TCP/UDP over IPv4 and IPv6.
This computation is TCP/UDP specific. Does the checksum calculation need to
be more generic ? Also, skbuff.h says that the checksum needs to be placed
at a specific location(skb->h.raw+skb->csum). I guess this means the adapter
needs to pass back the checksum to host driver after transmission. What
happens in case of TSO ?
2. On Rx, is it suffficient if we place the L4 checksum in skb->csum ? What
about L3 checksum ?

Thanks,
Ravi

