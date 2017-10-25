From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 1/1] l2tp: cleanup l2tp_tunnel_delete calls
Date: Wed, 25 Oct 2017 15:57:55 +0200
Message-ID: <20171025135755.25487-1-jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>,
        Sabrina Dubroca <sd@queasysnail.net>,
        Guillaume Nault <g.nault@alphalink.fr>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41796 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750891AbdJYN57 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 09:57:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_tunnel_delete does not return anything since commit 62b982eeb458
("l2tp: fix race condition in l2tp_tunnel_delete").  But call sites of
l2tp_tunnel_delete still do casts to void to avoid unused return value
warnings.

Kill these now useless casts.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Sabrina Dubroca <sd@queasysnail.net>
Cc: Guillaume Nault <g.nault@alphalink.fr>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/l2tp/l2tp_core.c    | 2 +-
 net/l2tp/l2tp_netlink.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 02d61101b108..af22aa8ae35b 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1891,7 +1891,7 @@ static __net_exit void l2tp_exit_net(struct net *net)
 
 	rcu_read_lock_bh();
 	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
-		(void)l2tp_tunnel_delete(tunnel);
+		l2tp_tunnel_delete(tunnel);
 	}
 	rcu_read_unlock_bh();
 
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 7135f4645d3a..c28223d8092b 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -282,7 +282,7 @@ static int l2tp_nl_cmd_tunnel_delete(struct sk_buff *skb, struct genl_info *info
 	l2tp_tunnel_notify(&l2tp_nl_family, info,
 			   tunnel, L2TP_CMD_TUNNEL_DELETE);
 
-	(void) l2tp_tunnel_delete(tunnel);
+	l2tp_tunnel_delete(tunnel);
 
 	l2tp_tunnel_dec_refcount(tunnel);
 
-- 
2.14.3
