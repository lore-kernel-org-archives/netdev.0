From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] i40e: clear VEB stats when pf stats are cleared
Date: Fri, 20 Jun 2014 00:49:43 -0700
Message-ID: <1403250588-14356-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62073 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933971AbaFTHt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 03:49:57 -0400
In-Reply-To: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The VEB really is part of the whole PF and should be cleared
at the same time.

Change-ID: Ia1d4d1df5cf421f2578a22486650dd256cc4617a
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 14d7db6..394253e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -444,9 +444,21 @@ void i40e_vsi_reset_stats(struct i40e_vsi *vsi)
  **/
 void i40e_pf_reset_stats(struct i40e_pf *pf)
 {
+	int i;
+
 	memset(&pf->stats, 0, sizeof(pf->stats));
 	memset(&pf->stats_offsets, 0, sizeof(pf->stats_offsets));
 	pf->stat_offsets_loaded = false;
+
+	for (i = 0; i < I40E_MAX_VEB; i++) {
+		if (pf->veb[i]) {
+			memset(&pf->veb[i]->stats, 0,
+			       sizeof(pf->veb[i]->stats));
+			memset(&pf->veb[i]->stats_offsets, 0,
+			       sizeof(pf->veb[i]->stats_offsets));
+			pf->veb[i]->stat_offsets_loaded = false;
+		}
+	}
 }
 
 /**
-- 
1.9.3
