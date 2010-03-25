From: kaber@trash.net
Subject: [PATCH 2/4] netfilter: xt_hashlimit: dl_seq_stop() fix
Date: Thu, 25 Mar 2010 18:54:44 +0100
Message-ID: <1269539686-3885-3-git-send-email-kaber@trash.net>
References: <1269539686-3885-1-git-send-email-kaber@trash.net>
 <1269539686-3885-2-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56921 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334Ab0CYRyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 13:54:50 -0400
In-Reply-To: <1269539686-3885-2-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

If dl_seq_start() memory allocation fails, we crash later in
dl_seq_stop(), trying to kfree(ERR_PTR(-ENOMEM))

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_hashlimit.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 9e9c489..70d561a 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -879,7 +879,8 @@ static void dl_seq_stop(struct seq_file *s, void *v)
 	struct xt_hashlimit_htable *htable = s->private;
 	unsigned int *bucket = (unsigned int *)v;
 
-	kfree(bucket);
+	if (!IS_ERR(bucket))
+		kfree(bucket);
 	spin_unlock_bh(&htable->lock);
 }
 
-- 
1.6.5.7

