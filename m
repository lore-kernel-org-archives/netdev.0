From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] virtio_net: Give indication on device probe failure.
Date: Thu, 24 Nov 2011 13:54:21 +0530
Message-ID: <20111124082421.26821.71126.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, levinsasha928@gmail.com,
	Krishna Kumar <krkumar2@in.ibm.com>, davem@davemloft.net
To: rusty@rustcorp.com.au, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:58425 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334Ab1KXIYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 03:24:31 -0500
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Thu, 24 Nov 2011 08:20:26 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAO8L8Tx1388558
	for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 19:21:08 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAO8ONc1002266
	for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 19:24:25 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide an indication when the virtio_net device fails to
initialize.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/virtio_net.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
--- org/drivers/net/virtio_net.c	2011-11-24 11:53:08.000000000 +0530
+++ new/drivers/net/virtio_net.c	2011-11-24 13:51:32.000000000 +0530
@@ -971,7 +971,7 @@ static void virtnet_config_changed(struc
 
 static int virtnet_probe(struct virtio_device *vdev)
 {
-	int err;
+	int err = -ENOMEM;
 	struct net_device *dev;
 	struct virtnet_info *vi;
 	struct virtqueue *vqs[3];
@@ -982,7 +982,7 @@ static int virtnet_probe(struct virtio_d
 	/* Allocate ourselves a network device with room for our info */
 	dev = alloc_etherdev(sizeof(struct virtnet_info));
 	if (!dev)
-		return -ENOMEM;
+		goto out;
 
 	/* Set up network device as normal. */
 	dev->priv_flags |= IFF_UNICAST_FLT;
@@ -1032,7 +1032,6 @@ static int virtnet_probe(struct virtio_d
 	vdev->priv = vi;
 	vi->pages = NULL;
 	vi->stats = alloc_percpu(struct virtnet_stats);
-	err = -ENOMEM;
 	if (vi->stats == NULL)
 		goto free;
 
@@ -1104,6 +1103,8 @@ free_stats:
 	free_percpu(vi->stats);
 free:
 	free_netdev(dev);
+out:
+	dev_err(&vdev->dev, "Device probe failed with errno: %d\n", err);
 	return err;
 }
 
