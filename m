From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 6/8] tcp_metrics: Remove the unused return code from tcp_metrics_flush_all
Date: Wed, 11 Mar 2015 11:41:28 -0500
Message-ID: <87wq2nebbb.fsf_-_@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com,
	Julian Anastasov <ja@ssi.bg>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42571 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbbCKQpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 12:45:10 -0400
In-Reply-To: <87vbi7fq92.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 11 Mar 2015 11:33:29 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tcp_metrics_flush_all always returns 0.  Remove the unnecessary return code.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/tcp_metrics.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 461c3d2e1ca4..0d07e14f2ca5 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1043,7 +1043,7 @@ out_free:
 
 #define deref_genl(p)	rcu_dereference_protected(p, lockdep_genl_is_held())
 
-static int tcp_metrics_flush_all(struct net *net)
+static void tcp_metrics_flush_all(struct net *net)
 {
 	unsigned int max_rows = 1U << net->ipv4.tcp_metrics_hash_log;
 	struct tcpm_hash_bucket *hb = net->ipv4.tcp_metrics_hash;
@@ -1064,7 +1064,6 @@ static int tcp_metrics_flush_all(struct net *net)
 			tm = next;
 		}
 	}
-	return 0;
 }
 
 static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
@@ -1081,8 +1080,10 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	ret = parse_nl_addr(info, &daddr, &hash, 1);
 	if (ret < 0)
 		return ret;
-	if (ret > 0)
-		return tcp_metrics_flush_all(net);
+	if (ret > 0) {
+		tcp_metrics_flush_all(net);
+		return 0;
+	}
 	ret = parse_nl_saddr(info, &saddr);
 	if (ret < 0)
 		src = false;
-- 
2.2.1
