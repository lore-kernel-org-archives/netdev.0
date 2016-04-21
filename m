From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/17] fm10k: Reset multicast mode when deleting lport
Date: Wed, 20 Apr 2016 23:09:26 -0700
Message-ID: <1461218969-68578-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55438 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675AbcDUGJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:36 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>

Deleting lport when multicast mode is configured to
FM10K_XCAST_MODE_ALLMULTI or FM10K_XCAST_MODE_PROMISC will result in
generating orphaned multicast-group entries in the switch manager.
Before deleting the lport, reset multicast mode to FM10K_XCAST_MODE_NONE
to flush out these multicast-group entries.

Signed-off-by: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 88d5acf..2105cb8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -488,6 +488,10 @@ static s32 fm10k_update_lport_state_pf(struct fm10k_hw *hw, u16 glort,
 	if (!fm10k_glort_valid_pf(hw, glort))
 		return FM10K_ERR_PARAM;
 
+	/* reset multicast mode if deleting lport */
+	if (!enable)
+		fm10k_update_xcast_mode_pf(hw, glort, FM10K_XCAST_MODE_NONE);
+
 	/* construct the lport message from the 2 pieces of data we have */
 	lport_msg = ((u32)count << 16) | glort;
 
-- 
2.5.5
