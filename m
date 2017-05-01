From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 35/53] netfilter: tcp: Use TCP_MAX_WSCALE instead of literal 14
Date: Mon,  1 May 2017 12:47:02 +0200
Message-ID: <1493635640-24325-36-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

The window scale may be enlarged from 14 to 15 according to the itef
draft https://tools.ietf.org/html/draft-nishida-tcpm-maxwin-03.

Use the macro TCP_MAX_WSCALE to support it easily with TCP stack in
the future.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_tcp.c | 7 +++----
 net/netfilter/nf_synproxy_core.c       | 4 ++--
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index d0c0a31dfe74..d61a68759dea 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -419,10 +419,9 @@ static void tcp_options(const struct sk_buff *skb,
 				 && opsize == TCPOLEN_WINDOW) {
 				state->td_scale = *(u_int8_t *)ptr;
 
-				if (state->td_scale > 14) {
-					/* See RFC1323 */
-					state->td_scale = 14;
-				}
+				if (state->td_scale > TCP_MAX_WSCALE)
+					state->td_scale = TCP_MAX_WSCALE;
+
 				state->flags |=
 					IP_CT_TCP_FLAG_WINDOW_SCALE;
 			}
diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index abe03e869f7b..a504e87c6ddf 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -66,8 +66,8 @@ synproxy_parse_options(const struct sk_buff *skb, unsigned int doff,
 			case TCPOPT_WINDOW:
 				if (opsize == TCPOLEN_WINDOW) {
 					opts->wscale = *ptr;
-					if (opts->wscale > 14)
-						opts->wscale = 14;
+					if (opts->wscale > TCP_MAX_WSCALE)
+						opts->wscale = TCP_MAX_WSCALE;
 					opts->options |= XT_SYNPROXY_OPT_WSCALE;
 				}
 				break;
-- 
2.1.4

