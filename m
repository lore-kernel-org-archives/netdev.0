From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/7] skge: fix truncated collision threshold mask
Date: Wed, 12 Jul 2006 15:23:43 -0700
Message-ID: <20060712222645.895293484@localhost.localdomain>
References: <20060712222341.686007133@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18569 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751323AbWGLWb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 18:31:58 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-thr-msk.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch to correct broken collision threshold mask in (same problem
as sky2 driver).  Should be three bits wide, but the mask only allows
for 1 bit to be set.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/skge.h	2006-07-07 13:02:23.000000000 -0700
+++ sky2/drivers/net/skge.h	2006-07-12 15:06:31.000000000 -0700
@@ -1734,11 +1734,11 @@
 	GM_TXCR_FORCE_JAM	= 1<<15, /* Bit 15:	Force Jam / Flow-Control */
 	GM_TXCR_CRC_DIS		= 1<<14, /* Bit 14:	Disable insertion of CRC */
 	GM_TXCR_PAD_DIS		= 1<<13, /* Bit 13:	Disable padding of packets */
-	GM_TXCR_COL_THR_MSK	= 1<<10, /* Bit 12..10:	Collision Threshold */
+	GM_TXCR_COL_THR_MSK	= 7<<10, /* Bit 12..10:	Collision Threshold */
 };
 
 #define TX_COL_THR(x)		(((x)<<10) & GM_TXCR_COL_THR_MSK)
-#define TX_COL_DEF		0x04
+#define TX_COL_DEF		0x04	/* late collision after 64 byte */
 
 /*	GM_RX_CTRL			16 bit r/w	Receive Control Register */
 enum {

--

