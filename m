From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.21-rc3-git4 ata1.00: qc timeout (cmd 0xef) (crashdump kernel)
Date: Mon, 12 Mar 2007 18:36:35 +0100
Message-ID: <6bffcb0e0703121036u47dc7aebx33e2307dd50889e0@mail.gmail.com>
References: <6bffcb0e0703090857r14eda34bj92f3fd1d0008edb8@mail.gmail.com>
	 <45F51218.9030907@gmail.com> <45F5805A.5080509@googlemail.com>
	 <45F581B9.9020005@gmail.com>
	 <1173718065.13341.96.camel@localhost.localdomain>
	 <45F58405.1050204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, "Jeff Garzik" <jeff@garzik.org>,
	linux-ide@vger.kernel.org, "Ingo Molnar" <mingo@elte.hu>,
	"Bartlomiej Zolnierkiewicz" <bzolnier@gmail.com>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, "Alan Cox" <alan@lxorguk.ukuu.org.uk>
To: "Tejun Heo" <htejun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:32435 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbXCLRgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 13:36:39 -0400
Received: by ug-out-1314.google.com with SMTP id 44so2324920uga
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 10:36:37 -0700 (PDT)
In-Reply-To: <45F58405.1050204@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/03/07, Tejun Heo <htejun@gmail.com> wrote:
> Thomas Gleixner wrote:
> > On Tue, 2007-03-13 at 01:37 +0900, Tejun Heo wrote:
> >> Michal Piotrowski wrote:
> >>> Calling initcall 0xc19154d8: piix_ide_init+0x0/0xbb()
> >>> Calling initcall 0xc19155b6: generic_ide_init+0x0/0x16()
> >>> Calling initcall 0xc191572e: ide_init+0x0/0x81()
> >>> Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
> >>> ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
> >>> ICH5: IDE controller at PCI slot 0000:00:1f.1
> >>> irq 5: nobody cared (try booting with the "irqpoll" option)
> >>>  [<c1604556>] show_trace_log_lvl+0x1a/0x2f
> >>>  [<c1604c2c>] show_trace+0x12/0x14
> >>>  [<c1604cde>] dump_stack+0x16/0x18
> >>>  [<c164341c>] __report_bad_irq+0x39/0x79
> >>>  [<c16435eb>] note_interrupt+0x18f/0x1c8
> >>>  [<c1643ec6>] handle_level_irq+0x95/0xcb
> >>>  [<c1605dd8>] do_IRQ+0xb4/0xe0
> >>>  =======================
> >>> handlers:
> >>> [<c174f55e>] (skge_intr+0x0/0x3ff)
> >>> Disabling IRQ #5
> >>> ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 5
> >>> ACPI: PCI Interrupt 0000:00:1f.1[A] -> Link [LNKC] -> GSI 5 (level, low) -> IRQ 5
> >>> ICH5: chipset revision 2
> >>> ICH5: not 100% native mode: will probe irqs later
> >>>     ide0: BM-DMA at 0xfc00-0xfc07, BIOS settings: hda:DMA, hdb:DMA
> >>>     ide1: BM-DMA at 0xfc08-0xfc0f, BIOS settings: hdc:pio, hdd:DMA
> >>>
> >>> Is this an IDE or skge bug?
> >> It seems skge's.  skge is screaming and kernel shuts down IRQ 5.
> >> ata_piix is unfortunately sharing the IRQ, so its IRQ doesn't get
> >> serviced and commands time out.
> >
> > I doubt that. On my box the interrupt is solely used by ata_piix.
>
> Ah right.  ata_piix could be screaming when the skge requested IRQ#5,
> but ata_piix is in native mode meaning that the PCI device is probably
> in disabled state when skge requests IRQ#5.
>
> Michal, can you please test the machine with skge disabled?

It seems to work fine with skge disabled.

>  If it's an
> on board device, you can probably disable it in the BIOS configuration menu.
>
> Thanks.
>
> --
> tejun
>

Regards,
Michal

-- 
Michal K. K. Piotrowski
LTG - Linux Testers Group (PL)
(http://www.stardust.webpages.pl/ltg/)
LTG - Linux Testers Group (EN)
(http://www.stardust.webpages.pl/linux_testers_group_en/)
