From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next v2 6/6] bnx2x: function descriptions format fixed
Date: Thu, 5 May 2011 01:24:07 +0300
Message-ID: <1304547847.19742.22.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3419 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756166Ab1EDWZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 18:25:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: David Miller <davem@davemloft.net>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c  |   44 +++---
 drivers/net/bnx2x/bnx2x_cmn.h  |  293 +++++++++++++++++-----------------------
 drivers/net/bnx2x/bnx2x_dcb.c  |   26 ----
 drivers/net/bnx2x/bnx2x_dcb.h  |    6 -
 drivers/net/bnx2x/bnx2x_link.c |   14 +-
 drivers/net/bnx2x/bnx2x_main.c |   60 +++++----
 6 files changed, 184 insertions(+), 259 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 8c16879..e5b3d35 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -308,13 +308,13 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
  */
 #define TPA_TSTAMP_OPT_LEN	12
 /**
- * Calculate the approximate value of the MSS for this
- * aggregation using the first packet of it.
+ * bnx2x_set_lro_mss - calculate the approximate value of the
+ * MSS for this aggregation using the first packet of it.
  *
- * @param bp
- * @param parsing_flags Parsing flags from the START CQE
- * @param len_on_bd Total length of the first packet for the
- *		     aggregation.
+ * @bp:			driver handle
+ * @parsing_flags:	parsing flags from the START CQE
+ * @len_on_bd:		total length of the first packet for the
+ *			aggregation.
  */
 static inline u16 bnx2x_set_lro_mss(struct bnx2x *bp, u16 parsing_flags,
 				    u16 len_on_bd)
