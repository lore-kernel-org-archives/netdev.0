From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next] gre/ipip: use be16 variants of netlink functions
Date: Fri,  6 Feb 2015 17:22:22 +0100
Message-ID: <1423239742-30865-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:25862 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751388AbbBFQWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2015 11:22:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

encap.sport and encap.dport are __be16, use nla_{get,put}_be16 instead
of nla_{get,put}_u16.

Fixes the sparse warnings:

warning: incorrect type in assignment (different base types)
   expected restricted __be32 [addressable] [usertype] o_key
   got restricted __be16 [addressable] [usertype] i_flags
warning: incorrect type in assignment (different base types)
   expected restricted __be16 [usertype] sport
   got unsigned short
warning: incorrect type in assignment (different base types)
   expected restricted __be16 [usertype] dport
   got unsigned short
warning: incorrect type in argument 3 (different base types)
   expected unsigned short [unsigned] [usertype] value
   got restricted __be16 [usertype] sport
warning: incorrect type in argument 3 (different base types)
   expected unsigned short [unsigned] [usertype] value
   got restricted __be16 [usertype] dport

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/ipv4/ip_gre.c | 12 ++++++------
 net/ipv4/ipip.c   | 12 ++++++------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6e7727f27393..6207275fc749 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -659,12 +659,12 @@ static bool ipgre_netlink_encap_parms(struct nlattr *data[],
 
 	if (data[IFLA_GRE_ENCAP_SPORT]) {
 		ret = true;
-		ipencap->sport = nla_get_u16(data[IFLA_GRE_ENCAP_SPORT]);
+		ipencap->sport = nla_get_be16(data[IFLA_GRE_ENCAP_SPORT]);
 	}
 
 	if (data[IFLA_GRE_ENCAP_DPORT]) {
 		ret = true;
-		ipencap->dport = nla_get_u16(data[IFLA_GRE_ENCAP_DPORT]);
+		ipencap->dport = nla_get_be16(data[IFLA_GRE_ENCAP_DPORT]);
 	}
 
 	return ret;
@@ -786,10 +786,10 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 
 	if (nla_put_u16(skb, IFLA_GRE_ENCAP_TYPE,
 			t->encap.type) ||
-	    nla_put_u16(skb, IFLA_GRE_ENCAP_SPORT,
-			t->encap.sport) ||
-	    nla_put_u16(skb, IFLA_GRE_ENCAP_DPORT,
-			t->encap.dport) ||
+	    nla_put_be16(skb, IFLA_GRE_ENCAP_SPORT,
+			 t->encap.sport) ||
+	    nla_put_be16(skb, IFLA_GRE_ENCAP_DPORT,
+			 t->encap.dport) ||
 	    nla_put_u16(skb, IFLA_GRE_ENCAP_FLAGS,
 			t->encap.flags))
 		goto nla_put_failure;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index b58d6689874c..915d215a7d14 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -366,12 +366,12 @@ static bool ipip_netlink_encap_parms(struct nlattr *data[],
 
 	if (data[IFLA_IPTUN_ENCAP_SPORT]) {
 		ret = true;
-		ipencap->sport = nla_get_u16(data[IFLA_IPTUN_ENCAP_SPORT]);
+		ipencap->sport = nla_get_be16(data[IFLA_IPTUN_ENCAP_SPORT]);
 	}
 
 	if (data[IFLA_IPTUN_ENCAP_DPORT]) {
 		ret = true;
-		ipencap->dport = nla_get_u16(data[IFLA_IPTUN_ENCAP_DPORT]);
+		ipencap->dport = nla_get_be16(data[IFLA_IPTUN_ENCAP_DPORT]);
 	}
 
 	return ret;
@@ -460,10 +460,10 @@ static int ipip_fill_info(struct sk_buff *skb, const struct net_device *dev)
 
 	if (nla_put_u16(skb, IFLA_IPTUN_ENCAP_TYPE,
 			tunnel->encap.type) ||
-	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_SPORT,
-			tunnel->encap.sport) ||
-	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_DPORT,
-			tunnel->encap.dport) ||
+	    nla_put_be16(skb, IFLA_IPTUN_ENCAP_SPORT,
+			 tunnel->encap.sport) ||
+	    nla_put_be16(skb, IFLA_IPTUN_ENCAP_DPORT,
+			 tunnel->encap.dport) ||
 	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_FLAGS,
 			tunnel->encap.flags))
 		goto nla_put_failure;
-- 
2.3.0
