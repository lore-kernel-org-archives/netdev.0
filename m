From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 1/8] ixgbevf: Fix handling of NAPI budget when multiple queues are enabled per vector
Date: Tue, 29 Dec 2015 19:23:22 -0800
Message-ID: <1451445809-70497-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1451445809-70497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: William Dauchy <william@gandi.net>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27547 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752158AbbL3DXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 22:23:32 -0500
In-Reply-To: <1451445809-70497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Dauchy <william@gandi.net>

This is the same patch as for ixgbe but applied differently according to
busy polling.  See commit 5d6002b7b822c74 ("ixgbe: Fix handling of NAPI
budget when multiple queues are enabled per vector")

Signed-off-by: William Dauchy <william@gandi.net>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index f098952..478c0f1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1016,6 +1016,8 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 	ixgbevf_for_each_ring(ring, q_vector->tx)
 		clean_complete &= ixgbevf_clean_tx_irq(q_vector, ring);
 
+	if (budget <= 0)
+		return budget;
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	if (!ixgbevf_qv_lock_napi(q_vector))
 		return budget;
-- 
2.5.0
