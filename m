From: george anzinger <george@mvista.com>
Subject: Re: System crash in tcp_fragment()
Date: Mon, 20 May 2002 23:08:38 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <accodj$9ag$2@main.gmane.org>
References: <Pine.LNX.4.33.0205201836160.9301-100000@w-nivedita2.des.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru, ak@suse.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:
> 
> On Mon, 20 May 2002, David S. Miller wrote:
> 
> > Such rule does not even make this piece of code legal.  Consider:
> >
> > task1:cpu0:   x = counters[smp_processor_id()];
> >       cpu0:   PREEMPT
> > task2:cpu0:   x = counters[smp_processor_id()];
> > task2:cpu0:   counters[smp_processor_id()] = x + 1;
> >       cpu0:   PREEMPT
> > task1:cpu0:   counters[smp_processor_id()] = x + 1;
> >               full garbage
> >
> > But it does bring up important point, preemption people need to
> > fully audit entire networking.
> >
> > It is totally broken by preemption the more I think about it.
> >
> > At the very beginning, all the SNMP counter bumping tricks will
> > totally fail with preemption enabled.

May be someone could tell me if these matter.  If you are
bumping a counter and you switch cpus in the middle, a.)
does it matter? and b.) if so which cpu should get the
count?  I sort of thought that, if this were going on, it
did not really matter as long as some counter was bumped.
> >
> 
> A lot of the synchronization between process context and interrupt
> context is based on per-cpu data structures or simple locks
> (without disabling irq's globally) eg:
> 
> softnet_data queue (we only disable local interrupts), and
> synchronization between tcp_readmsg() and tcp_rcv() over
> the receive queue would get confused (lock.users flag would
> be different on another CPU)..

Disabling local interrupts also disables preemption, as does
interrupt context.
> 
> Wonder how any of it could possibly work..

It seems to take a LOT of work to break it.  Even then, I
think this problem at hand is in the driver (a new one from
the intel folks).

-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
