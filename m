From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] skbuff: skb_store_bits const is backwards
Date: Fri, 20 Apr 2007 16:13:14 -0700
Message-ID: <20070420161314.21e8fa24@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:60475 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750700AbXDTXOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 19:14:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Getting warnings becuase skb_store_bits has skb as constant,
but the function overwrites it. Looks like const was on the
wrong side.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 include/linux/skbuff.h |    4 ++--
 net/core/skbuff.c      |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

--- net-2.6.22.orig/include/linux/skbuff.h
+++ net-2.6.22/include/linux/skbuff.h
@@ -1491,8 +1491,8 @@ extern __wsum	       skb_checksum(const 
 				    int len, __wsum csum);
 extern int	       skb_copy_bits(const struct sk_buff *skb, int offset,
 				     void *to, int len);
-extern int	       skb_store_bits(const struct sk_buff *skb, int offset,
-				      void *from, int len);
+extern int	       skb_store_bits(struct sk_buff *skb, int offset,
+				      const void *from, int len);
 extern __wsum	       skb_copy_and_csum_bits(const struct sk_buff *skb,
 					      int offset, u8 *to, int len,
 					      __wsum csum);
--- net-2.6.22.orig/net/core/skbuff.c
+++ net-2.6.22/net/core/skbuff.c
@@ -1188,7 +1188,7 @@ fault:
  *	traversing fragment lists and such.
  */
 
-int skb_store_bits(const struct sk_buff *skb, int offset, void *from, int len)
+int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len)
 {
 	int i, copy;
 	int start = skb_headlen(skb);
