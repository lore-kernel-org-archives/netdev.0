From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] htb: report overhead attribute
Date: Sun, 02 Jun 2013 14:33:01 -0700
Message-ID: <1370208781.24311.89.camel@edumazet-glaptop>
References: <20130529151330.22c5c89e@redhat.com>
	 <1370207755.24311.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:44822 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563Ab3FBVdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 17:33:03 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so496804pde.23
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 14:33:03 -0700 (PDT)
In-Reply-To: <1370207755.24311.81.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

"tc class show dev ..." omits the overhead attribute for HTB.

After patch I have :

tc class add dev $DEV parent 1: classid 1:1 est 1sec 4sec htb \
    rate 12Mbit mtu 1500 quantum 1514 overhead 20

tc class show dev $DEV
class htb 1:1 root prio 0 rate 12000Kbit overhead 20 ceil 12000Kbit
burst 1500b cburst 1500b

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 tc/q_htb.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/tc/q_htb.c b/tc/q_htb.c
index caa47c2..e6b09bb 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -264,6 +264,8 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 				fprintf(f, "quantum %d ", (int)hopt->quantum);
 		}
 	    fprintf(f, "rate %s ", sprint_rate(hopt->rate.rate, b1));
+	    if (hopt->rate.overhead)
+		fprintf(f, "overhead %u ", hopt->rate.overhead);
 	    buffer = tc_calc_xmitsize(hopt->rate.rate, hopt->buffer);
 	    fprintf(f, "ceil %s ", sprint_rate(hopt->ceil.rate, b1));
 	    cbuffer = tc_calc_xmitsize(hopt->ceil.rate, hopt->cbuffer);
