From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/4] net: check for reference outside of skb
Date: Mon, 02 Aug 2010 15:00:31 -0700
Message-ID: <20100802220113.557212477@vyatta.com>
References: <20100802220030.991706005@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58089 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959Ab0HBWJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 18:09:36 -0400
Content-Disposition: inline; filename=u32-header-pointer.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is legitimate for callers of skb_header_pointer to pass a negative
offset, but the resulting pointer should not go outside the valid
range of data in the skb.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/skbuff.h	2010-08-01 09:23:01.635121262 -0700
+++ b/include/linux/skbuff.h	2010-08-01 09:25:27.453901530 -0700
@@ -1853,6 +1853,9 @@ static inline void *skb_header_pointer(c
 {
 	int hlen = skb_headlen(skb);
 
+	if (hlen + offset < 0)
+		return NULL;
+
 	if (hlen - offset >= len)
 		return skb->data + offset;
 


