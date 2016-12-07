From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/19] i40e: use unsigned printf format specifier for active_filters count
Date: Wed,  7 Dec 2016 14:19:07 -0800
Message-ID: <20161207221918.57932-9-jeffrey.t.kirsher@intel.com>
References: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:42627 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933402AbcLGWUR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 17:20:17 -0500
In-Reply-To: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Replace the %d specifier used for printing vsi->active_filters and
vsi->promisc_threshold with an unsigned %u format specifier. While it is
unlikely in practice that these values will ever reach such a large
number they are unsigned values and thus should not be interpreted as
negative numbers.

Change-ID: Iff050fad5a1c8537c4c57fcd527441cd95cfc0d4
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index b8a03a0..f1f41f1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -172,7 +172,7 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 			 f->macaddr, f->vlan,
 			 i40e_filter_state_string[f->state]);
 	}
-	dev_info(&pf->pdev->dev, "    active_filters %d, promisc_threshold %d, overflow promisc %s\n",
+	dev_info(&pf->pdev->dev, "    active_filters %u, promisc_threshold %u, overflow promisc %s\n",
 		 vsi->active_filters, vsi->promisc_threshold,
 		 (test_bit(__I40E_FILTER_OVERFLOW_PROMISC, &vsi->state) ?
 		  "ON" : "OFF"));
-- 
2.9.3
