From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 08/14] ipv6: added net argument to ICMP6MSGOUT_INC_STATS
Date: Wed,  8 Oct 2008 15:51:56 +0400
Message-ID: <1223466722-8169-8-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31258 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753804AbYJHLxv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:53:51 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h |    4 ++--
 net/ipv6/mcast.c   |    2 +-
 net/ipv6/ndisc.c   |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 5107cd9..7f5a8de 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -144,8 +144,8 @@ DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 #define ICMP6_INC_STATS_BH(net, idev, field)	({ (void)(net); \
 		_DEVINC(icmpv6, _BH, idev, field); })
 
-#define ICMP6MSGOUT_INC_STATS(idev, field) \
-	_DEVINC(icmpv6msg, , idev, field +256)
+#define ICMP6MSGOUT_INC_STATS(net, idev, field) ({ (void)(net); \
+	_DEVINC(icmpv6msg, , idev, field +256); })
 #define ICMP6MSGOUT_INC_STATS_BH(idev, field) \
 	_DEVINC(icmpv6msg, _BH, idev, field +256)
 #define ICMP6MSGIN_INC_STATS(idev, field) \
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index f06ceea..a96e423 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1839,7 +1839,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 		      dst_output);
 out:
 	if (!err) {
-		ICMP6MSGOUT_INC_STATS(idev, type);
+		ICMP6MSGOUT_INC_STATS(net, idev, type);
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTMCASTPKTS);
 	} else
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 6ce238c..840b157 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -521,7 +521,7 @@ static void __ndisc_send(struct net_device *dev,
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
 		      dst_output);
 	if (!err) {
-		ICMP6MSGOUT_INC_STATS(idev, type);
+		ICMP6MSGOUT_INC_STATS(net, idev, type);
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
 	}
 
@@ -1585,7 +1585,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
 		      dst_output);
 	if (!err) {
-		ICMP6MSGOUT_INC_STATS(idev, NDISC_REDIRECT);
+		ICMP6MSGOUT_INC_STATS(net, idev, NDISC_REDIRECT);
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
 	}
 
-- 
1.5.3.rc5

