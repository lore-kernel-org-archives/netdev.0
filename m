From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] drivers: net: xgene: constify xgene_mac_ops and xgene_port_ops structures
Date: Tue,  8 Dec 2015 21:18:25 +0100
Message-ID: <1449605905-32342-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, Keyur Chudgar <kchudgar@apm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The xgene_mac_ops and xgene_port_ops structures are never modified, so
declare them as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    |    4 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |    4 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |    8 ++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |    4 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c |    4 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h |    4 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |    4 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h |    4 ++--
 8 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index c31e691..db55c9f 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -869,7 +869,7 @@ void xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata)
 	pdata->mdio_bus = NULL;
 }
 
-struct xgene_mac_ops xgene_gmac_ops = {
+const struct xgene_mac_ops xgene_gmac_ops = {
 	.init = xgene_gmac_init,
 	.reset = xgene_gmac_reset,
 	.rx_enable = xgene_gmac_rx_enable,
@@ -879,7 +879,7 @@ struct xgene_mac_ops xgene_gmac_ops = {
 	.set_mac_addr = xgene_gmac_set_mac_addr,
 };
 
-struct xgene_port_ops xgene_gport_ops = {
+const struct xgene_port_ops xgene_gport_ops = {
 	.reset = xgene_enet_reset,
 	.cle_bypass = xgene_enet_cle_bypass,
 	.shutdown = xgene_gport_shutdown,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index c153a1d..8a90910 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -340,8 +340,8 @@ int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata);
 void xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata);
 bool xgene_ring_mgr_init(struct xgene_enet_pdata *p);
 
-extern struct xgene_mac_ops xgene_gmac_ops;
-extern struct xgene_port_ops xgene_gport_ops;
+extern const struct xgene_mac_ops xgene_gmac_ops;
+extern const struct xgene_port_ops xgene_gport_ops;
 extern struct xgene_ring_ops xgene_ring1_ops;
 
 #endif /* __XGENE_ENET_HW_H__ */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index d21ee87..2394191 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -682,7 +682,7 @@ static void xgene_enet_napi_disable(struct xgene_enet_pdata *pdata)
 static int xgene_enet_open(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
-	struct xgene_mac_ops *mac_ops = pdata->mac_ops;
+	const struct xgene_mac_ops *mac_ops = pdata->mac_ops;
 	int ret;
 
 	mac_ops->tx_enable(pdata);
@@ -706,7 +706,7 @@ static int xgene_enet_open(struct net_device *ndev)
 static int xgene_enet_close(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
-	struct xgene_mac_ops *mac_ops = pdata->mac_ops;
+	const struct xgene_mac_ops *mac_ops = pdata->mac_ops;
 
 	netif_stop_queue(ndev);
 
@@ -1416,7 +1416,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	struct net_device *ndev;
 	struct xgene_enet_pdata *pdata;
 	struct device *dev = &pdev->dev;
-	struct xgene_mac_ops *mac_ops;
+	const struct xgene_mac_ops *mac_ops;
 	const struct of_device_id *of_id;
 	int ret;
 
@@ -1503,7 +1503,7 @@ err:
 static int xgene_enet_remove(struct platform_device *pdev)
 {
 	struct xgene_enet_pdata *pdata;
-	struct xgene_mac_ops *mac_ops;
+	const struct xgene_mac_ops *mac_ops;
 	struct net_device *ndev;
 
 	pdata = platform_get_drvdata(pdev);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index a6e56b8..054caf0 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -174,8 +174,8 @@ struct xgene_enet_pdata {
 	int phy_mode;
 	enum xgene_enet_rm rm;
 	struct rtnl_link_stats64 stats;
-	struct xgene_mac_ops *mac_ops;
-	struct xgene_port_ops *port_ops;
+	const struct xgene_mac_ops *mac_ops;
+	const struct xgene_port_ops *port_ops;
 	struct xgene_ring_ops *ring_ops;
 	struct delayed_work link_work;
 	u32 port_id;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index 05b817e..7847551 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -405,7 +405,7 @@ static void xgene_enet_link_state(struct work_struct *work)
 	schedule_delayed_work(&p->link_work, poll_interval);
 }
 
-struct xgene_mac_ops xgene_sgmac_ops = {
+const struct xgene_mac_ops xgene_sgmac_ops = {
 	.init		= xgene_sgmac_init,
 	.reset		= xgene_sgmac_reset,
 	.rx_enable	= xgene_sgmac_rx_enable,
@@ -416,7 +416,7 @@ struct xgene_mac_ops xgene_sgmac_ops = {
 	.link_state	= xgene_enet_link_state
 };
 
-struct xgene_port_ops xgene_sgport_ops = {
+const struct xgene_port_ops xgene_sgport_ops = {
 	.reset		= xgene_enet_reset,
 	.cle_bypass	= xgene_enet_cle_bypass,
 	.shutdown	= xgene_enet_shutdown
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
index de43246..29a71b4 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
@@ -35,7 +35,7 @@
 #define MPA_IDLE_WITH_QMI_EMPTY		BIT(12)
 #define SG_RX_DV_GATE_REG_0_ADDR	0x0dfc
 
-extern struct xgene_mac_ops xgene_sgmac_ops;
-extern struct xgene_port_ops xgene_sgport_ops;
+extern const struct xgene_mac_ops xgene_sgmac_ops;
+extern const struct xgene_port_ops xgene_sgport_ops;
 
 #endif  /* __XGENE_ENET_SGMAC_H__ */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index 7a28a48..ba030dc 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -326,7 +326,7 @@ static void xgene_enet_link_state(struct work_struct *work)
 	schedule_delayed_work(&pdata->link_work, poll_interval);
 }
 
-struct xgene_mac_ops xgene_xgmac_ops = {
+const struct xgene_mac_ops xgene_xgmac_ops = {
 	.init = xgene_xgmac_init,
 	.reset = xgene_xgmac_reset,
 	.rx_enable = xgene_xgmac_rx_enable,
@@ -338,7 +338,7 @@ struct xgene_mac_ops xgene_xgmac_ops = {
 	.link_state = xgene_enet_link_state
 };
 
-struct xgene_port_ops xgene_xgport_ops = {
+const struct xgene_port_ops xgene_xgport_ops = {
 	.reset = xgene_enet_reset,
 	.cle_bypass = xgene_enet_xgcle_bypass,
 	.shutdown = xgene_enet_shutdown,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
index f8f908d..0a2dca8 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
@@ -69,7 +69,7 @@
 #define XG_ENET_SPARE_CFG_REG_1_ADDR	0x0410
 #define XGENET_RX_DV_GATE_REG_0_ADDR	0x0804
 
-extern struct xgene_mac_ops xgene_xgmac_ops;
-extern struct xgene_port_ops xgene_xgport_ops;
+extern const struct xgene_mac_ops xgene_xgmac_ops;
+extern const struct xgene_port_ops xgene_xgport_ops;
 
 #endif /* __XGENE_ENET_XGMAC_H__ */
