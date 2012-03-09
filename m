From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/4] ipv4: Make ip_call_ra_chain() return bool.
Date: Fri, 09 Mar 2012 14:36:23 -0800 (PST)
Message-ID: <20120309.143623.1802285302288594053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51116 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755803Ab2CIWgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 17:36:24 -0500
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q29MaNGX018611
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2012 14:36:23 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip.h    |    2 +-
 net/ipv4/ip_input.c |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 775009f..b53d65f 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -388,7 +388,7 @@ static inline int sk_mc_loop(struct sock *sk)
 	return 1;
 }
 
-extern int	ip_call_ra_chain(struct sk_buff *skb);
+extern bool ip_call_ra_chain(struct sk_buff *skb);
 
 /*
  *	Functions provided by ip_fragment.c
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 073a9b0..70afe5b 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -148,7 +148,7 @@
 /*
  *	Process Router Attention IP option (RFC 2113)
  */
-int ip_call_ra_chain(struct sk_buff *skb)
+bool ip_call_ra_chain(struct sk_buff *skb)
 {
 	struct ip_ra_chain *ra;
 	u8 protocol = ip_hdr(skb)->protocol;
@@ -167,7 +167,7 @@ int ip_call_ra_chain(struct sk_buff *skb)
 		    net_eq(sock_net(sk), dev_net(dev))) {
 			if (ip_is_fragment(ip_hdr(skb))) {
 				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN))
-					return 1;
+					return true;
 			}
 			if (last) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
@@ -180,9 +180,9 @@ int ip_call_ra_chain(struct sk_buff *skb)
 
 	if (last) {
 		raw_rcv(last, skb);
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
 static int ip_local_deliver_finish(struct sk_buff *skb)
-- 
1.7.6.5
