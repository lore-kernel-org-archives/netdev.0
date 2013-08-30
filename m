From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/4] i40e: Whitespace cleaning
Date: Fri, 30 Aug 2013 16:06:07 -0700
Message-ID: <c5745ecd34424dce1f2ba62e20d1ff9cdc203d58.1377903831.git.joe@perches.com>
References: <cover.1377903831.git.joe@perches.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1377903831.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mostly done via:
	$ checkpatch --strict --fix -f drivers/net/ethernet/intel/i40e/*.[ch]

Removed externs from .h function prototypes
Aligned multiline statements to open parenthesis
Removed some blank lines before and after braces
Added a set of braces
Used sizeof(*foo)
Moved logical continuations from start to end of line

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             | 140 +++---
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  20 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 533 ++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  19 +-
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |  24 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 128 +++--
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_sysfs.c       |  12 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  15 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  13 +-
 11 files changed, 448 insertions(+), 469 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 8cd94b0..6de5e63 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -95,16 +95,16 @@
 #define prefetch(X)
 #endif
 
-#define I40E_RX_DESC(R, i)			\
-	((ring_is_16byte_desc_enabled(R))	\
-		? (union i40e_32byte_rx_desc *)	\
-			(&(((union i40e_16byte_rx_desc *)((R)->desc))[i])) \
-		: (&(((union i40e_32byte_rx_desc *)((R)->desc))[i])))
-#define I40E_TX_DESC(R, i)			\
+#define I40E_RX_DESC(R, i)						\
+	(((ring_is_16byte_desc_enabled(R))				\
+	  ? (union i40e_32byte_rx_desc *)				\
+	    (&(((union i40e_16byte_rx_desc *)((R)->desc))[i]))		\
+	  : (&(((union i40e_32byte_rx_desc *)((R)->desc))[i]))))
+#define I40E_TX_DESC(R, i)						\
 	(&(((struct i40e_tx_desc *)((R)->desc))[i]))
-#define I40E_TX_CTXTDESC(R, i)			\
+#define I40E_TX_CTXTDESC(R, i)						\
 	(&(((struct i40e_tx_context_desc *)((R)->desc))[i]))
-#define I40E_TX_FDIRDESC(R, i)			\
+#define I40E_TX_FDIRDESC(R, i)						\
 	(&(((struct i40e_filter_program_desc *)((R)->desc))[i]))
 
 /* default to trying for four seconds */
@@ -491,80 +491,76 @@ static inline bool i40e_rx_is_programming_status(u64 qw)
 }
 
 /* needed by i40e_ethtool.c */
-extern int i40e_up(struct i40e_vsi *vsi);
-extern void i40e_down(struct i40e_vsi *vsi);
+int i40e_up(struct i40e_vsi *vsi);
+void i40e_down(struct i40e_vsi *vsi);
 extern const char i40e_driver_name[];
 extern const char i40e_driver_version_str[];
-extern void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags);
-extern void i40e_update_stats(struct i40e_vsi *vsi);
-extern void i40e_update_eth_stats(struct i40e_vsi *vsi);
-extern struct rtnl_link_stats64 *i40e_get_vsi_stats_struct(struct i40e_vsi *vsi);
-extern s32 i40e_fetch_switch_configuration(struct i40e_pf *pf,
-					   bool printconfig);
+void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags);
+void i40e_update_stats(struct i40e_vsi *vsi);
+void i40e_update_eth_stats(struct i40e_vsi *vsi);
+struct rtnl_link_stats64 *i40e_get_vsi_stats_struct(struct i40e_vsi *vsi);
+s32 i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig);
 
 /* needed by i40e_main.c */
-extern void i40e_add_fdir_filter(struct i40e_fdir_data fdir_data,
-				  struct i40e_ring *tx_ring);
-extern void i40e_add_remove_filter(struct i40e_fdir_data fdir_data,
-				   struct i40e_ring *tx_ring);
-extern void i40e_update_fdir_filter(struct i40e_fdir_data fdir_data,
-				    struct i40e_ring *tx_ring);
-extern i40e_status i40e_program_fdir_filter(struct i40e_fdir_data *fdir_data,
-					    struct i40e_pf *pf, bool add);
-
-extern void i40e_set_ethtool_ops(struct net_device *netdev);
-extern struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
-					       u8 *macaddr, s16 vlan,
-					       bool is_vf, bool is_netdev);
-extern void i40e_del_filter(struct i40e_vsi *vsi,
-			    u8 *macaddr, s16 vlan,
-			    bool is_vf, bool is_netdev);
-extern i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi);
-extern i40e_status __i40e_sync_vsi_filters_locked(struct i40e_vsi *);
-extern struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
-				       u16 uplink, u32 param1);
-extern s32 i40e_vsi_release(struct i40e_vsi *vsi);
-extern struct i40e_vsi *i40e_vsi_lookup(struct i40e_pf *pf,
-					enum i40e_vsi_type type,
-					struct i40e_vsi *start_vsi);
-extern struct i40e_veb *i40e_veb_setup(struct i40e_pf *pf, u16 flags,
-				       u16 uplink_seid, u16 downlink_seid,
-				       u8 enabled_tc);
-extern s32 i40e_veb_release(struct i40e_veb *veb);
-
-extern i40e_status i40e_sys_add_vsi(struct i40e_vsi *vsi);
-extern void i40e_sys_del_vsi(struct i40e_vsi *vsi);
-extern i40e_status i40e_sys_add_veb(struct i40e_veb *veb);
-extern void i40e_sys_del_veb(struct i40e_veb *veb);
-extern i40e_status i40e_sys_init(struct i40e_pf *pf);
-extern void i40e_sys_exit(struct i40e_pf *pf);
-extern i40e_status i40e_vsi_add_pvid(struct i40e_vsi *vsi, u16 vid);
-extern i40e_status i40e_vsi_remove_pvid(struct i40e_vsi *vsi);
-extern void i40e_vsi_reset_stats(struct i40e_vsi *vsi);
-extern void i40e_pf_reset_stats(struct i40e_pf *pf);
+void i40e_add_fdir_filter(struct i40e_fdir_data fdir_data,
+			  struct i40e_ring *tx_ring);
+void i40e_add_remove_filter(struct i40e_fdir_data fdir_data,
+			    struct i40e_ring *tx_ring);
+void i40e_update_fdir_filter(struct i40e_fdir_data fdir_data,
+			     struct i40e_ring *tx_ring);
+i40e_status i40e_program_fdir_filter(struct i40e_fdir_data *fdir_data,
+				     struct i40e_pf *pf, bool add);
+
+void i40e_set_ethtool_ops(struct net_device *netdev);
+struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
+					u8 *macaddr, s16 vlan,
+					bool is_vf, bool is_netdev);
+void i40e_del_filter(struct i40e_vsi *vsi, u8 *macaddr, s16 vlan,
+		     bool is_vf, bool is_netdev);
+i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi);
+i40e_status __i40e_sync_vsi_filters_locked(struct i40e_vsi *);
+struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
+				u16 uplink, u32 param1);
+s32 i40e_vsi_release(struct i40e_vsi *vsi);
+struct i40e_vsi *i40e_vsi_lookup(struct i40e_pf *pf,
+				 enum i40e_vsi_type type,
+				 struct i40e_vsi *start_vsi);
+struct i40e_veb *i40e_veb_setup(struct i40e_pf *pf, u16 flags,
+				u16 uplink_seid, u16 downlink_seid,
+				u8 enabled_tc);
+s32 i40e_veb_release(struct i40e_veb *veb);
+
+i40e_status i40e_sys_add_vsi(struct i40e_vsi *vsi);
+void i40e_sys_del_vsi(struct i40e_vsi *vsi);
+i40e_status i40e_sys_add_veb(struct i40e_veb *veb);
+void i40e_sys_del_veb(struct i40e_veb *veb);
+i40e_status i40e_sys_init(struct i40e_pf *pf);
+void i40e_sys_exit(struct i40e_pf *pf);
+i40e_status i40e_vsi_add_pvid(struct i40e_vsi *vsi, u16 vid);
+i40e_status i40e_vsi_remove_pvid(struct i40e_vsi *vsi);
+void i40e_vsi_reset_stats(struct i40e_vsi *vsi);
+void i40e_pf_reset_stats(struct i40e_pf *pf);
 #ifdef CONFIG_DEBUG_FS
-extern void i40e_dbg_pf_init(struct i40e_pf *pf);
-extern void i40e_dbg_pf_exit(struct i40e_pf *pf);
-extern void i40e_dbg_init(void);
-extern void i40e_dbg_exit(void);
+void i40e_dbg_pf_init(struct i40e_pf *pf);
+void i40e_dbg_pf_exit(struct i40e_pf *pf);
+void i40e_dbg_init(void);
+void i40e_dbg_exit(void);
 #else
 static inline void i40e_dbg_pf_init(struct i40e_pf *pf) {}
 static inline void i40e_dbg_pf_exit(struct i40e_pf *pf) {}
 static inline void i40e_dbg_init(void) {}
 static inline void i40e_dbg_exit(void) {}
 #endif /* CONFIG_DEBUG_FS*/
-extern void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector);
-extern int i40e_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
-extern void i40e_vlan_stripping_disable(struct i40e_vsi *vsi);
-extern int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid);
-extern int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid);
-extern i40e_status i40e_put_mac_in_vlan(struct i40e_vsi *vsi,
-						  u8 *macaddr,
-						  bool is_vf, bool is_netdev);
-extern bool i40e_is_vsi_in_vlan(struct i40e_vsi *vsi);
-extern struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi,
-					 u8 *macaddr,
-					 bool is_vf, bool is_netdev);
-extern void i40e_vlan_stripping_enable(struct i40e_vsi *vsi);
+void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector);
+int i40e_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
+void i40e_vlan_stripping_disable(struct i40e_vsi *vsi);
+int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid);
+int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid);
+i40e_status i40e_put_mac_in_vlan(struct i40e_vsi *vsi, u8 *macaddr,
+				 bool is_vf, bool is_netdev);
+bool i40e_is_vsi_in_vlan(struct i40e_vsi *vsi);
+struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi, u8 *macaddr,
+				      bool is_vf, bool is_netdev);
+void i40e_vlan_stripping_enable(struct i40e_vsi *vsi);
 
 #endif /* _I40E_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 0d7759e..25dc629 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -68,7 +68,7 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 	}
 
 	hw_dbg(hw, "i40e_set_mac_type found mac: %d, returns: %d\n",
-		  hw->mac.type, status);
+	       hw->mac.type, status);
 	return status;
 }
 
@@ -564,7 +564,8 @@ aq_add_vsi_exit:
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
-				u16 seid, bool set, struct i40e_asq_cmd_details *cmd_details)
+						u16 seid, bool set,
+						struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_set_vsi_promiscuous_modes *cmd =
@@ -573,7 +574,7 @@ i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
 	u16 flags = 0;
 
 	i40e_fill_default_direct_cmd_desc(&desc,
-					i40e_aqc_opc_set_vsi_promiscuous_modes);
+					  i40e_aqc_opc_set_vsi_promiscuous_modes);
 
 	if (set)
 		flags |= I40E_AQC_SET_VSI_PROMISC_UNICAST;
@@ -596,7 +597,8 @@ i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_set_vsi_multicast_promiscuous(struct i40e_hw *hw,
-				u16 seid, bool set, struct i40e_asq_cmd_details *cmd_details)
+						  u16 seid, bool set,
+						  struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_set_vsi_promiscuous_modes *cmd =
@@ -605,7 +607,7 @@ i40e_status i40e_aq_set_vsi_multicast_promiscuous(struct i40e_hw *hw,
 	u16 flags = 0;
 
 	i40e_fill_default_direct_cmd_desc(&desc,
-					i40e_aqc_opc_set_vsi_promiscuous_modes);
+					  i40e_aqc_opc_set_vsi_promiscuous_modes);
 
 	if (set)
 		flags |= I40E_AQC_SET_VSI_PROMISC_MULTICAST;
@@ -639,7 +641,7 @@ i40e_status i40e_aq_set_vsi_broadcast(struct i40e_hw *hw,
 	i40e_status status;
 
 	i40e_fill_default_direct_cmd_desc(&desc,
-					i40e_aqc_opc_set_vsi_promiscuous_modes);
+					  i40e_aqc_opc_set_vsi_promiscuous_modes);
 
 	if (set_filter)
 		cmd->promiscuous_flags
