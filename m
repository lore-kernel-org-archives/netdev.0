From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/7] gre6: Call skb_checksum_simple_validate
Date: Wed, 7 May 2014 16:51:57 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405071642400.874@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:59005 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbaEGXv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 19:51:58 -0400
Received: by mail-pd0-f201.google.com with SMTP id r10so297424pdi.4
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 16:51:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use skb_checksum_simple_validate to verify checksum.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/ip6_gre.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 75277b7..3873181 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -468,17 +468,7 @@ static int ip6gre_rcv(struct sk_buff *skb)
 			goto drop;
 
 		if (flags&GRE_CSUM) {
-			switch (skb->ip_summed) {
-			case CHECKSUM_COMPLETE:
-				csum = csum_fold(skb->csum);
-				if (!csum)
-					break;
-				/* fall through */
-			case CHECKSUM_NONE:
-				skb->csum = 0;
-				csum = __skb_checksum_complete(skb);
-				skb->ip_summed = CHECKSUM_COMPLETE;
-			}
+			csum = skb_checksum_simple_validate(skb);
 			offset += 4;
 		}
 		if (flags&GRE_KEY) {
-- 
1.9.1.423.g4596e3a
