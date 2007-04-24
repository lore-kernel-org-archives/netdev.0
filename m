From: "Michael Chan" <mchan@broadcom.com>
Subject: [BNX2]: Fix occasional NETDEV WATCHDOG on 5709.
Date: Tue, 24 Apr 2007 15:57:45 -0700
Message-ID: <1177455465.4812.20.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1230 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423154AbXDXWL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 18:11:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix occasional NETDEV WATCHDOG on 5709.

Tweak a register setting to prevent the tx mailbox from halting.

Update version to 1.5.8.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 0b7aded..e85f5ec 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -54,8 +54,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.5.7"
-#define DRV_MODULE_RELDATE	"March 29, 2007"
+#define DRV_MODULE_VERSION	"1.5.8"
+#define DRV_MODULE_RELDATE	"April 24, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -3421,6 +3421,9 @@ bnx2_init_chip(struct bnx2 *bp)
 	val = REG_RD(bp, BNX2_MQ_CONFIG);
 	val &= ~BNX2_MQ_CONFIG_KNL_BYP_BLK_SIZE;
 	val |= BNX2_MQ_CONFIG_KNL_BYP_BLK_SIZE_256;
+	if (CHIP_ID(bp) == CHIP_ID_5709_A0 || CHIP_ID(bp) == CHIP_ID_5709_A1)
+		val |= BNX2_MQ_CONFIG_HALT_DIS;
+
 	REG_WR(bp, BNX2_MQ_CONFIG, val);
 
 	val = 0x10000 + (MAX_CID_CNT * MB_KERNEL_CTX_SIZE);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index ccbdf81..878eee5 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6518,6 +6518,7 @@ struct bnx2 {
 #define CHIP_ID_5708_B0			0x57081000
 #define CHIP_ID_5708_B1			0x57081010
 #define CHIP_ID_5709_A0			0x57090000
+#define CHIP_ID_5709_A1			0x57090010
 
 #define CHIP_BOND_ID(bp)		(((bp)->chip_id) & 0xf)
 


