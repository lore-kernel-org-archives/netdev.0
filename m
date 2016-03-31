From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 2/6] tuntap: socket rx busy polling support
Date: Thu, 31 Mar 2016 13:50:35 +0800
Message-ID: <1459403439-6011-3-git-send-email-jasowang@redhat.com>
References: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index afdf950..950faf5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -69,6 +69,7 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/sock.h>
+#include <net/busy_poll.h>
 #include <linux/seq_file.h>
 #include <linux/uio.h>
 
@@ -871,6 +872,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	nf_reset(skb);
 
+	sk_mark_napi_id(tfile->socket.sk, skb);
 	/* Enqueue packet */
 	skb_queue_tail(&tfile->socket.sk->sk_receive_queue, skb);
 
@@ -878,7 +880,6 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (tfile->flags & TUN_FASYNC)
 		kill_fasync(&tfile->fasync, SIGIO, POLL_IN);
 	tfile->socket.sk->sk_data_ready(tfile->socket.sk);
-
 	rcu_read_unlock();
 	return NETDEV_TX_OK;
 
-- 
2.5.0
