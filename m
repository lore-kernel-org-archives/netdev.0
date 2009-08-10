From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH] fix memory leak in virtio_net
Date: Mon, 10 Aug 2009 13:05:08 -0700
Message-ID: <1249934708.7400.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Why0umBOxGz2UWiN5Nja"
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Why0umBOxGz2UWiN5Nja
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Whild reading virtio code, I found some memory leak in removing
virtio_net.

In virtnet_remove, only skb has been freed not the pages in skb
frags. Here is the patch to fix this, please review it.

Signed-off-by: Shirley Ma <xma@us.ibm.com>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 2a6e81d..7e629d9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -978,6 +978,7 @@ static void virtnet_remove(struct virtio_device *vdev)
 
 	/* Free our skbs in send and recv queues, if any. */
 	while ((skb = __skb_dequeue(&vi->recv)) != NULL) {
+		trim_pages(vi, skb);
 		kfree_skb(skb);
 		vi->num--;
 	}





--=-Why0umBOxGz2UWiN5Nja
Content-Disposition: attachment; filename="memleak.patch"
Content-Type: text/x-patch; name="memleak.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Signed-off-by: Shirley Ma <xma@us.ibm.com>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 2a6e81d..7e629d9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -978,6 +978,7 @@ static void virtnet_remove(struct virtio_device *vdev)
 
 	/* Free our skbs in send and recv queues, if any. */
 	while ((skb = __skb_dequeue(&vi->recv)) != NULL) {
+		trim_pages(vi, skb);
 		kfree_skb(skb);
 		vi->num--;
 	}

--=-Why0umBOxGz2UWiN5Nja--

