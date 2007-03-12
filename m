From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.21-rc3-git4 ata1.00: qc timeout (cmd 0xef) (crashdump kernel)
Date: Mon, 12 Mar 2007 17:31:22 +0100
Message-ID: <45F5805A.5080509@googlemail.com>
References: <6bffcb0e0703090857r14eda34bj92f3fd1d0008edb8@mail.gmail.com> <45F51218.9030907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Jeff Garzik <jeff@garzik.org>, linux-ide@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Tejun Heo <htejun@gmail.com>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <45F51218.9030907@gmail.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Tejun Heo napisa=C5=82(a):
> Michal Piotrowski wrote:
>> Hi Jeff,
>>
>> I've got some problems with my SATA controller on crashdump kernel.
>>
>> Calling initcall 0xc1916081: fc_transport_init+0x0/0x35()
>> Calling initcall 0xc19160b6: init_sd+0x0/0xbc()
>> Calling initcall 0xc19161ec: piix_init+0x0/0x27()
>> ata_piix 0000:00:1f.2: version 2.10
>> ata_piix 0000:00:1f.2: MAP [ P0 -- P1 -- ]
>> ACPI: PCI Interrupt 0000:00:1f.2[A] -> Link [LNKC] -> GSI 5 (level,
>> low) -> IRQ 5
>> PCI: Setting latency timer of device 0000:00:1f.2 to 64
>> ata1: SATA max UDMA/133 cmd 0x0001cc00 ctl 0x0001c882 bmdma 0x0001c4=
00
>> irq 5
>> ata2: SATA max UDMA/133 cmd 0x0001c800 ctl 0x0001c482 bmdma 0x0001c4=
08
>> irq 5
>> scsi0 : ata_piix
>> PM: Adding info for No Bus:host0
>> ata1.00: ATA-7: ST3160811AS, 3.AAE, max UDMA/133
>> ata1.00: 312581808 sectors, multi 16: LBA48 NCQ (depth 0/32)
>> ata1.00: qc timeout (cmd 0xef)
>> ata1.00: failed to set xfermode (err_mask=3D0x4)
>=20
> Does giving 'irqpoll' boot parameter fix the problem?
>=20

Hmmm... it works.

Calling initcall 0xc19154d8: piix_ide_init+0x0/0xbb()
Calling initcall 0xc19155b6: generic_ide_init+0x0/0x16()
Calling initcall 0xc191572e: ide_init+0x0/0x81()
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebu=
s=3Dxx
ICH5: IDE controller at PCI slot 0000:00:1f.1
irq 5: nobody cared (try booting with the "irqpoll" option)
 [<c1604556>] show_trace_log_lvl+0x1a/0x2f
 [<c1604c2c>] show_trace+0x12/0x14
 [<c1604cde>] dump_stack+0x16/0x18
 [<c164341c>] __report_bad_irq+0x39/0x79
 [<c16435eb>] note_interrupt+0x18f/0x1c8
 [<c1643ec6>] handle_level_irq+0x95/0xcb
 [<c1605dd8>] do_IRQ+0xb4/0xe0
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
handlers:
[<c174f55e>] (skge_intr+0x0/0x3ff)
Disabling IRQ #5
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 5
ACPI: PCI Interrupt 0000:00:1f.1[A] -> Link [LNKC] -> GSI 5 (level, low=
) -> IRQ 5
ICH5: chipset revision 2
ICH5: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xfc00-0xfc07, BIOS settings: hda:DMA, hdb:DMA
    ide1: BM-DMA at 0xfc08-0xfc0f, BIOS settings: hdc:pio, hdd:DMA

Is this an IDE or skge bug?

http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.21-rc3-git=
4-kdump/git-config

Thomas, Ingo - this soft lockup with irqpoll seems to be fixed
http://www.ussg.iu.edu/hypermail/linux/kernel/0703.0/index.html#1116
Thanks!

Regards,
Michal

--=20
Michal K. K. Piotrowski
LTG - Linux Testers Group (PL)
(http://www.stardust.webpages.pl/ltg/)
LTG - Linux Testers Group (EN)
(http://www.stardust.webpages.pl/linux_testers_group_en/)
