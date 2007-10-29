From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 2/3] Change perturb_period to unsigned.
Date: Mon, 29 Oct 2007 00:24:46 -0700
Message-ID: <1193642687-1272-3-git-send-email-bugfood-ml@fatooh.org>
References: <1193642687-1272-1-git-send-email-bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:50397 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860AbXJ2HYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:24:50 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id AB44317C2CE
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 02:24:49 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IIfI6GbHf3+C for <netdev@vger.kernel.org>;
	Mon, 29 Oct 2007 02:24:49 -0500 (CDT)
Received: from bugfood (c-24-7-71-25.hsd1.ca.comcast.net [24.7.71.25])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id D010017C231
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 02:24:48 -0500 (CDT)
In-Reply-To: <1193642687-1272-1-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This corresponds to the kernel patch doing the same.

Here, too, this will technically break binary compatibility with older
kernels, but that shouldn't be a problem because negative perturb_period
values aren't usable anyway.
---
 include/linux/pkt_sched.h |    2 +-
 tc/q_sfq.c                |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 9d41f63..fb04a89 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -142,7 +142,7 @@ enum
 struct tc_sfq_qopt
 {
 	unsigned	quantum;	/* Bytes per round allocated to flow */
-	int		perturb_period;	/* Period of hash perturbation */
+	unsigned	perturb_period;	/* Period of hash perturbation */
 	__u32		limit;		/* Maximal packets in queue */
 	unsigned	divisor;	/* Hash divisor  */
 	unsigned	flows;		/* Maximal number of flows  */
diff --git a/tc/q_sfq.c b/tc/q_sfq.c
index 19e76ba..83c8a54 100644
--- a/tc/q_sfq.c
+++ b/tc/q_sfq.c
@@ -47,7 +47,7 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 			ok++;
 		} else if (strcmp(*argv, "perturb") == 0) {
 			NEXT_ARG();
-			if (get_integer(&opt.perturb_period, *argv, 0)) {
+			if (get_u32(&opt.perturb_period, *argv, 0)) {
 				fprintf(stderr, "Illegal \"perturb\"\n");
 				return -1;
 			}
@@ -114,7 +114,7 @@ static int sfq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		fprintf(f, "flows %u/%u ", qopt->flows, qopt->divisor);
 	}
 	if (qopt->perturb_period)
-		fprintf(f, "perturb %dsec ", qopt->perturb_period);
+		fprintf(f, "perturb %usec ", qopt->perturb_period);
 	return 0;
 }
 
-- 
1.5.3.4

