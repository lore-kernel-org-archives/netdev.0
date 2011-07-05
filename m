From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 3/4] ipv4: Add ip_defrag() agent IP_DEFRAG_AF_PACKET.
Date: Tue, 05 Jul 2011 02:04:22 -0700 (PDT)
Message-ID: <20110705.020422.1439937219658297425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: victor@inliniac.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407Ab1GEJE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 05:04:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Elide the ICMP on frag queue timeouts unconditionally for
this user.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip.h       |    3 ++-
 net/ipv4/ip_fragment.c |    5 +++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 9fa9416..aa76c7a 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -404,7 +404,8 @@ enum ip_defrag_users {
 	__IP_DEFRAG_CONNTRACK_BRIDGE_IN = IP_DEFRAG_CONNTRACK_BRIDGE_IN + USHRT_MAX,
 	IP_DEFRAG_VS_IN,
 	IP_DEFRAG_VS_OUT,
-	IP_DEFRAG_VS_FWD
+	IP_DEFRAG_VS_FWD,
+	IP_DEFRAG_AF_PACKET,
 };
 
 int ip_defrag(struct sk_buff *skb, u32 user);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 0ad6035..0e0ab98 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -261,8 +261,9 @@ static void ip_expire(unsigned long arg)
 		 * Only an end host needs to send an ICMP
 		 * "Fragment Reassembly Timeout" message, per RFC792.
 		 */
-		if (qp->user == IP_DEFRAG_CONNTRACK_IN &&
-		    skb_rtable(head)->rt_type != RTN_LOCAL)
+		if (qp->user == IP_DEFRAG_AF_PACKET ||
+		    (qp->user == IP_DEFRAG_CONNTRACK_IN &&
+		     skb_rtable(head)->rt_type != RTN_LOCAL))
 			goto out_rcu_unlock;
 
 
-- 
1.7.5.4

