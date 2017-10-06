From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: fix merge error
Date: Fri,  6 Oct 2017 10:57:20 -0700
Message-ID: <20171006175727.868-9-jeffrey.t.kirsher@intel.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Alice Michael <alice.michael@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56459 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752473AbdJFR5u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:50 -0400
In-Reply-To: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alice Michael <alice.michael@intel.com>

This patch removes some code that was accidentally added to
the wrong function with a merge error.  Fixes: c53934c6d1b1
("i40e: fix: do not sleep in netdev_ops")

Signed-off-by: Alice Michael <alice.michael@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 49401be7a2f4..628101bb08d4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1776,11 +1776,6 @@ static void i40e_set_rx_mode(struct net_device *netdev)
 		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
 		vsi->back->flags |= I40E_FLAG_FILTER_SYNC;
 	}
-
-	/* schedule our worker thread which will take care of
-	 * applying the new filter changes
-	 */
-	i40e_service_event_schedule(vsi->back);
 }
 
 /**
-- 
2.14.2
