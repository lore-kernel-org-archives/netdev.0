From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] virtchnl: convert to new macros
Date: Thu,  1 Jun 2017 14:38:32 -0700
Message-ID: <20170601213840.36286-7-jeffrey.t.kirsher@intel.com>
References: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:12134 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751050AbdFAVjA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 17:39:00 -0400
In-Reply-To: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As part of the conversion, change the arguments
to VF_IS_V1[01] macros and move them to virtchnl.h

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 6 +++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h | 3 ---
 include/linux/avf/virtchnl.h                       | 3 +++
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index d7fcc4ffa393..923026a255c0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1481,7 +1481,7 @@ static int i40e_vc_get_version_msg(struct i40e_vf *vf, u8 *msg)
 
 	vf->vf_ver = *(struct virtchnl_version_info *)msg;
 	/* VFs running the 1.0 API expect to get 1.0 back or they will cry. */
-	if (VF_IS_V10(vf))
+	if (VF_IS_V10(&vf->vf_ver))
 		info.minor = VIRTCHNL_VERSION_MINOR_NO_VF_CAPS;
 	return i40e_vc_send_msg_to_vf(vf, VIRTCHNL_OP_VERSION,
 				      I40E_SUCCESS, (u8 *)&info,
@@ -1521,7 +1521,7 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 		len = 0;
 		goto err;
 	}
-	if (VF_IS_V11(vf))
+	if (VF_IS_V11(&vf->vf_ver))
 		vf->driver_caps = *(u32 *)msg;
 	else
 		vf->driver_caps = VIRTCHNL_VF_OFFLOAD_L2 |
@@ -2557,7 +2557,7 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 	case VIRTCHNL_OP_RESET_VF:
 		break;
 	case VIRTCHNL_OP_GET_VF_RESOURCES:
-		if (VF_IS_V11(vf))
+		if (VF_IS_V11(&vf->vf_ver))
 			valid_len = sizeof(u32);
 		break;
 	case VIRTCHNL_OP_CONFIG_TX_QUEUE:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index b57ffffce141..1f4b0c504368 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -40,9 +40,6 @@
 #define I40E_VLAN_MASK			0xFFF
 #define I40E_PRIORITY_MASK		0x7000
 
-#define VF_IS_V10(_v) (((_v)->vf_ver.major == 1) && ((_v)->vf_ver.minor == 0))
-#define VF_IS_V11(_v) (((_v)->vf_ver.major == 1) && ((_v)->vf_ver.minor == 1))
-
 /* Various queue ctrls */
 enum i40e_queue_ctrl {
 	I40E_QUEUE_CTRL_UNKNOWN = 0,
diff --git a/include/linux/avf/virtchnl.h b/include/linux/avf/virtchnl.h
index a8b616121960..8ffa670c2ffd 100644
--- a/include/linux/avf/virtchnl.h
+++ b/include/linux/avf/virtchnl.h
@@ -123,6 +123,9 @@ struct virtchnl_version_info {
 	u32 minor;
 };
 
+#define VF_IS_V10(_v) (((_v)->major == 1) && ((_v)->minor == 0))
+#define VF_IS_V11(_ver) (((_ver)->major == 1) && ((_ver)->minor == 1))
+
 /* VIRTCHNL_OP_RESET_VF
  * VF sends this request to PF with no parameters
  * PF does NOT respond! VF driver must delay then poll VFGEN_RSTAT register
-- 
2.12.2
