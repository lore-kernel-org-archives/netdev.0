From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: remove dev arg of dsa_register_switch
Date: Fri, 26 May 2017 18:12:51 -0400
Message-ID: <20170526221251.14972-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49316 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948794AbdEZWO5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 18:14:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current dsa_register_switch function takes a useless struct device
pointer argument, which always equals ds->dev.

Drivers either call it with ds->dev, or with the same device pointer
passed to dsa_switch_alloc, which ends up being assigned to ds->dev.

This patch removes the second argument of the dsa_register_switch and
_dsa_register_switch functions.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c |  2 +-
 drivers/net/dsa/dsa_loop.c       |  2 +-
 drivers/net/dsa/lan9303-core.c   |  2 +-
 drivers/net/dsa/mt7530.c         |  2 +-
 drivers/net/dsa/mv88e6xxx/chip.c |  2 +-
 drivers/net/dsa/qca8k.c          |  2 +-
 include/net/dsa.h                |  2 +-
 net/dsa/dsa2.c                   | 10 +++++-----
 8 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index fa099ed41652..37bd6bd3b8d0 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1991,7 +1991,7 @@ int b53_switch_register(struct b53_device *dev)
 
 	pr_info("found switch: %s, rev %i\n", dev->name, dev->core_rev);
 
-	return dsa_register_switch(dev->ds, dev->ds->dev);
+	return dsa_register_switch(dev->ds);
 }
 EXPORT_SYMBOL(b53_switch_register);
 
diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index 5edf07beb9d2..79e62593ff4e 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -271,7 +271,7 @@ static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
 
 	dev_set_drvdata(&mdiodev->dev, ds);
 
-	return dsa_register_switch(ds, ds->dev);
+	return dsa_register_switch(ds);
 }
 
 static void dsa_loop_drv_remove(struct mdio_device *mdiodev)
diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index c8b2423c8ef7..cd76e61f1fca 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -802,7 +802,7 @@ static int lan9303_register_switch(struct lan9303 *chip)
 	chip->ds->ops = &lan9303_switch_ops;
 	chip->ds->phys_mii_mask = chip->phy_addr_sel_strap ? 0xe : 0x7;
 
-	return dsa_register_switch(chip->ds, chip->dev);
+	return dsa_register_switch(chip->ds);
 }
 
 static void lan9303_probe_reset_gpio(struct lan9303 *chip,
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 4d2f45153ede..25e00d5e0eec 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -1080,7 +1080,7 @@ mt7530_probe(struct mdio_device *mdiodev)
 	mutex_init(&priv->reg_mutex);
 	dev_set_drvdata(&mdiodev->dev, priv);
 
-	return dsa_register_switch(priv->ds, &mdiodev->dev);
+	return dsa_register_switch(priv->ds);
 }
 
 static void
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c2f38f6770aa..5e992a5745b0 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3892,7 +3892,7 @@ static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip)
 
 	dev_set_drvdata(dev, ds);
 
-	return dsa_register_switch(ds, dev);
+	return dsa_register_switch(ds);
 }
 
 static void mv88e6xxx_unregister_switch(struct mv88e6xxx_chip *chip)
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 0f6a011d8ed1..b3bee7eab45f 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -958,7 +958,7 @@ qca8k_sw_probe(struct mdio_device *mdiodev)
 	mutex_init(&priv->reg_mutex);
 	dev_set_drvdata(&mdiodev->dev, priv);
 
-	return dsa_register_switch(priv->ds, &mdiodev->dev);
+	return dsa_register_switch(priv->ds);
 }
 
 static void
diff --git a/include/net/dsa.h b/include/net/dsa.h
index c0e567c0c824..d9bd6939229a 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -480,7 +480,7 @@ static inline bool netdev_uses_dsa(struct net_device *dev)
 
 struct dsa_switch *dsa_switch_alloc(struct device *dev, size_t n);
 void dsa_unregister_switch(struct dsa_switch *ds);
-int dsa_register_switch(struct dsa_switch *ds, struct device *dev);
+int dsa_register_switch(struct dsa_switch *ds);
 #ifdef CONFIG_PM_SLEEP
 int dsa_switch_suspend(struct dsa_switch *ds);
 int dsa_switch_resume(struct dsa_switch *ds);
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 4301f52e4f5a..c0a4576db4a2 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -686,10 +686,10 @@ static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 	return ports;
 }
 
-static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
+static int _dsa_register_switch(struct dsa_switch *ds)
 {
-	struct dsa_chip_data *pdata = dev->platform_data;
-	struct device_node *np = dev->of_node;
+	struct dsa_chip_data *pdata = ds->dev->platform_data;
+	struct device_node *np = ds->dev->of_node;
 	struct dsa_switch_tree *dst;
 	struct device_node *ports;
 	u32 tree, index;
@@ -803,12 +803,12 @@ struct dsa_switch *dsa_switch_alloc(struct device *dev, size_t n)
 }
 EXPORT_SYMBOL_GPL(dsa_switch_alloc);
 
-int dsa_register_switch(struct dsa_switch *ds, struct device *dev)
+int dsa_register_switch(struct dsa_switch *ds)
 {
 	int err;
 
 	mutex_lock(&dsa2_mutex);
-	err = _dsa_register_switch(ds, dev);
+	err = _dsa_register_switch(ds);
 	mutex_unlock(&dsa2_mutex);
 
 	return err;
-- 
2.13.0