@@ -1191,7 +1193,7 @@ i40e_status i40e_aq_set_hmc_resource_profile(struct i40e_hw *hw,
 	i40e_status status;
 
 	i40e_fill_default_direct_cmd_desc(&desc,
-					i40e_aqc_opc_set_hmc_resource_profile);
+					  i40e_aqc_opc_set_hmc_resource_profile);
 
 	cmd->pm_profile = (u8)profile;
 	cmd->pe_vf_enabled = pe_vf_enabled_count;
@@ -1366,7 +1368,7 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 	u32 i = 0;
 	u16 id;
 
-	cap = (struct i40e_aqc_list_capabilities_element_resp *) buff;
+	cap = (struct i40e_aqc_list_capabilities_element_resp *)buff;
 
 	if (list_type_opc == i40e_aqc_opc_list_dev_capabilities)
 		p = (struct i40e_hw_capabilities *)&hw->dev_caps;
@@ -1522,7 +1524,7 @@ i40e_status i40e_aq_discover_capabilities(struct i40e_hw *hw,
 	i40e_status status = I40E_SUCCESS;
 
 	if (list_type_opc != i40e_aqc_opc_list_func_capabilities &&
-		list_type_opc != i40e_aqc_opc_list_dev_capabilities) {
+	    list_type_opc != i40e_aqc_opc_list_dev_capabilities) {
 		status = I40E_ERR_PARAM;
 		goto exit;
 	}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 0b2e9f7..e61ed67 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -243,7 +243,6 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 		buflen += sizeof(struct i40e_mac_filter) * filter_count;
 
 		if (i40e_dbg_prep_dump_buf(pf, buflen)) {
-
 			p = i40e_dbg_dump_buf;
 			seid_found = true;
 
@@ -387,319 +386,319 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 	vsi = i40e_dbg_find_vsi(pf, seid);
 	if (!vsi) {
 		dev_info(&pf->pdev->dev,
-			"%s: dump %d: seid not found\n", __func__, seid);
+			 "%s: dump %d: seid not found\n", __func__, seid);
 		return;
 	}
 	dev_info(&pf->pdev->dev,
-		"%s: vsi seid %d\n", __func__, seid);
+		 "%s: vsi seid %d\n", __func__, seid);
 	if (vsi->netdev)
 		dev_info(&pf->pdev->dev,
-			"    netdev: name = %s\n",
+			 "    netdev: name = %s\n",
 			vsi->netdev->name);
 	if (vsi->active_vlans)
 		dev_info(&pf->pdev->dev,
-			"    vlgrp: & = %p\n", vsi->active_vlans);
+			 "    vlgrp: & = %p\n", vsi->active_vlans);
 	dev_info(&pf->pdev->dev,
-		"    netdev_registered = %i, current_netdev_flags = 0x%04x, state = %li flags = 0x%08lx\n",
-		vsi->netdev_registered,
-		vsi->current_netdev_flags, vsi->state, vsi->flags);
+		 "    netdev_registered = %i, current_netdev_flags = 0x%04x, state = %li flags = 0x%08lx\n",
+		 vsi->netdev_registered,
+		 vsi->current_netdev_flags, vsi->state, vsi->flags);
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
 		dev_info(&pf->pdev->dev,
-			"    mac_filter_list: %pM vid=%d, is_netdev=%d is_vf=%d counter=%d\n",
-			f->macaddr, f->vlan, f->is_netdev, f->is_vf,
-			f->counter);
+			 "    mac_filter_list: %pM vid=%d, is_netdev=%d is_vf=%d counter=%d\n",
+			 f->macaddr, f->vlan, f->is_netdev, f->is_vf,
+			 f->counter);
 	}
 	nstat = i40e_get_vsi_stats_struct(vsi);
 	dev_info(&pf->pdev->dev,
-		"    net_stats: rx_packets = %lu, rx_bytes = %lu, rx_errors = %lu, rx_dropped = %lu\n",
-		(long unsigned int)nstat->rx_packets,
-		(long unsigned int)nstat->rx_bytes,
-		(long unsigned int)nstat->rx_errors,
-		(long unsigned int)nstat->rx_dropped);
+		 "    net_stats: rx_packets = %lu, rx_bytes = %lu, rx_errors = %lu, rx_dropped = %lu\n",
+		 (long unsigned int)nstat->rx_packets,
+		 (long unsigned int)nstat->rx_bytes,
+		 (long unsigned int)nstat->rx_errors,
+		 (long unsigned int)nstat->rx_dropped);
 	dev_info(&pf->pdev->dev,
-		"    net_stats: tx_packets = %lu, tx_bytes = %lu, tx_errors = %lu, tx_dropped = %lu\n",
-		(long unsigned int)nstat->tx_packets,
-		(long unsigned int)nstat->tx_bytes,
-		(long unsigned int)nstat->tx_errors,
-		(long unsigned int)nstat->tx_dropped);
+		 "    net_stats: tx_packets = %lu, tx_bytes = %lu, tx_errors = %lu, tx_dropped = %lu\n",
+		 (long unsigned int)nstat->tx_packets,
+		 (long unsigned int)nstat->tx_bytes,
+		 (long unsigned int)nstat->tx_errors,
+		 (long unsigned int)nstat->tx_dropped);
 	dev_info(&pf->pdev->dev,
-		"    net_stats: multicast = %lu, collisions = %lu\n",
-		(long unsigned int)nstat->multicast,
-		(long unsigned int)nstat->collisions);
+		 "    net_stats: multicast = %lu, collisions = %lu\n",
+		 (long unsigned int)nstat->multicast,
+		 (long unsigned int)nstat->collisions);
 	dev_info(&pf->pdev->dev,
-		"    net_stats: rx_length_errors = %lu, rx_over_errors = %lu, rx_crc_errors = %lu\n",
-		(long unsigned int)nstat->rx_length_errors,
-		(long unsigned int)nstat->rx_over_errors,
-		(long unsigned int)nstat->rx_crc_errors);
+		 "    net_stats: rx_length_errors = %lu, rx_over_errors = %lu, rx_crc_errors = %lu\n",
+		 (long unsigned int)nstat->rx_length_errors,
+		 (long unsigned int)nstat->rx_over_errors,
+		 (long unsigned int)nstat->rx_crc_errors);
 	dev_info(&pf->pdev->dev,
-		"    net_stats: rx_frame_errors = %lu, rx_fifo_errors = %lu, rx_missed_errors = %lu\n",
-		(long unsigned int)nstat->rx_frame_errors,
-		(long unsigned int)nstat->rx_fifo_errors,
-		(long unsigned int)nstat->rx_missed_errors);
+		 "    net_stats: rx_frame_errors = %lu, rx_fifo_errors = %lu, rx_missed_errors = %lu\n",
+		 (long unsigned int)nstat->rx_frame_errors,
+		 (long unsigned int)nstat->rx_fifo_errors,
+		 (long unsigned int)nstat->rx_missed_errors);
 	dev_info(&pf->pdev->dev,
-		"    net_stats: tx_aborted_errors = %lu, tx_carrier_errors = %lu, tx_fifo_errors = %lu\n",
-		(long unsigned int)nstat->tx_aborted_errors,
-		(long unsigned int)nstat->tx_carrier_errors,
-		(long unsigned int)nstat->tx_fifo_errors);
+		 "    net_stats: tx_aborted_errors = %lu, tx_carrier_errors = %lu, tx_fifo_errors = %lu\n",
+		 (long unsigned int)nstat->tx_aborted_errors,
+		 (long unsigned int)nstat->tx_carrier_errors,
+		 (long unsigned int)nstat->tx_fifo_errors);
 	dev_info(&pf->pdev->dev,
-		"    net_stats: tx_heartbeat_errors = %lu, tx_window_errors = %lu\n",
-		(long unsigned int)nstat->tx_heartbeat_errors,
-		(long unsigned int)nstat->tx_window_errors);
+		 "    net_stats: tx_heartbeat_errors = %lu, tx_window_errors = %lu\n",
+		 (long unsigned int)nstat->tx_heartbeat_errors,
+		 (long unsigned int)nstat->tx_window_errors);
 	dev_info(&pf->pdev->dev,
-		"    net_stats: rx_compressed = %lu, tx_compressed = %lu\n",
-		(long unsigned int)nstat->rx_compressed,
-		(long unsigned int)nstat->tx_compressed);
+		 "    net_stats: rx_compressed = %lu, tx_compressed = %lu\n",
+		 (long unsigned int)nstat->rx_compressed,
+		 (long unsigned int)nstat->tx_compressed);
 	dev_info(&pf->pdev->dev,
-		"    net_stats_offsets: rx_packets = %lu, rx_bytes = %lu, rx_errors = %lu, rx_dropped = %lu\n",
-		(long unsigned int)vsi->net_stats_offsets.rx_packets,
-		(long unsigned int)vsi->net_stats_offsets.rx_bytes,
-		(long unsigned int)vsi->net_stats_offsets.rx_errors,
-		(long unsigned int)vsi->net_stats_offsets.rx_dropped);
+		 "    net_stats_offsets: rx_packets = %lu, rx_bytes = %lu, rx_errors = %lu, rx_dropped = %lu\n",
+		 (long unsigned int)vsi->net_stats_offsets.rx_packets,
+		 (long unsigned int)vsi->net_stats_offsets.rx_bytes,
+		 (long unsigned int)vsi->net_stats_offsets.rx_errors,
+		 (long unsigned int)vsi->net_stats_offsets.rx_dropped);
 	dev_info(&pf->pdev->dev,
-		"    net_stats_offsets: tx_packets = %lu, tx_bytes = %lu, tx_errors = %lu, tx_dropped = %lu\n",
-		(long unsigned int)vsi->net_stats_offsets.tx_packets,
-		(long unsigned int)vsi->net_stats_offsets.tx_bytes,
-		(long unsigned int)vsi->net_stats_offsets.tx_errors,
-		(long unsigned int)vsi->net_stats_offsets.tx_dropped);
+		 "    net_stats_offsets: tx_packets = %lu, tx_bytes = %lu, tx_errors = %lu, tx_dropped = %lu\n",
+		 (long unsigned int)vsi->net_stats_offsets.tx_packets,
+		 (long unsigned int)vsi->net_stats_offsets.tx_bytes,
+		 (long unsigned int)vsi->net_stats_offsets.tx_errors,
+		 (long unsigned int)vsi->net_stats_offsets.tx_dropped);
 	dev_info(&pf->pdev->dev,
-		"    net_stats_offsets: multicast = %lu, collisions = %lu\n",
-		(long unsigned int)vsi->net_stats_offsets.multicast,
-		(long unsigned int)vsi->net_stats_offsets.collisions);
+		 "    net_stats_offsets: multicast = %lu, collisions = %lu\n",
+		 (long unsigned int)vsi->net_stats_offsets.multicast,
+		 (long unsigned int)vsi->net_stats_offsets.collisions);
 	dev_info(&pf->pdev->dev,
-		"    net_stats_offsets: rx_length_errors = %lu, rx_over_errors = %lu, rx_crc_errors = %lu\n",
-		(long unsigned int)vsi->net_stats_offsets.rx_length_errors,
-		(long unsigned int)vsi->net_stats_offsets.rx_over_errors,
-		(long unsigned int)vsi->net_stats_offsets.rx_crc_errors);
+		 "    net_stats_offsets: rx_length_errors = %lu, rx_over_errors = %lu, rx_crc_errors = %lu\n",
+		 (long unsigned int)vsi->net_stats_offsets.rx_length_errors,
+		 (long unsigned int)vsi->net_stats_offsets.rx_over_errors,
+		 (long unsigned int)vsi->net_stats_offsets.rx_crc_errors);
 	dev_info(&pf->pdev->dev,
-		"    net_stats_offsets: rx_frame_errors = %lu, rx_fifo_errors = %lu, rx_missed_errors = %lu\n",
-		(long unsigned int)vsi->net_stats_offsets.rx_frame_errors,
-		(long unsigned int)vsi->net_stats_offsets.rx_fifo_errors,
-		(long unsigned int)vsi->net_stats_offsets.rx_missed_errors);
+		 "    net_stats_offsets: rx_frame_errors = %lu, rx_fifo_errors = %lu, rx_missed_errors = %lu\n",
+		 (long unsigned int)vsi->net_stats_offsets.rx_frame_errors,
+		 (long unsigned int)vsi->net_stats_offsets.rx_fifo_errors,
+		 (long unsigned int)vsi->net_stats_offsets.rx_missed_errors);
 	dev_info(&pf->pdev->dev,
-		"    net_stats_offsets: tx_aborted_errors = %lu, tx_carrier_errors = %lu, tx_fifo_errors = %lu\n",
-		(long unsigned int)vsi->net_stats_offsets.tx_aborted_errors,
-		(long unsigned int)vsi->net_stats_offsets.tx_carrier_errors,
-		(long unsigned int)vsi->net_stats_offsets.tx_fifo_errors);
+		 "    net_stats_offsets: tx_aborted_errors = %lu, tx_carrier_errors = %lu, tx_fifo_errors = %lu\n",
+		 (long unsigned int)vsi->net_stats_offsets.tx_aborted_errors,
+		 (long unsigned int)vsi->net_stats_offsets.tx_carrier_errors,
+		 (long unsigned int)vsi->net_stats_offsets.tx_fifo_errors);
 	dev_info(&pf->pdev->dev,
-		"    net_stats_offsets: tx_heartbeat_errors = %lu, tx_window_errors = %lu\n",
-		(long unsigned int)vsi->net_stats_offsets.tx_heartbeat_errors,
-		(long unsigned int)vsi->net_stats_offsets.tx_window_errors);
+		 "    net_stats_offsets: tx_heartbeat_errors = %lu, tx_window_errors = %lu\n",
+		 (long unsigned int)vsi->net_stats_offsets.tx_heartbeat_errors,
+		 (long unsigned int)vsi->net_stats_offsets.tx_window_errors);
 	dev_info(&pf->pdev->dev,
-		"    net_stats_offsets: rx_compressed = %lu, tx_compressed = %lu\n",
-		(long unsigned int)vsi->net_stats_offsets.rx_compressed,
-		(long unsigned int)vsi->net_stats_offsets.tx_compressed);
+		 "    net_stats_offsets: rx_compressed = %lu, tx_compressed = %lu\n",
+		 (long unsigned int)vsi->net_stats_offsets.rx_compressed,
+		 (long unsigned int)vsi->net_stats_offsets.tx_compressed);
 	dev_info(&pf->pdev->dev,
-		"    tx_restart = %d, tx_busy = %d, rx_buf_failed = %d, rx_page_failed = %d\n",
-		vsi->tx_restart, vsi->tx_busy,
-		vsi->rx_buf_failed, vsi->rx_page_failed);
+		 "    tx_restart = %d, tx_busy = %d, rx_buf_failed = %d, rx_page_failed = %d\n",
+		 vsi->tx_restart, vsi->tx_busy,
+		 vsi->rx_buf_failed, vsi->rx_page_failed);
 	if (vsi->rx_rings) {
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
 			dev_info(&pf->pdev->dev,
-				"    rx_rings[%i]: desc = %p\n",
-				i, vsi->rx_rings[i].desc);
-			dev_info(&pf->pdev->dev,
-				"    rx_rings[%i]: dev = %p, netdev = %p, rx_bi = %p\n",
-				i, vsi->rx_rings[i].dev,
-				vsi->rx_rings[i].netdev,
-				vsi->rx_rings[i].rx_bi);
-			dev_info(&pf->pdev->dev,
-				"    rx_rings[%i]: state = %li, queue_index = %d, reg_idx = %d\n",
-				i, vsi->rx_rings[i].state,
-				vsi->rx_rings[i].queue_index,
-				vsi->rx_rings[i].reg_idx);
-			dev_info(&pf->pdev->dev,
-				"    rx_rings[%i]: rx_hdr_len = %d, rx_buf_len = %d, dtype = %d\n",
-				i, vsi->rx_rings[i].rx_hdr_len,
-				vsi->rx_rings[i].rx_buf_len,
-				vsi->rx_rings[i].dtype);
-			dev_info(&pf->pdev->dev,
-				"    rx_rings[%i]: hsplit = %d, next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
-				i, vsi->rx_rings[i].hsplit,
-				vsi->rx_rings[i].next_to_use,
-				vsi->rx_rings[i].next_to_clean,
-				vsi->rx_rings[i].ring_active);
-			dev_info(&pf->pdev->dev,
-				"    rx_rings[%i]: rx_stats: packets = %lld, bytes = %lld, non_eop_descs = %lld\n",
-				i, vsi->rx_rings[i].rx_stats.packets,
-				vsi->rx_rings[i].rx_stats.bytes,
-				vsi->rx_rings[i].rx_stats.non_eop_descs);
-			dev_info(&pf->pdev->dev,
-				"    rx_rings[%i]: rx_stats: alloc_rx_page_failed = %lld, alloc_rx_buff_failed = %lld\n",
-				i,
-				vsi->rx_rings[i].rx_stats.alloc_rx_page_failed,
-				vsi->rx_rings[i].rx_stats.alloc_rx_buff_failed);
-			dev_info(&pf->pdev->dev,
-				"    rx_rings[%i]: size = %i, dma = 0x%08lx\n",
-				i, vsi->rx_rings[i].size,
-				(long unsigned int)vsi->rx_rings[i].dma);
-			dev_info(&pf->pdev->dev,
-				"    rx_rings[%i]: vsi = %p, q_vector = %p\n",
-				i, vsi->rx_rings[i].vsi,
-				vsi->rx_rings[i].q_vector);
+				 "    rx_rings[%i]: desc = %p\n",
+				 i, vsi->rx_rings[i].desc);
+			dev_info(&pf->pdev->dev,
+				 "    rx_rings[%i]: dev = %p, netdev = %p, rx_bi = %p\n",
+				 i, vsi->rx_rings[i].dev,
+				 vsi->rx_rings[i].netdev,
+				 vsi->rx_rings[i].rx_bi);
+			dev_info(&pf->pdev->dev,
+				 "    rx_rings[%i]: state = %li, queue_index = %d, reg_idx = %d\n",
+				 i, vsi->rx_rings[i].state,
+				 vsi->rx_rings[i].queue_index,
+				 vsi->rx_rings[i].reg_idx);
+			dev_info(&pf->pdev->dev,
+				 "    rx_rings[%i]: rx_hdr_len = %d, rx_buf_len = %d, dtype = %d\n",
+				 i, vsi->rx_rings[i].rx_hdr_len,
+				 vsi->rx_rings[i].rx_buf_len,
+				 vsi->rx_rings[i].dtype);
+			dev_info(&pf->pdev->dev,
+				 "    rx_rings[%i]: hsplit = %d, next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
+				 i, vsi->rx_rings[i].hsplit,
+				 vsi->rx_rings[i].next_to_use,
+				 vsi->rx_rings[i].next_to_clean,
+				 vsi->rx_rings[i].ring_active);
+			dev_info(&pf->pdev->dev,
+				 "    rx_rings[%i]: rx_stats: packets = %lld, bytes = %lld, non_eop_descs = %lld\n",
+				 i, vsi->rx_rings[i].rx_stats.packets,
+				 vsi->rx_rings[i].rx_stats.bytes,
+				 vsi->rx_rings[i].rx_stats.non_eop_descs);
+			dev_info(&pf->pdev->dev,
+				 "    rx_rings[%i]: rx_stats: alloc_rx_page_failed = %lld, alloc_rx_buff_failed = %lld\n",
+				 i,
+				 vsi->rx_rings[i].rx_stats.alloc_rx_page_failed,
+				 vsi->rx_rings[i].rx_stats.alloc_rx_buff_failed);
+			dev_info(&pf->pdev->dev,
+				 "    rx_rings[%i]: size = %i, dma = 0x%08lx\n",
+				 i, vsi->rx_rings[i].size,
+				 (long unsigned int)vsi->rx_rings[i].dma);
+			dev_info(&pf->pdev->dev,
+				 "    rx_rings[%i]: vsi = %p, q_vector = %p\n",
+				 i, vsi->rx_rings[i].vsi,
+				 vsi->rx_rings[i].q_vector);
 		}
 	}
 	if (vsi->tx_rings) {
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
 			dev_info(&pf->pdev->dev,
-				"    tx_rings[%i]: desc = %p\n",
-				i, vsi->tx_rings[i].desc);
-			dev_info(&pf->pdev->dev,
-				"    tx_rings[%i]: dev = %p, netdev = %p, tx_bi = %p\n",
-				i, vsi->tx_rings[i].dev,
-				vsi->tx_rings[i].netdev,
-				vsi->tx_rings[i].tx_bi);
-			dev_info(&pf->pdev->dev,
-				"    tx_rings[%i]: state = %li, queue_index = %d, reg_idx = %d\n",
-				i, vsi->tx_rings[i].state,
-				vsi->tx_rings[i].queue_index,
-				vsi->tx_rings[i].reg_idx);
-			dev_info(&pf->pdev->dev,
-				"    tx_rings[%i]: dtype = %d\n",
-				i, vsi->tx_rings[i].dtype);
-			dev_info(&pf->pdev->dev,
-				"    tx_rings[%i]: hsplit = %d, next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
-				i, vsi->tx_rings[i].hsplit,
-				vsi->tx_rings[i].next_to_use,
-				vsi->tx_rings[i].next_to_clean,
-				vsi->tx_rings[i].ring_active);
-			dev_info(&pf->pdev->dev,
-				"    tx_rings[%i]: tx_stats: packets = %lld, bytes = %lld, restart_queue = %lld\n",
-				i, vsi->tx_rings[i].tx_stats.packets,
-				vsi->tx_rings[i].tx_stats.bytes,
-				vsi->tx_rings[i].tx_stats.restart_queue);
-			dev_info(&pf->pdev->dev,
-				"    tx_rings[%i]: tx_stats: tx_busy = %lld, completed = %lld, tx_done_old = %lld\n",
-				i,
-				vsi->tx_rings[i].tx_stats.tx_busy,
-				vsi->tx_rings[i].tx_stats.completed,
-				vsi->tx_rings[i].tx_stats.tx_done_old);
-			dev_info(&pf->pdev->dev,
-				"    tx_rings[%i]: size = %i, dma = 0x%08lx\n",
-				i, vsi->tx_rings[i].size,
-				(long unsigned int)vsi->tx_rings[i].dma);
-			dev_info(&pf->pdev->dev,
-				"    tx_rings[%i]: vsi = %p, q_vector = %p\n",
-				i, vsi->tx_rings[i].vsi,
-				vsi->tx_rings[i].q_vector);
-			dev_info(&pf->pdev->dev,
-				"    tx_rings[%i]: DCB tc = %d\n",
-				i, vsi->tx_rings[i].dcb_tc);
+				 "    tx_rings[%i]: desc = %p\n",
+				 i, vsi->tx_rings[i].desc);
+			dev_info(&pf->pdev->dev,
+				 "    tx_rings[%i]: dev = %p, netdev = %p, tx_bi = %p\n",
+				 i, vsi->tx_rings[i].dev,
+				 vsi->tx_rings[i].netdev,
+				 vsi->tx_rings[i].tx_bi);
+			dev_info(&pf->pdev->dev,
+				 "    tx_rings[%i]: state = %li, queue_index = %d, reg_idx = %d\n",
+				 i, vsi->tx_rings[i].state,
+				 vsi->tx_rings[i].queue_index,
+				 vsi->tx_rings[i].reg_idx);
+			dev_info(&pf->pdev->dev,
+				 "    tx_rings[%i]: dtype = %d\n",
+				 i, vsi->tx_rings[i].dtype);
+			dev_info(&pf->pdev->dev,
+				 "    tx_rings[%i]: hsplit = %d, next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
+				 i, vsi->tx_rings[i].hsplit,
+				 vsi->tx_rings[i].next_to_use,
+				 vsi->tx_rings[i].next_to_clean,
+				 vsi->tx_rings[i].ring_active);
+			dev_info(&pf->pdev->dev,
+				 "    tx_rings[%i]: tx_stats: packets = %lld, bytes = %lld, restart_queue = %lld\n",
+				 i, vsi->tx_rings[i].tx_stats.packets,
+				 vsi->tx_rings[i].tx_stats.bytes,
+				 vsi->tx_rings[i].tx_stats.restart_queue);
+			dev_info(&pf->pdev->dev,
+				 "    tx_rings[%i]: tx_stats: tx_busy = %lld, completed = %lld, tx_done_old = %lld\n",
+				 i,
+				 vsi->tx_rings[i].tx_stats.tx_busy,
+				 vsi->tx_rings[i].tx_stats.completed,
+				 vsi->tx_rings[i].tx_stats.tx_done_old);
+			dev_info(&pf->pdev->dev,
+				 "    tx_rings[%i]: size = %i, dma = 0x%08lx\n",
+				 i, vsi->tx_rings[i].size,
+				 (long unsigned int)vsi->tx_rings[i].dma);
+			dev_info(&pf->pdev->dev,
+				 "    tx_rings[%i]: vsi = %p, q_vector = %p\n",
+				 i, vsi->tx_rings[i].vsi,
+				 vsi->tx_rings[i].q_vector);
+			dev_info(&pf->pdev->dev,
+				 "    tx_rings[%i]: DCB tc = %d\n",
+				 i, vsi->tx_rings[i].dcb_tc);
 		}
 	}
 	dev_info(&pf->pdev->dev,
-		"    work_limit = %d, rx_itr_setting = %d (%s), tx_itr_setting = %d (%s)\n",
-		vsi->work_limit, vsi->rx_itr_setting,
-		ITR_IS_DYNAMIC(vsi->rx_itr_setting) ? "dynamic" : "fixed",
-		vsi->tx_itr_setting,
-		ITR_IS_DYNAMIC(vsi->tx_itr_setting) ? "dynamic" : "fixed");
+		 "    work_limit = %d, rx_itr_setting = %d (%s), tx_itr_setting = %d (%s)\n",
+		 vsi->work_limit, vsi->rx_itr_setting,
+		 ITR_IS_DYNAMIC(vsi->rx_itr_setting) ? "dynamic" : "fixed",
+		 vsi->tx_itr_setting,
+		 ITR_IS_DYNAMIC(vsi->tx_itr_setting) ? "dynamic" : "fixed");
 	dev_info(&pf->pdev->dev,
-		"    max_frame = %d, rx_hdr_len = %d, rx_buf_len = %d dtype = %d\n",
-		vsi->max_frame, vsi->rx_hdr_len, vsi->rx_buf_len, vsi->dtype);
+		 "    max_frame = %d, rx_hdr_len = %d, rx_buf_len = %d dtype = %d\n",
+		 vsi->max_frame, vsi->rx_hdr_len, vsi->rx_buf_len, vsi->dtype);
 	if (vsi->q_vectors) {
 		for (i = 0; i < vsi->num_q_vectors; i++) {
 			dev_info(&pf->pdev->dev,
-				"    q_vectors[%i]: base index = %ld\n",
-				i, ((long int)*vsi->q_vectors[i].rx.ring-
-					(long int)*vsi->q_vectors[0].rx.ring)/
-					sizeof(struct i40e_ring));
+				 "    q_vectors[%i]: base index = %ld\n",
+				 i, ((long int)*vsi->q_vectors[i].rx.ring-
+				     (long int)*vsi->q_vectors[0].rx.ring)/
+				 sizeof(struct i40e_ring));
 		}
 	}
 	dev_info(&pf->pdev->dev,
-		"    num_q_vectors = %i, base_vector = %i\n",
-		vsi->num_q_vectors, vsi->base_vector);
+		 "    num_q_vectors = %i, base_vector = %i\n",
+		 vsi->num_q_vectors, vsi->base_vector);
 	dev_info(&pf->pdev->dev,
-		"    seid = %d, id = %d, uplink_seid = %d\n",
-		vsi->seid, vsi->id, vsi->uplink_seid);
+		 "    seid = %d, id = %d, uplink_seid = %d\n",
+		 vsi->seid, vsi->id, vsi->uplink_seid);
 	dev_info(&pf->pdev->dev,
-		"    base_queue = %d, num_queue_pairs = %d, num_desc = %d\n",
-		vsi->base_queue, vsi->num_queue_pairs, vsi->num_desc);
+		 "    base_queue = %d, num_queue_pairs = %d, num_desc = %d\n",
+		 vsi->base_queue, vsi->num_queue_pairs, vsi->num_desc);
 	dev_info(&pf->pdev->dev,
-		"    type = %i\n",
-		vsi->type);
+		 "    type = %i\n",
+		 vsi->type);
 	dev_info(&pf->pdev->dev,
-		"    info: valid_sections = 0x%04x, switch_id = 0x%04x\n",
-		vsi->info.valid_sections, vsi->info.switch_id);
+		 "    info: valid_sections = 0x%04x, switch_id = 0x%04x\n",
+		 vsi->info.valid_sections, vsi->info.switch_id);
 	dev_info(&pf->pdev->dev,
-		"    info: sw_reserved[] = 0x%02x 0x%02x\n",
-		vsi->info.sw_reserved[0], vsi->info.sw_reserved[1]);
+		 "    info: sw_reserved[] = 0x%02x 0x%02x\n",
+		 vsi->info.sw_reserved[0], vsi->info.sw_reserved[1]);
 	dev_info(&pf->pdev->dev,
-		"    info: sec_flags = 0x%02x, sec_reserved = 0x%02x\n",
-		vsi->info.sec_flags, vsi->info.sec_reserved);
+		 "    info: sec_flags = 0x%02x, sec_reserved = 0x%02x\n",
+		 vsi->info.sec_flags, vsi->info.sec_reserved);
 	dev_info(&pf->pdev->dev,
-		"    info: pvid = 0x%04x, fcoe_pvid = 0x%04x, port_vlan_flags = 0x%02x\n",
-		vsi->info.pvid, vsi->info.fcoe_pvid, vsi->info.port_vlan_flags);
+		 "    info: pvid = 0x%04x, fcoe_pvid = 0x%04x, port_vlan_flags = 0x%02x\n",
+		 vsi->info.pvid, vsi->info.fcoe_pvid, vsi->info.port_vlan_flags);
 	dev_info(&pf->pdev->dev,
-		"    info: pvlan_reserved[] = 0x%02x 0x%02x 0x%02x\n",
-		vsi->info.pvlan_reserved[0], vsi->info.pvlan_reserved[1],
-		vsi->info.pvlan_reserved[2]);
+		 "    info: pvlan_reserved[] = 0x%02x 0x%02x 0x%02x\n",
+		 vsi->info.pvlan_reserved[0], vsi->info.pvlan_reserved[1],
+		 vsi->info.pvlan_reserved[2]);
 	dev_info(&pf->pdev->dev,
-		"    info: ingress_table = 0x%08x, egress_table = 0x%08x\n",
-		vsi->info.ingress_table, vsi->info.egress_table);
+		 "    info: ingress_table = 0x%08x, egress_table = 0x%08x\n",
+		 vsi->info.ingress_table, vsi->info.egress_table);
 	dev_info(&pf->pdev->dev,
-		"    info: cas_pv_stag = 0x%04x, cas_pv_flags= 0x%02x, cas_pv_reserved = 0x%02x\n",
-		vsi->info.cas_pv_tag, vsi->info.cas_pv_flags,
-		vsi->info.cas_pv_reserved);
+		 "    info: cas_pv_stag = 0x%04x, cas_pv_flags= 0x%02x, cas_pv_reserved = 0x%02x\n",
+		 vsi->info.cas_pv_tag, vsi->info.cas_pv_flags,
+		 vsi->info.cas_pv_reserved);
 	dev_info(&pf->pdev->dev,
-		"    info: queue_mapping[0..7 ] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
-		vsi->info.queue_mapping[0], vsi->info.queue_mapping[1],
-		vsi->info.queue_mapping[2], vsi->info.queue_mapping[3],
-		vsi->info.queue_mapping[4], vsi->info.queue_mapping[5],
-		vsi->info.queue_mapping[6], vsi->info.queue_mapping[7]);
+		 "    info: queue_mapping[0..7 ] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
+		 vsi->info.queue_mapping[0], vsi->info.queue_mapping[1],
+		 vsi->info.queue_mapping[2], vsi->info.queue_mapping[3],
+		 vsi->info.queue_mapping[4], vsi->info.queue_mapping[5],
+		 vsi->info.queue_mapping[6], vsi->info.queue_mapping[7]);
 	dev_info(&pf->pdev->dev,
-		"    info: queue_mapping[8..15] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
-		vsi->info.queue_mapping[8], vsi->info.queue_mapping[9],
-		vsi->info.queue_mapping[10], vsi->info.queue_mapping[11],
-		vsi->info.queue_mapping[12], vsi->info.queue_mapping[13],
-		vsi->info.queue_mapping[14], vsi->info.queue_mapping[15]);
+		 "    info: queue_mapping[8..15] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
+		 vsi->info.queue_mapping[8], vsi->info.queue_mapping[9],
+		 vsi->info.queue_mapping[10], vsi->info.queue_mapping[11],
+		 vsi->info.queue_mapping[12], vsi->info.queue_mapping[13],
+		 vsi->info.queue_mapping[14], vsi->info.queue_mapping[15]);
 	dev_info(&pf->pdev->dev,
-		"    info: tc_mapping[] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
-		vsi->info.tc_mapping[0], vsi->info.tc_mapping[1],
-		vsi->info.tc_mapping[2], vsi->info.tc_mapping[3],
-		vsi->info.tc_mapping[4], vsi->info.tc_mapping[5],
-		vsi->info.tc_mapping[6], vsi->info.tc_mapping[7]);
+		 "    info: tc_mapping[] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
+		 vsi->info.tc_mapping[0], vsi->info.tc_mapping[1],
+		 vsi->info.tc_mapping[2], vsi->info.tc_mapping[3],
+		 vsi->info.tc_mapping[4], vsi->info.tc_mapping[5],
+		 vsi->info.tc_mapping[6], vsi->info.tc_mapping[7]);
 	dev_info(&pf->pdev->dev,
-		"    info: queueing_opt_flags = 0x%02x  queueing_opt_reserved[0..2] = 0x%02x 0x%02x 0x%02x\n",
-		vsi->info.queueing_opt_flags,
-		vsi->info.queueing_opt_reserved[0],
-		vsi->info.queueing_opt_reserved[1],
-		vsi->info.queueing_opt_reserved[2]);
+		 "    info: queueing_opt_flags = 0x%02x  queueing_opt_reserved[0..2] = 0x%02x 0x%02x 0x%02x\n",
+		 vsi->info.queueing_opt_flags,
+		 vsi->info.queueing_opt_reserved[0],
+		 vsi->info.queueing_opt_reserved[1],
+		 vsi->info.queueing_opt_reserved[2]);
 	dev_info(&pf->pdev->dev,
-		"    info: up_enable_bits = 0x%02x\n",
-		vsi->info.up_enable_bits);
+		 "    info: up_enable_bits = 0x%02x\n",
+		 vsi->info.up_enable_bits);
 	dev_info(&pf->pdev->dev,
-		"    info: sched_reserved = 0x%02x, outer_up_table = 0x%04x\n",
-		vsi->info.sched_reserved, vsi->info.outer_up_table);
+		 "    info: sched_reserved = 0x%02x, outer_up_table = 0x%04x\n",
+		 vsi->info.sched_reserved, vsi->info.outer_up_table);
 	dev_info(&pf->pdev->dev,
-		"    info: cmd_reserved[] = 0x%02x 0x%02x 0x%02x 0x0%02x 0x%02x 0x%02x 0x%02x 0x0%02x\n",
-		vsi->info.cmd_reserved[0], vsi->info.cmd_reserved[1],
-		vsi->info.cmd_reserved[2], vsi->info.cmd_reserved[3],
-		vsi->info.cmd_reserved[4], vsi->info.cmd_reserved[5],
-		vsi->info.cmd_reserved[6], vsi->info.cmd_reserved[7]);
+		 "    info: cmd_reserved[] = 0x%02x 0x%02x 0x%02x 0x0%02x 0x%02x 0x%02x 0x%02x 0x0%02x\n",
+		 vsi->info.cmd_reserved[0], vsi->info.cmd_reserved[1],
+		 vsi->info.cmd_reserved[2], vsi->info.cmd_reserved[3],
+		 vsi->info.cmd_reserved[4], vsi->info.cmd_reserved[5],
+		 vsi->info.cmd_reserved[6], vsi->info.cmd_reserved[7]);
 	dev_info(&pf->pdev->dev,
-		"    info: qs_handle[] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
-		vsi->info.qs_handle[0], vsi->info.qs_handle[1],
-		vsi->info.qs_handle[2], vsi->info.qs_handle[3],
-		vsi->info.qs_handle[4], vsi->info.qs_handle[5],
-		vsi->info.qs_handle[6], vsi->info.qs_handle[7]);
+		 "    info: qs_handle[] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
+		 vsi->info.qs_handle[0], vsi->info.qs_handle[1],
+		 vsi->info.qs_handle[2], vsi->info.qs_handle[3],
+		 vsi->info.qs_handle[4], vsi->info.qs_handle[5],
+		 vsi->info.qs_handle[6], vsi->info.qs_handle[7]);
 	dev_info(&pf->pdev->dev,
-		"    info: stat_counter_idx = 0x%04x, sched_id = 0x%04x\n",
-		vsi->info.stat_counter_idx, vsi->info.sched_id);
+		 "    info: stat_counter_idx = 0x%04x, sched_id = 0x%04x\n",
+		 vsi->info.stat_counter_idx, vsi->info.sched_id);
 	dev_info(&pf->pdev->dev,
-		"    info: resp_reserved[] = 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x\n",
-		vsi->info.resp_reserved[0], vsi->info.resp_reserved[1],
-		vsi->info.resp_reserved[2], vsi->info.resp_reserved[3],
-		vsi->info.resp_reserved[4], vsi->info.resp_reserved[5],
-		vsi->info.resp_reserved[6], vsi->info.resp_reserved[7],
-		vsi->info.resp_reserved[8], vsi->info.resp_reserved[9],
-		vsi->info.resp_reserved[10], vsi->info.resp_reserved[11]);
+		 "    info: resp_reserved[] = 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x\n",
+		 vsi->info.resp_reserved[0], vsi->info.resp_reserved[1],
+		 vsi->info.resp_reserved[2], vsi->info.resp_reserved[3],
+		 vsi->info.resp_reserved[4], vsi->info.resp_reserved[5],
+		 vsi->info.resp_reserved[6], vsi->info.resp_reserved[7],
+		 vsi->info.resp_reserved[8], vsi->info.resp_reserved[9],
+		 vsi->info.resp_reserved[10], vsi->info.resp_reserved[11]);
 	if (vsi->back)
 		dev_info(&pf->pdev->dev,
-			"    pf = %p\n", vsi->back);
+			 "    pf = %p\n", vsi->back);
 	dev_info(&pf->pdev->dev,
-		"    idx = %d\n", vsi->idx);
+		 "    idx = %d\n", vsi->idx);
 	dev_info(&pf->pdev->dev,
-		"    tc_config: numtc = %d, enabled_tc = 0x%x\n",
-		vsi->tc_config.numtc, vsi->tc_config.enabled_tc);
+		 "    tc_config: numtc = %d, enabled_tc = 0x%x\n",
+		 vsi->tc_config.numtc, vsi->tc_config.enabled_tc);
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
 		dev_info(&pf->pdev->dev,
 			 "    tc_config: tc = %d, qoffset = %d, qcount = %d, netdev_tc = %d\n",
@@ -708,8 +707,8 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 			 vsi->tc_config.tc_info[i].netdev_tc);
 	}
 	dev_info(&pf->pdev->dev,
-		"    bw: bw_limit = %d, bw_max_quanta = %d\n",
-		vsi->bw_limit, vsi->bw_max_quanta);
+		 "    bw: bw_limit = %d, bw_max_quanta = %d\n",
+		 vsi->bw_limit, vsi->bw_max_quanta);
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
 		dev_info(&pf->pdev->dev,
 			 "    bw[%d]: ets_share_credits = %d, ets_limit_credits = %d, max_quanta = %d\n",
@@ -735,17 +734,17 @@ static void i40e_dbg_dump_aq_desc(struct i40e_pf *pf)
 	for (i = 0; i < ring->count; i++) {
 		struct i40e_aq_desc *d = I40E_ADMINQ_DESC(*ring, i);
 		dev_info(&pf->pdev->dev,
-			"   at[%02d] flags=0x%04x op=0x%04x dlen=0x%04x ret=0x%04x cookie_h=0x%08x cookie_l=0x%08x\n",
-			i, d->flags, d->opcode, d->datalen, d->retval,
-			d->cookie_high, d->cookie_low);
+			 "   at[%02d] flags=0x%04x op=0x%04x dlen=0x%04x ret=0x%04x cookie_h=0x%08x cookie_l=0x%08x\n",
+			 i, d->flags, d->opcode, d->datalen, d->retval,
+			 d->cookie_high, d->cookie_low);
 		dev_info(&pf->pdev->dev,
-			"            %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
-			d->params.raw[0], d->params.raw[1], d->params.raw[2],
-			d->params.raw[3], d->params.raw[4], d->params.raw[5],
-			d->params.raw[6], d->params.raw[7], d->params.raw[8],
-			d->params.raw[9], d->params.raw[10], d->params.raw[11],
-			d->params.raw[12], d->params.raw[13], d->params.raw[14],
-			d->params.raw[15]);
+			 "            %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
+			 d->params.raw[0], d->params.raw[1], d->params.raw[2],
+			 d->params.raw[3], d->params.raw[4], d->params.raw[5],
+			 d->params.raw[6], d->params.raw[7], d->params.raw[8],
+			 d->params.raw[9], d->params.raw[10], d->params.raw[11],
+			 d->params.raw[12], d->params.raw[13], d->params.raw[14],
+			 d->params.raw[15]);
 	}
 
 	dev_info(&pf->pdev->dev, "%s: AdminQ Rx Ring\n", __func__);
