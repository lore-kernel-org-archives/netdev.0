From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/25] fm10k: Set PF queues to unlimited bandwidth during virtualization
Date: Tue, 14 Apr 2015 16:51:00 -0700
Message-ID: <1429055471-401-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Todd Russell <todd.a.russell@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20409 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754836AbbDNXvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:24 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When returning virtualization queues from the VF back to the PF, do not
retain the VF rate limiter.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Todd Russell <todd.a.russell@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 159cd84..a92b58d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -676,7 +676,8 @@ static s32 fm10k_iov_assign_resources_pf(struct fm10k_hw *hw, u16 num_vfs,
 	/* loop through unallocated rings assigning them back to PF */
 	for (i = FM10K_MAX_QUEUES_PF; i < vf_q_idx; i++) {
 		fm10k_write_reg(hw, FM10K_TXDCTL(i), 0);
-		fm10k_write_reg(hw, FM10K_TXQCTL(i), FM10K_TXQCTL_PF | vid);
+		fm10k_write_reg(hw, FM10K_TXQCTL(i), FM10K_TXQCTL_PF |
+				FM10K_TXQCTL_UNLIMITED_BW | vid);
 		fm10k_write_reg(hw, FM10K_RXQCTL(i), FM10K_RXQCTL_PF);
 	}
 
-- 
1.9.3
