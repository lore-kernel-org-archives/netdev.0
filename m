From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] i40e: use more portable sign extension
Date: Thu,  5 Mar 2015 08:46:23 -0800
Message-ID: <1425573992-30955-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Kevin Scott <kevin.c.scott@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41895 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757896AbbCEQqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:52 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Use automatic sign extension by replacing 0xffff... constants
with ~(u64)0 or ~(u32)0.

Change-ID: I73cab4cd2611795bb12e00f0f24fafaaee07457c
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
index 4627588..0079ad7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
@@ -856,7 +856,7 @@ static void i40e_write_dword(u8 *hmc_bits,
 	if (ce_info->width < 32)
 		mask = ((u32)1 << ce_info->width) - 1;
 	else
-		mask = 0xFFFFFFFF;
+		mask = ~(u32)0;
 
 	/* don't swizzle the bits until after the mask because the mask bits
 	 * will be in a different bit position on big endian machines
@@ -908,7 +908,7 @@ static void i40e_write_qword(u8 *hmc_bits,
 	if (ce_info->width < 64)
 		mask = ((u64)1 << ce_info->width) - 1;
 	else
-		mask = 0xFFFFFFFFFFFFFFFF;
+		mask = ~(u64)0;
 
 	/* don't swizzle the bits until after the mask because the mask bits
 	 * will be in a different bit position on big endian machines
-- 
1.9.3
