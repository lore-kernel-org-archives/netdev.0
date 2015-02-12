From: Vince Bridgers <vbridger@opensource.altera.com>
Subject: [PATCH net] net: eth: altera: Change access ports to mdio for all xMII applications
Date: Thu, 12 Feb 2015 10:47:33 -0600
Message-ID: <1423759653-5023-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vbridger@altera.com>, <vbridger@opensource.altera.com>,
	<kailng@altera.com>, <dwesterg@gmail.com>
To: <netdev@vger.kernel.org>, <nios2-dev@lists.rocketboards.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change use of Altera TSE's MDIO access from phy 0 registers to phy 1
registers. This allows support for GMII, MII, RGMII, and SGMII
designs where the external PHY is always accesible through
Altera TSE's MDIO phy 1 registers and Altera's PCS is accessible
through MDIO phy 0 registers for SGMII applications.

Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>
Tested-by: Kai Lin Ng <kailng@altera.com>
Tested-by: Dalon Westergreen <dwesterg@gmail.com>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 996bdf1..a1ee261 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -105,11 +105,11 @@ static int altera_tse_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 
 	/* set MDIO address */
 	csrwr32((mii_id & 0x1f), priv->mac_dev,
-		tse_csroffs(mdio_phy0_addr));
+		tse_csroffs(mdio_phy1_addr));
 
 	/* get the data */
 	return csrrd32(priv->mac_dev,
-		       tse_csroffs(mdio_phy0) + regnum * 4) & 0xffff;
+		       tse_csroffs(mdio_phy1) + regnum * 4) & 0xffff;
 }
 
 static int altera_tse_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
@@ -120,10 +120,10 @@ static int altera_tse_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 
 	/* set MDIO address */
 	csrwr32((mii_id & 0x1f), priv->mac_dev,
-		tse_csroffs(mdio_phy0_addr));
+		tse_csroffs(mdio_phy1_addr));
 
 	/* write the data */
-	csrwr32(value, priv->mac_dev, tse_csroffs(mdio_phy0) + regnum * 4);
+	csrwr32(value, priv->mac_dev, tse_csroffs(mdio_phy1) + regnum * 4);
 	return 0;
 }
 
-- 
1.9.1
