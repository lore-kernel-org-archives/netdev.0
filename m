From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bridge: add a missing ntohs()
Date: Tue, 20 Apr 2010 15:20:05 +0200
Message-ID: <1271769605.7895.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:34927 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754647Ab0DTNUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 09:20:14 -0400
Received: by bwz19 with SMTP id 19so14265bwz.21
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 06:20:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found by code review and sparse endianness warning, I am not sure this
patch is valid.

Thanks

[PATCH] bridge: add a missing ntohs()

grec_nsrcs is in network order, we should convert to host horder in
br_multicast_igmp3_report()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index f29ada8..386c153 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -727,7 +727,7 @@ static int br_multicast_igmp3_report(struct net_bridge *br,
 		group = grec->grec_mca;
 		type = grec->grec_type;
 
-		len += grec->grec_nsrcs * 4;
+		len += ntohs(grec->grec_nsrcs) * 4;
 		if (!pskb_may_pull(skb, len))
 			return -EINVAL;
 



