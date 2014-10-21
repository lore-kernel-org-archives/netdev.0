From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: Queue with wait-free enqueue, blocking dequeue, splice
Date: Tue, 21 Oct 2014 12:02:38 +0000 (UTC)
Message-ID: <432461084.12697.1413892958910.JavaMail.zimbra@efficios.com>
References: <1311316954.11157.1413631325000.JavaMail.zimbra@efficios.com> <412768308.11171.1413632892841.JavaMail.zimbra@efficios.com> <20141020160237.302aa17c@redhat.com> <285747581.12566.1413849850921.JavaMail.zimbra@efficios.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.efficios.com ([78.47.125.74]:54733 "EHLO mail.efficios.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755181AbaJUMCs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2014 08:02:48 -0400
In-Reply-To: <285747581.12566.1413849850921.JavaMail.zimbra@efficios.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>
> To: "Jesper Dangaard Brouer" <brouer@redhat.com>
> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, netdev@vger.kernel.org, "Jamal Hadi Salim" <jhs@mojatatu.com>
> Sent: Monday, October 20, 2014 8:04:10 PM
> Subject: Re: Queue with wait-free enqueue, blocking dequeue, splice
> 
> ----- Original Message -----
> > From: "Jesper Dangaard Brouer" <brouer@redhat.com>
> > To: "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>
> > Cc: brouer@redhat.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
> > netdev@vger.kernel.org, "Jamal Hadi Salim"
> > <jhs@mojatatu.com>
> > Sent: Monday, October 20, 2014 10:02:37 AM
> > Subject: Re: Queue with wait-free enqueue, blocking dequeue, splice
> > 

[...]

> > 
> > AFAIK your queue implementation is a CAS-based, Wait-Free on enqueue,
> > but Lock-Free on dequeue with the potential for waiting/blocking on
> > a enqueue processes.
> >  I'm not 100% sure, that we want this behavior for the qdisc system.
> 
> It's actually xchg-based (not CAS-based). It is indeed wait-free
> in the strictest sense of the term on enqueue (at least on x86,
> some other arch implement xchg using ll/sc, which is not strictly
> wait-free).
> 
> On dequeue, it can busy-wait for a short while that the enqueue
> completes. Note that in kernel, since we disable preemption during
> enqueue, the dequeue does not have to ever block, just busy-looping
> is OK, since the longest thing that could nest over the enqueue
> is possibly an interrupt and softirq. So yes, I guess the dequeue
> would qualify as lock-free.

Scratch this last part about dequeue lock-freedom: dequeue can
busy-wait endlessly long if an enqueue is, for instance, interrupted
by a dequeue operation that would sit within an interrupt handler.
Dequeue is therefore not "lock-free". It is not even obstruction-free.

This just means that you need to be aware of this if you use dequeue
in an execution context that can interrupt enqueue.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com
