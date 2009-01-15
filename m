From: Chris Caputo <ccaputo@alt.net>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 07:26:28 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.0901150724000.20461@nacho.alt.net>
References: <20081010090426.GA6054@ff.dom.local>
	<Pine.LNX.4.64.0901110438050.16453@nacho.alt.net>
	<20090114063909.GA4234@ff.dom.local>
	<200901141417.58667.denys@visp.net.lb>
	<1231937404.14825.4.camel@laptop>
	<Pine.LNX.4.64.0901141748300.17915@nacho.alt.net>
	<20090115065322.GA4190@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Thomas Gleixner <tglx@linutronix.de>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nacho.alt.net ([208.90.169.18]:39944 "EHLO nacho.alt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756336AbZAOHdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 02:33:47 -0500
In-Reply-To: <20090115065322.GA4190@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jan 2009, Jarek Poplawski wrote:
> On Wed, Jan 14, 2009 at 06:02:04PM +0000, Chris Caputo wrote:
> ...
> > That said, I would not recommend just the three for -stable unless they 
> > get a much wider amount of testing, on multiple platforms.  I don't see 
> > that as likely to happen, plus Peter says they are incomplete, so maybe it 
> > is just best to recommend that 2.6.28 users getting crashes while using 
> > HTB try these specific patches at first, and then the rest of the patches 
> > if they do not work.
> 
> The main problem is my patches, at least the tested ones, harm htb's
> exactness, and I doubt I could convince anybody to merege them, at
> least before your case. It was only reported by two users here (plus
> one more on private), and looked like something very rare. After your
> report it looks much more necessary.
> 
> If there is nothing better, I can recommend it, but IMHO the best
> candidate for this is the testing patch #4 from this thread, which
> alas wasn't even tested... So, Chris, if you could give it a try in
> the meantime (without any other patches)?
> 
> Thanks,
> Jarek P.
> 
> (resend testing patch #4 - for 2.6.27 or 2.6.28)
> ---
> 
> diff -Nurp a2.6.27.7/net/sched/sch_htb.c b2.6.27.7/net/sched/sch_htb.c
> --- a2.6.27.7/net/sched/sch_htb.c	2008-12-11 08:16:16.000000000 +0000
> +++ b2.6.27.7/net/sched/sch_htb.c	2008-12-15 10:44:32.000000000 +0000
> @@ -924,6 +924,7 @@ static struct sk_buff *htb_dequeue(struc
>  		}
>  	}
>  	sch->qstats.overlimits++;
> +	qdisc_watchdog_cancel(&q->watchdog);
>  	qdisc_watchdog_schedule(&q->watchdog, next_event);
>  fin:
>  	return skb;

I hope you can forgive me, but since I have something that works on a 
production machine, I am not in a position in which I can test this.

Chris
