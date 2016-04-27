From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 07/17] net: icmp: rename ICMPMSGIN_INC_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:33 -0700
Message-ID: <1461800683-25034-8-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35202 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798AbcD0XpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:09 -0400
Received: by mail-pf0-f178.google.com with SMTP id n1so29273498pfn.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:08 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove misleading _BH suffix.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/icmp.h | 2 +-
 net/ipv4/icmp.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index 5a60ce819078..25edb740c648 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -32,7 +32,7 @@ extern const struct icmp_err icmp_err_convert[];
 #define ICMP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.icmp_statistics, field)
 #define __ICMP_INC_STATS(net, field)	SNMP_INC_STATS_BH((net)->mib.icmp_statistics, field)
 #define ICMPMSGOUT_INC_STATS(net, field)	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.icmpmsg_statistics, field+256)
-#define ICMPMSGIN_INC_STATS_BH(net, field)	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.icmpmsg_statistics, field)
+#define ICMPMSGIN_INC_STATS(net, field)		SNMP_INC_STATS_ATOMIC_LONG((net)->mib.icmpmsg_statistics, field)
 
 struct dst_entry;
 struct net_proto_family;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 995fef9c5099..38abe70e595f 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1006,7 +1006,7 @@ int icmp_rcv(struct sk_buff *skb)
 
 	icmph = icmp_hdr(skb);
 
-	ICMPMSGIN_INC_STATS_BH(net, icmph->type);
+	ICMPMSGIN_INC_STATS(net, icmph->type);
 	/*
 	 *	18 is the highest 'known' ICMP type. Anything else is a mystery
 	 *
-- 
2.8.0.rc3.226.g39d4020
