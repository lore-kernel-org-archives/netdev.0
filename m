From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2]: pkt_sched: Convert qdisc_watchdog to
 tasklet_hrtimer
Date: Tue, 01 Sep 2009 15:49:10 -0700 (PDT)
Message-ID: <20090901.154910.199945922.davem@davemloft.net>
References: <20090821.170330.217935645.davem@davemloft.net>
	<20090827083640.GA11152@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50348
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755308AbZIAWsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 18:48:55 -0400
In-Reply-To: <20090827083640.GA11152@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 27 Aug 2009 08:36:41 +0000

> On 22-08-2009 02:03, David Miller wrote:
>> None of this stuff should execute in hw IRQ context, therefore
>> use a tasklet_hrtimer so that it runs in softirq context.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
> ...
>>  void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
>>  {
>> -	hrtimer_cancel(&wd->timer);
>> +	tasklet_hrtimer_cancel(&wd->timer);
>>  	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
>>  }
>>  EXPORT_SYMBOL(qdisc_watchdog_cancel);
> 
> I've had a second look at it and I wonder why it's not reported, but
> since qdisc_watchdog_cancel is run in qdisc_reset with BHs disabled
> it seems there should be (at least) a warning triggered in
> tasklet_kill on positive in_interrupt test (unless I miss something,
> but can't test it now).

There are a lot of unknowns about this stuff.

It's very likely I'm going to simply revert these two patches
and try to work on these issues in net-next-2.6 instead.
