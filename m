From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: [PATCH] net: stmmac: fix incorrect bit set in gmac4 mdio addr register
Date: Wed, 28 Dec 2016 04:07:41 +0800
Message-ID: <1482869261-23803-1-git-send-email-hock.leong.kweh@intel.com>
Cc: Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, pavel@ucw.cz,
        Ong Boon Leong <boon.leong.ong@intel.com>,
        "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
        weifeng.voon@intel.com, lars.persson@axis.com,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        seraphin.bonnaffe@st.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:48475 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754279AbcL0MDH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Dec 2016 07:03:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>

Fixing the gmac4 mdio write access to use MII_GMAC4_WRITE only instead of
OR together with MII_WRITE.

Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index fda01f7..b0344c2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -116,7 +116,7 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 	unsigned int mii_address = priv->hw->mii.addr;
 	unsigned int mii_data = priv->hw->mii.data;
 
-	u32 value = MII_WRITE | MII_BUSY;
+	u32 value = MII_BUSY;
 
 	value |= (phyaddr << priv->hw->mii.addr_shift)
 		& priv->hw->mii.addr_mask;
@@ -126,6 +126,8 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 		& priv->hw->mii.clk_csr_mask;
 	if (priv->plat->has_gmac4)
 		value |= MII_GMAC4_WRITE;
+	else
+		value |= MII_WRITE;
 
 	/* Wait until any existing MII operation is complete */
 	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
-- 
1.7.9.5
