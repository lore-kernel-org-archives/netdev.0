From: Thomas Gleixner <tglx@linutronix.de>
Subject: RE: [PATCH] ARCH: Fix 32-bit x86 MSI-X allocation leakage
Date: Mon, 28 Apr 2008 23:16:00 +0200 (CEST)
Message-ID: <alpine.LFD.1.10.0804282313040.3261@apollo.tec.linutronix.de>
References: <20080426005850.7098.77479.stgit@scrappy.jf.intel.com> <alpine.LFD.1.10.0804282216570.3261@apollo.tec.linutronix.de> <D5C1322C3E673F459512FB59E0DDC32904F9EC8C@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:60023 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935658AbYD1VQl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 17:16:41 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32904F9EC8C@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Apr 2008, Waskiewicz Jr, Peter P wrote:
> > On Fri, 25 Apr 2008, PJ Waskiewicz wrote:
> > > This bug was introduced in the 2.6.24 i386/x86_64 tree merge, where
> > 
> > Can you please explain what exactly caused the bug. 
> > Definitely not the move from arch/i386 to arch/x86 as the 
> > code there was not changed at all and has not be changed since then.
> > 
> > CC'ed Eric as well.
> 
> Eric replied with the actual commit during the 2.6.24 merge window that
> introduced this bug.  The io_apic.c code from the i386 tree did not stay
> completely static when it was merged into the x86 io_apic_32.c code.
> Here is the commit that Eric identified that introduced the defect:
> 
> In particular commit dbeb2be21d678c49a8d8bbf774903df15dd55474
> Author: Rusty Russell <rusty@rustcorp.com.au>
> Date:   Fri Oct 19 20:35:03 2007 +0200
> 
>     i386: introduce "used_vectors" bitmap which can be used to reserve
> vectors.
>     
>     This simplifies the io_apic.c __assign_irq_vector() logic and
> removes
>     the explicit SYSCALL_VECTOR check, and also allows for vectors to be
>     reserved by other mechanisms (ie. lguest).
>     
>     [ tglx: arch/x86 adaptation ]
>     
>     Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>     Signed-off-by: Andi Kleen <ak@suse.de>
>     Signed-off-by: Ingo Molnar <mingo@elte.hu>
>     Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> 
> Basically the code introduced the test_and_set_bit() on the used_vectors
> bitmap, but it didn't have a corresponding clear_bit() on IRQ
> destruction.

Ok, that makes sense. I just did not get the context out of your
commit log. Adding the commit which caused the trouble to the commit
log makes it easier to understand. So the problem is unrelated to the
merger, it's caused by a patch which was pending against the i386 tree
around the time of the merger and which was converted to the merge
tree.

Thanks,
	tglx

