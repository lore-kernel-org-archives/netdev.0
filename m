From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Subject: [PATCH] IP checksuming doesn't work on GE0301 option cards
Date: Wed,  8 Dec 2010 09:21:52 +0100 (CET)
Message-ID: <20101208082152.407022397DD@solo.franken.de>
To: netdev@vger.kernel.org, j.dumon@option.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:39256 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751132Ab0LHJdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 04:33:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is definitly a problem, that some option cards send up broken
IP pakets leading to corrupted IP packets. These corruptions aren't
detected, because the driver claims that the packets are already
checksummed. This change removes the CHECKSUM_UNNECESSARY option
and let IP detect broken data.

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
---

 drivers/net/usb/hso.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index b154a94..1f94f92 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -958,10 +958,6 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 				/* Packet is complete. Inject into stack. */
 				/* We have IP packet here */
 				odev->skb_rx_buf->protocol = cpu_to_be16(ETH_P_IP);
-				/* don't check it */
-				odev->skb_rx_buf->ip_summed =
-					CHECKSUM_UNNECESSARY;
-
 				skb_reset_mac_header(odev->skb_rx_buf);
 
 				/* Ship it off to the kernel */
