From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH net-next 0/2] Local checksum offload for VXLAN
Date: Mon, 14 Dec 2015 15:11:18 +0000
Message-ID: <566EDC16.1060706@solarflare.com>
References: <5669E066.8090703@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:28102 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752442AbbLNPL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 10:11:26 -0500
In-Reply-To: <5669E066.8090703@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the inner packet checksum is offloaded, the outer UDP checksum is easy
 to calculate as it doesn't depend on the payload (because the inner checksum
 cancels out everything from the inner packet except the pseudo header).
Thus, transmit checksums for VXLAN (and in principle other encapsulations,
 but I haven't enabled it for / tested with those) can be offloaded on any
 device supporting NETIF_F_HW_CSUM.  Only the innermost checksum has to be
 offloaded, the rest are filled in by the stack.
Tested by hacking a driver to report NETIF_F_HW_CSUM, call skb_checksum_help
 before transmitting a packet, and not actually offload anything to the hw.
 I did it that way because I don't have any hw that can actually offload the
 inner checksum; but I should be able to get hold of some soon.

Edward Cree (2):
  net: udp: local checksum offload for encapsulation
  net: vxlan: enable local checksum offload on HW_CSUM devices

 drivers/net/vxlan.c |  5 ++++-
 net/ipv4/udp.c      | 31 +++++++++++++++++++++++++++----
 2 files changed, 31 insertions(+), 5 deletions(-)

-- 
2.4.3
