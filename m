From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH 2/2] ks8842: Advertise 100Mbps
Date: Sat, 24 Jul 2010 22:25:50 +0200
Message-ID: <1280003150.28285.281.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b12.telenor.se ([62.127.194.21]:46004 "EHLO
	smtprelay-b12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754274Ab0GXUZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 16:25:54 -0400
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-b12.telenor.se (Postfix) with ESMTP id 20753EA839
	for <netdev@vger.kernel.org>; Sat, 24 Jul 2010 22:25:51 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes sure that the ks8842 also advertises 100Mbps
during autonegotiation.

If the ks8842 is connected via VLB, the bus is slower
than 100Mbps ethernet. It turned out using flow control
in the chip was not optimal, so that non default setting
is removed.

Signed-off-by: Richard R=C3=B6jfors <richard.rojfors@pelagicore.com>
---
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 48e4582..ea22f29 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -254,10 +254,8 @@ static void ks8842_reset_hw(struct ks8842_adapter =
*adapter)
 	/* Enable QMU Transmit flow control / transmit padding / Transmit CRC=
 */
 	ks8842_write16(adapter, 16, 0x000E, REG_TXCR);
=20
-	/* enable the receiver, uni + multi + broadcast + flow ctrl
-		+ crc strip */
-	ks8842_write16(adapter, 16, 0x8 | 0x20 | 0x40 | 0x80 | 0x400,
-		REG_RXCR);
+	/* enable the receiver, uni + multi + broadcast + crc strip */
+	ks8842_write16(adapter, 16, 0x8 | 0x20 | 0x40 | 0x80, REG_RXCR);
=20
 	/* TX frame pointer autoincrement */
 	ks8842_write16(adapter, 17, 0x4000, REG_TXFDPR);
@@ -274,13 +272,11 @@ static void ks8842_reset_hw(struct ks8842_adapter=
 *adapter)
 	/* enable no excessive collison drop */
 	ks8842_enable_bits(adapter, 32, 1 << 3, REG_SGCR2);
=20
-	/* Enable port 1 force flow control / back pressure / transmit / recv=
 */
-	ks8842_write16(adapter, 48, 0x1E07, REG_P1CR2);
+	/* Enable port 1 / back pressure / transmit / recv */
+	ks8842_write16(adapter, 48, 0xE07, REG_P1CR2);
=20
 	/* restart port auto-negotiation */
 	ks8842_enable_bits(adapter, 49, 1 << 13, REG_P1CR4);
-	/* only advertise 10Mbps */
-	ks8842_clear_bits(adapter, 49, 3 << 2, REG_P1CR4);
=20
 	/* Enable the transmitter */
 	ks8842_enable_tx(adapter);

