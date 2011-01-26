From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [patch] kconfig: unify GENERIC_ISA_DMA and ISA_DMA_API
Date: Wed, 26 Jan 2011 11:29:08 +0000
Message-ID: <20110126112908.GD2562@n2100.arm.linux.org.uk>
References: <alpine.DEB.2.00.1101251706040.9641@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Kyle McMartin <kyle@redhat.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
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
In-Reply-To: <alpine.DEB.2.00.1101251706040.9641@chino.kir.corp.google.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 25, 2011 at 05:06:28PM -0800, David Rientjes wrote:
> CONFIG_GENERIC_ISA_DMA and CONFIG_ISA_DMA_API usually have dependencies
> on one another depending on the architecture and generic kernel code uses
> either to determine whether an ISA-style DMA API is configured.

Wrong.

GENERIC_ISA_DMA enables support for the standard ISA DMA allocator found
in kernel/dma.c

ISA_DMA_API says that a platform supports the ISA DMA interfaces.

An architecture can provide the ISA DMA interfaces, but not use the
standard ISA DMA allocator found in kernel/dma.c.  Such as the one in
arch/arm/kernel/dma.c.

So on ARM, we have platforms where ISA_DMA_API=y but GENERIC_ISA_DMA=n.

> This patch unifies both options and consolidates them into a single
> option: CONFIG_GENERIC_ISA_DMA.  It is also a prerequisite for a 1% text
> savings for a future x86 patch that allows these options to be disabled
> on that architecture when CONFIG_ZONE_DMA also becomes configurable.

NAK.  This is wrong.
