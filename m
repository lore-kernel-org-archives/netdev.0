From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/2] ip_tunnel: Add missing validation of encap type to ip_tunnel_encap_setup()
Date: Tue, 16 Dec 2014 21:05:21 +0100
Message-ID: <dd70de766b1111fdcb4794f6d671e4eca5053730.1418759998.git.tgraf@suug.ch>
References: <cover.1418759998.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, therbert@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49540 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbaLPUFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 15:05:24 -0500
In-Reply-To: <cover.1418759998.git.tgraf@suug.ch>
In-Reply-To: <cover.1418759998.git.tgraf@suug.ch>
References: <cover.1418759998.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The encap->type comes straight from Netlink. Validate it against
max supported encap types just like ip_encap_hlen() already does.

Fixes: a8c5f9 ("ip_tunnel: Ops registration for secondary encap (fou, gue)")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/ip_tunnel.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 2f498f8..d3e4479 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -573,6 +573,9 @@ int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
 	if (t->encap.type == TUNNEL_ENCAP_NONE)
 		return 0;
 
+	if (t->encap.type >= MAX_IPTUN_ENCAP_OPS)
+		return -EINVAL;
+
 	rcu_read_lock();
 	ops = rcu_dereference(iptun_encaps[t->encap.type]);
 	if (likely(ops && ops->build_header))
-- 
1.9.3
