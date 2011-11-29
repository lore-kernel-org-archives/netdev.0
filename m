From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] bnx2x: Use kcalloc instead of kzalloc to allocate array
Date: Tue, 29 Nov 2011 22:08:00 +0100
Message-ID: <1322600880.1534.320.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The advantage of kcalloc is, that will prevent integer overflows which could
result from the multiplication of number of elements and size and it is also
a bit nicer to read.

The semantic patch that makes this change is available
in https://lkml.org/lkml/2011/11/25/107

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c 2011-11-13 11:07:33.983607086 +0100
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c 2011-11-28 19:52:50.979887113 +0100
@@ -3278,14 +3278,14 @@ int __devinit bnx2x_alloc_mem_bp(struct
 	msix_table_size = bp->igu_sb_cnt + 1;
 
 	/* fp array: RSS plus CNIC related L2 queues */
-	fp = kzalloc((BNX2X_MAX_RSS_COUNT(bp) + NON_ETH_CONTEXT_USE) *
+	fp = kcalloc(BNX2X_MAX_RSS_COUNT(bp) + NON_ETH_CONTEXT_USE,
 		     sizeof(*fp), GFP_KERNEL);
 	if (!fp)
 		goto alloc_err;
 	bp->fp = fp;
 
 	/* msix table */
-	tbl = kzalloc(msix_table_size * sizeof(*tbl), GFP_KERNEL);
+	tbl = kcalloc(msix_table_size, sizeof(*tbl), GFP_KERNEL);
 	if (!tbl)
 		goto alloc_err;
 	bp->msix_table = tbl;
diff -u -p a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c 2011-11-28 19:36:47.716773832 +0100
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c 2011-11-28 19:52:53.063259517 +0100
@@ -3342,7 +3342,7 @@ static inline int bnx2x_mcast_refresh_re
 		if (!list_empty(&o->registry.exact_match.macs))
 			return 0;
 
-		elem = kzalloc(sizeof(*elem)*len, GFP_ATOMIC);
+		elem = kcalloc(len, sizeof(*elem), GFP_ATOMIC);
 		if (!elem) {
 			BNX2X_ERR("Failed to allocate registry memory\n");
 			return -ENOMEM;
