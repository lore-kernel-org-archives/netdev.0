From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 3/8] tcp_metrics: panic when tcp_metrics_init fails.
Date: Wed, 11 Mar 2015 11:38:12 -0500
Message-ID: <87egovfq17.fsf_-_@x220.int.ebiederm.org>
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
Received: from out03.mta.xmission.com ([166.70.13.233]:56087 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259AbbCKQlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 12:41:53 -0400
In-Reply-To: <87vbi7fq92.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 11 Mar 2015 11:33:29 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is not a practical way to cleanup during boot so
just panic if there is a problem initializing tcp_metrics.

That will at least give us a clear place to start debugging
if something does go wrong.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/tcp_metrics.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index e5f41bd5ec1b..4206b14d956d 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1175,16 +1175,10 @@ void __init tcp_metrics_init(void)
 
 	ret = register_pernet_subsys(&tcp_net_metrics_ops);
 	if (ret < 0)
-		goto cleanup;
+		panic("Could not allocate the tcp_metrics hash table\n");
+
 	ret = genl_register_family_with_ops(&tcp_metrics_nl_family,
 					    tcp_metrics_nl_ops);
 	if (ret < 0)
-		goto cleanup_subsys;
-	return;
-
-cleanup_subsys:
-	unregister_pernet_subsys(&tcp_net_metrics_ops);
-
-cleanup:
-	return;
+		panic("Could not register tcp_metrics generic netlink\n");
 }
-- 
2.2.1
