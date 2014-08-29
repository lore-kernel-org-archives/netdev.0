From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 5/5] sched: replace bare printks
Date: Fri, 29 Aug 2014 00:09:23 -0700
Message-ID: <20140829071035.547171617@networkplumber.org>
References: <20140829070918.508987897@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:47980 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbaH2HKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 03:10:37 -0400
Received: by mail-pa0-f54.google.com with SMTP id fb1so5820836pad.41
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 00:10:37 -0700 (PDT)
Content-Disposition: inline; filename=act-msg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't use bare printk for error messages.
Make GRED error an info level message rather than debug which
is likely to be suppressed.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/sched/act_ipt.c	2014-03-28 11:40:43.000000000 -0700
+++ b/net/sched/act_ipt.c	2014-08-22 16:53:33.676030680 -0700
@@ -290,10 +290,10 @@ static int __init ipt_init_module(void)
 
 	ret1 = tcf_register_action(&act_xt_ops, IPT_TAB_MASK);
 	if (ret1 < 0)
-		printk("Failed to load xt action\n");
+		pr_err("Failed to load xt action\n");
 	ret2 = tcf_register_action(&act_ipt_ops, IPT_TAB_MASK);
 	if (ret2 < 0)
-		printk("Failed to load ipt action\n");
+		pr_err("Failed to load ipt action\n");
 
 	if (ret1 < 0 && ret2 < 0) {
 		return ret1;
--- a/net/sched/act_mirred.c	2014-08-12 13:07:42.000000000 -0700
+++ b/net/sched/act_mirred.c	2014-08-22 16:54:07.244031579 -0700
@@ -140,7 +140,7 @@ static int tcf_mirred(struct sk_buff *sk
 
 	dev = m->tcfm_dev;
 	if (!dev) {
-		printk_once(KERN_NOTICE "tc mirred: target device is gone\n");
+		netdev_notice(dev, "tc mirred: target device is gone\n");
 		goto out;
 	}
 
--- a/net/sched/sch_gred.c	2014-03-28 11:40:43.000000000 -0700
+++ b/net/sched/sch_gred.c	2014-08-22 16:54:47.720032663 -0700
@@ -456,8 +456,8 @@ static int gred_change(struct Qdisc *sch
 			if (table->tab[table->def])
 				def_prio = table->tab[table->def]->prio;
 
-			printk(KERN_DEBUG "GRED: DP %u does not have a prio "
-			       "setting default to %d\n", ctl->DP, def_prio);
+			pr_info("GRED: DP %u does not have a prio "
+				"setting default to %d\n", ctl->DP, def_prio);
 
 			prio = def_prio;
 		} else
