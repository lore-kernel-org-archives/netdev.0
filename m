From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 06/14] ipv6: added net argument to ICMP6_INC_STATS
Date: Wed,  8 Oct 2008 15:51:54 +0400
Message-ID: <1223466722-8169-6-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29112 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754318AbYJHLy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:54:27 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h |    3 ++-
 net/ipv6/mcast.c   |    2 +-
 net/ipv6/ndisc.c   |    4 ++--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ac0487b..744fe74 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -139,7 +139,8 @@ DECLARE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
 DECLARE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
 DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 
-#define ICMP6_INC_STATS(idev, field)	_DEVINC(icmpv6, , idev, field)
+#define ICMP6_INC_STATS(net, idev, field)	({ (void)(net); \
+		_DEVINC(icmpv6, , idev, field); })
 #define ICMP6_INC_STATS_BH(idev, field)	_DEVINC(icmpv6, _BH, idev, field)
 
 #define ICMP6MSGOUT_INC_STATS(idev, field) \
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 88811eb..fa413af 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1840,7 +1840,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(idev, type);
-		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
+		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTMCASTPKTS);
 	} else
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index ce5b617..6ce238c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -522,7 +522,7 @@ static void __ndisc_send(struct net_device *dev,
 		      dst_output);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(idev, type);
-		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
+		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
 	}
 
 	if (likely(idev != NULL))
@@ -1586,7 +1586,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 		      dst_output);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(idev, NDISC_REDIRECT);
-		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
+		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
 	}
 
 	if (likely(idev != NULL))
-- 
1.5.3.rc5

