From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 10/13] phylink: add module EEPROM support
Date: Tue, 25 Jul 2017 15:03:23 +0100
Message-ID: <E1da0Ql-0007M4-Op@rmk-PC.armlinux.org.uk>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:50906 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752286AbdGYOD2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 10:03:28 -0400
In-Reply-To: <20170725140138.GK31807@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for reading module EEPROMs through phylink.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/phylink.c | 28 ++++++++++++++++++++++++++++
 include/linux/phylink.h   |  3 +++
 2 files changed, 31 insertions(+)

diff --git a/drivers/net/phy/phylink.c b/drivers/net/phy/phylink.c
index 02082f4a8a95..026060c95b82 100644
--- a/drivers/net/phy/phylink.c
+++ b/drivers/net/phy/phylink.c
@@ -1020,6 +1020,34 @@ int phylink_ethtool_set_pauseparam(struct phylink *pl,
 }
 EXPORT_SYMBOL_GPL(phylink_ethtool_set_pauseparam);
 
+int phylink_ethtool_get_module_info(struct phylink *pl,
+				    struct ethtool_modinfo *modinfo)
+{
+	int ret = -EOPNOTSUPP;
+
+	WARN_ON(!lockdep_rtnl_is_held());
+
+	if (pl->sfp_bus)
+		ret = sfp_get_module_info(pl->sfp_bus, modinfo);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phylink_ethtool_get_module_info);
+
+int phylink_ethtool_get_module_eeprom(struct phylink *pl,
+				      struct ethtool_eeprom *ee, u8 *buf)
+{
+	int ret = -EOPNOTSUPP;
+
+	WARN_ON(!lockdep_rtnl_is_held());
+
+	if (pl->sfp_bus)
+		ret = sfp_get_module_eeprom(pl->sfp_bus, ee, buf);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phylink_ethtool_get_module_eeprom);
+
 int phylink_init_eee(struct phylink *pl, bool clk_stop_enable)
 {
 	int ret = -EPROTONOSUPPORT;
diff --git a/include/linux/phylink.h b/include/linux/phylink.h
index 76f054f39684..af67edd4ae38 100644
--- a/include/linux/phylink.h
+++ b/include/linux/phylink.h
@@ -125,6 +125,9 @@ void phylink_ethtool_get_pauseparam(struct phylink *,
 				    struct ethtool_pauseparam *);
 int phylink_ethtool_set_pauseparam(struct phylink *,
 				   struct ethtool_pauseparam *);
+int phylink_ethtool_get_module_info(struct phylink *, struct ethtool_modinfo *);
+int phylink_ethtool_get_module_eeprom(struct phylink *,
+				      struct ethtool_eeprom *, u8 *);
 int phylink_init_eee(struct phylink *, bool);
 int phylink_get_eee_err(struct phylink *);
 int phylink_ethtool_get_eee(struct phylink *, struct ethtool_eee *);
-- 
2.7.4
