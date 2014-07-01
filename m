From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40e: Correct mask assignment value
Date: Tue,  1 Jul 2014 04:35:01 -0700
Message-ID: <1404214511-26868-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7330 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757759AbaGALfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 07:35:16 -0400
In-Reply-To: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

Make mask value of all 1s.  Value of -1 can't be used for u32 type.

Change-ID: I49d58b77639939fe7447a229dbf1f4a1bf7419ce
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
index 5a603a5..0d74b46 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
@@ -858,7 +858,7 @@ static void i40e_write_dword(u8 *hmc_bits,
 	if (ce_info->width < 32)
 		mask = ((u32)1 << ce_info->width) - 1;
 	else
-		mask = -1;
+		mask = 0xFFFFFFFF;
 
 	/* don't swizzle the bits until after the mask because the mask bits
 	 * will be in a different bit position on big endian machines
@@ -910,7 +910,7 @@ static void i40e_write_qword(u8 *hmc_bits,
 	if (ce_info->width < 64)
 		mask = ((u64)1 << ce_info->width) - 1;
 	else
-		mask = -1;
+		mask = 0xFFFFFFFFFFFFFFFF;
 
 	/* don't swizzle the bits until after the mask because the mask bits
 	 * will be in a different bit position on big endian machines
-- 
1.9.3
