From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] xt_hashlimit: dl_seq_stop() fix
Date: Wed, 24 Mar 2010 21:47:44 +0100
Message-ID: <1269463664.2849.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:38525 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756810Ab0CXUrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 16:47:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If dl_seq_start() memory allocation fails, we crash later in
dl_seq_stop(), trying to kfree(ERR_PTR(-ENOMEM))

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
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
 


