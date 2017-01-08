From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/4] net: dsa: Make dsa_switch_ops const
Date: Sun,  8 Jan 2017 14:52:08 -0800
Message-ID: <20170108225208.15431-5-f.fainelli@gmail.com>
References: <20170108225208.15431-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36548 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033712AbdAHW5r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 17:57:47 -0500
Received: by mail-pf0-f195.google.com with SMTP id b22so6837751pfd.3
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 14:57:47 -0800 (PST)
In-Reply-To: <20170108225208.15431-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have properly encapsulated and made drivers utilize exported
functions, we can switch dsa_switch_ops to be a annotated with const.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c |  2 +-
 drivers/net/dsa/bcm_sf2.c        |  2 +-
 drivers/net/dsa/mv88e6060.c      |  2 +-
 drivers/net/dsa/mv88e6xxx/chip.c |  2 +-
 drivers/net/dsa/qca8k.c          |  2 +-
 include/net/dsa.h                |  4 ++--
 net/dsa/dsa.c                    | 10 +++++-----
 net/dsa/hwmon.c                  |  2 +-
 8 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index a448661b55c6..5102a3701a1a 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1453,7 +1453,7 @@ static enum dsa_tag_protocol b53_get_tag_protocol(struct dsa_switch *ds)
 	return DSA_TAG_PROTO_NONE;
 }
 
-static struct dsa_switch_ops b53_switch_ops = {
+static const struct dsa_switch_ops b53_switch_ops = {
 	.get_tag_protocol	= b53_get_tag_protocol,
 	.setup			= b53_setup,
 	.get_strings		= b53_get_strings,
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index fcfc2cb5f3cd..4e7581788465 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -977,7 +977,7 @@ static struct b53_io_ops bcm_sf2_io_ops = {
 	.write64 = bcm_sf2_core_write64,
 };
 
-static struct dsa_switch_ops bcm_sf2_ops = {
+static const struct dsa_switch_ops bcm_sf2_ops = {
 	.get_tag_protocol	= bcm_sf2_sw_get_tag_protocol,
 	.setup			= bcm_sf2_sw_setup,
 	.get_strings		= b53_get_strings,
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index bcbd6dcbd8e8..5934b7a4c448 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -252,7 +252,7 @@ mv88e6060_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 	return reg_write(ds, addr, regnum, val);
 }
 
-static struct dsa_switch_ops mv88e6060_switch_ops = {
+static const struct dsa_switch_ops mv88e6060_switch_ops = {
 	.get_tag_protocol = mv88e6060_get_tag_protocol,
 	.probe		= mv88e6060_drv_probe,
 	.setup		= mv88e6060_setup,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d43d12c281b3..eea8e0176e33 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -4361,7 +4361,7 @@ static int mv88e6xxx_port_mdb_dump(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static struct dsa_switch_ops mv88e6xxx_switch_ops = {
+static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.probe			= mv88e6xxx_drv_probe,
 	.get_tag_protocol	= mv88e6xxx_get_tag_protocol,
 	.setup			= mv88e6xxx_setup,
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index b3df70d07ff6..54d270d59eb0 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -911,7 +911,7 @@ qca8k_get_tag_protocol(struct dsa_switch *ds)
 	return DSA_TAG_PROTO_QCA;
 }
 
-static struct dsa_switch_ops qca8k_switch_ops = {
+static const struct dsa_switch_ops qca8k_switch_ops = {
 	.get_tag_protocol	= qca8k_get_tag_protocol,
 	.setup			= qca8k_setup,
 	.get_strings		= qca8k_get_strings,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index edfa9b130953..b94d1f2ef912 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -169,7 +169,7 @@ struct dsa_switch {
 	/*
 	 * The switch operations.
 	 */
-	struct dsa_switch_ops	*ops;
+	const struct dsa_switch_ops	*ops;
 
 	/*
 	 * An array of which element [a] indicates which port on this
@@ -390,7 +390,7 @@ struct dsa_switch_ops {
 
 struct dsa_switch_driver {
 	struct list_head	list;
-	struct dsa_switch_ops	*ops;
+	const struct dsa_switch_ops *ops;
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 4e7bc57cdae5..fd532487dfdf 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -76,11 +76,11 @@ void unregister_switch_driver(struct dsa_switch_driver *drv)
 }
 EXPORT_SYMBOL_GPL(unregister_switch_driver);
 
-static struct dsa_switch_ops *
+static const struct dsa_switch_ops *
 dsa_switch_probe(struct device *parent, struct device *host_dev, int sw_addr,
 		 const char **_name, void **priv)
 {
-	struct dsa_switch_ops *ret;
+	const struct dsa_switch_ops *ret;
 	struct list_head *list;
 	const char *name;
 
@@ -89,7 +89,7 @@ dsa_switch_probe(struct device *parent, struct device *host_dev, int sw_addr,
 
 	mutex_lock(&dsa_switch_drivers_mutex);
 	list_for_each(list, &dsa_switch_drivers) {
-		struct dsa_switch_ops *ops;
+		const struct dsa_switch_ops *ops;
 		struct dsa_switch_driver *drv;
 
 		drv = list_entry(list, struct dsa_switch_driver, list);
@@ -207,7 +207,7 @@ void dsa_cpu_port_ethtool_restore(struct dsa_switch *ds)
 
 static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 {
-	struct dsa_switch_ops *ops = ds->ops;
+	const struct dsa_switch_ops *ops = ds->ops;
 	struct dsa_switch_tree *dst = ds->dst;
 	struct dsa_chip_data *cd = ds->cd;
 	bool valid_name_found = false;
@@ -326,7 +326,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 		 struct device *parent, struct device *host_dev)
 {
 	struct dsa_chip_data *cd = dst->pd->chip + index;
-	struct dsa_switch_ops *ops;
+	const struct dsa_switch_ops *ops;
 	struct dsa_switch *ds;
 	int ret;
 	const char *name;
diff --git a/net/dsa/hwmon.c b/net/dsa/hwmon.c
index 3a9cdf0b22b8..08831a811278 100644
--- a/net/dsa/hwmon.c
+++ b/net/dsa/hwmon.c
@@ -86,7 +86,7 @@ static umode_t dsa_hwmon_attrs_visible(struct kobject *kobj,
 {
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct dsa_switch *ds = dev_get_drvdata(dev);
-	struct dsa_switch_ops *ops = ds->ops;
+	const struct dsa_switch_ops *ops = ds->ops;
 	umode_t mode = attr->mode;
 
 	if (index == 1) {
-- 
2.9.3
