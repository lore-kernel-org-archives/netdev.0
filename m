From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 4/8] b44: rename b44_mii_{read,write} to b44_mdio_{read,write}_mii
Date: Sun, 15 Dec 2013 19:42:01 +0100
Message-ID: <1387132925-18651-5-git-send-email-hauke@hauke-m.de>
References: <1387132925-18651-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:50606 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751898Ab3LOSmZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Dec 2013 13:42:25 -0500
In-Reply-To: <1387132925-18651-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The next patch will add these functions for phylib, and we should
rename the old ones before. This now indicates that these functions are
used for the mdio registers and on the mii interface.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 6cffe65..c19319c 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -299,7 +299,7 @@ static inline int b44_writephy(struct b44 *bp, int reg, u32 val)
 }
 
 /* miilib interface */
-static int b44_mii_read(struct net_device *dev, int phy_id, int location)
+static int b44_mdio_read_mii(struct net_device *dev, int phy_id, int location)
 {
 	u32 val;
 	struct b44 *bp = netdev_priv(dev);
@@ -309,8 +309,8 @@ static int b44_mii_read(struct net_device *dev, int phy_id, int location)
 	return val;
 }
 
-static void b44_mii_write(struct net_device *dev, int phy_id, int location,
-			 int val)
+static void b44_mdio_write_mii(struct net_device *dev, int phy_id, int location,
+			       int val)
 {
 	struct b44 *bp = netdev_priv(dev);
 	__b44_writephy(bp, phy_id, location, val);
@@ -2213,8 +2213,8 @@ static int b44_init_one(struct ssb_device *sdev,
 	}
 
 	bp->mii_if.dev = dev;
-	bp->mii_if.mdio_read = b44_mii_read;
-	bp->mii_if.mdio_write = b44_mii_write;
+	bp->mii_if.mdio_read = b44_mdio_read_mii;
+	bp->mii_if.mdio_write = b44_mdio_write_mii;
 	bp->mii_if.phy_id = bp->phy_addr;
 	bp->mii_if.phy_id_mask = 0x1f;
 	bp->mii_if.reg_num_mask = 0x1f;
-- 
1.7.10.4
