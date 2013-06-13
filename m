From: Jason Wang <jasowang@redhat.com>
Subject: [net-next PATCH V2 1/2] macvtap: slient sparse warnings
Date: Thu, 13 Jun 2013 14:23:35 +0800
Message-ID: <1371104616-18319-1-git-send-email-jasowang@redhat.com>
Cc: edumazet@google.com, Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch silents the following sparse warnings:

drivers/net/macvtap.c:98:9: warning: incorrect type in assignment (different
address spaces)
drivers/net/macvtap.c:98:9:    expected struct macvtap_queue *<noident>
drivers/net/macvtap.c:98:9:    got struct macvtap_queue [noderef]
<asn:4>*<noident>
drivers/net/macvtap.c:120:9: warning: incorrect type in assignment (different
address spaces)
drivers/net/macvtap.c:120:9:    expected struct macvtap_queue *<noident>
drivers/net/macvtap.c:120:9:    got struct macvtap_queue [noderef]
<asn:4>*<noident>
drivers/net/macvtap.c:151:22: error: incompatible types in comparison expression
(different address spaces)
drivers/net/macvtap.c:233:23: error: incompatible types in comparison expression
(different address spaces)
drivers/net/macvtap.c:243:23: error: incompatible types in comparison expression
(different address spaces)
drivers/net/macvtap.c:247:15: error: incompatible types in comparison expression
(different address spaces)
  CC [M]  drivers/net/macvtap.o
drivers/net/macvlan.c:232:24: error: incompatible types in comparison expression
(different address spaces)

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c      |    2 +-
 include/linux/if_macvlan.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 992151c..edcbf1c 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -429,7 +429,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	if (!q)
 		goto out;
 
-	q->sock.wq = &q->wq;
+	RCU_INIT_POINTER(q->sock.wq, &q->wq);
 	init_waitqueue_head(&q->wq.wait);
 	q->sock.type = SOCK_RAW;
 	q->sock.state = SS_CONNECTED;
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 1912133..f49a9f6 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -70,7 +70,7 @@ struct macvlan_dev {
 	int (*receive)(struct sk_buff *skb);
 	int (*forward)(struct net_device *dev, struct sk_buff *skb);
 	/* This array tracks active taps. */
-	struct macvtap_queue	*taps[MAX_MACVTAP_QUEUES];
+	struct macvtap_queue	__rcu *taps[MAX_MACVTAP_QUEUES];
 	/* This list tracks all taps (both enabled and disabled) */
 	struct list_head	queue_list;
 	int			numvtaps;
-- 
1.7.1
