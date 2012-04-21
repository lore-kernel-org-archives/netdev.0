From: David Miller <davem@davemloft.net>
Subject: Re: net_sched: gred: red_calc_qavg() called with current qavg for
 backlog?
Date: Sat, 21 Apr 2012 16:10:32 -0400 (EDT)
Message-ID: <20120421.161032.2225288178918492428.davem@davemloft.net>
References: <4F930087.7010004@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911Ab2DUULv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 16:11:51 -0400
In-Reply-To: <4F930087.7010004@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Date: Sat, 21 Apr 2012 14:46:31 -0400

> In net/sched/sch_gred.c:
> 
> static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
> {
>      struct gred_sched *table = qdisc_priv(sch);
> ...
>      for (i = 0; i < MAX_DPs; i++) {
>          struct gred_sched_data *q = table->tab[i];
>          struct tc_gred_qopt opt;
> ...
>          opt.qave = red_calc_qavg(&q->parms, &q->vars, q->vars.qavg);
> 
> 
> I can't tell if red_calc_qavg is intentionally being passed the current 
> qavg as the backlog (which effectively causes qavg to only be 
> re-calculated if we are idling)?  Or should this be:
> 
>          opt.qave = red_calc_qavg(&q->parms,
>                                   &q->vars,
>                                   gred_backlog(table, q, sch));

Looking at commit 22b33429ab93155895854e9518a253680a920493
("[PKT_SCHED]: GRED: Use new generic red interface") it appears
that this line is intentional so that the dump reports the same
qave as it would have before Thomas's changes.

Thomas?
