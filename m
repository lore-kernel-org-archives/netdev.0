From: Borislav Petkov <bp@suse.de>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 9 Mar 2017 23:48:20 +0100
Message-ID: <20170309224820.5invcnhvr2tl3ges@pd.tnic>
References: <58C157E6.1010909@iogearbox.net>
 <alpine.DEB.2.20.1703091547460.3521@nanos>
 <58C19607.6000605@iogearbox.net>
 <CA+55aFyxM--wyvxXGhBOqdJHcdC_kKvGYpv-C5SpYvRNkbEmGw@mail.gmail.com>
 <CA+55aFyu-LHqMaZBaa7VNamxhUR99F4Xr+nL9esLDUBhotopVg@mail.gmail.com>
 <58C19F67.3040509@iogearbox.net>
 <58C1C9DC.7070509@iogearbox.net>
 <20170309215547.jmdzznlkzaxwu2pf@pd.tnic>
 <20170309220732.ufqoqlawktsi2gao@pd.tnic>
 <58C1D305.8090802@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Kees Cook <keescook@chromium.org>,
        Laura Abbott <labbott@redhat.com>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, the arch/x86 maintainers <x86@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <58C1D305.8090802@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 09, 2017 at 11:11:17PM +0100, Daniel Borkmann wrote:
> Yeah, I just tried that out and it had no effect unfortunately, the
> static_cpu_has() was still 1.

Right, just as I thought.

I guess we could return to doing boot_cpu_has() in __flush_tlb_all()
then. I mean, the timing-sensitivity argument is meh - killing global
TLB entries a bit faster doesn't bring me a whole lot when I have to go
and walk pagetable and reestablish them, which is the real price to pay
anyway.

Thanks.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix Imendörffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nürnberg)
-- 
