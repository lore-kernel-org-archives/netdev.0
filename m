From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 14/20] drivers/net/vmxnet3: Use kzalloc
Date: Thu, 13 May 2010 22:05:40 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005132204040.6282@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:42061 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057Ab0EMUFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 16:05:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Use kzalloc rather than the combination of kmalloc and memset.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression x,size,flags;
statement S;
@@

-x = kmalloc(size,flags);
+x = kzalloc(size,flags);
 if (x == NULL) S
-memset(x, 0, size);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/vmxnet3/vmxnet3_drv.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -u -p a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1369,13 +1369,12 @@ vmxnet3_rq_create(struct vmxnet3_rx_queu
 
 	sz = sizeof(struct vmxnet3_rx_buf_info) * (rq->rx_ring[0].size +
 						   rq->rx_ring[1].size);
-	bi = kmalloc(sz, GFP_KERNEL);
+	bi = kzalloc(sz, GFP_KERNEL);
 	if (!bi) {
 		printk(KERN_ERR "%s: failed to allocate rx bufinfo\n",
 		       adapter->netdev->name);
 		goto err;
 	}
-	memset(bi, 0, sz);
 	rq->buf_info[0] = bi;
 	rq->buf_info[1] = bi + rq->rx_ring[0].size;
 
