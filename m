From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/3] qla3xxx: ethtool ops for controlling checksum
Date: Wed, 30 May 2007 14:23:19 -0700
Message-ID: <20070530212512.267956457@linux-foundation.org>
References: <20070530212316.407169588@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:37279 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759397AbXE3ViL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 17:38:11 -0400
Content-Disposition: inline; filename=qla-ethtool-ops.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the ability to control scatter/gather and checksumming
via ethtool.

Compile tested only, no hardware available.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/qla3xxx.c |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

--- a/drivers/net/qla3xxx.c	2007-05-30 14:10:42.000000000 -0700
+++ b/drivers/net/qla3xxx.c	2007-05-30 14:15:37.000000000 -0700
@@ -1901,6 +1901,35 @@ static void ql_get_pauseparam(struct net
 	pause->tx_pause = (reg & MAC_CONFIG_REG_TF) >> 1;
 }
 
+static int ql_set_tx_csum(struct net_device *dev, u32 data)
+{
+	if (data) {
+		struct ql3_adapter *qdev = netdev_priv(ndev);
+
+		if (qdev->device_id != QL3032_DEVICE_ID)
+			return -EINVAL;
+
+		dev->features |= NETIF_F_IP_CSUM;
+	} else
+		dev->features &= ~NETIF_F_IP_CSUM;
+
+	return 0;
+}
+
+static int ql_set_sg(struct net_device *dev, u32 data)
+{
+	if (data) {
+		struct ql3_adapter *qdev = netdev_priv(ndev);
+
+		if (qdev->device_id != QL3032_DEVICE_ID)
+			return -EINVAL;
+		dev->features |= NETIF_F_SG;
+	} else
+		dev->features &= ~NETIF_F_SG;
+
+	return 0;
+}
+
 static const struct ethtool_ops ql3xxx_ethtool_ops = {
 	.get_settings = ql_get_settings,
 	.get_drvinfo = ql_get_drvinfo,
@@ -1909,6 +1938,10 @@ static const struct ethtool_ops ql3xxx_e
 	.get_msglevel = ql_get_msglevel,
 	.set_msglevel = ql_set_msglevel,
 	.get_pauseparam = ql_get_pauseparam,
+	.get_tx_csum = ql_op_get_tx_csum,
+	.set_tx_csum = ethtool_op_set_tx_csum,
+	.get_sg = ethtool_op_get_sg,
+	.set_sg = ql_get_sg,
 };
 
 static int ql_populate_free_queue(struct ql3_adapter *qdev)

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

