From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: quirk_e100_interrupt() called too early
Date: Thu, 28 Jun 2007 09:01:08 -0700
Message-ID: <4683DB44.9070704@intel.com>
References: <4683A80F.5020605@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-pci@atrey.karlin.mff.cuni.cz, len.brown@intel.com,
	NetDev <netdev@vger.kernel.org>
To: Marian Balakowicz <m8@semihalf.com>, bjorn.helgaas@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms040pub.verizon.net ([206.46.252.40]:44587 "EHLO
	vms040pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756303AbXF1QBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 12:01:24 -0400
Received: from ahkok-mobl.jf.intel.com ([205.233.55.186])
 by vms040.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0JKC00MJVSHXBYH0@vms040.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 28 Jun 2007 11:01:09 -0500 (CDT)
In-reply-to: <4683A80F.5020605@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marian Balakowicz wrote:
> I am enabling and testing PCI on tqm5200 mpc5200 based board where I
> faced the following issue.
> 
> I am using EEPRO100 PCI card for which there is specific
> quirk_e100_interrupt that tries to disable interrupts if
> they were left enabled by the firmware. quirk_e100_interrupts() is
> called after PCI controller is initialized and before PCI bus
> enumeration is performed. On some powerpc platforms, like the one I am
> using, PCI controller configuration sets different MEM and IO windows
> than those set by firmware. That is why quirk_e100_interrupt() is
> causing kernel panic as it tries to read from device BAR0 offets which
> at this time point to a invalid PCI window (set by firmware).
> 
> The patch below delays the quirk_100_interrupt() to pci_fixup_final
> phase, which happens after bus enumeration and before device PCI enable
> and device driver initialization - so, it seem to be still a good place
> for this quirk. It works fine for me but I only tested it on a tqm5200.
> Could someone please help and verify that on other platforms?

will try to do. This sounds indeed like the proper thing to do. Unfortunately I 
don't have any NICs to repro this on (allthough I have a ppc box with said 
firmware probe method).

Bjorn orignially wrote this patch, perhaps he can comment on the fixup move?

Also, please send a signed-off-by patch so I can push it forward as usual.

Cheers,

Auke


> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> index 01d8f8a..7194074 100644
> --- a/drivers/pci/quirks.c
> +++ b/drivers/pci/quirks.c
> @@ -1475,7 +1475,7 @@ static void __devinit quirk_e100_interru
> 
>         iounmap(csr);
>  }
> -DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, PCI_ANY_ID,
> quirk_e100_interrupt);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_ANY_ID,
> quirk_e100_interrupt);
> 
>  static void __devinit fixup_rev1_53c810(struct pci_dev* dev)
>  {

