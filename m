From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ipv4: return valid RTA_IIF on ip route get
Date: Sun, 13 Apr 2014 18:08:02 +0300
Message-ID: <1397401682-8615-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54734 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751268AbaDMPIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2014 11:08:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend commit 13378cad02afc2adc6c0e07fca03903c7ada0b37
("ipv4: Change rt->rt_iif encoding.") from 3.6 to return valid
RTA_IIF on 'ip route get ... iif DEVICE' instead of rt_iif 0
which is displayed as 'iif *'.

inet_iif is not appropriate to use because skb_iif is not set.
Use the skb->dev->ifindex instead.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 34d094c..20a59c3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2357,7 +2357,7 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 			}
 		} else
 #endif
-			if (nla_put_u32(skb, RTA_IIF, rt->rt_iif))
+			if (nla_put_u32(skb, RTA_IIF, skb->dev->ifindex))
 				goto nla_put_failure;
 	}
 
-- 
1.8.5.3
