From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] xt_quota: don't copy quota back to userspace
Date: Fri, 23 Jul 2010 12:54:05 +0800
Message-ID: <1279860845-7177-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch should be applied after my another patch:
http://patchwork.ozlabs.org/patch/59729/

xt_quota: don't copy quota back to userspace

In nowadays, table entries are per-cpu variables, so it don't make any sense to
copy quota back to one of the variable instances. To keep things simple, this
patch undo the copy.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netfilter/xt_quota.h |    2 +-
 net/netfilter/xt_quota.c           |    2 --
 2 files changed, 1 insertion(+), 3 deletions(-)
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
