From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] sfq: add divisor support
Date: Sun, 23 Jan 2011 11:09:06 +0100
Message-ID: <1295777346.17333.26.camel@edumazet-laptop>
References: <1295518498.2825.2.camel@edumazet-laptop>
	 <20110120.165618.180427971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:52353 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab1AWKJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jan 2011 05:09:13 -0500
Received: by wwi17 with SMTP id 17so2233812wwi.1
        for <netdev@vger.kernel.org>; Sun, 23 Jan 2011 02:09:12 -0800 (PST)
In-Reply-To: <20110120.165618.180427971.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 2.6.39, we can build SFQ queues with a given hash table size,
different than default one (1024 slots)

# tc qdisc add dev eth0 sfq help
Usage: ... sfq [ limit NUMBER ] [ perturb SECS ] [ quantum BYTES ]
               [ divisor NUMBER ]

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 tc/q_sfq.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/tc/q_sfq.c b/tc/q_sfq.c
index 71a3c9a..98ec530 100644
--- a/tc/q_sfq.c
+++ b/tc/q_sfq.c
@@ -26,6 +26,7 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... sfq [ limit NUMBER ] [ perturb SECS ] [ quantum BYTES ]\n");
+	fprintf(stderr, "               [ divisor NUMBER ]\n");
 }
 
 static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
@@ -61,6 +62,13 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				return -1;
 			}
 			ok++;
+		} else if (strcmp(*argv, "divisor") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opt.divisor, *argv, 0)) {
+				fprintf(stderr, "Illegal \"divisor\"\n");
+				return -1;
+			}
+			ok++;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -93,6 +101,7 @@ static int sfq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (show_details) {
 		fprintf(f, "flows %u/%u ", qopt->flows, qopt->divisor);
 	}
+	fprintf(f, "divisor %u ", qopt->divisor);
 	if (qopt->perturb_period)
 		fprintf(f, "perturb %dsec ", qopt->perturb_period);
 	return 0;


