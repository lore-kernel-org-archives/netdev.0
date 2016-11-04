From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Subject: [PATCH net-next 2/5] net: l2tp: fix L2TP_ATTR_UDP_ZERO_CSUM6_{RX,TX} attribute types
Date: Fri,  4 Nov 2016 22:48:35 +0000
Message-ID: <20161104224838.7925-2-asbjorn@asbjorn.st>
References: <20161104224838.7925-1-asbjorn@asbjorn.st>
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Miao Wang <shankerwangmiao@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104224838.7925-1-asbjorn@asbjorn.st>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The attributes L2TP_ATTR_UDP_ZERO_CSUM6_RX and
L2TP_ATTR_UDP_ZERO_CSUM6_TX are used as flags,
but is defined as a u8 in a comment.

This patch redocuments them as flags, and adds
them to the nla_policy, so they gets validated.

The only publicly user, iproute2, already treat
these attributes as flags.

CC: Miao Wang <shankerwangmiao@gmail.com>
Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
---
 include/uapi/linux/l2tp.h | 4 ++--
 net/l2tp/l2tp_netlink.c   | 2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/l2tp.h b/include/uapi/linux/l2tp.h
index 73e3a23..345e49f 100644
--- a/include/uapi/linux/l2tp.h
+++ b/include/uapi/linux/l2tp.h
@@ -124,8 +124,8 @@ enum {
 	L2TP_ATTR_STATS,		/* nested */
 	L2TP_ATTR_IP6_SADDR,		/* struct in6_addr */
 	L2TP_ATTR_IP6_DADDR,		/* struct in6_addr */
-	L2TP_ATTR_UDP_ZERO_CSUM6_TX,	/* u8 */
-	L2TP_ATTR_UDP_ZERO_CSUM6_RX,	/* u8 */
+	L2TP_ATTR_UDP_ZERO_CSUM6_TX,	/* flag */
+	L2TP_ATTR_UDP_ZERO_CSUM6_RX,	/* flag */
 	L2TP_ATTR_PAD,
 	__L2TP_ATTR_MAX,
 };
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 1fe05da..e45c5409 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -880,6 +880,8 @@ static const struct nla_policy l2tp_nl_policy[L2TP_ATTR_MAX + 1] = {
 	[L2TP_ATTR_SESSION_ID]		= { .type = NLA_U32, },
 	[L2TP_ATTR_PEER_SESSION_ID]	= { .type = NLA_U32, },
 	[L2TP_ATTR_UDP_CSUM]		= { .type = NLA_FLAG, },
+	[L2TP_ATTR_UDP_ZERO_CSUM6_TX]	= { .type = NLA_FLAG, },
+	[L2TP_ATTR_UDP_ZERO_CSUM6_RX]	= { .type = NLA_FLAG, },
 	[L2TP_ATTR_VLAN_ID]		= { .type = NLA_U16, },
 	[L2TP_ATTR_DEBUG]		= { .type = NLA_U32, },
 	[L2TP_ATTR_RECV_SEQ]		= { .type = NLA_U8, },
-- 
2.10.1
