From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 2.6.21-rc3-git4 ata1.00: qc timeout (cmd 0xef) (crashdump
	kernel)
Date: Mon, 12 Mar 2007 17:46:52 +0100
Message-ID: <1173718012.13341.95.camel@localhost.localdomain>
References: <6bffcb0e0703090857r14eda34bj92f3fd1d0008edb8@mail.gmail.com>
	 <45F51218.9030907@gmail.com>  <45F5805A.5080509@googlemail.com>
Reply-To: tglx@linutronix.de
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <htejun@gmail.com>, Jeff Garzik <jeff@garzik.org>,
	linux-ide@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <45F5805A.5080509@googlemail.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-03-12 at 17:31 +0100, Michal Piotrowski wrote:
> Calling initcall 0xc19154d8: piix_ide_init+0x0/0xbb()
> Calling initcall 0xc19155b6: generic_ide_init+0x0/0x16()
> Calling initcall 0xc191572e: ide_init+0x0/0x81()
> Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
> ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
> ICH5: IDE controller at PCI slot 0000:00:1f.1
> irq 5: nobody cared (try booting with the "irqpoll" option)
>  [<c1604556>] show_trace_log_lvl+0x1a/0x2f
>  [<c1604c2c>] show_trace+0x12/0x14
>  [<c1604cde>] dump_stack+0x16/0x18
>  [<c164341c>] __report_bad_irq+0x39/0x79
>  [<c16435eb>] note_interrupt+0x18f/0x1c8
>  [<c1643ec6>] handle_level_irq+0x95/0xcb
>  [<c1605dd8>] do_IRQ+0xb4/0xe0
>  =======================
> handlers:
> [<c174f55e>] (skge_intr+0x0/0x3ff)
> Disabling IRQ #5

I know this one :( 

It seems to be related to the BIOS spinning up the CDROM and leaving the
IDE controller in some weird state. When we come back the interrupt is
screaming and nobody cares, so it gets disabled. I have no clue yet, how
to handle this.

Disabling the interrupt across suspend/resume helps, but does not work,
when the interrupt is shared with some other device.

	tglx


