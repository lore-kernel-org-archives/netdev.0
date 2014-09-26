From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6 -stable] netfilter: x_tables: allow to use default cgroup match
Date: Fri, 26 Sep 2014 13:43:42 +0200
Message-ID: <1411731824-15051-5-git-send-email-pablo@netfilter.org>
References: <1411731824-15051-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36250 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754150AbaIZLmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 07:42:46 -0400
In-Reply-To: <1411731824-15051-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

[ upstream commit caa8ad94edf686d02b555c65a6162c0d1b434958 ]

There's actually no good reason why we cannot use cgroup id 0,
so lets just remove this artificial barrier.

Cc: <stable@vger.kernel.org> # 3.16.x
Cc: <stable@vger.kernel.org> # 3.14.x
Reported-by: Alexey Perevalov <a.perevalov@samsung.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Tested-by: Alexey Perevalov <a.perevalov@samsung.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_cgroup.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_cgroup.c b/net/netfilter/xt_cgroup.c
index f4e8330..7198d66 100644
--- a/net/netfilter/xt_cgroup.c
+++ b/net/netfilter/xt_cgroup.c
@@ -31,7 +31,7 @@ static int cgroup_mt_check(const struct xt_mtchk_param *par)
 	if (info->invert & ~1)
 		return -EINVAL;
 
-	return info->id ? 0 : -EINVAL;
+	return 0;
 }
 
 static bool
-- 
1.7.10.4
