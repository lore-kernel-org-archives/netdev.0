From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 03/18] netvsc: report number of rx queues in ethtool
Date: Tue, 24 Jan 2017 13:06:00 -0800
Message-ID: <20170124210615.18628-4-sthemmin@microsoft.com>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33860 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbdAXVG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:06:59 -0500
Received: by mail-pg0-f45.google.com with SMTP id 14so57791438pgg.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:06:21 -0800 (PST)
In-Reply-To: <20170124210615.18628-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report actual number of receive queues to ethtool.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f26d9d2d475f..b158cab678b3 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1008,6 +1008,21 @@ static void netvsc_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	}
 }
 
+static int
+netvsc_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
+		 u32 *rules)
+{
+	struct net_device_context *ndc = netdev_priv(dev);
+	struct netvsc_device *nvdev = ndc->nvdev;
+
+	switch (info->cmd) {
+	case ETHTOOL_GRXRINGS:
+		info->data = nvdev->num_chn;
+		return 0;
+	}
+	return -EOPNOTSUPP;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void netvsc_poll_controller(struct net_device *net)
 {
@@ -1028,6 +1043,7 @@ static const struct ethtool_ops ethtool_ops = {
 	.get_ts_info	= ethtool_op_get_ts_info,
 	.get_settings	= netvsc_get_settings,
 	.set_settings	= netvsc_set_settings,
+	.get_rxnfc	= netvsc_get_rxnfc,
 };
 
 static const struct net_device_ops device_ops = {
-- 
2.11.0
