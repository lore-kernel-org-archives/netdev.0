From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.23-rc2: WARNING: at kernel/irq/resend.c:70 check_irq_resend()
Date: Thu, 9 Aug 2007 17:54:45 +0200
Message-ID: <20070809155445.GA5161@ff.dom.local>
References: <18107.11431.838905.331157@stoffel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, shemminger@linux-foundation.org,
	vignaud@xandmail.fr, marcin.slusarz@gmail.com, tglx@linutronix.de,
	mingo@elte.hu, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: John Stoffel <john@stoffel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:41535 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1765415AbXHIPyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 11:54:12 -0400
Content-Disposition: inline
In-Reply-To: <18107.11431.838905.331157@stoffel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2007 at 11:03:03AM -0400, John Stoffel wrote:
> 
> Hi,

Hi, read below, please...

> 
> I'm opening this ticket as a new subject, even though it looks like it
> might be related to the thread "Networking dies after random time".
> Sorry for the wide CC list, but since my network hasn't died since I
> rebooted into 2.6.23-rc2 (after 30+ days at 2.6.22-rc7), I'm wondering
> if the problem is more than networking related.  
> 
> Honestly, I haven't gone back over the previous thread in detail, so I
> might be missing info here.
> 
> System details: Dell Precision 610MT, Intel 440GX chipset, Dual PIII
> Xeon, 550Mhz, 2gb RAM (upgraded from 768Mb last night), a mix of IDE,
> SCSI and SATA disks in the system.  My poor PCI bus!  Just upgraded to
> 2.6.23-rc2.  Interrupts looks like this:
> 
>     > cat /proc/interrupts 
> 	       CPU0       CPU1       
>       0:        280          1   IO-APIC-edge      timer
>       1:        788          0   IO-APIC-edge      i8042
>       6:          1          4   IO-APIC-edge      floppy
>       8:          0          1   IO-APIC-edge      rtc
>       9:          0          0   IO-APIC-fasteoi   acpi
>      11:      82410       1239   IO-APIC-edge      Cyclom-Y
>      12:        279        106   IO-APIC-edge      i8042
>      14:     440901       4266   IO-APIC-edge      libata
>      15:          0          0   IO-APIC-edge      libata
>      16:    2394727      42983   IO-APIC-fasteoi   ohci_hcd:usb3, Ensoniq
> 	       AudioPCI, mga@pci:0000:01:00.0
>      17:    2237362       1110   IO-APIC-fasteoi   sata_sil,
> 	       ehci_hcd:usb1, eth0
>      18:     126520      31978   IO-APIC-fasteoi   aic7xxx, aic7xxx, ide2,
> 	       ide3, ohci1394
>      19:          0          0   IO-APIC-fasteoi   ohci_hcd:usb2,
> 	       uhci_hcd:usb4
>     NMI:          0          0 
>     LOC:   40672484   40672246 
>     ERR:          0
>     MIS:          0
> 
> I've only seen the one Warning oops, and backups and other system
> processes have been running for the past 12 hours without a problem.  
> 
> 
>     [  187.747442] Probing IDE interface ide2...
>     [  188.011634] hde: WDC WD1200JB-00CRA1, ATA DISK drive
>     [  188.623038] WARNING: at kernel/irq/resend.c:70 check_irq_resend()
>     [  188.623105]  [<c0149e38>] check_irq_resend+0xa8/0xc0
>     [  188.623204]  [<c01499d3>] enable_irq+0xc3/0xd0
>     [  188.623295]  [<f8867280>] probe_hwif+0x670/0x7c0 [ide_core]
>     [  188.623448]  [<f8869f04>] do_ide_setup_pci_device+0x154/0x480
>     [ide_core]
>     [  188.623571]  [<f8867d6c>] probe_hwif_init_with_fixup+0xc/0x90
>     [ide_core]
>     [  188.623690]  [<f88817d0>] init_setup_hpt302+0x0/0x30 [hpt366]
>     [  188.623791]  [<f886a39b>] ide_setup_pci_device+0x7b/0xc0 [ide_core]
>     [  188.623909]  [<f88817d0>] init_setup_hpt302+0x0/0x30 [hpt366]
>     [  188.624004]  [<f88811ed>] hpt366_init_one+0x8d/0xa0 [hpt366]
>     [  188.624095]  [<f88817d0>] init_setup_hpt302+0x0/0x30 [hpt366]
>     [  188.624187]  [<f8881e50>] init_chipset_hpt366+0x0/0x680 [hpt366]
>     [  188.624281]  [<f8882680>] init_hwif_hpt366+0x0/0x380 [hpt366]
>     [  188.624372]  [<f8881800>] init_dma_hpt366+0x0/0xe0 [hpt366]
>     [  188.624466]  [<c0265fc6>] pci_device_probe+0x56/0x80
>     [  188.624565]  [<c02d0f8e>] driver_probe_device+0x8e/0x190
>     [  188.624669]  [<c02d11fe>] __driver_attach+0x9e/0xa0
>     [  188.624756]  [<c02d038a>] bus_for_each_dev+0x3a/0x60
>     [  188.624845]  [<c02d0e06>] driver_attach+0x16/0x20
>     [  188.624932]  [<c02d1160>] __driver_attach+0x0/0xa0
>     [  188.625017]  [<c02d075a>] bus_add_driver+0x8a/0x1b0
>     [  188.625107]  [<c0266173>] __pci_register_driver+0x53/0xa0
>     [  188.625197]  [<c0144d5d>] sys_init_module+0x13d/0x1820
>     [  188.625315]  [<f8844000>] snd_timer_find+0x0/0x90 [snd_timer]
>     [  188.625424]  [<c0149530>] disable_irq+0x0/0x30
>     [  188.625513]  [<c0108b7d>] sys_mmap2+0xcd/0xd0
>     [  188.625612]  [<c0104266>] syscall_call+0x7/0xb
>     [  188.625701]  [<c0410000>] rpc_get_inode+0x0/0x80
>     [  188.625798]  =======================
>     [  188.625871] hde: selected mode 0x45
>     [  188.626817] ide2 at 0xecf8-0xecff,0xecf2 on irq 18
>     [  188.627080] Probing IDE interface ide3...
>     [  188.891165] hdg: WDC WD1200JB-00EVA0, ATA DISK drive
>     [  189.502580] hdg: selected mode 0x45
>     [  189.503698] ide3 at 0xece0-0xece7,0xecda on irq 18
> 
> 
> Let 

I'm not sure I don't miss anything (a little in hurry now), but this
warning's aim was purely diagnostical and nothing wrong is meant!
Unless there is something wrong... Then please try to be more explicit.

If you prefer to not see this, there is my patch proposal somewhere
in this older thread:
Subject: [patch] genirq: temporary fix for level-triggered IRQ resend
Date: Wed, 8 Aug 2007 13:00:37 +0200

On the other hand, if it works OK, it would be better to let it be
tested more like this...

Regards,
Jarek P.
