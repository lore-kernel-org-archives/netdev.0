From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/4] net_sched: cbq: remove a flaky use of qdisc_is_throttled()
Date: Fri, 10 Jun 2016 16:41:37 -0700
Message-ID: <1465602099-15808-3-git-send-email-edumazet@google.com>
References: <1465602099-15808-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35383 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932284AbcFJXlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 19:41:49 -0400
Received: by mail-pf0-f177.google.com with SMTP id c2so27527514pfa.2
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 16:41:48 -0700 (PDT)
In-Reply-To: <1465602099-15808-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far no qdisc ever unset the throttled bit at enqueue() time,
so CBQ usage of qdisc_is_throttled() was flaky.

Since __QDISC_STATE_THROTTLED set/unset is way too expensive
considering that only CBQ was eventually caring for this status,
it would make sense to implement a Qdisc ops ->is_throttled()
if we find that this is needed.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_cbq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index f2af31be6370..6e61f9aa8783 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -345,7 +345,7 @@ cbq_mark_toplevel(struct cbq_sched_data *q, struct cbq_class *cl)
 {
 	int toplevel = q->toplevel;
 
-	if (toplevel > cl->level && !(qdisc_is_throttled(cl->q))) {
+	if (toplevel > cl->level) {
 		psched_time_t now = psched_get_time();
 
 		do {
-- 
2.8.0.rc3.226.g39d4020
