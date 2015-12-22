From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] fm10k: constify fm10k_mac_ops, fm10k_iov_ops and fm10k_info structures
Date: Tue, 22 Dec 2015 06:02:08 -0800
Message-ID: <1450792932-96015-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17834 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753512AbbLVODP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 09:03:15 -0500
In-Reply-To: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

These structures never change so declare them as const.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c   | 6 +++---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h   | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_type.h | 8 ++++----
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c   | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_vf.h   | 2 +-
 5 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 606c0f1..62ccebc 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1866,7 +1866,7 @@ static const struct fm10k_msg_data fm10k_msg_data_pf[] = {
 	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_tlv_msg_error),
 };
 
-static struct fm10k_mac_ops mac_ops_pf = {
+static const struct fm10k_mac_ops mac_ops_pf = {
 	.get_bus_info		= fm10k_get_bus_info_generic,
 	.reset_hw		= fm10k_reset_hw_pf,
 	.init_hw		= fm10k_init_hw_pf,
@@ -1889,7 +1889,7 @@ static struct fm10k_mac_ops mac_ops_pf = {
 	.read_systime		= fm10k_read_systime_pf,
 };
 
-static struct fm10k_iov_ops iov_ops_pf = {
+static const struct fm10k_iov_ops iov_ops_pf = {
 	.assign_resources		= fm10k_iov_assign_resources_pf,
 	.configure_tc			= fm10k_iov_configure_tc_pf,
 	.assign_int_moderator		= fm10k_iov_assign_int_moderator_pf,
@@ -1908,7 +1908,7 @@ static s32 fm10k_get_invariants_pf(struct fm10k_hw *hw)
 	return fm10k_sm_mbx_init(hw, &hw->mbx, fm10k_msg_data_pf);
 }
 
-struct fm10k_info fm10k_pf_info = {
+const struct fm10k_info fm10k_pf_info = {
 	.mac		= fm10k_mac_pf,
 	.get_invariants	= fm10k_get_invariants_pf,
 	.mac_ops	= &mac_ops_pf,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
index 3378592..b2d96b4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
@@ -133,5 +133,5 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *, u32 **,
 s32 fm10k_iov_msg_lport_state_pf(struct fm10k_hw *, u32 **,
 				 struct fm10k_mbx_info *);
 
-extern struct fm10k_info fm10k_pf_info;
+extern const struct fm10k_info fm10k_pf_info;
 #endif /* _FM10K_PF_H */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index 098883d..bc27c75 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -660,10 +660,10 @@ enum fm10k_devices {
 };
 
 struct fm10k_info {
-	enum fm10k_mac_type	mac;
-	s32			(*get_invariants)(struct fm10k_hw *);
-	struct fm10k_mac_ops	*mac_ops;
-	struct fm10k_iov_ops	*iov_ops;
+	enum fm10k_mac_type		mac;
+	s32				(*get_invariants)(struct fm10k_hw *);
+	const struct fm10k_mac_ops	*mac_ops;
+	const struct fm10k_iov_ops	*iov_ops;
 };
 
 struct fm10k_hw {
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index 38219f5..91f8d73 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -562,7 +562,7 @@ static const struct fm10k_msg_data fm10k_msg_data_vf[] = {
 	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_tlv_msg_error),
 };
 
-static struct fm10k_mac_ops mac_ops_vf = {
+static const struct fm10k_mac_ops mac_ops_vf = {
 	.get_bus_info		= fm10k_get_bus_info_generic,
 	.reset_hw		= fm10k_reset_hw_vf,
 	.init_hw		= fm10k_init_hw_vf,
@@ -590,7 +590,7 @@ static s32 fm10k_get_invariants_vf(struct fm10k_hw *hw)
 	return fm10k_pfvf_mbx_init(hw, &hw->mbx, fm10k_msg_data_vf, 0);
 }
 
-struct fm10k_info fm10k_vf_info = {
+const struct fm10k_info fm10k_vf_info = {
 	.mac		= fm10k_mac_vf,
 	.get_invariants	= fm10k_get_invariants_vf,
 	.mac_ops	= &mac_ops_vf,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.h b/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
index 06a99d7..c4439f1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
@@ -74,5 +74,5 @@ extern const struct fm10k_tlv_attr fm10k_1588_msg_attr[];
 #define FM10K_VF_MSG_1588_HANDLER(func) \
 	FM10K_MSG_HANDLER(FM10K_VF_MSG_ID_1588, fm10k_1588_msg_attr, func)
 
-extern struct fm10k_info fm10k_vf_info;
+extern const struct fm10k_info fm10k_vf_info;
 #endif /* _FM10K_VF_H */
-- 
2.5.0
