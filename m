From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: phy: Cosmetic fixes to phylink/sfp/sfp-bus.c
Date: Mon, 30 Oct 2017 21:42:57 -0700
Message-ID: <20171031044258.16094-2-f.fainelli@gmail.com>
References: <20171031044258.16094-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, rmk+kernel@armlinux.org.uk, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:56370 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbdJaEnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 00:43:05 -0400
Received: by mail-oi0-f65.google.com with SMTP id v9so25406263oif.13
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 21:43:05 -0700 (PDT)
In-Reply-To: <20171031044258.16094-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Perform a number of stylistic changes to phylink.c, sfp.c and sfp-bus.c:

- align with netdev-style comments
- align function arguments to the opening parenthesis
- remove blank lines
- fixup a few lines over 80 columns

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phylink.c | 13 ++++++-------
 drivers/net/phy/sfp-bus.c | 11 +++--------
 drivers/net/phy/sfp.c     | 27 +++++++++++++--------------
 3 files changed, 22 insertions(+), 29 deletions(-)

diff --git a/drivers/net/phy/phylink.c b/drivers/net/phy/phylink.c
index bcb4755bcd95..05c8f1c10e36 100644
--- a/drivers/net/phy/phylink.c
+++ b/drivers/net/phy/phylink.c
@@ -357,7 +357,7 @@ static void phylink_get_fixed_state(struct phylink *pl, struct phylink_link_stat
  *    1     1       0     1     TX
  */
 static void phylink_resolve_flow(struct phylink *pl,
-	struct phylink_link_state *state)
+				 struct phylink_link_state *state)
 {
 	int new_pause = 0;
 
@@ -506,7 +506,8 @@ static int phylink_register_sfp(struct phylink *pl, struct device_node *np)
 }
 
 struct phylink *phylink_create(struct net_device *ndev, struct device_node *np,
-	phy_interface_t iface, const struct phylink_mac_ops *ops)
+			       phy_interface_t iface,
+			       const struct phylink_mac_ops *ops)
 {
 	struct phylink *pl;
 	int ret;
@@ -585,7 +586,7 @@ void phylink_phy_change(struct phy_device *phydev, bool up, bool do_carrier)
 	phylink_run_resolve(pl);
 
 	netdev_dbg(pl->netdev, "phy link %s %s/%s/%s\n", up ? "up" : "down",
-	           phy_modes(phydev->interface),
+		   phy_modes(phydev->interface),
 		   phy_speed_to_str(phydev->speed),
 		   phy_duplex_to_str(phydev->duplex));
 }
