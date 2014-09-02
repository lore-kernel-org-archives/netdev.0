From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/7] netfilter: x_tables: allow to use default cgroup match
Date: Tue,  2 Sep 2014 12:13:59 +0200
Message-ID: <1409652844-10289-3-git-send-email-pablo@netfilter.org>
References: <1409652844-10289-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48015 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753262AbaIBKNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 06:13:22 -0400
In-Reply-To: <1409652844-10289-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

There's actually no good reason why we cannot use cgroup id 0,
so lets just remove this artificial barrier.

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
