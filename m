From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 11/14] ipv6: added net argument to ICMP6MSGIN_INC_STATS_BH
Date: Wed,  8 Oct 2008 15:51:59 +0400
Message-ID: <1223466722-8169-11-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:45123 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032AbYJHLyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:54:02 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h |    4 ++--
 net/ipv6/icmp.c    |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 01da23c..47a76bf 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -148,8 +148,8 @@ DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 	_DEVINC(icmpv6msg, , idev, field +256); })
 #define ICMP6MSGOUT_INC_STATS_BH(net, idev, field) ({ (void)(net); \
 	_DEVINC(icmpv6msg, _BH, idev, field +256); })
-#define ICMP6MSGIN_INC_STATS_BH(idev, field) \
-	_DEVINC(icmpv6msg, _BH, idev, field)
+#define ICMP6MSGIN_INC_STATS_BH(net, idev, field) ({ (void)(net); \
+	_DEVINC(icmpv6msg, _BH, idev, field); })
 
 struct ip6_ra_chain
 {
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 4c96155..9b7d19a 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -693,7 +693,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 
 	type = hdr->icmp6_type;
 
-	ICMP6MSGIN_INC_STATS_BH(idev, type);
+	ICMP6MSGIN_INC_STATS_BH(dev_net(dev), idev, type);
 
 	switch (type) {
 	case ICMPV6_ECHO_REQUEST:
-- 
1.5.3.rc5

