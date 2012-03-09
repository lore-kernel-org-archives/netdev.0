From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/4] ipv4: Make ip_rcv_options() return bool.
Date: Fri, 09 Mar 2012 14:36:25 -0800 (PST)
Message-ID: <20120309.143625.1871443879443526104.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755803Ab2CIWg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 17:36:26 -0500
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q29MaP3n018616
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2012 14:36:25 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_input.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 70afe5b..bdaa2c5 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -265,7 +265,7 @@ int ip_local_deliver(struct sk_buff *skb)
 		       ip_local_deliver_finish);
 }
 
-static inline int ip_rcv_options(struct sk_buff *skb)
+static inline bool ip_rcv_options(struct sk_buff *skb)
 {
 	struct ip_options *opt;
 	const struct iphdr *iph;
@@ -309,9 +309,9 @@ static inline int ip_rcv_options(struct sk_buff *skb)
 			goto drop;
 	}
 
-	return 0;
+	return false;
 drop:
-	return -1;
+	return true;
 }
 
 static int ip_rcv_finish(struct sk_buff *skb)
-- 
1.7.6.5
