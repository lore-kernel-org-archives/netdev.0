From: Andi Kleen <andi@firstfloor.org>
Subject: Re: PROBLEM: in_atomic() misuse all over the place
Date: Wed, 28 Jan 2009 13:18:50 +0100
Message-ID: <87pri7k4id.fsf@basil.nowhere.org>
References: <200901280010.37633.roger.larsson@e-gatan.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Robert Love <rml@tech9.net>, Pavel Machek <pavel@ucw.cz>,
	netdev@vger.kernel.org
To: Roger Larsson <roger.larsson@e-gatan.se>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753722AbZA1MT0@vger.kernel.org>
In-Reply-To: <200901280010.37633.roger.larsson@e-gatan.se> (Roger Larsson's message of "Wed, 28 Jan 2009 00:10:37 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roger Larsson <roger.larsson@e-gatan.se> writes:

[cc netdev since network code is discussed]

> [2.] Full description of the problem/report:
>
> The problem is that in_atomic() only works on preemptive kernels...

That's not fully correct. It works in tasklets/softirqs/spin_lock_bh
on all kernels.

> file:  include/net/sock.h
>
>    static inline gfp_t gfp_any(void)
>    {
>      return in_atomic() ? GFP_ATOMIC : GFP_KERNEL;
>    }

That's typically for softirq vs non softirq, which is important
for the network stack.

That said its undoubtedly possible that some users get
it wrong and assume it applies to spinlocks (without _bh) too. 
But at least the classical uses in the network stack should be ok.

I personally would consider anyone using it inside a normal
spinlock dubious anyways, because GFP_ATOMIC is the wrong
thing to use here. The correct way is to either switch to a mutex/sem
or move the allocation outside the lock.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
