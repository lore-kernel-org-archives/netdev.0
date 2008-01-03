From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [NET]: Avoid divides in net/core/gen_estimator.c
Date: Thu, 3 Jan 2008 14:12:35 +0100
Message-ID: <20080103141235.dbff886f.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:40039 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754314AbYACNMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2008 08:12:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can void divides (as seen with CONFIG_CC_OPTIMIZE_FOR_SIZE=y on x86)
changing ((HZ<<idx)/4) to ((HZ/4) << idx)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index daadbcc..86037d1 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -135,7 +135,7 @@ skip:
 	}
 
 	if (!list_empty(&elist[idx].list))
-		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
+		mod_timer(&elist[idx].timer, jiffies + ((HZ/4) << idx));
 	rcu_read_unlock();
 }
 
@@ -191,7 +191,7 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 	}
 
 	if (list_empty(&elist[idx].list))
-		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
+		mod_timer(&elist[idx].timer, jiffies + ((HZ/4) << idx));
 
 	list_add_rcu(&est->list, &elist[idx].list);
 	return 0;

