From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/4] arch: Add lightweight memory barriers fast_rmb() and
 fast_wmb()
Date: Tue, 18 Nov 2014 16:48:27 +0000
Message-ID: <20141118164827.GR18842@arm.com>
References: <20141117171005.22333.96544.stgit@ahduyck-server>
 <20141117171812.22333.90395.stgit@ahduyck-server>
 <1416254687.18381.3.camel@kernel.crashing.org>
 <546A5968.1090201@gmail.com>
 <1416271167.18381.16.camel@kernel.crashing.org>
 <546AB959.1020602@redhat.com>
 <20141118115836.GL18842@arm.com>
 <546B71DE.4050506@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mathieu.desnoyers@polymtl.ca" <mathieu.desnoyers@polymtl.ca>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
	"mingo@kernel.org" <mingo@kernel.org>,
	"mikey@neuling.org" <mikey@neuling.org>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"matthew.vick@intel.com" <matthew.vick@intel.com>,
	"geert@linux-m68k.org" <geert@linux-m68k.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vn
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <546B71DE.4050506@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 18, 2014 at 04:20:46PM +0000, Alexander Duyck wrote:
> On 11/18/2014 03:58 AM, Will Deacon wrote:
> > So actually, this is an interesting case where the barrier would like to
> > know whether the memory returned by dma_alloc_coherent is h/w coherent
> > (normal, cacheable) or s/w coherent (normal, non-cacheable). I think Ben
> > is thinking of the h/w coherent case (i.e. actual snooping into the CPU
> > caches by the DMA master).
> >
> > For the former, we could use inner-shareable barriers. For the latter, we'd
> > need to use outer-shareable barriers.
> >
> > If we can't tell, then these should be dmb(osh), which will work for both.
> >
> 
> Okay, so I will update the ARM portion of my patches to use osh and 
> oshst then since it sounds like I was using too strong of barriers.

Sounds good. Another reason this is interesting is because the native
acquire/release instructions on ARMv8 actually take into account the
shareability domain of the virtual address, so using them would give you
the shareability domain you want but slightly stronger ordering guarantees
within that domain.

Still, either of them will be a damn sight better than the dsb we currently
have courtesy of the mandatory barriers.

Will
