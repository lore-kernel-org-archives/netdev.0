From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 06/10 net-next] l2tp: show IPv6 addresses in l2tp debugfs file
Date: Mon, 30 Apr 2012 08:48:51 +0100
Message-ID: <1335772135-27910-7-git-send-email-jchapman@katalix.com>
References: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
Cc: Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:53477 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754819Ab2D3Hs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 03:48:59 -0400
In-Reply-To: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Elston <celston@katalix.com>

If an L2TP tunnel uses IPv6, make sure the l2tp debugfs file shows the
IPv6 address correctly.

Signed-off-by: Chris Elston <celston@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_debugfs.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index 7613013..c0d57ba 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -122,6 +122,14 @@ static void l2tp_dfs_seq_tunnel_show(struct seq_file *m, void *v)
 	seq_printf(m, "\nTUNNEL %u peer %u", tunnel->tunnel_id, tunnel->peer_tunnel_id);
 	if (tunnel->sock) {
 		struct inet_sock *inet = inet_sk(tunnel->sock);
+
+#if IS_ENABLED(CONFIG_IPV6)
+		if (tunnel->sock->sk_family == AF_INET6) {
+			struct ipv6_pinfo *np = inet6_sk(tunnel->sock);
+			seq_printf(m, " from %pI6c to %pI6c\n",
+				&np->saddr, &np->daddr);
+		} else
+#endif
 		seq_printf(m, " from %pI4 to %pI4\n",
 			   &inet->inet_saddr, &inet->inet_daddr);
 		if (tunnel->encap == L2TP_ENCAPTYPE_UDP)
-- 
1.7.0.4
