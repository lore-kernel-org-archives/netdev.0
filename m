From: David Gibson <david@gibson.dropbear.id.au>
Subject: [PATCH] netxen: Correct off-by-one errors in bounds checks
Date: Fri, 20 Dec 2013 15:10:44 +1100
Message-ID: <1387512644-31759-1-git-send-email-david@gibson.dropbear.id.au>
Cc: netdev@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>
To: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35927 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972Ab3LTFqJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 00:46:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netxen_process_lro() contains two bounds checks.  One for the ring number
against the number of rings, and one for the Rx buffer ID against the
array of receive buffers.

Both of these have off-by-one errors, using > instead of >=. The correct
versions are used in netxen_process_rcv(), they're just wrong in
netxen_process_lro().

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index 7692dfd..cc68657 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1604,13 +1604,13 @@ netxen_process_lro(struct netxen_adapter *adapter,
 	u32 seq_number;
 	u8 vhdr_len = 0;
 
-	if (unlikely(ring > adapter->max_rds_rings))
+	if (unlikely(ring >= adapter->max_rds_rings))
 		return NULL;
 
 	rds_ring = &recv_ctx->rds_rings[ring];
 
 	index = netxen_get_lro_sts_refhandle(sts_data0);
-	if (unlikely(index > rds_ring->num_desc))
+	if (unlikely(index >= rds_ring->num_desc))
 		return NULL;
 
 	buffer = &rds_ring->rx_buf_arr[index];
-- 
1.8.4.2
