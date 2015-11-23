From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] fm10k: Correct MTU for jumbo frames
Date: Mon, 23 Nov 2015 11:36:03 -0800
Message-ID: <1448307376-20063-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Matthew Vick <matthew.vick@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40449 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751699AbbKWTgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:21 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Based on hardware testing, the host interface supports up to 15368 bytes
as the maximum frame size. To determine the correct MTU, we subtract 8
for the internal switch tag, 14 for the L2 header, and 4 for the
appended FCS header, resulting in 15342 bytes of payload for our maximum
MTU on jumbo frames.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 1444020..48809e5 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -33,7 +33,7 @@
 #include "fm10k_pf.h"
 #include "fm10k_vf.h"
 
-#define FM10K_MAX_JUMBO_FRAME_SIZE	15358	/* Maximum supported size 15K */
+#define FM10K_MAX_JUMBO_FRAME_SIZE	15342	/* Maximum supported size 15K */
 
 #define MAX_QUEUES	FM10K_MAX_QUEUES_PF
 
-- 
2.5.0
