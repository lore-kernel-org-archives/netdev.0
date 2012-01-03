From: Luigi Rizzo <rizzo@iet.unipi.it>
Subject: Re: [PATCH] sch_qfq: fix overflow in qfq_update_start()
Date: Tue, 3 Jan 2012 17:54:22 +0100
Message-ID: <20120103165422.GA58432@onelab2.iet.unipi.it>
References: <1325519277.2375.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20120103082557.5c5cb962@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from onelab2.iet.unipi.it ([131.114.59.238]:56002 "EHLO
	onelab2.iet.unipi.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138Ab2ACQrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 11:47:02 -0500
Content-Disposition: inline
In-Reply-To: <20120103082557.5c5cb962@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thanks, appreciated.

cheers
luigi

On Tue, Jan 03, 2012 at 08:25:57AM -0800, Stephen Hemminger wrote:
> On Mon, 02 Jan 2012 16:47:57 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > grp->slot_shift is between 22 and 41, so using 32bit wide variables is
> > probably a typo.
> > 
> > This could explain QFQ hangs Dave reported to me, after 2^23 packets ?
> > 
> > (23 = 64 - 41)
> > 
> > Reported-by: Dave Taht <dave.taht@gmail.com>
> > CC: Stephen Hemminger <shemminger@vyatta.com>
> > CC: Dave Taht <dave.taht@gmail.com>
> > ---
> >  net/sched/sch_qfq.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
> > index 1033434..7b03254 100644
> > --- a/net/sched/sch_qfq.c
> > +++ b/net/sched/sch_qfq.c
> > @@ -817,11 +817,11 @@ skip_unblock:
> >  static void qfq_update_start(struct qfq_sched *q, struct qfq_class *cl)
> >  {
> >  	unsigned long mask;
> > -	uint32_t limit, roundedF;
> > +	u64 limit, roundedF;
> >  	int slot_shift = cl->grp->slot_shift;
> >  
> >  	roundedF = qfq_round_down(cl->F, slot_shift);
> > -	limit = qfq_round_down(q->V, slot_shift) + (1UL << slot_shift);
> > +	limit = qfq_round_down(q->V, slot_shift) + (1ULL << slot_shift);
> >  
> >  	if (!qfq_gt(cl->F, q->V) || qfq_gt(roundedF, limit)) {
> >  		/* timestamp was stale */
> > 
> > 
> 
> 
> You need to copy the BSD developers on these patches since
> most of the code came from them and FreeBSD probably still has same bug!
