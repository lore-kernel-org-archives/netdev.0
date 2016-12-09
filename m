From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH] i40e: don't truncate match_method assignment
Date: Fri,  9 Dec 2016 13:39:21 -0800
Message-ID: <20161209213921.26451-1-jacob.e.keller@intel.com>
Cc: Jeffrey Kirsher <jeffrey.t.kirsher@intel.com>,
        netdev@vger.kernel.org, Jacob Keller <jacob.e.keller@intel.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Bimmy Pujari <bimmy.pujari@intel.com>
To: Intel Wired LAN <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43815 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752030AbcLIVjY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Dec 2016 16:39:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The .match_method field is a u8, so we shouldn't be casting to a u16,
and because it is only one byte, we do not need to byte swap anything.
Just assign the value directly. This avoids issues on Big Endian
architectures which would have byte swapped and then incorrectly
truncated the value.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Bimmy Pujari <bimmy.pujari@intel.com>
---
Not sure if this was already in Jeff's queue, but since it's an obvious
fix for the issue found by Stephen, I thought I'd send it out now just
to make sure. Thanks for catching this, and sorry we didn't find the fix
earlier.

 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 69a51a4119d6..6ccf18464339 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2257,8 +2257,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			}
 			add_list[num_add].queue_number = 0;
 			/* set invalid match method for later detection */
-			add_list[num_add].match_method =
-				cpu_to_le16((u16)I40E_AQC_MM_ERR_NO_RES);
+			add_list[num_add].match_method = I40E_AQC_MM_ERR_NO_RES;
 			cmd_flags |= I40E_AQC_MACVLAN_ADD_PERFECT_MATCH;
 			add_list[num_add].flags = cpu_to_le16(cmd_flags);
 			num_add++;
-- 
2.11.0.rc2.152.g4d04e67
