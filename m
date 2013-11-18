From: <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 5/9] net: stmmac: make stmmac_mdio_reset non-static
Date: Mon, 18 Nov 2013 11:32:06 +0000
Message-ID: <1384774326-10262-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <srinivas.kandagatla@st.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog125.obsmtp.com ([207.126.144.159]:58348 "EHLO
	eu1sys200aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751766Ab3KRLd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 06:33:56 -0500
In-Reply-To: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch promotes stmmac_mdio_reset function from static to
non-static, so that power management functions can decide to reset if
the IP comes out from lowe power state specially hibernation cases.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 22f89ff..8c3fed3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -112,6 +112,7 @@ extern int phyaddr;
 
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
