From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/24] ax25: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:23 -0700
Message-ID: <a426e678426cf2be1552edfbbb0de7ce08e9a7ef.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joerg Reuter <jreuter@yaina.de>, Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ax25/ax25_dev.c   |    5 ++---
 net/ax25/ax25_out.c   |    8 ++++----
 net/ax25/ax25_route.c |    5 ++---
 3 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/ax25/ax25_dev.c b/net/ax25/ax25_dev.c
index c1cb982..986908a 100644
--- a/net/ax25/ax25_dev.c
+++ b/net/ax25/ax25_dev.c
@@ -55,10 +55,9 @@ void ax25_dev_device_up(struct net_device *dev)
 {
 	ax25_dev *ax25_dev;
 
-	if ((ax25_dev = kzalloc(sizeof(*ax25_dev), GFP_ATOMIC)) == NULL) {
-		printk(KERN_ERR "AX.25: ax25_dev_device_up - out of memory\n");
+	ax25_dev = kzalloc(sizeof(*ax25_dev), GFP_ATOMIC);
+	if (ax25_dev == NULL)
 		return;
-	}
 
 	ax25_unregister_sysctl();
 
diff --git a/net/ax25/ax25_out.c b/net/ax25/ax25_out.c
index 37507d8..a27046d 100644
--- a/net/ax25/ax25_out.c
+++ b/net/ax25/ax25_out.c
@@ -146,9 +146,9 @@ void ax25_output(ax25_cb *ax25, int paclen, struct sk_buff *skb)
 
 		while (skb->len > 0) {
 			spin_lock_bh(&ax25_frag_lock);
-			if ((skbn = alloc_skb(paclen + 2 + frontlen, GFP_ATOMIC)) == NULL) {
+			skbn = alloc_skb(paclen + 2 + frontlen, GFP_ATOMIC);
+			if (skbn == NULL) {
 				spin_unlock_bh(&ax25_frag_lock);
-				printk(KERN_CRIT "AX.25: ax25_output - out of memory\n");
 				return;
 			}
 
@@ -342,8 +342,8 @@ void ax25_transmit_buffer(ax25_cb *ax25, struct sk_buff *skb, int type)
 	headroom = ax25_addr_size(ax25->digipeat);
 
 	if (skb_headroom(skb) < headroom) {
-		if ((skbn = skb_realloc_headroom(skb, headroom)) == NULL) {
-			printk(KERN_CRIT "AX.25: ax25_transmit_buffer - out of memory\n");
+		skbn = skb_realloc_headroom(skb, headroom);
+		if (skbn == NULL) {
 			kfree_skb(skb);
 			return;
 		}
diff --git a/net/ax25/ax25_route.c b/net/ax25/ax25_route.c
index a169084..75e67c0 100644
--- a/net/ax25/ax25_route.c
+++ b/net/ax25/ax25_route.c
@@ -466,10 +466,9 @@ struct sk_buff *ax25_rt_build_path(struct sk_buff *skb, ax25_address *src,
 	len = digi->ndigi * AX25_ADDR_LEN;
 
 	if (skb_headroom(skb) < len) {
-		if ((skbn = skb_realloc_headroom(skb, len)) == NULL) {
-			printk(KERN_CRIT "AX.25: ax25_dg_build_path - out of memory\n");
+		skbn = skb_realloc_headroom(skb, len);
+		if (skbn == NULL)
 			return NULL;
-		}
 
 		if (skb->sk != NULL)
 			skb_set_owner_w(skbn, skb->sk);
-- 
1.7.6.405.gc1be0
