From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] b44: change comment about irq mask register
Date: Mon, 06 Nov 2006 23:17:20 +0100
Message-ID: <1162851440.1412.31.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:939 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1753869AbWKFWSr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 17:18:47 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Through some experimentation with the similarly built bcm43xx I came to
the conclusion that if the hw/firmware sets a bit in the interrupt
register, an interrupt will only be raised if that bit is included in
the interrupt mask. Hence, the interrupt mask is more like an interrupt
control mask.

This patch changes the comment to reflect that.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/drivers/net/b44.c	2006-11-06 23:13:36.909597550 +0100
+++ wireless-dev/drivers/net/b44.c	2006-11-06 23:14:21.949597550 +0100
@@ -908,8 +908,9 @@ static irqreturn_t b44_interrupt(int irq
 	istat = br32(bp, B44_ISTAT);
 	imask = br32(bp, B44_IMASK);
 
-	/* ??? What the fuck is the purpose of the interrupt mask
-	 * ??? register if we have to mask it out by hand anyways?
+	/* The interrupt mask register controls which interrupt bits
+	 * will actually raise an interrupt to the CPU when set by hw/firmware,
+	 * but doesn't mask off the bits.
 	 */
 	istat &= imask;
 	if (istat) {


