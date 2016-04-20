From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: nla_align_64bit() needs to test the right pointer.
Date: Wed, 20 Apr 2016 15:43:28 -0400 (EDT)
Message-ID: <20160420.154328.600123926132270366.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbcDTTnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 15:43:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Netlink messages are appended, one object at a time, to the end of
the SKB.  Therefore we need to test skb_tail_pointer(), not skb->data,
for alignment purposes.

Fixes: 35c5845957c7 ("net: Add helpers for 64-bit aligning netlink attributes.")
Signed-off-by: David S. Miller <davem@davemloft.net>
---

This is like a never ending story....

 include/net/netlink.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index cf95df1..3c1fd92 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1250,7 +1250,7 @@ static inline int nla_align_64bit(struct sk_buff *skb, int padattr)
 	 * nlattr header for next attribute, will make nla_data()
 	 * 8-byte aligned.
 	 */
-	if (IS_ALIGNED((unsigned long)skb->data, 8) &&
+	if (IS_ALIGNED((unsigned long)skb_tail_pointer(skb), 8) &&
 	    !nla_reserve(skb, padattr, 0))
 		return -EMSGSIZE;
 #endif
-- 
2.4.1
