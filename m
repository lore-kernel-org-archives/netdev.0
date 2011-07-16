From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Use calculated 'neigh' instead of re-evaluating
 dst->neighbour
Date: Sat, 16 Jul 2011 14:26:22 -0700 (PDT)
Message-ID: <20110716.142622.2055046891903048230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534Ab1GPV0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2011 17:26:24 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6GLQMEa015885
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 16 Jul 2011 14:26:24 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index a621b96..1ac674a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -210,7 +210,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 		if (hh->hh_len)
 			return neigh_hh_output(hh, skb);
 		else
-			return dst->neighbour->output(skb);
+			return neigh->output(skb);
 	}
 	if (net_ratelimit())
 		printk(KERN_DEBUG "ip_finish_output2: No header cache and no neighbour!\n");
-- 
1.7.6

