From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Thu, 15 Jan 2009 21:57:41 +0100
Message-ID: <200901152157.42500.arnd@arndb.de>
References: <20090107195052.GA24981@ovro.caltech.edu> <200901151853.52202.arnd@arndb.de> <20090115182034.GA9091@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	shemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:65197 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934121AbZAOU5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 15:57:52 -0500
In-Reply-To: <20090115182034.GA9091@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 January 2009, Ira Snyder wrote:
> Some sort of Broadcom chipset, I think. Full dmesg and lspci output are
> appended.
> 
> The PCI bridge does mention MSI, so maybe it does support it. Would
> using the DMA from the host mean that the guest system couldn't use the
> DMA controller at all? All of the channels share the same interrupt line
> on the guest. I need one channel on the DMA controller on the guest to
> do realtime transfers from some data processing FPGAs on the board.

The PCI-CompactPCI bridge supports MSI, but that does not imply that
the host does. My limited understanding of x86 tells me that you need
to enable the I/O-APIC in order to use MSI. Your log shows two relavant
lines:

[    0.000000] Local APIC disabled by BIOS -- you can enable it with "lapic"
and
[    2.146845] IO APIC resources could be not be allocated.

I think you first need to enable the local APIC, then find out what the
problem with the IO APIC is. If possible, try enabling ACPI (sic) in the
BIOS in order to get the APIC support.

If you get that to work, you can use the interrupt line of the DMA controller
to signal interrupts to the FSL machine, while using DMA transfers to the
MSI address for sending interrupts to the host machine.

	Arnd <><
