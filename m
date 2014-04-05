From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/8] netfilter: connlimit: fix UP build
Date: Sat,  5 Apr 2014 18:03:43 +0200
Message-ID: <1396713830-4009-2-git-send-email-pablo@netfilter.org>
References: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34325 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752995AbaDEQEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2014 12:04:00 -0400
In-Reply-To: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

cannot use ARRAY_SIZE() if spinlock_t is empty struct.

Fixes: 1442e7507dd597 ("netfilter: connlimit: use keyed locks")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_connlimit.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 458464e..a6e129e 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -377,7 +377,7 @@ static int connlimit_mt_check(const struct xt_mtchk_param *par)
 		return -ENOMEM;
 	}
 
-	for (i = 0; i < ARRAY_SIZE(info->data->locks); ++i)
+	for (i = 0; i < CONNLIMIT_LOCK_SLOTS; ++i)
 		spin_lock_init(&info->data->locks[i]);
 
 	for (i = 0; i < ARRAY_SIZE(info->data->climit_root4); ++i)
-- 
1.7.10.4
