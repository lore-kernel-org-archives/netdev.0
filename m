From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netem missing qdisc destroy
Date: Mon, 12 Jul 2004 10:28:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040712102855.1a08262c@dell_ss3.pdx.osdl.net>
References: <20040712101500.4a0babd3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040712101500.4a0babd3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The underlying qdisc was not being properly destroyed, shows up as
assertion failure on device removal.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-07-12 10:27:10 -07:00
+++ b/net/sched/sch_netem.c	2004-07-12 10:27:10 -07:00
@@ -806,6 +806,9 @@
 	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
 
 	del_timer_sync(&q->timer);
+
+	qdisc_destroy(q->qdisc);
+	q->qdisc = &noop_qdisc;
 }
 
 static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
