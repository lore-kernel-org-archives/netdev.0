From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 3/4] net: macvlan: call netdev_lockdep_set_classes()
Date: Wed,  8 Jun 2016 20:29:23 -0700
Message-ID: <1465442964-5786-3-git-send-email-edumazet@google.com>
References: <1465442964-5786-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35478 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755048AbcFID3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 23:29:37 -0400
Received: by mail-pf0-f181.google.com with SMTP id c2so8841521pfa.2
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 20:29:37 -0700 (PDT)
In-Reply-To: <1465442964-5786-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case a qdisc is used on a macvlan device, we need to use different
lockdep classes to avoid false positives.

Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a seqcount")
Fixes: 79640a4ca695 ("net: add additional lock to qdisc to increase throughput")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/macvlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 0c65bd914aed..b0c6f5b43f67 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -823,6 +823,7 @@ static void macvlan_set_lockdep_class(struct net_device *dev)
 				       &macvlan_netdev_addr_lock_key,
 				       macvlan_get_nest_level(dev));
 	netdev_for_each_tx_queue(dev, macvlan_set_lockdep_class_one, NULL);
+	netdev_lockdep_set_classes(dev);
 }
 
 static int macvlan_init(struct net_device *dev)
-- 
2.8.0.rc3.226.g39d4020
