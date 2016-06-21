From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next] of_mdio: Enable fixed PHY support if driver is a
 module
Date: Tue, 21 Jun 2016 01:17:17 +0100
Message-ID: <1466468237.26723.20.camel@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: CT kernel <linux-kernel@lists.codethink.co.uk>,
	netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:56317 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932943AbcFUARc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 20:17:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fixed_phy driver doesn't have to be built-in, and it's
important that of_mdio supports it even if it's a module.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
Re-sending with the proper subject prefix.

Ben.

--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -274,7 +274,7 @@ struct phy_device *of_phy_attach(struct
 }
 EXPORT_SYMBOL(of_phy_attach);
 
-#if defined(CONFIG_FIXED_PHY)
+#if IS_ENABLED(CONFIG_FIXED_PHY)
 /*
  * of_phy_is_fixed_link() and of_phy_register_fixed_link() must
  * support two DT bindings:
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -69,7 +69,7 @@ static inline int of_mdio_parse_addr(str
 }
 #endif /* CONFIG_OF */
 
-#if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
+#if defined(CONFIG_OF) && IS_ENABLED(CONFIG_FIXED_PHY)
 extern int of_phy_register_fixed_link(struct device_node *np);
 extern bool of_phy_is_fixed_link(struct device_node *np);
 #else


-- 
Ben Hutchings
Software Developer, Codethink Ltd.
