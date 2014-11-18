From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v4 0/4] Add lightweight memory barriers for coherent
 memory access
Date: Tue, 18 Nov 2014 15:06:49 -0800
Message-ID: <CA+55aFwHUQv+zBxyN41Y4MDyRXbQ84H8zc01O6O_eg9ZvoqYiQ@mail.gmail.com>
References: <20141118172644.26303.37688.stgit@ahduyck-server>
	<CA+55aFw3ygP8UEF1vidWdjBUEkqXOELCPkpjLMD-X=vXXQEGOQ@mail.gmail.com>
	<546BCC73.3050903@redhat.com>
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
In-Reply-To: <546BCC73.3050903@redhat.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 18, 2014 at 2:47 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
>
> The problem is DMA is a broad brush.  There are multiple cases I can think
> of where DMA does not represent coherent memory.

.. and I already addressed that, in the thing you even included:

>> about what is actually the important issue. All sane memory is
>> coherent, after all (and if it isn't, you have other issues than
>> memory ordering).

The thing is, if the DMA isn't coherent, nobody is going to care about
the memory barriers anyway. You have bigger issues.

And your argument is that "dma" is bigger than this issue. *MY*
argument is that "coherent" is bigger than this issue. There's tons of
coherent memory that is not about DMA, the same way that there is DMA
memory that isn't coherent.

See? The two are 100% equivalent. Except "dma" is just three letters,
and matches "smp" both visually and in use (SMP memory is "coherent"
too - yes, you can - and crap architectures do - have incoherent
caches due to virtual aliases etc, but exactly as with DMA, if you
have incoherent SMP, you have bigger issues than the barriers).

And yes, you could call it "coherent_dma_read_memory_barrier()", and
it would be very descriptive. It would also drive everybody crazy.

So I argue for "dma_mb()" pairing with "smp_mb()" from a naming
standpoint. It just *describes* the problem better. Look at the
drivers, it's very much about the devices doing DMA to memory, and our
ordering.

To be even more clear: nobody sane cares about the "coherent" part,
because only insane horrible crap architectures have incoherent memory
in the first place, and sane people run away screaming from that
steaming pile of sh*t.

Just look at some of the drivers you actually *use* this in. They are
for intel hardware, they presumably would never even work in the first
place without cache-coherent DMA. Why do you think that "coherent" is
so important?

                       Linus
