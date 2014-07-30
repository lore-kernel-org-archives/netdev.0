From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH net-next] net: Remove unlikely() for WARN_ON()
	conditions
Date: Wed, 30 Jul 2014 02:31:08 +0200
Message-ID: <3d85d9264cad5d116792e896149e41e5f14678ce.1406680126.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

No need for the unlikely(), WARN_ON() and BUG_ON() internally use
unlikely() on the condition.

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
---
 net/core/dev.c             | 2 +-
 net/openvswitch/datapath.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index e1b7cfa..b370230 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2326,7 +2326,7 @@ __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 	 */
 	if (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
 		if (vlan_depth) {
-			if (unlikely(WARN_ON(vlan_depth < VLAN_HLEN)))
+			if (WARN_ON(vlan_depth < VLAN_HLEN))
 				return 0;
 			vlan_depth -= VLAN_HLEN;
 		} else {
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 7ede507..701b573 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -144,7 +144,7 @@ int lockdep_ovsl_is_held(void);
 #define lockdep_ovsl_is_held()	1
 #endif
 
-#define ASSERT_OVSL()		WARN_ON(unlikely(!lockdep_ovsl_is_held()))
+#define ASSERT_OVSL()		WARN_ON(!lockdep_ovsl_is_held())
 #define ovsl_dereference(p)					\
 	rcu_dereference_protected(p, lockdep_ovsl_is_held())
 #define rcu_dereference_ovsl(p)					\
-- 
1.9.3
