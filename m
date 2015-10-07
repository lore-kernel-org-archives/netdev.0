From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH-next v2 3/4] net/sched: make sch_blackhole.c explicitly non-modular
Date: Wed, 7 Oct 2015 17:27:45 -0400
Message-ID: <1444253266-22012-4-git-send-email-paul.gortmaker@windriver.com>
References: <1444253266-22012-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47780 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756317AbbJGVaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 17:30:02 -0400
In-Reply-To: <1444253266-22012-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Kconfig currently controlling compilation of this code is:

net/sched/Kconfig:menuconfig NET_SCHED
net/sched/Kconfig:      bool "QoS and/or fair queueing"

...meaning that it currently is not being built as a module by anyone.

Lets remove the modular code that is essentially orphaned, so that
when reading the driver there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.  We can
change to one of the other priority initcalls (subsys?) at any later
date, if desired.

We also delete the MODULE_LICENSE tag since all that information
is already contained at the top of the file in the comments.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/sched/sch_blackhole.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/net/sched/sch_blackhole.c b/net/sched/sch_blackhole.c
index 094a874b48bc..3fee70d9814f 100644
--- a/net/sched/sch_blackhole.c
+++ b/net/sched/sch_blackhole.c
@@ -11,7 +11,7 @@
  * Note: Quantum tunneling is not supported.
  */
 
-#include <linux/module.h>
+#include <linux/init.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
@@ -37,17 +37,8 @@ static struct Qdisc_ops blackhole_qdisc_ops __read_mostly = {
 	.owner		= THIS_MODULE,
 };
 
-static int __init blackhole_module_init(void)
+static int __init blackhole_init(void)
 {
 	return register_qdisc(&blackhole_qdisc_ops);
 }
-
-static void __exit blackhole_module_exit(void)
-{
-	unregister_qdisc(&blackhole_qdisc_ops);
-}
-
-module_init(blackhole_module_init)
-module_exit(blackhole_module_exit)
-
-MODULE_LICENSE("GPL");
+device_initcall(blackhole_init)
-- 
2.6.0.rc3
