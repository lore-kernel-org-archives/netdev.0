From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/2] ixgbe: remove unused functions
Date: Wed, 13 Oct 2010 01:20:34 -0700
Message-ID: <20101013081759.24491.46846.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Stephen Hemminger <shemminger@vyatta.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:52250
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753123Ab0JMIU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 04:20:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Remove functions that are declared, but not used in the driver.
This patch fixes warnings reported by `make namespacecheck`

Reported by Stephen Hemminger

CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c     |  147 -----------------------
 drivers/net/ixgbe/ixgbe_common.c    |   45 -------
 drivers/net/ixgbe/ixgbe_dcb.c       |  219 -----------------------------------
 drivers/net/ixgbe/ixgbe_dcb.h       |   18 ---
 drivers/net/ixgbe/ixgbe_dcb_82598.c |   59 ---------
 drivers/net/ixgbe/ixgbe_dcb_82598.h |    4 -
 drivers/net/ixgbe/ixgbe_dcb_82599.c |   57 ---------
 drivers/net/ixgbe/ixgbe_dcb_82599.h |    6 -
 8 files changed, 0 insertions(+), 555 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index e80657c..344c5d6 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1415,92 +1415,6 @@ s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 dst_addr)
 }
 
 /**
- *  ixgbe_atr_set_src_ipv6_82599 - Sets the source IPv6 address
- *  @input: input stream to modify
- *  @src_addr_1: the first 4 bytes of the IP address to load
- *  @src_addr_2: the second 4 bytes of the IP address to load
- *  @src_addr_3: the third 4 bytes of the IP address to load
- *  @src_addr_4: the fourth 4 bytes of the IP address to load
- **/
-s32 ixgbe_atr_set_src_ipv6_82599(struct ixgbe_atr_input *input,
-                                 u32 src_addr_1, u32 src_addr_2,
-                                 u32 src_addr_3, u32 src_addr_4)
-{
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET] = src_addr_4 & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 1] =
-	                                               (src_addr_4 >> 8) & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 2] =
-	                                              (src_addr_4 >> 16) & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 3] = src_addr_4 >> 24;
-
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 4] = src_addr_3 & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 5] =
-	                                               (src_addr_3 >> 8) & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 6] =
-	                                              (src_addr_3 >> 16) & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 7] = src_addr_3 >> 24;
-
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 8] = src_addr_2 & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 9] =
-	                                               (src_addr_2 >> 8) & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 10] =
-	                                              (src_addr_2 >> 16) & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 11] = src_addr_2 >> 24;
-
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 12] = src_addr_1 & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 13] =
-	                                               (src_addr_1 >> 8) & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 14] =
-	                                              (src_addr_1 >> 16) & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 15] = src_addr_1 >> 24;
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_set_dst_ipv6_82599 - Sets the destination IPv6 address
- *  @input: input stream to modify
- *  @dst_addr_1: the first 4 bytes of the IP address to load
- *  @dst_addr_2: the second 4 bytes of the IP address to load
- *  @dst_addr_3: the third 4 bytes of the IP address to load
- *  @dst_addr_4: the fourth 4 bytes of the IP address to load
- **/
-s32 ixgbe_atr_set_dst_ipv6_82599(struct ixgbe_atr_input *input,
-                                 u32 dst_addr_1, u32 dst_addr_2,
-                                 u32 dst_addr_3, u32 dst_addr_4)
-{
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET] = dst_addr_4 & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 1] =
-	                                               (dst_addr_4 >> 8) & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 2] =
-	                                              (dst_addr_4 >> 16) & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 3] = dst_addr_4 >> 24;
-
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 4] = dst_addr_3 & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 5] =
-	                                               (dst_addr_3 >> 8) & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 6] =
-	                                              (dst_addr_3 >> 16) & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 7] = dst_addr_3 >> 24;
-
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 8] = dst_addr_2 & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 9] =
-	                                               (dst_addr_2 >> 8) & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 10] =
-	                                              (dst_addr_2 >> 16) & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 11] = dst_addr_2 >> 24;
-
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 12] = dst_addr_1 & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 13] =
-	                                               (dst_addr_1 >> 8) & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 14] =
-	                                              (dst_addr_1 >> 16) & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 15] = dst_addr_1 >> 24;
-
-	return 0;
-}
-
-/**
  *  ixgbe_atr_set_src_port_82599 - Sets the source port
  *  @input: input stream to modify
  *  @src_port: the source port to load
@@ -1540,19 +1454,6 @@ s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input, u16 flex_byte)
 }
 
 /**
- *  ixgbe_atr_set_vm_pool_82599 - Sets the Virtual Machine pool
- *  @input: input stream to modify
- *  @vm_pool: the Virtual Machine pool to load
- **/
-s32 ixgbe_atr_set_vm_pool_82599(struct ixgbe_atr_input *input,
-                                u8 vm_pool)
-{
-	input->byte_stream[IXGBE_ATR_VM_POOL_OFFSET] = vm_pool;
-
-	return 0;
-}
-
-/**
  *  ixgbe_atr_set_l4type_82599 - Sets the layer 4 packet type
  *  @input: input stream to modify
  *  @l4type: the layer 4 type value to load
@@ -1645,41 +1546,6 @@ static s32 ixgbe_atr_get_src_ipv6_82599(struct ixgbe_atr_input *input,
 }
 
 /**
- *  ixgbe_atr_get_dst_ipv6_82599 - Gets the destination IPv6 address
- *  @input: input stream to search
- *  @dst_addr_1: the first 4 bytes of the IP address to load
- *  @dst_addr_2: the second 4 bytes of the IP address to load
- *  @dst_addr_3: the third 4 bytes of the IP address to load
- *  @dst_addr_4: the fourth 4 bytes of the IP address to load
- **/
-s32 ixgbe_atr_get_dst_ipv6_82599(struct ixgbe_atr_input *input,
-                                        u32 *dst_addr_1, u32 *dst_addr_2,
-                                        u32 *dst_addr_3, u32 *dst_addr_4)
-{
-	*dst_addr_1 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 12];
-	*dst_addr_1 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 13] << 8;
-	*dst_addr_1 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 14] << 16;
-	*dst_addr_1 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 15] << 24;
-
-	*dst_addr_2 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 8];
-	*dst_addr_2 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 9] << 8;
-	*dst_addr_2 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 10] << 16;
-	*dst_addr_2 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 11] << 24;
-
-	*dst_addr_3 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 4];
-	*dst_addr_3 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 5] << 8;
-	*dst_addr_3 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 6] << 16;
-	*dst_addr_3 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 7] << 24;
-
-	*dst_addr_4 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET];
-	*dst_addr_4 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 1] << 8;
-	*dst_addr_4 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 2] << 16;
-	*dst_addr_4 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 3] << 24;
-
-	return 0;
-}
-
-/**
  *  ixgbe_atr_get_src_port_82599 - Gets the source port
  *  @input: input stream to modify
  *  @src_port: the source port to load
@@ -1732,19 +1598,6 @@ static s32 ixgbe_atr_get_flex_byte_82599(struct ixgbe_atr_input *input,
 }
 
 /**
- *  ixgbe_atr_get_vm_pool_82599 - Gets the Virtual Machine pool
- *  @input: input stream to modify
- *  @vm_pool: the Virtual Machine pool to load
- **/
-s32 ixgbe_atr_get_vm_pool_82599(struct ixgbe_atr_input *input,
-                                       u8 *vm_pool)
-{
-	*vm_pool = input->byte_stream[IXGBE_ATR_VM_POOL_OFFSET];
-
-	return 0;
-}
-
-/**
  *  ixgbe_atr_get_l4type_82599 - Gets the layer 4 packet type
  *  @input: input stream to modify
  *  @l4type: the layer 4 type value to load
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 9595b1b..939e60f 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -2704,48 +2704,3 @@ s32 ixgbe_check_mac_link_generic(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
 
 	return 0;
 }
-
-/**
- *  ixgbe_get_wwn_prefix_generic - Get alternative WWNN/WWPN prefix from
- *  the EEPROM
- *  @hw: pointer to hardware structure
- *  @wwnn_prefix: the alternative WWNN prefix
- *  @wwpn_prefix: the alternative WWPN prefix
- *
- *  This function will read the EEPROM from the alternative SAN MAC address
- *  block to check the support for the alternative WWNN/WWPN prefix support.
- **/
-s32 ixgbe_get_wwn_prefix_generic(struct ixgbe_hw *hw, u16 *wwnn_prefix,
-                                 u16 *wwpn_prefix)
-{
-	u16 offset, caps;
-	u16 alt_san_mac_blk_offset;
-
-	/* clear output first */
-	*wwnn_prefix = 0xFFFF;
-	*wwpn_prefix = 0xFFFF;
-
-	/* check if alternative SAN MAC is supported */
-	hw->eeprom.ops.read(hw, IXGBE_ALT_SAN_MAC_ADDR_BLK_PTR,
-	                    &alt_san_mac_blk_offset);
-
-	if ((alt_san_mac_blk_offset == 0) ||
-	    (alt_san_mac_blk_offset == 0xFFFF))
-		goto wwn_prefix_out;
-
-	/* check capability in alternative san mac address block */
-	offset = alt_san_mac_blk_offset + IXGBE_ALT_SAN_MAC_ADDR_CAPS_OFFSET;
-	hw->eeprom.ops.read(hw, offset, &caps);
-	if (!(caps & IXGBE_ALT_SAN_MAC_ADDR_CAPS_ALTWWN))
-		goto wwn_prefix_out;
-
-	/* get the corresponding prefix for WWNN/WWPN */
-	offset = alt_san_mac_blk_offset + IXGBE_ALT_SAN_MAC_ADDR_WWNN_OFFSET;
-	hw->eeprom.ops.read(hw, offset, wwnn_prefix);
-
-	offset = alt_san_mac_blk_offset + IXGBE_ALT_SAN_MAC_ADDR_WWPN_OFFSET;
-	hw->eeprom.ops.read(hw, offset, wwpn_prefix);
-
-wwn_prefix_out:
-	return 0;
-}
diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
index 9aea4f0..8bb9ddb 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -34,98 +34,6 @@
 #include "ixgbe_dcb_82599.h"
 
 /**
- * ixgbe_dcb_config - Struct containing DCB settings.
- * @dcb_config: Pointer to DCB config structure
- *
- * This function checks DCB rules for DCB settings.
- * The following rules are checked:
- * 1. The sum of bandwidth percentages of all Bandwidth Groups must total 100%.
- * 2. The sum of bandwidth percentages of all Traffic Classes within a Bandwidth
- *    Group must total 100.
- * 3. A Traffic Class should not be set to both Link Strict Priority
- *    and Group Strict Priority.
- * 4. Link strict Bandwidth Groups can only have link strict traffic classes
- *    with zero bandwidth.
- */
-s32 ixgbe_dcb_check_config(struct ixgbe_dcb_config *dcb_config)
-{
-	struct tc_bw_alloc *p;
-	s32 ret_val = 0;
-	u8 i, j, bw = 0, bw_id;
-	u8 bw_sum[2][MAX_BW_GROUP];
-	bool link_strict[2][MAX_BW_GROUP];
-
-	memset(bw_sum, 0, sizeof(bw_sum));
-	memset(link_strict, 0, sizeof(link_strict));
-
-	/* First Tx, then Rx */
-	for (i = 0; i < 2; i++) {
-		/* Check each traffic class for rule violation */
-		for (j = 0; j < MAX_TRAFFIC_CLASS; j++) {
-			p = &dcb_config->tc_config[j].path[i];
-
-			bw = p->bwg_percent;
-			bw_id = p->bwg_id;
-
-			if (bw_id >= MAX_BW_GROUP) {
-				ret_val = DCB_ERR_CONFIG;
-				goto err_config;
-			}
-			if (p->prio_type == prio_link) {
-				link_strict[i][bw_id] = true;
-				/* Link strict should have zero bandwidth */
-				if (bw) {
-					ret_val = DCB_ERR_LS_BW_NONZERO;
-					goto err_config;
-				}
-			} else if (!bw) {
-				/*
-				 * Traffic classes without link strict
-				 * should have non-zero bandwidth.
-				 */
-				ret_val = DCB_ERR_TC_BW_ZERO;
-				goto err_config;
-			}
-			bw_sum[i][bw_id] += bw;
-		}
-
-		bw = 0;
-
-		/* Check each bandwidth group for rule violation */
-		for (j = 0; j < MAX_BW_GROUP; j++) {
-			bw += dcb_config->bw_percentage[i][j];
-			/*
-			 * Sum of bandwidth percentages of all traffic classes
-			 * within a Bandwidth Group must total 100 except for
-			 * link strict group (zero bandwidth).
-			 */
-			if (link_strict[i][j]) {
-				if (bw_sum[i][j]) {
-					/*
-					 * Link strict group should have zero
-					 * bandwidth.
-					 */
-					ret_val = DCB_ERR_LS_BWG_NONZERO;
-					goto err_config;
-				}
-			} else if (bw_sum[i][j] != BW_PERCENT &&
-				   bw_sum[i][j] != 0) {
-				ret_val = DCB_ERR_TC_BW;
-				goto err_config;
-			}
-		}
-
-		if (bw != BW_PERCENT) {
-			ret_val = DCB_ERR_BW_GROUP;
-			goto err_config;
-		}
-	}
-
-err_config:
-	return ret_val;
-}
-
-/**
  * ixgbe_dcb_calculate_tc_credits - Calculates traffic class credits
  * @ixgbe_dcb_config: Struct containing DCB settings.
  * @direction: Configuring either Tx or Rx.
@@ -203,133 +111,6 @@ out:
 }
 
 /**
- * ixgbe_dcb_get_tc_stats - Returns status of each traffic class
- * @hw: pointer to hardware structure
- * @stats: pointer to statistics structure
- * @tc_count:  Number of elements in bwg_array.
- *
- * This function returns the status data for each of the Traffic Classes in use.
- */
-s32 ixgbe_dcb_get_tc_stats(struct ixgbe_hw *hw, struct ixgbe_hw_stats *stats,
-                           u8 tc_count)
-{
-	s32 ret = 0;
-	if (hw->mac.type == ixgbe_mac_82598EB)
-		ret = ixgbe_dcb_get_tc_stats_82598(hw, stats, tc_count);
-	else if (hw->mac.type == ixgbe_mac_82599EB)
-		ret = ixgbe_dcb_get_tc_stats_82599(hw, stats, tc_count);
-	return ret;
-}
-
-/**
- * ixgbe_dcb_get_pfc_stats - Returns CBFC status of each traffic class
- * hw - pointer to hardware structure
- * stats - pointer to statistics structure
- * tc_count -  Number of elements in bwg_array.
- *
- * This function returns the CBFC status data for each of the Traffic Classes.
- */
-s32 ixgbe_dcb_get_pfc_stats(struct ixgbe_hw *hw, struct ixgbe_hw_stats *stats,
-                            u8 tc_count)
-{
-	s32 ret = 0;
-	if (hw->mac.type == ixgbe_mac_82598EB)
-		ret = ixgbe_dcb_get_pfc_stats_82598(hw, stats, tc_count);
-	else if (hw->mac.type == ixgbe_mac_82599EB)
-		ret = ixgbe_dcb_get_pfc_stats_82599(hw, stats, tc_count);
-	return ret;
-}
-
-/**
- * ixgbe_dcb_config_rx_arbiter - Config Rx arbiter
- * @hw: pointer to hardware structure
- * @dcb_config: pointer to ixgbe_dcb_config structure
- *
- * Configure Rx Data Arbiter and credits for each traffic class.
- */
-s32 ixgbe_dcb_config_rx_arbiter(struct ixgbe_hw *hw,
-                                struct ixgbe_dcb_config *dcb_config)
-{
-	s32 ret = 0;
-	if (hw->mac.type == ixgbe_mac_82598EB)
-		ret = ixgbe_dcb_config_rx_arbiter_82598(hw, dcb_config);
-	else if (hw->mac.type == ixgbe_mac_82599EB)
-		ret = ixgbe_dcb_config_rx_arbiter_82599(hw, dcb_config);
-	return ret;
-}
-
-/**
- * ixgbe_dcb_config_tx_desc_arbiter - Config Tx Desc arbiter
- * @hw: pointer to hardware structure
- * @dcb_config: pointer to ixgbe_dcb_config structure
- *
- * Configure Tx Descriptor Arbiter and credits for each traffic class.
- */
-s32 ixgbe_dcb_config_tx_desc_arbiter(struct ixgbe_hw *hw,
-                                     struct ixgbe_dcb_config *dcb_config)
-{
-	s32 ret = 0;
-	if (hw->mac.type == ixgbe_mac_82598EB)
-		ret = ixgbe_dcb_config_tx_desc_arbiter_82598(hw, dcb_config);
-	else if (hw->mac.type == ixgbe_mac_82599EB)
-		ret = ixgbe_dcb_config_tx_desc_arbiter_82599(hw, dcb_config);
-	return ret;
-}
-
-/**
- * ixgbe_dcb_config_tx_data_arbiter - Config Tx data arbiter
- * @hw: pointer to hardware structure
- * @dcb_config: pointer to ixgbe_dcb_config structure
- *
- * Configure Tx Data Arbiter and credits for each traffic class.
- */
-s32 ixgbe_dcb_config_tx_data_arbiter(struct ixgbe_hw *hw,
-                                     struct ixgbe_dcb_config *dcb_config)
-{
-	s32 ret = 0;
-	if (hw->mac.type == ixgbe_mac_82598EB)
-		ret = ixgbe_dcb_config_tx_data_arbiter_82598(hw, dcb_config);
-	else if (hw->mac.type == ixgbe_mac_82599EB)
-		ret = ixgbe_dcb_config_tx_data_arbiter_82599(hw, dcb_config);
-	return ret;
-}
-
-/**
- * ixgbe_dcb_config_pfc - Config priority flow control
- * @hw: pointer to hardware structure
- * @dcb_config: pointer to ixgbe_dcb_config structure
- *
- * Configure Priority Flow Control for each traffic class.
- */
-s32 ixgbe_dcb_config_pfc(struct ixgbe_hw *hw,
-                         struct ixgbe_dcb_config *dcb_config)
-{
-	s32 ret = 0;
-	if (hw->mac.type == ixgbe_mac_82598EB)
-		ret = ixgbe_dcb_config_pfc_82598(hw, dcb_config);
-	else if (hw->mac.type == ixgbe_mac_82599EB)
-		ret = ixgbe_dcb_config_pfc_82599(hw, dcb_config);
-	return ret;
-}
-
-/**
- * ixgbe_dcb_config_tc_stats - Config traffic class statistics
- * @hw: pointer to hardware structure
- *
- * Configure queue statistics registers, all queues belonging to same traffic
- * class uses a single set of queue statistics counters.
- */
-s32 ixgbe_dcb_config_tc_stats(struct ixgbe_hw *hw)
-{
-	s32 ret = 0;
-	if (hw->mac.type == ixgbe_mac_82598EB)
-		ret = ixgbe_dcb_config_tc_stats_82598(hw);
-	else if (hw->mac.type == ixgbe_mac_82599EB)
-		ret = ixgbe_dcb_config_tc_stats_82599(hw);
-	return ret;
-}
-
-/**
  * ixgbe_dcb_hw_config - Config and enable DCB
  * @hw: pointer to hardware structure
  * @dcb_config: pointer to ixgbe_dcb_config structure
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index 5caafd4..eb1059f 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -149,27 +149,9 @@ struct ixgbe_dcb_config {
 
 /* DCB driver APIs */
 
