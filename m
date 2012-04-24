From: Thomas Graf <tgraf@infradead.org>
Subject: Re: net_sched: gred: red_calc_qavg() called with current qavg for
 backlog?
Date: Tue, 24 Apr 2012 08:37:30 -0400
Message-ID: <20120424123730.GI27640@canuck.infradead.org>
References: <4F930087.7010004@ll.mit.edu>
 <20120421.161032.2225288178918492428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: david.ward@ll.mit.edu, tgraf@suug.ch, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:54812 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700Ab2DXMhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 08:37:34 -0400
Content-Disposition: inline
In-Reply-To: <20120421.161032.2225288178918492428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 21, 2012 at 04:10:32PM -0400, David Miller wrote:
> From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
> Date: Sat, 21 Apr 2012 14:46:31 -0400
> 
> > In net/sched/sch_gred.c:
> > 
> > static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
> > {
> >      struct gred_sched *table = qdisc_priv(sch);
> > ...
> >      for (i = 0; i < MAX_DPs; i++) {
> >          struct gred_sched_data *q = table->tab[i];
> >          struct tc_gred_qopt opt;
> > ...
> >          opt.qave = red_calc_qavg(&q->parms, &q->vars, q->vars.qavg);
> > 
> > 
> > I can't tell if red_calc_qavg is intentionally being passed the current 
> > qavg as the backlog (which effectively causes qavg to only be 
> > re-calculated if we are idling)?  Or should this be:
> > 
> >          opt.qave = red_calc_qavg(&q->parms,
> >                                   &q->vars,
> >                                   gred_backlog(table, q, sch));
> 
> Looking at commit 22b33429ab93155895854e9518a253680a920493
> ("[PKT_SCHED]: GRED: Use new generic red interface") it appears
> that this line is intentional so that the dump reports the same
> qave as it would have before Thomas's changes.

When doing the convert, I simply preserved behaviour. I am not sure on
what basis the original behaviour has been written.
