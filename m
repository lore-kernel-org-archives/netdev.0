From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [PATCH] move inline keywords nearer beginning of declaration in
 skbuff.c to elliminate warning with gcc -W
Date: Wed, 24 Nov 2004 01:16:05 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0411240106580.3389@dragon.hygekrogen.localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261618AbUKXAJl@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In order to get rid of 
net/core/skbuff.c:1353: warning: `inline' is not at beginning of declaration
net/core/skbuff.c:1374: warning: `inline' is not at beginning of declaration
when building with gcc -W, I submit the patch below.
There's no impact on the way the code works, so it is perfectly safe. It 
just brings the count of warnings that I have to sift through down by two 
(yes, I know the kernel is not normally build with -W, but I do it to 
look for stuff that potentially needs review, and the less warnings I 
have to sift through the better). I see no good reason not to apply this.
Please apply.

Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>

diff -up linux-2.6.10-rc2-bk6-orig/net/core/skbuff.c linux-2.6.10-rc2-bk6/net/core/skbuff.c
--- linux-2.6.10-rc2-bk6-orig/net/core/skbuff.c	2004-11-17 01:20:32.000000000 +0100
+++ linux-2.6.10-rc2-bk6/net/core/skbuff.c	2004-11-24 01:05:32.000000000 +0100
@@ -1350,7 +1350,7 @@ void skb_add_mtu(int mtu)
 }
 #endif
 
-static void inline skb_split_inside_header(struct sk_buff *skb,
+static inline void skb_split_inside_header(struct sk_buff *skb,
 					   struct sk_buff* skb1,
 					   const u32 len, const int pos)
 {
@@ -1371,7 +1371,7 @@ static void inline skb_split_inside_head
 	skb->tail		   = skb->data + len;
 }
 
-static void inline skb_split_no_header(struct sk_buff *skb,
+static inline void skb_split_no_header(struct sk_buff *skb,
 				       struct sk_buff* skb1,
 				       const u32 len, int pos)
 {
