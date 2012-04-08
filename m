From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] netfilter: fix incorrect logic in nf_conntrack_init_net
Date: Sun, 8 Apr 2012 10:08:28 +0800
Message-ID: <1333850908-3108-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

in function nf_conntrack_init_net,when nf_conntrack_timeout_init falied,
we should call nf_conntrack_ecache_fini to do rollback.
but the current code calls nf_conntrack_timeout_fini.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 3cc4487..729f157 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1592,7 +1592,7 @@ static int nf_conntrack_init_net(struct net *net)
 	return 0;
 
 err_timeout:
-	nf_conntrack_timeout_fini(net);
+	nf_conntrack_ecache_fini(net);
 err_ecache:
 	nf_conntrack_tstamp_fini(net);
 err_tstamp:
-- 
1.7.7.6

