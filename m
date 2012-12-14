From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: [PATCH] bridge: remove temporary variable for MLDv2 maximum response
 code computation
Date: Fri, 14 Dec 2012 17:08:39 +0800
Message-ID: <50CAEC97.2090609@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:44011 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751652Ab2LNJIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 04:08:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by Stephen Hemminger, this remove the temporary variable introduced in commit
eca2a43bb0d2c6ebd528be6acb30a88435abe307

Signed-off-by: Ang Way Chuang <wcang@sfc.wide.ad.jp>
---
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 1093c89..2561af9 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1165,7 +1165,6 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 		if (max_delay)
 			group = &mld->mld_mca;
 	} else if (skb->len >= sizeof(*mld2q)) {
-		u16 mrc;
 		if (!pskb_may_pull(skb, sizeof(*mld2q))) {
 			err = -EINVAL;
 			goto out;
@@ -1173,8 +1172,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 		mld2q = (struct mld2_query *)icmp6_hdr(skb);
 		if (!mld2q->mld2q_nsrcs)
 			group = &mld2q->mld2q_mca;
-		mrc = ntohs(mld2q->mld2q_mrc);
-		max_delay = mrc ? MLDV2_MRC(mrc) : 1;
+		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q->mld2q_mrc)) : 1;
 	}
 
 	if (!group)
