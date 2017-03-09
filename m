From: Borislav Petkov <bp@suse.de>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 9 Mar 2017 22:55:47 +0100
Message-ID: <20170309215547.jmdzznlkzaxwu2pf@pd.tnic>
References: <CAGXu5jLm3jbJoQAsBsTiiQGK1==JTnSkN_GLsuBGqFvAz5B3AQ@mail.gmail.com>
 <58C152F1.9090004@iogearbox.net>
 <alpine.DEB.2.20.1703091409080.3521@nanos>
 <58C157E6.1010909@iogearbox.net>
 <alpine.DEB.2.20.1703091547460.3521@nanos>
 <58C19607.6000605@iogearbox.net>
 <CA+55aFyxM--wyvxXGhBOqdJHcdC_kKvGYpv-C5SpYvRNkbEmGw@mail.gmail.com>
 <CA+55aFyu-LHqMaZBaa7VNamxhUR99F4Xr+nL9esLDUBhotopVg@mail.gmail.com>
 <58C19F67.3040509@iogearbox.net>
 <58C1C9DC.7070509@iogearbox.net>
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
In-Reply-To: <58C1C9DC.7070509@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 09, 2017 at 10:32:12PM +0100, Daniel Borkmann wrote:
> 	get_online_cpus();
> 	if (boot_cpu_has(X86_FEATURE_PGE)) { /* We have a broader idea of "global". */
> 		/* Remember that this was originally set (for cleanup). */
> 		cpu_had_pge = 1;
> 		/*
> 		 * adjust_pge is a helper function which sets or unsets the PGE
> 		 * bit on its CPU, depending on the argument (0 == unset).
> 		 */
> 		on_each_cpu(adjust_pge, (void *)0, 1);
> 		/* Turn off the feature in the global feature set. */
> 		clear_cpu_cap(&boot_cpu_data, X86_FEATURE_PGE);

Can you make that:

	setup_clear_cpu_cap(X86_FEATURE_PGE);

and see if it fixes your issue?

Thanks.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix Imendörffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nürnberg)
-- 
