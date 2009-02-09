From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] netdevice: ticks reaches 25, not 26.
Date: Mon, 09 Feb 2009 23:22:11 +0100
Message-ID: <4990AC93.3080906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:26140 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbZBIWWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 17:22:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With while (tick++ < 25) { ... } ticks reaches 25, not 26.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 899ed06..a95e217 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -161,7 +161,7 @@ static int myri_do_handshake(struct myri_eth *mp)
 
 	myri_enable_irq(mp->lregs, cregs);
 
-	if (tick > 25) {
+	if (tick >= 25) {
 		DET(("25 ticks we lose, failure.\n"));
 		return -1;
 	}
