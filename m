From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/2] bnx2: Turn off link during shutdown
Date: Wed, 28 Jun 2006 10:59:20 -0700
Message-ID: <1151517560.3502.20.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:6160 "EHLO mms1.broadcom.com")
	by vger.kernel.org with ESMTP id S1751516AbWF1R6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 13:58:17 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor change in shutdown logic to effect a link down.

Update version to 1.4.43.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index e59cb59..d55b0f7 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.4.42"
-#define DRV_MODULE_RELDATE	"June 12, 2006"
+#define DRV_MODULE_VERSION	"1.4.43"
+#define DRV_MODULE_RELDATE	"June 28, 2006"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -4541,7 +4541,7 @@ bnx2_close(struct net_device *dev)
 	bnx2_netif_stop(bp);
 	del_timer_sync(&bp->timer);
 	if (bp->flags & NO_WOL_FLAG)
-		reset_code = BNX2_DRV_MSG_CODE_UNLOAD;
+		reset_code = BNX2_DRV_MSG_CODE_UNLOAD_LNK_DN;
 	else if (bp->wol)
 		reset_code = BNX2_DRV_MSG_CODE_SUSPEND_WOL;
 	else
@@ -5978,7 +5978,7 @@ bnx2_suspend(struct pci_dev *pdev, pm_me
 	netif_device_detach(dev);
 	del_timer_sync(&bp->timer);
 	if (bp->flags & NO_WOL_FLAG)
-		reset_code = BNX2_DRV_MSG_CODE_UNLOAD;
+		reset_code = BNX2_DRV_MSG_CODE_UNLOAD_LNK_DN;
 	else if (bp->wol)
 		reset_code = BNX2_DRV_MSG_CODE_SUSPEND_WOL;
 	else
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 5845e33..658c5ee 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -4174,6 +4174,7 @@ struct fw_info {
 #define BNX2_DRV_MSG_CODE_PULSE			 0x06000000
 #define BNX2_DRV_MSG_CODE_DIAG			 0x07000000
 #define BNX2_DRV_MSG_CODE_SUSPEND_NO_WOL	 0x09000000
+#define BNX2_DRV_MSG_CODE_UNLOAD_LNK_DN		 0x0b000000
 
 #define BNX2_DRV_MSG_DATA			 0x00ff0000
 #define BNX2_DRV_MSG_DATA_WAIT0			 0x00010000