@@ -2084,12 +2084,11 @@ static inline void bnx2x_set_pbd_gso_e2(struct sk_buff *skb, u32 *parsing_data,
 }
 
 /**
- * Update PBD in GSO case.
+ * bnx2x_set_pbd_gso - update PBD in GSO case.
  *
- * @param skb
- * @param tx_start_bd
- * @param pbd
- * @param xmit_type
+ * @skb:	packet skb
+ * @pbd:	parse BD
+ * @xmit_type:	xmit flags
  */
 static inline void bnx2x_set_pbd_gso(struct sk_buff *skb,
 				     struct eth_tx_parse_bd_e1x *pbd,
@@ -2116,13 +2115,13 @@ static inline void bnx2x_set_pbd_gso(struct sk_buff *skb,
 }
 
 /**
+ * bnx2x_set_pbd_csum_e2 - update parsing data with checksum for 57712
+ * and return header length
  *
- * @param skb
- * @param tx_start_bd
- * @param pbd_e2
- * @param xmit_type
- *
- * @return header len
+ * @bp:			driver handle
+ * @skb:		packet skb
+ * @parsing_data:	data to be updated
+ * @xmit_type:		xmit flags
  */
 static inline  u8 bnx2x_set_pbd_csum_e2(struct bnx2x *bp, struct sk_buff *skb,
 	u32 *parsing_data, u32 xmit_type)
@@ -2147,13 +2146,12 @@ static inline  u8 bnx2x_set_pbd_csum_e2(struct bnx2x *bp, struct sk_buff *skb,
 }
 
 /**
+ * bnx2x_set_pbd_csum - update PBD with checksum and return header length
  *
- * @param skb
- * @param tx_start_bd
- * @param pbd
- * @param xmit_type
- *
- * @return Header length
+ * @bp:		driver handle
+ * @skb:	packet skb
+ * @pbd:	parse BD to be updated
+ * @xmit_type:	xmit flags
  */
 static inline u8 bnx2x_set_pbd_csum(struct bnx2x *bp, struct sk_buff *skb,
 	struct eth_tx_parse_bd_e1x *pbd,
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 72f206e..b044e8f 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -63,43 +63,41 @@ extern int num_queues;
  */
 
 /**
- * Initialize link parameters structure variables.
+ * bnx2x_initial_phy_init - initialize link parameters structure variables.
  *
- * @param bp
- * @param load_mode
- *
- * @return u8
+ * @bp:		driver handle
+ * @load_mode:	current mode
  */
 u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode);
 
 /**
- * Configure hw according to link parameters structure.
+ * bnx2x_link_set - configure hw according to link parameters structure.
  *
- * @param bp
+ * @bp:		driver handle
  */
 void bnx2x_link_set(struct bnx2x *bp);
 
 /**
- * Query link status
+ * bnx2x_link_test - query link status.
  *
- * @param bp
- * @param is_serdes
+ * @bp:		driver handle
+ * @is_serdes:	bool
  *
- * @return 0 - link is UP
+ * Returns 0 if link is UP.
  */
 u8 bnx2x_link_test(struct bnx2x *bp, u8 is_serdes);
 
 /**
- * Handles link status change
+ * bnx2x__link_status_update - handles link status change.
  *
- * @param bp
+ * @bp:		driver handle
  */
 void bnx2x__link_status_update(struct bnx2x *bp);
 
 /**
- * Report link status to upper layer
+ * bnx2x_link_report - report link status to upper layer.
  *
- * @param bp
+ * @bp:		driver handle
  */
 void bnx2x_link_report(struct bnx2x *bp);
 
@@ -107,212 +105,194 @@ void bnx2x_link_report(struct bnx2x *bp);
 void __bnx2x_link_report(struct bnx2x *bp);
 
 /**
- * calculates MF speed according to current linespeed and MF
- * configuration
- *
- * @param bp
+ * bnx2x_get_mf_speed - calculates MF speed according to current
+ * linespeed and MF configuration.
  *
- * @return u16
+ * @bp:		driver handle
  */
 u16 bnx2x_get_mf_speed(struct bnx2x *bp);
 
 /**
- * MSI-X slowpath interrupt handler
+ * bnx2x_msix_sp_int - MSI-X slowpath interrupt handler
  *
- * @param irq
- * @param dev_instance
- *
- * @return irqreturn_t
+ * @irq:		irq number
+ * @dev_instance:	private instance
  */
 irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance);
 
 /**
- * non MSI-X interrupt handler
- *
- * @param irq
- * @param dev_instance
+ * bnx2x_interrupt - non MSI-X interrupt handler
  *
- * @return irqreturn_t
+ * @irq:		irq number
+ * @dev_instance:	private instance
  */
 irqreturn_t bnx2x_interrupt(int irq, void *dev_instance);
 #ifdef BCM_CNIC
 
 /**
- * Send command to cnic driver
+ * bnx2x_cnic_notify - send command to cnic driver
  *
- * @param bp
- * @param cmd
+ * @bp:		driver handle
+ * @cmd:	command
  */
 int bnx2x_cnic_notify(struct bnx2x *bp, int cmd);
 
 /**
- * Provides cnic information for proper interrupt handling
+ * bnx2x_setup_cnic_irq_info - provides cnic information for proper
+ * interrupt handling
  *
- * @param bp
+ * @bp:		driver handle
  */
 void bnx2x_setup_cnic_irq_info(struct bnx2x *bp);
 #endif
 
 /**
- * Enable HW interrupts.
+ * bnx2x_int_enable - enable HW interrupts.
  *
- * @param bp
+ * @bp:		driver handle
  */
 void bnx2x_int_enable(struct bnx2x *bp);
 
 /**
- * Disable interrupts. This function ensures that there are no
- * ISRs or SP DPCs (sp_task) are running after it returns.
+ * bnx2x_int_disable_sync - disable interrupts.
+ *
+ * @bp:		driver handle
+ * @disable_hw:	true, disable HW interrupts.
  *
- * @param bp
- * @param disable_hw if true, disable HW interrupts.
+ * This function ensures that there are no
+ * ISRs or SP DPCs (sp_task) are running after it returns.
  */
 void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw);
 
 /**
- * Loads device firmware
- *
- * @param bp
+ * bnx2x_init_firmware - loads device firmware
  *
- * @return int
+ * @bp:		driver handle
  */
 int bnx2x_init_firmware(struct bnx2x *bp);
 
 /**
- * Init HW blocks according to current initialization stage:
+ * bnx2x_init_hw - init HW blocks according to current initialization stage:
  * COMMON, PORT or FUNCTION.
  *
- * @param bp
- * @param load_code: COMMON, PORT or FUNCTION
- *
- * @return int
+ * @bp:		driver handle
+ * @load_code:	COMMON, PORT or FUNCTION
  */
 int bnx2x_init_hw(struct bnx2x *bp, u32 load_code);
 
 /**
- * Init driver internals:
+ * bnx2x_nic_init - init driver internals.
  *  - rings
  *  - status blocks
  *  - etc.
  *
- * @param bp
- * @param load_code COMMON, PORT or FUNCTION
+ * @bp:		driver handle
+ * @load_code:	COMMON, PORT or FUNCTION
  */
 void bnx2x_nic_init(struct bnx2x *bp, u32 load_code);
 
 /**
- * Allocate driver's memory.
- *
- * @param bp
+ * bnx2x_alloc_mem - allocate driver's memory.
  *
- * @return int
+ * @bp:		driver handle
  */
 int bnx2x_alloc_mem(struct bnx2x *bp);
 
 /**
- * Release driver's memory.
+ * bnx2x_free_mem - release driver's memory.
  *
- * @param bp
+ * @bp:		driver handle
  */
 void bnx2x_free_mem(struct bnx2x *bp);
 
 /**
- * Setup eth Client.
+ * bnx2x_setup_client - setup eth client.
  *
- * @param bp
- * @param fp
- * @param is_leading
- *
- * @return int
+ * @bp:		driver handle
+ * @fp:		pointer to fastpath structure
+ * @is_leading:	boolean
  */
 int bnx2x_setup_client(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		       int is_leading);
 
 /**
- * Set number of queues according to mode
- *
- * @param bp
+ * bnx2x_set_num_queues - set number of queues according to mode.
  *
+ * @bp:		driver handle
  */
 void bnx2x_set_num_queues(struct bnx2x *bp);
 
 /**
- * Cleanup chip internals:
+ * bnx2x_chip_cleanup - cleanup chip internals:
  * - Cleanup MAC configuration.
  * - Close clients.
  * - etc.
  *
- * @param bp
- * @param unload_mode
+ * @bp:			driver handle
+ * @unload_mode:	COMMON, PORT, FUNCTION
  */
 void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode);
 
 /**
- * Acquire HW lock.
+ * bnx2x_acquire_hw_lock - acquire HW lock.
  *
- * @param bp
- * @param resource Resource bit which was locked
- *
- * @return int
+ * @bp:		driver handle
+ * @resource:	resource bit which was locked
  */
 int bnx2x_acquire_hw_lock(struct bnx2x *bp, u32 resource);
 
 /**
- * Release HW lock.
- *
- * @param bp driver handle
- * @param resource Resource bit which was locked
+ * bnx2x_release_hw_lock - release HW lock.
  *
- * @return int
+ * @bp:		driver handle
+ * @resource:	resource bit which was locked
  */
 int bnx2x_release_hw_lock(struct bnx2x *bp, u32 resource);
 
 /**
- * Configure eth MAC address in the HW according to the value in
- * netdev->dev_addr.
+ * bnx2x_set_eth_mac - configure eth MAC address in the HW
+ * according to the value in netdev->dev_addr.
  *
- * @param bp driver handle
- * @param set
+ * @bp:		driver handle
+ * @set:	set or clear
  */
 void bnx2x_set_eth_mac(struct bnx2x *bp, int set);
 
 #ifdef BCM_CNIC
 /**
- * Set/Clear FIP MAC(s) at the next enties in the CAM after the ETH
- * MAC(s). This function will wait until the ramdord completion
- * returns.
+ * bnx2x_set_fip_eth_mac_addr - Set/Clear FIP MAC(s) at the next enties
+ * in the CAM after the ETH MAC(s).
  *
- * @param bp driver handle
- * @param set set or clear the CAM entry
+ * @bp:		driver handle
+ * @set:	set or clear the CAM entry
  *
- * @return 0 if cussess, -ENODEV if ramrod doesn't return.
+ * This function will wait until the ramdord completion returns.
+ * Return 0 if cussess, -ENODEV if ramrod doesn't return.
  */
 int bnx2x_set_fip_eth_mac_addr(struct bnx2x *bp, int set);
 
 /**
- * Set/Clear ALL_ENODE mcast MAC.
+ * bnx2x_set_all_enode_macs - Set/Clear ALL_ENODE mcast MAC.
  *
- * @param bp
- * @param set
- *
- * @return int
+ * @bp:		driver handle
+ * @set:	set or clear
  */
 int bnx2x_set_all_enode_macs(struct bnx2x *bp, int set);
 #endif
 
 /**
- * Set MAC filtering configurations.
+ * bnx2x_set_rx_mode - set MAC filtering configurations.
  *
- * @remarks called with netif_tx_lock from dev_mcast.c
+ * @dev:	netdevice
  *
- * @param dev net_device
+ * called with netif_tx_lock from dev_mcast.c
  */
 void bnx2x_set_rx_mode(struct net_device *dev);
 
 /**
- * Configure MAC filtering rules in a FW.
+ * bnx2x_set_storm_rx_mode - configure MAC filtering rules in a FW.
  *
- * @param bp driver handle
+ * @bp:		driver handle
  */
 void bnx2x_set_storm_rx_mode(struct bnx2x *bp);
 
