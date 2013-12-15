From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 3/8] b44: abort when no PHY is available at all
Date: Sun, 15 Dec 2013 19:42:00 +0100
Message-ID: <1387132925-18651-4-git-send-email-hauke@hauke-m.de>
References: <1387132925-18651-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:50600 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751938Ab3LOSmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Dec 2013 13:42:21 -0500
In-Reply-To: <1387132925-18651-1-git-send-email-hauke@hauke-m.de>
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
index fce36dd..6cffe65 100644
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
index ade80d6..e3ee9ca2 100644
--- a/drivers/net/ethernet/broadcom/b44.h
+++ b/drivers/net/ethernet/broadcom/b44.h
@@ -282,6 +282,7 @@ struct ring_info {
 
 #define B44_MCAST_TABLE_SIZE		32
 #define B44_PHY_ADDR_NO_LOACL_PHY	30 /* no local phy regs */
+#define B44_PHY_ADDR_NO_PHY		31 /* no phy present at all */
 #define B44_MDC_RATIO			5000000
 
 #define	B44_STAT_REG_DECLARE		\
-- 
1.7.10.4
