From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [RESEND PATCH net-next 1/4] vhost: remove the dead branch
Date: Thu, 28 Nov 2013 09:31:30 +0800
Message-ID: <1385602293-24024-2-git-send-email-zwu.kernel@gmail.com>
References: <1385602293-24024-1-git-send-email-zwu.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385602293-24024-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Since vhost_dev_init() forever return 0, some branches are never run,
therefore need to be removed.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
Acked-by: Michael S. Tsirkin <mst@redhat.com>
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
index f175629..3164680 100644
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