@@ -324,63 +304,60 @@ bool bnx2x_reset_is_done(struct bnx2x *bp);
 void bnx2x_disable_close_the_gate(struct bnx2x *bp);
 
 /**
- * Perform statistics handling according to event
+ * bnx2x_stats_handle - perform statistics handling according to event.
  *
- * @param bp driver handle
- * @param event bnx2x_stats_event
+ * @bp:		driver handle
+ * @event:	bnx2x_stats_event
  */
 void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event);
 
 /**
- * Handle ramrods completion
+ * bnx2x_sp_event - handle ramrods completion
  *
- * @param fp fastpath handle for the event
- * @param rr_cqe eth_rx_cqe
+ * @fp:		fastpath handle for the event
+ * @rr_cqe:	eth_rx_cqe
  */
 void bnx2x_sp_event(struct bnx2x_fastpath *fp, union eth_rx_cqe *rr_cqe);
 
 /**
- * Init/halt function before/after sending
+ * bnx2x_func_start - Init/halt function before/after sending
  * CLIENT_SETUP/CFC_DEL for the first/last client.
  *
- * @param bp
- *
- * @return int
+ * @bp:		driver handle
  */
 int bnx2x_func_start(struct bnx2x *bp);
 
 /**
- * Prepare ILT configurations according to current driver
+ * bnx2x_ilt_set_info - prepare ILT configurations according to current driver
  * parameters.
  *
- * @param bp
+ * @bp:		driver handle
  */
 void bnx2x_ilt_set_info(struct bnx2x *bp);
 
 /**
- * Inintialize dcbx protocol
+ * bnx2x_dcbx_init - initialize dcbx protocol
  *
- * @param bp
+ * @bp:		driver handle
  */
 void bnx2x_dcbx_init(struct bnx2x *bp);
 
 /**
- * Set power state to the requested value. Currently only D0 and
- * D3hot are supported.
+ * bnx2x_set_power_state - set power state to the requested value.
  *
- * @param bp
- * @param state D0 or D3hot
+ * @bp:		driver handle
+ * @state:	required state D0 or D3hot
  *
- * @return int
+ * Currently only D0 and D3hot are supported.
  */
 int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state);
 
 /**
- * Updates MAX part of MF configuration in HW
+ * bnx2x_update_max_mf_config - update MAX part of MF configuration in HW
  * (if required)
  *
- * @param bp
- * @param value
+ * @bp:		driver handle
+ * @value:	new value
  */
 void bnx2x_update_max_mf_config(struct bnx2x *bp, u32 value);
 
