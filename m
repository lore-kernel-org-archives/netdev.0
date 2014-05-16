From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v3 net-next 4/6] bridge: Introduce BR_PROMISC flag
Date: Fri, 16 May 2014 09:59:18 -0400
Message-ID: <1400248760-20672-5-git-send-email-vyasevic@redhat.com>
References: <1400248760-20672-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	mst@redhat.com, john.r.fastabend@intel.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933100AbaEPN7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 09:59:31 -0400
In-Reply-To: <1400248760-20672-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a BR_PROMISC per-port flag that will help us track if the
current port is supposed to be in promiscuous mode or not.  For now,
always start in promiscuous mode.

Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_if.c      | 2 +-
 net/bridge/br_private.h | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f7ef5f2..3fefff9 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -238,7 +238,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	p->path_cost = port_cost(dev);
 	p->priority = 0x8000 >> BR_PORT_BITS;
 	p->port_no = index;
-	p->flags = BR_LEARNING | BR_FLOOD;
+	p->flags = BR_LEARNING | BR_FLOOD | BR_PROMISC;
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 	br_stp_port_timer_init(p);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c0a804b..00922a4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -175,6 +175,7 @@ struct net_bridge_port
 #define BR_LEARNING		0x00000020
 #define BR_FLOOD		0x00000040
 #define BR_AUTO_MASK (BR_FLOOD | BR_LEARNING)
+#define BR_PROMISC		0x00000080
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	struct bridge_mcast_query	ip4_query;
@@ -200,6 +201,7 @@ struct net_bridge_port
 };
 
 #define br_auto_port(p) ((p)->flags & BR_AUTO_MASK)
+#define br_promisc_port(p) ((p)->flags & BR_PROMISC)
 
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
 
-- 
1.9.0
