From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 03/12] netxen: configure interrupt coalesce defaults
Date: Sun, 26 Jul 2009 23:07:38 -0700
Message-ID: <1248674867-18821-4-git-send-email-dhananjay@netxen.com>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33562 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751075AbZG0GHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:07:47 -0400
In-Reply-To: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize and configure interrupt coalesing defaults
in the firmware, so that these also reflect in "ethool -c".

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b368326..76bdd5c 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -819,6 +819,20 @@ netxen_nic_free_irq(struct netxen_adapter *adapter)
 	}
 }
 
+static void
+netxen_nic_init_coalesce_defaults(struct netxen_adapter *adapter)
+{
+	adapter->coal.flags = NETXEN_NIC_INTR_DEFAULT;
+	adapter->coal.normal.data.rx_time_us =
+		NETXEN_DEFAULT_INTR_COALESCE_RX_TIME_US;
+	adapter->coal.normal.data.rx_packets =
+		NETXEN_DEFAULT_INTR_COALESCE_RX_PACKETS;
+	adapter->coal.normal.data.tx_time_us =
+		NETXEN_DEFAULT_INTR_COALESCE_TX_TIME_US;
+	adapter->coal.normal.data.tx_packets =
+		NETXEN_DEFAULT_INTR_COALESCE_TX_PACKETS;
+}
+
 static int
 netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 {
@@ -841,6 +855,9 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 	if (adapter->max_sds_rings > 1)
 		netxen_config_rss(adapter, 1);
 
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		netxen_config_intr_coalesce(adapter);
+
 	netxen_napi_enable(adapter);
 
 	if (adapter->capabilities & NX_FW_CAPABILITY_LINK_NOTIFICATION)
@@ -936,6 +953,9 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 		goto err_out_free_rxbuf;
 	}
 
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		netxen_nic_init_coalesce_defaults(adapter);
+
 	adapter->is_up = NETXEN_ADAPTER_UP_MAGIC;
 	return 0;
 
-- 
1.6.0.2

