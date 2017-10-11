From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [jkirsher/next-queue PATCH v4 2/6] i40e: Map TCs with the VSI seids
Date: Tue, 10 Oct 2017 17:24:23 -0700
Message-ID: <150768146296.5320.684345674569171719.stgit@anamdev.jf.intel.com>
References: <150768099999.5320.1633617713417675266.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jiri@resnulli.us,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        jhs@mojatatu.com, alexander.duyck@gmail.com,
        xiyou.wangcong@gmail.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:21914 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756553AbdJKAZs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 20:25:48 -0400
In-Reply-To: <150768099999.5320.1633617713417675266.stgit@anamdev.jf.intel.com>
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
index eb01776..f3c501e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -739,6 +739,7 @@ struct i40e_vsi {
 	u16 next_base_queue;	/* next queue to be used for channel setup */
 
 	struct list_head ch_list;
+	u16 tc_seid_map[I40E_MAX_TRAFFIC_CLASS];
 
 	void *priv;	/* client driver data reference. */
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 75f944f..33a8f429 100644
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
