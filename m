From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] macvtap: correctly free skb during socket destruction
Date: Tue, 19 Jul 2016 11:02:59 +0800
Message-ID: <1468897379-4373-1-git-send-email-jasowang@redhat.com>
Cc: dan.carpenter@oracle.com, Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should use kfree_skb() instead of kfree() to free an skb.

Fixes: 362899b8725b ("macvtap: switch to use skb array")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 9204d19..a38c0da 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -536,7 +536,7 @@ static void macvtap_sock_destruct(struct sock *sk)
 	struct sk_buff *skb;
 
 	while ((skb = skb_array_consume(&q->skb_array)) != NULL)
-		kfree(skb);
+		kfree_skb(skb);
 }
 
 static int macvtap_open(struct inode *inode, struct file *file)
-- 
2.7.4
