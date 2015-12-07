From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 18/26] net: mvneta: add nway_reset support
Date: Mon, 07 Dec 2015 17:38:43 +0000
Message-ID: <E1a5zkJ-00076K-M7@rmk-PC.arm.linux.org.uk>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60305 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932137AbbLGRiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:38:46 -0500
In-Reply-To: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ethtool nway_reset support to mvneta via phylink, so that userspace
can request the link in whatever mode to be renegotiated via
ethtool -r ethX.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/marvell/mvneta.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index f19d9a31dccd..82aa2b59a249 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3020,6 +3020,13 @@ int mvneta_ethtool_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	return phylink_ethtool_set_settings(pp->phylink, cmd);
 }
 
+static int mvneta_ethtool_nway_reset(struct net_device *dev)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	return phylink_ethtool_nway_reset(pp->phylink);
+}
+
 /* Set interrupt coalescing for ethtools */
 static int mvneta_ethtool_set_coalesce(struct net_device *dev,
 				       struct ethtool_coalesce *c)
@@ -3184,6 +3191,7 @@ const struct ethtool_ops mvneta_eth_tool_ops = {
 	.get_link       = ethtool_op_get_link,
 	.get_settings   = mvneta_ethtool_get_settings,
 	.set_settings   = mvneta_ethtool_set_settings,
+	.nway_reset	= mvneta_ethtool_nway_reset,
 	.set_coalesce   = mvneta_ethtool_set_coalesce,
 	.get_coalesce   = mvneta_ethtool_get_coalesce,
 	.get_drvinfo    = mvneta_ethtool_get_drvinfo,
-- 
2.1.0
