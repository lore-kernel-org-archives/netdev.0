From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 1/2 v2 -next] cxgb4: potential shift wrapping bug
Date: Wed, 8 Oct 2014 16:43:17 +0300
Message-ID: <20141008134317.GA12036@mwanda>
References: <20141003.154629.555967384624529643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45115 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbaJHNnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 09:43:33 -0400
Content-Disposition: inline
In-Reply-To: <20141003.154629.555967384624529643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"cntxt_id" is an unsigned int but "udb" is a u64 so there is a potential
shift wrapping bug here.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
No changes since v1.

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index bb7851e..e8e90ce 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2258,7 +2258,7 @@ static u64 udb_address(struct adapter *adap, unsigned int cntxt_id,
 		(QUEUESPERPAGEPF1 - QUEUESPERPAGEPF0) * adap->fn);
 	udb_density = 1 << ((qpp >> s_qpp) & QUEUESPERPAGEPF0_MASK);
 	qpshift = PAGE_SHIFT - ilog2(udb_density);
-	udb = cntxt_id << qpshift;
+	udb = (u64)cntxt_id << qpshift;
 	udb &= PAGE_MASK;
 	page = udb / PAGE_SIZE;
 	udb += (cntxt_id - (page * udb_density)) * SGE_UDB_SIZE;
