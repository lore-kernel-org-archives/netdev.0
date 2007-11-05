From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH] prevent that myri_do_handshake lies about ticks in drivers/net/myri_sbus.c
Date: Mon, 05 Nov 2007 16:06:11 +0100
Message-ID: <472F3163.2060302@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out0.tiscali.nl ([195.241.79.175]:34945 "EHLO
	smtp-out0.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbXKEPGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 10:06:13 -0500
Received: from [82.171.216.234] (helo=[192.168.1.2])
	by smtp-out0.tiscali.nl with esmtp (Tiscali http://www.tiscali.nl)
	id 1Ip3Wl-000422-Tl
	for <netdev@vger.kernel.org>; Mon, 05 Nov 2007 16:06:12 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With '<=' tick can be incremented up to 26, The last loop is redundant since 
even when 'softstate' becomes 'STATE_READY', 'if (tick > 25)' will still cause
the function to return -1,

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 8d29319..656a260 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -134,7 +134,7 @@ static int myri_do_handshake(struct myri_eth *mp)
 
 	myri_disable_irq(mp->lregs, cregs);
 
-	while (tick++ <= 25) {
+	while (tick++ < 25) {
 		u32 softstate;
 
 		/* Wake it up. */


