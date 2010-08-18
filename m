From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 2/8] net: rps: skip fragment when computing rxhash
Date: Wed, 18 Aug 2010 13:01:38 +0800
Message-ID: <1282107698-3456-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:36333 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297Ab0HRFBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 01:01:52 -0400
Received: by pvg2 with SMTP id 2so56027pvg.19
        for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 22:01:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fragmented IP packets may have no transfer header, so when computing
rxhash, we should skip them.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/dev.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index 3f82781..b7c5309 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2284,7 +2284,10 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 			goto done;
 
 		ip = (struct iphdr *) skb->data + nhoff;
-		ip_proto = ip->protocol;
+		if (ip->frag_off & htons(IP_MF|IP_OFFSET))
+			ip_proto = 0;
+		else
+			ip_proto = ip->protocol;
 		addr1 = (__force u32) ip->saddr;
 		addr2 = (__force u32) ip->daddr;
 		ihl = ip->ihl;
