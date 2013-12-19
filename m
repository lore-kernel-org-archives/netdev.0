From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2 4/9] b44: abort when no PHY is available at all
Date: Thu, 19 Dec 2013 02:28:41 +0100
Message-ID: <1387416526-7394-5-git-send-email-hauke@hauke-m.de>
References: <1387416526-7394-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	f.fainelli@gmail.com, Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:44343 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752379Ab3LSB3y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 20:29:54 -0500
In-Reply-To: <1387416526-7394-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the phy address is 31, this means that there is no PHY connected
to this MAC at all, no internal and no external PHY. Reading these PHY
registers causes a system reset on some routers.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c |    6 ++++++
 drivers/net/ethernet/broadcom/b44.h |    1 +
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 5c05d15..09e9e97 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2206,6 +2206,12 @@ static int b44_init_one(struct ssb_device *sdev,
 		goto err_out_powerdown;
 	}
 
+	if (bp->phy_addr == B44_PHY_ADDR_NO_PHY) {
+		dev_err(sdev->dev, "No PHY present on this MAC, aborting\n");
+		err = -ENODEV;
+		goto err_out_powerdown;
+	}
+
 	bp->mii_if.dev = dev;
 	bp->mii_if.mdio_read = b44_mii_read;
 	bp->mii_if.mdio_write = b44_mii_write;
diff --git a/drivers/net/ethernet/broadcom/b44.h b/drivers/net/ethernet/broadcom/b44.h
index 57e5357..4b0c5d2 100644
--- a/drivers/net/ethernet/broadcom/b44.h
+++ b/drivers/net/ethernet/broadcom/b44.h
@@ -282,6 +282,7 @@ struct ring_info {
 
 #define B44_MCAST_TABLE_SIZE		32
 #define B44_PHY_ADDR_NO_LOCAL_PHY	30 /* no local phy regs */
+#define B44_PHY_ADDR_NO_PHY		31 /* no phy present at all */
 #define B44_MDC_RATIO			5000000
 
 #define	B44_STAT_REG_DECLARE		\
-- 
1.7.10.4
