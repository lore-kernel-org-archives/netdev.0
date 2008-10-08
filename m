From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 09/14] ipv6: added net argument to ICMP6MSGOUT_INC_STATS_BH
Date: Wed,  8 Oct 2008 15:51:57 +0400
Message-ID: <1223466722-8169-9-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:33857 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752448AbYJHLyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:54:36 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h    |    4 ++--
 net/ipv6/ip6_output.c |    2 +-
 net/ipv6/mcast.c      |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 7f5a8de..4736d8f 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -146,8 +146,8 @@ DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 
 #define ICMP6MSGOUT_INC_STATS(net, idev, field) ({ (void)(net); \
 	_DEVINC(icmpv6msg, , idev, field +256); })
-#define ICMP6MSGOUT_INC_STATS_BH(idev, field) \
-	_DEVINC(icmpv6msg, _BH, idev, field +256)
+#define ICMP6MSGOUT_INC_STATS_BH(net, idev, field) ({ (void)(net); \
+	_DEVINC(icmpv6msg, _BH, idev, field +256); })
 #define ICMP6MSGIN_INC_STATS(idev, field) \
 	 _DEVINC(icmpv6msg, , idev, field)
 #define ICMP6MSGIN_INC_STATS_BH(idev, field) \
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e7eff32..c77db0b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1482,7 +1482,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	if (proto == IPPROTO_ICMPV6) {
 		struct inet6_dev *idev = ip6_dst_idev(skb->dst);
 
-		ICMP6MSGOUT_INC_STATS_BH(idev, icmp6_hdr(skb)->icmp6_type);
+		ICMP6MSGOUT_INC_STATS_BH(net, idev, icmp6_hdr(skb)->icmp6_type);
 		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
 	}
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index a96e423..d7b3c6d 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1474,7 +1474,7 @@ static void mld_sendpack(struct sk_buff *skb)
 		      dst_output);
 out:
 	if (!err) {
-		ICMP6MSGOUT_INC_STATS_BH(idev, ICMPV6_MLD2_REPORT);
+		ICMP6MSGOUT_INC_STATS_BH(net, idev, ICMPV6_MLD2_REPORT);
 		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
 		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTMCASTPKTS);
 	} else
-- 
1.5.3.rc5

