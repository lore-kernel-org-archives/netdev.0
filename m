From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 5/20] mib: add net to IP_ADD_STATS_BH
Date: Wed, 16 Jul 2008 12:14:00 +0400
Message-ID: <487DADC8.4030006@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:36888 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755891AbYGPIPv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:15:51 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Very simple - only ip_evictor (fragments) requires such.
This patch ends up the IP_XXX_STATS patching.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/ip.h       |    2 +-
 net/ipv4/ip_fragment.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 9973ce0..93d0e09 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -159,7 +159,7 @@ extern struct ipv4_config ipv4_config;
 DECLARE_SNMP_STAT(struct ipstats_mib, ip_statistics);
 #define IP_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(ip_statistics, field); } while (0)
 #define IP_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(ip_statistics, field); } while (0)
-#define IP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(ip_statistics, field, val)
+#define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS_BH(ip_statistics, field, val)
 DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
 #define NET_INC_STATS(field)		SNMP_INC_STATS(net_statistics, field)
 #define NET_INC_STATS_BH(field)		SNMP_INC_STATS_BH(net_statistics, field)
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 65364c0..38d38f0 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -178,7 +178,7 @@ static void ip_evictor(struct net *net)
 
 	evicted = inet_frag_evictor(&net->ipv4.frags, &ip4_frags);
 	if (evicted)
-		IP_ADD_STATS_BH(IPSTATS_MIB_REASMFAILS, evicted);
+		IP_ADD_STATS_BH(net, IPSTATS_MIB_REASMFAILS, evicted);
 }
 
 /*
-- 
1.5.5.1

