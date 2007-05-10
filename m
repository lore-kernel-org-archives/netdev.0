From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Thu, 10 May 2007 10:42:59 +0530
Message-ID: <OFF9085DDC.F5960247-ON652572D7.001B794E-652572D7.001CA7E2@in.ibm.com>
References: <1178725965.4058.75.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:41188 "EHLO
	ausmtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757187AbXEJFNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 01:13:53 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4A5FKhk8474628
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 15:15:20 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4A5HFGo031232
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 15:17:17 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4A5Dfnn023306
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 15:13:42 +1000
In-Reply-To: <1178725965.4058.75.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal,

J Hadi Salim <j.hadi123@gmail.com> wrote on 05/09/2007 09:22:44 PM:

> > Since I am holding a lock in these two changed areas till I return
> > back to __qdisc_run (which clears the RUNNING bit) and then drop the
> > lock, there is no way packets can be on the queue while I falsely
> > return 0, or no packets on the queue while I falsely return -1.
>
> If you relinquish yourself from being a dequeuer by letting go of
> RUNNING then it is possible during that short window one of the other
> N-1 CPUs could have been enqueueing; that packet will never be dequeued
> unless a new packet shows up some X amount of time later.

But RUNNING is never relinquished till all the way back out to
__qdisc_run. Only the lock is dropped before calling xmit and
re-got after xmit is finished (all the while holding RUNNING).
After xmit both queue_lock and RUNNING are held. If some other
cpu enqueue'd during this release window (and they would have
returned after dropping the lock as they are pure enqueuer's),
qdisc_restart will find those skbs. Similarly if no skbs were
added, qdisc_restart will return 0.

Thanks,

- KK

> I hope what i described above helps. Off for about a day. CCing Herbert
> who last made changes to that area incase i missed something ..
>
> cheers,
> jamal
>
> PS:- Please dont use my temporary gmail account to respond; a reply-to
> will pick the right address (@cyberus.ca).
>

