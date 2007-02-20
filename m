From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/3] chelsio: use const for virtual functions
Date: Tue, 20 Feb 2007 15:58:02 -0800
Message-ID: <20070220235905.350443524@linux-foundation.org>
References: <20070220235759.102686172@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:57036 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965257AbXBUADS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 19:03:18 -0500
Content-Disposition: inline; filename=chelso-const-ops.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are several uses of _ops structure in this driver that
can be converted to const.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/chelsio/common.h    |    6 +++---
 drivers/net/chelsio/cphy.h      |   16 +++++++---------
 drivers/net/chelsio/gmac.h      |   10 +++-------
 drivers/net/chelsio/mac.c       |    2 +-
 drivers/net/chelsio/mv88e1xxx.c |    8 ++++----
 drivers/net/chelsio/mv88x201x.c |    8 ++++----
 drivers/net/chelsio/my3126.c    |    8 ++++----
 drivers/net/chelsio/pm3393.c    |    8 ++++----
 drivers/net/chelsio/subr.c      |    4 ++--
 drivers/net/chelsio/vsc7326.c   |    2 +-
 10 files changed, 33 insertions(+), 39 deletions(-)

--- chelsio.orig/drivers/net/chelsio/common.h
+++ chelsio/drivers/net/chelsio/common.h
@@ -322,9 +322,9 @@ struct board_info {
 	unsigned char           mdio_mdiinv;
 	unsigned char           mdio_mdc;
 	unsigned char           mdio_phybaseaddr;
-	struct gmac            *gmac;
-	struct gphy            *gphy;
-	struct mdio_ops        *mdio_ops;
+	const struct gmac      *gmac;
+	const struct gphy      *gphy;
+	const struct mdio_ops  *mdio_ops;
 	const char             *desc;
 };
 
