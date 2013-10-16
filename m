From: Nikita Kiryanov <nikita@compulab.co.il>
Subject: [PATCH 1/4] dm9000: during init reset phy only for dm9000b
Date: Wed, 16 Oct 2013 11:41:31 +0300
Message-ID: <1381912894-4780-2-git-send-email-nikita@compulab.co.il>
References: <1381912894-4780-1-git-send-email-nikita@compulab.co.il>
Cc: Nikita Kiryanov <nikita@compulab.co.il>,
	"David S. Miller" <davem@davemloft.net>,
	Jingoo Han <jg1.han@samsung.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Igor Grinberg <grinberg@compulab.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from softlayer.compulab.co.il ([50.23.254.55]:53064 "EHLO
	compulab.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755174Ab3JPImK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 04:42:10 -0400
In-Reply-To: <1381912894-4780-1-git-send-email-nikita@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the changes introduced in commit 6741f40 (DM9000B: driver
initialization upgrade) break functionality on DM9000A
(error message during NFS boot: "dm9000 dm9000.0: eth0: link down")

Since the changes were meant to serve only DM9000B, make them
dependent on the chip type.

Cc: David S. Miller <davem@davemloft.net>
Cc: Jingoo Han <jg1.han@samsung.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Nikita Kiryanov <nikita@compulab.co.il>
Signed-off-by: Igor Grinberg <grinberg@compulab.co.il>
---
 drivers/net/ethernet/davicom/dm9000.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 5f5896e..912983b 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -891,8 +891,13 @@ dm9000_init_dm9000(struct net_device *dev)
 
 	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
 
-	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET); /* PHY RESET */
-	dm9000_phy_write(dev, 0, MII_DM_DSPCR, DSPCR_INIT_PARAM); /* Init */
+	/* If we are dealing with DM9000B, some extra steps are required: a
+	 * manual phy reset, and setting init params.
+	 */
+	if (db->type == TYPE_DM9000B) {
+		dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);
+		dm9000_phy_write(dev, 0, MII_DM_DSPCR, DSPCR_INIT_PARAM);
+	}
 
 	ncr = (db->flags & DM9000_PLATF_EXT_PHY) ? NCR_EXT_PHY : 0;
 
-- 
1.8.1.2
