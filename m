From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 1/2] ipvs: null check of net->ipvs in lblc(r) shedulers
Date: Wed, 25 Apr 2012 09:43:40 +0200
Message-ID: <1335339821-29684-2-git-send-email-hans.schillstrom@ericsson.com>
References: <1335339821-29684-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: <horms@verge.net.au>, <ja@ssi.bg>, <wensong@linux-vs.org>,
	<lvs-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:60712 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626Ab2DYHnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 03:43:46 -0400
In-Reply-To: <1335339821-29684-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid crash when registering shedulers after
the IPVS core initialization for netns fails. Do this by
checking for present core (net->ipvs).

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_lblc.c  |    3 +++
 net/netfilter/ipvs/ip_vs_lblcr.c |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 222b6cb..df646cc 100644
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
index 30c476f..570e31e 100644
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
1.7.2.3
