From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 3/4] ipmr: align RTA_MFC_STATS on 64-bit
Date: Thu, 21 Apr 2016 18:58:26 +0200
Message-ID: <1461257907-4458-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461257907-4458-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com, tgraf@suug.ch, jhs@mojatatu.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:52626 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbcDUQ6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 12:58:49 -0400
In-Reply-To: <1461257907-4458-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/rtnetlink.h | 1 +
 net/ipv4/ipmr.c                | 4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index cc885c4e9065..a94e0b69c769 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -317,6 +317,7 @@ enum rtattr_type_t {
 	RTA_ENCAP_TYPE,
 	RTA_ENCAP,
 	RTA_EXPIRES,
+	RTA_PAD,
 	__RTA_MAX
 };
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 395e2814a46d..21a38e296fe2 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2104,7 +2104,7 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	mfcs.mfcs_packets = c->mfc_un.res.pkt;
 	mfcs.mfcs_bytes = c->mfc_un.res.bytes;
 	mfcs.mfcs_wrong_if = c->mfc_un.res.wrong_if;
-	if (nla_put(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs) < 0)
+	if (nla_put_64bit(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs, RTA_PAD) < 0)
 		return -EMSGSIZE;
 
 	rtm->rtm_type = RTN_MULTICAST;
@@ -2237,7 +2237,7 @@ static size_t mroute_msgsize(bool unresolved, int maxvif)
 		      + nla_total_size(0)	/* RTA_MULTIPATH */
 		      + maxvif * NLA_ALIGN(sizeof(struct rtnexthop))
 						/* RTA_MFC_STATS */
-		      + nla_total_size(sizeof(struct rta_mfc_stats))
+		      + nla_total_size_64bit(sizeof(struct rta_mfc_stats))
 		;
 
 	return len;
-- 
2.4.2
