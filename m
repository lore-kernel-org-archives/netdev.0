From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 24/25] fm10k: corrected VF multicast update
Date: Tue, 14 Apr 2015 16:51:10 -0700
Message-ID: <1429055471-401-25-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Ngai-Mint Kwan <ngai-mint.kwan@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62596 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755111AbbDNXva (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:30 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VFs were being improperly added to the switch's multicast group. The
error stems from the fact that incorrect arguments were passed to the
"update_mc_addr" function. It would seem to be a copy paste error since
the parameters are similar to the "update_uc_addr" function.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index a92b58d..891e218 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -329,6 +329,9 @@ static s32 fm10k_update_xc_addr_pf(struct fm10k_hw *hw, u16 glort,
 	struct fm10k_mac_update mac_update;
 	u32 msg[5];
 
+	/* clear set bit from VLAN ID */
+	vid &= ~FM10K_VLAN_CLEAR;
+
 	/* if glort or vlan are not valid return error */
 	if (!fm10k_glort_valid_pf(hw, glort) || vid >= FM10K_VLAN_TABLE_VID_MAX)
 		return FM10K_ERR_PARAM;
@@ -1250,8 +1253,8 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 		}
 
 		/* notify switch of request for new multicast address */
-		err = hw->mac.ops.update_mc_addr(hw, vf_info->glort, mac,
-						 !(vlan & FM10K_VLAN_CLEAR), 0);
+		err = hw->mac.ops.update_mc_addr(hw, vf_info->glort, mac, vlan,
+						 !(vlan & FM10K_VLAN_CLEAR));
 	}
 
 	return err;
-- 
1.9.3
