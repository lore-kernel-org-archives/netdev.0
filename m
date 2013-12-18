From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/2 v2] qlcnic: make local functions static
Date: Wed, 18 Dec 2013 13:54:38 -0800
Message-ID: <20131218135438.71ea917f@nehalam.linuxnetplumber.net>
References: <20131213123119.16358e1b@nehalam.linuxnetplumber.net>
	<1902752B0C92F943AB7EA9EE13E2DEEC1273B9F4A5@HQ1-EXCH02.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33335 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548Ab3LRVzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 16:55:55 -0500
Received: by mail-pa0-f42.google.com with SMTP id lj1so249521pab.15
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 13:55:54 -0800 (PST)
In-Reply-To: <1902752B0C92F943AB7EA9EE13E2DEEC1273B9F4A5@HQ1-EXCH02.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions only used in one file should be static.
Found by running make namespacecheck

Compile tested only.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
v2 - update to latest net-next

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h              |   15 ------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c      |   33 ++++++++++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h      |   20 ---------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c    |    4 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c    |    2 
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c      |   33 +++++++--------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c           |   10 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h           |    4 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c           |   25 +++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c         |   22 +++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h        |    3 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c |    9 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c        |    4 -
 13 files changed, 86 insertions(+), 98 deletions(-)

--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c	2013-12-18 13:32:21.098021506 -0800
@@ -13,6 +13,22 @@
 #include <linux/interrupt.h>
 #include <linux/aer.h>
 
+static void __qlcnic_83xx_process_aen(struct qlcnic_adapter *);
+static int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *, u8);
+static void qlcnic_83xx_configure_mac(struct qlcnic_adapter *, u8 *, u8,
+				      struct qlcnic_cmd_args *);
+static int qlcnic_83xx_get_port_config(struct qlcnic_adapter *);
+static irqreturn_t qlcnic_83xx_handle_aen(int, void *);
+static pci_ers_result_t qlcnic_83xx_io_error_detected(struct pci_dev *,
+						      pci_channel_state_t);
+static int qlcnic_83xx_set_port_config(struct qlcnic_adapter *);
+static pci_ers_result_t qlcnic_83xx_io_slot_reset(struct pci_dev *);
+static void qlcnic_83xx_io_resume(struct pci_dev *);
+static int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *, u8);
+static void qlcnic_83xx_set_mac_filter_count(struct qlcnic_adapter *);
+static int qlcnic_83xx_resume(struct qlcnic_adapter *);
+static int qlcnic_83xx_shutdown(struct pci_dev *);
+
 #define RSS_HASHTYPE_IP_TCP		0x3
 #define QLC_83XX_FW_MBX_CMD		0
 #define QLC_SKIP_INACTIVE_PCI_REGS	7
@@ -317,12 +333,12 @@ int qlcnic_83xx_setup_intr(struct qlcnic
 	return 0;
 }
 
-inline void qlcnic_83xx_clear_legacy_intr_mask(struct qlcnic_adapter *adapter)
+static inline void qlcnic_83xx_clear_legacy_intr_mask(struct qlcnic_adapter *adapter)
 {
 	writel(0, adapter->tgt_mask_reg);
 }
 
