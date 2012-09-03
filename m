From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH 2/2] netfilter: More users of ipv6_find_hdr_cb()
Date: Mon, 03 Sep 2012 23:16:47 +0200
Message-ID: <20120903211631.8851.40213.stgit@dragon>
References: <20120903211504.8851.6894.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: "Patrick McHardy" <kaber@trash.net>,
	Hans Schillstrom <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120903211504.8851.6894.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Functions tproxy_tg6_v1() and socket_mt6_v1 could use the
CB cached version of ipv6_find_hdr().

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
Could someone with tproxy or socket experience tell me,
if the SKB CB data can survive this far?


 net/netfilter/xt_TPROXY.c |    2 +-
 net/netfilter/xt_socket.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index d7f1953..c73b713 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -285,7 +285,7 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 	int thoff = 0;
 	int tproto;
 
-	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
+	tproto = ipv6_find_hdr_cb(skb, &thoff, -1, NULL, NULL);
 	if (tproto < 0) {
 		pr_debug("unable to find transport header in IPv6 packet, dropping\n");
 		return NF_DROP;
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 9ea482d..4feca50 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -266,7 +266,7 @@ socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
 	int thoff = 0, tproto;
 	const struct xt_socket_mtinfo1 *info = (struct xt_socket_mtinfo1 *) par->matchinfo;
 
-	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
+	tproto = ipv6_find_hdr_cb(skb, &thoff, -1, NULL, NULL);
 	if (tproto < 0) {
 		pr_debug("unable to find transport header in IPv6 packet, dropping\n");
 		return NF_DROP;

