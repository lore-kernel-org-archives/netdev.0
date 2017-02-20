From: Michael Walle <michael@walle.cc>
Subject: [PATCH] dpaa_eth: implement ioctl() for PHY-related ops
Date: Mon, 20 Feb 2017 16:54:18 +0100
Message-ID: <1487606058-10994-1-git-send-email-michael@walle.cc>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Michael Walle <michael@walle.cc>
To: Madalin Bucur <madalin.bucur@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ssl.serverraum.org ([213.133.101.245]:35514 "EHLO
        ssl.serverraum.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753483AbdBTQDq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 11:03:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds the ndo_do_ioctl() callback which allows the userspace to
access PHY registers, for example. This will make mii-diag and similar
tools work.

Signed-off-by: Michael Walle <michael@walle.cc>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 726b569..b0f5990 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -2335,6 +2335,13 @@ static int dpaa_eth_stop(struct net_device *net_dev)
 	return err;
 }
 
+static int dpaa_ioctl(struct net_device *net_dev, struct ifreq *rq, int cmd)
+{
+	if (!net_dev->phydev)
+		return -EINVAL;
+	return phy_mii_ioctl(net_dev->phydev, rq, cmd);
+}
+
 static const struct net_device_ops dpaa_ops = {
 	.ndo_open = dpaa_open,
 	.ndo_start_xmit = dpaa_start_xmit,
@@ -2344,6 +2351,7 @@ static const struct net_device_ops dpaa_ops = {
 	.ndo_set_mac_address = dpaa_set_mac_address,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_set_rx_mode = dpaa_set_rx_mode,
+	.ndo_do_ioctl = dpaa_ioctl,
 };
 
 static int dpaa_napi_add(struct net_device *net_dev)
-- 
2.1.4
