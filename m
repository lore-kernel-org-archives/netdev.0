From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 9 Mar 2017 15:26:02 -0800
Message-ID: <CA+55aFy5vi3af5VBuG6ZOdTeKNxqGSq64J-EkrjaRhGVKXPy0A@mail.gmail.com>
References: <58C157E6.1010909@iogearbox.net> <alpine.DEB.2.20.1703091547460.3521@nanos>
 <58C19607.6000605@iogearbox.net> <CA+55aFyxM--wyvxXGhBOqdJHcdC_kKvGYpv-C5SpYvRNkbEmGw@mail.gmail.com>
 <CA+55aFyu-LHqMaZBaa7VNamxhUR99F4Xr+nL9esLDUBhotopVg@mail.gmail.com>
 <58C19F67.3040509@iogearbox.net> <58C1C9DC.7070509@iogearbox.net>
 <20170309215547.jmdzznlkzaxwu2pf@pd.tnic> <20170309220732.ufqoqlawktsi2gao@pd.tnic>
 <58C1D305.8090802@iogearbox.net> <20170309224820.5invcnhvr2tl3ges@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Gleixner <tglx@linutronix.de>,
        Kees Cook <keescook@chromium.org>,
        Laura Abbott <labbott@redhat.com>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, "the arch/x86 maintainers" <x86@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Borislav Petkov <bp@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170309224820.5invcnhvr2tl3ges@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 9, 2017 at 2:48 PM, Borislav Petkov <bp@suse.de> wrote:
>
> I guess we could return to doing boot_cpu_has() in __flush_tlb_all()
> then. I mean, the timing-sensitivity argument is meh - killing global
> TLB entries a bit faster doesn't bring me a whole lot when I have to go
> and walk pagetable and reestablish them, which is the real price to pay
> anyway.

So should all of commit ("c109bf95992b x86/cpufeature: Remove
cpu_has_pge") just be reverted (and then marked for stable)?

Or do we have some alternate plan?

This has apparently been going on for a long while (it got merged into
4.7), but presumably it only actually _matters_ if lguest is enabled
and used and we've triggered that lguest_arch_host_init() code.

Maybe it's the lguest games with PGE that need to be removed?

                Linus
