From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [PACKET] LL_RESERVED_SPACE
Date: Mon, 09 Feb 2004 13:43:41 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209.134341.43254113.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

D: [PACKET] Use LL_RESERVED_SPACE() where appricable.

===== net/packet/af_packet.c 1.40 vs edited =====
--- 1.40/net/packet/af_packet.c	Sat Feb  7 06:30:12 2004
+++ edited/net/packet/af_packet.c	Mon Feb  9 12:41:20 2004
@@ -327,7 +327,7 @@
 		goto out_unlock;
 
 	err = -ENOBUFS;
-	skb = sock_wmalloc(sk, len+dev->hard_header_len+15, 0, GFP_KERNEL);
+	skb = sock_wmalloc(sk, len + LL_RESERVED_SPACE(dev), 0, GFP_KERNEL);
 
 	/*
 	 *	If the write buffer is full, then tough. At this level the user gets to
@@ -346,7 +346,7 @@
 	 * hard header at transmission time by themselves. PPP is the
 	 * notable one here. This should really be fixed at the driver level.
 	 */
-	skb_reserve(skb,(dev->hard_header_len+15)&~15);
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	skb->nh.raw = skb->data;
 
 	/* Try to align data part correctly */
@@ -700,12 +700,12 @@
 	if (len > dev->mtu+reserve)
 		goto out_unlock;
 
-	skb = sock_alloc_send_skb(sk, len+dev->hard_header_len+15, 
+	skb = sock_alloc_send_skb(sk, len + LL_RESERVED_SPACE(dev),
 				msg->msg_flags & MSG_DONTWAIT, &err);
 	if (skb==NULL)
 		goto out_unlock;
 
-	skb_reserve(skb, (dev->hard_header_len+15)&~15);
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	skb->nh.raw = skb->data;
 
 	if (dev->hard_header) {

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