--- chelsio.orig/drivers/net/chelsio/cphy.h
+++ chelsio/drivers/net/chelsio/cphy.h
@@ -100,7 +100,7 @@ struct cphy {
 
 	u32 elmer_gpo;
 
-	struct cphy_ops *ops;                /* PHY operations */
+	const struct cphy_ops *ops;            /* PHY operations */
 	int (*mdio_read)(adapter_t *adapter, int phy_addr, int mmd_addr,
 			 int reg_addr, unsigned int *val);
 	int (*mdio_write)(adapter_t *adapter, int phy_addr, int mmd_addr,
@@ -136,7 +136,7 @@ static inline int simple_mdio_write(stru
 /* Convenience initializer */
 static inline void cphy_init(struct cphy *phy, adapter_t *adapter,
 			     int phy_addr, struct cphy_ops *phy_ops,
-			     struct mdio_ops *mdio_ops)
+			     const struct mdio_ops *mdio_ops)
 {
 	phy->adapter = adapter;
 	phy->addr    = phy_addr;
@@ -151,7 +151,7 @@ static inline void cphy_init(struct cphy
 struct gphy {
 	/* Construct a PHY instance with the given PHY address */
 	struct cphy *(*create)(adapter_t *adapter, int phy_addr,
-			       struct mdio_ops *mdio_ops);
+			       const struct mdio_ops *mdio_ops);
 
 	/*
 	 * Reset the PHY chip.  This resets the whole PHY chip, not individual
@@ -160,11 +160,9 @@ struct gphy {
 	int (*reset)(adapter_t *adapter);
 };
 
-extern struct gphy t1_my3126_ops;
-extern struct gphy t1_mv88e1xxx_ops;
-extern struct gphy t1_vsc8244_ops;
-extern struct gphy t1_xpak_ops;
-extern struct gphy t1_mv88x201x_ops;
-extern struct gphy t1_dummy_phy_ops;
+extern const struct gphy t1_my3126_ops;
+extern const struct gphy t1_mv88e1xxx_ops;
+extern const struct gphy t1_vsc8244_ops;
+extern const struct gphy t1_mv88x201x_ops;
 
 #endif /* _CXGB_CPHY_H_ */
--- chelsio.orig/drivers/net/chelsio/gmac.h
+++ chelsio/drivers/net/chelsio/gmac.h
@@ -126,7 +126,7 @@ typedef struct _cmac_instance cmac_insta
 struct cmac {
 	struct cmac_statistics stats;
 	adapter_t *adapter;
-	struct cmac_ops *ops;
+	const struct cmac_ops *ops;
 	cmac_instance *instance;
 };
 
@@ -136,11 +136,7 @@ struct gmac {
 	int (*reset)(adapter_t *);
 };
 
-extern struct gmac t1_pm3393_ops;
-extern struct gmac t1_chelsio_mac_ops;
-extern struct gmac t1_vsc7321_ops;
-extern struct gmac t1_vsc7326_ops;
-extern struct gmac t1_ixf1010_ops;
-extern struct gmac t1_dummy_mac_ops;
+extern const struct gmac t1_pm3393_ops;
+extern const struct gmac t1_vsc7326_ops;
 
 #endif /* _CXGB_GMAC_H_ */
--- chelsio.orig/drivers/net/chelsio/mac.c
+++ chelsio/drivers/net/chelsio/mac.c
@@ -363,6 +363,6 @@ static struct cmac *mac_create(adapter_t
 	return mac;
 }
 
-struct gmac t1_chelsio_mac_ops = {
+const struct gmac t1_chelsio_mac_ops = {
 	.create = mac_create
 };
--- chelsio.orig/drivers/net/chelsio/mv88e1xxx.c
+++ chelsio/drivers/net/chelsio/mv88e1xxx.c
@@ -354,7 +354,7 @@ static struct cphy_ops mv88e1xxx_ops = {
 };
 
 static struct cphy *mv88e1xxx_phy_create(adapter_t *adapter, int phy_addr,
-					 struct mdio_ops *mdio_ops)
+					 const struct mdio_ops *mdio_ops)
 {
 	struct cphy *cphy = kzalloc(sizeof(*cphy), GFP_KERNEL);
 
@@ -390,7 +390,7 @@ static int mv88e1xxx_phy_reset(adapter_t
 	return 0;
 }
 
-struct gphy t1_mv88e1xxx_ops = {
-	mv88e1xxx_phy_create,
-	mv88e1xxx_phy_reset
+const struct gphy t1_mv88e1xxx_ops = {
+	.create = mv88e1xxx_phy_create,
+	.reset =  mv88e1xxx_phy_reset
 };
--- chelsio.orig/drivers/net/chelsio/mv88x201x.c
+++ chelsio/drivers/net/chelsio/mv88x201x.c
@@ -208,7 +208,7 @@ static struct cphy_ops mv88x201x_ops = {
 };
 
 static struct cphy *mv88x201x_phy_create(adapter_t *adapter, int phy_addr,
-					 struct mdio_ops *mdio_ops)
+					 const struct mdio_ops *mdio_ops)
 {
 	u32 val;
 	struct cphy *cphy = kzalloc(sizeof(*cphy), GFP_KERNEL);
@@ -252,7 +252,7 @@ static int mv88x201x_phy_reset(adapter_t
 	return 0;
 }
 
-struct gphy t1_mv88x201x_ops = {
-	mv88x201x_phy_create,
-	mv88x201x_phy_reset
+const struct gphy t1_mv88x201x_ops = {
+	.create = mv88x201x_phy_create,
+	.reset = mv88x201x_phy_reset
 };
--- chelsio.orig/drivers/net/chelsio/my3126.c
+++ chelsio/drivers/net/chelsio/my3126.c
@@ -166,7 +166,7 @@ static struct cphy_ops my3126_ops = {
 };
 
 static struct cphy *my3126_phy_create(adapter_t *adapter,
-			int phy_addr, struct mdio_ops *mdio_ops)
+			int phy_addr, const struct mdio_ops *mdio_ops)
 {
 	struct cphy *cphy = kzalloc(sizeof (*cphy), GFP_KERNEL);
 
@@ -201,7 +201,7 @@ static int my3126_phy_reset(adapter_t * 
 	return 0;
 }
 
-struct gphy t1_my3126_ops = {
-	my3126_phy_create,
-	my3126_phy_reset
+const struct gphy t1_my3126_ops = {
+	.create = my3126_phy_create,
+	.reset = my3126_phy_reset
 };
--- chelsio.orig/drivers/net/chelsio/pm3393.c
+++ chelsio/drivers/net/chelsio/pm3393.c
@@ -807,8 +807,8 @@ static int pm3393_mac_reset(adapter_t * 
 	return successful_reset ? 0 : 1;
 }
 
-struct gmac t1_pm3393_ops = {
-	STATS_TICK_SECS,
-	pm3393_mac_create,
-	pm3393_mac_reset
+const struct gmac t1_pm3393_ops = {
+	.stats_update_period = STATS_TICK_SECS,
+	.create              = pm3393_mac_create,
+	.reset               = pm3393_mac_reset,
 };
--- chelsio.orig/drivers/net/chelsio/subr.c
+++ chelsio/drivers/net/chelsio/subr.c
@@ -321,7 +321,7 @@ static int mi1_mdio_write(adapter_t *ada
 }
 
 #if defined(CONFIG_CHELSIO_T1_1G) || defined(CONFIG_CHELSIO_T1_COUGAR)
-static struct mdio_ops mi1_mdio_ops = {
+static const struct mdio_ops mi1_mdio_ops = {
 	.init = mi1_mdio_init,
 	.read = mi1_mdio_read,
 	.write = mi1_mdio_write
@@ -377,7 +377,7 @@ static int mi1_mdio_ext_write(adapter_t 
 	return 0;
 }
 
-static struct mdio_ops mi1_mdio_ext_ops = {
+static const struct mdio_ops mi1_mdio_ext_ops = {
 	.init = mi1_mdio_init,
 	.read = mi1_mdio_ext_read,
 	.write = mi1_mdio_ext_write
--- chelsio.orig/drivers/net/chelsio/vsc7326.c
+++ chelsio/drivers/net/chelsio/vsc7326.c
@@ -723,7 +723,7 @@ static int vsc7326_mac_reset(adapter_t *
 	return 0;
 }
 
-struct gmac t1_vsc7326_ops = {
+const struct gmac t1_vsc7326_ops = {
 	.stats_update_period = STATS_TICK_SECS,
 	.create              = vsc7326_mac_create,
 	.reset               = vsc7326_mac_reset,

-- 

