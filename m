From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Sat, 29 May 2010 19:24:01 -0600
Message-ID: <20100530012401.GC9132@parisc-linux.org>
References: <20100528.235052.241451895.davem@davemloft.net> <C27F8246C663564A84BB7AB3439772421B78147573@IRVEXCHCCR01.corp.ad.broadcom.com> <20100529.160527.108793180.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, grundler@parisc-linux.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100529.160527.108793180.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 29, 2010 at 04:05:27PM -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Sat, 29 May 2010 09:22:07 -0700
> 
> > I think there may be more issues after thinking about it some more.
> > The device is essentially still active at this time.  The PCI
> > layer can turn off certain things, but enabling INTX can lead to
> > "irq x: nobody cared" if the driver is not ready for it.  The
> > device really needs to be reset by the driver to be totally
> > reliable.
> 
> We still have to find some generic way to do this.
> 
> My position still stands, and it is entirely rediculious to
> have every single driver have to attend to all of these
> esoteric details just to handle interrupts properly.  Drivers
> are hard enough to write as-is.

I think we can do this generically.  PCI has disable bits for MSI,
MSI-X and pin-based interrupts.  So we can leave MSIs enabled, but disable
interrupt generation.

We should probably set the interrupt type back to pin-based before the
kexec kernel starts, right?  Or do we expect drivers to handle being
initialised with the device still set to MSI mode?

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