-/* DCB rule checking function.*/
-s32 ixgbe_dcb_check_config(struct ixgbe_dcb_config *config);
-
 /* DCB credits calculation */
 s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_dcb_config *, u8);
 
-/* DCB PFC functions */
-s32 ixgbe_dcb_config_pfc(struct ixgbe_hw *, struct ixgbe_dcb_config *g);
-s32 ixgbe_dcb_get_pfc_stats(struct ixgbe_hw *, struct ixgbe_hw_stats *, u8);
-
-/* DCB traffic class stats */
-s32 ixgbe_dcb_config_tc_stats(struct ixgbe_hw *);
-s32 ixgbe_dcb_get_tc_stats(struct ixgbe_hw *, struct ixgbe_hw_stats *, u8);
-
-/* DCB config arbiters */
-s32 ixgbe_dcb_config_tx_desc_arbiter(struct ixgbe_hw *,
-                                     struct ixgbe_dcb_config *);
-s32 ixgbe_dcb_config_tx_data_arbiter(struct ixgbe_hw *,
-                                     struct ixgbe_dcb_config *);
-s32 ixgbe_dcb_config_rx_arbiter(struct ixgbe_hw *, struct ixgbe_dcb_config *);
-
 /* DCB hw initialization */
 s32 ixgbe_dcb_hw_config(struct ixgbe_hw *, struct ixgbe_dcb_config *);
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index f0e9279..6e9c8bb 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -32,65 +32,6 @@
 #include "ixgbe_dcb_82598.h"
 
 /**
- * ixgbe_dcb_get_tc_stats_82598 - Return status data for each traffic class
- * @hw: pointer to hardware structure
- * @stats: pointer to statistics structure
- * @tc_count:  Number of elements in bwg_array.
- *
- * This function returns the status data for each of the Traffic Classes in use.
- */
-s32 ixgbe_dcb_get_tc_stats_82598(struct ixgbe_hw *hw,
-                                 struct ixgbe_hw_stats *stats,
-                                 u8 tc_count)
-{
-	int tc;
-
-	if (tc_count > MAX_TRAFFIC_CLASS)
-		return DCB_ERR_PARAM;
-
-	/* Statistics pertaining to each traffic class */
-	for (tc = 0; tc < tc_count; tc++) {
-		/* Transmitted Packets */
-		stats->qptc[tc] += IXGBE_READ_REG(hw, IXGBE_QPTC(tc));
-		/* Transmitted Bytes */
-		stats->qbtc[tc] += IXGBE_READ_REG(hw, IXGBE_QBTC(tc));
-		/* Received Packets */
-		stats->qprc[tc] += IXGBE_READ_REG(hw, IXGBE_QPRC(tc));
-		/* Received Bytes */
-		stats->qbrc[tc] += IXGBE_READ_REG(hw, IXGBE_QBRC(tc));
-	}
-
-	return 0;
-}
-
-/**
- * ixgbe_dcb_get_pfc_stats_82598 - Returns CBFC status data
- * @hw: pointer to hardware structure
- * @stats: pointer to statistics structure
- * @tc_count:  Number of elements in bwg_array.
- *
- * This function returns the CBFC status data for each of the Traffic Classes.
- */
-s32 ixgbe_dcb_get_pfc_stats_82598(struct ixgbe_hw *hw,
-                                  struct ixgbe_hw_stats *stats,
-                                  u8 tc_count)
-{
-	int tc;
-
-	if (tc_count > MAX_TRAFFIC_CLASS)
-		return DCB_ERR_PARAM;
-
-	for (tc = 0; tc < tc_count; tc++) {
-		/* Priority XOFF Transmitted */
-		stats->pxofftxc[tc] += IXGBE_READ_REG(hw, IXGBE_PXOFFTXC(tc));
-		/* Priority XOFF Received */
-		stats->pxoffrxc[tc] += IXGBE_READ_REG(hw, IXGBE_PXOFFRXC(tc));
-	}
-
-	return 0;
-}
-
-/**
  * ixgbe_dcb_config_packet_buffers_82598 - Configure packet buffers
  * @hw: pointer to hardware structure
  * @dcb_config: pointer to ixgbe_dcb_config structure
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.h b/drivers/net/ixgbe/ixgbe_dcb_82598.h
index cc728fa..def907f 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.h
@@ -72,13 +72,9 @@
 
 /* DCB PFC functions */
 s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *, struct ixgbe_dcb_config *);