@@ -753,17 +752,17 @@ static void i40e_dbg_dump_aq_desc(struct i40e_pf *pf)
 	for (i = 0; i < ring->count; i++) {
 		struct i40e_aq_desc *d = I40E_ADMINQ_DESC(*ring, i);
 		dev_info(&pf->pdev->dev,
-			"   ar[%02d] flags=0x%04x op=0x%04x dlen=0x%04x ret=0x%04x cookie_h=0x%08x cookie_l=0x%08x\n",
-			i, d->flags, d->opcode, d->datalen, d->retval,
-			d->cookie_high, d->cookie_low);
+			 "   ar[%02d] flags=0x%04x op=0x%04x dlen=0x%04x ret=0x%04x cookie_h=0x%08x cookie_l=0x%08x\n",
+			 i, d->flags, d->opcode, d->datalen, d->retval,
+			 d->cookie_high, d->cookie_low);
 		dev_info(&pf->pdev->dev,
-			"            %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
-			d->params.raw[0], d->params.raw[1], d->params.raw[2],
-			d->params.raw[3], d->params.raw[4], d->params.raw[5],
-			d->params.raw[6], d->params.raw[7], d->params.raw[8],
-			d->params.raw[9], d->params.raw[10], d->params.raw[11],
-			d->params.raw[12], d->params.raw[13], d->params.raw[14],
-			d->params.raw[15]);
+			 "            %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
+			 d->params.raw[0], d->params.raw[1], d->params.raw[2],
+			 d->params.raw[3], d->params.raw[4], d->params.raw[5],
+			 d->params.raw[6], d->params.raw[7], d->params.raw[8],
+			 d->params.raw[9], d->params.raw[10], d->params.raw[11],
+			 d->params.raw[12], d->params.raw[13], d->params.raw[14],
+			 d->params.raw[15]);
 	}
 }
 