-inline void qlcnic_83xx_set_legacy_intr_mask(struct qlcnic_adapter *adapter)
+static inline void qlcnic_83xx_set_legacy_intr_mask(struct qlcnic_adapter *adapter)
 {
 	if (adapter->tgt_mask_reg)
 		writel(1, adapter->tgt_mask_reg);
@@ -342,8 +358,7 @@ void qlcnic_83xx_disable_intr(struct qlc
 	writel(1, sds_ring->crb_intr_mask);
 }
 
-inline void qlcnic_83xx_enable_legacy_msix_mbx_intr(struct qlcnic_adapter
-						    *adapter)
+static void qlcnic_83xx_enable_legacy_msix_mbx_intr(struct qlcnic_adapter *adapter)
 {
 	u32 mask;
 
@@ -635,7 +650,7 @@ int qlcnic_83xx_get_port_info(struct qlc
 	return status;
 }
 
-void qlcnic_83xx_set_mac_filter_count(struct qlcnic_adapter *adapter)
+static void qlcnic_83xx_set_mac_filter_count(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u16 act_pci_fn = ahw->total_nic_func;
@@ -870,7 +885,7 @@ static void qlcnic_83xx_handle_idc_comp_
 	return;
 }
 
-void __qlcnic_83xx_process_aen(struct qlcnic_adapter *adapter)
+static void __qlcnic_83xx_process_aen(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u32 event[QLC_83XX_MBX_AEN_CNT];
@@ -1552,7 +1567,7 @@ void qlcnic_83xx_initialize_nic(struct q
 	qlcnic_free_mbx_args(&cmd);
 }
 
-int qlcnic_83xx_set_port_config(struct qlcnic_adapter *adapter)
+static int qlcnic_83xx_set_port_config(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_cmd_args cmd;
 	int err;
@@ -1807,7 +1822,7 @@ int qlcnic_83xx_set_lb_mode(struct qlcni
 	return status;
 }
 
-int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
+static int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u32 config = ahw->port_config, max_wait_count;
@@ -3544,7 +3559,7 @@ int qlcnic_83xx_shutdown(struct pci_dev
 	return 0;
 }
 
-int qlcnic_83xx_resume(struct qlcnic_adapter *adapter)
+static int qlcnic_83xx_resume(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlc_83xx_idc *idc = &ahw->idc;
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h	2013-12-18 13:32:21.098021506 -0800
@@ -542,10 +542,7 @@ void qlcnic_83xx_write_crb(struct qlcnic
 void qlcnic_83xx_read_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
 int qlcnic_83xx_rd_reg_indirect(struct qlcnic_adapter *, ulong, int *);
 int qlcnic_83xx_wrt_reg_indirect(struct qlcnic_adapter *, ulong, u32);
-void qlcnic_83xx_process_rcv_diag(struct qlcnic_adapter *, int, u64 []);
 int qlcnic_83xx_nic_set_promisc(struct qlcnic_adapter *, u32);
-int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *, u8);
-int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *, u8);
 int qlcnic_83xx_config_hw_lro(struct qlcnic_adapter *, int);
 int qlcnic_83xx_config_rss(struct qlcnic_adapter *, int);
 int qlcnic_83xx_config_intr_coalesce(struct qlcnic_adapter *);
@@ -573,15 +570,12 @@ void qlcnic_83xx_process_rcv_ring_diag(s
 int qlcnic_83xx_config_intrpt(struct qlcnic_adapter *, bool);
 int qlcnic_83xx_sre_macaddr_change(struct qlcnic_adapter *, u8 *, u16, u8);
 int qlcnic_83xx_get_mac_address(struct qlcnic_adapter *, u8 *, u8);
-void qlcnic_83xx_configure_mac(struct qlcnic_adapter *, u8 *, u8,
-			       struct qlcnic_cmd_args *);
 int qlcnic_83xx_alloc_mbx_args(struct qlcnic_cmd_args *,
 			       struct qlcnic_adapter *, u32);
 void qlcnic_free_mbx_args(struct qlcnic_cmd_args *);
 void qlcnic_set_npar_data(struct qlcnic_adapter *, const struct qlcnic_info *,
 			  struct qlcnic_info *);
 void qlcnic_83xx_config_intr_coal(struct qlcnic_adapter *);
-irqreturn_t qlcnic_83xx_handle_aen(int, void *);
 int qlcnic_83xx_get_port_info(struct qlcnic_adapter *);
 void qlcnic_83xx_enable_mbx_interrupt(struct qlcnic_adapter *);
 void qlcnic_83xx_disable_mbx_intr(struct qlcnic_adapter *);
@@ -594,11 +588,7 @@ void qlcnic_83xx_disable_intr(struct qlc
 			     struct qlcnic_host_sds_ring *);
 void qlcnic_83xx_check_vf(struct qlcnic_adapter *,
 			  const struct pci_device_id *);
-void __qlcnic_83xx_process_aen(struct qlcnic_adapter *);
-int qlcnic_83xx_get_port_config(struct qlcnic_adapter *);
-int qlcnic_83xx_set_port_config(struct qlcnic_adapter *);
 int qlcnic_enable_eswitch(struct qlcnic_adapter *, u8, u8);
-int qlcnic_83xx_get_nic_configuration(struct qlcnic_adapter *);
 int qlcnic_83xx_config_default_opmode(struct qlcnic_adapter *);
 int qlcnic_83xx_setup_mbx_intr(struct qlcnic_adapter *);
 void qlcnic_83xx_free_mbx_intr(struct qlcnic_adapter *);
@@ -620,9 +610,7 @@ int qlcnic_83xx_lockless_flash_read32(st
 				      u32, u8 *, int);
 int qlcnic_83xx_init(struct qlcnic_adapter *, int);
 int qlcnic_83xx_idc_ready_state_entry(struct qlcnic_adapter *);
-int qlcnic_83xx_check_hw_status(struct qlcnic_adapter *p_dev);
 void qlcnic_83xx_idc_poll_dev_state(struct work_struct *);
-int qlcnic_83xx_get_reset_instruction_template(struct qlcnic_adapter *);
 void qlcnic_83xx_idc_exit(struct qlcnic_adapter *);
 void qlcnic_83xx_idc_request_reset(struct qlcnic_adapter *, u32);
 int qlcnic_83xx_lock_driver(struct qlcnic_adapter *);
@@ -630,7 +618,6 @@ void qlcnic_83xx_unlock_driver(struct ql
 int qlcnic_83xx_set_default_offload_settings(struct qlcnic_adapter *);
 int qlcnic_83xx_ms_mem_write128(struct qlcnic_adapter *, u64, u32 *, u32);
 int qlcnic_83xx_idc_vnic_pf_entry(struct qlcnic_adapter *);
-int qlcnic_83xx_enable_vnic_mode(struct qlcnic_adapter *, int);
 int qlcnic_83xx_disable_vnic_mode(struct qlcnic_adapter *, int);
 int qlcnic_83xx_config_vnic_opmode(struct qlcnic_adapter *);
 int qlcnic_83xx_get_vnic_vport_info(struct qlcnic_adapter *,
@@ -658,9 +645,6 @@ int qlcnic_83xx_enable_flash_write(struc
 int qlcnic_83xx_disable_flash_write(struct qlcnic_adapter *);
 void qlcnic_83xx_enable_mbx_poll(struct qlcnic_adapter *);
 void qlcnic_83xx_disable_mbx_poll(struct qlcnic_adapter *);
-void qlcnic_83xx_set_mac_filter_count(struct qlcnic_adapter *);
-int qlcnic_83xx_shutdown(struct pci_dev *);
-int qlcnic_83xx_resume(struct qlcnic_adapter *);
 int qlcnic_83xx_idc_init(struct qlcnic_adapter *);
 int qlcnic_83xx_idc_reattach_driver(struct qlcnic_adapter *);
 int qlcnic_83xx_set_vnic_opmode(struct qlcnic_adapter *);
@@ -668,8 +652,4 @@ int qlcnic_83xx_check_vnic_state(struct
 void qlcnic_83xx_aer_stop_poll_work(struct qlcnic_adapter *);
 int qlcnic_83xx_aer_reset(struct qlcnic_adapter *);
 void qlcnic_83xx_aer_start_poll_work(struct qlcnic_adapter *);
-pci_ers_result_t qlcnic_83xx_io_error_detected(struct pci_dev *,
-					       pci_channel_state_t);
-pci_ers_result_t qlcnic_83xx_io_slot_reset(struct pci_dev *);
-void qlcnic_83xx_io_resume(struct pci_dev *);
 #endif
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h	2013-12-18 13:25:07.324212943 -0800
@@ -1466,8 +1466,6 @@ int qlcnic_fw_cmd_get_minidump_temp(stru
 int qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config);
 int qlcnic_pci_mem_write_2M(struct qlcnic_adapter *, u64 off, u64 data);
 int qlcnic_pci_mem_read_2M(struct qlcnic_adapter *, u64 off, u64 *data);
-void qlcnic_pci_camqm_read_2M(struct qlcnic_adapter *, u64, u64 *);
-void qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *, u64, u64);
 
 #define ADDR_IN_RANGE(addr, low, high)	\
 	(((addr) < (high)) && ((addr) >= (low)))
@@ -1503,16 +1501,11 @@ void qlcnic_pcie_sem_unlock(struct qlcni
 
 #define MAX_CTL_CHECK 1000
 
-int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
 void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
 void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
 int qlcnic_dump_fw(struct qlcnic_adapter *);
 int qlcnic_enable_fw_dump_state(struct qlcnic_adapter *);
 bool qlcnic_check_fw_dump_state(struct qlcnic_adapter *);
-pci_ers_result_t qlcnic_82xx_io_error_detected(struct pci_dev *,
-					       pci_channel_state_t);
-pci_ers_result_t qlcnic_82xx_io_slot_reset(struct pci_dev *);
-void qlcnic_82xx_io_resume(struct pci_dev *);
 
 /* Functions from qlcnic_init.c */
 void qlcnic_schedule_work(struct qlcnic_adapter *, work_func_t, int);
@@ -1547,7 +1540,6 @@ int qlcnic_check_fw_status(struct qlcnic
 void qlcnic_watchdog_task(struct work_struct *work);
 void qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_rds_ring *rds_ring, u8 ring_id);
-int qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max);
 void qlcnic_set_multi(struct net_device *netdev);
 void __qlcnic_set_multi(struct net_device *, u16);
 int qlcnic_nic_add_mac(struct qlcnic_adapter *, const u8 *, u16);
@@ -1562,13 +1554,11 @@ netdev_features_t qlcnic_fix_features(st
 	netdev_features_t features);
 int qlcnic_set_features(struct net_device *netdev, netdev_features_t features);
 int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
-int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
 void qlcnic_update_cmd_producer(struct qlcnic_host_tx_ring *);
 
 /* Functions from qlcnic_ethtool.c */
 int qlcnic_check_loopback_buff(unsigned char *, u8 []);
 int qlcnic_do_lb_test(struct qlcnic_adapter *, u8);
-int qlcnic_loopback_test(struct net_device *, u8);
 
 /* Functions from qlcnic_main.c */
 int qlcnic_reset_context(struct qlcnic_adapter *);
@@ -1580,7 +1570,6 @@ void qlcnic_set_sds_ring_count(struct ql
 int qlcnic_setup_rings(struct qlcnic_adapter *, u8, u8);
 int qlcnic_validate_rings(struct qlcnic_adapter *, __u32, int);
 void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
-void qlcnic_82xx_set_mac_filter_count(struct qlcnic_adapter *);
 int qlcnic_enable_msix(struct qlcnic_adapter *, u32);
 void qlcnic_set_drv_version(struct qlcnic_adapter *);
 
@@ -1609,11 +1598,8 @@ void qlcnic_dump_mbx(struct qlcnic_adapt
 
 void qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter);
 void qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter);
-void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter);
-void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter);
 void qlcnic_82xx_add_sysfs(struct qlcnic_adapter *adapter);
 void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter);
-int qlcnic_82xx_get_settings(struct qlcnic_adapter *, struct ethtool_cmd *);
 
 int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
 int qlcnicvf_config_led(struct qlcnic_adapter *, u32, u32);
@@ -1636,7 +1622,6 @@ int qlcnic_init_pci_info(struct qlcnic_a
 int qlcnic_set_default_offload_settings(struct qlcnic_adapter *);
 int qlcnic_reset_npar_config(struct qlcnic_adapter *);
 int qlcnic_set_eswitch_port_config(struct qlcnic_adapter *);
-void qlcnic_add_lb_filter(struct qlcnic_adapter *, struct sk_buff *, int, u16);
 int qlcnic_get_beacon_state(struct qlcnic_adapter *, u8 *);
 int qlcnic_83xx_configure_opmode(struct qlcnic_adapter *adapter);
 int qlcnic_read_mac_addr(struct qlcnic_adapter *);
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c	2013-12-18 13:25:07.328212885 -0800
@@ -270,21 +270,8 @@ qlcnic_get_drvinfo(struct net_device *de
 		sizeof(drvinfo->version));
 }
 
-static int
-qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
-{
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
-
-	if (qlcnic_82xx_check(adapter))
-		return qlcnic_82xx_get_settings(adapter, ecmd);
-	else if (qlcnic_83xx_check(adapter))
-		return qlcnic_83xx_get_settings(adapter, ecmd);
-
-	return -EIO;
-}
-
-int qlcnic_82xx_get_settings(struct qlcnic_adapter *adapter,
-			     struct ethtool_cmd *ecmd)
+static int qlcnic_82xx_get_settings(struct qlcnic_adapter *adapter,
+				    struct ethtool_cmd *ecmd)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u32 speed, reg;
@@ -425,6 +412,20 @@ skip:
 	return 0;
 }
 
+static int qlcnic_get_settings(struct net_device *dev,
+			       struct ethtool_cmd *ecmd)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+
+	if (qlcnic_82xx_check(adapter))
+		return qlcnic_82xx_get_settings(adapter, ecmd);
+	else if (qlcnic_83xx_check(adapter))
+		return qlcnic_83xx_get_settings(adapter, ecmd);
+
+	return -EIO;
+}
+
+
 static int qlcnic_set_port_config(struct qlcnic_adapter *adapter,
 				  struct ethtool_cmd *ecmd)
 {
@@ -1055,7 +1056,7 @@ int qlcnic_do_lb_test(struct qlcnic_adap
 	return 0;
 }
 
-int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
+static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int drv_tx_rings = adapter->drv_tx_rings;
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c	2013-12-18 13:25:07.328212885 -0800
@@ -1299,7 +1299,7 @@ void qlcnic_remove_sysfs_entries(struct
 		device_remove_file(dev, &dev_attr_bridged_mode);
 }
 
-void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
+static void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
@@ -1338,7 +1338,7 @@ void qlcnic_create_diag_entries(struct q
 		dev_info(dev, "failed to create eswitch stats sysfs entry");
 }
 
-void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
+static void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c	2013-12-18 13:25:07.328212885 -0800
@@ -39,6 +39,8 @@
 static int qlcnic_83xx_init_default_driver(struct qlcnic_adapter *adapter);
 static int qlcnic_83xx_check_heartbeat(struct qlcnic_adapter *p_dev);
 static int qlcnic_83xx_restart_hw(struct qlcnic_adapter *adapter);
+static int qlcnic_83xx_check_hw_status(struct qlcnic_adapter *p_dev);
+static int qlcnic_83xx_get_reset_instruction_template(struct qlcnic_adapter *);
 
 /* Template header */
 struct qlc_83xx_reset_hdr {
@@ -2013,7 +2015,7 @@ static int qlcnic_83xx_restart_hw(struct
 	return 0;
 }
 
-int qlcnic_83xx_get_nic_configuration(struct qlcnic_adapter *adapter)
+static int qlcnic_83xx_get_nic_configuration(struct qlcnic_adapter *adapter)
 {
 	int err;
 	struct qlcnic_info nic_info;
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c	2013-12-18 13:25:07.328212885 -0800
@@ -8,7 +8,7 @@
 #include "qlcnic.h"
 #include "qlcnic_hw.h"
 
-int qlcnic_83xx_enable_vnic_mode(struct qlcnic_adapter *adapter, int lock)
+static int qlcnic_83xx_enable_vnic_mode(struct qlcnic_adapter *adapter, int lock)
 {
 	if (lock) {
 		if (qlcnic_83xx_lock_driver(adapter))
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c	2013-12-18 13:32:59.205478715 -0800
@@ -505,7 +505,7 @@ int qlcnic_nic_add_mac(struct qlcnic_ada
 	return 0;
 }
 
-void __qlcnic_set_multi(struct net_device *netdev, u16 vlan)
+static void __qlcnic_set_multi(struct net_device *netdev, u16 vlan)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -944,7 +944,7 @@ int qlcnic_82xx_linkevent_request(struct
 	return rv;
 }
 
-int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter)
+static int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_nic_req req;
 	u64 word;
@@ -1243,7 +1243,7 @@ static int qlcnic_pci_mem_access_direct(
 	return 0;
 }
 
-void
+static void
 qlcnic_pci_camqm_read_2M(struct qlcnic_adapter *adapter, u64 off, u64 *data)
 {
 	void __iomem *addr = adapter->ahw->pci_base0 +
@@ -1254,7 +1254,7 @@ qlcnic_pci_camqm_read_2M(struct qlcnic_a
 	mutex_unlock(&adapter->ahw->mem_lock);
 }
 
-void
+static void
 qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *adapter, u64 off, u64 data)
 {
 	void __iomem *addr = adapter->ahw->pci_base0 +
@@ -1490,7 +1490,7 @@ int qlcnic_82xx_get_board_info(struct ql
 	return 0;
 }
 
-int
+static int
 qlcnic_wol_supported(struct qlcnic_adapter *adapter)
 {
 	u32 wol_cfg;
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c	2013-12-18 13:25:07.328212885 -0800
@@ -124,10 +124,9 @@
 #define qlcnic_83xx_is_ip_align(sts)	(((sts) >> 46) & 1)
 #define qlcnic_83xx_has_vlan_tag(sts)	(((sts) >> 47) & 1)
 
-struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *,
-				     struct qlcnic_host_rds_ring *, u16, u16);
+static int qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max);
 
-inline void qlcnic_enable_tx_intr(struct qlcnic_adapter *adapter,
+static void qlcnic_enable_tx_intr(struct qlcnic_adapter *adapter,
 				  struct qlcnic_host_tx_ring *tx_ring)
 {
 	if (qlcnic_check_multi_tx(adapter) &&
@@ -144,13 +143,13 @@ static inline void qlcnic_disable_tx_int
 		writel(1, tx_ring->crb_intr_mask);
 }
 
-inline void qlcnic_83xx_enable_tx_intr(struct qlcnic_adapter *adapter,
+static void qlcnic_83xx_enable_tx_intr(struct qlcnic_adapter *adapter,
 				       struct qlcnic_host_tx_ring *tx_ring)
 {
 	writel(0, tx_ring->crb_intr_mask);
 }
 
-inline void qlcnic_83xx_disable_tx_intr(struct qlcnic_adapter *adapter,
+static void qlcnic_83xx_disable_tx_intr(struct qlcnic_adapter *adapter,
 					struct qlcnic_host_tx_ring *tx_ring)
 {
 	writel(1, tx_ring->crb_intr_mask);
@@ -210,8 +209,8 @@ static struct qlcnic_filter *qlcnic_find
 	return NULL;
 }
 
-void qlcnic_add_lb_filter(struct qlcnic_adapter *adapter, struct sk_buff *skb,
-			  int loopback_pkt, u16 vlan_id)
+static void qlcnic_add_lb_filter(struct qlcnic_adapter *adapter,
+				 struct sk_buff *skb, int loopback_pkt, u16 vlan_id)
 {
 	struct ethhdr *phdr = (struct ethhdr *)(skb->data);
 	struct qlcnic_filter *fil, *tmp_fil;
@@ -1015,9 +1014,9 @@ static void qlcnic_handle_fw_message(int
 	}
 }
 
-struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
-				     struct qlcnic_host_rds_ring *ring,
-				     u16 index, u16 cksum)
+static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
+					    struct qlcnic_host_rds_ring *ring,
+					    u16 index, u16 cksum)
 {
 	struct qlcnic_rx_buffer *buffer;
 	struct sk_buff *skb;
@@ -1236,7 +1235,7 @@ qlcnic_process_lro(struct qlcnic_adapter
 	return buffer;
 }
 
-int qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max)
+static int qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max)
 {
 	struct qlcnic_host_rds_ring *rds_ring;
 	struct qlcnic_adapter *adapter = sds_ring->adapter;
@@ -2025,8 +2024,8 @@ void qlcnic_83xx_napi_del(struct qlcnic_
 	qlcnic_free_tx_rings(adapter);
 }
 
-void qlcnic_83xx_process_rcv_diag(struct qlcnic_adapter *adapter,
-				  int ring, u64 sts_data[])
+static void qlcnic_83xx_process_rcv_diag(struct qlcnic_adapter *adapter,
+					 int ring, u64 sts_data[])
 {
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct sk_buff *skb;
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h	2013-12-18 13:25:07.328212885 -0800
@@ -162,7 +162,6 @@ struct qlcnic_host_tx_ring;
 struct qlcnic_hardware_context;
 struct qlcnic_adapter;
 
-int qlcnic_82xx_start_firmware(struct qlcnic_adapter *);
 int qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong, int *);
 int qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *, ulong, u32);
 int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int);
@@ -181,9 +180,6 @@ int qlcnic_82xx_clear_lb_mode(struct qlc
 int qlcnic_82xx_set_lb_mode(struct qlcnic_adapter *, u8);
 void qlcnic_82xx_write_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
 void qlcnic_82xx_read_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
-void qlcnic_82xx_dev_request_reset(struct qlcnic_adapter *, u32);
-int qlcnic_82xx_setup_intr(struct qlcnic_adapter *);
-irqreturn_t qlcnic_82xx_clear_legacy_intr(struct qlcnic_adapter *);
 int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
 			  struct qlcnic_cmd_args *);
 int qlcnic_82xx_mq_intrpt(struct qlcnic_adapter *, int);
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c	2013-12-18 13:25:07.328212885 -0800
@@ -81,6 +81,16 @@ static int qlcnicvf_start_firmware(struc
 static int qlcnic_vlan_rx_add(struct net_device *, __be16, u16);
 static int qlcnic_vlan_rx_del(struct net_device *, __be16, u16);
 
+static int qlcnic_82xx_setup_intr(struct qlcnic_adapter *);
+static void qlcnic_82xx_dev_request_reset(struct qlcnic_adapter *, u32);
+static irqreturn_t qlcnic_82xx_clear_legacy_intr(struct qlcnic_adapter *);
+static pci_ers_result_t qlcnic_82xx_io_slot_reset(struct pci_dev *);
+static int qlcnic_82xx_start_firmware(struct qlcnic_adapter *);
+static void qlcnic_82xx_io_resume(struct pci_dev *);
+static void qlcnic_82xx_set_mac_filter_count(struct qlcnic_adapter *);
+static pci_ers_result_t qlcnic_82xx_io_error_detected(struct pci_dev *,
+						      pci_channel_state_t);
+
 static u32 qlcnic_vlan_tx_check(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -721,7 +731,7 @@ static int qlcnic_enable_msi_legacy(stru
 	return err;
 }
 
-int qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter)
+static int qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter)
 {
 	int num_msix, err = 0;
 
@@ -1484,7 +1494,7 @@ qlcnic_set_mgmt_operations(struct qlcnic
 	return err;
 }
 
-int qlcnic_82xx_start_firmware(struct qlcnic_adapter *adapter)
+static int qlcnic_82xx_start_firmware(struct qlcnic_adapter *adapter)
 {
 	int err;
 
@@ -2035,7 +2045,7 @@ qlcnic_reset_context(struct qlcnic_adapt
 	return err;
 }
 
-void qlcnic_82xx_set_mac_filter_count(struct qlcnic_adapter *adapter)
+static void qlcnic_82xx_set_mac_filter_count(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u16 act_pci_fn = ahw->total_nic_func;
@@ -2791,7 +2801,7 @@ static struct net_device_stats *qlcnic_g
 	return stats;
 }
 
-irqreturn_t qlcnic_82xx_clear_legacy_intr(struct qlcnic_adapter *adapter)
+static irqreturn_t qlcnic_82xx_clear_legacy_intr(struct qlcnic_adapter *adapter)
 {
 	u32 status;
 
@@ -3579,8 +3589,8 @@ static int qlcnic_attach_func(struct pci
 	return err;
 }
 
-pci_ers_result_t qlcnic_82xx_io_error_detected(struct pci_dev *pdev,
-					       pci_channel_state_t state)
+static pci_ers_result_t qlcnic_82xx_io_error_detected(struct pci_dev *pdev,
+						      pci_channel_state_t state)
 {
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h	2013-12-18 13:28:21.321440876 -0800
@@ -188,7 +188,6 @@ void qlcnic_sriov_vf_register_map(struct
 int qlcnic_sriov_vf_init(struct qlcnic_adapter *, int);
 void qlcnic_sriov_vf_set_ops(struct qlcnic_adapter *);
 int qlcnic_sriov_func_to_index(struct qlcnic_adapter *, u8);
-int qlcnic_sriov_channel_cfg_cmd(struct qlcnic_adapter *, u8);
 void qlcnic_sriov_handle_bc_event(struct qlcnic_adapter *, u32);
 int qlcnic_sriov_cfg_bc_intr(struct qlcnic_adapter *, u8);
 void qlcnic_sriov_cleanup_async_list(struct qlcnic_back_channel *);
@@ -198,8 +197,6 @@ int __qlcnic_sriov_add_act_list(struct q
 int qlcnic_sriov_get_vf_vport_info(struct qlcnic_adapter *,
 				   struct qlcnic_info *, u16);
 int qlcnic_sriov_cfg_vf_guest_vlan(struct qlcnic_adapter *, u16, u8);
-int qlcnic_sriov_vf_shutdown(struct pci_dev *);
-int qlcnic_sriov_vf_resume(struct qlcnic_adapter *);
 void qlcnic_sriov_free_vlans(struct qlcnic_adapter *);
 void qlcnic_sriov_alloc_vlans(struct qlcnic_adapter *);
 bool qlcnic_sriov_check_any_vlan(struct qlcnic_vf_info *);
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c	2013-12-18 13:24:47.384498168 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c	2013-12-18 13:25:07.332212829 -0800
@@ -35,7 +35,10 @@ static void qlcnic_sriov_vf_cancel_fw_wo
 static void qlcnic_sriov_cleanup_transaction(struct qlcnic_bc_trans *);
 static int qlcnic_sriov_issue_cmd(struct qlcnic_adapter *,
 				  struct qlcnic_cmd_args *);
+static int qlcnic_sriov_channel_cfg_cmd(struct qlcnic_adapter *, u8);
 static void qlcnic_sriov_process_bc_cmd(struct work_struct *);
+static int qlcnic_sriov_vf_shutdown(struct pci_dev *);
+static int qlcnic_sriov_vf_resume(struct qlcnic_adapter *);
 
 static struct qlcnic_hardware_ops qlcnic_sriov_vf_hw_ops = {
 	.read_crb			= qlcnic_83xx_read_crb,
@@ -1426,7 +1429,7 @@ cleanup_transaction:
 	return rsp;
 }
 
-int qlcnic_sriov_channel_cfg_cmd(struct qlcnic_adapter *adapter, u8 cmd_op)
+static int qlcnic_sriov_channel_cfg_cmd(struct qlcnic_adapter *adapter, u8 cmd_op)
 {
 	struct qlcnic_cmd_args cmd;
 	struct qlcnic_vf_info *vf = &adapter->ahw->sriov->vf_info[0];
@@ -2039,7 +2042,7 @@ static void qlcnic_sriov_vf_free_mac_lis
 }
 
 
-int qlcnic_sriov_vf_shutdown(struct pci_dev *pdev)
+static int qlcnic_sriov_vf_shutdown(struct pci_dev *pdev)
 {
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
@@ -2063,7 +2066,7 @@ int qlcnic_sriov_vf_shutdown(struct pci_
 	return 0;
 }
 
-int qlcnic_sriov_vf_resume(struct qlcnic_adapter *adapter)
+static int qlcnic_sriov_vf_resume(struct qlcnic_adapter *adapter)
 {
 	struct qlc_83xx_idc *idc = &adapter->ahw->idc;
 	struct net_device *netdev = adapter->netdev;
