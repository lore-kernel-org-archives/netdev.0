From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 2/7] bnx2x: store module parameters in driver
 main structure
Date: Tue, 27 Jul 2010 22:05:41 +0300
Message-ID: <1280257541.8566.12.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4412 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980Ab0G0TQT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 15:16:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Store module parameters during initialization of main driver
structure. This will allow access to the parameters from different
files.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h      |    2 ++
 drivers/net/bnx2x/bnx2x_main.c |    7 ++++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 3b51c5f..237609f 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1006,6 +1006,8 @@ struct bnx2x {
 
 	int			multi_mode;
 	int			num_queues;
+	int			disable_tpa;
+	int			int_mode;
 
 	u32			rx_mode;
 #define BNX2X_RX_MODE_NONE		0
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 51b7883..1e0ac8b 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -7878,7 +7878,7 @@ static int bnx2x_set_num_queues(struct bnx2x *bp)
 {
 	int rc = 0;
 
-	switch (int_mode) {
+	switch (bp->int_mode) {
 	case INT_MODE_INTx:
 	case INT_MODE_MSI:
 		bp->num_queues = 1;
@@ -9951,7 +9951,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 		multi_mode = ETH_RSS_MODE_DISABLED;
 	}
 	bp->multi_mode = multi_mode;
-
+	bp->int_mode = int_mode;
 
 	bp->dev->features |= NETIF_F_GRO;
 
@@ -9963,6 +9963,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 		bp->flags |= TPA_ENABLE_FLAG;
 		bp->dev->features |= NETIF_F_LRO;
 	}
+	bp->disable_tpa = disable_tpa;
 
 	if (CHIP_IS_E1(bp))
 		bp->dropless_fc = 0;
@@ -11006,7 +11007,7 @@ static int bnx2x_set_flags(struct net_device *dev, u32 data)
 
 	/* TPA requires Rx CSUM offloading */
 	if ((data & ETH_FLAG_LRO) && bp->rx_csum) {
-		if (!disable_tpa) {
+		if (!bp->disable_tpa) {
 			if (!(dev->features & NETIF_F_LRO)) {
 				dev->features |= NETIF_F_LRO;
 				bp->flags |= TPA_ENABLE_FLAG;
-- 
1.7.1




