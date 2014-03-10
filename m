From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv5 net-next 31/31] iw_cxgb4: Use pr_warn_ratelimited
Date: Mon, 10 Mar 2014 22:38:28 +0530
Message-ID: <1394471308-4304-32-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2047 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754650AbaCJRSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:18:48 -0400
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/resource.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/resource.c b/drivers/infiniband/hw/cxgb4/resource.c
index d9bc9ba..67df71a 100644
--- a/drivers/infiniband/hw/cxgb4/resource.c
+++ b/drivers/infiniband/hw/cxgb4/resource.c
@@ -326,8 +326,8 @@ u32 c4iw_rqtpool_alloc(struct c4iw_rdev *rdev, int size)
 	unsigned long addr = gen_pool_alloc(rdev->rqt_pool, size << 6);
 	PDBG("%s addr 0x%x size %d\n", __func__, (u32)addr, size << 6);
 	if (!addr)
-		printk_ratelimited(KERN_WARNING MOD "%s: Out of RQT memory\n",
-		       pci_name(rdev->lldi.pdev));
+		pr_warn_ratelimited(MOD "%s: Out of RQT memory\n",
+				    pci_name(rdev->lldi.pdev));
 	mutex_lock(&rdev->stats.lock);
 	if (addr) {
 		rdev->stats.rqt.cur += roundup(size << 6, 1 << MIN_RQT_SHIFT);
-- 
1.8.4
