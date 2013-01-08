From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 2/2] net: dev_queue_xmit_nit: fix potential NULL ptr dereference
Date: Tue,  8 Jan 2013 19:51:33 +0100
Message-ID: <1357671093-9605-3-git-send-email-dborkman@redhat.com>
References: <1357671093-9605-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3814 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756980Ab3AHSvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 13:51:50 -0500
In-Reply-To: <1357671093-9605-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 71d9dec24dce548bf699815c976cf063ad9257e2 (``net: increase
skb->users instead of skb_clone()'') introduced a skb_clone in
dev_queue_xmit_nit that, when NULL, leaves the loop, but can still
be injected into pt_prev->func().

Cc: Changli Gao <xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 723dcd0..6c35c33 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1827,7 +1827,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 			pt_prev = ptype;
 		}
 	}
-	if (pt_prev)
+	if (skb2 && pt_prev)
 		pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
 	rcu_read_unlock();
 }
-- 
1.7.11.7
