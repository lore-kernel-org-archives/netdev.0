From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 12/17] net: rename IP_UPD_PO_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:38 -0700
Message-ID: <1461800683-25034-13-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34222 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882AbcD0XpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:20 -0400
Received: by mail-pf0-f178.google.com with SMTP id y69so26275589pfb.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:20 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename IP_UPD_PO_STATS_BH() to __IP_UPD_PO_STATS()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip.h    | 2 +-
 net/ipv4/ip_input.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 0df4809bc68a..55f5de50a564 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -191,7 +191,7 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 #define IP_ADD_STATS(net, field, val)	SNMP_ADD_STATS64((net)->mib.ip_statistics, field, val)
 #define __IP_ADD_STATS(net, field, val) SNMP_ADD_STATS64_BH((net)->mib.ip_statistics, field, val)
 #define IP_UPD_PO_STATS(net, field, val) SNMP_UPD_PO_STATS64((net)->mib.ip_statistics, field, val)
-#define IP_UPD_PO_STATS_BH(net, field, val) SNMP_UPD_PO_STATS64_BH((net)->mib.ip_statistics, field, val)
+#define __IP_UPD_PO_STATS(net, field, val) SNMP_UPD_PO_STATS64_BH((net)->mib.ip_statistics, field, val)
 #define NET_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.net_statistics, field)
 #define NET_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.net_statistics, field)
 #define NET_ADD_STATS(net, field, adnd)	SNMP_ADD_STATS((net)->mib.net_statistics, field, adnd)
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 11f34e421270..8fda63d78435 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -358,9 +358,9 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 	rt = skb_rtable(skb);
 	if (rt->rt_type == RTN_MULTICAST) {
-		IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_INMCAST, skb->len);
+		__IP_UPD_PO_STATS(net, IPSTATS_MIB_INMCAST, skb->len);
 	} else if (rt->rt_type == RTN_BROADCAST) {
-		IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_INBCAST, skb->len);
+		__IP_UPD_PO_STATS(net, IPSTATS_MIB_INBCAST, skb->len);
 	} else if (skb->pkt_type == PACKET_BROADCAST ||
 		   skb->pkt_type == PACKET_MULTICAST) {
 		struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
@@ -409,7 +409,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
 
 	net = dev_net(dev);
-	IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_IN, skb->len);
+	__IP_UPD_PO_STATS(net, IPSTATS_MIB_IN, skb->len);
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (!skb) {
-- 
2.8.0.rc3.226.g39d4020
