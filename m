From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 7/8] qlcnic: turn off lro when rxcsum is disabled.
Date: Wed, 11 Aug 2010 05:05:28 -0700
Message-ID: <1281528329-8812-8-git-send-email-amit.salecha@qlogic.com>
References: <1281528329-8812-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:62081 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751843Ab0HKMFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 08:05:30 -0400
In-Reply-To: <1281528329-8812-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    1 +
 drivers/net/qlcnic/qlcnic_ethtool.c |    8 ++++++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index ae02b53..1d680a5 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -894,6 +894,7 @@ struct qlcnic_mac_req {
 #define QLCNIC_MSI_ENABLED		0x02
 #define QLCNIC_MSIX_ENABLED		0x04
 #define QLCNIC_LRO_ENABLED		0x08
+#define QLCNIC_LRO_DISABLED		0x00
 #define QLCNIC_BRIDGE_ENABLED       	0X10
 #define QLCNIC_DIAG_ENABLED		0x20
 #define QLCNIC_ESWITCH_ENABLED		0x40
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 3d4655d..706eb80 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -819,6 +819,14 @@ static int qlcnic_set_rx_csum(struct net_device *dev, u32 data)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	adapter->rx_csum = !!data;
+
+	if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO))
+		return 0;
+
+	if (!adapter->rx_csum && !(dev->features & NETIF_F_LRO)) {
+		dev->features &= ~NETIF_F_LRO;
+		qlcnic_config_hw_lro(adapter, QLCNIC_LRO_DISABLED);
+	}
 	return 0;
 }
 
-- 
1.6.0.2

