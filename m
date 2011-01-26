From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [patch] kconfig: unify GENERIC_ISA_DMA and ISA_DMA_API
Date: Wed, 26 Jan 2011 20:10:00 +0000
Message-ID: <20110126201000.GB7323@n2100.arm.linux.org.uk>
References: <alpine.DEB.2.00.1101251706040.9641@chino.kir.corp.google.com> <20110126112908.GD2562@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1101261158490.13163@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Kyle McMartin <kyle@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Randy Dunlap <randy.dunlap@oracle.com>, x86@kernel.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1101261158490.13163@chino.kir.corp.google.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 26, 2011 at 12:00:08PM -0800, David Rientjes wrote:
> On Wed, 26 Jan 2011, Russell King - ARM Linux wrote:
> 
> > On Tue, Jan 25, 2011 at 05:06:28PM -0800, David Rientjes wrote:
> > > CONFIG_GENERIC_ISA_DMA and CONFIG_ISA_DMA_API usually have dependencies
> > > on one another depending on the architecture and generic kernel code uses
> > > either to determine whether an ISA-style DMA API is configured.
> > 
> > Wrong.
> > 
> > GENERIC_ISA_DMA enables support for the standard ISA DMA allocator found
> > in kernel/dma.c
> > 
> > ISA_DMA_API says that a platform supports the ISA DMA interfaces.
> > 
> > An architecture can provide the ISA DMA interfaces, but not use the
> > standard ISA DMA allocator found in kernel/dma.c.  Such as the one in
> > arch/arm/kernel/dma.c.
> > 
> > So on ARM, we have platforms where ISA_DMA_API=y but GENERIC_ISA_DMA=n.
> > 
> 
> Ok, fair enough.  Thanks for pointing that out.  I'll work to resolve the 
> existing dependency chain on x86 that cause build failures when one is 
> disabled and another is not and add Kconfig dependencies on drivers that 
> require GENERIC_ISA_DMA.

Drivers should depend on ISA_DMA_API as that indicates that the ISA DMA
API is present - in other words, when the following are available from
an architecture/platform:

dma_spin_lock
claim_dma_lock
release_dma_lock
enable_dma
disable_dma
clear_dma_ff
set_dma_mode
set_dma_page
set_dma_addr
set_dma_count
get_dma_residue
request_dma
free_dma

GENERIC_ISA_DMA should be set by an architecture/platform when ISA_DMA_API
has already been set -and- it wants to use kernel/dma.c.  No drivers should
depend on GENERIC_ISA_DMA.