-s32 ixgbe_dcb_get_pfc_stats_82598(struct ixgbe_hw *, struct ixgbe_hw_stats *,
-                                  u8);
 
 /* DCB traffic class stats */
 s32 ixgbe_dcb_config_tc_stats_82598(struct ixgbe_hw *);
-s32 ixgbe_dcb_get_tc_stats_82598(struct ixgbe_hw *, struct ixgbe_hw_stats *,
-                                 u8);
 
 /* DCB config arbiters */
 s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index 25b02fb..1364718 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -31,63 +31,6 @@
 #include "ixgbe_dcb_82599.h"
 
 /**
- * ixgbe_dcb_get_tc_stats_82599 - Returns status for each traffic class
- * @hw: pointer to hardware structure
- * @stats: pointer to statistics structure
- * @tc_count:  Number of elements in bwg_array.
- *
- * This function returns the status data for each of the Traffic Classes in use.
- */
-s32 ixgbe_dcb_get_tc_stats_82599(struct ixgbe_hw *hw,
-                                 struct ixgbe_hw_stats *stats,
-                                 u8 tc_count)
-{
-	int tc;
-
-	if (tc_count > MAX_TRAFFIC_CLASS)
-		return DCB_ERR_PARAM;
-	/* Statistics pertaining to each traffic class */
-	for (tc = 0; tc < tc_count; tc++) {
-		/* Transmitted Packets */
-		stats->qptc[tc] += IXGBE_READ_REG(hw, IXGBE_QPTC(tc));
-		/* Transmitted Bytes */
-		stats->qbtc[tc] += IXGBE_READ_REG(hw, IXGBE_QBTC(tc));
-		/* Received Packets */
-		stats->qprc[tc] += IXGBE_READ_REG(hw, IXGBE_QPRC(tc));
-		/* Received Bytes */
-		stats->qbrc[tc] += IXGBE_READ_REG(hw, IXGBE_QBRC(tc));
-	}
-
-	return 0;
-}
-
-/**
- * ixgbe_dcb_get_pfc_stats_82599 - Return CBFC status data
- * @hw: pointer to hardware structure
- * @stats: pointer to statistics structure
- * @tc_count:  Number of elements in bwg_array.
- *
- * This function returns the CBFC status data for each of the Traffic Classes.
- */
-s32 ixgbe_dcb_get_pfc_stats_82599(struct ixgbe_hw *hw,
-                                  struct ixgbe_hw_stats *stats,
-                                  u8 tc_count)
-{
-	int tc;
-
-	if (tc_count > MAX_TRAFFIC_CLASS)
-		return DCB_ERR_PARAM;
-	for (tc = 0; tc < tc_count; tc++) {
-		/* Priority XOFF Transmitted */
-		stats->pxofftxc[tc] += IXGBE_READ_REG(hw, IXGBE_PXOFFTXC(tc));
-		/* Priority XOFF Received */
-		stats->pxoffrxc[tc] += IXGBE_READ_REG(hw, IXGBE_PXOFFRXCNT(tc));
-	}
-
-	return 0;
-}
-
-/**
  * ixgbe_dcb_config_packet_buffers_82599 - Configure DCB packet buffers
  * @hw: pointer to hardware structure
  * @dcb_config: pointer to ixgbe_dcb_config structure
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ixgbe/ixgbe_dcb_82599.h
index 0f3f791..88819b2 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.h
@@ -101,15 +101,9 @@
 /* DCB PFC functions */
 s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
                                struct ixgbe_dcb_config *dcb_config);
-s32 ixgbe_dcb_get_pfc_stats_82599(struct ixgbe_hw *hw,
-                                  struct ixgbe_hw_stats *stats,
-                                  u8 tc_count);
 
 /* DCB traffic class stats */
 s32 ixgbe_dcb_config_tc_stats_82599(struct ixgbe_hw *hw);
-s32 ixgbe_dcb_get_tc_stats_82599(struct ixgbe_hw *hw,
-                                 struct ixgbe_hw_stats *stats,
-                                 u8 tc_count);
 
 /* DCB config arbiters */
 s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,

