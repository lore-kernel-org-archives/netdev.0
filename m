From: akpm@linux-foundation.org
Subject: [patch 4/4] netdev: gianfar: add MII ioctl handler
Date: Fri, 09 Jan 2009 12:23:11 -0800
Message-ID: <200901092023.n09KNBAl020243@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	clifford@clifford.at
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48678 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756577AbZAIUbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 15:31:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Clifford Wolf <clifford@clifford.at>

This is the same kind of wrapper that can also be found in many
other network device drivers.

Tested with a freescale MPC8349E host CPU:
Toggled the interface LEDs on a DP83865 PHY.

Signed-off-by: Clifford Wolf <clifford@clifford.at>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/gianfar.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff -puN drivers/net/gianfar.c~netdev-gianfar-add-mii-ioctl-handler drivers/net/gianfar.c
--- a/drivers/net/gianfar.c~netdev-gianfar-add-mii-ioctl-handler
+++ a/drivers/net/gianfar.c
@@ -296,6 +296,20 @@ err_out:
 	return err;
 }
 
+/* Ioctl MII Interface */
+static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	if (!priv->phydev)
+		return -ENODEV;
+
+	return phy_mii_ioctl(priv->phydev, if_mii(rq), cmd);
+}
+
 /* Set up the ethernet device structure, private data,
  * and anything else we need before we start */
 static int gfar_probe(struct of_device *ofdev,
@@ -366,6 +380,7 @@ static int gfar_probe(struct of_device *
 	dev->set_multicast_list = gfar_set_multi;
 
 	dev->ethtool_ops = &gfar_ethtool_ops;
+	dev->do_ioctl = gfar_ioctl;
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
 		priv->rx_csum_enable = 1;
_
