From: idosch@idosch.org
Subject: [PATCH net-next] net: core: Traverse the adjacency list from first entry
Date: Wed, 26 Oct 2016 09:39:22 +0300
Message-ID: <1477463962-2802-1-git-send-email-idosch@idosch.org>
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, Ido Schimmel <idosch@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:41919 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751792AbcJZGkS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 02:40:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

netdev_next_lower_dev() returns NULL when we finished traversing the
adjacency list ('iter' points to the list's head). Therefore, we must
start traversing the list from the first entry and not its head.

Fixes: 1a3f060c1a47 ("net: Introduce new api for walking upper and lower devices")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f55fb45..d9c937f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5419,7 +5419,7 @@ int netdev_walk_all_lower_dev(struct net_device *dev,
 	struct list_head *iter;
 	int ret;
 
-	for (iter = &dev->adj_list.lower,
+	for (iter = dev->adj_list.lower.next,
 	     ldev = netdev_next_lower_dev(dev, &iter);
 	     ldev;
 	     ldev = netdev_next_lower_dev(dev, &iter)) {
-- 
2.7.4
