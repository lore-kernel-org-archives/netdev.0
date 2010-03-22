From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] can: bfin_can: switch to common Blackfin can header
Date: Mon, 22 Mar 2010 03:06:01 -0400
Message-ID: <1269241561-28956-1-git-send-email-vapier@gentoo.org>
References: <1268150589-27123-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: socketcan-core@lists.berlios.de,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:47872 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753953Ab0CVHGD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 03:06:03 -0400
In-Reply-To: <1268150589-27123-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MMR bits are being moved to this header, so include it.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/bfin_can.c |   97 +++----------------------------------------
 1 files changed, 7 insertions(+), 90 deletions(-)

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 866905f..0348986 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -22,6 +22,7 @@
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 
+#include <asm/bfin_can.h>
 #include <asm/portmux.h>
 
 #define DRV_NAME "bfin_can"
@@ -29,90 +30,6 @@
 #define TX_ECHO_SKB_MAX  1
 
 /*
- * transmit and receive channels
- */
-#define TRANSMIT_CHL            24
-#define RECEIVE_STD_CHL         0
-#define RECEIVE_EXT_CHL         4
-#define RECEIVE_RTR_CHL         8
-#define RECEIVE_EXT_RTR_CHL     12
-#define MAX_CHL_NUMBER          32
-
-/*
- * bfin can registers layout
- */
-struct bfin_can_mask_regs {
-	u16 aml;
-	u16 dummy1;
-	u16 amh;
-	u16 dummy2;
-};
-
-struct bfin_can_channel_regs {
-	u16 data[8];
-	u16 dlc;
-	u16 dummy1;
-	u16 tsv;
-	u16 dummy2;
-	u16 id0;
-	u16 dummy3;
-	u16 id1;
-	u16 dummy4;
-};
-
-struct bfin_can_regs {
-	/*
-	 * global control and status registers
-	 */
-	u16 mc1;           /* offset 0 */
-	u16 dummy1;
-	u16 md1;           /* offset 4 */
-	u16 rsv1[13];
-	u16 mbtif1;        /* offset 0x20 */
-	u16 dummy2;
-	u16 mbrif1;        /* offset 0x24 */
-	u16 dummy3;
-	u16 mbim1;         /* offset 0x28 */
-	u16 rsv2[11];
-	u16 mc2;           /* offset 0x40 */
-	u16 dummy4;
-	u16 md2;           /* offset 0x44 */
-	u16 dummy5;
-	u16 trs2;          /* offset 0x48 */
-	u16 rsv3[11];
-	u16 mbtif2;        /* offset 0x60 */
-	u16 dummy6;
-	u16 mbrif2;        /* offset 0x64 */
-	u16 dummy7;
-	u16 mbim2;         /* offset 0x68 */
-	u16 rsv4[11];
-	u16 clk;           /* offset 0x80 */
-	u16 dummy8;
-	u16 timing;        /* offset 0x84 */
-	u16 rsv5[3];
-	u16 status;        /* offset 0x8c */
-	u16 dummy9;
-	u16 cec;           /* offset 0x90 */
-	u16 dummy10;
-	u16 gis;           /* offset 0x94 */
-	u16 dummy11;
-	u16 gim;           /* offset 0x98 */
-	u16 rsv6[3];
-	u16 ctrl;          /* offset 0xa0 */
-	u16 dummy12;
-	u16 intr;          /* offset 0xa4 */
-	u16 rsv7[7];
-	u16 esr;           /* offset 0xb4 */
-	u16 rsv8[37];
-
-	/*
-	 * channel(mailbox) mask and message registers
-	 */
-	struct bfin_can_mask_regs msk[MAX_CHL_NUMBER];    /* offset 0x100 */
-	struct bfin_can_channel_regs chl[MAX_CHL_NUMBER]; /* offset 0x200 */
-};
-
-/*
  * bfin can private data
  */
 struct bfin_can_priv {
@@ -163,7 +80,7 @@ static int bfin_can_set_bittiming(struct net_device *dev)
 	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
 		timing |= SAM;
 
-	bfin_write16(&reg->clk, clk);
+	bfin_write16(&reg->clock, clk);
 	bfin_write16(&reg->timing, timing);
 
 	dev_info(dev->dev.parent, "setting CLOCK=0x%04x TIMING=0x%04x\n",
@@ -185,11 +102,11 @@ static void bfin_can_set_reset_mode(struct net_device *dev)
 	bfin_write16(&reg->gim, 0);
 
 	/* reset can and enter configuration mode */
-	bfin_write16(&reg->ctrl, SRS | CCR);
+	bfin_write16(&reg->control, SRS | CCR);
 	SSYNC();
-	bfin_write16(&reg->ctrl, CCR);
+	bfin_write16(&reg->control, CCR);
 	SSYNC();
-	while (!(bfin_read16(&reg->ctrl) & CCA)) {
+	while (!(bfin_read16(&reg->control) & CCA)) {
 		udelay(10);
 		if (--timeout == 0) {
 			dev_err(dev->dev.parent,
@@ -244,7 +161,7 @@ static void bfin_can_set_normal_mode(struct net_device *dev)
 	/*
 	 * leave configuration mode
 	 */
-	bfin_write16(&reg->ctrl, bfin_read16(&reg->ctrl) & ~CCR);
+	bfin_write16(&reg->control, bfin_read16(&reg->control) & ~CCR);
 
 	while (bfin_read16(&reg->status) & CCA) {
 		udelay(10);
@@ -726,7 +643,7 @@ static int bfin_can_suspend(struct platform_device *pdev, pm_message_t mesg)
 
 	if (netif_running(dev)) {
 		/* enter sleep mode */
-		bfin_write16(&reg->ctrl, bfin_read16(&reg->ctrl) | SMR);
+		bfin_write16(&reg->control, bfin_read16(&reg->control) | SMR);
 		SSYNC();
 		while (!(bfin_read16(&reg->intr) & SMACK)) {
 			udelay(10);
-- 
1.7.0.2

