From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] i40e: Map TCs with the VSI seids
Date: Tue, 31 Oct 2017 11:40:08 -0700
Message-ID: <20171031184012.29690-6-jeffrey.t.kirsher@intel.com>
References: <20171031184012.29690-1-jeffrey.t.kirsher@intel.com>
Cc: Amritha Nambiar <amritha.nambiar@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4615 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932655AbdJaSkh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 14:40:37 -0400
In-Reply-To: <20171031184012.29690-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amritha Nambiar <amritha.nambiar@intel.com>

Add mapping of TCs with the seids of the channel VSIs. TC0
will be mapped to the main VSI seid and all other TCs are
mapped to the seid of the corresponding channel VSI.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index eb017763646d..f3c501efddc8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -739,6 +739,7 @@ struct i40e_vsi {
 	u16 next_base_queue;	/* next queue to be used for channel setup */
 
 	struct list_head ch_list;
+	u16 tc_seid_map[I40E_MAX_TRAFFIC_CLASS];
 
 	void *priv;	/* client driver data reference. */
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1cf9ba2d9a41..2ff7384cb24b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6100,6 +6100,7 @@ static int i40e_configure_queue_channels(struct i40e_vsi *vsi)
 	int ret = 0, i;
 
 	/* Create app vsi with the TCs. Main VSI with TC0 is already set up */
+	vsi->tc_seid_map[0] = vsi->seid;
 	for (i = 1; i < I40E_MAX_TRAFFIC_CLASS; i++) {
 		if (vsi->tc_config.enabled_tc & BIT(i)) {
 			ch = kzalloc(sizeof(*ch), GFP_KERNEL);
@@ -6130,6 +6131,7 @@ static int i40e_configure_queue_channels(struct i40e_vsi *vsi)
 					i, ch->num_queue_pairs);
 				goto err_free;
 			}
+			vsi->tc_seid_map[i] = ch->seid;
 		}
 	}
 	return ret;
-- 
2.14.2
