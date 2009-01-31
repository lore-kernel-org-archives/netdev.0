From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: PROBLEM: in_atomic() misuse all over the place
Date: Fri, 30 Jan 2009 16:03:16 -0800
Message-ID: <20090130160316.7e53ef99.akpm@linux-foundation.org>
References: <200901280010.37633.roger.larsson@e-gatan.se>
	<87pri7k4id.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roger.larsson@e-gatan.se, linux-kernel@vger.kernel.org,
	mingo@elte.hu, rml@tech9.net, pavel@ucw.cz, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757290AbZAaAEK@vger.kernel.org>
In-Reply-To: <87pri7k4id.fsf@basil.nowhere.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Jan 2009 13:18:50 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> > file:  include/net/sock.h
> >
> >    static inline gfp_t gfp_any(void)
> >    {
> >      return in_atomic() ? GFP_ATOMIC : GFP_KERNEL;
> >    }
> 
> That's typically for softirq vs non softirq, which is important
> for the network stack.
> 

There's a bit of a problem here.  If someone accidentally uses
gfp_any() inside a spinlock, it will do a sleeping allocation on
non-preempt kernels and will do an atomic allocation on preemptible
kernels, so we won't get to see the warning which would allow us to fix
the bug.

Would using irq_count() work?  If so, that would fix this up.
