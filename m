From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1) instead
 of yield() to wait for outstanding qdisc_run calls
Date: Fri, 7 Mar 2014 16:47:39 +0100
Message-ID: <20140307154739.GA18441@linutronix.de>
References: <1393976987-23555-1-git-send-email-mkl@pengutronix.de>
 <20140306.160622.59358366688518505.davem@davemloft.net>
 <5318EB2E.8040707@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, linux-rt-users@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5318EB2E.8040707@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Marc Kleine-Budde | 2014-03-06 22:39:58 [+0100]:

>> Therefore it should allow lower priority threads to run, not just
>> equal or higher priority ones.
>
>Yes, we need a call that does what you described, however I'm not sure
>if yield() really does that. According to:
>
>http://lxr.free-electrons.com/source/kernel/sched/core.c#L3599
>
>> * Typical broken usage is:
>> *
>> * while (!event)
>> *      yield();
>> *
>> * where one assumes that yield() will let 'the other' process run that will
>> * make event true. If the current task is a SCHED_FIFO task that will never
>> * happen. Never use yield() as a progress guarantee!!
>
>My Process runs with SCHED_FIFO and prio > 50, with IRQ at default prio,
>which is 50.
>
>Maybe the RT guys can comment on this. I found another interesting
>function in the RT patch set: cpu_chill().

If you boot mainline without -RT, use threadirqs, start your application
do the same prio thing then you should end up with exactly the same
outcome. Please say so :)

msleep() is safe as long as it is used outside of the softirq. Nice that
you found cpu_chill() but on non-RT it turns to cpu_relax() and you do
not want this here.

wait_event() would be nice in the end to have. For now I take that patch
for -RT.

>Marc

Sebastian
