From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/2] bnx2: Add missing netif_tx_disable() in
 bnx2_close()
Date: Wed, 27 Jun 2012 18:08:24 -0700
Message-ID: <1340845704-12580-6-git-send-email-mchan@broadcom.com>
References: <1340845704-12580-1-git-send-email-mchan@broadcom.com>
 <1340845704-12580-2-git-send-email-mchan@broadcom.com>
 <1340845704-12580-3-git-send-email-mchan@broadcom.com>
 <1340845704-12580-4-git-send-email-mchan@broadcom.com>
 <1340845704-12580-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3197 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932193Ab2F1A50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 20:57:26 -0400
In-Reply-To: <1340845704-12580-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to stop all tx queues.  Update version to 2.2.3.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index e6116ec..9eb7624 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -58,8 +58,8 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.2.2"
-#define DRV_MODULE_RELDATE	"June 16, 2012"
+#define DRV_MODULE_VERSION	"2.2.3"
+#define DRV_MODULE_RELDATE	"June 27, 2012"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-6.2.3.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-6.0.15.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-6.2.1b.fw"
@@ -6703,6 +6703,7 @@ bnx2_close(struct net_device *dev)
 
 	bnx2_disable_int_sync(bp);
 	bnx2_napi_disable(bp);
+	netif_tx_disable(dev);
 	del_timer_sync(&bp->timer);
 	bnx2_shutdown_chip(bp);
 	bnx2_free_irq(bp);
-- 
1.7.1
