From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 2/3] vhost: adjust vhost_dev_init() to be void
Date: Mon, 18 Nov 2013 11:19:22 +0800
Message-ID: <1384744763-7476-2-git-send-email-zwu.kernel@gmail.com>
References: <1384744763-7476-1-git-send-email-zwu.kernel@gmail.com>
Cc: mst@redhat.com, rusty@rustcorp.com.au,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:41432 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959Ab3KRDUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Nov 2013 22:20:25 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Sun, 17 Nov 2013 22:20:24 -0500
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2C66EC90052
	for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 22:20:20 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAI3KL4t66257042
	for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 03:20:21 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAI3KK5Y014556
	for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 22:20:21 -0500
In-Reply-To: <1384744763-7476-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/vhost/net.c   |    4 ++--
 drivers/vhost/scsi.c  |    2 +-
 drivers/vhost/test.c  |    3 +--
 drivers/vhost/vhost.c |    4 +---
 drivers/vhost/vhost.h |    2 +-
 5 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 0554785..9a68409 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -683,7 +683,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	struct vhost_net *n = kmalloc(sizeof *n, GFP_KERNEL);
 	struct vhost_dev *dev;
 	struct vhost_virtqueue **vqs;
-	int r, i;
+	int i;
 
 	if (!n)
 		return -ENOMEM;
@@ -706,7 +706,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 		n->vqs[i].vhost_hlen = 0;
 		n->vqs[i].sock_hlen = 0;
 	}
-	r = vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX);
+	vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX);
 
 	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
 	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index 9d5e18d..e02b7df 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -1417,7 +1417,7 @@ static int vhost_scsi_open(struct inode *inode, struct file *f)
 		vqs[i] = &vs->vqs[i].vq;
 		vs->vqs[i].vq.handle_kick = vhost_scsi_handle_kick;
 	}
-	r = vhost_dev_init(&vs->dev, vqs, VHOST_SCSI_MAX_VQ);
+	vhost_dev_init(&vs->dev, vqs, VHOST_SCSI_MAX_VQ);
 
 	tcm_vhost_init_inflight(vs, NULL);
 
diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
index 99cb960..c2a54fb 100644
--- a/drivers/vhost/test.c
+++ b/drivers/vhost/test.c
@@ -104,7 +104,6 @@ static int vhost_test_open(struct inode *inode, struct file *f)
 	struct vhost_test *n = kmalloc(sizeof *n, GFP_KERNEL);
 	struct vhost_dev *dev;
 	struct vhost_virtqueue **vqs;
-	int r;
 
 	if (!n)
 		return -ENOMEM;
@@ -117,7 +116,7 @@ static int vhost_test_open(struct inode *inode, struct file *f)
 	dev = &n->dev;
 	vqs[VHOST_TEST_VQ] = &n->vqs[VHOST_TEST_VQ];
 	n->vqs[VHOST_TEST_VQ].handle_kick = handle_vq_kick;
-	r = vhost_dev_init(dev, vqs, VHOST_TEST_VQ_MAX);
+	vhost_dev_init(dev, vqs, VHOST_TEST_VQ_MAX);
 
 	f->private_data = n;
 
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 69068e0..78987e4 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -290,7 +290,7 @@ static void vhost_dev_free_iovecs(struct vhost_dev *dev)
 		vhost_vq_free_iovecs(dev->vqs[i]);
 }
 
-long vhost_dev_init(struct vhost_dev *dev,
+void vhost_dev_init(struct vhost_dev *dev,
 		    struct vhost_virtqueue **vqs, int nvqs)
 {
 	struct vhost_virtqueue *vq;
@@ -319,8 +319,6 @@ long vhost_dev_init(struct vhost_dev *dev,
 			vhost_poll_init(&vq->poll, vq->handle_kick,
 					POLLIN, dev);
 	}
-
-	return 0;
 }
 EXPORT_SYMBOL_GPL(vhost_dev_init);
 
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 4465ed5..35eeb2a 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -127,7 +127,7 @@ struct vhost_dev {
 	struct task_struct *worker;
 };
 
-long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue **vqs, int nvqs);
+void vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue **vqs, int nvqs);
 long vhost_dev_set_owner(struct vhost_dev *dev);
 bool vhost_dev_has_owner(struct vhost_dev *dev);
 long vhost_dev_check_owner(struct vhost_dev *);
-- 
1.7.6.5
