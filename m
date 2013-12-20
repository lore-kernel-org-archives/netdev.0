From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v3 2/8] b44: rename B44_PHY_ADDR_NO_PHY to B44_PHY_ADDR_NO_LOCAL_PHY
Date: Fri, 20 Dec 2013 02:16:07 +0100
Message-ID: <1387502173-21743-3-git-send-email-hauke@hauke-m.de>
References: <1387502173-21743-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	f.fainelli@gmail.com, Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:53947 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755598Ab3LTBQc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 20:16:32 -0500
In-Reply-To: <1387502173-21743-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY address 30 means there is no local PHY, but there could be an
external PHY like a switch connected via MII. This is the case on most
embedded home routers where this driver is used.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c |    2 +-
 drivers/net/ethernet/broadcom/b44.h |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 3c7909e..5c05d15 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2237,7 +2237,7 @@ static int b44_init_one(struct ssb_device *sdev,
 
 	/* do a phy reset to test if there is an active phy */
 	if (b44_phy_reset(bp) < 0)
-		bp->phy_addr = B44_PHY_ADDR_NO_PHY;
+		bp->phy_addr = B44_PHY_ADDR_NO_LOCAL_PHY;
 
 	netdev_info(dev, "%s %pM\n", DRV_DESCRIPTION, dev->dev_addr);
 
diff --git a/drivers/net/ethernet/broadcom/b44.h b/drivers/net/ethernet/broadcom/b44.h
index 8ed7d6b..57e5357 100644
--- a/drivers/net/ethernet/broadcom/b44.h
+++ b/drivers/net/ethernet/broadcom/b44.h
@@ -280,9 +280,9 @@ struct ring_info {
 	dma_addr_t	mapping;
 };
 
-#define B44_MCAST_TABLE_SIZE	32
-#define B44_PHY_ADDR_NO_PHY	30
-#define B44_MDC_RATIO		5000000
+#define B44_MCAST_TABLE_SIZE		32
+#define B44_PHY_ADDR_NO_LOCAL_PHY	30 /* no local phy regs */
+#define B44_MDC_RATIO			5000000
 
 #define	B44_STAT_REG_DECLARE		\
 	_B44(tx_good_octets)		\
-- 
1.7.10.4
