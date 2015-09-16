From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 04/30] xfrm: Remove unused afinfo method init_dst
Date: Tue, 15 Sep 2015 20:03:52 -0500
Message-ID: <1442365458-16349-4-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/xfrm.h     | 2 --
 net/xfrm/xfrm_policy.c | 2 --
 2 files changed, 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 312e3fee9ccf..fd176106909a 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -296,8 +296,6 @@ struct xfrm_policy_afinfo {
 						  struct flowi *fl,
 						  int reverse);
 	int			(*get_tos)(const struct flowi *fl);
-	void			(*init_dst)(struct net *net,
-					    struct xfrm_dst *dst);
 	int			(*init_path)(struct xfrm_dst *path,
 					     struct dst_entry *dst,
 					     int nfheader_len);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 94af3d065785..6b5d6e2b9a49 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1583,8 +1583,6 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 
 		memset(dst + 1, 0, sizeof(*xdst) - sizeof(*dst));
 		xdst->flo.ops = &xfrm_bundle_fc_ops;
-		if (afinfo->init_dst)
-			afinfo->init_dst(net, xdst);
 	} else
 		xdst = ERR_PTR(-ENOBUFS);
 
-- 
2.2.1

