From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 11/12] be2net: remove multiple assignments on a single line
Date: Fri, 19 Sep 2014 15:47:01 +0530
Message-ID: <1411121822-25842-12-git-send-email-sathya.perla@emulex.com>
References: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:53077 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944AbaISKOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:14:34 -0400
In-Reply-To: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This patch removes multiple assignments on a single line as warned
by checkpatch.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    8 ++++----
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    6 ++++--
 drivers/net/ethernet/emulex/benet/be_main.c    |    6 ++++--
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 48f4be3..58e7eff 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1910,8 +1910,8 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 					    BE_IF_FLAGS_VLAN_PROMISCUOUS |
 					    BE_IF_FLAGS_MCAST_PROMISCUOUS);
 	} else if (flags & IFF_ALLMULTI) {
-		req->if_flags_mask = req->if_flags =
-				cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS);
+		req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS);
+		req->if_flags =	cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS);
 	} else if (flags & BE_FLAGS_VLAN_PROMISC) {
 		req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_VLAN_PROMISCUOUS);
 
@@ -1922,8 +1922,8 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 		struct netdev_hw_addr *ha;
 		int i = 0;
 
-		req->if_flags_mask = req->if_flags =
-				cpu_to_le32(BE_IF_FLAGS_MULTICAST);
+		req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_MULTICAST);
+		req->if_flags =	cpu_to_le32(BE_IF_FLAGS_MULTICAST);
 
 		/* Reset mcast promisc mode if already set by setting mask
 		 * and not setting flags field
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 42b10f9..240fb46 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -684,8 +684,10 @@ static void be_get_ringparam(struct net_device *netdev,
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
-	ring->rx_max_pending = ring->rx_pending = adapter->rx_obj[0].q.len;
-	ring->tx_max_pending = ring->tx_pending = adapter->tx_obj[0].q.len;
+	ring->rx_max_pending = adapter->rx_obj[0].q.len;
+	ring->rx_pending = adapter->rx_obj[0].q.len;
+	ring->tx_max_pending = adapter->tx_obj[0].q.len;
+	ring->tx_pending = adapter->tx_obj[0].q.len;
 }
 
 static void
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 0bed42b..78f1de6 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2061,7 +2061,8 @@ static void be_rx_cq_clean(struct be_rx_obj *rxo)
 		memset(page_info, 0, sizeof(*page_info));
 	}
 	BUG_ON(atomic_read(&rxq->used));
-	rxq->tail = rxq->head = 0;
+	rxq->tail = 0;
+	rxq->head = 0;
 }
 
 static void be_tx_compl_clean(struct be_adapter *adapter)
@@ -4923,7 +4924,8 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 
 	INIT_DELAYED_WORK(&adapter->work, be_worker);
 	INIT_DELAYED_WORK(&adapter->func_recovery_work, be_func_recovery_task);
-	adapter->rx_fc = adapter->tx_fc = true;
+	adapter->rx_fc = true;
+	adapter->tx_fc = true;
 
 	status = be_setup(adapter);
 	if (status)
-- 
1.7.1
