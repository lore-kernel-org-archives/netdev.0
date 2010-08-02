From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/4] net: add likely/unlikely to skb_header_pointer
Date: Mon, 02 Aug 2010 15:00:32 -0700
Message-ID: <20100802220113.643085589@vyatta.com>
References: <20100802220030.991706005@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58089 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752744Ab0HBWJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 18:09:37 -0400
Content-Disposition: inline; filename=u32-header-likely.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The expected case that should be optimized is that the offset is valid
and the data is available.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/skbuff.h	2010-08-01 11:20:15.872942674 -0700
+++ b/include/linux/skbuff.h	2010-08-01 11:20:59.513693007 -0700
@@ -1853,13 +1853,13 @@ static inline void *skb_header_pointer(c
 {
 	int hlen = skb_headlen(skb);
 
-	if (hlen + offset < 0)
+	if (unlikely(hlen + offset < 0))
 		return NULL;
 
-	if (hlen - offset >= len)
+	if (likely(hlen - offset >= len))
 		return skb->data + offset;
 
-	if (skb_copy_bits(skb, offset, buffer, len) < 0)
+	if (unlikely(skb_copy_bits(skb, offset, buffer, len) < 0))
 		return NULL;
 
 	return buffer;


