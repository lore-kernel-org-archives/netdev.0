From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: [PATCH 3/6] pch_gbe: change order of PHY address discovering
Date: Mon, 26 May 2014 15:40:36 +0200
Message-ID: <1401111639-11507-3-git-send-email-alexander.stein@systec-electronic.com>
References: <1401111639-11507-1-git-send-email-alexander.stein@systec-electronic.com>
Cc: Daniel Krueger <daniel.krueger@systec-electronic.com>,
	netdev@vger.kernel.org,
	Alexander Stein <alexander.stein@systec-electronic.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:58895 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752569AbaEZNm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 09:42:28 -0400
In-Reply-To: <1401111639-11507-1-git-send-email-alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Krueger <daniel.krueger@systec-electronic.com>

Scan PHY address 0 after all other addresses. Address 0 is a multicast
address which unfortunately does not work properly with Micrel KSZ9021.
Our board uses PHY address 2.

Signed-off-by: Daniel Krueger <daniel.krueger@systec-electronic.com>
Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 693ee50..52e6cbd 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -662,9 +662,9 @@ static int pch_gbe_init_phy(struct pch_gbe_adapter *adapter)
 	u32 addr;
 	u16 bmcr, stat;
 
-	/* Discover phy addr by searching addrs in order {1,0,2,..., 31} */
+	/* Discover phy addr by searching addrs in order {1,2,...,31,0} */
 	for (addr = 0; addr < PCH_GBE_PHY_REGS_LEN; addr++) {
-		adapter->mii.phy_id = (addr == 0) ? 1 : (addr == 1) ? 0 : addr;
+		adapter->mii.phy_id = (addr == 31) ? 0 : (addr + 1);
 		bmcr = pch_gbe_mdio_read(netdev, adapter->mii.phy_id, MII_BMCR);
 		stat = pch_gbe_mdio_read(netdev, adapter->mii.phy_id, MII_BMSR);
 		stat = pch_gbe_mdio_read(netdev, adapter->mii.phy_id, MII_BMSR);
-- 
1.8.5.5
