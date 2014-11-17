From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/4] arch: Add lightweight memory barriers fast_rmb() and fast_wmb()
Date: Mon, 17 Nov 2014 12:52:17 -0800
Message-ID: <CA+55aFxZ9dhB074p3OAQLyQ53TuRjVOo33h6OOda1soh-9xxnQ@mail.gmail.com>
References: <20141117171005.22333.96544.stgit@ahduyck-server>
	<20141117171812.22333.90395.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Peter Zijlstra <peterz@infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Ingo Molnar <mingo@kernel.org>,
	Michael Neuling <mikey@neuling.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	nic_swsd@realtek.com, Will Deacon <will.deacon@arm.com>,
	Michael Ellerman <michael@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Martin Schwidefsky <
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141117171812.22333.90395.stgit@ahduyck-server>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 17, 2014 at 9:18 AM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> There are a number of situations where the mandatory barriers rmb() and
> wmb() are used to order memory/memory operations in the device drivers
> and those barriers are much heavier than they actually need to be.

Ugh. I absolutely despise the name.

It's not "fast". It's just limited. It's the same as "smp_*mb()", in
that it works on cacheable memory, but it actually stays around even
for non-SMP builds.

So I think the name is actively misleading.

Naming should be about what it does, not about some kind of PR thing
that confuses people into thinking it's "better".

Maybe "dma_*mb()" would be acceptable, and ends up having the same
naming convention as "smb_*mb()", and explains what it's about.

And yes, in the same spirit, it would probably be good to try to
eventually get rid of the plain "*mb()" functions, and perhaps call
them "mmio_*mb()" to clarify that they are about ordering memory wrt
mmio.

Hmm?

                        Linus
