From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/16] i40e: add check for null VSI
Date: Fri, 19 Feb 2016 01:54:05 -0800
Message-ID: <1455875651-21696-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Underwood <johnx.underwood@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5855 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427416AbcBSJyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 04:54:23 -0500
In-Reply-To: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Underwood <johnx.underwood@intel.com>

Return from i40e_vsi_reinit_setup() if vsi param is NULL.
This makes this code consistent with all the other code that
checks for NULL before using one of the VSI pointers accessed
with an indexed variable. (Indexed VSI pointers are
intentionally set to NULL in i40e_vsi_clear() and
i40e_remove().

Change-ID: I3bc8b909c70fd2439334eeae994d151f61480985
Signed-off-by: John Underwood <johnx.underwood@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 05def9f..3ff3e83 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9583,10 +9583,15 @@ vector_setup_out:
  **/
 static struct i40e_vsi *i40e_vsi_reinit_setup(struct i40e_vsi *vsi)
 {
-	struct i40e_pf *pf = vsi->back;
+	struct i40e_pf *pf;
 	u8 enabled_tc;
 	int ret;
 
+	if (!vsi)
+		return NULL;
+
+	pf = vsi->back;
+
 	i40e_put_lump(pf->qp_pile, vsi->base_queue, vsi->idx);
 	i40e_vsi_clear_rings(vsi);
 
-- 
2.5.0
