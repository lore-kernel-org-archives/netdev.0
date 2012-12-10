From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] virtio_net: fix a typo in virtnet_alloc_queues()
Date: Mon, 10 Dec 2012 20:24:08 +0800
Message-ID: <1355142248-19987-1-git-send-email-amwang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41673 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751046Ab2LJMYS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 07:24:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Obviously it should check !vi->rq.

Reported-by: Fengguang Wu <fengguang.wu@intel.com> 
Cc: Jason Wang <jasowang@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index a644eeb..68d64f0 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1347,7 +1347,7 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
 	if (!vi->sq)
 		goto err_sq;
 	vi->rq = kzalloc(sizeof(*vi->rq) * vi->max_queue_pairs, GFP_KERNEL);
-	if (!vi->sq)
+	if (!vi->rq)
 		goto err_rq;
 
 	INIT_DELAYED_WORK(&vi->refill, refill_work);
