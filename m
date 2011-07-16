From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Use calculated 'neigh' instead of re-evaluating
 dst->neighbour
Date: Sat, 16 Jul 2011 14:31:42 -0700 (PDT)
Message-ID: <20110716.143142.415381345010899435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084Ab1GPVbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2011 17:31:43 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6GLVg1I016118
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 16 Jul 2011 14:31:43 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/ip6_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index f0f144c..36362e9 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -141,7 +141,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 		if (hh->hh_len)
 			return neigh_hh_output(hh, skb);
 		else
-			return dst->neighbour->output(skb);
+			return neigh->output(skb);
 	}
 	IP6_INC_STATS_BH(dev_net(dst->dev),
 			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
-- 
1.7.6

