From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/17] fm10k: update comment regarding reserved bits check
Date: Wed, 20 Apr 2016 23:09:25 -0700
Message-ID: <1461218969-68578-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8320 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbcDUGJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:35 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The original comment may be read incorrectly as referring to checking
the *entire* length is zero. However, it merely checks only the reserved
bits of both length and reserved in a small amount of code. Update the
comment to indicate this is a clever trick and clearly spell out that it
only checks the reserve bits.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index 801238d..0440706 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -188,7 +188,7 @@ static s32 fm10k_update_vlan_vf(struct fm10k_hw *hw, u32 vid, u8 vsi, bool set)
 	if (vsi)
 		return FM10K_ERR_PARAM;
 
-	/* verify upper 4 bits of vid and length are 0 */
+	/* clever trick to verify reserved bits in both vid and length */
 	if ((vid << 16 | vid) >> 28)
 		return FM10K_ERR_PARAM;
 
-- 
2.5.5
