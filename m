From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v2 3/3] virtio: use kcalloc and kmalloc_array
Date: Tue, 26 Jul 2016 09:37:15 -0700
Message-ID: <20160726163747.437348999@networkplumber.org>
References: <20160726163712.721213063@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33870 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785AbcGZQhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 12:37:32 -0400
Received: by mail-pa0-f48.google.com with SMTP id fi15so1334002pac.1
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 09:37:32 -0700 (PDT)
Content-Disposition: inline; filename=virtio-kcalloc.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preferred style is to use kcalloc and kmalloc_array.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/virtio_net.c	2016-07-26 09:28:21.401557546 -0700
+++ b/drivers/net/virtio_net.c	2016-07-26 09:36:05.107695337 -0700
@@ -1551,13 +1551,13 @@ static int virtnet_find_vqs(struct virtn
 		    virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ);
 
 	/* Allocate space for find_vqs parameters */
-	vqs = kzalloc(total_vqs * sizeof(*vqs), GFP_KERNEL);
+	vqs = kcalloc(total_vqs, sizeof(*vqs), GFP_KERNEL);
 	if (!vqs)
 		goto err_vq;
-	callbacks = kmalloc(total_vqs * sizeof(*callbacks), GFP_KERNEL);
+	callbacks = kmalloc_array(total_vqs, sizeof(*callbacks), GFP_KERNEL);
 	if (!callbacks)
 		goto err_callback;
-	names = kmalloc(total_vqs * sizeof(*names), GFP_KERNEL);
+	names = kmalloc_array(total_vqs, sizeof(*names), GFP_KERNEL);
 	if (!names)
 		goto err_names;
 
@@ -1613,10 +1613,10 @@ static int virtnet_alloc_queues(struct v
 {
 	int i;
 
-	vi->sq = kzalloc(sizeof(*vi->sq) * vi->max_queue_pairs, GFP_KERNEL);
+	vi->sq = kcalloc(vi->max_queue_pairs, sizeof(*vi->sq), GFP_KERNEL);
 	if (!vi->sq)
 		goto err_sq;
-	vi->rq = kzalloc(sizeof(*vi->rq) * vi->max_queue_pairs, GFP_KERNEL);
+	vi->rq = kcalloc(vi->max_queue_pairs, sizeof(*vi->rq), GFP_KERNEL);
 	if (!vi->rq)
 		goto err_rq;
 
