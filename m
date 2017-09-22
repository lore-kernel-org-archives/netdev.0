From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] virtio-net: correctly set xdp_xmit for mergeable buffer
Date: Fri, 22 Sep 2017 14:38:58 +0800
Message-ID: <1506062338-3617-1-git-send-email-jasowang@redhat.com>
Cc: John Fastabend <john.fastabend@gmail.com>
To: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should set xdp_xmit only when xdp_do_redirect() succeed.

Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f6c1f13..dd14a45 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -721,7 +721,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			goto xdp_xmit;
 		case XDP_REDIRECT:
 			err = xdp_do_redirect(dev, &xdp, xdp_prog);
-			if (err)
+			if (!err)
 				*xdp_xmit = true;
 			rcu_read_unlock();
 			goto xdp_xmit;
-- 
2.7.4
