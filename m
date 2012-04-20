From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 06/10] l2tp: show IPv6 addresses in l2tp debugfs file
Date: Fri, 20 Apr 2012 10:02:49 +0100
Message-ID: <1334912573-28804-7-git-send-email-jchapman@katalix.com>
References: <1334912573-28804-1-git-send-email-jchapman@katalix.com>
Cc: bcrl@kvack.org, Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:56665 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981Ab2DTJDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 05:03:00 -0400
In-Reply-To: <1334912573-28804-1-git-send-email-jchapman@katalix.com>
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
