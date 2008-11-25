From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1b/2] tc: check for errors in gen_rate_estimator
 creation
Date: Tue, 25 Nov 2008 11:14:23 -0800
Message-ID: <20081125111423.0b953570@extreme>
References: <20081125101656.52348bdd@extreme>
	<492C43DF.1040703@trash.net>
	<20081125105850.7aa30a3d@extreme>
	<492C4C8A.9000202@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49920 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752110AbYKYTO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 14:14:26 -0500
In-Reply-To: <492C4C8A.9000202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Nov 2008 20:05:46 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > The functions gen_new_estimator and gen_replace_estimator can return errors,
> > but they were being ignored.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > 
> > ---
> > --- a/net/sched/sch_api.c	2008-11-25 10:51:47.000000000 -0800
> > +++ b/net/sched/sch_api.c	2008-11-25 10:54:16.000000000 -0800
> > @@ -887,6 +887,14 @@ static int qdisc_change(struct Qdisc *sc
> >  			return err;
> >  	}
> >  
> > +	if (tca[TCA_RATE]) {
> > +		err = gen_replace_estimator(&sch->bstats, &sch->rate_est,
> > +					    qdisc_root_sleeping_lock(sch),
> > +					    tca[TCA_RATE]);
> > +		if (err)
> > +			return err;
> 
> This appears to have the same problem as in HFSC unless I missed more
> code movement - changes to the qdisc have already been performed.

That is not fixable since both change and replace_estimator are non-unwindable,
and either one could fail. Could split checking and initialization out of gen_new_estimator,
but is it worth it??
