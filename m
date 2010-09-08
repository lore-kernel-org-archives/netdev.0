From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC PATCH 1/4] Add a new API to virtio-pci
Date: Wed, 08 Sep 2010 12:59:05 +0530
Message-ID: <20100908072905.23769.10732.sendpatchset@krkumar2.in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	anthony@codemonkey.ws, kvm@vger.kernel.org, mst@redhat.com
To: rusty@rustcorp.com.au, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:52380 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757930Ab0IHH3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 03:29:11 -0400
In-Reply-To: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add virtio_get_queue_index() to get the queue index of a
vq.  This is needed by the cb handler to locate the queue
that should be processed.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/virtio/virtio_pci.c |    9 +++++++++
 include/linux/virtio.h      |    3 +++
 2 files changed, 12 insertions(+)

diff -ruNp org/include/linux/virtio.h tx_only/include/linux/virtio.h
--- org/include/linux/virtio.h	2010-09-03 16:33:51.000000000 +0530
+++ tx_only/include/linux/virtio.h	2010-09-08 10:23:36.000000000 +0530
@@ -136,4 +136,7 @@ struct virtio_driver {
 
 int register_virtio_driver(struct virtio_driver *drv);
 void unregister_virtio_driver(struct virtio_driver *drv);
+
+/* return the internal queue index associated with the virtqueue */
+extern int virtio_get_queue_index(struct virtqueue *vq);
 #endif /* _LINUX_VIRTIO_H */
diff -ruNp org/drivers/virtio/virtio_pci.c tx_only/drivers/virtio/virtio_pci.c
--- org/drivers/virtio/virtio_pci.c	2010-09-03 16:33:51.000000000 +0530
+++ tx_only/drivers/virtio/virtio_pci.c	2010-09-08 10:23:16.000000000 +0530
@@ -359,6 +359,15 @@ static int vp_request_intx(struct virtio
 	return err;
 }
 
+/* Return the internal queue index associated with the virtqueue */
+int virtio_get_queue_index(struct virtqueue *vq)
+{
+	struct virtio_pci_vq_info *info = vq->priv;
+
+	return info->queue_index;
+}
+EXPORT_SYMBOL(virtio_get_queue_index);
+
 static struct virtqueue *setup_vq(struct virtio_device *vdev, unsigned index,
 				  void (*callback)(struct virtqueue *vq),
 				  const char *name,
