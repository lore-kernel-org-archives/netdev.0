From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netem: memory leak
Date: Fri, 4 Feb 2005 15:31:08 -0800
Message-ID: <20050204153108.703ea71b@dxpl.pdx.osdl.net>
References: <20050204231103.33325.qmail@web41510.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: js si <nistnet_user@yahoo.com>, netem@lists.osdl.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050204231103.33325.qmail@web41510.mail.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Good catch.. netem needs to free skb's that are dropped due to loss
simulation.

diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2005-02-04 15:30:13 -08:00
+++ b/net/sched/sch_netem.c	2005-02-04 15:30:13 -08:00
@@ -177,6 +177,7 @@
 	if (q->loss && q->loss >= get_crandom(&q->loss_cor)) {
 		pr_debug("netem_enqueue: random loss\n");
 		sch->qstats.drops++;
+		kfree_skb(skb);
 		return 0;	/* lie about loss so TCP doesn't know */
 	}
 
