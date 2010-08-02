From: kaber@trash.net
Subject: [PATCH 18/28] xt_quota: report initial quota value instead of current value to userspace
Date: Mon,  2 Aug 2010 21:57:35 +0200
Message-ID: <1280779065-9333-19-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35365 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754852Ab0HBT6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 15:58:01 -0400
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

We should copy the initial value to userspace for iptables-save and
to allow removal of specific quota rules.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/xt_quota.h |    2 +-
 net/netfilter/xt_quota.c           |    2 --
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/include/linux/netfilter/xt_quota.h b/include/linux/netfilter/xt_quota.h
index 8dc89df..b0d28c6 100644
--- a/include/linux/netfilter/xt_quota.h
+++ b/include/linux/netfilter/xt_quota.h
@@ -11,9 +11,9 @@ struct xt_quota_priv;
 struct xt_quota_info {
 	u_int32_t		flags;
 	u_int32_t		pad;
+	aligned_u64		quota;
 
 	/* Used internally by the kernel */
-	aligned_u64		quota;
 	struct xt_quota_priv	*master;
 };
 
diff --git a/net/netfilter/xt_quota.c b/net/netfilter/xt_quota.c
index 304b1fd..70eb2b4 100644
--- a/net/netfilter/xt_quota.c
+++ b/net/netfilter/xt_quota.c
@@ -36,8 +36,6 @@ quota_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		/* we do not allow even small packets from now on */
 		priv->quota = 0;
 	}
-	/* Copy quota back to matchinfo so that iptables can display it */
-	q->quota = priv->quota;
 	spin_unlock_bh(&priv->lock);
 
 	return ret;
-- 
1.7.1

