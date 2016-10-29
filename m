From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/17] i40e: Remove unused function i40e_vsi_lookup
Date: Sat, 29 Oct 2016 00:30:45 -0700
Message-ID: <1477726258-111563-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12932 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751824AbcJ2HbI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 03:31:08 -0400
In-Reply-To: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The function is not used so there is no need to carry it forward.  I have
plans to add a slightly different function that can be inlined to handle
the same kind of functionality.

Change-ID: Ie2dfcb189dc75e5fbc156bac23003e3b4210ae0f
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h        |  2 --
 drivers/net/ethernet/intel/i40e/i40e_client.c | 31 ---------------------------
 2 files changed, 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 2030d7c..34c7a5d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -728,8 +728,6 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi);
 struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 				u16 uplink, u32 param1);
 int i40e_vsi_release(struct i40e_vsi *vsi);
-struct i40e_vsi *i40e_vsi_lookup(struct i40e_pf *pf, enum i40e_vsi_type type,
-				 struct i40e_vsi *start_vsi);
 #ifdef I40E_FCOE
 void i40e_vsi_setup_queue_map(struct i40e_vsi *vsi,
 			      struct i40e_vsi_context *ctxt,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 6ffac03..417ac16 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -406,37 +406,6 @@ int i40e_vf_client_capable(struct i40e_pf *pf, u32 vf_id,
 }
 
 /**
- * i40e_vsi_lookup - finds a matching VSI from the PF list starting at start_vsi
- * @pf: board private structure
- * @type: vsi type
- * @start_vsi: a VSI pointer from where to start the search
- *
- * Returns non NULL on success or NULL for failure
- **/
-struct i40e_vsi *i40e_vsi_lookup(struct i40e_pf *pf,
-				 enum i40e_vsi_type type,
-				 struct i40e_vsi *start_vsi)
-{
-	struct i40e_vsi *vsi;
-	int i = 0;
-
-	if (start_vsi) {
-		for (i = 0; i < pf->num_alloc_vsi; i++) {
-			vsi = pf->vsi[i];
-			if (vsi == start_vsi)
-				break;
-		}
-	}
-	for (; i < pf->num_alloc_vsi; i++) {
-		vsi = pf->vsi[i];
-		if (vsi && vsi->type == type)
-			return vsi;
-	}
-
-	return NULL;
-}
-
-/**
  * i40e_client_add_instance - add a client instance struct to the instance list
  * @pf: pointer to the board struct
  * @client: pointer to a client struct in the client list.
-- 
2.7.4