@@ -787,7 +786,7 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 	vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 	if (!vsi) {
 		dev_info(&pf->pdev->dev,
-			"%s: vsi %d not found\n", __func__, vsi_seid);
+			 "%s: vsi %d not found\n", __func__, vsi_seid);
 		if (is_rx_ring)
 			dev_info(&pf->pdev->dev,
 				 "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
@@ -846,7 +845,7 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 		if (is_rx_ring)
 			ds = I40E_RX_DESC(&ring, desc_n);
 		else
-			ds = (union i40e_rx_desc *) I40E_TX_DESC(&ring, desc_n);
+			ds = (union i40e_rx_desc *)I40E_TX_DESC(&ring, desc_n);
 		if ((sizeof(union i40e_rx_desc) ==
 		    sizeof(union i40e_16byte_rx_desc)) || (!is_rx_ring))
 			dev_info(&pf->pdev->dev,
@@ -1864,7 +1863,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			for (i = 0; i < buffer_len; i++) {
 				if ((i % 16) == 0) {
 					snprintf(print_buf, 11, "\n0x%08x: ",
-								    offset + i);
+						 offset + i);
 					print_buf += 11;
 				}
 				snprintf(print_buf, 5, "%04x ", buff[i]);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index db2871e..f66bc46 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -322,7 +322,6 @@ static void i40e_get_regs(struct net_device *netdev, struct ethtool_regs *regs,
 			reg_buf[ri++] = rd32(hw, reg);
 		}
 	}
-
 }
 
 static int i40e_get_eeprom(struct net_device *netdev,
@@ -652,7 +651,7 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 		if (vsi == pf->vsi[pf->lan_vsi]) {
 			for (i = 0; i < I40E_GLOBAL_STATS_LEN; i++) {
 				snprintf(p, ETH_GSTRING_LEN, "port.%s",
-					i40e_gstrings_stats[i].stat_string);
+					 i40e_gstrings_stats[i].stat_string);
 				p += ETH_GSTRING_LEN;
 			}
 			for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
@@ -1166,12 +1165,12 @@ static i40e_status i40e_add_del_fdir_udpv4(struct i40e_vsi *vsi,
 
 		if (ret != I40E_SUCCESS) {
 			dev_info(&pf->pdev->dev,
-				"%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
+				 "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
 				__func__, fd_data->pctype, ret);
 			err = true;
 		} else {
 			dev_info(&pf->pdev->dev,
-				"%s: Filter OK for PCTYPE %d (ret = %d)\n",
+				 "%s: Filter OK for PCTYPE %d (ret = %d)\n",
 				 __func__,
 				fd_data->pctype, ret);
 		}
@@ -1212,7 +1211,7 @@ static i40e_status i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 
 	if (ret != I40E_SUCCESS) {
 		dev_info(&pf->pdev->dev,
-			"%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
+			 "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
 			 __func__, fd_data->pctype, ret);
 			err = true;
 	} else {
@@ -1227,12 +1226,12 @@ static i40e_status i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 
 	if (ret != I40E_SUCCESS) {
 		dev_info(&pf->pdev->dev,
-			"%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
+			 "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
 			__func__, fd_data->pctype, ret);
 			err = true;
 	} else {
 		dev_info(&pf->pdev->dev,
-			"%s: Filter OK for PCTYPE %d (ret = %d)\n",
+			 "%s: Filter OK for PCTYPE %d (ret = %d)\n",
 			 __func__, fd_data->pctype, ret);
 	}
 
@@ -1290,12 +1289,12 @@ static i40e_status i40e_add_del_fdir_ipv4(struct i40e_vsi *vsi,
 
 		if (ret != I40E_SUCCESS) {
 			dev_info(&pf->pdev->dev,
-				"%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
+				 "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
 				__func__, fd_data->pctype, ret);
 				err = true;
 		} else {
 			dev_info(&pf->pdev->dev,
-				"%s: Filter OK for PCTYPE %d (ret = %d)\n",
+				 "%s: Filter OK for PCTYPE %d (ret = %d)\n",
 				 __func__, fd_data->pctype, ret);
 		}
 	}
@@ -1338,7 +1337,7 @@ static int i40e_add_del_fdir_ethtool(struct i40e_vsi *vsi,
 
 	if (!fd_data.raw_packet) {
 		dev_info(&pf->pdev->dev,
-			"%s: Could not allocate memory\n", __func__);
+			 "%s: Could not allocate memory\n", __func__);
 		return -ENOMEM;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
index 695ed3c..84c8f93 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
@@ -136,7 +136,7 @@ i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
 	if (txq_num > obj->max_cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_COUNT;
 		hw_dbg(hw, "i40e_init_lan_hmc: Tx context: asks for 0x%x but max allowed is 0x%x, returns error %d\n",
-			  txq_num, obj->max_cnt, ret_code);
+		       txq_num, obj->max_cnt, ret_code);
 		goto init_lan_hmc_out;
 	}
 
@@ -159,7 +159,7 @@ i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
 	if (rxq_num > obj->max_cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_COUNT;
 		hw_dbg(hw, "i40e_init_lan_hmc: Rx context: asks for 0x%x but max allowed is 0x%x, returns error %d\n",
-			  rxq_num, obj->max_cnt, ret_code);
+		       rxq_num, obj->max_cnt, ret_code);
 		goto init_lan_hmc_out;
 	}
 
@@ -182,7 +182,7 @@ i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
 	if (fcoe_cntx_num > obj->max_cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_COUNT;
 		hw_dbg(hw, "i40e_init_lan_hmc: FCoE context: asks for 0x%x but max allowed is 0x%x, returns error %d\n",
-			  fcoe_cntx_num, obj->max_cnt, ret_code);
+		       fcoe_cntx_num, obj->max_cnt, ret_code);
 		goto init_lan_hmc_out;
 	}
 
@@ -205,7 +205,7 @@ i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
 	if (fcoe_filt_num > obj->max_cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_COUNT;
 		hw_dbg(hw, "i40e_init_lan_hmc: FCoE filter: asks for 0x%x but max allowed is 0x%x, returns error %d\n",
-			  fcoe_filt_num, obj->max_cnt, ret_code);
+		       fcoe_filt_num, obj->max_cnt, ret_code);
 		goto init_lan_hmc_out;
 	}
 
