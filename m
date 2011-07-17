From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH RFC 1/2] r8169: expand received packet length indication.
Date: Sun, 17 Jul 2011 22:51:30 +0200
Message-ID: <20110717205130.GA6932@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56098 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab1GQVGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 17:06:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

8168d and above allow jumbo frames beyond 8k. Bump the received
packet length check before enabling jumbo frames on these chipsets.

Frame length indication covers bits 0..13 of the first Rx descriptor
32 bits for the 8169 and 8168. I only have authoritative documentation
for the allowed use of the extra (13) bit with the 8169 and 8168c.
Realtek's drivers use the same mask for the 816x and the fast ethernet
only 810x.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3ddd339..ea8ee93 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -5311,7 +5311,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 		} else {
 			struct sk_buff *skb;
 			dma_addr_t addr = le64_to_cpu(desc->addr);
-			int pkt_size = (status & 0x00001FFF) - 4;
+			int pkt_size = (status & 0x00003fff) - 4;
 
 			/*
 			 * The driver does not support incoming fragmented
-- 
1.7.4.4

