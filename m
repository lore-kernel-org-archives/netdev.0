From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/4] net: ipvlan: call netdev_lockdep_set_classes()
Date: Wed,  8 Jun 2016 16:55:27 -0700
Message-ID: <1465430127-22993-4-git-send-email-edumazet@google.com>
References: <1465430127-22993-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33445 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932401AbcFHXzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 19:55:41 -0400
Received: by mail-pa0-f54.google.com with SMTP id ec8so6940952pac.0
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 16:55:40 -0700 (PDT)
In-Reply-To: <1465430127-22993-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case a qdisc is used on a ipvlan device, we need to use different
lockdep classes to avoid false positives.

Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a seqcount")
Fixes: 79640a4ca695 ("net: add additional lock to qdisc to increase throughput")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 1c4d395fbd49..dee2e67db065 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -107,6 +107,7 @@ static void ipvlan_set_lockdep_class(struct net_device *dev)
 {
 	lockdep_set_class(&dev->addr_list_lock, &ipvlan_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, ipvlan_set_lockdep_class_one, NULL);
+	netdev_lockdep_set_classes(dev);
 }
 
 static int ipvlan_init(struct net_device *dev)
-- 
2.8.0.rc3.226.g39d4020