@@ -330,14 +330,14 @@ static i40e_status i40e_create_lan_hmc_object(struct i40e_hw *hw,
 	if (info->start_idx >= info->hmc_info->hmc_obj[info->rsrc_type].cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_INDEX;
 		hw_dbg(hw, "i40e_create_lan_hmc_object: returns error %d\n",
-			  ret_code);
+		       ret_code);
 		goto exit;
 	}
 	if ((info->start_idx + info->count) >
 	    info->hmc_info->hmc_obj[info->rsrc_type].cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_COUNT;
 		hw_dbg(hw, "i40e_create_lan_hmc_object: returns error %d\n",
-			  ret_code);
+		       ret_code);
 		goto exit;
 	}
 
@@ -408,7 +408,7 @@ static i40e_status i40e_create_lan_hmc_object(struct i40e_hw *hw,
 			switch (sd_entry->entry_type) {
 			case I40E_SD_TYPE_PAGED:
 				I40E_SET_PF_SD_ENTRY(hw,
-					sd_entry->u.pd_table.pd_page_addr.pa,
+						     sd_entry->u.pd_table.pd_page_addr.pa,
 					j, sd_entry->entry_type);
 				break;
 			case I40E_SD_TYPE_DIRECT:
@@ -506,7 +506,7 @@ try_type_paged:
 		/* unsupported type */
 		ret_code = I40E_ERR_INVALID_SD_TYPE;
 		hw_dbg(hw, "i40e_configure_lan_hmc: Unknown SD type: %d\n",
-			  ret_code);
+		       ret_code);
 		goto configure_lan_hmc_out;
 		break;
 	}
