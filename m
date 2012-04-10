From: pablo@netfilter.org
Subject: [PATCH 5/5] netfilter: nf_conntrack: fix incorrect logic in nf_conntrack_init_net
Date: Tue, 10 Apr 2012 14:49:01 +0200
Message-ID: <1334062141-3962-6-git-send-email-pablo@netfilter.org>
References: <1334062141-3962-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44999 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755689Ab2DJMt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 08:49:27 -0400
In-Reply-To: <1334062141-3962-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

in function nf_conntrack_init_net,when nf_conntrack_timeout_init falied,
we should call nf_conntrack_ecache_fini to do rollback.
but the current code calls nf_conntrack_timeout_fini.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 3cc4487..729f157 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1592,7 +1592,7 @@ static int nf_conntrack_init_net(struct net *net)
 	return 0;
 
 err_timeout:
-	nf_conntrack_timeout_fini(net);
+	nf_conntrack_ecache_fini(net);
 err_ecache:
 	nf_conntrack_tstamp_fini(net);
 err_tstamp:
-- 
1.7.2.5
