From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/7] sk98lin: fix truncated collision threshold mask
Date: Wed, 12 Jul 2006 15:23:44 -0700
Message-ID: <20060712222646.085423694@localhost.localdomain>
References: <20060712222341.686007133@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18825 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751360AbWGLWb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 18:31:58 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sk98lin-thr-msk.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch to correct broken collision threshold mask in (same problem
as sky2 driver).  Should be three bits wide, but the mask only allows
for 1 bit to be set.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sk98lin/h/xmac_ii.h	2006-04-27 11:12:38.000000000 -0700
+++ sky2/drivers/net/sk98lin/h/xmac_ii.h	2006-07-12 15:09:23.000000000 -0700
@@ -1473,7 +1473,7 @@
 #define GM_TXCR_FORCE_JAM	(1<<15)	/* Bit 15:	Force Jam / Flow-Control */
 #define GM_TXCR_CRC_DIS		(1<<14)	/* Bit 14:	Disable insertion of CRC */
 #define GM_TXCR_PAD_DIS		(1<<13)	/* Bit 13:	Disable padding of packets */
-#define GM_TXCR_COL_THR_MSK	(1<<10)	/* Bit 12..10:	Collision Threshold */
+#define GM_TXCR_COL_THR_MSK	(7<<10)	/* Bit 12..10:	Collision Threshold */
 
 #define TX_COL_THR(x)		(SHIFT10(x) & GM_TXCR_COL_THR_MSK)
 

--

