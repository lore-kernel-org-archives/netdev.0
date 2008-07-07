From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 7/7] MIB: add struct net to ICMPMSGIN_INC_STATS_BH
Date: Mon, 07 Jul 2008 14:53:44 +0400
Message-ID: <4871F5B8.5080508@openvz.org>
References: <4871F2D8.8030502@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54616 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752862AbYGGK4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 06:56:15 -0400
In-Reply-To: <4871F2D8.8030502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/icmp.h |    2 +-
 net/ipv4/icmp.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index ee9c8d4..03b9972 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -34,7 +34,7 @@ DECLARE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics);
 #define ICMP_INC_STATS(net, field)	SNMP_INC_STATS(icmp_statistics, field)
 #define ICMP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH(icmp_statistics, field)
 #define ICMPMSGOUT_INC_STATS(net, field)	SNMP_INC_STATS(icmpmsg_statistics, field+256)
-#define ICMPMSGIN_INC_STATS_BH(field)	SNMP_INC_STATS_BH(icmpmsg_statistics, field)
+#define ICMPMSGIN_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH(icmpmsg_statistics, field)
 
 struct dst_entry;
 struct net_proto_family;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 6f4c65b..ea60ad4 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1012,7 +1012,7 @@ int icmp_rcv(struct sk_buff *skb)
 
 	icmph = icmp_hdr(skb);
 
-	ICMPMSGIN_INC_STATS_BH(icmph->type);
+	ICMPMSGIN_INC_STATS_BH(net, icmph->type);
 	/*
 	 *	18 is the highest 'known' ICMP type. Anything else is a mystery
 	 *
-- 
1.5.3.4

