From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Sun, 30 May 2010 09:32:32 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B78147575@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <C27F8246C663564A84BB7AB3439772421B78147573@IRVEXCHCCR01.corp.ad.broadcom.com>
 <20100529.160527.108793180.davem@davemloft.net>
 <20100530012401.GC9132@parisc-linux.org>
 <20100529.204906.55850229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "'grundler@parisc-linux.org'" <grundler@parisc-linux.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-pci@vger.kernel.org'" <linux-pci@vger.kernel.org>
To: "'David Miller'" <davem@davemloft.net>,
	"'matthew@wil.cx'" <matthew@wil.cx>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100529.204906.55850229.davem@davemloft.net>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> From: Matthew Wilcox <matthew@wil.cx>
> Date: Sat, 29 May 2010 19:24:01 -0600
> 
> > We should probably set the interrupt type back to pin-based before
> the
> > kexec kernel starts, right?  Or do we expect drivers to handle being
> > initialised with the device still set to MSI mode?
> 
> The expectation is that the device comes up in INTX mode, which is the
> default after a PCI reset.

We need to be very careful because the device may still be active as I
said earlier.  Turning INTX on may lead to an IRQ storm that nobody will
handle.  Some older devices don't have the INTX enable bit, and INTX will
automatically be enabled when MSI is disabled.

> 
> Basically all of these issues tend to be about the fact that unlike on
> a normal boot, after a kexec an intermediate PCI reset has not occured.
