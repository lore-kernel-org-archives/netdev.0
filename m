From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make skb_{under,over}_panic() static
Date: Mon, 21 Apr 2008 11:48:05 +0300
Message-ID: <20080421084805.GL26897@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:58316 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756423AbYDUIse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 04:48:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_{under,over}_panic() can now become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/linux/skbuff.h |    4 ----
 net/core/skbuff.c      |    6 ++----
 2 files changed, 2 insertions(+), 8 deletions(-)

7bb1567021c093a87aeabdabf129ba7a4d70779f diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 11fd9f2..7bf66ba 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -385,10 +385,6 @@ extern int	       skb_cow_data(struct sk_buff *skb, int tailbits,
 				    struct sk_buff **trailer);
 extern int	       skb_pad(struct sk_buff *skb, int pad);
 #define dev_kfree_skb(a)	kfree_skb(a)
-extern void	      skb_over_panic(struct sk_buff *skb, int len,
-				     void *here);
-extern void	      skb_under_panic(struct sk_buff *skb, int len,
-				      void *here);
 extern void	      skb_truesize_bug(struct sk_buff *skb);
 
 static inline void skb_truesize_check(struct sk_buff *skb)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4fe605f..08beac8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -120,7 +120,7 @@ static struct pipe_buf_operations sock_pipe_buf_ops = {
  *
  *	Out of line support code for skb_put(). Not user callable.
  */
-void skb_over_panic(struct sk_buff *skb, int sz, void *here)
+static void skb_over_panic(struct sk_buff *skb, int sz, void *here)
 {
 	printk(KERN_EMERG "skb_over_panic: text:%p len:%d put:%d head:%p "
 			  "data:%p tail:%#lx end:%#lx dev:%s\n",
@@ -139,7 +139,7 @@ void skb_over_panic(struct sk_buff *skb, int sz, void *here)
  *	Out of line support code for skb_push(). Not user callable.
  */
 
-void skb_under_panic(struct sk_buff *skb, int sz, void *here)
+static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
 {
 	printk(KERN_EMERG "skb_under_panic: text:%p len:%d put:%d head:%p "
 			  "data:%p tail:%#lx end:%#lx dev:%s\n",
@@ -2597,10 +2597,8 @@ EXPORT_SYMBOL(skb_copy_and_csum_bits);
 EXPORT_SYMBOL(skb_copy_and_csum_dev);
 EXPORT_SYMBOL(skb_copy_bits);
 EXPORT_SYMBOL(skb_copy_expand);
-EXPORT_SYMBOL(skb_over_panic);
 EXPORT_SYMBOL(skb_pad);
 EXPORT_SYMBOL(skb_realloc_headroom);
-EXPORT_SYMBOL(skb_under_panic);
 EXPORT_SYMBOL(skb_dequeue);
 EXPORT_SYMBOL(skb_dequeue_tail);
 EXPORT_SYMBOL(skb_insert);

