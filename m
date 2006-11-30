From: "Nordlund Kim (Nokia-NET/Helsinki)" <Kim.Nordlund@nokia.com>
Subject: Re: [PKT_SCHED] act_gact: division by zero
Date: Thu, 30 Nov 2006 15:51:04 +0200 (EET)
Message-ID: <Pine.LNX.4.44.0611301530590.4036-100000@dhcp09282.ntc.nokia.com>
References: <456ECBC5.3080501@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Nordlund Kim (Nokia-NET/Helsinki)" <Kim.Nordlund@nokia.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-ext04.nokia.com ([131.228.20.96]:15758 "EHLO
	mgw-ext04.nokia.com") by vger.kernel.org with ESMTP id S936321AbWK3Nvd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 08:51:33 -0500
To: ext Patrick McHardy <kaber@trash.net>
In-Reply-To: <456ECBC5.3080501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 30 Nov 2006, ext Patrick McHardy wrote:
> I think it should reject an invalid configuration or handle
> the zero case correctly by not dividing.

You are correct. Not returning -EINVAL, because someone might
want to use the value zero in some future gact_prob algorithm?

Signed-off-by: Kim Nordlund <kim.nordlund@nokia.com>

diff -rub linux-2.6.19-orig/net/sched/act_gact.c linux/net/sched/act_gact.c
--- linux-2.6.19-orig/net/sched/act_gact.c	2006-11-29 23:57:37.000000000 +0200
+++ linux/net/sched/act_gact.c	2006-11-30 15:33:12.000000000 +0200
@@ -48,14 +48,14 @@
 #ifdef CONFIG_GACT_PROB
 static int gact_net_rand(struct tcf_gact *gact)
 {
-	if (net_random() % gact->tcfg_pval)
+	if (!gact->tcfg_pval || net_random() % gact->tcfg_pval)
 		return gact->tcf_action;
 	return gact->tcfg_paction;
 }
 
 static int gact_determ(struct tcf_gact *gact)
 {
-	if (gact->tcf_bstats.packets % gact->tcfg_pval)
+	if (!gact->tcfg_pval || gact->tcf_bstats.packets % gact->tcfg_pval)
 		return gact->tcf_action;
 	return gact->tcfg_paction;
 }

