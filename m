From: kuznet@ms2.inr.ac.ru
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 01:25:53 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <acbpoe$udd$2@main.gmane.org>
References: <3CE95190.75C52E2D@mvista.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, davem@redhat.com, ak@muc.de,
   pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george@mvista.com (george anzinger)
In-Reply-To: <3CE95190.75C52E2D@mvista.com> from "george anzinger" at May 20, 2 12:42:08 pm
List-Id: netdev.vger.kernel.org

Hello!

> Is is possible for the other cpu (or even this one given the
> ksoftirqd stuff) to remove or alter the skb that
> tcp_fragment() is processing?

No.
> What locks, if any, are needed to prevent this.

They are already applied.


Looking at the last lines of the bugzilla thread, I see the answer:

> - Observation, the BUG_TRAP assertion likely should have done something better
> than just report the condition, wonder if an earlier panic or other corrective
> action may have kept the TCP stack moving instead of the oops? Looks lazy to
> me...

Well, add BUG() to BIG_TRAP() to oops it earlier. Maybe this will move
you closer to real problem.


And also your reasoning about smp_processor_id() sounds strange,
preemption code must reschedule thread preemted in the kernel to the
same cpu, it is enough to avoid troubles with this. 

Alexey
