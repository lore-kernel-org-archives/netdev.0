From: Andi Kleen <ak@suse.de>
Subject: Re: Zero copy transmit
Date: Wed, 30 Apr 2003 17:29:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030430152922.GD18661@oldwotan.suse.de>
References: <3EAEC7FF.4040504@sgi.com> <20030429192041.GC17413@Wotan.suse.de> <3EAED567.2090006@sgi.com> <20030429195924.GC349@Wotan.suse.de> <3EAEDBE9.1060405@sgi.com> <20030429203945.GD349@Wotan.suse.de> <20030430150533.GA8158@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com, modica@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robin Holt <holt@sgi.com>
Content-Disposition: inline
In-Reply-To: <20030430150533.GA8158@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Last time I checked, the IA64 processor provides a ptc.g instruction for
> exactly this.  The only hit we take from using it is Intel limits it to
> a single outstanding ptc.g pending machine wide.  This is accomplished with
> a global spinlock.  I would love to convince Intel to change this instruction,
> but that probably will not happen any time soon.

IA64 Linux doesn't use it at least. The 2.5 flush_tlb_mm calls smp_flush_tlb_mm
which ends up doing IPIs. Same for flush_tlb_page - calls flush_tlb_range
which calls sn2_global_tlb_purge, which does something complicated
that also looks like an global IPI. It also takes a global spinlock.

> 
> I will concede that the ptc.g instruction takes a considerable period of
> time on our 64 processor machines, but that comes out to a lot of local
> TLB coherence domains that need to be updated.
> 
> I believe there is a similar instruction for x86.  Could someone verify
> this?

Nope. x86 has to IPI for remote TLB flushes.

-Andi
> 
