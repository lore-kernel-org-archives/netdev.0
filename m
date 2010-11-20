From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: remove an atomic bit operation
Date: Sat, 20 Nov 2010 15:55:17 +0800
Message-ID: <1290239717-12664-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As this ct won't be seen by the others, we don't need to set the
IPS_CONFIRMED_BIT in atomic way.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/nf_conntrack_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 27a5ea6..c708248 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -486,7 +486,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	ct->timeout.expires += jiffies;
 	add_timer(&ct->timeout);
 	atomic_inc(&ct->ct_general.use);
-	set_bit(IPS_CONFIRMED_BIT, &ct->status);
+	ct->status |= IPS_CONFIRMED_BIT;
 
 	/* Since the lookup is lockless, hash insertion must be done after
 	 * starting the timer and setting the CONFIRMED bit. The RCU barriers
