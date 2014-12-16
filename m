From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/2] ip_tunnel: Add sanity checks to ip_tunnel_encap_add_ops()
Date: Tue, 16 Dec 2014 21:05:20 +0100
Message-ID: <49e7071697c633338689b0450f9d6562bae5d146.1418759998.git.tgraf@suug.ch>
References: <cover.1418759998.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, therbert@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49533 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbaLPUFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 15:05:24 -0500
In-Reply-To: <cover.1418759998.git.tgraf@suug.ch>
In-Reply-To: <cover.1418759998.git.tgraf@suug.ch>
References: <cover.1418759998.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The symbols are exported and could be used by external modules.

Fixes: a8c5f9 ("ip_tunnel: Ops registration for secondary encap (fou, gue)")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/ip_tunnel.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 63e745a..2f498f8 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -514,6 +514,9 @@ const struct ip_tunnel_encap_ops __rcu *
 int ip_tunnel_encap_add_ops(const struct ip_tunnel_encap_ops *ops,
 			    unsigned int num)
 {
+	if (num >= MAX_IPTUN_ENCAP_OPS)
+		return -ERANGE;
+
 	return !cmpxchg((const struct ip_tunnel_encap_ops **)
 			&iptun_encaps[num],
 			NULL, ops) ? 0 : -1;
@@ -525,6 +528,9 @@ int ip_tunnel_encap_del_ops(const struct ip_tunnel_encap_ops *ops,
 {
 	int ret;
 
+	if (num >= MAX_IPTUN_ENCAP_OPS)
+		return -ERANGE;
+
 	ret = (cmpxchg((const struct ip_tunnel_encap_ops **)
 		       &iptun_encaps[num],
 		       ops, NULL) == ops) ? 0 : -1;
-- 
1.9.3
