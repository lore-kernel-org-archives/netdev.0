From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] ipvs: info leak in __ip_vs_get_dest_entries()
Date: Mon, 10 Jun 2013 18:07:41 +0200
Message-ID: <1370880461-4265-6-git-send-email-pablo@netfilter.org>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59112 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754057Ab3FJQH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 12:07:56 -0400
In-Reply-To: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

The entry struct has a 2 byte hole after ->port and another 4 byte
hole after ->stats.outpkts.  You must have CAP_NET_ADMIN in your
namespace to hit this information leak.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5b142fb..9e6c2a0 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2542,6 +2542,7 @@ __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
 		struct ip_vs_dest *dest;
 		struct ip_vs_dest_entry entry;
 
+		memset(&entry, 0, sizeof(entry));
 		list_for_each_entry(dest, &svc->destinations, n_list) {
 			if (count >= get->num_dests)
 				break;
-- 
1.7.10.4
