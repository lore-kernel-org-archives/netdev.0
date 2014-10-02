From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 1/2 -next] cxgb4: potential shift wrapping bug
Date: Thu, 2 Oct 2014 13:20:53 +0300
Message-ID: <20141002102052.GA14241@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"cntxt_id" is an unsigned int but "udb" is a u64 so there is a potential
shift wrapping bug here.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

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
