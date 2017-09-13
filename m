From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [RFC PATCH v3 3/7] i40e: Map TCs with the VSI seids
Date: Wed, 13 Sep 2017 02:59:29 -0700
Message-ID: <150529676964.57063.13731545596355696552.stgit@anamdev.jf.intel.com>
References: <150529632024.57063.15338545678487601430.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        amritha.nambiar@intel.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:2883 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752134AbdIMKAj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 06:00:39 -0400
In-Reply-To: <150529632024.57063.15338545678487601430.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add mapping of TCs with the seids of the channel VSIs. TC0
will be mapped to the main VSI seid and all other TCs are
mapped to the seid of the corresponding channel VSI.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |    1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c |    2 ++
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 266e1dc..d846da9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -738,6 +738,7 @@ struct i40e_vsi {
 	u16 next_base_queue;	/* next queue to be used for channel setup */
 
 	struct list_head ch_list;
+	u16 tc_seid_map[I40E_MAX_TRAFFIC_CLASS];
 
 	void *priv;	/* client driver data reference. */
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5ef3927..0455283 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6093,6 +6093,7 @@ static int i40e_configure_queue_channels(struct i40e_vsi *vsi)
 	int ret = 0, i;
 
 	/* Create app vsi with the TCs. Main VSI with TC0 is already set up */
+	vsi->tc_seid_map[0] = vsi->seid;
 	for (i = 1; i < I40E_MAX_TRAFFIC_CLASS; i++) {
 		if (vsi->tc_config.enabled_tc & BIT(i)) {
 			ch = kzalloc(sizeof(*ch), GFP_KERNEL);
@@ -6122,6 +6123,7 @@ static int i40e_configure_queue_channels(struct i40e_vsi *vsi)
 					i, ch->num_queue_pairs);
 				goto err_free;
 			}
+			vsi->tc_seid_map[i] = ch->seid;
 		}
 	}
 	return ret;