@@ -528,7 +528,7 @@ try_type_paged:
 	/* FCoE contexts */
 	obj = &hw->hmc.hmc_obj[I40E_HMC_FCOE_CTX];
 	wr32(hw, I40E_GLHMC_FCOEDDPBASE(hmc_fn_id),
-	 (u32)((obj->base & I40E_GLHMC_FCOEDDPBASE_FPMFCOEDDPBASE_MASK) / 512));
+	     (u32)((obj->base & I40E_GLHMC_FCOEDDPBASE_FPMFCOEDDPBASE_MASK) / 512));
 	wr32(hw, I40E_GLHMC_FCOEDDPCNT(hmc_fn_id), obj->cnt);
 
 	/* FCoE filters */
@@ -590,7 +590,7 @@ static i40e_status i40e_delete_lan_hmc_object(struct i40e_hw *hw,
 	if (info->start_idx >= info->hmc_info->hmc_obj[info->rsrc_type].cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_INDEX;
 		hw_dbg(hw, "i40e_delete_hmc_object: returns error %d\n",
-			  ret_code);
+		       ret_code);
 		goto exit;
 	}
 
@@ -598,7 +598,7 @@ static i40e_status i40e_delete_lan_hmc_object(struct i40e_hw *hw,
 	    info->hmc_info->hmc_obj[info->rsrc_type].cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_COUNT;
 		hw_dbg(hw, "i40e_delete_hmc_object: returns error %d\n",
-			  ret_code);
+		       ret_code);
 		goto exit;
 	}
 
@@ -895,7 +895,7 @@ i40e_status i40e_hmc_get_object_va(struct i40e_hmc_info *hmc_info,
 	}
 	if (obj_idx >= hmc_info->hmc_obj[rsrc_type].cnt) {
 		hw_dbg(hw, "i40e_hmc_get_object_va: returns error %d\n",
-			  ret_code);
+		       ret_code);
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_INDEX;
 		goto exit;
 	}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 95617e6..b0f92f4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -387,9 +387,9 @@ void i40e_vsi_reset_stats(struct i40e_vsi *vsi)
 	if (vsi->rx_rings)
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
 			memset(&vsi->rx_rings[i].rx_stats, 0 ,
-				sizeof(struct i40e_rx_queue_stats));
+			       sizeof(struct i40e_rx_queue_stats));
 			memset(&vsi->tx_rings[i].tx_stats, 0,
-				sizeof(struct i40e_tx_queue_stats));
+			       sizeof(struct i40e_tx_queue_stats));
 		}
 	vsi->stat_offsets_loaded = false;
 }
@@ -961,7 +961,7 @@ struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi, u8 *macaddr,
 
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
 		if ((0 == memcmp(macaddr, f->macaddr, ETH_ALEN)) &&
-			(!is_vf || f->is_vf) &&
+		    (!is_vf || f->is_vf) &&
 			(!is_netdev || f->is_netdev))
 			return f;
 	}
@@ -1523,7 +1523,7 @@ i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 
 			/* vlan0 as wild card to allow packets from all vlans */
 			if (f->vlan == I40E_VLAN_ANY || (vsi->netdev &&
-			    !(vsi->netdev->features &
+							 !(vsi->netdev->features &
 						 NETIF_F_HW_VLAN_CTAG_FILTER)))
 				cmd_flags |= I40E_AQC_MACVLAN_ADD_IGNORE_VLAN;
 			add_list[num_add].flags = cpu_to_le16(cmd_flags);
@@ -1551,9 +1551,9 @@ i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		kfree(add_list);
 		add_list = NULL;
 
-		if (add_happened && (ret == I40E_SUCCESS))
+		if (add_happened && (ret == I40E_SUCCESS)) {
 			/* do nothing */;
-		else if (add_happened && (ret != I40E_SUCCESS)) {
+		} else if (add_happened && (ret != I40E_SUCCESS)) {
 			dev_info(&pf->pdev->dev,
 				 "%s: add filter failed, err %d, aq_err %d\n",
 				 __func__, ret, pf->hw.aq.asq_last_status);
@@ -1739,7 +1739,7 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 					is_vf, is_netdev);
 		if (add_f == NULL) {
 			dev_info(&vsi->back->pdev->dev, "%s: Could not add vlan filter %d for %pM\n",
-					 __func__, vid, vsi->netdev->dev_addr);
+				 __func__, vid, vsi->netdev->dev_addr);
 			return -ENOMEM;
 		}
 	}
@@ -1791,8 +1791,8 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 					       0, is_vf, is_netdev);
 				if (add_f == NULL) {
 					dev_info(&vsi->back->pdev->dev,
-					 "%s: Could not add filter 0 for %pM\n",
-					 __func__, f->macaddr);
+						 "%s: Could not add filter 0 for %pM\n",
+						 __func__, f->macaddr);
 					return -ENOMEM;
 				}
 			}
@@ -1828,7 +1828,7 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 	ret = i40e_sync_vsi_filters(vsi);
 	if (ret != I40E_SUCCESS) {
 		dev_info(&vsi->back->pdev->dev, "%s: Could not sync filters\n",
-			__func__);
+			 __func__);
 		return ret;
 	}
 
@@ -1855,8 +1855,8 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 				    is_vf, is_netdev);
 		if (f == NULL) {
 			dev_info(&vsi->back->pdev->dev, "%s: Could not add filter %d for %pM\n",
-					__func__, I40E_VLAN_ANY,
-					 netdev->dev_addr);
+				 __func__, I40E_VLAN_ANY,
+				 netdev->dev_addr);
 			return -ENOMEM;
 		}
 	}
@@ -1868,7 +1868,7 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 					    is_vf, is_netdev);
 			if (add_f == NULL) {
 				dev_info(&vsi->back->pdev->dev, "%s: Could not add filter %d for %pM\n",
-					__func__, I40E_VLAN_ANY, f->macaddr);
+					 __func__, I40E_VLAN_ANY, f->macaddr);
 				return -ENOMEM;
 			}
 		}
@@ -2209,7 +2209,7 @@ static s32 i40e_configure_rx_ring(struct i40e_ring *ring)
 	if (err != I40E_SUCCESS) {
 		dev_info(&vsi->back->pdev->dev,
 			 "%s: Failed to set LAN Rx queue context on Rx ring %d (pf_q %d), error: %d\n",
-			__func__, ring->queue_index, pf_q, err);
+			 __func__, ring->queue_index, pf_q, err);
 		return err;
 	}
 
@@ -2568,14 +2568,14 @@ static int i40e_vsi_request_irq_msix(struct i40e_vsi *vsi, char *basename)
 
 		if (q_vector->tx.ring[0] && q_vector->rx.ring[0]) {
 			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-				"%s-%s-%d", basename, "TxRx", rx_int_idx++);
+				 "%s-%s-%d", basename, "TxRx", rx_int_idx++);
 			tx_int_idx++;
 		} else if (q_vector->rx.ring[0]) {
 			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-				"%s-%s-%d", basename, "rx", rx_int_idx++);
+				 "%s-%s-%d", basename, "rx", rx_int_idx++);
 		} else if (q_vector->tx.ring[0]) {
 			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-				"%s-%s-%d", basename, "tx", tx_int_idx++);
+				 "%s-%s-%d", basename, "tx", tx_int_idx++);
 		} else {
 			/* skip this unused q_vector */
 			continue;
@@ -2587,8 +2587,8 @@ static int i40e_vsi_request_irq_msix(struct i40e_vsi *vsi, char *basename)
 				  q_vector);
 		if (err) {
 			dev_info(&pf->pdev->dev,
-				"%s: request_irq failed, error: %d\n",
-				__func__, err);
+				 "%s: request_irq failed, error: %d\n",
+				 __func__, err);
 			goto free_queue_irqs;
 		}
 		/* assign the mask for this irq */
@@ -2724,7 +2724,6 @@ static irqreturn_t i40e_intr(int irq, void *data)
 
 	/* only q0 is used in MSI/Legacy mode, and none are used in MSIX */
 	if (icr0 & I40E_PFINT_ICR0_QUEUE_0_MASK) {
-
 		/* temporarily disable queue cause for NAPI processing */
 		u32 qval = rd32(hw, I40E_QINT_RQCTL(0));
 		qval &= ~I40E_QINT_RQCTL_CAUSE_ENA_MASK;
@@ -3119,7 +3118,7 @@ static void i40e_vsi_free_irq(struct i40e_vsi *vsi)
 
 			/* clear the affinity_mask in the IRQ descriptor */
 			irq_set_affinity_hint(pf->msix_entries[vector].vector,
-					       NULL);
+					      NULL);
 			free_irq(pf->msix_entries[vector].vector,
 				 &vsi->q_vectors[i]);
 
@@ -3563,7 +3562,7 @@ static s32 i40e_vsi_configure_bw_alloc(struct i40e_vsi *vsi,
 	if (ret != I40E_SUCCESS) {
 		dev_info(&vsi->back->pdev->dev,
 			 "%s: AQ command Config VSI BW allocation per TC failed = %d\n",
-			  __func__, vsi->back->hw.aq.asq_last_status);
+			 __func__, vsi->back->hw.aq.asq_last_status);
 		return ret;
 	}
 