@@ -420,51 +397,49 @@ void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw);
 void bnx2x_netif_start(struct bnx2x *bp);
 
 /**
- * Fill msix_table, request vectors, update num_queues according
- * to number of available vectors
+ * bnx2x_enable_msix -fill msix_table, request vectors, update num_queues
+ * according to number of available vectors
  *
- * @param bp
- *
- * @return int
+ * @bp:		driver handle
  */
 int bnx2x_enable_msix(struct bnx2x *bp);
 
 /**
- * Request msi mode from OS, updated internals accordingly
- *
- * @param bp
+ * bnx2x_enable_msi - request msi mode from OS, updated internals accordingly
  *
- * @return int
+ * @bp:		driver handle
  */
 int bnx2x_enable_msi(struct bnx2x *bp);
 
 /**
- * NAPI callback
+ * bnx2x_poll - NAPI callback
  *
- * @param napi
- * @param budget
+ * @napi:	napi structure
+ * @budget:
  *
- * @return int
  */
 int bnx2x_poll(struct napi_struct *napi, int budget);
 
 /**
- * Allocate/release memories outsize main driver structure
+ * bnx2x_alloc_mem_bp - allocate memories outsize main driver structure
  *
- * @param bp
- *
- * @return int
+ * @bp:		driver handle
  */
 int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp);
