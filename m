From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 11/17] net: rename IP_ADD_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:37 -0700
Message-ID: <1461800683-25034-12-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33812 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717AbcD0XpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:18 -0400
Received: by mail-pa0-f49.google.com with SMTP id r5so25337931pag.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:18 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename IP_ADD_STATS_BH() to __IP_ADD_STATS()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip.h      | 2 +-
 net/ipv4/ip_forward.c | 2 +-
 net/ipv4/ip_input.c   | 6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 0be0af3017ba..0df4809bc68a 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -189,7 +189,7 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 #define IP_INC_STATS(net, field)	SNMP_INC_STATS64((net)->mib.ip_statistics, field)
 #define __IP_INC_STATS(net, field)	SNMP_INC_STATS64_BH((net)->mib.ip_statistics, field)
 #define IP_ADD_STATS(net, field, val)	SNMP_ADD_STATS64((net)->mib.ip_statistics, field, val)
-#define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS64_BH((net)->mib.ip_statistics, field, val)
+#define __IP_ADD_STATS(net, field, val) SNMP_ADD_STATS64_BH((net)->mib.ip_statistics, field, val)
 #define IP_UPD_PO_STATS(net, field, val) SNMP_UPD_PO_STATS64((net)->mib.ip_statistics, field, val)
 #define IP_UPD_PO_STATS_BH(net, field, val) SNMP_UPD_PO_STATS64_BH((net)->mib.ip_statistics, field, val)
 #define NET_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.net_statistics, field)
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 42fbd59b0ba8..cbfb1808fcc4 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -66,7 +66,7 @@ static int ip_forward_finish(struct net *net, struct sock *sk, struct sk_buff *s
 	struct ip_options *opt	= &(IPCB(skb)->opt);
 
 	__IP_INC_STATS(net, IPSTATS_MIB_OUTFORWDATAGRAMS);
-	IP_ADD_STATS_BH(net, IPSTATS_MIB_OUTOCTETS, skb->len);
+	__IP_ADD_STATS(net, IPSTATS_MIB_OUTOCTETS, skb->len);
 
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index cca6729cd6ee..11f34e421270 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -439,9 +439,9 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	BUILD_BUG_ON(IPSTATS_MIB_ECT1PKTS != IPSTATS_MIB_NOECTPKTS + INET_ECN_ECT_1);
 	BUILD_BUG_ON(IPSTATS_MIB_ECT0PKTS != IPSTATS_MIB_NOECTPKTS + INET_ECN_ECT_0);
 	BUILD_BUG_ON(IPSTATS_MIB_CEPKTS != IPSTATS_MIB_NOECTPKTS + INET_ECN_CE);
-	IP_ADD_STATS_BH(net,
-			IPSTATS_MIB_NOECTPKTS + (iph->tos & INET_ECN_MASK),
-			max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));
+	__IP_ADD_STATS(net,
+		       IPSTATS_MIB_NOECTPKTS + (iph->tos & INET_ECN_MASK),
+		       max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));
 
 	if (!pskb_may_pull(skb, iph->ihl*4))
 		goto inhdr_error;
-- 
2.8.0.rc3.226.g39d4020
