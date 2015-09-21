From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 74/84] ipvs: Pass ipvs not net into sysctl_nat_icmp_send
Date: Mon, 21 Sep 2015 13:02:51 -0500
Message-ID: <1442858581-15869-74-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:33636 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756886AbbIUSOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 14:14:12 -0400
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 15661691bf7d..b25fb3309472 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -657,9 +657,8 @@ static int sysctl_snat_reroute(struct sk_buff *skb)
 	return ipvs->sysctl_snat_reroute;
 }
 
-static int sysctl_nat_icmp_send(struct net *net)
+static int sysctl_nat_icmp_send(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	return ipvs->sysctl_nat_icmp_send;
 }
 
@@ -671,7 +670,7 @@ static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs)
 #else
 
 static int sysctl_snat_reroute(struct sk_buff *skb) { return 0; }
-static int sysctl_nat_icmp_send(struct net *net) { return 0; }
+static int sysctl_nat_icmp_send(struct netns_ipvs *ipvs) { return 0; }
 static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs) { return 0; }
 
 #endif
@@ -1252,7 +1251,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 
 	if (likely(cp))
 		return handle_response(af, skb, pd, cp, &iph, hooknum);
-	if (sysctl_nat_icmp_send(net) &&
+	if (sysctl_nat_icmp_send(ipvs) &&
 	    (pp->protocol == IPPROTO_TCP ||
 	     pp->protocol == IPPROTO_UDP ||
 	     pp->protocol == IPPROTO_SCTP)) {
-- 
2.2.1
