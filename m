From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/7] igmp: Call skb_checksum_simple_validate
Date: Wed, 7 May 2014 16:52:10 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405071642550.895@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:48050 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbaEGXwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 19:52:11 -0400
Received: by mail-oa0-f73.google.com with SMTP id i4so393380oah.0
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 16:52:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use skb_checksum_simple_validate to verify checksum.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/igmp.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 97e4d16..17d34e3 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -988,16 +988,8 @@ int igmp_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct igmphdr)))
 		goto drop;
 
-	switch (skb->ip_summed) {
-	case CHECKSUM_COMPLETE:
-		if (!csum_fold(skb->csum))
-			break;
-		/* fall through */
-	case CHECKSUM_NONE:
-		skb->csum = 0;
-		if (__skb_checksum_complete(skb))
-			goto drop;
-	}
+	if (skb_checksum_simple_validate(skb))
+		goto drop;
 
 	ih = igmp_hdr(skb);
 	switch (ih->type) {
-- 
1.9.1.423.g4596e3a
