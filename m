From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH v3 RESEND 3/3] neigh: disallow un-init_net to change thresh of neigh
Date: Thu, 20 Jun 2013 10:01:34 +0800
Message-ID: <1371693694-18531-3-git-send-email-gaofeng@cn.fujitsu.com>
References: <1371693694-18531-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:43283 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S935237Ab3FTCAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 22:00:25 -0400
In-Reply-To: <1371693694-18531-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thresh and interval are global resources,
only init net can change them.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/core/neighbour.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 2ec1faf..5e0fe89 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2049,6 +2049,12 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 	}
 
+	err = -ENOENT;
+	if ((tb[NDTA_THRESH1] || tb[NDTA_THRESH2] ||
+	     tb[NDTA_THRESH3] || tb[NDTA_GC_INTERVAL]) &&
+	    !net_eq(net, &init_net))
+		goto errout_tbl_lock;
+
 	if (tb[NDTA_THRESH1])
 		tbl->gc_thresh1 = nla_get_u32(tb[NDTA_THRESH1]);
 
-- 
1.8.1.4
