From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 09:33:21 -0600
Message-ID: <1194968001.3416.12.camel@localhost.localdomain>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com>
	 <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Natalie Protasevich <protasnb@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org,
	linux-scsi <linux-scsi@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-11-13 at 03:15 -0800, Andrew Morton wrote:
> >
> SCSI==================================================================
> > 
> > qla2xxx: driver initialization does not complete when booting with
> > Port connected
> > http://bugzilla.kernel.org/show_bug.cgi?id=9267
> > Kernel: 2.6.23.1
> 
> No response from developers

Urm, well, if no-one ever tells the SCSI list it's unrealistic to expect
anyone to be working on it.  As far as I can tell, email was sent to
Andrew Vasquez only on 31 October. However, the fault looks to be
generic, so he probably just dropped it.

This seems to be the significant line from the trace:

Oct  7 23:35:07 t-host kernel:   ISP2422: PCI-X Mode 1 (133 MHz) @
0000:01:03.0
hdma-, host#=1, fw=4.00.27 [IP] 
Oct  7 23:35:07 t-host kernel: ACPI: PCI Interrupt 0000:01:03.1[B] -> GSI 29
(level, low) -> IRQ 22
Oct  7 23:35:07 t-host kernel: qla2xxx 0000:01:03.1: Found an ISP2422, irq 22,
iobase 0xf8cf4000
Oct  7 23:35:07 t-host kernel: qla2xxx 0000:01:03.1: Configuring PCI space...
Oct  7 23:35:07 t-host kernel: qla2xxx 0000:01:03.1: Configure NVRAM
parameters...
Oct  7 23:35:07 t-host kernel: qla2xxx 0000:01:03.1: Verifying loaded RISC
code...
Oct  7 23:35:07 t-host kernel: qla2xxx 0000:01:03.1: Allocated (64 KB) for
EFT...
Oct  7 23:35:07 t-host kernel: qla2xxx 0000:01:03.1: Allocated (1413 KB) for
firmware dump...
Oct  7 23:35:07 t-host kernel: scsi2 : qla2xxx
Oct  7 23:35:07 t-host kernel: qla2xxx 0000:01:03.1: 
Oct  7 23:35:07 t-host kernel:  QLogic Fibre Channel HBA Driver: 8.01.07-k7
Oct  7 23:35:07 t-host kernel:   QLogic QLA2462 - PCI-X 2.0 to 4Gb FC, Dual
Channel
Oct  7 23:35:07 t-host kernel:   ISP2422: PCI-X Mode 1 (133 MHz) @ 0000:01:03.1
hdma-, host#=2, fw=4.00.27 [IP] 
Oct  7 23:35:07 t-host kernel: qla2xxx 0000:01:03.0: LIP reset occured (f8f7).
Oct  7 23:35:07 t-host kernel: qla2xxx 0000:01:03.0: LIP occured (f8f7).
Oct  7 23:35:07 t-host kernel: qla2xxx 0000:01:03.0: LOOP UP detected (4 Gbps).
Oct  7 23:35:07 t-host kernel: ohci_hcd 0000:03:00.0: auto-stop root hub
Oct  7 23:35:07 t-host kernel: ohci_hcd 0000:03:00.1: auto-stop root hub
Oct  7 23:35:07 t-host kernel: scsi 1:0:0:0: Direct-Access     transtec
PV610F16R1C      348B PQ: 0 ANSI: 4
Oct  7 23:35:07 t-host kernel: kobject_add failed for 1:0:0:0 with -EEXIST,
don't try to register things with the same name in the same directory.
Oct  7 23:35:07 t-host kernel:  [<c022c841>] kobject_shadow_add+0x111/0x190
Oct  7 23:35:07 t-host kernel:  [<c0286814>] device_add+0xc4/0x570
Oct  7 23:35:07 t-host kernel:  [<c02c90ce>] scsi_adjust_queue_depth+0x9e/0xf0
Oct  7 23:35:07 t-host kernel:  [<c02249b2>] __blk_queue_init_tags+0x32/0x70
Oct  7 23:35:07 t-host kernel:  [<c02d302f>] scsi_sysfs_add_sdev+0x4f/0x230
Oct  7 23:35:07 t-host kernel:  [<f8d93421>] qla2xxx_slave_configure+0x71/0x100
[qla2xxx]
Oct  7 23:35:07 t-host kernel:  [<c02d0ecf>] scsi_probe_and_add_lun+0xa5f/0xb40
Oct  7 23:35:07 t-host kernel:  [<c02d1559>] __scsi_scan_target+0xd9/0x6c0
Oct  7 23:35:07 t-host kernel:  [<c03a5be1>] schedule+0x2e1/0x950
Oct  7 23:35:07 t-host kernel:  [<c02d21f9>] scsi_scan_target+0xa9/0xe0
Oct  7 23:35:07 t-host kernel:  [<c02d5640>] fc_scsi_scan_rport+0x0/0x80
Oct  7 23:35:07 t-host kernel:  [<c02d56a9>] fc_scsi_scan_rport+0x69/0x80
Oct  7 23:35:07 t-host kernel:  [<c012b032>] run_workqueue+0x72/0x100
Oct  7 23:35:07 t-host kernel:  [<c012e8d0>] prepare_to_wait+0x20/0x70
Oct  7 23:35:07 t-host kernel:  [<c012b8c0>] worker_thread+0x0/0x100
Oct  7 23:35:07 t-host kernel:  [<c012b964>] worker_thread+0xa4/0x100
Oct  7 23:35:07 t-host kernel:  [<c012e720>] autoremove_wake_function+0x0/0x50
Oct  7 23:35:07 t-host kernel:  [<c012b8c0>] worker_thread+0x0/0x100
Oct  7 23:35:07 t-host kernel:  [<c012e462>] kthread+0x42/0x70
Oct  7 23:35:07 t-host kernel:  [<c012e420>] kthread+0x0/0x70
Oct  7 23:35:07 t-host kernel:  [<c0103573>] kernel_thread_helper+0x7/0x14
Oct  7 23:35:07 t-host kernel:  =======================
Oct  7 23:35:07 t-host kernel: error 1

It looks like some type of sysfs/kobject race in SCSI ... and I think we
might have seen it before, just not able to reproduce it reliably.

My bet would be that the LIP which acts like a reset and occurs in the
middle of the scan and so the initialising object is killed on the first
scan but not yet dead and then can't be re-added on the second scan.

Hannes has patches to help with this, but they're rather complex, and
not really 2.6.24 material.  I could see if there's a simpler fix.

James


