From: David Gibson <david@gibson.dropbear.id.au>
Subject: [PATCH 1/2] netxen: Correct off-by-one error in bounds check
Date: Tue, 17 Dec 2013 16:22:32 +1100
Message-ID: <1387257753-18676-2-git-send-email-david@gibson.dropbear.id.au>
References: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
Cc: netdev@vger.kernel.org, snagarka@redhat.com, tcamuso@redhat.com,
	vdasgupt@redhat.com, David Gibson <david@gibson.dropbear.id.au>
To: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58935 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751021Ab3LQFUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 00:20:52 -0500
In-Reply-To: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After retrieving an Rx buffer index from the hardware, the netxen driver
bounds checks it against its array of receive buffers.  However in the case
of LRO packets, there's an off-by-one error in the check - it uses >
instead of the >= it uses for the normal receive path in
netxen_process_rcv().

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index 7692dfd..68658b8 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1610,7 +1610,7 @@ netxen_process_lro(struct netxen_adapter *adapter,
 	rds_ring = &recv_ctx->rds_rings[ring];
 
 	index = netxen_get_lro_sts_refhandle(sts_data0);
-	if (unlikely(index > rds_ring->num_desc))
+	if (unlikely(index >= rds_ring->num_desc))
 		return NULL;
 
 	buffer = &rds_ring->rx_buf_arr[index];
-- 
1.8.3.1
