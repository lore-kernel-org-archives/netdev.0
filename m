From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: [PATCH] net-sysfs: get_netdev_queue_index() cleanup
Date: Fri, 11 Sep 2015 17:08:39 -0300
Message-ID: <1442002119-15823-1-git-send-email-cascardo@redhat.com>
Cc: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004AbbIKUI7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2015 16:08:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Redo commit ed1acc8cd8c22efa919da8d300bab646e01c2dce.

Commit 822b3b2ebfff8e9b3d006086c527738a7ca00cd0 ("net: Add max rate tx queue
attribute") moved get_netdev_queue_index around, but kept the old version.
Probably because of a reuse of the original patch from before Eric's change to
that function.

Remove one inline keyword, and no need for a loop to find
an index into a table.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Fixes: 822b3b2ebfff8e9b3d006086c527738a7ca00cd0
Cc: Or Gerlitz <ogerlitz@mellanox.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Eric Dumazet <edumazet@google.com>
---

Not sure what is the best way to credit Eric Dumazet here. I assume he will add
any appropriate tags.

---
 net/core/net-sysfs.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b279077..49b5990 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1004,15 +1004,12 @@ static ssize_t show_trans_timeout(struct netdev_queue *queue,
 }
 
 #ifdef CONFIG_XPS
-static inline unsigned int get_netdev_queue_index(struct netdev_queue *queue)
+static unsigned int get_netdev_queue_index(struct netdev_queue *queue)
 {
 	struct net_device *dev = queue->dev;
-	int i;
-
-	for (i = 0; i < dev->num_tx_queues; i++)
-		if (queue == &dev->_tx[i])
-			break;
+	unsigned int i;
 
+	i = queue - dev->_tx;
 	BUG_ON(i >= dev->num_tx_queues);
 
 	return i;
-- 
2.4.3
