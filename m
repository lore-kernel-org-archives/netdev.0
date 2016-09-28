From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2-next] tc: fq: display unthrottle latency
Date: Wed, 28 Sep 2016 06:23:15 -0700
Message-ID: <1475068995.28155.96.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34189 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932642AbcI1NXR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 09:23:17 -0400
Received: by mail-pa0-f67.google.com with SMTP id r9so1419502paz.1
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 06:23:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In linux-4.9 fq packet scheduler got a new stat :

unthrottle_latency in nano second units.

Gives a good indication of system load or timer implementation
latencies.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/pkt_sched.h |    2 +-
 tc/q_fq.c                 |    3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index f8e39db..df7451d 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -811,7 +811,7 @@ struct tc_fq_qd_stats {
 	__u32	flows;
 	__u32	inactive_flows;
 	__u32	throttled_flows;
-	__u32	pad;
+	__u32	unthrottle_latency_ns;
 };
 
 /* Heavy-Hitter Filter */
diff --git a/tc/q_fq.c b/tc/q_fq.c
index 90147a6..c9efbfc 100644
--- a/tc/q_fq.c
+++ b/tc/q_fq.c
@@ -312,6 +312,9 @@ static int fq_print_xstats(struct qdisc_util *qu, FILE *f,
 
 	fprintf(f, ", %llu throttled", st->throttled);
 
+	if (st->unthrottle_latency_ns)
+		fprintf(f, ", %u ns latency", st->unthrottle_latency_ns);
+
 	if (st->flows_plimit)
 		fprintf(f, ", %llu flows_plimit", st->flows_plimit);
 
