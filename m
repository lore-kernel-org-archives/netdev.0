From: xiaohui.xin@intel.com
Subject: [PATCH] deal with if frags[0].size is pulled to 0 in dev_gro_receive()
Date: Tue,  3 Aug 2010 11:17:19 +0800
Message-ID: <1280805439-18988-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18483 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753339Ab0HCDDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 23:03:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

Now in dev_gro_receive(), if frags[0].size is pulled to 0, memmove is called and
the null page is released. But it's not enough, we should reset size of each frags
left as well. Compared to this, we can have another way to do this, it's not do do
anything at all.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>

---
 net/core/dev.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 264137f..28cdbbf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2730,13 +2730,6 @@ pull:
 
 		skb_shinfo(skb)->frags[0].page_offset += grow;
 		skb_shinfo(skb)->frags[0].size -= grow;
-
-		if (unlikely(!skb_shinfo(skb)->frags[0].size)) {
-			put_page(skb_shinfo(skb)->frags[0].page);
-			memmove(skb_shinfo(skb)->frags,
-				skb_shinfo(skb)->frags + 1,
-				--skb_shinfo(skb)->nr_frags);
-		}
 	}
 
 ok:
-- 
1.5.4.4

