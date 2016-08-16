From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/6] e1000e: fix PTP on e1000_pch_lpt variants
Date: Tue, 16 Aug 2016 13:40:11 -0700
Message-ID: <1471380014-134435-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471380014-134435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27840 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752831AbcHPUkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 16:40:17 -0400
In-Reply-To: <1471380014-134435-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index 3e11322..f3aaca7 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -5885,7 +5885,8 @@ const struct e1000_info e1000_pch_lpt_info = {
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
2.7.4
