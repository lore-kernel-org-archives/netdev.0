From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] cxgb3: No need to wake queue in xmit handler
Date: Thu, 15 Oct 2009 11:24:19 +0530
Message-ID: <20091015055419.30109.16062.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, divy@chelsio.com,
	Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:41128 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752561AbZJOFzM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 01:55:12 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9F5r5Lw000405
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 01:53:05 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9F5sPlM248622
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 01:54:25 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9F5sP4c025543
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 01:54:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xmit handler doesn't need to wake the queue after stopping
it temporarily (some other drivers are doing the same).

Patch on net-next-2.6, multiple netperf sessions tested.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 drivers/net/cxgb3/sge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -ruNp org/drivers/net/cxgb3/sge.c new/drivers/net/cxgb3/sge.c
--- org/drivers/net/cxgb3/sge.c	2009-09-07 10:09:03.000000000 +0530
+++ new/drivers/net/cxgb3/sge.c	2009-09-07 10:11:11.000000000 +0530
@@ -1260,7 +1260,7 @@ netdev_tx_t t3_eth_xmit(struct sk_buff *
 		if (should_restart_tx(q) &&
 		    test_and_clear_bit(TXQ_ETH, &qs->txq_stopped)) {
 			q->restarts++;
-			netif_tx_wake_queue(txq);
+			netif_tx_start_queue(txq);
 		}
 	}
 
