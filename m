From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: [PATCH] bridge: Bug fix for incorrect interpretation of MLDv2 maximum
 response code
Date: Fri, 14 Dec 2012 08:07:01 +0800
Message-ID: <50CA6DA5.1020101@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:34750 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754792Ab2LNAPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 19:15:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the incorrect interpretation of endianness of MLDv2 maximum response
code within bridge's multicast snooping code.

Signed-off-by: Ang Way Chuang <wcang@sfc.wide.ad.jp>
---
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 977c3ee..29c6283 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1172,7 +1172,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 		mld2q = (struct mld2_query *)icmp6_hdr(skb);
 		if (!mld2q->mld2q_nsrcs)
 			group = &mld2q->mld2q_mca;
-		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(mld2q->mld2q_mrc) : 1;
+		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q->mld2q_mrc)) : 1;
 	}
 
 	if (!group)
