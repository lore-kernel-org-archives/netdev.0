From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Sat, 29 May 2010 20:49:06 -0700 (PDT)
Message-ID: <20100529.204906.55850229.davem@davemloft.net>
References: <C27F8246C663564A84BB7AB3439772421B78147573@IRVEXCHCCR01.corp.ad.broadcom.com>
	<20100529.160527.108793180.davem@davemloft.net>
	<20100530012401.GC9132@parisc-linux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, grundler@parisc-linux.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: matthew@wil.cx
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100530012401.GC9132@parisc-linux.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthew Wilcox <matthew@wil.cx>
Date: Sat, 29 May 2010 19:24:01 -0600

> We should probably set the interrupt type back to pin-based before the
> kexec kernel starts, right?  Or do we expect drivers to handle being
> initialised with the device still set to MSI mode?

The expectation is that the device comes up in INTX mode, which is the
default after a PCI reset.

Basically all of these issues tend to be about the fact that unlike on
a normal boot, after a kexec an intermediate PCI reset has not occured.
