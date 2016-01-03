From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] chelsio: constify cphy_ops structures
Date: Sun,  3 Jan 2016 14:09:37 +0100
Message-ID: <1451826577-21403-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Santosh Raspatur <santosh@chelsio.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cphy_ops structures are never modified, so declare them as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/chelsio/cxgb/cphy.h      |    2 +-
 drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.c |    2 +-
 drivers/net/ethernet/chelsio/cxgb/mv88x201x.c |    2 +-
 drivers/net/ethernet/chelsio/cxgb/my3126.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/ael1002.c  |   12 ++++++------
 drivers/net/ethernet/chelsio/cxgb3/aq100x.c   |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/common.h   |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/vsc8211.c  |    4 ++--
 8 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/cphy.h b/drivers/net/ethernet/chelsio/cxgb/cphy.h
index a4d2a4c..bf43da6 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cphy.h
+++ b/drivers/net/ethernet/chelsio/cxgb/cphy.h
@@ -137,7 +137,7 @@ static inline int simple_mdio_write(struct cphy *cphy, int reg,
 
 /* Convenience initializer */
 static inline void cphy_init(struct cphy *phy, struct net_device *dev,
-			     int phy_addr, struct cphy_ops *phy_ops,
+			     int phy_addr, const struct cphy_ops *phy_ops,
 			     const struct mdio_ops *mdio_ops)
 {
 	struct adapter *adapter = netdev_priv(dev);
diff --git a/drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.c b/drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.c
index 71018a4..76ce6e5 100644
--- a/drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.c
+++ b/drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.c
@@ -337,7 +337,7 @@ static void mv88e1xxx_destroy(struct cphy *cphy)
 	kfree(cphy);
 }
 
-static struct cphy_ops mv88e1xxx_ops = {
+static const struct cphy_ops mv88e1xxx_ops = {
 	.destroy              = mv88e1xxx_destroy,
 	.reset                = mv88e1xxx_reset,
 	.interrupt_enable     = mv88e1xxx_interrupt_enable,
diff --git a/drivers/net/ethernet/chelsio/cxgb/mv88x201x.c b/drivers/net/ethernet/chelsio/cxgb/mv88x201x.c
index d0cf611..7ddb301 100644
--- a/drivers/net/ethernet/chelsio/cxgb/mv88x201x.c
+++ b/drivers/net/ethernet/chelsio/cxgb/mv88x201x.c
@@ -195,7 +195,7 @@ static void mv88x201x_destroy(struct cphy *cphy)
 	kfree(cphy);
 }
 
-static struct cphy_ops mv88x201x_ops = {
+static const struct cphy_ops mv88x201x_ops = {
 	.destroy           = mv88x201x_destroy,
 	.reset             = mv88x201x_reset,
 	.interrupt_enable  = mv88x201x_interrupt_enable,
diff --git a/drivers/net/ethernet/chelsio/cxgb/my3126.c b/drivers/net/ethernet/chelsio/cxgb/my3126.c
index a683fd3..d546f46 100644
--- a/drivers/net/ethernet/chelsio/cxgb/my3126.c
+++ b/drivers/net/ethernet/chelsio/cxgb/my3126.c
@@ -154,7 +154,7 @@ static void my3126_destroy(struct cphy *cphy)
 	kfree(cphy);
 }
 
-static struct cphy_ops my3126_ops = {
+static const struct cphy_ops my3126_ops = {
 	.destroy		= my3126_destroy,
 	.reset			= my3126_reset,
 	.interrupt_enable	= my3126_interrupt_enable,
diff --git a/drivers/net/ethernet/chelsio/cxgb3/ael1002.c b/drivers/net/ethernet/chelsio/cxgb3/ael1002.c
index 2028da9..dadf11e 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/ael1002.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/ael1002.c
@@ -198,7 +198,7 @@ static int get_link_status_r(struct cphy *phy, int *link_ok, int *speed,
 	return 0;
 }
 
-static struct cphy_ops ael1002_ops = {
+static const struct cphy_ops ael1002_ops = {
 	.reset = ael1002_reset,
 	.intr_enable = ael1002_intr_noop,
 	.intr_disable = ael1002_intr_noop,
@@ -224,7 +224,7 @@ static int ael1006_reset(struct cphy *phy, int wait)
 	return t3_phy_reset(phy, MDIO_MMD_PMAPMD, wait);
 }
 
-static struct cphy_ops ael1006_ops = {
+static const struct cphy_ops ael1006_ops = {
 	.reset = ael1006_reset,
 	.intr_enable = t3_phy_lasi_intr_enable,
 	.intr_disable = t3_phy_lasi_intr_disable,
@@ -495,7 +495,7 @@ static int ael2005_intr_handler(struct cphy *phy)
 	return ret ? ret : cphy_cause_link_change;
 }
 
-static struct cphy_ops ael2005_ops = {
+static const struct cphy_ops ael2005_ops = {
 	.reset           = ael2005_reset,
 	.intr_enable     = ael2005_intr_enable,
 	.intr_disable    = ael2005_intr_disable,
@@ -801,7 +801,7 @@ static int ael2020_intr_handler(struct cphy *phy)
 	return ret ? ret : cphy_cause_link_change;
 }
 
-static struct cphy_ops ael2020_ops = {
+static const struct cphy_ops ael2020_ops = {
 	.reset           = ael2020_reset,
 	.intr_enable     = ael2020_intr_enable,
 	.intr_disable    = ael2020_intr_disable,
@@ -856,7 +856,7 @@ static int get_link_status_x(struct cphy *phy, int *link_ok, int *speed,
 	return 0;
 }
 
-static struct cphy_ops qt2045_ops = {
+static const struct cphy_ops qt2045_ops = {
 	.reset = ael1006_reset,
 	.intr_enable = t3_phy_lasi_intr_enable,
 	.intr_disable = t3_phy_lasi_intr_disable,
@@ -921,7 +921,7 @@ static int xaui_direct_power_down(struct cphy *phy, int enable)
 	return 0;
 }
 
-static struct cphy_ops xaui_direct_ops = {
+static const struct cphy_ops xaui_direct_ops = {
 	.reset = xaui_direct_reset,
 	.intr_enable = ael1002_intr_noop,
 	.intr_disable = ael1002_intr_noop,
diff --git a/drivers/net/ethernet/chelsio/cxgb3/aq100x.c b/drivers/net/ethernet/chelsio/cxgb3/aq100x.c
index 341b7ef..6af5d20 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/aq100x.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/aq100x.c
@@ -247,7 +247,7 @@ static int aq100x_get_link_status(struct cphy *phy, int *link_ok,
 	return 0;
 }
 
-static struct cphy_ops aq100x_ops = {
+static const struct cphy_ops aq100x_ops = {
 	.reset             = aq100x_reset,
 	.intr_enable       = aq100x_intr_enable,
 	.intr_disable      = aq100x_intr_disable,
diff --git a/drivers/net/ethernet/chelsio/cxgb3/common.h b/drivers/net/ethernet/chelsio/cxgb3/common.h
index 4424809..1bd7d89 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/common.h
+++ b/drivers/net/ethernet/chelsio/cxgb3/common.h
@@ -575,7 +575,7 @@ static inline int t3_mdio_write(struct cphy *phy, int mmd, int reg,
 
 /* Convenience initializer */
 static inline void cphy_init(struct cphy *phy, struct adapter *adapter,
-			     int phy_addr, struct cphy_ops *phy_ops,
+			     int phy_addr, const struct cphy_ops *phy_ops,
 			     const struct mdio_ops *mdio_ops,
 			      unsigned int caps, const char *desc)
 {
diff --git a/drivers/net/ethernet/chelsio/cxgb3/vsc8211.c b/drivers/net/ethernet/chelsio/cxgb3/vsc8211.c
index 4f9a1c2..8638ad4 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/vsc8211.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/vsc8211.c
@@ -336,7 +336,7 @@ static int vsc8211_intr_handler(struct cphy *cphy)
 	return cphy_cause;
 }
 
-static struct cphy_ops vsc8211_ops = {
+static const struct cphy_ops vsc8211_ops = {
 	.reset = vsc8211_reset,
 	.intr_enable = vsc8211_intr_enable,
 	.intr_disable = vsc8211_intr_disable,
@@ -350,7 +350,7 @@ static struct cphy_ops vsc8211_ops = {
 	.power_down = vsc8211_power_down,
 };
 
-static struct cphy_ops vsc8211_fiber_ops = {
+static const struct cphy_ops vsc8211_fiber_ops = {
 	.reset = vsc8211_reset,
 	.intr_enable = vsc8211_intr_enable,
 	.intr_disable = vsc8211_intr_disable,

