From: Mark Brown <broonie@kernel.org>
Subject: [PATCH 1/2] net: asix: Staticise non-exported symbols
Date: Fri,  9 Aug 2013 18:31:21 +0100
Message-ID: <1376069482-16951-1-git-send-email-broonie@kernel.org>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, Mark Brown <broonie@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:48316 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490Ab3HIRbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 13:31:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@linaro.org>

Make functions that are only referenced from ops structures static, they
do not need to be in the global namespace and sparse complains about this.

Signed-off-by: Mark Brown <broonie@linaro.org>
---
 drivers/net/usb/ax88172a.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
index d012203..723b387 100644
--- a/drivers/net/usb/ax88172a.c
+++ b/drivers/net/usb/ax88172a.c
@@ -161,7 +161,8 @@ static const struct net_device_ops ax88172a_netdev_ops = {
 	.ndo_set_rx_mode        = asix_set_multicast,
 };
 
-int ax88172a_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
+static int ax88172a_get_settings(struct net_device *net,
+				 struct ethtool_cmd *cmd)
 {
 	if (!net->phydev)
 		return -ENODEV;
@@ -169,7 +170,8 @@ int ax88172a_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
 	return phy_ethtool_gset(net->phydev, cmd);
 }
 
-int ax88172a_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
+static int ax88172a_set_settings(struct net_device *net,
+				 struct ethtool_cmd *cmd)
 {
 	if (!net->phydev)
 		return -ENODEV;
@@ -177,7 +179,7 @@ int ax88172a_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
 	return phy_ethtool_sset(net->phydev, cmd);
 }
 
-int ax88172a_nway_reset(struct net_device *net)
+static int ax88172a_nway_reset(struct net_device *net)
 {
 	if (!net->phydev)
 		return -ENODEV;
-- 
1.8.4.rc1
