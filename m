From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Tue, 7 Jul 2009 15:45:33 -0400
Message-ID: <20090707194533.GB13858@Krystal>
References: <20090703095659.GA4518@jolsa.lab.eng.brq.redhat.com> <20090703102530.GD32128@elte.hu> <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com> <20090707101816.GA6619@jolsa.lab.eng.brq.redhat.com> <20090707134601.GB6619@jolsa.lab.eng.brq.redhat.com> <20090707140135.GA5506@Krystal> <20090707143416.GB11704@redhat.com> <20090707150406.GC7124@Krystal> <20090707154440.GA15605@redhat.com> <1246981815.9777.12.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg@redhat.com>, Jiri Olsa <jolsa@redhat.com>,
	Ingo Molnar <mingo@elte.hu>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	davem@redhat.com, htejun@gmail.com, jarkao2@gmail.com,
	davidel@xmailserver.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts40.bellnexxia.net ([209.226.175.97]:58956 "EHLO
	tomts40-srv.bellnexxia.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754912AbZGGTpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 15:45:51 -0400
Content-Disposition: inline
In-Reply-To: <1246981815.9777.12.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Peter Zijlstra (a.p.zijlstra@chello.nl) wrote:
> On Tue, 2009-07-07 at 17:44 +0200, Oleg Nesterov wrote:
> > On 07/07, Mathieu Desnoyers wrote:
> > >
> > > Actually, thinking about it more, to appropriately support x86, as well
> > > as powerpc, arm and mips, we would need something like:
> > >
> > > read_lock_smp_mb()
> > >
> > > Which would be a read_lock with an included memory barrier.
> > 
> > Then we need read_lock_irq_smp_mb, read_lock_irqsave__smp_mb, write_lock_xxx,
> > otherwise it is not clear why only read_lock() has _smp_mb() version.
> > 
> > The same for spin_lock_xxx...
> 
> At which time the smp_mb__{before,after}_{un,}lock become attractive
> again.
> 

Then having a new __read_lock() (without acquire semantic) which would
be required to be followed by a smp__mb_after_lock() would make sense. I
think this would fit all of x86, powerpc, arm, mips without having to
create tons of new primitives. Only "simpler" ones that clearly separate
locking from memory barriers.

Mathieu




-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
