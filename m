From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv4 net-next 32/32] iw_cxgb4: Use pr_warn_ratelimited
Date: Fri,  7 Mar 2014 16:03:29 +0530
Message-ID: <1394188409-9739-33-git-send-email-hariprasad@chelsio.com>
References: <1394188409-9739-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, santosh@chelsio.com,
	dm@chelsio.com, kumaras@chelsio.com, swise@opengridcomputing.com,
	leedom@chelsio.com, nirranjan@chelsio.com, hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12197 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752940AbaCGKnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 05:43:33 -0500
In-Reply-To: <1394188409-9739-1-git-send-email-hariprasad@chelsio.com>
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
