From: Tushar Dave <tushar.n.dave@oracle.com>
Subject: [PATCH] i40e: Fix incorrect pf->flags
Date: Fri, 19 May 2017 18:01:52 -0700
Message-ID: <1495242112-14835-1-git-send-email-tushar.n.dave@oracle.com>
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24260 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752010AbdETBCJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 21:02:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix bug introduced by 'commit 47994c119a36e ("i40e: remove
hw_disabled_flags in favor of using separate flag bits")' that
mistakenly wipes out pf->flags.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d5c9c9e..6b98d34 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8821,9 +8821,9 @@ static int i40e_sw_init(struct i40e_pf *pf)
 		    (pf->hw.aq.api_min_ver > 4))) {
 		/* Supported in FW API version higher than 1.4 */
 		pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
-		pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
+		pf->flags |= I40E_FLAG_HW_ATR_EVICT_CAPABLE;
 	} else {
-		pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
+		pf->flags |= I40E_FLAG_HW_ATR_EVICT_CAPABLE;
 	}
 
 	pf->eeprom_version = 0xDEAD;
-- 
1.9.1
