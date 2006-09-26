From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/8] sky2: workarounds for some 88e806x chips
Date: Tue, 26 Sep 2006 16:10:16 -0700
Message-ID: <20060926161016.47a99b23@freekitty>
References: <20060926160814.79750148@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:47283 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965145AbWIZXRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 19:17:54 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k8QNHInW026365
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:20 -0700
Received: from freekitty (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k8QNHISx006577
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:18 -0700
To: netdev@vger.kernel.org
In-Reply-To: <20060926160814.79750148@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Workarounds for 88e806x chips from the vendor driver.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-09-25 15:23:02.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.c	2006-09-25 15:23:13.000000000 -0700
@@ -1124,7 +1124,8 @@
 	sky2_qset(hw, txqaddr[port]);
 
 	/* Set almost empty threshold */
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U && hw->chip_rev == 1)
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U
+	    && hw->chip_rev == CHIP_REV_YU_EC_U_A0)
 		sky2_write16(hw, Q_ADDR(txqaddr[port], Q_AL), 0x1a0);
 
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
@@ -1443,6 +1444,13 @@
 	sky2_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL),
 		     RB_RST_SET | RB_DIS_OP_MD);
 
+	/* WA for dev. #4.209 */
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U
+	    && hw->chip_rev == CHIP_REV_YU_EC_U_A1)
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     sky2->speed != SPEED_1000 ?
+			     TX_STFW_ENA : TX_STFW_DIS);
+
 	ctrl = gma_read16(hw, port, GM_GP_CTRL);
 	ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, ctrl);
