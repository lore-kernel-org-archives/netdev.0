From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 4/6] mv643xx_eth: export rx csum get/set methods via ethtool
Date: Fri, 13 Feb 2009 01:07:56 +0100
Message-ID: <20090213000756.GN17914@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:43006 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbZBMAH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:07:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 0fcaca5..c998a7c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1528,6 +1528,24 @@ mv643xx_eth_set_ringparam(struct net_device *dev, struct ethtool_ringparam *er)
 	return 0;
 }
 
+static u32
+mv643xx_eth_get_rx_csum(struct net_device *dev)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+
+	return !!(rdlp(mp, PORT_CONFIG) & 0x02000000);
+}
+
+static int
+mv643xx_eth_set_rx_csum(struct net_device *dev, u32 rx_csum)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+
+	wrlp(mp, PORT_CONFIG, rx_csum ? 0x02000000 : 0x00000000);
+
+	return 0;
+}
+
 static void mv643xx_eth_get_strings(struct net_device *dev,
 				    uint32_t stringset, uint8_t *data)
 {
@@ -1586,6 +1604,8 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.set_coalesce		= mv643xx_eth_set_coalesce,
 	.get_ringparam		= mv643xx_eth_get_ringparam,
 	.set_ringparam		= mv643xx_eth_set_ringparam,
+	.get_rx_csum		= mv643xx_eth_get_rx_csum,
+	.set_rx_csum		= mv643xx_eth_set_rx_csum,
 	.set_sg			= ethtool_op_set_sg,
 	.get_strings		= mv643xx_eth_get_strings,
 	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
-- 
1.5.6.4
