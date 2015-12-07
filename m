From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 25/26] net: mvneta: add module EEPROM reading support
Date: Mon, 07 Dec 2015 17:39:19 +0000
Message-ID: <E1a5zkt-000779-NX@rmk-PC.arm.linux.org.uk>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60328 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932735AbbLGRjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:39:22 -0500
In-Reply-To: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/marvell/mvneta.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 3de2aa9335b2..bf0b03f58dae 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3244,6 +3244,22 @@ static int mvneta_ethtool_get_sset_count(struct net_device *dev, int sset)
 	return -EOPNOTSUPP;
 }
 
+static int mvneta_ethtool_get_module_info(struct net_device *dev,
+					  struct ethtool_modinfo *modinfo)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	return phylink_ethtool_get_module_info(pp->phylink, modinfo);
+}
+
+static int mvneta_ethtool_get_module_eeprom(struct net_device *dev,
+					    struct ethtool_eeprom *ee, u8 *buf)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	return phylink_ethtool_get_module_eeprom(pp->phylink, ee, buf);
+}
+
 static int mvneta_ethtool_get_eee(struct net_device *dev,
 				  struct ethtool_eee *eee)
 {
@@ -3312,6 +3328,8 @@ const struct ethtool_ops mvneta_eth_tool_ops = {
 	.get_strings	= mvneta_ethtool_get_strings,
 	.get_ethtool_stats = mvneta_ethtool_get_stats,
 	.get_sset_count	= mvneta_ethtool_get_sset_count,
+	.get_module_info = mvneta_ethtool_get_module_info,
+	.get_module_eeprom = mvneta_ethtool_get_module_eeprom,
 	.get_eee	= mvneta_ethtool_get_eee,
 	.set_eee	= mvneta_ethtool_set_eee,
 };
-- 
2.1.0
