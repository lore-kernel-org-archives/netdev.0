From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 09/10] atl1: make functions static
Date: Sat,  2 Feb 2008 19:50:11 -0600
Message-ID: <1202003412-4028-9-git-send-email-jacliburn@bellsouth.net>
References: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost06.isp.att.net ([204.127.217.106]:56741 "EHLO
	fmailhost06.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933465AbYBCBuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 20:50:25 -0500
In-Reply-To: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make needlessly global functions static.  In a couple of cases this
requires removing forward declarations and reordering functions.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
Acked-by: Chris Snook <csnook@redhat.com>
---
 drivers/net/atlx/atl1.c |  101 ++++++++++++++++++++++++-----------------------
 drivers/net/atlx/atl1.h |    3 -
 2 files changed, 51 insertions(+), 53 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 4e4cb23..6f4a1d5 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -211,7 +211,7 @@ static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
  *
  * Return 0 on success, negative on failure
  */
-s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
+static s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 {
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
@@ -402,7 +402,7 @@ static void atl1_clean_tx_ring(struct atl1_adapter *adapter)
  *
  * Free all transmit software resources
  */
-void atl1_free_ring_resources(struct atl1_adapter *adapter)
+static void atl1_free_ring_resources(struct atl1_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
@@ -580,40 +580,6 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 	return 0;
 }
 
-/*
- * atl1_change_mtu - Change the Maximum Transfer Unit
- * @netdev: network interface device structure
- * @new_mtu: new value for maximum frame size
- *
- * Returns 0 on success, negative on failure
- */
-static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	int old_mtu = netdev->mtu;
-	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
-
-	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
-	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		if (netif_msg_link(adapter))
-			dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
-		return -EINVAL;
-	}
-
-	adapter->hw.max_frame_size = max_frame;
-	adapter->hw.tx_jumbo_task_th = (max_frame + 7) >> 3;
-	adapter->rx_buffer_len = (max_frame + 7) & ~7;
-	adapter->hw.rx_jumbo_th = adapter->rx_buffer_len / 8;
-
-	netdev->mtu = new_mtu;
-	if ((old_mtu != new_mtu) && netif_running(netdev)) {
-		atl1_down(adapter);
-		atl1_up(adapter);
-	}
-
-	return 0;
-}
-
 static void set_flow_ctrl_old(struct atl1_adapter *adapter)
 {
 	u32 hi, lo, value;
@@ -1794,19 +1760,8 @@ static void atl1_phy_config(unsigned long data)
  * assert again and again.
  * </vendor comment>
  */
-static void atl1_tx_timeout_task(struct work_struct *work)
-{
-	struct atl1_adapter *adapter =
-		container_of(work, struct atl1_adapter, tx_timeout_task);
-	struct net_device *netdev = adapter->netdev;
 
-	netif_device_detach(netdev);
-	atl1_down(adapter);
-	atl1_up(adapter);
-	netif_device_attach(netdev);
-}
-
-int atl1_reset(struct atl1_adapter *adapter)
+static int atl1_reset(struct atl1_adapter *adapter)
 {
 	int ret;
 	ret = atl1_reset_hw(&adapter->hw);
@@ -1815,7 +1770,7 @@ int atl1_reset(struct atl1_adapter *adapter)
 	return atl1_init_hw(&adapter->hw);
 }
 
-s32 atl1_up(struct atl1_adapter *adapter)
+static s32 atl1_up(struct atl1_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	int err;
@@ -1860,7 +1815,7 @@ err_up:
 	return err;
 }
 
-void atl1_down(struct atl1_adapter *adapter)
+static void atl1_down(struct atl1_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
@@ -1883,6 +1838,52 @@ void atl1_down(struct atl1_adapter *adapter)
 	atl1_clean_rx_ring(adapter);
 }
 
+static void atl1_tx_timeout_task(struct work_struct *work)
+{
+	struct atl1_adapter *adapter =
+		container_of(work, struct atl1_adapter, tx_timeout_task);
+	struct net_device *netdev = adapter->netdev;
+
+	netif_device_detach(netdev);
+	atl1_down(adapter);
+	atl1_up(adapter);
+	netif_device_attach(netdev);
+}
+
+/*
+ * atl1_change_mtu - Change the Maximum Transfer Unit
+ * @netdev: network interface device structure
+ * @new_mtu: new value for maximum frame size
+ *
+ * Returns 0 on success, negative on failure
+ */
+static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	int old_mtu = netdev->mtu;
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+
+	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
+	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
+		if (netif_msg_link(adapter))
+			dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
+		return -EINVAL;
+	}
+
+	adapter->hw.max_frame_size = max_frame;
+	adapter->hw.tx_jumbo_task_th = (max_frame + 7) >> 3;
+	adapter->rx_buffer_len = (max_frame + 7) & ~7;
+	adapter->hw.rx_jumbo_th = adapter->rx_buffer_len / 8;
+
+	netdev->mtu = new_mtu;
+	if ((old_mtu != new_mtu) && netif_running(netdev)) {
+		atl1_down(adapter);
+		atl1_up(adapter);
+	}
+
+	return 0;
+}
+
 /*
  * atl1_open - Called when a network interface is made active
  * @netdev: network interface device structure
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index 12ec916..6220298 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -73,9 +73,6 @@ void atl1_check_options(struct atl1_adapter *adapter);
 static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 	int cmd);
 static u32 atl1_check_link(struct atl1_adapter *adapter);
-s32 atl1_up(struct atl1_adapter *adapter);
-void atl1_down(struct atl1_adapter *adapter);
-int atl1_reset(struct atl1_adapter *adapter);
 
 extern const struct ethtool_ops atl1_ethtool_ops;
 
-- 
1.5.3.8

