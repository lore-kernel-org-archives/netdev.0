From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [PATCH] cxgb3: Set the rxq
Date: Fri, 23 Oct 2009 16:43:21 +0530
Message-ID: <20091023111321.4726.29354.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, divy@chelsio.com,
	Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:39788 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204AbZJWLNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2009 07:13:22 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9NBBuLs026606
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 07:11:56 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9NBDQtc093368
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 07:13:26 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9N5F2cE018072
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 01:15:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Set the rxq# for LRO when processing the last fragment of a
frame. This helps in fast txq selection for routing workloads.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 drivers/net/cxgb3/sge.c |    1 +
 1 file changed, 1 insertion(+)

diff -ruNp org/drivers/net/cxgb3/sge.c new/drivers/net/cxgb3/sge.c
--- org/drivers/net/cxgb3/sge.c	2009-10-19 11:58:16.000000000 +0530
+++ new/drivers/net/cxgb3/sge.c	2009-10-20 09:40:40.000000000 +0530
@@ -2135,6 +2135,7 @@ static void lro_add_page(struct adapter 
 	if (!complete)
 		return;
 
+	skb_record_rx_queue(skb, qs - &adap->sge.qs[0]);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	cpl = qs->lro_va;
 
