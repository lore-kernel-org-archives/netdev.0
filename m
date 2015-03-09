From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 4/6] tcp_metrics: Remove the unused return code from tcp_metrics_flush_all
Date: Mon, 09 Mar 2015 13:30:02 -0500
Message-ID: <87ioeayqfp.fsf_-_@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:49211 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613AbbCISdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 14:33:41 -0400
In-Reply-To: <87h9tu114z.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Mon, 09 Mar 2015 13:22:52 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tcp_metrics_flush_all always returns 0.  Remove the unnecessary return code.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/tcp_metrics.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 4ec02d6cab5b..e98c6e9770c1 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1038,7 +1038,7 @@ out_free:
 
 #define deref_genl(p)	rcu_dereference_protected(p, lockdep_genl_is_held())
 
-static int tcp_metrics_flush_all(struct net *net)
+static void tcp_metrics_flush_all(struct net *net)
 {
 	unsigned int max_rows = 1U << net->ipv4.tcp_metrics_hash_log;
 	struct tcpm_hash_bucket *hb = net->ipv4.tcp_metrics_hash;
@@ -1059,7 +1059,6 @@ static int tcp_metrics_flush_all(struct net *net)
 			tm = next;
 		}
 	}
-	return 0;
 }
 
 static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
@@ -1076,8 +1075,10 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
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
