From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v4 0/4] Add lightweight memory barriers for coherent
 memory access
Date: Tue, 18 Nov 2014 12:53:34 -0800
Message-ID: <CA+55aFw3ygP8UEF1vidWdjBUEkqXOELCPkpjLMD-X=vXXQEGOQ@mail.gmail.com>
References: <20141118172644.26303.37688.stgit@ahduyck-server>
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
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20141118172644.26303.37688.stgit@ahduyck-server>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 18, 2014 at 9:28 AM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> These patches introduce two new primitives for synchronizing cache coherent
> memory writes and reads.  These two new primitives are:
>
>         coherent_rmb()
>         coherent_wmb()

So I'm still not convinced about the name. I don't hate it, but if you
ever want to do "read_acquire", then that whole "coherent_" thing does
make for a big mouthful. I don't see why "dma" isn't simpler and more
to the point, and has the advantage of lining up (in documentation
etc) with "smp".

Why would you ever use "coherent_xyz()" on something that isn't about
dma? If it's cache-coherent memory without DMA, you'd use "smp_xyz()",
so I really do prefer that whole "dma-vs-smp" issue, because it talks
about what is actually the important issue. All sane memory is
coherent, after all (and if it isn't, you have other issues than
memory ordering).

                  Linus
