From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 4/4] ip6mr: align RTA_MFC_STATS on 64-bit
Date: Wed, 20 Apr 2016 10:57:35 +0200
Message-ID: <1461142655-5067-5-git-send-email-nicolas.dichtel@6wind.com>
References: <20160419.195009.1052027353987244150.davem@davemloft.net>
 <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com, tgraf@suug.ch, jhs@mojatatu.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:56437 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932723AbcDTI5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 04:57:52 -0400
In-Reply-To: <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6mr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index a10e77103c88..bf678324fd52 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2268,7 +2268,7 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	mfcs.mfcs_packets = c->mfc_un.res.pkt;
 	mfcs.mfcs_bytes = c->mfc_un.res.bytes;
 	mfcs.mfcs_wrong_if = c->mfc_un.res.wrong_if;
-	if (nla_put(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs) < 0)
+	if (nla_put_64bit(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs, RTA_PAD) < 0)
 		return -EMSGSIZE;
 
 	rtm->rtm_type = RTN_MULTICAST;
@@ -2411,7 +2411,7 @@ static int mr6_msgsize(bool unresolved, int maxvif)
 		      + nla_total_size(0)	/* RTA_MULTIPATH */
 		      + maxvif * NLA_ALIGN(sizeof(struct rtnexthop))
 						/* RTA_MFC_STATS */
-		      + nla_total_size(sizeof(struct rta_mfc_stats))
+		      + nla_total_size_64bit(sizeof(struct rta_mfc_stats))
 		;
 
 	return len;
-- 
2.4.2
