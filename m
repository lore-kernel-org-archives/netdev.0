From: frank.blaschka@de.ibm.com
Subject: [patch 6/6] [PATCH] qeth: Fix HiperSockets performance regression
Date: Mon, 21 Jan 2013 13:30:23 +0100
Message-ID: <20130121123037.755818924@de.ibm.com>
References: <20130121123017.240686588@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:44259 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753577Ab3AUMam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 07:30:42 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 21 Jan 2013 12:29:34 -0000
Content-Disposition: inline; filename=605-qeth-hipersocket-performance.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

Commit 46d3ceab "tcp: TCP Small Queues" has severly degraded
performance for single connection RR workloads on HiperSockets with
MTU >=16K due to a conflict of the TCP Small Queues approach with our
buffer scan threshold which releases buffers not frequently enough yet.
This fix restores performance to the same level as before cited commit.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4700,7 +4700,7 @@ static int qeth_qdio_establish(struct qe
 	init_data.output_sbal_addr_array = (void **) out_sbal_ptrs;
 	init_data.output_sbal_state_array = card->qdio.out_bufstates;
 	init_data.scan_threshold =
-		(card->info.type == QETH_CARD_TYPE_IQD) ? 8 : 32;
+		(card->info.type == QETH_CARD_TYPE_IQD) ? 1 : 32;
 
 	if (atomic_cmpxchg(&card->qdio.state, QETH_QDIO_ALLOCATED,
 		QETH_QDIO_ESTABLISHED) == QETH_QDIO_ALLOCATED) {
