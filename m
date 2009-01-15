From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Thu, 15 Jan 2009 15:27:58 -0800
Message-ID: <20090115232758.GD9091@ovro.caltech.edu>
References: <20090107195052.GA24981@ovro.caltech.edu> <200901151853.52202.arnd@arndb.de> <20090115182034.GA9091@ovro.caltech.edu> <200901152157.42500.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:41082 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756336AbZAOX2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 18:28:00 -0500
Content-Disposition: inline
In-Reply-To: <200901152157.42500.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 09:57:41PM +0100, Arnd Bergmann wrote:
> On Thursday 15 January 2009, Ira Snyder wrote:
> > Some sort of Broadcom chipset, I think. Full dmesg and lspci output are
> > appended.
> > 
> > The PCI bridge does mention MSI, so maybe it does support it. Would
> > using the DMA from the host mean that the guest system couldn't use the
> > DMA controller at all? All of the channels share the same interrupt line
> > on the guest. I need one channel on the DMA controller on the guest to
> > do realtime transfers from some data processing FPGAs on the board.
> 
> The PCI-CompactPCI bridge supports MSI, but that does not imply that
> the host does. My limited understanding of x86 tells me that you need
> to enable the I/O-APIC in order to use MSI. Your log shows two relavant
> lines:
> 
> [    0.000000] Local APIC disabled by BIOS -- you can enable it with "lapic"
> and
> [    2.146845] IO APIC resources could be not be allocated.
> 
> I think you first need to enable the local APIC, then find out what the
> problem with the IO APIC is. If possible, try enabling ACPI (sic) in the
> BIOS in order to get the APIC support.
> 
> If you get that to work, you can use the interrupt line of the DMA controller
> to signal interrupts to the FSL machine, while using DMA transfers to the
> MSI address for sending interrupts to the host machine.
> 

I managed to get the local APIC enabled by adding "lapic" to the kernel
command line. It didn't seem to change anything.

I am totally unable to get the IO APIC working. I hunch that these
boards have totally broken ACPI support, judging from the kernel log.
The BIOS doesn't have much in the way of settings, but I tried the ones
that made sense. No luck there.

Oh well. As in our further discussion, the mailbox or doorbell registers
could be used to trigger DMA interrupts without problems.

Ira
