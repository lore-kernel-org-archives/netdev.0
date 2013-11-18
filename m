From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 1/3] vhost: remove the dead branch
Date: Mon, 18 Nov 2013 11:19:21 +0800
Message-ID: <1384744763-7476-1-git-send-email-zwu.kernel@gmail.com>
Cc: mst@redhat.com, rusty@rustcorp.com.au,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:60915 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959Ab3KRDUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Nov 2013 22:20:20 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Sun, 17 Nov 2013 22:20:20 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 9CC536E804C
	for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 22:20:15 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAI3KHWP6750480
	for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 03:20:17 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAI3KGm4031913
	for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 22:20:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Since vhost_dev_init() forever return 0, some branches are never run,
therefore need to be removed.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/vhost/net.c  |    5 -----
 drivers/vhost/scsi.c |    5 -----
 drivers/vhost/test.c |    5 -----
 3 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 831eb4f..0554785 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -707,11 +707,6 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 		n->vqs[i].sock_hlen = 0;
 	}
 	r = vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX);
-	if (r < 0) {
-		kfree(n);
-		kfree(vqs);
-		return r;
-	}
 
 	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
 	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index e663921..9d5e18d 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -1421,14 +1421,9 @@ static int vhost_scsi_open(struct inode *inode, struct file *f)
 
 	tcm_vhost_init_inflight(vs, NULL);
 
-	if (r < 0)
-		goto err_init;
-
 	f->private_data = vs;
 	return 0;
 
-err_init:
-	kfree(vqs);
 err_vqs:
 	vhost_scsi_free(vs);
 err_vs:
diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
index 339eae8..99cb960 100644
--- a/drivers/vhost/test.c
+++ b/drivers/vhost/test.c
@@ -118,11 +118,6 @@ static int vhost_test_open(struct inode *inode, struct file *f)
 	vqs[VHOST_TEST_VQ] = &n->vqs[VHOST_TEST_VQ];
 	n->vqs[VHOST_TEST_VQ].handle_kick = handle_vq_kick;
 	r = vhost_dev_init(dev, vqs, VHOST_TEST_VQ_MAX);
-	if (r < 0) {
-		kfree(vqs);
-		kfree(n);
-		return r;
-	}
 
 	f->private_data = n;
 
-- 
1.7.6.5
