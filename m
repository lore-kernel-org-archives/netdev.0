From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 2/2] neigh: disallow un-init_net to change thresh of neigh
Date: Wed, 12 Jun 2013 12:34:11 +0800
Message-ID: <1371011651-30894-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1371011651-30894-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	Gao feng <gaofeng@Donkey.lan>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:9781 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751266Ab3FLEd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 00:33:58 -0400
In-Reply-To: <1371011651-30894-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@Donkey.lan>

thresh is a global resource, only init net can change it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/core/neighbour.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index e4027ff..8feb382 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2056,6 +2056,12 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 	}
 
+	err = -EPERM;
+	if ((tb[NDTA_THRESH1] || tb[NDTA_THRESH2] ||
+	     tb[NDTA_THRESH3] || tb[NDTA_GC_INTERVAL]) &&
+	    !net_eq(net, &init_net))
+		goto errout_tbl_lock;
+
 	if (tb[NDTA_THRESH1])
 		tbl->gc_thresh1 = nla_get_u32(tb[NDTA_THRESH1]);
 
-- 
1.8.1.4
