From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/5] ipvs: null check of net->ipvs in lblc(r) shedulers
Date: Fri, 27 Apr 2012 09:53:57 +0900
Message-ID: <1335488039-13471-4-git-send-email-horms@verge.net.au>
References: <1335488039-13471-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58361 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753970Ab2D0AyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 20:54:24 -0400
In-Reply-To: <1335488039-13471-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

Avoid crash when registering shedulers after
the IPVS core initialization for netns fails. Do this by
checking for present core (net->ipvs).

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblc.c  |    3 +++
 net/netfilter/ipvs/ip_vs_lblcr.c |    3 +++
 2 files changed, 6 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 0f16283..caa4370 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -551,6 +551,9 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	if (!ipvs)
+		return -ENOENT;
+
 	if (!net_eq(net, &init_net)) {
 		ipvs->lblc_ctl_table = kmemdup(vs_vars_table,
 						sizeof(vs_vars_table),
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index eec797f..548bf37 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -745,6 +745,9 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	if (!ipvs)
+		return -ENOENT;
+
 	if (!net_eq(net, &init_net)) {
 		ipvs->lblcr_ctl_table = kmemdup(vs_vars_table,
 						sizeof(vs_vars_table),
-- 
1.7.9.5
