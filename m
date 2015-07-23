From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e/i40evf: add macros for virtual channel API version and device capability
Date: Thu, 23 Jul 2015 06:52:38 -0700
Message-ID: <1437659564-48822-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11915 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbbGWNw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:52:58 -0400
In-Reply-To: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Now that we've rolled the virtual channel API version to 1.1, add some
macros to test what version is being used by our partner in crime. For the
VF, add some macros to determine what our device capabilities are.

Change-ID: I79f6683d4c23bd76a8ad9fd492776fcc1208e1dc
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h | 3 +++
 drivers/net/ethernet/intel/i40evf/i40evf.h         | 9 +++++++++
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 09043c1..d254a5e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -42,6 +42,9 @@
 #define I40E_VLAN_MASK			0xFFF
 #define I40E_PRIORITY_MASK		0x7000
 
+#define VF_IS_V10(_v) (((_v)->vf_ver.major == 1) && ((_v)->vf_ver.minor == 0))
+#define VF_IS_V11(_v) (((_v)->vf_ver.major == 1) && ((_v)->vf_ver.minor == 1))
+
 /* Various queue ctrls */
 enum i40e_queue_ctrl {
 	I40E_QUEUE_CTRL_UNKNOWN = 0,
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index fea3b75..f3bcd05 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -249,8 +249,17 @@ struct i40evf_adapter {
 	bool netdev_registered;
 	bool link_up;
 	enum i40e_virtchnl_ops current_op;
+#define CLIENT_ENABLED(_a) ((_a)->vf_res->vf_offload_flags & \
+			    I40E_VIRTCHNL_VF_OFFLOAD_IWARP)
+#define RSS_AQ(_a) ((_a)->vf_res->vf_offload_flags & \
+		    I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ)
+#define VLAN_ALLOWED(_a) ((_a)->vf_res->vf_offload_flags & \
+			  I40E_VIRTCHNL_VF_OFFLOAD_VLAN)
 	struct i40e_virtchnl_vf_resource *vf_res; /* incl. all VSIs */
 	struct i40e_virtchnl_vsi_resource *vsi_res; /* our LAN VSI */
+	struct i40e_virtchnl_version_info pf_version;
+#define PF_IS_V11(_a) (((_a)->pf_version.major == 1) && \
+		       ((_a)->pf_version.minor == 1))
 	u16 msg_enable;
 	struct i40e_eth_stats current_stats;
 	struct i40e_vsi vsi;
-- 
2.4.3
