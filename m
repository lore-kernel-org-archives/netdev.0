From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net] ila: Fix tailroom allocation of lwtstate
Date: Wed, 19 Oct 2016 23:16:39 +0200
Message-ID: <d7e2292a2be9d142a05b7c528746820bac358065.1476911506.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37020 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753594AbcJSVQp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 17:16:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tailroom is supposed to be of length sizeof(struct ila_lwt) but
sizeof(struct ila_params) is currently allocated.

This leads to the dst_cache and connected member of ila_lwt being
referenced out of bounds.

struct ila_lwt {
	struct ila_params p;
	struct dst_cache dst_cache;
	u32 connected : 1;
};

Fixes: 65d7ab8de582 ("net: Identifier Locator Addressing module")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 -stable candidate

 net/ipv6/ila/ila_lwt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index 9fafba6..c7a39d0 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -122,7 +122,7 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
 	struct ila_lwt *ilwt;
 	struct ila_params *p;
 	struct nlattr *tb[ILA_ATTR_MAX + 1];
-	size_t encap_len = sizeof(*p);
+	size_t encap_len = sizeof(*ilwt);
 	struct lwtunnel_state *newts;
 	const struct fib6_config *cfg6 = cfg;
 	struct ila_addr *iaddr;
-- 
2.7.4
