From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 2/3] Change perturb_period to unsigned.
Date: Sat, 25 Aug 2007 15:30:27 -0700
Message-ID: <118808102970-git-send-email-bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:41399 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761512AbXHYWa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 18:30:29 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id 5BC9E17C316
	for <netdev@vger.kernel.org>; Sat, 25 Aug 2007 17:30:30 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id U6vsLFfCwAgV for <netdev@vger.kernel.org>;
	Sat, 25 Aug 2007 17:30:30 -0500 (CDT)
Received: from bugfood (c-76-102-59-34.hsd1.ca.comcast.net [76.102.59.34])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id BF9B317C313
	for <netdev@vger.kernel.org>; Sat, 25 Aug 2007 17:30:29 -0500 (CDT)
In-Reply-To: 11880808243166-git-send-email-bugfood-ml@fatooh.org
References: 11880808243166-git-send-email-bugfood-ml@fatooh.org
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
index 37946d4..0252bb7 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -133,7 +133,7 @@ enum
 struct tc_sfq_qopt
 {
 	unsigned	quantum;	/* Bytes per round allocated to flow */
-	int		perturb_period;	/* Period of hash perturbation */
+	unsigned	perturb_period;	/* Period of hash perturbation */
 	__u32		limit;		/* Maximal packets in queue */
 	unsigned	divisor;	/* Hash divisor  */
 	unsigned	flows;		/* Maximal number of flows  */
diff --git a/tc/q_sfq.c b/tc/q_sfq.c
index 7754db7..c9fcc53 100644
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
@@ -115,7 +115,7 @@ static int sfq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		fprintf(f, "flows %u/%u ", qopt->flows, qopt->divisor);
 	}
 	if (qopt->perturb_period)
-		fprintf(f, "perturb %dsec ", qopt->perturb_period);
+		fprintf(f, "perturb %usec ", qopt->perturb_period);
 	return 0;
 }
 
-- 
1.5.2.4

