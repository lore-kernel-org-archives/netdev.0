From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/17] fm10k: remove err_no reference in fm10k_mbx.c
Date: Tue, 16 Jun 2015 06:47:26 -0700
Message-ID: <1434462448-140563-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:62774 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756715AbbFPNrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 09:47:37 -0400
In-Reply-To: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The reference to err_no was left around after a previous code refactor.
We never use the value, and it doesn't seem to be used in side a hidden
macro reference. Discovered via cppcheck.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index 1b27383..1a4b526 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -1259,16 +1259,11 @@ static s32 fm10k_mbx_process_error(struct fm10k_hw *hw,
 				   struct fm10k_mbx_info *mbx)
 {
 	const u32 *hdr = &mbx->mbx_hdr;
-	s32 err_no;
 	u16 head;
 
 	/* we will need to pull all of the fields for verification */
 	head = FM10K_MSG_HDR_FIELD_GET(*hdr, HEAD);
 
-	/* we only have lower 10 bits of error number so add upper bits */
-	err_no = FM10K_MSG_HDR_FIELD_GET(*hdr, ERR_NO);
-	err_no |= ~FM10K_MSG_HDR_MASK(ERR_NO);
-
 	switch (mbx->state) {
 	case FM10K_STATE_OPEN:
 	case FM10K_STATE_DISCONNECT:
-- 
2.4.3
