From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/8] netfilter: ipset: off by one in ip_set_nfnl_get_byindex()
Date: Mon, 27 Oct 2014 22:38:01 +0100
Message-ID: <1414445887-5108-3-git-send-email-pablo@netfilter.org>
References: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35971 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752646AbaJ0Vgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 17:36:38 -0400
In-Reply-To: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

The ->ip_set_list[] array is initialized in ip_set_net_init() and it
has ->ip_set_max elements so this check should be >= instead of >
otherwise we are off by one.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 912e5a0..86f9d76 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -659,7 +659,7 @@ ip_set_nfnl_get_byindex(struct net *net, ip_set_id_t index)
 	struct ip_set *set;
 	struct ip_set_net *inst = ip_set_pernet(net);
 
-	if (index > inst->ip_set_max)
+	if (index >= inst->ip_set_max)
 		return IPSET_INVALID_ID;
 
 	nfnl_lock(NFNL_SUBSYS_IPSET);
-- 
1.7.10.4
