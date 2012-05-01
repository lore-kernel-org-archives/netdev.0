From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 6/8] ixgbe: add syfs interface for to export read only driver information
Date: Tue,  1 May 2012 01:51:07 -0700
Message-ID: <1335862269-28914-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335862269-28914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46313 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754287Ab2EAIvP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 04:51:15 -0400
In-Reply-To: <1335862269-28914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch exports non-thermal (which was done via hwmon in an earlier
patch) data to sysfs which isn't readily available elsewhere.  All of the
fields are read only as this interface is to only export driver data.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |  322 +++++++++++++++++++++++-
 1 files changed, 317 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
index aa41fb7..6601986 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -41,6 +41,310 @@
  * This file provides a sysfs interface to export information from the
  * driver.  The information presented is READ-ONLY.
  */
+
+static struct net_device *ixgbe_get_netdev(struct kobject *kobj)
+{
+	struct net_device *netdev;
+	struct kobject *parent = kobj->parent;
+	struct device *device_info_kobj;
+
+	if (kobj == NULL)
+		return NULL;
+
+	device_info_kobj = container_of(parent, struct device, kobj);
+	if (device_info_kobj == NULL)
+		return NULL;
+
+	netdev = container_of(device_info_kobj, struct net_device, dev);
+	return netdev;
+}
+
+static struct ixgbe_adapter *ixgbe_get_adapter(struct kobject *kobj)
+{
+	struct ixgbe_adapter *adapter;
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return NULL;
+
+	adapter = netdev_priv(netdev);
+	return adapter;
+}
+
+static ssize_t ixgbe_rxupacks(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_TPR));
+}
+
+static ssize_t ixgbe_rxmpacks(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_MPRC));
+}
+
+static ssize_t ixgbe_rxbpacks(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_BPRC));
+}
+
+static ssize_t ixgbe_txupacks(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_TPT));
+}
+
+static ssize_t ixgbe_txmpacks(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_MPTC));
+}
+
+static ssize_t ixgbe_txbpacks(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_BPTC));
+}
+
+static ssize_t ixgbe_maclla1(struct kobject *kobj,
+			     struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_hw *hw;
+	u16 eeprom_buff[6];
+	int first_word = 0x37;
+	int word_count = 6;
+	int rc;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	hw = &adapter->hw;
+	if (hw == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
+
+	rc = hw->eeprom.ops.read_buffer(hw, first_word, word_count,
+					eeprom_buff);
+	if (rc)
+		return snprintf(buf, PAGE_SIZE, "error: reading buffer\n");
+
+	switch (hw->bus.func) {
+	case 0:
+		return snprintf(buf, PAGE_SIZE, "0x%04X%04X%04X\n",
+				eeprom_buff[0],
+				eeprom_buff[1],
+				eeprom_buff[2]);
+	case 1:
+		return snprintf(buf, PAGE_SIZE, "0x%04X%04X%04X\n",
+				eeprom_buff[3],
+				eeprom_buff[4],
+				eeprom_buff[5]);
+	}
+
+	return snprintf(buf, PAGE_SIZE, "unexpected port %d\n", hw->bus.func);
+}
+
+static ssize_t ixgbe_txdscqsz(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->tx_ring[0]->count);
+}
+
+static ssize_t ixgbe_rxdscqsz(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->rx_ring[0]->count);
+}
+
+static ssize_t ixgbe_rxqavg(struct kobject *kobj,
+			    struct kobj_attribute *attr, char *buf)
+{
+	int index;
+	int diff = 0;
+	u16 ntc;
+	u16 ntu;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	for (index = 0; index < adapter->num_rx_queues; index++) {
+		ntc = adapter->rx_ring[index]->next_to_clean;
+		ntu = adapter->rx_ring[index]->next_to_use;
+
+		if (ntc >= ntu)
+			diff += (ntc - ntu);
+		else
+			diff += (adapter->rx_ring[index]->count - ntu + ntc);
+	}
+
+	if (adapter->num_rx_queues <= 0)
+		return snprintf(buf, PAGE_SIZE,
+				"can't calculate, number of queues %d\n",
+				adapter->num_rx_queues);
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", diff/adapter->num_rx_queues);
+}
+
+static ssize_t ixgbe_txqavg(struct kobject *kobj,
+			    struct kobj_attribute *attr, char *buf)
+{
+	int index;
+	int diff = 0;
+	u16 ntc;
+	u16 ntu;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	for (index = 0; index < adapter->num_tx_queues; index++) {
+		ntc = adapter->tx_ring[index]->next_to_clean;
+		ntu = adapter->tx_ring[index]->next_to_use;
+
+		if (ntc >= ntu)
+			diff += (ntc - ntu);
+		else
+			diff += (adapter->tx_ring[index]->count - ntu + ntc);
+	}
+
+	if (adapter->num_tx_queues <= 0)
+		return snprintf(buf, PAGE_SIZE,
+				"can't calculate, number of queues %d\n",
+				adapter->num_tx_queues);
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", diff/adapter->num_tx_queues);
+}
+
+static ssize_t ixgbe_funcnbr(struct kobject *kobj,
+			     struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->num_vfs);
+}
+
+/* Initialize the attributes */
+static struct kobj_attribute ixgbe_sysfs_rxupacks_attr =
+	__ATTR(rxupacks, 0444, ixgbe_rxupacks, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxmpacks_attr =
+	__ATTR(rxmpacks, 0444, ixgbe_rxmpacks, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxbpacks_attr =
+	__ATTR(rxbpacks, 0444, ixgbe_rxbpacks, NULL);
+static struct kobj_attribute ixgbe_sysfs_txupacks_attr =
+	__ATTR(txupacks, 0444, ixgbe_txupacks, NULL);
+static struct kobj_attribute ixgbe_sysfs_txmpacks_attr =
+	__ATTR(txmpacks, 0444, ixgbe_txmpacks, NULL);
+static struct kobj_attribute ixgbe_sysfs_txbpacks_attr =
+	__ATTR(txbpacks, 0444, ixgbe_txbpacks, NULL);
+static struct kobj_attribute ixgbe_sysfs_maclla1_attr =
+	__ATTR(maclla1, 0444, ixgbe_maclla1, NULL);
+static struct kobj_attribute ixgbe_sysfs_txdscqsz_attr =
+	__ATTR(txdscqsz, 0444, ixgbe_txdscqsz, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxdscqsz_attr =
+	__ATTR(rxdscqsz, 0444, ixgbe_rxdscqsz, NULL);
+static struct kobj_attribute ixgbe_sysfs_txqavg_attr =
+	__ATTR(txqavg, 0444, ixgbe_txqavg, NULL);
+static struct kobj_attribute ixgbe_sysfs_rxqavg_attr =
+	__ATTR(rxqavg, 0444, ixgbe_rxqavg, NULL);
+static struct kobj_attribute ixgbe_sysfs_funcnbr_attr =
+	__ATTR(funcnbr, 0444, ixgbe_funcnbr, NULL);
+
+static struct attribute *attrs[] = {
+	&ixgbe_sysfs_rxupacks_attr.attr,
+	&ixgbe_sysfs_rxmpacks_attr.attr,
+	&ixgbe_sysfs_rxbpacks_attr.attr,
+	&ixgbe_sysfs_txupacks_attr.attr,
+	&ixgbe_sysfs_txmpacks_attr.attr,
+	&ixgbe_sysfs_txbpacks_attr.attr,
+	&ixgbe_sysfs_maclla1_attr.attr,
+	&ixgbe_sysfs_txdscqsz_attr.attr,
+	&ixgbe_sysfs_rxdscqsz_attr.attr,
+	&ixgbe_sysfs_txqavg_attr.attr,
+	&ixgbe_sysfs_rxqavg_attr.attr,
+	&ixgbe_sysfs_funcnbr_attr.attr,
+	NULL
+};
+
+/* add attributes to a group */
+static struct attribute_group attr_group = {
+	.attrs = attrs,
+};
+
 #ifdef CONFIG_IXGBE_HWMON
 
 /* hwmon callback functions */
@@ -185,8 +489,11 @@ static void ixgbe_sysfs_del_adapter(struct ixgbe_adapter *adapter)
 		hwmon_device_unregister(adapter->ixgbe_hwmon_buff.device);
 #endif /* CONFIG_IXGBE_HWMON */
 
-	if (adapter->info_kobj != NULL)
+	if (adapter->info_kobj != NULL) {
+		sysfs_remove_group(adapter->info_kobj, &attr_group);
 		kobject_put(adapter->info_kobj);
+		adapter->info_kobj = NULL;
+	}
 }
 
 /* called from ixgbe_main.c */
@@ -213,17 +520,22 @@ int ixgbe_sysfs_init(struct ixgbe_adapter *adapter)
 		goto err;
 	}
 
+	rc = sysfs_create_group(adapter->info_kobj, &attr_group);
+	if (rc)
+		goto err;
+
 #ifdef CONFIG_IXGBE_HWMON
 	/* If this method isn't defined we don't support thermals */
 	if (adapter->hw.mac.ops.init_thermal_sensor_thresh == NULL) {
-		rc = -EPERM;
-		goto err;
+		goto exit;
 	}
 
 	/* Don't create thermal hwmon interface if no sensors present */
 	rc = adapter->hw.mac.ops.init_thermal_sensor_thresh(&adapter->hw);
-	if (rc)
-		goto err;
+	if (rc) {
+		rc = 0;
+		goto exit;
+	}
 
 	/*
 	 * Allocation space for max attributs
-- 
1.7.7.6
