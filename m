From: Hermin Anggawijaya <hermin.anggawijaya@alliedtelesis.co.nz>
Subject: [PATCH v2] ipv6: Make MLD packets to only be processed locally
Date: Fri,  3 Jul 2015 14:40:52 +1200
Message-ID: <1435891252-3938-1-git-send-email-hermin.anggawijaya@alliedtelesis.co.nz>
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	hermin.anggawijaya@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:59612 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374AbbGCClL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 22:41:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before commit daad151263cf ("ipv6: Make ipv6_is_mld() inline and use it
from ip6_mc_input().") MLD packets were only processed locally. After the
change, a copy of MLD packet goes through ip6_mr_input, causing
MRT6MSG_NOCACHE message to be generated to user space.

Make MLD packet only processed locally.

Fixes: daad151263cf ("ipv6: Make ipv6_is_mld() inline and use it from 
ip6_mc_input().")

Signed-off-by: Hermin Anggawijaya <hermin.anggawijaya@alliedtelesis.co.nz>
---
 net/ipv6/ip6_input.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index f2e464e..57990c9 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -331,10 +331,10 @@ int ip6_mc_input(struct sk_buff *skb)
 				if (offset < 0)
 					goto out;
 
-				if (!ipv6_is_mld(skb, nexthdr, offset))
-					goto out;
+				if (ipv6_is_mld(skb, nexthdr, offset))
+					deliver = true;
 
-				deliver = true;
+				goto out;
 			}
 			/* unknown RA - process it normally */
 		}
-- 
1.9.1
