From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: patch pci-quirk_e100_interrupt-called-too-early.patch added to
 gregkh-2.6 tree
Date: Tue, 17 Jul 2007 10:26:12 -0700
Message-ID: <469CFBB4.4020404@intel.com>
References: <20070717172109.0DA7614540D0@imap.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: m8@semihalf.com, netdev@vger.kernel.org
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7572 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764917AbXGQR0P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2007 13:26:15 -0400
In-Reply-To: <20070717172109.0DA7614540D0@imap.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gregkh@suse.de wrote:
> This is a note to let you know that I've just added the patch titled
> 
>      Subject: [PATCH] PCI: quirk_e100_interrupt() called too early
> 
> to my gregkh-2.6 tree.  Its filename is
> 
>      pci-quirk_e100_interrupt-called-too-early.patch
> 
> This tree can be found at 
>     http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/
> 
> 
> From owner-linux-pci@atrey.karlin.mff.cuni.cz Tue Jul  3 02:03:55 2007
> From: Marian Balakowicz <m8@semihalf.com>
> Date: Tue, 03 Jul 2007 11:03:18 +0200
> Subject: [PATCH] PCI: quirk_e100_interrupt() called too early
> To: "Kok, Auke" <auke-jan.h.kok@intel.com>
> Cc: bjorn.helgaas@hp.com, linux-pci@atrey.karlin.mff.cuni.cz, len.brown@intel.com, NetDev <netdev@vger.kernel.org>
> Message-ID: <468A10D6.2020900@semihalf.com>
> 
> 
> quirk_e100_interrupts() is called after PCI controller is initialized
> and before PCI bus enumeration is performed. On some powerpc platforms
> which modify PCI controller configuration and set different MEM and IO
> windows than those set by firmware quirk_e100_interrupt() is causing
> kernel panic as it tries to read from device BAR0 offets which at this
> time points to a invalid PCI window (set by firmware).
> 
> This patch delays the quirk_100_interrupt() to pci_fixup_final phase,
> which happens after bus enumeration and before PCI enable and
> device driver initialization.
> 
> Signed-off-by: Marian Balakowicz <m8@semihalf.com>
> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> 
> ---
>  drivers/pci/quirks.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/drivers/pci/quirks.c
> +++ b/drivers/pci/quirks.c
> @@ -1485,7 +1485,7 @@ static void __devinit quirk_e100_interru
>  
>  	iounmap(csr);
>  }
> -DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, PCI_ANY_ID, quirk_e100_interrupt);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_ANY_ID, quirk_e100_interrupt);
>  
>  static void __devinit fixup_rev1_53c810(struct pci_dev* dev)
>  {
> 
> 
> Patches currently in gregkh-2.6 which might be from m8@semihalf.com are
> 
> pci/pci-quirk_e100_interrupt-called-too-early.patch


Yes, that's OK. Please note that I asked the person who originally reported the 
problem to make sure that this patch doesn't break anything, but he was still 
too busy to test until now.

I assume (from what I know of the PCI subsystem now) that this is a safe patch, 
so feel free to add:

Acked-by: Auke Kok <auke-jan.h.kok@intel.com>

Cheers,


Auke
