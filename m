From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/16] fm10k: base queue scheme covered by RSS
Date: Tue,  5 Apr 2016 01:01:21 -0700
Message-ID: <1459843288-40623-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5422 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754225AbcDEIBx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 04:01:53 -0400
In-Reply-To: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

In fm10k_set_num_queues, we previously assigned the base template. This
would always be overwritten by either fm10k_set_qos_queues or
fm10k_set_rss_queues. In either case, we don't need the base values, so
we can just remove them.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index db4353b..b87401c38 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1572,13 +1572,11 @@ static bool fm10k_set_rss_queues(struct fm10k_intfc *interface)
  **/
 static void fm10k_set_num_queues(struct fm10k_intfc *interface)
 {
-	/* Start with base case */
-	interface->num_rx_queues = 1;
-	interface->num_tx_queues = 1;
-
+	/* Attempt to setup QoS and RSS first */
 	if (fm10k_set_qos_queues(interface))
 		return;
 
+	/* If we don't have QoS, just fallback to only RSS. */
 	fm10k_set_rss_queues(interface);
 }
 
-- 
2.5.5
