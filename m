From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_tbf: report backlog information
Date: Thu, 29 Dec 2011 10:27:44 +0100
Message-ID: <1325150864.2607.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44076 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926Ab1L2J1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 04:27:48 -0500
Received: by vbbfc26 with SMTP id fc26so10114748vbb.19
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2011 01:27:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide child qdisc backlog (byte count) information so that "tc -s
qdisc" can report it to user.

qdisc netem 30: root refcnt 18 limit 1000 delay 20.0ms  10.0ms
 Sent 948517 bytes 898 pkt (dropped 0, overlimits 0 requeues 1) 
 rate 175056bit 16pps backlog 114b 1p requeues 1 
qdisc tbf 40: parent 30: rate 256000bit burst 20Kb/8 mpu 0b lat 0us 
 Sent 948517 bytes 898 pkt (dropped 15, overlimits 611 requeues 0) 
 backlog 18168b 12p requeues 0 

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_tbf.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 1dcfb52..b8e1563 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -346,6 +346,7 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 	struct nlattr *nest;
 	struct tc_tbf_qopt opt;
 
+	sch->qstats.backlog = q->qdisc->qstats.backlog;
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
