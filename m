From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] netfilter: connlimit: fix UP build
Date: Mon, 17 Mar 2014 22:27:50 +0100
Message-ID: <1395091670-28238-1-git-send-email-fw@strlen.de>
References: <53275dbf./J0nBeffRcN62Ddt%fengguang.wu@intel.com>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54324 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752414AbaCQVcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 17:32:41 -0400
In-Reply-To: <53275dbf./J0nBeffRcN62Ddt%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cannot use ARRAY_SIZE() if spinlock_t is empty struct.

Fixes: 1442e7507dd597 ("netfilter: connlimit: use keyed locks")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
Another one, did UP build with LOCKDEP=y  8-(

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
1.8.1.5