@@ -823,7 +824,7 @@ static void phylink_get_ksettings(const struct phylink_link_state *state,
 }
 
 int phylink_ethtool_ksettings_get(struct phylink *pl,
-	struct ethtool_link_ksettings *kset)
+				  struct ethtool_link_ksettings *kset)
 {
 	struct phylink_link_state link_state;
 
@@ -870,7 +871,7 @@ int phylink_ethtool_ksettings_get(struct phylink *pl,
 EXPORT_SYMBOL_GPL(phylink_ethtool_ksettings_get);
 
 int phylink_ethtool_ksettings_set(struct phylink *pl,
-	const struct ethtool_link_ksettings *kset)
+				  const struct ethtool_link_ksettings *kset)
 {
 	struct ethtool_link_ksettings our_kset;
 	struct phylink_link_state config;
@@ -1337,8 +1338,6 @@ int phylink_mii_ioctl(struct phylink *pl, struct ifreq *ifr, int cmd)
 }
 EXPORT_SYMBOL_GPL(phylink_mii_ioctl);
 
-
-
 static int phylink_sfp_module_insert(void *upstream,
 				     const struct sfp_eeprom_id *id)
 {
diff --git a/drivers/net/phy/sfp-bus.c b/drivers/net/phy/sfp-bus.c
index 5cb5384697ea..8a1b1f4c1b7c 100644
--- a/drivers/net/phy/sfp-bus.c
+++ b/drivers/net/phy/sfp-bus.c
@@ -26,7 +26,6 @@ struct sfp_bus {
 	bool started;
 };
 
-
 int sfp_parse_port(struct sfp_bus *bus, const struct sfp_eeprom_id *id,
 		   unsigned long *support)
 {
@@ -208,7 +207,6 @@ void sfp_parse_support(struct sfp_bus *bus, const struct sfp_eeprom_id *id,
 }
 EXPORT_SYMBOL_GPL(sfp_parse_support);
 
-
 static LIST_HEAD(sfp_buses);
 static DEFINE_MUTEX(sfp_mutex);
 
@@ -295,7 +293,6 @@ static void sfp_unregister_bus(struct sfp_bus *bus)
 	bus->registered = false;
 }
 
-
 int sfp_get_module_info(struct sfp_bus *bus, struct ethtool_modinfo *modinfo)
 {
 	if (!bus->registered)
@@ -305,7 +302,7 @@ int sfp_get_module_info(struct sfp_bus *bus, struct ethtool_modinfo *modinfo)
 EXPORT_SYMBOL_GPL(sfp_get_module_info);
 
 int sfp_get_module_eeprom(struct sfp_bus *bus, struct ethtool_eeprom *ee,
-	u8 *data)
+			  u8 *data)
 {
 	if (!bus->registered)
 		return -ENOIOCTLCMD;
@@ -330,8 +327,8 @@ void sfp_upstream_stop(struct sfp_bus *bus)
 EXPORT_SYMBOL_GPL(sfp_upstream_stop);
 
 struct sfp_bus *sfp_register_upstream(struct device_node *np,
-	struct net_device *ndev, void *upstream,
-	const struct sfp_upstream_ops *ops)
+				      struct net_device *ndev, void *upstream,
+				      const struct sfp_upstream_ops *ops)
 {
 	struct sfp_bus *bus = sfp_bus_get(np);
 	int ret = 0;
@@ -368,7 +365,6 @@ void sfp_unregister_upstream(struct sfp_bus *bus)
 }
 EXPORT_SYMBOL_GPL(sfp_unregister_upstream);
 
-
 /* Socket driver entry points */
 int sfp_add_phy(struct sfp_bus *bus, struct phy_device *phydev)
 {
@@ -395,7 +391,6 @@ void sfp_remove_phy(struct sfp_bus *bus)
 }
 EXPORT_SYMBOL_GPL(sfp_remove_phy);
 
-
 void sfp_link_up(struct sfp_bus *bus)
 {
 	const struct sfp_upstream_ops *ops = sfp_get_upstream_ops(bus);
diff --git a/drivers/net/phy/sfp.c b/drivers/net/phy/sfp.c
index baee371bf767..448465da0422 100644
--- a/drivers/net/phy/sfp.c
+++ b/drivers/net/phy/sfp.c
@@ -88,15 +88,12 @@ static const enum gpiod_flags gpio_flags[] = {
 #define T_PROBE_INIT	msecs_to_jiffies(300)
 #define T_PROBE_RETRY	msecs_to_jiffies(100)
 
-/*
- * SFP modules appear to always have their PHY configured for bus address
+/* SFP modules appear to always have their PHY configured for bus address
  * 0x56 (which with mdio-i2c, translates to a PHY address of 22).
  */
 #define SFP_PHY_ADDR	22
 
-/*
- * Give this long for the PHY to reset.
- */
+/* Give this long for the PHY to reset. */
 #define T_PHY_RESET_MS	50
 
 static DEFINE_MUTEX(sfp_mutex);
@@ -150,10 +147,10 @@ static void sfp_gpio_set_state(struct sfp *sfp, unsigned int state)
 		/* If the module is present, drive the signals */
 		if (sfp->gpio[GPIO_TX_DISABLE])
 			gpiod_direction_output(sfp->gpio[GPIO_TX_DISABLE],
-						state & SFP_F_TX_DISABLE);
+					       state & SFP_F_TX_DISABLE);
 		if (state & SFP_F_RATE_SELECT)
 			gpiod_direction_output(sfp->gpio[GPIO_RATE_SELECT],
-						state & SFP_F_RATE_SELECT);
+					       state & SFP_F_RATE_SELECT);
 	} else {
 		/* Otherwise, let them float to the pull-ups */
 		if (sfp->gpio[GPIO_TX_DISABLE])
@@ -164,7 +161,7 @@ static void sfp_gpio_set_state(struct sfp *sfp, unsigned int state)
 }
 
 static int sfp__i2c_read(struct i2c_adapter *i2c, u8 bus_addr, u8 dev_addr,
-	void *buf, size_t len)
+			 void *buf, size_t len)
 {
 	struct i2c_msg msgs[2];
 	int ret;
@@ -186,7 +183,7 @@ static int sfp__i2c_read(struct i2c_adapter *i2c, u8 bus_addr, u8 dev_addr,
 }
 
 static int sfp_i2c_read(struct sfp *sfp, bool a2, u8 addr, void *buf,
-	size_t len)
+			size_t len)
 {
 	return sfp__i2c_read(sfp->i2c, a2 ? 0x51 : 0x50, addr, buf, len);
 }
@@ -220,7 +217,6 @@ static int sfp_i2c_configure(struct sfp *sfp, struct i2c_adapter *i2c)
 	return 0;
 }
 
-
 /* Interface */
 static unsigned int sfp_get_state(struct sfp *sfp)
 {
@@ -295,7 +291,8 @@ static void sfp_sm_next(struct sfp *sfp, unsigned int state,
 	sfp_sm_set_timer(sfp, timeout);
 }
 
-static void sfp_sm_ins_next(struct sfp *sfp, unsigned int state, unsigned int timeout)
+static void sfp_sm_ins_next(struct sfp *sfp, unsigned int state,
+			    unsigned int timeout)
 {
 	sfp->sm_mod_state = state;
 	sfp_sm_set_timer(sfp, timeout);
@@ -370,7 +367,8 @@ static void sfp_sm_link_check_los(struct sfp *sfp)
 static void sfp_sm_fault(struct sfp *sfp, bool warn)
 {
 	if (sfp->sm_retries && !--sfp->sm_retries) {
-		dev_err(sfp->dev, "module persistently indicates fault, disabling\n");
+		dev_err(sfp->dev,
+			"module persistently indicates fault, disabling\n");
 		sfp_sm_next(sfp, SFP_S_TX_DISABLE, 0);
 	} else {
 		if (warn)
@@ -461,7 +459,8 @@ static int sfp_sm_mod_probe(struct sfp *sfp)
 	memcpy(date, sfp->id.ext.datecode, 8);
 	date[8] = '\0';
 
-	dev_info(sfp->dev, "module %s %s rev %s sn %s dc %s\n", vendor, part, rev, sn, date);
+	dev_info(sfp->dev, "module %s %s rev %s sn %s dc %s\n",
+		 vendor, part, rev, sn, date);
 
 	/* We only support SFP modules, not the legacy GBIC modules. */
 	if (sfp->id.base.phys_id != SFP_PHYS_ID_SFP ||
@@ -651,7 +650,7 @@ static int sfp_module_info(struct sfp *sfp, struct ethtool_modinfo *modinfo)
 }
 
 static int sfp_module_eeprom(struct sfp *sfp, struct ethtool_eeprom *ee,
-	u8 *data)
+			     u8 *data)
 {
 	unsigned int first, last, len;
 	int ret;
-- 
2.14.1
