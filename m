From: Joe Perches <joe@perches.com>
Subject: [PATCH 23/24] x25: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:42 -0700
Message-ID: <a4253b35f596dbe4b1079ff90412d4b51334c010.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:43959 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755249Ab1H2VWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 17:22:21 -0400
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/x25/x25_dev.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index e547ca1..b77852f 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -147,10 +147,10 @@ void x25_establish_link(struct x25_neigh *nb)
 
 	switch (nb->dev->type) {
 	case ARPHRD_X25:
-		if ((skb = alloc_skb(1, GFP_ATOMIC)) == NULL) {
-			printk(KERN_ERR "x25_dev: out of memory\n");
+		skb = alloc_skb(1, GFP_ATOMIC);
+		if (skb == NULL)
 			return;
-		}
+
 		ptr  = skb_put(skb, 1);
 		*ptr = X25_IFACE_CONNECT;
 		break;
@@ -182,10 +182,8 @@ void x25_terminate_link(struct x25_neigh *nb)
 		return;
 
 	skb = alloc_skb(1, GFP_ATOMIC);
-	if (!skb) {
-		printk(KERN_ERR "x25_dev: out of memory\n");
+	if (!skb)
 		return;
-	}
 
 	ptr  = skb_put(skb, 1);
 	*ptr = X25_IFACE_DISCONNECT;
-- 
1.7.6.405.gc1be0
