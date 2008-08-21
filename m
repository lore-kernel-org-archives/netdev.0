From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Wed, 20 Aug 2008 23:42:03 -0700
Message-ID: <86802c440808202342l1e8eebcbuc92f13c6807dd186@mail.gmail.com>
References: <271523.9227.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>, "Vivek Goyal" <vgoyal@redhat.com>,
	"Bill Fink" <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:28247 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbYHUGmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 02:42:04 -0400
Received: by rv-out-0506.google.com with SMTP id k40so813956rvb.1
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 23:42:03 -0700 (PDT)
In-Reply-To: <271523.9227.qm@web82105.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 20, 2008 at 9:07 PM, David Witbrodt <dawitbro@sbcglobal.net> wrote:
>
>
>> please apply attached patch to see if insert_resource/request resource
>> works on your conf
>
> Yinghai,
>
> Please advise me on how you would like me to handle 2.6.27 kernels.
> If I use your patch on 2.6.27-rc3, the message scroll off the 80x25
> screen before I can see them... and then the kernel hangs.  I can run
> the kernel with "hpet=disable", but I'm not sure you want that.  If
> you _do_ want that, just let me know.
>
> As an alternative, I can alter your patch to use a log level of
> something lower, like KERN_WARNING.  Then I could see the messages
> from your patch if I set a "loglevel=4" boot parameter, even on a
> kernel that hangs.  The normal messages should disappear, only
> leaving the messages from your patch.
>
>
> In the meantime, here is what I _did_ do to test your patch:
>
> ==================================
> $ git checkout -f v2.6.27-rc3
> HEAD is now at 30a2f3c... Linux 2.6.27-rc3
>
> $ git apply --verbose --check ../yh_insert_resource_debug.patch
> Checking patch kernel/resource.c...
>
> $ git apply --verbose ../yh_insert_resource_debug.patch
> Checking patch kernel/resource.c...
> Applied patch kernel/resource.c cleanly.
>
> $ git status
> # Not currently on any branch.
> # Changed but not updated:
> #   (use "git add <file>..." to update what will be committed)
> #
> #    modified:   kernel/resource.c
> #
> no changes added to commit (use "git add" and/or "git commit -a")
> ==================================
>
> This kernel boots and hangs, and I cannot see your patch messages.  But
> I am sure they are there.  (See below.)
>
>
> To see your patch messages without altering the patch, I checked out
> an older revision that will boot.  Also, I just realized why I never get
> the earliest boot log messages from 'dmesg':  the standard value of
> CONFIG_LOG_BUF_SHIFT is 15 (32 KB), which is too small to capture all
> of my early boot messages.
>
> In view of these things, I checked out the last kernel that will run for
> me without hanging,
>
> $ git checkout -f 700efc1b
>
> and set CONFIG_LOG_BUF_SHIFT=18.  Your patch messages show up nicely this
> way:
> ==================================
> $ uname -r
> 2.6.25.test
>
> $ dmesg
> Linux version 2.6.25.test (dawitbro@fileserver) (gcc version 4.3.1 (Debian 4.3.1-2) ) #1 SMP Wed Aug 20 23:31:39 EDT 2008
> Command line: root=/dev/hda1 ro video=uvesafb:1280x1024-16@60,mtrr:3 fbcon=scrollback:256k,font:10x18 debug
> BIOS-provided physical RAM map:
>  BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
>  BIOS-e820: 000000000009f400 - 00000000000a0000 (reserved)
>  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
>  BIOS-e820: 0000000000100000 - 0000000077fe0000 (usable)
>  BIOS-e820: 0000000077fe0000 - 0000000077fe3000 (ACPI NVS)
>  BIOS-e820: 0000000077fe3000 - 0000000077ff0000 (ACPI data)
>  BIOS-e820: 0000000077ff0000 - 0000000078000000 (reserved)
>  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
>  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
> Entering add_active_range(0, 0, 159) 0 entries of 3200 used
> Entering add_active_range(0, 256, 491488) 1 entries of 3200 used
> end_pfn_map = 1048576
> DMI 2.5 present.
> ACPI: RSDP 000F7B80, 0024 (r2 RS690 )
> ACPI: RSDT 77FE3040, 0038 (r1 RS690  AWRDACPI 42302E31 AWRD        0)
> ACPI: FACP 77FE30C0, 0074 (r1 RS690  AWRDACPI 42302E31 AWRD        0)
> ACPI: DSDT 77FE3180, 4B0B (r1 RS690  AWRDACPI     1000 MSFT  3000000)
> ACPI: FACS 77FE0000, 0040
> ACPI: SSDT 77FE7DC0, 028A (r1 PTLTD  POWERNOW        1  LTP        1)
> ACPI: HPET 77FE80C0, 0038 (r1 RS690  AWRDACPI 42302E31 AWRD       98)
> ACPI: MCFG 77FE8140, 003C (r1 RS690  AWRDACPI 42302E31 AWRD        0)
> ACPI: APIC 77FE7D00, 0068 (r1 RS690  AWRDACPI 42302E31 AWRD        0)
> No NUMA configuration found
> Faking a node at 0000000000000000-0000000077fe0000
> Entering add_active_range(0, 0, 159) 0 entries of 3200 used
> Entering add_active_range(0, 256, 491488) 1 entries of 3200 used
> Bootmem setup node 0 0000000000000000-0000000077fe0000
>  NODE_DATA [000000000000c000 - 0000000000012fff]
>  bootmap [0000000000013000 -  0000000000021fff] pages f
> early res: 0 [0-fff] BIOS data page
> early res: 1 [6000-7fff] SMP_TRAMPOLINE
> early res: 2 [200000-7b5387] TEXT DATA BSS
> early res: 3 [9f000-aefff] EBDA
> early res: 4 [8000-bfff] PGTABLE
>  [ffffe20000000000-ffffe200001fffff] PMD ->ffff810001200000 on node 0
>  [ffffe20000200000-ffffe200003fffff] PMD ->ffff810001600000 on node 0
>  [ffffe20000400000-ffffe200005fffff] PMD ->ffff810001a00000 on node 0
>  [ffffe20000600000-ffffe200007fffff] PMD ->ffff810001e00000 on node 0
>  [ffffe20000800000-ffffe200009fffff] PMD ->ffff810002200000 on node 0
>  [ffffe20000a00000-ffffe20000bfffff] PMD ->ffff810002600000 on node 0
>  [ffffe20000c00000-ffffe20000dfffff] PMD ->ffff810002a00000 on node 0
>  [ffffe20000e00000-ffffe20000ffffff] PMD ->ffff810002e00000 on node 0
>  [ffffe20001000000-ffffe200011fffff] PMD ->ffff810003200000 on node 0
>  [ffffe20001200000-ffffe200013fffff] PMD ->ffff810003600000 on node 0
>  [ffffe20001400000-ffffe200015fffff] PMD ->ffff810003a00000 on node 0
>  [ffffe20001600000-ffffe200017fffff] PMD ->ffff810003e00000 on node 0
>  [ffffe20001800000-ffffe200019fffff] PMD ->ffff810004200000 on node 0
>  [ffffe20001a00000-ffffe20001bfffff] PMD ->ffff810004600000 on node 0
> Zone PFN ranges:
>  DMA             0 ->     4096
>  DMA32        4096 ->  1048576
>  Normal    1048576 ->  1048576
> Movable zone start PFN for each node
> early_node_map[2] active PFN ranges
>    0:        0 ->      159
>    0:      256 ->   491488
> On node 0 totalpages: 491391
>  DMA zone: 56 pages used for memmap
>  DMA zone: 1486 pages reserved
>  DMA zone: 2457 pages, LIFO batch:0
>  DMA32 zone: 6663 pages used for memmap
>  DMA32 zone: 480729 pages, LIFO batch:31
>  Normal zone: 0 pages used for memmap
>  Movable zone: 0 pages used for memmap
> ATI board detected. Disabling timer routing over 8254.
> Detected use of extended apic ids on hypertransport bus
> ACPI: PM-Timer IO Port: 0x4008
> ACPI: Local APIC address 0xfee00000
> ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> Processor #0 (Bootup-CPU)
> ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
> Processor #1
> ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
> ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
> ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
> IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
> ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
> ACPI: IRQ0 used by override.
> ACPI: IRQ2 used by override.
> ACPI: IRQ9 used by override.
> Setting APIC routing to flat
> ACPI: HPET id: 0x10b9a201 base: 0xfed00000
> Using ACPI (MADT) for SMP configuration information
> insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (Local APIC) [fee00000, fee00fff]
>    insert_resource: good with request direct parent: (PCI mem) [0, ffffffffffffffff], new: (Local APIC) [fee00000, fee00fff]
> request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (System RAM) [0, 9f3ff] conflict 0
> request_resource: root: (System RAM) [0, 9f3ff], new: (Kernel code) [200000, 557241] conflict 1
> request_resource: root: (System RAM) [0, 9f3ff], new: (Kernel data) [557242, 6b4397] conflict 1
> request_resource: root: (System RAM) [0, 9f3ff], new: (Kernel bss) [736000, 7b5387] conflict 1
> request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (reserved) [9f400, 9ffff] conflict 0
> request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (reserved) [f0000, fffff] conflict 0
> request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (System RAM) [100000, 77fdffff] conflict 0
> request_resource: root: (System RAM) [100000, 77fdffff], new: (Kernel code) [200000, 557241] conflict 0
> request_resource: root: (System RAM) [100000, 77fdffff], new: (Kernel data) [557242, 6b4397] conflict 0
> request_resource: root: (System RAM) [100000, 77fdffff], new: (Kernel bss) [736000, 7b5387] conflict 0
> request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (ACPI Non-volatile Storage) [77fe0000, 77fe2fff] conflict 0
> request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (ACPI Tables) [77fe3000, 77feffff] conflict 0
> request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (reserved) [77ff0000, 77ffffff] conflict 0
> request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (reserved) [e0000000, efffffff] conflict 0
> request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (reserved) [fec00000, ffffffff] conflict 1
..
> insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (HPET 0) [fed00000, fed003ff]
>  insert_resource: first: (0000:00:14.0) [fed00000, fed003ff], new: (HPET 0) [fed00000, fed003ff]
>  insert_resource: direct parent: (PCI mem) [0, ffffffffffffffff], new: (HPET 0) [fed00000, fed003ff]
>    insert_resource: child: (0000:00:14.0) [fed00000, fed003ff], new: (HPET 0) [fed00000, fed003ff]
> insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (IOAPIC 0) [fec00000, fec00fff]
>  insert_resource: first: (pnp 00:0d) [fec00000, fec00fff], new: (IOAPIC 0) [fec00000, fec00fff]
>  insert_resource: direct parent: (PCI mem) [0, ffffffffffffffff], new: (IOAPIC 0) [fec00000, fec00fff]
>    insert_resource: child: (pnp 00:0d) [fec00000, fec00fff], new: (IOAPIC 0) [fec00000, fec00fff]

so old kernel doesn't register [fec00000, ffffffff] from e820 as
reserved. because lapic address register at first.

lapic, ioapic, and hpet0 addr all should be children of [fec00000,
fffffffff] as reserved from e820.

please use my print out patch with current kernel.

YH
