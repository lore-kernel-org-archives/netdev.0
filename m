From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 64/84] ipvs: Pass ipvs not net into ip_vs_conn_net_flush
Date: Sun, 20 Sep 2015 01:23:20 -0500
Message-ID: <1442730220-32458-64-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	lvs-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53061 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754675AbbITGef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 02:34:35 -0400
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 76cdb6c06a52..43b7a7d2ba4d 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1309,11 +1309,10 @@ void ip_vs_random_dropentry(struct netns_ipvs *ipvs)
 /*
  *      Flush all the connection entries in the ip_vs_conn_tab
  */
-static void ip_vs_conn_flush(struct net *net)
+static void ip_vs_conn_flush(struct netns_ipvs *ipvs)
 {
 	int idx;
 	struct ip_vs_conn *cp, *cp_c;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 
 flush_again:
 	rcu_read_lock();
@@ -1359,8 +1358,10 @@ int __net_init ip_vs_conn_net_init(struct net *net)
 
 void __net_exit ip_vs_conn_net_cleanup(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	/* flush all the connection entries first */
-	ip_vs_conn_flush(net);
+	ip_vs_conn_flush(ipvs);
 	remove_proc_entry("ip_vs_conn", net->proc_net);
 	remove_proc_entry("ip_vs_conn_sync", net->proc_net);
 }
-- 
2.2.1
