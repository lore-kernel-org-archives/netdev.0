From: Bart Samwel <bart@samwel.tk>
Subject: [PATCH] [TRIVIAL] "unsigned char"/"char" consistency?
Date: Sat, 24 Jan 2004 18:05:57 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <4012A5F5.2000804@samwel.tk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080708070903020808070107"
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080708070903020808070107
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi there,

I was just nosing around and I noticed a minor inconsistency in the 
usage of unsigned chars in skbuff push/pull functions. Almost all of 
these functions return unsigned chars, but there are two that return 
regular chars. Of course, this might be intentional, but AFAICS it 
probably isn't. If nobody has a reason why this must be like this, I 
suggest changing those two functions to return unsigned char as well. 
I've attached a patch that does this, it's against 2.6.2-rc1.

-- Bart

--------------080708070903020808070107
Content-Type: text/x-patch;
 name="unsigned_char_skbuff_pull.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="unsigned_char_skbuff_pull.patch"

diff -Naur linux-2.6.2-rc1/include/linux/skbuff.h linux-2.6.2-rc1-withunsigneds/include/linux/skbuff.h
--- linux-2.6.2-rc1/include/linux/skbuff.h	2004-01-09 07:59:44.000000000 +0100
+++ linux-2.6.2-rc1-withunsigneds/include/linux/skbuff.h	2004-01-24 16:40:42.000000000 +0100
@@ -871,7 +871,7 @@
 	return skb->data;
 }
 
-static inline char *__skb_pull(struct sk_buff *skb, unsigned int len)
+static inline unsigned char *__skb_pull(struct sk_buff *skb, unsigned int len)
 {
 	skb->len -= len;
 	BUG_ON(skb->len < skb->data_len);
@@ -895,7 +895,7 @@
 
 extern unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta);
 
-static inline char *__pskb_pull(struct sk_buff *skb, unsigned int len)
+static inline unsigned char *__pskb_pull(struct sk_buff *skb, unsigned int len)
 {
 	if (len > skb_headlen(skb) &&
 	    !__pskb_pull_tail(skb, len-skb_headlen(skb)))

--------------080708070903020808070107--