+
+/**
+ * bnx2x_free_mem_bp - release memories outsize main driver structure
+ *
+ * @bp:		driver handle
+ */
 void bnx2x_free_mem_bp(struct bnx2x *bp);
 
 /**
- * Change mtu netdev callback
+ * bnx2x_change_mtu - change mtu netdev callback
  *
- * @param dev
- * @param new_mtu
+ * @dev:	net device
+ * @new_mtu:	requested mtu
  *
- * @return int
  */
 int bnx2x_change_mtu(struct net_device *dev, int new_mtu);
 
@@ -472,29 +447,12 @@ u32 bnx2x_fix_features(struct net_device *dev, u32 features);
 int bnx2x_set_features(struct net_device *dev, u32 features);
 
 /**
- * tx timeout netdev callback
- *
- * @param dev
- * @param new_mtu
+ * bnx2x_tx_timeout - tx timeout netdev callback
  *
- * @return int
+ * @dev:	net device
  */
 void bnx2x_tx_timeout(struct net_device *dev);
 
-#ifdef BCM_VLAN
-/**
- * vlan rx register netdev callback
- *
- * @param dev
- * @param new_mtu
- *
- * @return int
- */
-void bnx2x_vlan_rx_register(struct net_device *dev,
-				   struct vlan_group *vlgrp);
-
-#endif
-
 static inline void bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
 {
 	barrier(); /* status block is written to by the chip */
@@ -745,7 +703,7 @@ static inline int bnx2x_has_rx_work(struct bnx2x_fastpath *fp)
 /**
  * disables tx from stack point of view
  *
- * @param bp
+ * @bp:		driver handle
  */
 static inline void bnx2x_tx_disable(struct bnx2x *bp)
 {
@@ -1149,12 +1107,11 @@ void bnx2x_acquire_phy_lock(struct bnx2x *bp);
 void bnx2x_release_phy_lock(struct bnx2x *bp);
 
 /**
- * Extracts MAX BW part from MF configuration.
+ * bnx2x_extract_max_cfg - extract MAX BW part from MF configuration.
  *
- * @param bp
- * @param mf_cfg
+ * @bp:		driver handle
+ * @mf_cfg:	MF configuration
  *
- * @return u16
  */
 static inline u16 bnx2x_extract_max_cfg(struct bnx2x *bp, u32 mf_cfg)
 {
diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/bnx2x/bnx2x_dcb.c
index 3396ff2..0f83092 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/bnx2x/bnx2x_dcb.c
@@ -1079,12 +1079,6 @@ static void bnx2x_dcbx_get_num_pg_traf_type(struct bnx2x *bp,
 	}
 }
 
-
-/*******************************************************************************
- * Description: single priority group
- *
- * Return:
- ******************************************************************************/
 static void bnx2x_dcbx_ets_disabled_entry_data(struct bnx2x *bp,
 					       struct cos_help_data *cos_data,
 					       u32 pri_join_mask)
@@ -1097,11 +1091,6 @@ static void bnx2x_dcbx_ets_disabled_entry_data(struct bnx2x *bp,
 	cos_data->num_of_cos = 1;
 }
 
-/*******************************************************************************
- * Description: updating the cos bw
- *
- * Return:
- ******************************************************************************/
 static inline void bnx2x_dcbx_add_to_cos_bw(struct bnx2x *bp,
 					    struct cos_entry_help_data *data,
 					    u8 pg_bw)
@@ -1112,11 +1101,6 @@ static inline void bnx2x_dcbx_add_to_cos_bw(struct bnx2x *bp,
 		data->cos_bw += pg_bw;
 }
 
-/*******************************************************************************
- * Description: single priority group
- *
- * Return:
- ******************************************************************************/
 static void bnx2x_dcbx_separate_pauseable_from_non(struct bnx2x *bp,
 			struct cos_help_data *cos_data,
 			u32 *pg_pri_orginal_spread,
@@ -1369,11 +1353,6 @@ static void bnx2x_dcbx_two_pg_to_cos_params(
 	}
 }
 
-/*******************************************************************************
- * Description: Still
- *
- * Return:
- ******************************************************************************/
 static void bnx2x_dcbx_three_pg_to_cos_params(
 			      struct bnx2x		*bp,
 			      struct pg_help_data	*pg_help_data,
@@ -1561,11 +1540,6 @@ static void bnx2x_dcbx_get_ets_pri_pg_tbl(struct bnx2x *bp,
 	}
 }
 
-/*******************************************************************************
- * Description: Fill pfc_config struct that will be sent in DCBX start ramrod
- *
- * Return:
- ******************************************************************************/
 static void bnx2x_pfc_fw_struct_e2(struct bnx2x *bp)
 {
 	struct flow_control_configuration   *pfc_fw_cfg = NULL;
diff --git a/drivers/net/bnx2x/bnx2x_dcb.h b/drivers/net/bnx2x/bnx2x_dcb.h
index bb6e9a5b..bed369d 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/bnx2x/bnx2x_dcb.h
@@ -61,9 +61,6 @@ struct bnx2x_dcbx_port_params {
 #define BNX2X_DCBX_OVERWRITE_SETTINGS_ENABLE		1
 #define BNX2X_DCBX_OVERWRITE_SETTINGS_INVALID	(BNX2X_DCBX_CONFIG_INV_VALUE)
 
-/*******************************************************************************
- * LLDP protocol configuration parameters.
- ******************************************************************************/
 struct bnx2x_config_lldp_params {
 	u32 overwrite_settings;
 	u32 msg_tx_hold;
@@ -83,9 +80,6 @@ struct bnx2x_admin_priority_app_table {
 		u32 app_id;
 };
 
-/*******************************************************************************
- * DCBX protocol configuration parameters.
- ******************************************************************************/
 struct bnx2x_config_dcbx_params {
 	u32 overwrite_settings;
 	u32 admin_dcbx_version;
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 974ef2b..076e11f 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -385,7 +385,7 @@ u8 bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos)
 	return 0;
 }
 /******************************************************************/
-/*			ETS section				  */
+/*			PFC section				  */
 /******************************************************************/
 
 static void bnx2x_bmac2_get_pfc_stat(struct link_params *params,
@@ -1301,14 +1301,12 @@ static u8 bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 	return 0;
 }
 
-/*
- * get_emac_base
- *
- * @param cb
- * @param mdc_mdio_access
- * @param port
+/**
+ * bnx2x_get_emac_base - retrive emac base address
  *
- * @return u32
+ * @bp:			driver handle
+ * @mdc_mdio_access:	access type
+ * @port:		port id
  *
  * This function selects the MDC/MDIO access (through emac0 or
  * emac1) depend on the mdc_mdio_access, port, port swapped. Each
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 0c31b91..d6aa25e 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -6035,14 +6035,15 @@ static int bnx2x_func_stop(struct bnx2x *bp)
 }
 
 /**
- * Sets a MAC in a CAM for a few L2 Clients for E1x chips
+ * bnx2x_set_mac_addr_gen - set a MAC in a CAM for a few L2 Clients
+ * for E1x chips
  *
- * @param bp driver descriptor
- * @param set set or clear an entry (1 or 0)
- * @param mac pointer to a buffer containing a MAC
- * @param cl_bit_vec bit vector of clients to register a MAC for
- * @param cam_offset offset in a CAM to use
- * @param is_bcast is the set MAC a broadcast address (for E1 only)
+ * @bp:		driver handle
+ * @set:	set or clear an entry (1 or 0)
+ * @mac:	pointer to a buffer containing a MAC
+ * @cl_bit_vec:	bit vector of clients to register a MAC for
+ * @cam_offset:	offset in a CAM to use
+ * @is_bcast:	is the set MAC a broadcast address (for E1 only)
  */
 static void bnx2x_set_mac_addr_gen(struct bnx2x *bp, int set, const u8 *mac,
 				   u32 cl_bit_vec, u8 cam_offset,
@@ -6402,14 +6403,14 @@ void bnx2x_invalidate_e1h_mc_list(struct bnx2x *bp)
 
 #ifdef BCM_CNIC
 /**
- * Set iSCSI MAC(s) at the next enties in the CAM after the ETH
- * MAC(s). This function will wait until the ramdord completion
- * returns.
+ * bnx2x_set_iscsi_eth_mac_addr - set iSCSI MAC(s) at the next
+ * enties in the CAM after the ETH MAC(s).
  *
- * @param bp driver handle
- * @param set set or clear the CAM entry
+ * @bp:		driver handle
+ * @set:	set or clear the CAM entry
  *
- * @return 0 if cussess, -ENODEV if ramrod doesn't return.
+ * This function will wait until the ramdord completion returns.
+ * Return 0 if success, -ENODEV if ramrod doesn't return.
  */
 static int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
 {
@@ -6430,14 +6431,14 @@ static int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
 }
 
 /**
- * Set FCoE L2 MAC(s) at the next enties in the CAM after the
- * ETH MAC(s). This function will wait until the ramdord
- * completion returns.
+ * bnx2x_set_fip_eth_mac_addr - set FCoE L2 MAC(s) at the next enties
+ * in the CAM after the ETH MAC(s).
  *
- * @param bp driver handle
- * @param set set or clear the CAM entry
+ * @bp:		driver handle
+ * @set:	set or clear the CAM entry
  *
- * @return 0 if cussess, -ENODEV if ramrod doesn't return.
+ * This function will wait until the ramrod completion returns.
+ * Returns 0 if success, -ENODEV if ramrod doesn't return.
  */
 int bnx2x_set_fip_eth_mac_addr(struct bnx2x *bp, int set)
 {
@@ -6641,12 +6642,12 @@ static int bnx2x_setup_fw_client(struct bnx2x *bp,
 }
 
 /**
- * Configure interrupt mode according to current configuration.
- * In case of MSI-X it will also try to enable MSI-X.
+ * bnx2x_set_int_mode - configure interrupt mode according to
+ * current configuration.
  *
- * @param bp
+ * @bp:		driver handle
  *
- * @return int
+ * In case of MSI-X it will also try to enable MSI-X.
  */
 static int __devinit bnx2x_set_int_mode(struct bnx2x *bp)
 {
@@ -7244,10 +7245,12 @@ static void bnx2x_clp_reset_done(struct bnx2x *bp, u32 magic_val)
 }
 
 /**
- * Prepares for MCP reset: takes care of CLP configurations.
+ * bnx2x_reset_mcp_prep - prepare for MCP reset.
  *
- * @param bp
- * @param magic_val Old value of 'magic' bit.
+ * @bp:		driver handle
+ * @magic_val:	old value of 'magic' bit.
+ *
+ * Takes care of CLP configurations.
  */
 static void bnx2x_reset_mcp_prep(struct bnx2x *bp, u32 *magic_val)
 {
@@ -7272,10 +7275,11 @@ static void bnx2x_reset_mcp_prep(struct bnx2x *bp, u32 *magic_val)
 #define MCP_TIMEOUT      5000   /* 5 seconds (in ms) */
 #define MCP_ONE_TIMEOUT  100    /* 100 ms */
 
-/* Waits for MCP_ONE_TIMEOUT or MCP_ONE_TIMEOUT*10,
+/**
+ * bnx2x_mcp_wait_one - wait for MCP_ONE_TIMEOUT or MCP_ONE_TIMEOUT*10,
  * depending on the HW type.
  *
- * @param bp
+ * @bp:	driver handle
  */
 static inline void bnx2x_mcp_wait_one(struct bnx2x *bp)
 {
-- 
1.7.2.2





