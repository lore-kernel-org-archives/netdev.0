From: Cong Wang <amwang@redhat.com>
Subject: [RFC PATCH 1/2] bridge: export port_no and port_id via
	IFA_INFO_DATA
Date: Tue, 27 Nov 2012 17:49:43 +0800
Message-ID: <1354009785-20014-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
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

Based on net-next.

This patch exports port->port_no port->port_id in the end of IFA_INFO_DATA.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 include/uapi/linux/if_link.h |    2 ++
 net/bridge/br_netlink.c      |    8 +++++++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index bb58aeb..9cd91a9 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -218,6 +218,8 @@ enum {
 	IFLA_BRPORT_MODE,	/* mode (hairpin)          */
 	IFLA_BRPORT_GUARD,	/* bpdu guard              */
 	IFLA_BRPORT_PROTECT,	/* root port protection    */
+	IFLA_BRPORT_NO,		/* port no                 */
+	IFLA_BRPORT_ID,		/* port id                 */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 65429b9..7b7414e 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -28,6 +28,8 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(1)	/* IFLA_BRPORT_MODE */
 		+ nla_total_size(1)	/* IFLA_BRPORT_GUARD */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROTECT */
+		+ nla_total_size(2)	/* IFLA_BRPORT_NO */
+		+ nla_total_size(2)	/* IFLA_BRPORT_ID */
 		+ 0;
 }
 
@@ -53,7 +55,9 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u32(skb, IFLA_BRPORT_COST, p->path_cost) ||
 	    nla_put_u8(skb, IFLA_BRPORT_MODE, mode) ||
 	    nla_put_u8(skb, IFLA_BRPORT_GUARD, !!(p->flags & BR_BPDU_GUARD)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_PROTECT, !!(p->flags & BR_ROOT_BLOCK)))
+	    nla_put_u8(skb, IFLA_BRPORT_PROTECT, !!(p->flags & BR_ROOT_BLOCK)) ||
+	    nla_put_u16(skb, IFLA_BRPORT_NO, p->port_no) ||
+	    nla_put_u16(skb, IFLA_BRPORT_ID, p->port_id))
 		return -EMSGSIZE;
 
 	return 0;
@@ -168,6 +172,8 @@ static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_NO]	= { .type = NLA_U16 },
+	[IFLA_BRPORT_ID]	= { .type = NLA_U16 },
 };
 
 /* Change the state of the port and notify spanning tree */
-- 
1.7.7.6
