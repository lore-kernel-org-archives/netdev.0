From: kaber@trash.net
Subject: [PATCH 70/79] netfilter: nf_conntrack: remove an atomic bit operation
Date: Wed, 19 Jan 2011 20:15:10 +0100
Message-ID: <1295464519-21763-71-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51977 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013Ab1ASTPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:42 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

As this ct won't be seen by the others, we don't need to set the
IPS_CONFIRMED_BIT in atomic way.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Cc: Tim Gardner <tim.gardner@canonical.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index dc2ff2c..f47ac67 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -486,7 +486,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	ct->timeout.expires += jiffies;
 	add_timer(&ct->timeout);
 	atomic_inc(&ct->ct_general.use);
-	set_bit(IPS_CONFIRMED_BIT, &ct->status);
+	ct->status |= IPS_CONFIRMED;
 
 	/* Since the lookup is lockless, hash insertion must be done after
 	 * starting the timer and setting the CONFIRMED bit. The RCU barriers
-- 
1.7.2.3

