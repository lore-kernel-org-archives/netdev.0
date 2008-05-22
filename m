From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/2] VIRTIO: Use __skb_queue_purge()
Date: Thu, 22 May 2008 18:07:43 +0800
Message-ID: <483545EF.3070501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>,
	Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51614 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759230AbYEVKKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:10:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use standard routine for queue purging.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/virtio_net.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

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
 
-- 
1.5.4.rc3


