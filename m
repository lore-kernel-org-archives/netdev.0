From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: Make the alloc and free queue vector calls orthogonal
Date: Wed, 26 Mar 2014 11:03:21 -0700
Message-ID: <1395857013-7568-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2937 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754693AbaCZSES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 14:04:18 -0400
In-Reply-To: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

It's annoying to search for a matching alloc and free set of function calls
when they don't use the same framework for the name of the functions.  Fix
that up in the case of alloc and free of vsi queue vectors.

i40e_vsi_free_q*
i40e_vsi_alloc_q*

Change-ID: I510eb863a0fbe405312bebea55c2846c76285e6d
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 28df88e..91fd1f1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6111,13 +6111,13 @@ static int i40e_init_msix(struct i40e_pf *pf)
 }
 
 /**
- * i40e_alloc_q_vector - Allocate memory for a single interrupt vector
+ * i40e_vsi_alloc_q_vector - Allocate memory for a single interrupt vector
  * @vsi: the VSI being configured
  * @v_idx: index of the vector in the vsi struct
  *
  * We allocate one q_vector.  If allocation fails we return -ENOMEM.
  **/
-static int i40e_alloc_q_vector(struct i40e_vsi *vsi, int v_idx)
+static int i40e_vsi_alloc_q_vector(struct i40e_vsi *vsi, int v_idx)
 {
 	struct i40e_q_vector *q_vector;
 
@@ -6143,13 +6143,13 @@ static int i40e_alloc_q_vector(struct i40e_vsi *vsi, int v_idx)
 }
 
 /**
- * i40e_alloc_q_vectors - Allocate memory for interrupt vectors
+ * i40e_vsi_alloc_q_vectors - Allocate memory for interrupt vectors
  * @vsi: the VSI being configured
  *
  * We allocate one q_vector per queue interrupt.  If allocation fails we
  * return -ENOMEM.
  **/
-static int i40e_alloc_q_vectors(struct i40e_vsi *vsi)
+static int i40e_vsi_alloc_q_vectors(struct i40e_vsi *vsi)
 {
 	struct i40e_pf *pf = vsi->back;
 	int v_idx, num_q_vectors;
@@ -6164,7 +6164,7 @@ static int i40e_alloc_q_vectors(struct i40e_vsi *vsi)
 		return -EINVAL;
 
 	for (v_idx = 0; v_idx < num_q_vectors; v_idx++) {
-		err = i40e_alloc_q_vector(vsi, v_idx);
+		err = i40e_vsi_alloc_q_vector(vsi, v_idx);
 		if (err)
 			goto err_out;
 	}
@@ -7020,7 +7020,7 @@ static int i40e_vsi_setup_vectors(struct i40e_vsi *vsi)
 		return -EEXIST;
 	}
 
-	ret = i40e_alloc_q_vectors(vsi);
+	ret = i40e_vsi_alloc_q_vectors(vsi);
 	if (ret) {
 		dev_info(&pf->pdev->dev,
 			 "failed to allocate %d q_vector for VSI %d, ret=%d\n",
-- 
1.8.3.1
