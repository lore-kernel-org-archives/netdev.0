From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 2/8] ixgbevf: minor cleanups for ixgbevf_set_itr()
Date: Tue, 29 Dec 2015 19:23:23 -0800
Message-ID: <1451445809-70497-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1451445809-70497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27547 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752996AbbL3DXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 22:23:33 -0500
In-Reply-To: <1451445809-70497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

adapter->rx_itr_setting is not a mask so check it with == instead of &
do not default to 12K interrupts in ixgbevf_set_itr()

There should be no functional effect from these changes.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 478c0f1..3558f01 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1047,7 +1047,7 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 		return budget;
 	/* all work done, exit the polling mode */
 	napi_complete_done(napi, work_done);
-	if (adapter->rx_itr_setting & 1)
+	if (adapter->rx_itr_setting == 1)
 		ixgbevf_set_itr(q_vector);
 	if (!test_bit(__IXGBEVF_DOWN, &adapter->state) &&
 	    !test_bit(__IXGBEVF_REMOVING, &adapter->state))
@@ -1250,9 +1250,10 @@ static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector)
 		new_itr = IXGBE_20K_ITR;
 		break;
 	case bulk_latency:
-	default:
 		new_itr = IXGBE_12K_ITR;
 		break;
+	default:
+		break;
 	}
 
 	if (new_itr != q_vector->itr) {
-- 
2.5.0
