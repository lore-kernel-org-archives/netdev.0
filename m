From: <srinivas.kandagatla@st.com>
Subject: [PATCH v2 5/9] net: stmmac: make stmmac_mdio_reset non-static
Date: Thu, 16 Jan 2014 10:52:27 +0000
Message-ID: <1389869547-28218-1-git-send-email-srinivas.kandagatla@st.com>
References: <1389869450-28003-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	David Miller <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <srinivas.kandagatla@st.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389869450-28003-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch promotes stmmac_mdio_reset function from static to
non-static, so that power management functions can decide to reset if
the IP comes out from lowe power state specially hibernation cases.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 92be6b3..5a568015 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -110,6 +110,7 @@ struct stmmac_priv {
 
 int stmmac_mdio_unregister(struct net_device *ndev);
 int stmmac_mdio_register(struct net_device *ndev);
+int stmmac_mdio_reset(struct mii_bus *mii);
 void stmmac_set_ethtool_ops(struct net_device *netdev);
 extern const struct stmmac_desc_ops enh_desc_ops;
 extern const struct stmmac_desc_ops ndesc_ops;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index aab12d2..a468eb1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -128,7 +128,7 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
  * @bus: points to the mii_bus structure
  * Description: reset the MII bus
  */
-static int stmmac_mdio_reset(struct mii_bus *bus)
+int stmmac_mdio_reset(struct mii_bus *bus)
 {
 #if defined(CONFIG_STMMAC_PLATFORM)
 	struct net_device *ndev = bus->priv;
-- 
1.7.6.5