@@ -3611,7 +3610,7 @@ static void i40e_vsi_config_netdev_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 		 */
 		if (vsi->tc_config.enabled_tc & (1 << i))
 			netdev_set_tc_queue(netdev,
-					vsi->tc_config.tc_info[i].netdev_tc,
+					    vsi->tc_config.tc_info[i].netdev_tc,
 					vsi->tc_config.tc_info[i].qcount,
 					vsi->tc_config.tc_info[i].qoffset);
 	}
@@ -3996,7 +3995,6 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 
 	/* do the biggest reset indicated */
 	if (reset_flags & (1 << __I40E_GLOBAL_RESET_REQUESTED)) {
-
 		/* Request a Global Reset
 		 *
 		 * This will start the chip's countdown to the actual full
@@ -4011,7 +4009,6 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		wr32(&pf->hw, I40E_GLGEN_RTRIG, val);
 
 	} else if (reset_flags & (1 << __I40E_CORE_RESET_REQUESTED)) {
-
 		/* Request a Core Reset
 		 *
 		 * Same as Global Reset, except does *not* include the MAC/PHY
@@ -4023,7 +4020,6 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		i40e_flush(&pf->hw);
 
 	} else if (reset_flags & (1 << __I40E_PF_RESET_REQUESTED)) {
-
 		/* Request a PF Reset
 		 *
 		 * Resets only the PF-specific registers
@@ -4411,7 +4407,6 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 
 		opcode = le16_to_cpu(event.desc.opcode);
 		switch (opcode) {
-
 		case i40e_aqc_opc_get_link_status:
 			i40e_handle_link_event(pf, &event);
 			break;
@@ -4426,7 +4421,7 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 		case i40e_aqc_opc_lldp_update_mib:
 			dev_info(&pf->pdev->dev,
 				 "%s: ARQ: Update LLDP MIB event received\n",
-				  __func__);
+				 __func__);
 			break;
 		case i40e_aqc_opc_event_lan_overflow:
 			dev_info(&pf->pdev->dev,
@@ -5049,7 +5044,7 @@ static s32 i40e_vsi_mem_alloc(struct i40e_pf *pf, enum i40e_vsi_type type)
 	}
 	pf->next_vsi = ++i;
 
-	vsi = kzalloc(sizeof(struct i40e_vsi), GFP_KERNEL);
+	vsi = kzalloc(sizeof(*vsi), GFP_KERNEL);
 	if (!vsi) {
 		ret = -ENOMEM;
 		goto err_alloc_vsi;
@@ -5220,8 +5215,8 @@ static int i40e_reserve_msix_vectors(struct i40e_pf *pf, int vectors)
 		} else if (err < 0) {
 			/* total failure */
 			dev_info(&pf->pdev->dev,
-				"%s: MSI-X vector reservation failed: %d\n",
-				__func__, err);
+				 "%s: MSI-X vector reservation failed: %d\n",
+				 __func__, err);
 			vectors = 0;
 			break;
 		} else {
@@ -5235,8 +5230,8 @@ static int i40e_reserve_msix_vectors(struct i40e_pf *pf, int vectors)
 
 	if (vectors > 0 && vectors < I40E_MIN_MSIX) {
 		dev_info(&pf->pdev->dev,
-			"%s: Couldn't get enough vectors, only %d available\n",
-			__func__, vectors);
+			 "%s: Couldn't get enough vectors, only %d available\n",
+			 __func__, vectors);
 		vectors = 0;
 	}
 
@@ -5299,8 +5294,8 @@ static i40e_status i40e_init_msix(struct i40e_pf *pf)
 	} else if (vec == I40E_MIN_MSIX) {
 		/* Adjust for minimal MSIX use */
 		dev_info(&pf->pdev->dev,
-			"%s: Features disabled, not enough MSIX vectors\n",
-			__func__);
+			 "%s: Features disabled, not enough MSIX vectors\n",
+			 __func__);
 		pf->flags &= ~I40E_FLAG_VMDQ_ENABLED;
 		pf->num_vmdq_vsis = 0;
 		pf->num_vmdq_qps = 0;
@@ -5366,7 +5361,7 @@ static int i40e_alloc_q_vectors(struct i40e_vsi *vsi)
 		vsi->q_vectors[v_idx].v_idx = v_idx;
 		/* Allocate the affinity_hint cpumask, configure the mask */
 		if (!alloc_cpumask_var(&vsi->q_vectors[v_idx].affinity_mask,
-					GFP_KERNEL))
+				       GFP_KERNEL))
 			goto err_out;
 		cpumask_set_cpu(v_idx, vsi->q_vectors[v_idx].affinity_mask);
 		if (vsi->netdev)
@@ -5404,8 +5399,8 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 		}
 	}
 
-	if (!(pf->flags & I40E_FLAG_MSIX_ENABLED)
-	    && (pf->flags & I40E_FLAG_MSI_ENABLED)) {
+	if (!(pf->flags & I40E_FLAG_MSIX_ENABLED) &&
+	    (pf->flags & I40E_FLAG_MSI_ENABLED)) {
 		err = pci_enable_msi(pf->pdev);
 		if (err) {
 			dev_info(&pf->pdev->dev,
@@ -5443,8 +5438,8 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
 				  i40e_intr, 0, pf->misc_int_name, pf);
 		if (err) {
 			dev_info(&pf->pdev->dev,
-				"%s, request_irq for msix_misc failed: %d\n",
-				__func__, err);
+				 "%s, request_irq for msix_misc failed: %d\n",
+				 __func__, err);
 			return I40E_ERR_CONFIG;
 		}
 	}
@@ -5500,7 +5495,6 @@ static s32 i40e_config_rss(struct i40e_pf *pf)
 
 	/* Populate the LUT with max no. of queues in round robin fashion */
 	for (i = 0, j = 0; i < pf->hw.func_caps.rss_table_size; i++, j++) {
-
 		/* The assumption is that lan qp count will be the highest
 		 * qp count for any PF VSI that needs RSS.
 		 * If multiple VSIs need RSS support, all the qp counts
@@ -5569,13 +5563,13 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	if (pf->hw.func_caps.fd) {
 		/* FW/NVM is not yet fixed in this regard */
 		if ((pf->hw.func_caps.fd_filters_guaranteed > 0) ||
-			   (pf->hw.func_caps.fd_filters_best_effort > 0)) {
+		    (pf->hw.func_caps.fd_filters_best_effort > 0)) {
 			pf->flags |= I40E_FLAG_FDIR_ATR_ENABLED;
 			dev_info(&pf->pdev->dev,
-				"Flow Director ATR mode Enabled\n");
+				 "Flow Director ATR mode Enabled\n");
 			pf->flags |= I40E_FLAG_FDIR_ENABLED;
 			dev_info(&pf->pdev->dev,
-				"Flow Director Side Band mode Enabled\n");
+				 "Flow Director Side Band mode Enabled\n");
 			pf->fdir_pf_filter_count =
 					 pf->hw.func_caps.fd_filters_guaranteed;
 		}
@@ -5733,7 +5727,7 @@ static s32 i40e_config_netdev(struct i40e_vsi *vsi)
 	} else {
 		random_ether_addr(mac_addr);
 		snprintf(netdev->name, IFNAMSIZ, "%sv%%d",
-			pf->vsi[pf->lan_vsi]->netdev->name);
+			 pf->vsi[pf->lan_vsi]->netdev->name);
 		i40e_add_filter(vsi, mac_addr, I40E_VLAN_ANY, false, false);
 	}
 
@@ -6130,7 +6124,6 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 	}
 
 	if (!veb && uplink_seid != pf->mac_seid) {
-
 		for (i = 0; i < pf->hw.func_caps.num_vsis; i++) {
 			if (pf->vsi[i] && pf->vsi[i]->seid == uplink_seid) {
 				vsi = pf->vsi[i];
@@ -6323,7 +6316,7 @@ static s32 i40e_veb_mem_alloc(struct i40e_pf *pf)
 		goto err_alloc_veb;  /* out of VEB slots! */
 	}
 
-	veb = kzalloc(sizeof(struct i40e_veb), GFP_KERNEL);
+	veb = kzalloc(sizeof(*veb), GFP_KERNEL);
 	if (!veb) {
 		ret = -ENOMEM;
 		goto err_alloc_veb;
@@ -6370,7 +6363,7 @@ static void i40e_switch_branch_release(struct i40e_veb *branch)
 		if (!pf->vsi[i])
 			continue;
 		if (pf->vsi[i]->uplink_seid == branch_seid &&
-		   (pf->vsi[i]->flags & I40E_VSI_FLAG_VEB_OWNER) == 0) {
+		    (pf->vsi[i]->flags & I40E_VSI_FLAG_VEB_OWNER) == 0) {
 			i40e_vsi_release(pf->vsi[i]);
 		}
 	}
@@ -6532,8 +6525,8 @@ struct i40e_veb *i40e_veb_setup(struct i40e_pf *pf, u16 flags,
 	int ret;
 
 	/* if one seid is 0, the other must be 0 to create a floating relay */
-	if ((uplink_seid == 0 || vsi_seid == 0)
-	    && (uplink_seid + vsi_seid != 0)) {
+	if ((uplink_seid == 0 || vsi_seid == 0) &&
+	    (uplink_seid + vsi_seid != 0)) {
 		dev_info(&pf->pdev->dev,
 			 "%s: one, not both seid's are 0: uplink=%d vsi=%d\n",
 			 __func__, uplink_seid, vsi_seid);
@@ -6644,10 +6637,10 @@ s32 i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
 				dev_info(&pf->pdev->dev,
 					 "%s: type=%d seid=%d uplink=%d downlink=%d\n",
 					 __func__,
-					sw_config->element[i].element_type,
-					sw_config->element[i].seid,
-					sw_config->element[i].uplink_seid,
-					sw_config->element[i].downlink_seid);
+					 sw_config->element[i].element_type,
+					 sw_config->element[i].seid,
+					 sw_config->element[i].uplink_seid,
+					 sw_config->element[i].downlink_seid);
 
 			switch (sw_config->element[i].element_type) {
 			case I40E_SWITCH_ELEMENT_TYPE_MAC:
@@ -6708,10 +6701,10 @@ s32 i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
 				break;
 			default:
 				dev_info(&pf->pdev->dev,
-					"%s: unknown element type=%d seid=%d\n",
-					__func__,
-					sw_config->element[i].element_type,
-					sw_config->element[i].seid);
+					 "%s: unknown element type=%d seid=%d\n",
+					 __func__,
+					 sw_config->element[i].element_type,
+					 sw_config->element[i].seid);
 				break;
 			}
 		}
@@ -6850,7 +6843,6 @@ pf->rss_size = num_tc0;                                        \
 		!(pf->flags & (I40E_FLAG_RSS_ENABLED |
 		I40E_FLAG_FDIR_ENABLED | I40E_FLAG_DCB_ENABLED)) ||
 		(queues_left == 1)) {
-
 		/* one qp for PF, no queues for anything else */
 		queues_left = 0;
 		pf->rss_size = pf->num_lan_qps = 1;
@@ -6867,7 +6859,6 @@ pf->rss_size = num_tc0;                                        \
 	} else if (pf->flags & I40E_FLAG_RSS_ENABLED	  &&
 		   !(pf->flags & I40E_FLAG_FDIR_ENABLED)  &&
 		   !(pf->flags & I40E_FLAG_DCB_ENABLED)) {
-
 		SET_RSS_SIZE;
 
 		queues_left -= pf->rss_size;
@@ -6876,7 +6867,6 @@ pf->rss_size = num_tc0;                                        \
 	} else if (pf->flags & I40E_FLAG_RSS_ENABLED	  &&
 		   !(pf->flags & I40E_FLAG_FDIR_ENABLED)  &&
 		   (pf->flags & I40E_FLAG_DCB_ENABLED)) {
-
 		/* save num_tc_qps queues for TCs 1 thru 7 and the rest
 		 * are set up for RSS in TC0
 		 */
@@ -6896,7 +6886,6 @@ pf->rss_size = num_tc0;                                        \
 	} else if (pf->flags & I40E_FLAG_RSS_ENABLED   &&
 		  (pf->flags & I40E_FLAG_FDIR_ENABLED) &&
 		  !(pf->flags & I40E_FLAG_DCB_ENABLED)) {
-
 		queues_left -= 1; /* save 1 queue for FD */
 
 		SET_RSS_SIZE;
@@ -6914,7 +6903,6 @@ pf->rss_size = num_tc0;                                        \
 	} else if (pf->flags & I40E_FLAG_RSS_ENABLED   &&
 		  (pf->flags & I40E_FLAG_FDIR_ENABLED) &&
 		  (pf->flags & I40E_FLAG_DCB_ENABLED)) {
-
 		/* save 1 queue for TCs 1 thru 7,
 		 * 1 queue for flow director,
 		 * and the rest are set up for RSS in TC0
@@ -6941,14 +6929,14 @@ pf->rss_size = num_tc0;                                        \
 	}
 
 	if ((pf->flags & I40E_FLAG_SRIOV_ENABLED) &&
-	     pf->num_vf_qps && pf->num_req_vfs && queues_left) {
+	    pf->num_vf_qps && pf->num_req_vfs && queues_left) {
 		pf->num_req_vfs = min_t(int, pf->num_req_vfs, (queues_left /
 							       pf->num_vf_qps));
 		queues_left -= (pf->num_req_vfs * pf->num_vf_qps);
 	}
 
 	if ((pf->flags & I40E_FLAG_VMDQ_ENABLED) &&
-	     pf->num_vmdq_vsis && pf->num_vmdq_qps && queues_left) {
+	    pf->num_vmdq_vsis && pf->num_vmdq_qps && queues_left) {
 		pf->num_vmdq_vsis = min_t(int, pf->num_vmdq_vsis,
 					  (queues_left / pf->num_vmdq_qps));
 		queues_left -= (pf->num_vmdq_vsis * pf->num_vmdq_qps);
@@ -7018,7 +7006,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
 	} else {
 		dev_err(&pdev->dev, "%s: DMA configuration failed: %d\n",
-			 __func__, err);
+			__func__, err);
 		err = -EIO;
 		goto err_dma;
 	}
@@ -7041,7 +7029,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * the Admin Queue structures and then querying for the
 	 * device's current profile information.
 	 */
-	pf = kzalloc(sizeof(struct i40e_pf), GFP_KERNEL);
+	pf = kzalloc(sizeof(*pf), GFP_KERNEL);
 	if (!pf) {
 		err = -ENOMEM;
 		goto err_pf_alloc;
@@ -7101,7 +7089,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			 "%s: init_adminq failed: %d expecting API %02x.%02x\n",
 			 __func__, err,
 			 I40E_FW_API_VERSION_MAJOR, I40E_FW_API_VERSION_MINOR
-			 );
+			);
 		goto err_pf_reset;
 	}
 
