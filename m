From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2]: pkt_sched: Convert qdisc_watchdog to
	tasklet_hrtimer
Date: Thu, 27 Aug 2009 08:36:41 +0000
Message-ID: <20090827083640.GA11152@ff.dom.local>
References: <20090821.170330.217935645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tglx@linutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:55843 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbZH0Igp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 04:36:45 -0400
Received: by bwz19 with SMTP id 19so806314bwz.37
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2009 01:36:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090821.170330.217935645.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22-08-2009 02:03, David Miller wrote:
> None of this stuff should execute in hw IRQ context, therefore
> use a tasklet_hrtimer so that it runs in softirq context.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
...
>  void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
>  {
> -	hrtimer_cancel(&wd->timer);
> +	tasklet_hrtimer_cancel(&wd->timer);
>  	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
>  }
>  EXPORT_SYMBOL(qdisc_watchdog_cancel);

I've had a second look at it and I wonder why it's not reported, but
since qdisc_watchdog_cancel is run in qdisc_reset with BHs disabled
it seems there should be (at least) a warning triggered in
tasklet_kill on positive in_interrupt test (unless I miss something,
but can't test it now).

Jarek P.
