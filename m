From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: Tue, 6 Jul 2004 14:41:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706144132.4a5fe83b.davem@redhat.com>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
	<20040702134437.5891e998@dell_ss3.pdx.osdl.net>
	<1088824432.1043.271.camel@jzny.localdomain>
	<20040705194925.37b7efcb.davem@redhat.com>
	<1089119090.4260.2.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, util@deuroconsult.ro, netdev@oss.sgi.com,
        lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1089119090.4260.2.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 06 Jul 2004 09:04:50 -0400
jamal <hadi@cyberus.ca> wrote:

> On Mon, 2004-07-05 at 22:49, David S. Miller wrote:
> > I'm going to hold off on Stephen's patches until Jamal and he has
> > a chance to fight it out :-)
> 
> Actually i would be fine with it if Stephen gets rid of the new "rate"
> thing.

Ok, so for now I'm going to just put in this part of Stephen's
patch which just adds the rtnetlink.h include and the loss
optimization.

To be honest, the rate feature is such a tiny amount of code...
it's not the end of the world if we put it in :-)

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/07/06 14:35:36-07:00 shemminger@osdl.org 
#   [PKT_SCHED]: Two small netem fixes.
#   
#   - rtnetlink.h needs including
#   - optimize loss test so that net_random() call is not done
#     when no-loss is indicated
#   
#   Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/sched/sch_netem.c
#   2004/07/06 14:31:50-07:00 shemminger@osdl.org +2 -1
#   [PKT_SCHED]: Two small netem fixes.
#   
#   - rtnetlink.h needs including
#   - optimize loss test so that net_random() call is not done
#     when no-loss is indicated
#   
#   Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-07-06 14:36:05 -07:00
+++ b/net/sched/sch_netem.c	2004-07-06 14:36:05 -07:00
@@ -18,6 +18,7 @@
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
 
 #include <net/pkt_sched.h>
 
@@ -54,7 +55,7 @@
 	pr_debug("netem_enqueue skb=%p @%lu\n", skb, jiffies);
 
 	/* Random packet drop 0 => none, ~0 => all */
-	if (q->loss >= net_random()) {
+	if (q->loss && q->loss >= net_random()) {
 		sch->stats.drops++;
 		return 0;	/* lie about loss so TCP doesn't know */
 	}
