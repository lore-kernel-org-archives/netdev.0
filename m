From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/4] u32: allow negative offset
Date: Mon, 02 Aug 2010 15:00:33 -0700
Message-ID: <20100802220113.731693525@vyatta.com>
References: <20100802220030.991706005@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58089 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754108Ab0HBWJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 18:09:38 -0400
Content-Disposition: inline; filename=u32-signed-offset.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was possible to use a negative offset in a u32 match to reference
the ethernet header or other parts of the link layer header.
This fixes the regression caused by:

commit fbc2e7d9cf49e0bf89b9e91fd60a06851a855c5d
Author: Changli Gao <xiaosuo@gmail.com>
Date:   Wed Jun 2 07:32:42 2010 -0700

    cls_u32: use skb_header_pointer() to dereference data safely


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/cls_u32.c	2010-08-01 09:26:20.734923805 -0700
+++ b/net/sched/cls_u32.c	2010-08-01 09:27:09.099851764 -0700
@@ -134,10 +134,9 @@ next_knode:
 #endif
 
 		for (i = n->sel.nkeys; i>0; i--, key++) {
-			unsigned int toff;
+			int toff = off + key->off + (off2 & key->offmask);
 			__be32 *data, _data;
-
-			toff = off + key->off + (off2 & key->offmask);
+
 			data = skb_header_pointer(skb, toff, 4, &_data);
 			if (!data)
 				goto out;


