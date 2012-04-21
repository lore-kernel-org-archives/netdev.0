From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Subject: net_sched: gred: red_calc_qavg() called with current qavg for
 backlog?
Date: Sat, 21 Apr 2012 14:46:31 -0400
Message-ID: <4F930087.7010004@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:35162 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147Ab2DUSqo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 14:46:44 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In net/sched/sch_gred.c:

static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
{
     struct gred_sched *table = qdisc_priv(sch);
...
     for (i = 0; i < MAX_DPs; i++) {
         struct gred_sched_data *q = table->tab[i];
         struct tc_gred_qopt opt;
...
         opt.qave = red_calc_qavg(&q->parms, &q->vars, q->vars.qavg);


I can't tell if red_calc_qavg is intentionally being passed the current 
qavg as the backlog (which effectively causes qavg to only be 
re-calculated if we are idling)?  Or should this be:

         opt.qave = red_calc_qavg(&q->parms,
                                  &q->vars,
                                  gred_backlog(table, q, sch));

Thanks,

David
