From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/4] e1000e: fix PTP on e1000_pch_lpt variants
Date: Sun, 30 Apr 2017 05:36:11 -0700
Message-ID: <20170430123614.67897-2-jeffrey.t.kirsher@intel.com>
References: <20170430123614.67897-1-jeffrey.t.kirsher@intel.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38083 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935553AbdD3MgT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 08:36:19 -0400
In-Reply-To: <20170430123614.67897-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Wilson <jarod@redhat.com>

I've got reports that the Intel I-218V NIC in Intel NUC5i5RYH systems used
as a PTP slave experiences random ~10 hour clock jumps, which are resolved
if the same workaround for the 82574 and 82583 is employed, so set the
appropriate flag2 in e1000_pch_lpt_info too.

Reported-by: Rupesh Patel <rupatel@redhat.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index f3aaca743ea3..72add037f07e 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -5865,7 +5865,8 @@ const struct e1000_info e1000_pch2_info = {
 				  | FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_APME_IN_WUC,
 	.flags2			= FLAG2_HAS_PHY_STATS
-				  | FLAG2_HAS_EEE,
+				  | FLAG2_HAS_EEE
+				  | FLAG2_CHECK_SYSTIM_OVERFLOW,
 	.pba			= 26,
 	.max_hw_frame_size	= 9022,
 	.get_variants		= e1000_get_variants_ich8lan,
-- 
2.12.2
