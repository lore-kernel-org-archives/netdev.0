From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 53/84] ipvs: Pass ipvs not net into ip_vs_app_inc_new
Date: Mon, 21 Sep 2015 13:02:30 -0500
Message-ID: <1442858581-15869-53-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46817 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756232AbbIUSN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 14:13:59 -0400
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_app.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index f20f72c4ac80..951516b7783b 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -75,10 +75,9 @@ static void ip_vs_app_inc_rcu_free(struct rcu_head *head)
  *	Allocate/initialize app incarnation and register it in proto apps.
  */
 static int
-ip_vs_app_inc_new(struct net *net, struct ip_vs_app *app, __u16 proto,
+ip_vs_app_inc_new(struct netns_ipvs *ipvs, struct ip_vs_app *app, __u16 proto,
 		  __u16 port)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_protocol *pp;
 	struct ip_vs_app *inc;
 	int ret;
@@ -180,11 +179,12 @@ int
 register_ip_vs_app_inc(struct net *net, struct ip_vs_app *app, __u16 proto,
 		       __u16 port)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	int result;
 
 	mutex_lock(&__ip_vs_app_mutex);
 
-	result = ip_vs_app_inc_new(net, app, proto, port);
+	result = ip_vs_app_inc_new(ipvs, app, proto, port);
 
 	mutex_unlock(&__ip_vs_app_mutex);
 
-- 
2.2.1
