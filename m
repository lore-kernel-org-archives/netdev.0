From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] dpaa_eth: small leak on error
Date: Thu, 16 Feb 2017 12:56:10 +0300
Message-ID: <20170216095610.GA23242@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Madalin Bucur <madalin.bucur@nxp.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This should be >= instead of > here.  It means that we don't increment
the free count enough so it becomes off by one.

Fixes: 9ad1a3749333 ("dpaa_eth: add support for DPAA Ethernet")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Applies to -net tree.

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 25a14a3fe784..bc5a3347fd4a 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -1666,7 +1666,7 @@ static struct sk_buff *sg_fd_to_skb(const struct dpaa_priv *priv,
 
 free_buffers:
 	/* compensate sw bpool counter changes */
-	for (i--; i > 0; i--) {
+	for (i--; i >= 0; i--) {
 		dpaa_bp = dpaa_bpid2pool(sgt[i].bpid);
 		if (dpaa_bp) {
 			count_ptr = this_cpu_ptr(dpaa_bp->percpu_count);
