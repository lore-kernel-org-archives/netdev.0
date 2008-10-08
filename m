From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 05/14] ipv6: added net argument to IP6_ADD_STATS_BH
Date: Wed,  8 Oct 2008 15:51:53 +0400
Message-ID: <1223466722-8169-5-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5616 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754414AbYJHLyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:54:32 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h    |    3 ++-
 net/ipv6/reassembly.c |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e7732d3..ac0487b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -133,7 +133,8 @@ DECLARE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
 		_DEVINC(ipv6, , idev, field); })
 #define IP6_INC_STATS_BH(net, idev,field) ({ (void)(net); \
 		_DEVINC(ipv6, _BH, idev, field); })
-#define IP6_ADD_STATS_BH(idev,field,val) _DEVADD(ipv6, _BH, idev, field, val)
+#define IP6_ADD_STATS_BH(net, idev,field,val) ({ (void)(net); \
+		_DEVADD(ipv6, _BH, idev, field, val); })
 
 DECLARE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
 DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 693d208..af12de0 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -189,7 +189,7 @@ static void ip6_evictor(struct net *net, struct inet6_dev *idev)
 
 	evicted = inet_frag_evictor(&net->ipv6.frags, &ip6_frags);
 	if (evicted)
-		IP6_ADD_STATS_BH(idev, IPSTATS_MIB_REASMFAILS, evicted);
+		IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_REASMFAILS, evicted);
 }
 
 static void ip6_frag_expire(unsigned long data)
-- 
1.5.3.rc5

