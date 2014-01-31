From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v2 1/4] net: ethoc: implement basic ethtool operations
Date: Fri, 31 Jan 2014 09:41:04 +0400
Message-ID: <1391146867-30508-2-git-send-email-jcmvbkbc@gmail.com>
References: <1391146867-30508-1-git-send-email-jcmvbkbc@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Marc Gauthier <marc@cadence.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:49222 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbaAaFvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 00:51:14 -0500
In-Reply-To: <1391146867-30508-1-git-send-email-jcmvbkbc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following methods are implemented:
- get link state (standard implementation);
- get timestamping info (standard implementation).

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/ethernet/ethoc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 4de8cfd..0623c20 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -890,6 +890,11 @@ out:
 	return NETDEV_TX_OK;
 }
 
+const struct ethtool_ops ethoc_ethtool_ops = {
+	.get_link = ethtool_op_get_link,
+	.get_ts_info = ethtool_op_get_ts_info,
+};
+
 static const struct net_device_ops ethoc_netdev_ops = {
 	.ndo_open = ethoc_open,
 	.ndo_stop = ethoc_stop,
@@ -1111,6 +1116,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	netdev->netdev_ops = &ethoc_netdev_ops;
 	netdev->watchdog_timeo = ETHOC_TIMEOUT;
 	netdev->features |= 0;
+	netdev->ethtool_ops = &ethoc_ethtool_ops;
 
 	/* setup NAPI */
 	netif_napi_add(netdev, &priv->napi, ethoc_poll, 64);
-- 
1.8.1.4
