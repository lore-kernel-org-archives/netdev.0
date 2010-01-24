From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH] tc: add new queue discipline: head drop fifo
Date: Sun, 24 Jan 2010 23:31:05 +0100
Message-ID: <1264372265-31442-1-git-send-email-hagen@jauu.net>
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:59730 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753246Ab0AXWbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2010 17:31:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the required changes to gain access to
the head drop classfull queuing discipline named
pfifo_head_drop. In difference to pfifo or pfifo_fast
this queuing discipline will drop the first packet
in the case of queue congestion. As a result the queue
contain always the freshest packets.

To replace the current a root queueing discipline
for eth0:
$ tc qdisc replace dev eth0 root pfifo_head_drop

And show statistics:
$ tc -s qdisc show dev eth0

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 tc/q_fifo.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/tc/q_fifo.c b/tc/q_fifo.c
index f561752..6242a98 100644
--- a/tc/q_fifo.c
+++ b/tc/q_fifo.c
@@ -25,7 +25,7 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... [p|b]fifo [ limit NUMBER ]\n");
+	fprintf(stderr, "Usage: ... <[p|b]fifo | pfifo_head_drop> [ limit NUMBER ]\n");
 }
 
 static int fifo_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
@@ -89,6 +89,12 @@ struct qdisc_util pfifo_qdisc_util = {
 	.print_qopt = fifo_print_opt,
 };
 
+struct qdisc_util pfifo_head_drop_qdisc_util = {
+	.id = "pfifo_head_drop",
+	.parse_qopt = fifo_parse_opt,
+	.print_qopt = fifo_print_opt,
+};
+
 extern int prio_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt);
 struct qdisc_util pfifo_fast_qdisc_util = {
 	.id = "pfifo_fast",
-- 
1.6.6.196.g1f735.dirty

