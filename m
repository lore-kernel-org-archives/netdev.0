From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Fri, 12 Feb 2016 18:10:37 +0100
Message-ID: <20160212171037.GV6357@twins.programming.kicks-ass.net>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <56BDB5A8.9030006@suse.cz>
 <20160212144543.GA29004@treble.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jslaby@suse.cz>, Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	linux-kernel@vger.kernel.org, live-patching@vger.kernel.org,
	Michal Marek <mmarek@suse.cz>,
	Andy Lutomirski <luto@kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Pedro Alves <palves@redhat.com>,
	Namhyung Kim <namhyung@gmail.com>,
	Bernd Petrovitsch <bernd@petrovitsch.priv.at>,
	Chris J Arges <chris.j.arges@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Borislav Petkov <bp@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Chris Wright <chrisw@sous-sol.org>,
To: Josh Poimboeuf <jpoimboe@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160212144543.GA29004@treble.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 12, 2016 at 08:45:43AM -0600, Josh Poimboeuf wrote:
> On Fri, Feb 12, 2016 at 11:36:24AM +0100, Jiri Slaby wrote:
> 
> This seems like a real frame pointer bug caused by the following line in
> arch/x86/include/asm/preempt.h:
> 
>   # define __preempt_schedule() asm ("call ___preempt_schedule")

The purpose there is that:

	preempt_enable();

turns into:

	decl	__percpu_prefix:__preempt_count
	jnz	1f:
	call	___preempt_schedule
1:

See arch/x86/include/asm/preempt.h:__preempt_count_dec_and_test()
