From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net-sysfs: get_netdev_queue_index() cleanup
Date: Thu, 13 Feb 2014 10:07:13 -0800
Message-ID: <1392314833.1752.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:64141 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbaBMSHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 13:07:14 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so10867712pde.0
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 10:07:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Remove one inline keyword, and no need for a loop to find
an index into a table.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/net-sysfs.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 93886246a0b4..73aa594674ef 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -996,15 +996,12 @@ static struct attribute_group dql_group = {
 #endif /* CONFIG_BQL */
 
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
