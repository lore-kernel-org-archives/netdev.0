From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 01/02]: Add support for SFQ xstats
Date: Thu, 31 Jan 2008 18:58:52 +0100
Message-ID: <47A20C5C.1070906@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080602010101070106010505"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55182 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761960AbYAaR7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 12:59:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080602010101070106010505
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------080602010101070106010505
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[IPROUTE]: Add support for SFQ xstats

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 196870f762ee393438c42115425f4af69e5b5186
tree 5650c1f93cc58886f8f97a0e55e374c157b96e2e
parent 54bb35c69cec6c730a4ac95530a1d2ca6670f73b
author Patrick McHardy <kaber@trash.net> Thu, 31 Jan 2008 15:10:07 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 31 Jan 2008 15:10:07 +0100

 include/linux/pkt_sched.h |    5 +++++
 tc/q_sfq.c                |   17 +++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 3276135..4ccd684 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -150,6 +150,11 @@ struct tc_sfq_qopt
 	unsigned	flows;		/* Maximal number of flows  */
 };
 
+struct tc_sfq_xstats
+{
+	__u32		allot;
+};
+
 /*
  *  NOTE: limit, divisor and flows are hardwired to code at the moment.
  *
diff --git a/tc/q_sfq.c b/tc/q_sfq.c
index 05385cf..ce4dade 100644
--- a/tc/q_sfq.c
+++ b/tc/q_sfq.c
@@ -100,8 +100,25 @@ static int sfq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	return 0;
 }
 
+static int sfq_print_xstats(struct qdisc_util *qu, FILE *f,
+			    struct rtattr *xstats)
+{
+	struct tc_sfq_xstats *st;
+
+	if (xstats == NULL)
+		return 0;
+	if (RTA_PAYLOAD(xstats) < sizeof(*st))
+		return -1;
+	st = RTA_DATA(xstats);
+
+	fprintf(f, " allot %d ", st->allot);
+	fprintf(f, "\n");
+	return 0;
+}
+
 struct qdisc_util sfq_qdisc_util = {
 	.id		= "sfq",
 	.parse_qopt	= sfq_parse_opt,
 	.print_qopt	= sfq_print_opt,
+	.print_xstats	= sfq_print_xstats,
 };

--------------080602010101070106010505--
