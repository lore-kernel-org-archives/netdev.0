From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net-next 4/8] bridge: Introduce BR_PROMISC flag
Date: Thu, 15 May 2014 12:56:52 -0400
Message-ID: <1400173016-8952-5-git-send-email-vyasevic@redhat.com>
References: <1400173016-8952-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>, mst@redhat.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com,
	john.r.fastabend@intel.com, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1400173016-8952-1-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Introduce a BR_PROMISC per-port flag that will help us track if the
current port is supposed to be in promiscuous mode or not.  For now,
always start in promiscuous mode.

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
