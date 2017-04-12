From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 2/2] l2tp: define parameters of l2tp_tunnel_find*()
 as "const"
Date: Wed, 12 Apr 2017 10:05:30 +0200
Message-ID: <2e88f5ce221477cffc73a01d8792a5b92d79a67d.1491984104.git.g.nault@alphalink.fr>
References: <cover.1491984104.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:37851 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752719AbdDLIFg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 04:05:36 -0400
Content-Disposition: inline
In-Reply-To: <cover.1491984104.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_tunnel_find() and l2tp_tunnel_find_nth() don't modify "net".

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_core.c | 4 ++--
 net/l2tp/l2tp_core.h | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 4828111c9ea7..fa0342574b89 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -379,7 +379,7 @@ static int l2tp_session_add_to_tunnel(struct l2tp_tunnel *tunnel,
 
 /* Lookup a tunnel by id
  */
-struct l2tp_tunnel *l2tp_tunnel_find(struct net *net, u32 tunnel_id)
+struct l2tp_tunnel *l2tp_tunnel_find(const struct net *net, u32 tunnel_id)
 {
 	struct l2tp_tunnel *tunnel;
 	struct l2tp_net *pn = l2tp_pernet(net);
@@ -397,7 +397,7 @@ struct l2tp_tunnel *l2tp_tunnel_find(struct net *net, u32 tunnel_id)
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_find);
 
-struct l2tp_tunnel *l2tp_tunnel_find_nth(struct net *net, int nth)
+struct l2tp_tunnel *l2tp_tunnel_find_nth(const struct net *net, int nth)
 {
 	struct l2tp_net *pn = l2tp_pernet(net);
 	struct l2tp_tunnel *tunnel;
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 1a46bc44632f..eec5ad2ebb93 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -238,8 +238,8 @@ struct l2tp_session *l2tp_session_get_nth(struct l2tp_tunnel *tunnel, int nth,
 struct l2tp_session *l2tp_session_get_by_ifname(const struct net *net,
 						const char *ifname,
 						bool do_ref);
-struct l2tp_tunnel *l2tp_tunnel_find(struct net *net, u32 tunnel_id);
-struct l2tp_tunnel *l2tp_tunnel_find_nth(struct net *net, int nth);
+struct l2tp_tunnel *l2tp_tunnel_find(const struct net *net, u32 tunnel_id);
+struct l2tp_tunnel *l2tp_tunnel_find_nth(const struct net *net, int nth);
 
 int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id,
 		       u32 peer_tunnel_id, struct l2tp_tunnel_cfg *cfg,
-- 
2.11.0