@@ -7318,8 +7306,8 @@ static void i40e_remove(struct pci_dev *pdev)
 	ret_code = i40e_shutdown_adminq(&pf->hw);
 	if (ret_code != I40E_SUCCESS)
 		dev_warn(&pdev->dev,
-			"%s: Failed to destroy the Admin Queue resources: %d\n",
-			__func__, ret_code);
+			 "%s: Failed to destroy the Admin Queue resources: %d\n",
+			 __func__, ret_code);
 
 	/* Clear all dynamic memory lists of rings, q_vectors, and VSIs */
 	i40e_clear_interrupt_scheme(pf);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 64f829b..41d4904 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -120,7 +120,7 @@ i40e_status i40e_acquire_nvm(struct i40e_hw *hw,
 			hw->nvm.hw_semaphore_wait =
 						I40E_MS_TO_GTIME(time) + gtime;
 			hw_dbg(hw, "NVM acquire timed out, wait %llu ms before trying again.\n",
-				  time);
+			       time);
 		}
 	}
 
@@ -204,7 +204,7 @@ static i40e_status i40e_read_nvm_srctl(struct i40e_hw *hw, u16 offset,
 	}
 	if (ret_code != I40E_SUCCESS)
 		hw_dbg(hw, "NVM read error: Couldn't access Shadow RAM address: 0x%x\n",
-			  offset);
+		       offset);
 
 read_nvm_exit:
 	return ret_code;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_sysfs.c b/drivers/net/ethernet/intel/i40e/i40e_sysfs.c
index 5f4e937..fe83333 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_sysfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_sysfs.c
@@ -396,10 +396,10 @@ static struct attribute_group i40e_sys_veb_attr_group = {
 /* hw-switch attributes */
 static struct kobj_attribute i40e_sys_hw_switch_hash_ptypes_attr =
 	__ATTR(hash_ptypes, 0644, i40e_sys_hw_switch_hash_ptypes_read,
-	i40e_sys_hw_switch_hash_ptypes_write);
+	       i40e_sys_hw_switch_hash_ptypes_write);
 static struct kobj_attribute i40e_sys_hw_switch_hash_type_attr =
 	__ATTR(hash_type, S_IWUSR | S_IRUGO, i40e_sys_hw_switch_hash_type_read,
-	i40e_sys_hw_switch_hash_type_write);
+	       i40e_sys_hw_switch_hash_type_write);
 
 static struct attribute *i40e_sys_hw_switch_attrs[] = {
 	&i40e_sys_hw_switch_hash_ptypes_attr.attr,
@@ -440,8 +440,8 @@ i40e_status i40e_sys_add_vsi(struct i40e_vsi *vsi)
 	} else {
 		/* find the parent kobj */
 		for (parent_veb = 0; parent_veb < I40E_MAX_VEB; parent_veb++) {
-			if (pf->veb[parent_veb]
-			    && pf->veb[parent_veb]->seid == vsi->uplink_seid)
+			if (pf->veb[parent_veb] &&
+			    pf->veb[parent_veb]->seid == vsi->uplink_seid)
 				break;
 		}
 		if ((parent_veb == I40E_MAX_VEB) ||
@@ -512,8 +512,8 @@ i40e_status i40e_sys_add_veb(struct i40e_veb *veb)
 		kobj = pf->switch_kobj;
 	} else {
 		for (parent_veb = 0; parent_veb < I40E_MAX_VEB; parent_veb++) {
-			if (pf->veb[parent_veb]
-			    && pf->veb[parent_veb]->seid == veb->uplink_seid)
+			if (pf->veb[parent_veb] &&
+			    pf->veb[parent_veb]->seid == veb->uplink_seid)
 				break;
 		}
 		if ((parent_veb != I40E_MAX_VEB) &&
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 7584c05..b6689d0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -301,7 +301,7 @@ static bool i40e_check_tx_hang(struct i40e_ring *tx_ring)
 	 * pending but without time to complete it yet.
 	 */
 	if ((tx_ring->tx_stats.tx_done_old == tx_ring->tx_stats.packets) &&
-	     tx_pending) {
+	    tx_pending) {
 		/* make sure it is true for two checks in a row */
 		ret = test_and_set_bit(__I40E_HANG_CHECK_ARMED,
 				       &tx_ring->state);
@@ -406,7 +406,7 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 		netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
 
 		dev_info(tx_ring->dev,
-			"tx hang detected on queue %d, resetting adapter\n",
+			 "tx hang detected on queue %d, resetting adapter\n",
 			tx_ring->queue_index);
 
 		tx_ring->netdev->netdev_ops->ndo_tx_timeout(tx_ring->netdev);
@@ -962,7 +962,6 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 
 		/* Get the rest of the data if this was a header split */
 		if (ring_is_ps_enabled(rx_ring) && rx_packet_len) {
-
 			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
 					   rx_bi->page,
 					   rx_bi->page_offset,
@@ -1103,7 +1102,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	if (!test_bit(__I40E_DOWN, &vsi->state)) {
 		if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
 			i40e_irq_dynamic_enable(vsi,
-					q_vector->v_idx + vsi->base_vector);
+						q_vector->v_idx + vsi->base_vector);
 		} else {
 			struct i40e_hw *hw = &vsi->back->hw;
 			/* We re-enable the queue 0 cause, but
@@ -1337,7 +1336,6 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
 						 0, IPPROTO_TCP, 0);
 	} else if (skb_is_gso_v6(skb)) {
-
 		ipv6h = skb->encapsulation ? inner_ipv6_hdr(skb)
 					   : ipv6_hdr(skb);
 		tcph = skb->encapsulation ? inner_tcp_hdr(skb) : tcp_hdr(skb);
@@ -1388,7 +1386,6 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 tx_flags,
 		this_tcp_hdrlen = inner_tcp_hdrlen(skb);
 
 		if (tx_flags & I40E_TX_FLAGS_IPV4) {
-
 			if (tx_flags & I40E_TX_FLAGS_TSO) {
 				*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV4;
 				ip_hdr(skb)->check = 0;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 5baa99b..0125c96 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -247,13 +247,12 @@ struct i40e_ring_container {
 	u16 itr;
 };
 
-extern void i40e_alloc_rx_buffers(struct i40e_ring *rxr, u16 cleaned_count);
-extern netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb,
-				       struct net_device *netdev);
+void i40e_alloc_rx_buffers(struct i40e_ring *rxr, u16 cleaned_count);
+netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 void i40e_clean_tx_ring(struct i40e_ring *tx_ring);
 void i40e_clean_rx_ring(struct i40e_ring *rx_ring);
-extern int i40e_setup_tx_descriptors(struct i40e_ring *tx_ring);
-extern int i40e_setup_rx_descriptors(struct i40e_ring *rx_ring);
-extern void i40e_free_tx_resources(struct i40e_ring *tx_ring);
-extern void i40e_free_rx_resources(struct i40e_ring *rx_ring);
-extern int i40e_napi_poll(struct napi_struct *napi, int budget);
+int i40e_setup_tx_descriptors(struct i40e_ring *tx_ring);
+int i40e_setup_rx_descriptors(struct i40e_ring *rx_ring);
+void i40e_free_tx_resources(struct i40e_ring *tx_ring);
+void i40e_free_rx_resources(struct i40e_ring *rx_ring);
+int i40e_napi_poll(struct napi_struct *napi, int budget);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index cdc7fad..441ae12 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -884,9 +884,9 @@ i40e_status i40e_free_vfs(struct i40e_pf *pf)
 
 	/* Re-enable interrupt 0. */
 	wr32(hw, I40E_PFINT_DYN_CTL0,
-		 I40E_PFINT_DYN_CTL0_INTENA_MASK |
-		 I40E_PFINT_DYN_CTL0_CLEARPBA_MASK |
-		 (I40E_ITR_NONE << I40E_PFINT_DYN_CTL0_ITR_INDX_SHIFT));
+	     I40E_PFINT_DYN_CTL0_INTENA_MASK |
+	     I40E_PFINT_DYN_CTL0_CLEARPBA_MASK |
+	     (I40E_ITR_NONE << I40E_PFINT_DYN_CTL0_ITR_INDX_SHIFT));
 	i40e_flush(hw);
 	return ret;
 }
@@ -1150,7 +1150,7 @@ static i40e_status i40e_vc_get_vf_resources_msg(struct i40e_vf *vf)
 err:
 	/* send the response back to the vf */
 	ret = i40e_vc_send_msg_to_vf(vf, I40E_VIRTCHNL_OP_GET_VF_RESOURCES,
-				     ret, (u8 *) vfres, len);
+				     ret, (u8 *)vfres, len);
 
 	kfree(vfres);
 	return ret;
@@ -1832,8 +1832,8 @@ static i40e_status i40e_vc_remove_vlan_msg(struct i40e_vf *vf, u8 *msg,
 		ret = i40e_vsi_kill_vlan(vsi, vfl->vlan_id[i]);
 		if (I40E_SUCCESS != ret)
 			dev_err(&pf->pdev->dev,
-			     "%s: Unable to delete vlan filter %d, error %d\n",
-			      __func__, vfl->vlan_id[i], ret);
+				"%s: Unable to delete vlan filter %d, error %d\n",
+				__func__, vfl->vlan_id[i], ret);
 	}
 
 error_param:
@@ -2108,7 +2108,6 @@ i40e_status i40e_vc_process_vflr_event(struct i40e_pf *pf)
 
 			ret = i40e_enable_vf_mappings(vf);
 		}
-
 	}
 
 	/* re-enable vflr interrupt cause */
-- 
1.8.1.2.459.gbcd45b4.dirty
