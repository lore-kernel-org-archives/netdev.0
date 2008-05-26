From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 3/3] virtio: Use __skb_queue_purge()
Date: Mon, 26 May 2008 17:53:23 +1000
Message-ID: <200805261753.23860.rusty@rustcorp.com.au>
References: <200805261742.43215.rusty@rustcorp.com.au> <200805261748.13449.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>,
	Wang Chen <wangchen@cn.fujitsu.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:55399 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752750AbYEZHxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 03:53:52 -0400
In-Reply-To: <200805261748.13449.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>

Use standard routine for queue purging.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f926b5a..fe7cdf2 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -470,8 +470,7 @@ static void virtnet_remove(struct virtio_device *vdev)
 		kfree_skb(skb);
 		vi->num--;
 	}
-	while ((skb = __skb_dequeue(&vi->send)) != NULL)
-		kfree_skb(skb);
+	__skb_queue_purge(&vi->send);
 
 	BUG_ON(vi->num != 0);
 
