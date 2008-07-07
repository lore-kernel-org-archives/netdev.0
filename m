From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 6/7] MIB: add struct net to ICMPMSGOUT_INC_STATS
Date: Mon, 07 Jul 2008 14:53:02 +0400
Message-ID: <4871F58E.4000905@openvz.org>
References: <4871F2D8.8030502@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54608 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751905AbYGGKze (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 06:55:34 -0400
In-Reply-To: <4871F2D8.8030502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/icmp.h |    2 +-
 net/ipv4/icmp.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index e2ae640..ee9c8d4 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -33,7 +33,7 @@ DECLARE_SNMP_STAT(struct icmp_mib, icmp_statistics);
 DECLARE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics);
 #define ICMP_INC_STATS(net, field)	SNMP_INC_STATS(icmp_statistics, field)
 #define ICMP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH(icmp_statistics, field)
-#define ICMPMSGOUT_INC_STATS(field)	SNMP_INC_STATS(icmpmsg_statistics, field+256)
+#define ICMPMSGOUT_INC_STATS(net, field)	SNMP_INC_STATS(icmpmsg_statistics, field+256)
 #define ICMPMSGIN_INC_STATS_BH(field)	SNMP_INC_STATS_BH(icmpmsg_statistics, field)
 
 struct dst_entry;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 56a7bbc..6f4c65b 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -298,7 +298,7 @@ out:
  */
 void icmp_out_count(struct net *net, unsigned char type)
 {
-	ICMPMSGOUT_INC_STATS(type);
+	ICMPMSGOUT_INC_STATS(net, type);
 	ICMP_INC_STATS(net, ICMP_MIB_OUTMSGS);
 }
 
-- 
1.5.3.4

