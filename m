From: george anzinger <george@mvista.com>
Subject: Re: System crash in tcp_fragment()
Date: Mon, 20 May 2002 16:01:00 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <acbvnq$9dn$2@main.gmane.org>
References: <200205202125.BAA03545@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, davem@redhat.com, ak@muc.de,
   pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> 
> Hello!
> 
> > Is is possible for the other cpu (or even this one given the
> > ksoftirqd stuff) to remove or alter the skb that
> > tcp_fragment() is processing?
> 
> No.
> > What locks, if any, are needed to prevent this.
> 
> They are already applied.
> 
> Looking at the last lines of the bugzilla thread, I see the answer:
> 
> > - Observation, the BUG_TRAP assertion likely should have done something better
> > than just report the condition, wonder if an earlier panic or other corrective
> > action may have kept the TCP stack moving instead of the oops? Looks lazy to
> > me...
> 
> Well, add BUG() to BIG_TRAP() to oops it earlier. Maybe this will move
> you closer to real problem.

Right. Will do.
> 
> And also your reasoning about smp_processor_id() sounds strange,
> preemption code must reschedule thread preemted in the kernel to the
> same cpu, it is enough to avoid troubles with this.

That (ahem) hack was tried and rejected by the powers that
be.  I admit that is it more work to find the resulting
problems, but the fixes seem to be easy and do not to add to
overhead, at least thus far.
> 
> Alexey

-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
