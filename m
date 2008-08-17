From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sun, 17 Aug 2008 12:35:46 +0300
Message-ID: <200808171235.46413.denys@visp.net.lb>
References: <20080815190905.M56388@visp.net.lb> <200808171202.13422.denys@visp.net.lb> <20080817093414.GA2907@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:60065 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbYHQJgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 05:36:55 -0400
In-Reply-To: <20080817093414.GA2907@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have applied now 
01-fix-pkt_sched: Fix unloc~ in tc_ctl_tfilter()
02-lockdep.patch (it is adding in sch_api.c lockdep_set_class)
"take 3" patch
and latest patch you sent

Is it correct?

On Sunday 17 August 2008, Jarek Poplawski wrote:
> On Sun, Aug 17, 2008 at 12:02:13PM +0300, Denys Fedoryshchenko wrote:
> > Is it was a fix? Because for now it is running fine from night (but i
> > have enabled some minor debug options in kernel). No crash or warning
> > yet.
> >
> > I disable now debug as it was before and testing more.
>
> Only the patch named "take #3" is debugging only, and the latter 2
> patches were intended to fix things. As a matter of fact the first
> fixing patch should be needed as well, so if it's possible try to add
> it again without reverting anything. It can show some minor offset
> while applying now. I resend it below for any case.
>
> Thanks,
> Jarek P.
>
> ---
>
>  include/net/sch_generic.h |    5 +++++
>  net/sched/sch_api.c       |    2 +-
>  2 files changed, 6 insertions(+), 1 deletions(-)
>
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index a7abfda..4f28fa7 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -193,6 +193,11 @@ static inline struct Qdisc *qdisc_root(struct Qdisc
> *qdisc) return qdisc->dev_queue->qdisc;
>  }
>
> +static inline struct Qdisc *qdisc_root_sleeping(struct Qdisc *qdisc)
> +{
> +	return qdisc->dev_queue->qdisc_sleeping;
> +}
> +
>  /* The qdisc root lock is a mechanism by which to top level
>   * of a qdisc tree can be locked from any qdisc node in the
>   * forest.  This allows changing the configuration of some
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index c25465e..5c7ae56 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -435,7 +435,7 @@ void qdisc_watchdog_init(struct qdisc_watchdog *wd,
> struct Qdisc *qdisc) {
>  	hrtimer_init(&wd->timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
>  	wd->timer.function = qdisc_watchdog;
> -	wd->qdisc = qdisc;
> +	wd->qdisc = qdisc_root_sleeping(qdisc);
>  }
>  EXPORT_SYMBOL(qdisc_watchdog_init);


