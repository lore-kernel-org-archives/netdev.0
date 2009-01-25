From: Sitsofe Wheeler <sitsofe@yahoo.com>
Subject: Re: [atl2] warn_slowpath in dev_watchdog
Date: Sun, 25 Jan 2009 08:17:25 -0800 (PST)
Message-ID: <884897.63360.qm@web110608.mail.gq1.yahoo.com>
References: <gkt97e$ti0$1@ger.gmane.org> <20090117194045.649f55a0@osprey.hogchain.net> <767752.95325.qm@web110601.mail.gq1.yahoo.com> <20090118095231.2c73c448@osprey.hogchain.net> <879024.62535.qm@web110609.mail.gq1.yahoo.com> <20090118115858.1b636b2d@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, Chris Snook <csnook@redhat.com>,
	jie.yang@atheros.com, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web110608.mail.gq1.yahoo.com ([67.195.13.199]:44835 "HELO
	web110608.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751769AbZAYQR1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jan 2009 11:17:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Jay Cliburn <jcliburn@gmail.com>
> 
> I'll wait for you to try the patch I sent earlier.  I'd like to see if
> the watchdog timeout occurs with the patch applied.

OK the circumstances took a lllllong time to occur again but the result is that
the patch does not prevent the warning. While the issue was occurring I tried to
reproduce the warning from single user mode (after configuring the network via 
dhclient) and could not cause the warning to happen. This makes me wonder
if it is tied to Network Manager or something else that starts on a full boot. 
I also tried disabling the wifi card on the final try to see if the problem was due
to some interaction there but unfortunately the disabling of that didn't work 
completely (see the dmesg with lots of ath5k warnings before the warning).
dmesgs are included below:

[    0.000000] BIOS EBDA/lowmem at: 0009fc00/0009fc00
[    0.000000] Linux version 2.6.28 (@verona) (gcc version 4.2.4) #3
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003f780000 (usable)
[    0.000000]  BIOS-e820: 000000003f780000 - 000000003f790000 (ACPI data)
[    0.000000]  BIOS-e820: 000000003f790000 - 000000003f7d0000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000003f7d0000 - 000000003f7de000 (reserved)
[    0.000000]  BIOS-e820: 000000003f7e0000 - 000000003f800000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
[    0.000000] DMI present.
[    0.000000] last_pfn = 0x3f780 max_arch_pfn = 0x100000
[    0.000000] original variable MTRRs
[    0.000000] reg 0, base: 0GB, range: 1GB, type WB
[    0.000000] reg 1, base: 1016MB, range: 8MB, type UC
[    0.000000] total RAM coverred: 1016M
[    0.000000]  gran_size: 64K     chunk_size: 64K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 128K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 256K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 512K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 128K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 256K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 512K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 256K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 512K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 512K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 16M     chunk_size: 16M     num_reg: 6      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 32M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 64M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 128M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 256M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 512M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 1G     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 2G     num_reg: 6      lose cover RAM: 8M
[    0.000000]  gran_size: 32M     chunk_size: 32M     num_reg: 5      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 64M     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 128M     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 256M     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 512M     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 1G     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 2G     num_reg: 5      lose cover RAM: 24M
[    0.000000]  gran_size: 64M     chunk_size: 64M     num_reg: 4      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 128M     num_reg: 2      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 256M     num_reg: 2      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 512M     num_reg: 2      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 1G     num_reg: 2      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 2G     num_reg: 4      lose cover RAM: 56M
[    0.000000]  gran_size: 128M     chunk_size: 128M     num_reg: 3      lose cover RAM: 120M
[    0.000000]  gran_size: 128M     chunk_size: 256M     num_reg: 2      lose cover RAM: 120M
[    0.000000]  gran_size: 128M     chunk_size: 512M     num_reg: 2      lose cover RAM: 120M
[    0.000000]  gran_size: 128M     chunk_size: 1G     num_reg: 2      lose cover RAM: 120M
[    0.000000]  gran_size: 128M     chunk_size: 2G     num_reg: 3      lose cover RAM: 120M
[    0.000000]  gran_size: 256M     chunk_size: 256M     num_reg: 2      lose cover RAM: 248M
[    0.000000]  gran_size: 256M     chunk_size: 512M     num_reg: 2      lose cover RAM: 248M
[    0.000000]  gran_size: 256M     chunk_size: 1G     num_reg: 2      lose cover RAM: 248M
[    0.000000]  gran_size: 256M     chunk_size: 2G     num_reg: 2      lose cover RAM: 248M
[    0.000000]  gran_size: 512M     chunk_size: 512M     num_reg: 1      lose cover RAM: 504M
[    0.000000]  gran_size: 512M     chunk_size: 1G     num_reg: 1      lose cover RAM: 504M
[    0.000000]  gran_size: 512M     chunk_size: 2G     num_reg: 1      lose cover RAM: 504M
[    0.000000]  gran_size: 1G     chunk_size: 1G     num_reg: 0      lose cover RAM: 1016M
[    0.000000]  gran_size: 1G     chunk_size: 2G     num_reg: 0      lose cover RAM: 1016M
[    0.000000]  gran_size: 2G     chunk_size: 2G     num_reg: 0      lose cover RAM: 1016M
[    0.000000] Found optimal setting for mtrr clean up
[    0.000000] gran_size: 64K     chunk_size: 16M     num_reg: 2      lose RAM: 0G
[    0.000000] range0: 0000000000000000 - 0000000040000000
[    0.000000] Setting variable MTRR 0, base: 0GB, range: 1GB, type WB
[    0.000000] hole: 000000003f800000 - 0000000040000000
[    0.000000] Setting variable MTRR 1, base: 1016MB, range: 8MB, type UC
[    0.000000] kernel direct mapping tables up to 377fe000 @ 7000-d000
[    0.000000] ACPI: RSDP 000FBE60, 0014 (r0 ACPIAM)
[    0.000000] ACPI: RSDT 3F780000, 0034 (r1 A M I  OEMRSDT   9000811 MSFT       97)
[    0.000000] ACPI: FACP 3F780200, 0081 (r1 A M I  OEMFACP   9000811 MSFT       97)
[    0.000000] ACPI: DSDT 3F780400, 6109 (r1  A0979 A0979034       34 INTL 20060113)
[    0.000000] ACPI: FACS 3F790000, 0040
[    0.000000] ACPI: APIC 3F780390, 0068 (r1 A M I  OEMAPIC   9000811 MSFT       97)
[    0.000000] ACPI: OEMB 3F790040, 0046 (r1 A M I  AMI_OEM   9000811 MSFT       97)
[    0.000000] ACPI: MCFG 3F786510, 003C (r1 A M I  OEMMCFG   9000811 MSFT       97)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 127MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 00000000 - 377fe000
[    0.000000]   bootmap 00009000 - 0000ff00
[    0.000000] (6 early reservations) ==> bootmem [0000000000 - 00377fe000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
[    0.000000]   #1 [0000100000 - 000052a0cc]    TEXT DATA BSS ==> [0000100000 - 000052a0cc]
[    0.000000]   #2 [000052b000 - 000052e000]    INIT_PG_TABLE ==> [000052b000 - 000052e000]
[    0.000000]   #3 [000009fc00 - 0000100000]    BIOS reserved ==> [000009fc00 - 0000100000]
[    0.000000]   #4 [0000007000 - 0000009000]          PGTABLE ==> [0000007000 - 0000009000]
[    0.000000]   #5 [0000009000 - 0000010000]          BOOTMAP ==> [0000009000 - 0000010000]
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x000377fe
[    0.000000]   HighMem  0x000377fe -> 0x0003f780
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0003f780
[    0.000000] On node 0 totalpages: 259871
[    0.000000] free_area_init_node: node 0, pgdat c04738e0, node_mem_map c1000000
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3967 pages, LIFO batch:0
[    0.000000]   Normal zone: 1744 pages used for memmap
[    0.000000]   Normal zone: 221486 pages, LIFO batch:31
[    0.000000]   HighMem zone: 256 pages used for memmap
[    0.000000]   HighMem zone: 32386 pages, LIFO batch:7
[    0.000000]   Movable zone: 0 pages used for memmap
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Allocating PCI resources starting at 40000000 (gap: 3f800000:bf600000)
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 257839
[    0.000000] Kernel command line: root=/dev/sdb2 ro quiet
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 16384 bytes)
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 900.210 MHz processor.
[    0.000999] Console: colour VGA+ 80x25
[    0.000999] console [tty0] enabled
[    0.000999] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000999] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000999] Memory: 1025948k/1039872k available (2547k kernel code, 13236k reserved, 1019k data, 256k init, 130568k highmem)
[    0.000999] virtual kernel memory layout:
[    0.000999]     fixmap  : 0xfffac000 - 0xfffff000   ( 332 kB)
[    0.000999]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000999]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000999]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000999]       .init : 0xc047e000 - 0xc04be000   ( 256 kB)
[    0.000999]       .data : 0xc037cd2a - 0xc047bcec   (1019 kB)
[    0.000999]       .text : 0xc0100000 - 0xc037cd2a   (2547 kB)
[    0.000999] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000999] SLUB: Genslabs=12, HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.001014] Calibrating delay loop (skipped), value calculated using timer frequency.. 1800.42 BogoMIPS (lpj=900210)
[    0.001038] Security Framework initialized
[    0.001057] Mount-cache hash table entries: 512
[    0.001276] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.001281] CPU: L2 cache: 512K
[    0.001285] Intel machine check architecture supported.
[    0.001293] Intel machine check reporting enabled on CPU#0.
[    0.001307] CPU: Intel(R) Celeron(R) M processor          900MHz stepping 08
[    0.001318] Checking 'hlt' instruction... OK.
[    0.005639] Freeing SMP alternatives: 0k freed
[    0.005643] ACPI: Core revision 20080926
[    0.020777] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.030995] net_namespace: 288 bytes
[    0.030995] NET: Registered protocol family 16
[    0.030995] ACPI: bus type pci registered
[    0.030995] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.030995] PCI: Not using MMCONFIG.
[    0.030995] PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=5
[    0.030995] PCI: Using configuration type 1 for base access
[    0.036028] ACPI: EC: Look up EC in DSDT
[    0.047863] ACPI: Interpreter enabled
[    0.047876] ACPI: (supports S0 S1 S3 S5)
[    0.047908] ACPI: Using IOAPIC for interrupt routing
[    0.048032] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.051374] PCI: MCFG area at e0000000 reserved in ACPI motherboard resources
[    0.051379] PCI: Using MMCONFIG for extended config space
[    0.062779] ACPI: EC: GPE = 0x18, I/O: command/status = 0x66, data = 0x62
[    0.062785] ACPI: EC: driver started in poll mode
[    0.063081] ACPI: No dock devices found.
[    0.063232] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.063393] pci 0000:00:02.0: reg 10 32bit mmio: [0xf7f00000-0xf7f7ffff]
[    0.063401] pci 0000:00:02.0: reg 14 io port: [0xec00-0xec07]
[    0.063408] pci 0000:00:02.0: reg 18 32bit mmio: [0xd0000000-0xdfffffff]
[    0.063416] pci 0000:00:02.0: reg 1c 32bit mmio: [0xf7ec0000-0xf7efffff]
[    0.063454] pci 0000:00:02.1: reg 10 32bit mmio: [0xf7f80000-0xf7ffffff]
[    0.063549] pci 0000:00:1b.0: reg 10 64bit mmio: [0xf7eb8000-0xf7ebbfff]
[    0.063583] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.063590] pci 0000:00:1b.0: PME# disabled
[    0.063642] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.063648] pci 0000:00:1c.0: PME# disabled
[    0.063702] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.063707] pci 0000:00:1c.1: PME# disabled
[    0.063761] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.063767] pci 0000:00:1c.2: PME# disabled
[    0.063820] pci 0000:00:1d.0: reg 20 io port: [0xe400-0xe41f]
[    0.063875] pci 0000:00:1d.1: reg 20 io port: [0xe480-0xe49f]
[    0.063928] pci 0000:00:1d.2: reg 20 io port: [0xe800-0xe81f]
[    0.063981] pci 0000:00:1d.3: reg 20 io port: [0xe880-0xe89f]
[    0.064047] pci 0000:00:1d.7: reg 10 32bit mmio: [0xf7eb7c00-0xf7eb7fff]
[    0.064091] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.064097] pci 0000:00:1d.7: PME# disabled
[    0.064222] pci 0000:00:1f.0: Force enabled HPET at 0xfed00000
[    0.064231] pci 0000:00:1f.0: quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
[    0.064238] pci 0000:00:1f.0: quirk: region 0480-04bf claimed by ICH6 GPIO
[    0.064270] pci 0000:00:1f.2: reg 10 io port: [0x00-0x07]
[    0.064278] pci 0000:00:1f.2: reg 14 io port: [0x00-0x03]
[    0.064287] pci 0000:00:1f.2: reg 18 io port: [0x00-0x07]
[    0.064295] pci 0000:00:1f.2: reg 1c io port: [0x00-0x03]
[    0.064303] pci 0000:00:1f.2: reg 20 io port: [0xffa0-0xffaf]
[    0.064324] pci 0000:00:1f.2: PME# supported from D3hot
[    0.064329] pci 0000:00:1f.2: PME# disabled
[    0.064379] pci 0000:00:1f.3: reg 20 io port: [0x400-0x41f]
[    0.064510] pci 0000:03:00.0: reg 10 64bit mmio: [0xfbfc0000-0xfbffffff]
[    0.064547] pci 0000:03:00.0: reg 30 32bit mmio: [0xfbfa0000-0xfbfbffff]
[    0.064562] pci 0000:03:00.0: PME# supported from D3hot D3cold
[    0.064569] pci 0000:03:00.0: PME# disabled
[    0.064624] pci 0000:00:1c.1: bridge 32bit mmio: [0xfbf00000-0xfbffffff]
[    0.064689] pci 0000:01:00.0: reg 10 64bit mmio: [0xfbef0000-0xfbefffff]
[    0.064791] pci 0000:00:1c.2: bridge 32bit mmio: [0xf8000000-0xfbefffff]
[    0.064800] pci 0000:00:1c.2: bridge 64bit mmio pref: [0xf0000000-0xf6ffffff]
[    0.064852] pci 0000:00:1e.0: transparent bridge
[    0.064883] bus 00 -> node 0
[    0.064899] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.065408] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P3._PRT]
[    0.065603] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P5._PRT]
[    0.065795] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P6._PRT]
[    0.073813] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 *5 6 7 10 11 12 14 15)
[    0.074115] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[    0.074387] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    0.074660] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *7 10 11 12 14 15)
[    0.074929] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.075214] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.075487] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.075762] ACPI: PCI Interrupt Link [LNKH] (IRQs *3 4 5 6 7 10 11 12 14 15)
[    0.076388] SCSI subsystem initialized
[    0.076427] libata version 3.00 loaded.
[    0.076580] usbcore: registered new interface driver usbfs
[    0.076637] usbcore: registered new interface driver hub
[    0.076702] usbcore: registered new device driver usb
[    0.077014] PCI: Using ACPI for IRQ routing
[    0.077177] cfg80211: Using static regulatory domain info
[    0.077177] cfg80211: Regulatory domain: US
[    0.077177]     (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[    0.077177]     (2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, 2700 mBm)
[    0.077177]     (5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.077177]     (5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.077177]     (5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.077177]     (5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.077177]     (5735000 KHz - 5835000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
[    0.077177] cfg80211: Calling CRDA for country: US
[    0.077423] hpet clockevent registered
[    0.077429] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.077439] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.077447] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.079052] pnp: PnP ACPI init
[    0.079052] ACPI: bus type pnp registered
[    0.083294] pnp: PnP ACPI: found 13 devices
[    0.083299] ACPI: ACPI bus type pnp unregistered
[    0.083322] system 00:01: iomem range 0xfed13000-0xfed19fff has been reserved
[    0.083341] system 00:08: ioport range 0x380-0x383 has been reserved
[    0.083347] system 00:08: ioport range 0x4d0-0x4d1 has been reserved
[    0.083352] system 00:08: ioport range 0x800-0x87f has been reserved
[    0.083357] system 00:08: ioport range 0x480-0x4bf has been reserved
[    0.083363] system 00:08: iomem range 0xfed1c000-0xfed1ffff has been reserved
[    0.083369] system 00:08: iomem range 0xfed20000-0xfed8ffff has been reserved
[    0.083380] system 00:08: iomem range 0xfff00000-0xffffffff could not be reserved
[    0.083390] system 00:09: iomem range 0xfec00000-0xfec00fff has been reserved
[    0.083396] system 00:09: iomem range 0xfee00000-0xfee00fff has been reserved
[    0.083406] system 00:0a: iomem range 0xe0000000-0xefffffff has been reserved
[    0.083415] system 00:0b: iomem range 0xe0000000-0xefffffff has been reserved
[    0.083425] system 00:0c: iomem range 0x0-0x9ffff could not be reserved
[    0.083431] system 00:0c: iomem range 0xe0000-0xfffff could not be reserved
[    0.083436] system 00:0c: iomem range 0x100000-0x3f7fffff could not be reserved
[    0.118701] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:04
[    0.118707] pci 0000:00:1c.0:   IO window: disabled
[    0.118714] pci 0000:00:1c.0:   MEM window: disabled
[    0.118720] pci 0000:00:1c.0:   PREFETCH window: disabled
[    0.118728] pci 0000:00:1c.1: PCI bridge, secondary bus 0000:03
[    0.118732] pci 0000:00:1c.1:   IO window: disabled
[    0.118739] pci 0000:00:1c.1:   MEM window: 0xfbf00000-0xfbffffff
[    0.118745] pci 0000:00:1c.1:   PREFETCH window: disabled
[    0.118753] pci 0000:00:1c.2: PCI bridge, secondary bus 0000:01
[    0.118757] pci 0000:00:1c.2:   IO window: disabled
[    0.118763] pci 0000:00:1c.2:   MEM window: 0xf8000000-0xfbefffff
[    0.118770] pci 0000:00:1c.2:   PREFETCH window: 0x000000f0000000-0x000000f6ffffff
[    0.118779] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:05
[    0.118783] pci 0000:00:1e.0:   IO window: disabled
[    0.118789] pci 0000:00:1e.0:   MEM window: disabled
[    0.118794] pci 0000:00:1e.0:   PREFETCH window: disabled
[    0.118818] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.118826] pci 0000:00:1c.0: setting latency timer to 64
[    0.118836] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    0.118842] pci 0000:00:1c.1: setting latency timer to 64
[    0.118853] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    0.118859] pci 0000:00:1c.2: setting latency timer to 64
[    0.118868] pci 0000:00:1e.0: setting latency timer to 64
[    0.118874] bus: 00 index 0 io port: [0x00-0xffff]
[    0.118878] bus: 00 index 1 mmio: [0x000000-0xffffffff]
[    0.118882] bus: 04 index 0 mmio: [0x0-0x0]
[    0.118886] bus: 04 index 1 mmio: [0x0-0x0]
[    0.118889] bus: 04 index 2 mmio: [0x0-0x0]
[    0.118892] bus: 04 index 3 mmio: [0x0-0x0]
[    0.118896] bus: 03 index 0 mmio: [0x0-0x0]
[    0.118900] bus: 03 index 1 mmio: [0xfbf00000-0xfbffffff]
[    0.118903] bus: 03 index 2 mmio: [0x0-0x0]
[    0.118907] bus: 03 index 3 mmio: [0x0-0x0]
[    0.118910] bus: 01 index 0 mmio: [0x0-0x0]
[    0.118914] bus: 01 index 1 mmio: [0xf8000000-0xfbefffff]
[    0.118918] bus: 01 index 2 mmio: [0xf0000000-0xf6ffffff]
[    0.118922] bus: 01 index 3 mmio: [0x0-0x0]
[    0.118926] bus: 05 index 0 mmio: [0x0-0x0]
[    0.118929] bus: 05 index 1 mmio: [0x0-0x0]
[    0.118932] bus: 05 index 2 mmio: [0x0-0x0]
[    0.118936] bus: 05 index 3 io port: [0x00-0xffff]
[    0.118940] bus: 05 index 4 mmio: [0x000000-0xffffffff]
[    0.118958] NET: Registered protocol family 2
[    0.119062] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.119198] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.120884] TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
[    0.121385] TCP: Hash tables configured (established 131072 bind 65536)
[    0.121391] TCP reno registered
[    0.121509] NET: Registered protocol family 1
[    0.121803] Machine check exception polling timer started.
[    0.122309] Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.122361] alg: cipher: Test 1 failed on encryption for aes-asm
[    0.122426] 00000000: 00 01 02 03 04 05 06 07 08 08 08 08 08 08 08 08 
[    0.122803] highmem bounce pool size: 64 pages
[    0.122919] fuse init (API version 7.10)
[    0.123035] msgmni has been set to 1749
[    0.123301] alg: No test for stdrng (krng)
[    0.123319] io scheduler noop registered
[    0.123323] io scheduler deadline registered (default)
[    0.123341] pci 0000:00:02.0: Boot video device
[    0.126398] pcieport-driver 0000:00:1c.0: setting latency timer to 64
[    0.126440] pcieport-driver 0000:00:1c.0: found MSI capability
[    0.126474] pcieport-driver 0000:00:1c.0: irq 287 for MSI/MSI-X
[    0.126489] pci_express 0000:00:1c.0:pcie00: allocate port service
[    0.126550] pci_express 0000:00:1c.0:pcie02: allocate port service
[    0.126608] pci_express 0000:00:1c.0:pcie03: allocate port service
[    0.126715] pcieport-driver 0000:00:1c.1: setting latency timer to 64
[    0.126753] pcieport-driver 0000:00:1c.1: found MSI capability
[    0.126779] pcieport-driver 0000:00:1c.1: irq 286 for MSI/MSI-X
[    0.126796] pci_express 0000:00:1c.1:pcie00: allocate port service
[    0.126849] pci_express 0000:00:1c.1:pcie02: allocate port service
[    0.126904] pci_express 0000:00:1c.1:pcie03: allocate port service
[    0.127018] pcieport-driver 0000:00:1c.2: setting latency timer to 64
[    0.127055] pcieport-driver 0000:00:1c.2: found MSI capability
[    0.127082] pcieport-driver 0000:00:1c.2: irq 285 for MSI/MSI-X
[    0.127098] pci_express 0000:00:1c.2:pcie00: allocate port service
[    0.127152] pci_express 0000:00:1c.2:pcie02: allocate port service
[    0.127209] pci_express 0000:00:1c.2:pcie03: allocate port service
[    0.127602] ACPI: AC Adapter [AC0] (off-line)
[    0.129219] ACPI: EC: non-query interrupt received, switching to interrupt mode
[    0.577801] Switched to high resolution mode on CPU 0
[    0.598276] ACPI: Battery Slot [BAT0] (battery present)
[    0.598979] input: Power Button (FF) as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.598984] ACPI: Power Button (FF) [PWRF]
[    0.599137] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input1
[    0.614490] ACPI: Lid Switch [LID]
[    0.614627] input: Sleep Button (CM) as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input2
[    0.614632] ACPI: Sleep Button (CM) [SLPB]
[    0.614752] input: Power Button (CM) as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input3
[    0.614757] ACPI: Power Button (CM) [PWRB]
[    0.615623] ACPI: CPU0 (power states: C1[C1] C2[C2] C3[C3])
[    0.615705] processor ACPI_CPU:00: registered as cooling_device0
[    0.615713] ACPI: Processor [CPU1] (supports 8 throttling states)
[    0.827845] thermal LNXTHERM:01: registered as thermal_zone0
[    0.860819] ACPI: Thermal Zone [TZ00] (55 C)
[    0.865562] Non-volatile memory driver v1.2
[    0.865567] Linux agpgart interface v0.103
[    0.865596] agpgart-intel 0000:00:00.0: Intel 915GM Chipset
[    0.865895] agpgart-intel 0000:00:00.0: detected 7932K stolen memory
[    0.869384] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    0.869510] [drm] Initialized drm 1.1.0 20060810
[    0.869547] pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.869554] pci 0000:00:02.0: setting latency timer to 64
[    0.869630] [drm:i915_gem_detect_bit_6_swizzle] *ERROR* Couldn't read from MCHBAR.  Disabling tiling.
[    0.869829] [drm] Initialized i915 1.6.0 20080730 on minor 0
[    0.870919] loop: module loaded
[    0.870958] eeepc: Eee PC Hotkey Driver
[    0.871233] eeepc: Hotkey init flags 0x41
[    0.872503] eeepc: Get control methods supported: 0x101711
[    0.872636] input: Asus EeePC extra buttons as /devices/virtual/input/input4
[    0.877036] Atheros(R) L2 Ethernet Driver - version 2.2.3
[    0.877041] Copyright (c) 2007 Atheros Corporation.
[    0.877073] atl2 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.877085] atl2 0000:03:00.0: setting latency timer to 64
[    0.916261] ath5k_pci 0000:01:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    0.916274] ath5k_pci 0000:01:00.0: setting latency timer to 64
[    0.916315] ath5k_pci 0000:01:00.0: registered as 'phy0'
[    0.956603] phy0: Selected rate control algorithm 'minstrel'
[    0.956876] ath5k phy0: Atheros AR2425 chip found (MAC: 0xe2, PHY: 0x70)
[    0.956931] Linux video capture interface: v2.00
[    0.957146] usbcore: registered new interface driver uvcvideo
[    0.957152] USB Video Class driver (v0.1.0)
[    0.957199] Driver 'sd' needs updating - please use bus_type methods
[    0.957264] ata_piix 0000:00:1f.2: version 2.12
[    0.957289] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    0.957295] ata_piix 0000:00:1f.2: MAP [ P0 P2 IDE IDE ]
[    0.957356] ata_piix 0000:00:1f.2: setting latency timer to 64
[    0.957441] scsi0 : ata_piix
[    0.957608] scsi1 : ata_piix
[    0.960826] ata1: SATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
[    0.960831] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
[    1.278366] ata2.00: ATA-5: ASUS-PHISON OB SSD, TST2.04P, max UDMA/66
[    1.278372] ata2.00: 7880544 sectors, multi 0: LBA 
[    1.278445] ata2.01: ATA-5: ASUS-PHISON SSD, TST2.04P, max UDMA/66
[    1.278449] ata2.01: 31522176 sectors, multi 0: LBA 
[    1.281339] ata2.00: configured for UDMA/66
[    1.284333] ata2.01: configured for UDMA/66
[    1.284488] scsi 1:0:0:0: Direct-Access     ATA      ASUS-PHISON OB S TST2 PQ: 0 ANSI: 5
[    1.284764] sd 1:0:0:0: [sda] 7880544 512-byte hardware sectors: (4.03 GB/3.75 GiB)
[    1.284788] sd 1:0:0:0: [sda] Write Protect is off
[    1.284793] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.284826] sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    1.284919] sd 1:0:0:0: [sda] 7880544 512-byte hardware sectors: (4.03 GB/3.75 GiB)
[    1.284939] sd 1:0:0:0: [sda] Write Protect is off
[    1.284943] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.284974] sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    1.284980]  sda: sda1 sda2 sda3 sda4
[    1.286437] sd 1:0:0:0: [sda] Attached SCSI disk
[    1.286619] scsi 1:0:1:0: Direct-Access     ATA      ASUS-PHISON SSD  TST2 PQ: 0 ANSI: 5
[    1.286864] sd 1:0:1:0: [sdb] 31522176 512-byte hardware sectors: (16.1 GB/15.0 GiB)
[    1.286885] sd 1:0:1:0: [sdb] Write Protect is off
[    1.286890] sd 1:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    1.286921] sd 1:0:1:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    1.287015] sd 1:0:1:0: [sdb] 31522176 512-byte hardware sectors: (16.1 GB/15.0 GiB)
[    1.287036] sd 1:0:1:0: [sdb] Write Protect is off
[    1.287041] sd 1:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    1.287072] sd 1:0:1:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    1.287077]  sdb: sdb1 sdb2
[    1.288714] sd 1:0:1:0: [sdb] Attached SCSI disk
[    1.288837] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.288879] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    1.288907] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    1.288913] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    1.289021] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    1.292948] ehci_hcd 0000:00:1d.7: debug port 1
[    1.292958] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
[    1.292977] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xf7eb7c00
[    1.302009] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    1.302198] usb usb1: configuration #1 chosen from 1 choice
[    1.302285] hub 1-0:1.0: USB hub found
[    1.302299] hub 1-0:1.0: 8 ports detected
[    1.302617] uhci_hcd: USB Universal Host Controller Interface driver
[    1.302649] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    1.302659] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    1.302665] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    1.302738] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    1.302770] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000e400
[    1.302945] usb usb2: configuration #1 chosen from 1 choice
[    1.303040] hub 2-0:1.0: USB hub found
[    1.303053] hub 2-0:1.0: 2 ports detected
[    1.303277] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    1.303288] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    1.303293] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    1.303361] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    1.303397] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000e480
[    1.303566] usb usb3: configuration #1 chosen from 1 choice
[    1.303649] hub 3-0:1.0: USB hub found
[    1.303662] hub 3-0:1.0: 2 ports detected
[    1.303891] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    1.303901] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    1.303907] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    1.303978] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    1.304020] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000e800
[    1.304207] usb usb4: configuration #1 chosen from 1 choice
[    1.304302] hub 4-0:1.0: USB hub found
[    1.304314] hub 4-0:1.0: 2 ports detected
[    1.304538] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 16 (level, low) -> IRQ 16
[    1.304548] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    1.304553] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    1.304624] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    1.304659] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000e880
[    1.304840] usb usb5: configuration #1 chosen from 1 choice
[    1.304924] hub 5-0:1.0: USB hub found
[    1.304937] hub 5-0:1.0: 2 ports detected
[    1.305228] Initializing USB Mass Storage driver...
[    1.305316] usbcore: registered new interface driver usb-storage
[    1.305323] USB Mass Storage support registered.
[    1.305491] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    1.338241] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.338249] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.338515] mice: PS/2 mouse device common for all mice
[    1.339810] rtc_cmos 00:03: RTC can wake from S4
[    1.339910] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    1.339938] rtc0: alarms up to one month, 114 bytes nvram, hpet irqs
[    1.340168] cpuidle: using governor ladder
[    1.340483] cpuidle: using governor menu
[    1.340549] Advanced Linux Sound Architecture Driver Version 1.0.18rc3.
[    1.340676] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.340716] HDA Intel 0000:00:1b.0: setting latency timer to 64
[    1.342056] Marking TSC unstable due to TSC halts in idle
[    1.342802] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input5
[    1.348929] hda_codec: Unknown model for ALC662, trying auto-probe from BIOS...
[    1.373784] ALSA device list:
[    1.373788]   #0: HDA Intel at 0xf7eb8000 irq 16
[    1.373831] TCP cubic registered
[    1.373835] NET: Registered protocol family 17
[    1.373898] Using IPI Shortcut mode
[    1.374337] rtc_cmos 00:03: setting system clock to
[    1.577017] Clocksource tsc unstable (delta = -189549034 ns)
[    1.604194] usb 1-5: new high speed USB device using ehci_hcd and address 2
[    1.721557] usb 1-5: configuration #1 chosen from 1 choice
[    1.721849] scsi2 : SCSI emulation for USB Mass Storage devices
[    1.722117] usb-storage: device found at 2
[    1.722121] usb-storage: waiting for device to settle before scanning
[    3.400647] input: ImPS/2 Logitech Wheel Mouse as /devices/platform/i8042/serio1/input/input6
[    3.498160] kjournald starting.  Commit interval 5 seconds
[    3.498175] EXT3-fs: mounted filesystem with ordered data mode.
[    3.498191] VFS: Mounted root (ext3 filesystem) readonly.
[    3.498397] Freeing unused kernel memory: 256k freed
[    3.498467] Write protecting the kernel text: 2548k
[    3.498500] Write protecting the kernel read-only data: 696k
[    6.503338] EXT3 FS on sdb2, internal journal
[    6.723849] usb-storage: device scan complete
[    6.724749] scsi 2:0:0:0: Direct-Access     USB2.0   CardReader SD0   0100 PQ: 0 ANSI: 0
[    7.235711] sd 2:0:0:0: [sdc] 15661056 512-byte hardware sectors: (8.01 GB/7.46 GiB)
[    7.236209] sd 2:0:0:0: [sdc] Write Protect is on
[    7.236216] sd 2:0:0:0: [sdc] Mode Sense: 03 00 80 00
[    7.236220] sd 2:0:0:0: [sdc] Assuming drive cache: write through
[    7.237835] sd 2:0:0:0: [sdc] 15661056 512-byte hardware sectors: (8.01 GB/7.46 GiB)
[    7.238335] sd 2:0:0:0: [sdc] Write Protect is on
[    7.238342] sd 2:0:0:0: [sdc] Mode Sense: 03 00 80 00
[    7.238346] sd 2:0:0:0: [sdc] Assuming drive cache: write through
[    7.238431]  sdc: sdc1 sdc2
[    7.241317] sd 2:0:0:0: [sdc] Attached SCSI removable disk
[   12.199714] warning: `avahi-daemon' uses 32-bit capabilities (legacy support in use)
[   13.692295] atl2 0000:03:00.0: irq 284 for MSI/MSI-X
[   13.897628] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[   50.220051] kjournald starting.  Commit interval 5 seconds
[   50.220085] EXT3-fs: mounted filesystem with ordered data mode.
[  434.025873] ------------[ cut here ]------------
[  434.025880] WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x19f/0x1b0()
[  434.025885] NETDEV WATCHDOG: eth0 (atl2): transmit timed out
[  434.025891] Pid: 0, comm: swapper Not tainted 2.6.28 #3
[  434.025894] Call Trace:
[  434.025904]  [<c011f8f1>] warn_slowpath+0x71/0x90
[  434.025913]  [<c01389e2>] tick_dev_program_event+0x32/0xa0
[  434.025919]  [<c0138ab4>] tick_program_event+0x14/0x20
[  434.025927]  [<c0132e83>] hrtimer_interrupt+0x153/0x180
[  434.025935]  [<c01113f0>] smp_apic_timer_interrupt+0x40/0x80
[  434.025942]  [<c0103cd4>] apic_timer_interrupt+0x28/0x30
[  434.025949]  [<c01f007b>] blk_rq_map_user+0x9b/0x270
[  434.025955]  [<c01f8ca0>] strlcpy+0x20/0x60
[  434.025962]  [<c0108c32>] native_read_tsc+0x2/0x10
[  434.025968]  [<c03183d0>] dev_watchdog+0x0/0x1b0
[  434.025974]  [<c031856f>] dev_watchdog+0x19f/0x1b0
[  434.025981]  [<c0276f00>] ath5k_hw_channel+0x730/0x790
[  434.025988]  [<c01389e2>] tick_dev_program_event+0x32/0xa0
[  434.025995]  [<c0126faf>] run_timer_softirq+0x10f/0x160
[  434.026001]  [<c0123884>] __do_softirq+0x54/0x100
[  434.026016]  [<c0105db0>] timer_interrupt+0x20/0x30
[  434.026021]  [<c013d025>] handle_IRQ_event+0x25/0x60
[  434.026027]  [<c0123957>] do_softirq+0x27/0x30
[  434.026033]  [<c0123be5>] irq_exit+0x45/0x70
[  434.026038]  [<c0105455>] do_IRQ+0x75/0x90
[  434.026043]  [<c01140aa>] read_hpet+0xa/0x10
[  434.026048]  [<c0134b47>] getnstimeofday+0x37/0xf0
[  434.026054]  [<c0103ca7>] common_interrupt+0x23/0x28
[  434.026062]  [<c022bde0>] acpi_idle_enter_bm+0x1ae/0x1df
[  434.026069]  [<c02dab25>] cpuidle_idle_call+0x65/0xb0
[  434.026074]  [<c0101dd5>] cpu_idle+0x35/0x70
[  434.026078] ---[ end trace 55f6a70c5e40656e ]---
[  434.035766] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[  454.312924] ath5k phy0: noise floor calibration timeout (2412MHz)
[  465.313095] ath5k phy0: noise floor calibration timeout (2412MHz)
[  465.450255] ath5k phy0: failed to wakeup the MAC Chip


[    0.000000] BIOS EBDA/lowmem at: 0009fc00/0009fc00
[    0.000000] Linux version 2.6.28 (@verona) (gcc version 4.2.4) #3
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003f780000 (usable)
[    0.000000]  BIOS-e820: 000000003f780000 - 000000003f790000 (ACPI data)
[    0.000000]  BIOS-e820: 000000003f790000 - 000000003f7d0000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000003f7d0000 - 000000003f7de000 (reserved)
[    0.000000]  BIOS-e820: 000000003f7e0000 - 000000003f800000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
[    0.000000] DMI present.
[    0.000000] last_pfn = 0x3f780 max_arch_pfn = 0x100000
[    0.000000] original variable MTRRs
[    0.000000] reg 0, base: 0GB, range: 1GB, type WB
[    0.000000] reg 1, base: 1016MB, range: 8MB, type UC
[    0.000000] total RAM coverred: 1016M
[    0.000000]  gran_size: 64K     chunk_size: 64K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 128K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 256K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 512K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 128K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 256K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 512K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 256K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 512K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 512K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 16M     chunk_size: 16M     num_reg: 6      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 32M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 64M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 128M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 256M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 512M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 1G     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 2G     num_reg: 6      lose cover RAM: 8M
[    0.000000]  gran_size: 32M     chunk_size: 32M     num_reg: 5      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 64M     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 128M     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 256M     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 512M     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 1G     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 2G     num_reg: 5      lose cover RAM: 24M
[    0.000000]  gran_size: 64M     chunk_size: 64M     num_reg: 4      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 128M     num_reg: 2      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 256M     num_reg: 2      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 512M     num_reg: 2      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 1G     num_reg: 2      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 2G     num_reg: 4      lose cover RAM: 56M
[    0.000000]  gran_size: 128M     chunk_size: 128M     num_reg: 3      lose cover RAM: 120M
[    0.000000]  gran_size: 128M     chunk_size: 256M     num_reg: 2      lose cover RAM: 120M
[    0.000000]  gran_size: 128M     chunk_size: 512M     num_reg: 2      lose cover RAM: 120M
[    0.000000]  gran_size: 128M     chunk_size: 1G     num_reg: 2      lose cover RAM: 120M
[    0.000000]  gran_size: 128M     chunk_size: 2G     num_reg: 3      lose cover RAM: 120M
[    0.000000]  gran_size: 256M     chunk_size: 256M     num_reg: 2      lose cover RAM: 248M
[    0.000000]  gran_size: 256M     chunk_size: 512M     num_reg: 2      lose cover RAM: 248M
[    0.000000]  gran_size: 256M     chunk_size: 1G     num_reg: 2      lose cover RAM: 248M
[    0.000000]  gran_size: 256M     chunk_size: 2G     num_reg: 2      lose cover RAM: 248M
[    0.000000]  gran_size: 512M     chunk_size: 512M     num_reg: 1      lose cover RAM: 504M
[    0.000000]  gran_size: 512M     chunk_size: 1G     num_reg: 1      lose cover RAM: 504M
[    0.000000]  gran_size: 512M     chunk_size: 2G     num_reg: 1      lose cover RAM: 504M
[    0.000000]  gran_size: 1G     chunk_size: 1G     num_reg: 0      lose cover RAM: 1016M
[    0.000000]  gran_size: 1G     chunk_size: 2G     num_reg: 0      lose cover RAM: 1016M
[    0.000000]  gran_size: 2G     chunk_size: 2G     num_reg: 0      lose cover RAM: 1016M
[    0.000000] Found optimal setting for mtrr clean up
[    0.000000] gran_size: 64K     chunk_size: 16M     num_reg: 2      lose RAM: 0G
[    0.000000] range0: 0000000000000000 - 0000000040000000
[    0.000000] Setting variable MTRR 0, base: 0GB, range: 1GB, type WB
[    0.000000] hole: 000000003f800000 - 0000000040000000
[    0.000000] Setting variable MTRR 1, base: 1016MB, range: 8MB, type UC
[    0.000000] kernel direct mapping tables up to 377fe000 @ 7000-d000
[    0.000000] ACPI: RSDP 000FBE60, 0014 (r0 ACPIAM)
[    0.000000] ACPI: RSDT 3F780000, 0034 (r1 A M I  OEMRSDT   9000811 MSFT       97)
[    0.000000] ACPI: FACP 3F780200, 0081 (r1 A M I  OEMFACP   9000811 MSFT       97)
[    0.000000] ACPI: DSDT 3F780400, 6109 (r1  A0979 A0979034       34 INTL 20060113)
[    0.000000] ACPI: FACS 3F790000, 0040
[    0.000000] ACPI: APIC 3F780390, 0068 (r1 A M I  OEMAPIC   9000811 MSFT       97)
[    0.000000] ACPI: OEMB 3F790040, 0046 (r1 A M I  AMI_OEM   9000811 MSFT       97)
[    0.000000] ACPI: MCFG 3F786510, 003C (r1 A M I  OEMMCFG   9000811 MSFT       97)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 127MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 00000000 - 377fe000
[    0.000000]   bootmap 00009000 - 0000ff00
[    0.000000] (6 early reservations) ==> bootmem [0000000000 - 00377fe000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
[    0.000000]   #1 [0000100000 - 000052a0cc]    TEXT DATA BSS ==> [0000100000 - 000052a0cc]
[    0.000000]   #2 [000052b000 - 000052e000]    INIT_PG_TABLE ==> [000052b000 - 000052e000]
[    0.000000]   #3 [000009fc00 - 0000100000]    BIOS reserved ==> [000009fc00 - 0000100000]
[    0.000000]   #4 [0000007000 - 0000009000]          PGTABLE ==> [0000007000 - 0000009000]
[    0.000000]   #5 [0000009000 - 0000010000]          BOOTMAP ==> [0000009000 - 0000010000]
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x000377fe
[    0.000000]   HighMem  0x000377fe -> 0x0003f780
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0003f780
[    0.000000] On node 0 totalpages: 259871
[    0.000000] free_area_init_node: node 0, pgdat c04738e0, node_mem_map c1000000
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3967 pages, LIFO batch:0
[    0.000000]   Normal zone: 1744 pages used for memmap
[    0.000000]   Normal zone: 221486 pages, LIFO batch:31
[    0.000000]   HighMem zone: 256 pages used for memmap
[    0.000000]   HighMem zone: 32386 pages, LIFO batch:7
[    0.000000]   Movable zone: 0 pages used for memmap
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Allocating PCI resources starting at 40000000 (gap: 3f800000:bf600000)
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 257839
[    0.000000] Kernel command line: root=/dev/sdb2 ro quiet
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 16384 bytes)
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 900.017 MHz processor.
[    0.000999] Console: colour VGA+ 80x25
[    0.000999] console [tty0] enabled
[    0.000999] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000999] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000999] Memory: 1025948k/1039872k available (2547k kernel code, 13236k reserved, 1019k data, 256k init, 130568k highmem)
[    0.000999] virtual kernel memory layout:
[    0.000999]     fixmap  : 0xfffac000 - 0xfffff000   ( 332 kB)
[    0.000999]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000999]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000999]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000999]       .init : 0xc047e000 - 0xc04be000   ( 256 kB)
[    0.000999]       .data : 0xc037cd2a - 0xc047bcec   (1019 kB)
[    0.000999]       .text : 0xc0100000 - 0xc037cd2a   (2547 kB)
[    0.000999] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000999] SLUB: Genslabs=12, HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.001012] Calibrating delay loop (skipped), value calculated using timer frequency.. 1800.03 BogoMIPS (lpj=900017)
[    0.001037] Security Framework initialized
[    0.001058] Mount-cache hash table entries: 512
[    0.001278] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.001283] CPU: L2 cache: 512K
[    0.001288] Intel machine check architecture supported.
[    0.001295] Intel machine check reporting enabled on CPU#0.
[    0.001307] CPU: Intel(R) Celeron(R) M processor          900MHz stepping 08
[    0.001319] Checking 'hlt' instruction... OK.
[    0.005613] Freeing SMP alternatives: 0k freed
[    0.005618] ACPI: Core revision 20080926
[    0.020780] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.031995] APIC calibration not consistent with PM Timer: 118ms instead of 100ms
[    0.031995] APIC delta adjusted to PM-Timer: 625064 (743715)
[    0.031995] net_namespace: 288 bytes
[    0.031995] NET: Registered protocol family 16
[    0.031995] ACPI: bus type pci registered
[    0.031995] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.031995] PCI: Not using MMCONFIG.
[    0.031995] PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=5
[    0.031995] PCI: Using configuration type 1 for base access
[    0.037034] ACPI: EC: Look up EC in DSDT
[    0.049273] ACPI: Interpreter enabled
[    0.049286] ACPI: (supports S0 S1 S3 S5)
[    0.049317] ACPI: Using IOAPIC for interrupt routing
[    0.049432] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.052772] PCI: MCFG area at e0000000 reserved in ACPI motherboard resources
[    0.052777] PCI: Using MMCONFIG for extended config space
[    0.063439] ACPI: EC: GPE = 0x18, I/O: command/status = 0x66, data = 0x62
[    0.063444] ACPI: EC: driver started in poll mode
[    0.063719] ACPI: No dock devices found.
[    0.063866] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.064042] pci 0000:00:02.0: reg 10 32bit mmio: [0xf7f00000-0xf7f7ffff]
[    0.064050] pci 0000:00:02.0: reg 14 io port: [0xec00-0xec07]
[    0.064058] pci 0000:00:02.0: reg 18 32bit mmio: [0xd0000000-0xdfffffff]
[    0.064065] pci 0000:00:02.0: reg 1c 32bit mmio: [0xf7ec0000-0xf7efffff]
[    0.064103] pci 0000:00:02.1: reg 10 32bit mmio: [0xf7f80000-0xf7ffffff]
[    0.064198] pci 0000:00:1b.0: reg 10 64bit mmio: [0xf7eb8000-0xf7ebbfff]
[    0.064233] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.064239] pci 0000:00:1b.0: PME# disabled
[    0.064291] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.064297] pci 0000:00:1c.0: PME# disabled
[    0.064351] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.064357] pci 0000:00:1c.1: PME# disabled
[    0.064410] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.064416] pci 0000:00:1c.2: PME# disabled
[    0.064470] pci 0000:00:1d.0: reg 20 io port: [0xe400-0xe41f]
[    0.064524] pci 0000:00:1d.1: reg 20 io port: [0xe480-0xe49f]
[    0.064577] pci 0000:00:1d.2: reg 20 io port: [0xe800-0xe81f]
[    0.064630] pci 0000:00:1d.3: reg 20 io port: [0xe880-0xe89f]
[    0.064688] pci 0000:00:1d.7: reg 10 32bit mmio: [0xf7eb7c00-0xf7eb7fff]
[    0.064732] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.064738] pci 0000:00:1d.7: PME# disabled
[    0.064863] pci 0000:00:1f.0: Force enabled HPET at 0xfed00000
[    0.064872] pci 0000:00:1f.0: quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
[    0.064879] pci 0000:00:1f.0: quirk: region 0480-04bf claimed by ICH6 GPIO
[    0.064913] pci 0000:00:1f.2: reg 10 io port: [0x00-0x07]
[    0.064921] pci 0000:00:1f.2: reg 14 io port: [0x00-0x03]
[    0.064929] pci 0000:00:1f.2: reg 18 io port: [0x00-0x07]
[    0.064937] pci 0000:00:1f.2: reg 1c io port: [0x00-0x03]
[    0.064945] pci 0000:00:1f.2: reg 20 io port: [0xffa0-0xffaf]
[    0.064966] pci 0000:00:1f.2: PME# supported from D3hot
[    0.064972] pci 0000:00:1f.2: PME# disabled
[    0.065029] pci 0000:00:1f.3: reg 20 io port: [0x400-0x41f]
[    0.065160] pci 0000:03:00.0: reg 10 64bit mmio: [0xfbfc0000-0xfbffffff]
[    0.065197] pci 0000:03:00.0: reg 30 32bit mmio: [0xfbfa0000-0xfbfbffff]
[    0.065212] pci 0000:03:00.0: PME# supported from D3hot D3cold
[    0.065219] pci 0000:03:00.0: PME# disabled
[    0.065275] pci 0000:00:1c.1: bridge 32bit mmio: [0xfbf00000-0xfbffffff]
[    0.065325] pci 0000:00:1c.2: bridge 32bit mmio: [0xf8000000-0xfbefffff]
[    0.065334] pci 0000:00:1c.2: bridge 64bit mmio pref: [0xf0000000-0xf6ffffff]
[    0.065387] pci 0000:00:1e.0: transparent bridge
[    0.065418] bus 00 -> node 0
[    0.065433] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.065916] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P3._PRT]
[    0.066123] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P5._PRT]
[    0.066312] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P6._PRT]
[    0.074280] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 *5 6 7 10 11 12 14 15)
[    0.074560] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[    0.074843] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    0.075142] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *7 10 11 12 14 15)
[    0.075415] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.075688] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.075959] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.076243] ACPI: PCI Interrupt Link [LNKH] (IRQs *3 4 5 6 7 10 11 12 14 15)
[    0.076867] SCSI subsystem initialized
[    0.076911] libata version 3.00 loaded.
[    0.077077] usbcore: registered new interface driver usbfs
[    0.077130] usbcore: registered new interface driver hub
[    0.077195] usbcore: registered new device driver usb
[    0.077482] PCI: Using ACPI for IRQ routing
[    0.077647] cfg80211: Using static regulatory domain info
[    0.077647] cfg80211: Regulatory domain: US
[    0.077647]     (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[    0.077647]     (2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, 2700 mBm)
[    0.077647]     (5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.077647]     (5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.077647]     (5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.077647]     (5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.077647]     (5735000 KHz - 5835000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
[    0.077647] cfg80211: Calling CRDA for country: US
[    0.078223] hpet clockevent registered
[    0.078229] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.078237] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.078245] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.080055] pnp: PnP ACPI init
[    0.080055] ACPI: bus type pnp registered
[    0.084320] pnp: PnP ACPI: found 13 devices
[    0.084325] ACPI: ACPI bus type pnp unregistered
[    0.084350] system 00:01: iomem range 0xfed13000-0xfed19fff has been reserved
[    0.084368] system 00:08: ioport range 0x380-0x383 has been reserved
[    0.084374] system 00:08: ioport range 0x4d0-0x4d1 has been reserved
[    0.084379] system 00:08: ioport range 0x800-0x87f has been reserved
[    0.084385] system 00:08: ioport range 0x480-0x4bf has been reserved
[    0.084390] system 00:08: iomem range 0xfed1c000-0xfed1ffff has been reserved
[    0.084396] system 00:08: iomem range 0xfed20000-0xfed8ffff has been reserved
[    0.084402] system 00:08: iomem range 0xfff00000-0xffffffff could not be reserved
[    0.084412] system 00:09: iomem range 0xfec00000-0xfec00fff has been reserved
[    0.084417] system 00:09: iomem range 0xfee00000-0xfee00fff has been reserved
[    0.084429] system 00:0a: iomem range 0xe0000000-0xefffffff has been reserved
[    0.084438] system 00:0b: iomem range 0xe0000000-0xefffffff has been reserved
[    0.084456] system 00:0c: iomem range 0x0-0x9ffff could not be reserved
[    0.084462] system 00:0c: iomem range 0xe0000-0xfffff could not be reserved
[    0.084467] system 00:0c: iomem range 0x100000-0x3f7fffff could not be reserved
[    0.119725] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:04
[    0.119730] pci 0000:00:1c.0:   IO window: disabled
[    0.119737] pci 0000:00:1c.0:   MEM window: disabled
[    0.119743] pci 0000:00:1c.0:   PREFETCH window: disabled
[    0.119751] pci 0000:00:1c.1: PCI bridge, secondary bus 0000:03
[    0.119755] pci 0000:00:1c.1:   IO window: disabled
[    0.119762] pci 0000:00:1c.1:   MEM window: 0xfbf00000-0xfbffffff
[    0.119768] pci 0000:00:1c.1:   PREFETCH window: disabled
[    0.119776] pci 0000:00:1c.2: PCI bridge, secondary bus 0000:01
[    0.119779] pci 0000:00:1c.2:   IO window: disabled
[    0.119786] pci 0000:00:1c.2:   MEM window: 0xf8000000-0xfbefffff
[    0.119793] pci 0000:00:1c.2:   PREFETCH window: 0x000000f0000000-0x000000f6ffffff
[    0.119802] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:05
[    0.119806] pci 0000:00:1e.0:   IO window: disabled
[    0.119812] pci 0000:00:1e.0:   MEM window: disabled
[    0.119817] pci 0000:00:1e.0:   PREFETCH window: disabled
[    0.119843] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.119850] pci 0000:00:1c.0: setting latency timer to 64
[    0.119861] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    0.119867] pci 0000:00:1c.1: setting latency timer to 64
[    0.119878] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    0.119884] pci 0000:00:1c.2: setting latency timer to 64
[    0.119893] pci 0000:00:1e.0: setting latency timer to 64
[    0.119899] bus: 00 index 0 io port: [0x00-0xffff]
[    0.119903] bus: 00 index 1 mmio: [0x000000-0xffffffff]
[    0.119907] bus: 04 index 0 mmio: [0x0-0x0]
[    0.119911] bus: 04 index 1 mmio: [0x0-0x0]
[    0.119914] bus: 04 index 2 mmio: [0x0-0x0]
[    0.119917] bus: 04 index 3 mmio: [0x0-0x0]
[    0.119921] bus: 03 index 0 mmio: [0x0-0x0]
[    0.119925] bus: 03 index 1 mmio: [0xfbf00000-0xfbffffff]
[    0.119928] bus: 03 index 2 mmio: [0x0-0x0]
[    0.119932] bus: 03 index 3 mmio: [0x0-0x0]
[    0.119935] bus: 01 index 0 mmio: [0x0-0x0]
[    0.119939] bus: 01 index 1 mmio: [0xf8000000-0xfbefffff]
[    0.119943] bus: 01 index 2 mmio: [0xf0000000-0xf6ffffff]
[    0.119947] bus: 01 index 3 mmio: [0x0-0x0]
[    0.119951] bus: 05 index 0 mmio: [0x0-0x0]
[    0.119954] bus: 05 index 1 mmio: [0x0-0x0]
[    0.119957] bus: 05 index 2 mmio: [0x0-0x0]
[    0.119961] bus: 05 index 3 io port: [0x00-0xffff]
[    0.119965] bus: 05 index 4 mmio: [0x000000-0xffffffff]
[    0.119981] NET: Registered protocol family 2
[    0.120086] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.120222] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.121909] TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
[    0.122409] TCP: Hash tables configured (established 131072 bind 65536)
[    0.122416] TCP reno registered
[    0.122533] NET: Registered protocol family 1
[    0.122827] Machine check exception polling timer started.
[    0.123331] Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.123384] alg: cipher: Test 1 failed on encryption for aes-asm
[    0.123450] 00000000: 00 01 02 03 04 05 06 07 08 08 08 08 08 08 08 08 
[    0.123827] highmem bounce pool size: 64 pages
[    0.123944] fuse init (API version 7.10)
[    0.124055] msgmni has been set to 1749
[    0.124317] alg: No test for stdrng (krng)
[    0.124336] io scheduler noop registered
[    0.124340] io scheduler deadline registered (default)
[    0.124357] pci 0000:00:02.0: Boot video device
[    0.127406] pcieport-driver 0000:00:1c.0: setting latency timer to 64
[    0.127447] pcieport-driver 0000:00:1c.0: found MSI capability
[    0.127479] pcieport-driver 0000:00:1c.0: irq 287 for MSI/MSI-X
[    0.127495] pci_express 0000:00:1c.0:pcie00: allocate port service
[    0.127554] pci_express 0000:00:1c.0:pcie02: allocate port service
[    0.127610] pci_express 0000:00:1c.0:pcie03: allocate port service
[    0.127716] pcieport-driver 0000:00:1c.1: setting latency timer to 64
[    0.127754] pcieport-driver 0000:00:1c.1: found MSI capability
[    0.127781] pcieport-driver 0000:00:1c.1: irq 286 for MSI/MSI-X
[    0.127796] pci_express 0000:00:1c.1:pcie00: allocate port service
[    0.127851] pci_express 0000:00:1c.1:pcie02: allocate port service
[    0.127904] pci_express 0000:00:1c.1:pcie03: allocate port service
[    0.128016] pcieport-driver 0000:00:1c.2: setting latency timer to 64
[    0.128054] pcieport-driver 0000:00:1c.2: found MSI capability
[    0.128081] pcieport-driver 0000:00:1c.2: irq 285 for MSI/MSI-X
[    0.128097] pci_express 0000:00:1c.2:pcie00: allocate port service
[    0.128151] pci_express 0000:00:1c.2:pcie02: allocate port service
[    0.128203] pci_express 0000:00:1c.2:pcie03: allocate port service
[    0.128593] ACPI: AC Adapter [AC0] (on-line)
[    0.130238] ACPI: EC: non-query interrupt received, switching to interrupt mode
[    0.538246] ACPI: Battery Slot [BAT0] (battery present)
[    0.538795] input: Power Button (FF) as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.538801] ACPI: Power Button (FF) [PWRF]
[    0.538946] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input1
[    0.554684] ACPI: Lid Switch [LID]
[    0.554823] input: Sleep Button (CM) as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input2
[    0.554829] ACPI: Sleep Button (CM) [SLPB]
[    0.554946] input: Power Button (CM) as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input3
[    0.554952] ACPI: Power Button (CM) [PWRB]
[    0.555830] ACPI: CPU0 (power states: C1[C1] C2[C2] C3[C3])
[    0.555908] processor ACPI_CPU:00: registered as cooling_device0
[    0.555916] ACPI: Processor [CPU1] (supports 8 throttling states)
[    0.579784] Switched to high resolution mode on CPU 0
[    0.580239] thermal LNXTHERM:01: registered as thermal_zone0
[    0.727577] ACPI: Thermal Zone [TZ00] (53 C)
[    0.732262] Non-volatile memory driver v1.2
[    0.732268] Linux agpgart interface v0.103
[    0.732294] agpgart-intel 0000:00:00.0: Intel 915GM Chipset
[    0.732586] agpgart-intel 0000:00:00.0: detected 7932K stolen memory
[    0.736088] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    0.736215] [drm] Initialized drm 1.1.0 20060810
[    0.736250] pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.736258] pci 0000:00:02.0: setting latency timer to 64
[    0.736330] [drm:i915_gem_detect_bit_6_swizzle] *ERROR* Couldn't read from MCHBAR.  Disabling tiling.
[    0.736533] [drm] Initialized i915 1.6.0 20080730 on minor 0
[    0.737601] loop: module loaded
[    0.737640] eeepc: Eee PC Hotkey Driver
[    0.737890] eeepc: Hotkey init flags 0x41
[    0.739190] eeepc: Get control methods supported: 0x101711
[    0.739323] input: Asus EeePC extra buttons as /devices/virtual/input/input4
[    1.845041] Atheros(R) L2 Ethernet Driver - version 2.2.3
[    1.845046] Copyright (c) 2007 Atheros Corporation.
[    1.845076] atl2 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    1.845090] atl2 0000:03:00.0: setting latency timer to 64
[    1.884285] Linux video capture interface: v2.00
[    1.884485] usbcore: registered new interface driver uvcvideo
[    1.884493] USB Video Class driver (v0.1.0)
[    1.884540] Driver 'sd' needs updating - please use bus_type methods
[    1.884610] ata_piix 0000:00:1f.2: version 2.12
[    1.884631] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    1.884638] ata_piix 0000:00:1f.2: MAP [ P0 P2 IDE IDE ]
[    1.884693] ata_piix 0000:00:1f.2: setting latency timer to 64
[    1.884767] scsi0 : ata_piix
[    1.884935] scsi1 : ata_piix
[    1.888172] ata1: SATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
[    1.888178] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
[    2.206363] ata2.00: ATA-5: ASUS-PHISON OB SSD, TST2.04P, max UDMA/66
[    2.206368] ata2.00: 7880544 sectors, multi 0: LBA 
[    2.206441] ata2.01: ATA-5: ASUS-PHISON SSD, TST2.04P, max UDMA/66
[    2.206446] ata2.01: 31522176 sectors, multi 0: LBA 
[    2.209340] ata2.00: configured for UDMA/66
[    2.212333] ata2.01: configured for UDMA/66
[    2.212488] scsi 1:0:0:0: Direct-Access     ATA      ASUS-PHISON OB S TST2 PQ: 0 ANSI: 5
[    2.212798] sd 1:0:0:0: [sda] 7880544 512-byte hardware sectors: (4.03 GB/3.75 GiB)
[    2.212822] sd 1:0:0:0: [sda] Write Protect is off
[    2.212827] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.212860] sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    2.212953] sd 1:0:0:0: [sda] 7880544 512-byte hardware sectors: (4.03 GB/3.75 GiB)
[    2.212972] sd 1:0:0:0: [sda] Write Protect is off
[    2.212977] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.213017] sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    2.213023]  sda: sda1 sda2 sda3 sda4
[    2.214472] sd 1:0:0:0: [sda] Attached SCSI disk
[    2.214659] scsi 1:0:1:0: Direct-Access     ATA      ASUS-PHISON SSD  TST2 PQ: 0 ANSI: 5
[    2.214902] sd 1:0:1:0: [sdb] 31522176 512-byte hardware sectors: (16.1 GB/15.0 GiB)
[    2.214924] sd 1:0:1:0: [sdb] Write Protect is off
[    2.214929] sd 1:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    2.214961] sd 1:0:1:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    2.215063] sd 1:0:1:0: [sdb] 31522176 512-byte hardware sectors: (16.1 GB/15.0 GiB)
[    2.215083] sd 1:0:1:0: [sdb] Write Protect is off
[    2.215087] sd 1:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    2.215119] sd 1:0:1:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    2.215125]  sdb: sdb1 sdb2
[    2.216748] sd 1:0:1:0: [sdb] Attached SCSI disk
[    2.216863] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.216904] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    2.216931] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    2.216939] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    2.217049] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    2.220964] ehci_hcd 0000:00:1d.7: debug port 1
[    2.220974] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
[    2.220992] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xf7eb7c00
[    2.230011] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    2.230191] usb usb1: configuration #1 chosen from 1 choice
[    2.230275] hub 1-0:1.0: USB hub found
[    2.230289] hub 1-0:1.0: 8 ports detected
[    2.230606] uhci_hcd: USB Universal Host Controller Interface driver
[    2.230638] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    2.230648] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    2.230654] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    2.230723] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    2.230753] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000e400
[    2.230922] usb usb2: configuration #1 chosen from 1 choice
[    2.231014] hub 2-0:1.0: USB hub found
[    2.231027] hub 2-0:1.0: 2 ports detected
[    2.231254] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    2.231266] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    2.231271] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    2.231347] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    2.231383] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000e480
[    2.231554] usb usb3: configuration #1 chosen from 1 choice
[    2.231642] hub 3-0:1.0: USB hub found
[    2.231655] hub 3-0:1.0: 2 ports detected
[    2.231890] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    2.231900] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    2.231906] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    2.231975] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    2.232024] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000e800
[    2.232200] usb usb4: configuration #1 chosen from 1 choice
[    2.232281] hub 4-0:1.0: USB hub found
[    2.232295] hub 4-0:1.0: 2 ports detected
[    2.232518] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 16 (level, low) -> IRQ 16
[    2.232529] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    2.232534] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    2.232620] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    2.232656] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000e880
[    2.232839] usb usb5: configuration #1 chosen from 1 choice
[    2.232922] hub 5-0:1.0: USB hub found
[    2.232934] hub 5-0:1.0: 2 ports detected
[    2.233243] Initializing USB Mass Storage driver...
[    2.233332] usbcore: registered new interface driver usb-storage
[    2.233338] USB Mass Storage support registered.
[    2.233500] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    2.265245] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.265252] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.265519] mice: PS/2 mouse device common for all mice
[    2.267665] rtc_cmos 00:03: RTC can wake from S4
[    2.267777] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    2.267806] rtc0: alarms up to one month, 114 bytes nvram, hpet irqs
[    2.268048] cpuidle: using governor ladder
[    2.268363] cpuidle: using governor menu
[    2.268430] Advanced Linux Sound Architecture Driver Version 1.0.18rc3.
[    2.268562] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    2.268602] HDA Intel 0000:00:1b.0: setting latency timer to 64
[    2.270059] Marking TSC unstable due to TSC halts in idle
[    2.270810] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input5
[    2.275922] hda_codec: Unknown model for ALC662, trying auto-probe from BIOS...
[    2.300792] ALSA device list:
[    2.300796]   #0: HDA Intel at 0xf7eb8000 irq 16
[    2.300838] TCP cubic registered
[    2.300842] NET: Registered protocol family 17
[    2.300903] Using IPI Shortcut mode
[    2.301333] rtc_cmos 00:03: setting system clock to
[    2.533380] usb 1-5: new high speed USB device using ehci_hcd and address 2
[    2.578015] Clocksource tsc unstable (delta = -241546938 ns)
[    2.648201] usb 1-5: configuration #1 chosen from 1 choice
[    2.648462] scsi2 : SCSI emulation for USB Mass Storage devices
[    2.648708] usb-storage: device found at 2
[    2.648712] usb-storage: waiting for device to settle before scanning
[    4.341225] input: ImPS/2 Logitech Wheel Mouse as /devices/platform/i8042/serio1/input/input6
[    4.425425] kjournald starting.  Commit interval 5 seconds
[    4.425440] EXT3-fs: mounted filesystem with ordered data mode.
[    4.425456] VFS: Mounted root (ext3 filesystem) readonly.
[    4.425657] Freeing unused kernel memory: 256k freed
[    4.425728] Write protecting the kernel text: 2548k
[    4.425760] Write protecting the kernel read-only data: 696k
[    6.536135] EXT3 FS on sdb2, internal journal
[    7.651957] usb-storage: device scan complete
[    7.653307] scsi 2:0:0:0: Direct-Access     USB2.0   CardReader SD0   0100 PQ: 0 ANSI: 0
[    8.155243] sd 2:0:0:0: [sdc] 15661056 512-byte hardware sectors: (8.01 GB/7.46 GiB)
[    8.157431] sd 2:0:0:0: [sdc] Write Protect is on
[    8.157439] sd 2:0:0:0: [sdc] Mode Sense: 03 00 80 00
[    8.157444] sd 2:0:0:0: [sdc] Assuming drive cache: write through
[    8.161076] sd 2:0:0:0: [sdc] 15661056 512-byte hardware sectors: (8.01 GB/7.46 GiB)
[    8.161567] sd 2:0:0:0: [sdc] Write Protect is on
[    8.161572] sd 2:0:0:0: [sdc] Mode Sense: 03 00 80 00
[    8.161577] sd 2:0:0:0: [sdc] Assuming drive cache: write through
[    8.161679]  sdc: sdc1 sdc2
[    8.164667] sd 2:0:0:0: [sdc] Attached SCSI removable disk
[   15.863141] warning: `avahi-daemon' uses 32-bit capabilities (legacy support in use)
[   17.190531] atl2 0000:03:00.0: irq 284 for MSI/MSI-X
[   17.395866] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[   44.086026] kjournald starting.  Commit interval 5 seconds
[   44.086045] EXT3-fs: mounted filesystem with ordered data mode.
[  147.704041] ------------[ cut here ]------------
[  147.704050] WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x19f/0x1b0()
[  147.704054] NETDEV WATCHDOG: eth0 (atl2): transmit timed out
[  147.704060] Pid: 0, comm: swapper Not tainted 2.6.28 #3
[  147.704064] Call Trace:
[  147.704074]  [<c011f8f1>] warn_slowpath+0x71/0x90
[  147.704082]  [<c0280030>] __video_ioctl2+0x20d0/0x3a50
[  147.704090]  [<c028f2c1>] scsi_init_io+0x11/0xa0
[  147.704095]  [<c0297687>] sd_prep_fn+0x67/0x440
[  147.704102]  [<c02cfef8>] mousedev_notify_readers+0x1e8/0x1f0
[  147.704109]  [<c01140aa>] read_hpet+0xa/0x10
[  147.704115]  [<c0134b47>] getnstimeofday+0x37/0xf0
[  147.704122]  [<c01f8ca0>] strlcpy+0x20/0x60
[  147.704128]  [<c03183d0>] dev_watchdog+0x0/0x1b0
[  147.704134]  [<c031856f>] dev_watchdog+0x19f/0x1b0
[  147.704140]  [<c01389e2>] tick_dev_program_event+0x32/0xa0
[  147.704147]  [<c0126d8c>] cascade+0x5c/0x70
[  147.704152]  [<c0126faf>] run_timer_softirq+0x10f/0x160
[  147.704159]  [<c0123884>] __do_softirq+0x54/0x100
[  147.704165]  [<c0105db0>] timer_interrupt+0x20/0x30
[  147.704171]  [<c013d025>] handle_IRQ_event+0x25/0x60
[  147.704177]  [<c0123957>] do_softirq+0x27/0x30
[  147.704182]  [<c0123be5>] irq_exit+0x45/0x70
[  147.704187]  [<c0105455>] do_IRQ+0x75/0x90
[  147.704192]  [<c01140aa>] read_hpet+0xa/0x10
[  147.704197]  [<c0134b47>] getnstimeofday+0x37/0xf0
[  147.704203]  [<c0103ca7>] common_interrupt+0x23/0x28
[  147.704211]  [<c022bde0>] acpi_idle_enter_bm+0x1ae/0x1df
[  147.704217]  [<c02dab25>] cpuidle_idle_call+0x65/0xb0
[  147.704222]  [<c0101dd5>] cpu_idle+0x35/0x70
[  147.704226] ---[ end trace 85eaaddc85a953b7 ]---
[  147.710616] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>


[    0.000000] BIOS EBDA/lowmem at: 0009fc00/0009fc00
[    0.000000] Linux version 2.6.28 (sw612@verona) (gcc version 4.2.4) #3
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003f780000 (usable)
[    0.000000]  BIOS-e820: 000000003f780000 - 000000003f790000 (ACPI data)
[    0.000000]  BIOS-e820: 000000003f790000 - 000000003f7d0000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000003f7d0000 - 000000003f7de000 (reserved)
[    0.000000]  BIOS-e820: 000000003f7e0000 - 000000003f800000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
[    0.000000] DMI present.
[    0.000000] last_pfn = 0x3f780 max_arch_pfn = 0x100000
[    0.000000] original variable MTRRs
[    0.000000] reg 0, base: 0GB, range: 1GB, type WB
[    0.000000] reg 1, base: 1016MB, range: 8MB, type UC
[    0.000000] total RAM coverred: 1016M
[    0.000000]  gran_size: 64K     chunk_size: 64K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 128K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 256K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 512K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 64K     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 128K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 256K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 512K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 128K     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 256K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 512K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 256K     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 512K     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 512K     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 1M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 1M     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 2M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 2M     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 4M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 4M     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 8M     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 16M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 32M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 64M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 128M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 256M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 512M     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 1G     num_reg: 2      lose cover RAM: 0G
[    0.000000]  gran_size: 8M     chunk_size: 2G     num_reg: 7      lose cover RAM: 0G
[    0.000000]  gran_size: 16M     chunk_size: 16M     num_reg: 6      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 32M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 64M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 128M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 256M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 512M     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 1G     num_reg: 2      lose cover RAM: 8M
[    0.000000]  gran_size: 16M     chunk_size: 2G     num_reg: 6      lose cover RAM: 8M
[    0.000000]  gran_size: 32M     chunk_size: 32M     num_reg: 5      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 64M     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 128M     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 256M     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 512M     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 1G     num_reg: 2      lose cover RAM: 24M
[    0.000000]  gran_size: 32M     chunk_size: 2G     num_reg: 5      lose cover RAM: 24M
[    0.000000]  gran_size: 64M     chunk_size: 64M     num_reg: 4      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 128M     num_reg: 2      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 256M     num_reg: 2      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 512M     num_reg: 2      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 1G     num_reg: 2      lose cover RAM: 56M
[    0.000000]  gran_size: 64M     chunk_size: 2G     num_reg: 4      lose cover RAM: 56M
[    0.000000]  gran_size: 128M     chunk_size: 128M     num_reg: 3      lose cover RAM: 120M
[    0.000000]  gran_size: 128M     chunk_size: 256M     num_reg: 2      lose cover RAM: 120M
[    0.000000]  gran_size: 128M     chunk_size: 512M     num_reg: 2      lose cover RAM: 120M
[    0.000000]  gran_size: 128M     chunk_size: 1G     num_reg: 2      lose cover RAM: 120M
[    0.000000]  gran_size: 128M     chunk_size: 2G     num_reg: 3      lose cover RAM: 120M
[    0.000000]  gran_size: 256M     chunk_size: 256M     num_reg: 2      lose cover RAM: 248M
[    0.000000]  gran_size: 256M     chunk_size: 512M     num_reg: 2      lose cover RAM: 248M
[    0.000000]  gran_size: 256M     chunk_size: 1G     num_reg: 2      lose cover RAM: 248M
[    0.000000]  gran_size: 256M     chunk_size: 2G     num_reg: 2      lose cover RAM: 248M
[    0.000000]  gran_size: 512M     chunk_size: 512M     num_reg: 1      lose cover RAM: 504M
[    0.000000]  gran_size: 512M     chunk_size: 1G     num_reg: 1      lose cover RAM: 504M
[    0.000000]  gran_size: 512M     chunk_size: 2G     num_reg: 1      lose cover RAM: 504M
[    0.000000]  gran_size: 1G     chunk_size: 1G     num_reg: 0      lose cover RAM: 1016M
[    0.000000]  gran_size: 1G     chunk_size: 2G     num_reg: 0      lose cover RAM: 1016M
[    0.000000]  gran_size: 2G     chunk_size: 2G     num_reg: 0      lose cover RAM: 1016M
[    0.000000] Found optimal setting for mtrr clean up
[    0.000000] gran_size: 64K     chunk_size: 16M     num_reg: 2      lose RAM: 0G
[    0.000000] range0: 0000000000000000 - 0000000040000000
[    0.000000] Setting variable MTRR 0, base: 0GB, range: 1GB, type WB
[    0.000000] hole: 000000003f800000 - 0000000040000000
[    0.000000] Setting variable MTRR 1, base: 1016MB, range: 8MB, type UC
[    0.000000] kernel direct mapping tables up to 377fe000 @ 7000-d000
[    0.000000] ACPI: RSDP 000FBE60, 0014 (r0 ACPIAM)
[    0.000000] ACPI: RSDT 3F780000, 0034 (r1 A M I  OEMRSDT   9000811 MSFT       97)
[    0.000000] ACPI: FACP 3F780200, 0081 (r1 A M I  OEMFACP   9000811 MSFT       97)
[    0.000000] ACPI: DSDT 3F780400, 6109 (r1  A0979 A0979034       34 INTL 20060113)
[    0.000000] ACPI: FACS 3F790000, 0040
[    0.000000] ACPI: APIC 3F780390, 0068 (r1 A M I  OEMAPIC   9000811 MSFT       97)
[    0.000000] ACPI: OEMB 3F790040, 0046 (r1 A M I  AMI_OEM   9000811 MSFT       97)
[    0.000000] ACPI: MCFG 3F786510, 003C (r1 A M I  OEMMCFG   9000811 MSFT       97)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 127MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 00000000 - 377fe000
[    0.000000]   bootmap 00009000 - 0000ff00
[    0.000000] (6 early reservations) ==> bootmem [0000000000 - 00377fe000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
[    0.000000]   #1 [0000100000 - 000052a0cc]    TEXT DATA BSS ==> [0000100000 - 000052a0cc]
[    0.000000]   #2 [000052b000 - 000052e000]    INIT_PG_TABLE ==> [000052b000 - 000052e000]
[    0.000000]   #3 [000009fc00 - 0000100000]    BIOS reserved ==> [000009fc00 - 0000100000]
[    0.000000]   #4 [0000007000 - 0000009000]          PGTABLE ==> [0000007000 - 0000009000]
[    0.000000]   #5 [0000009000 - 0000010000]          BOOTMAP ==> [0000009000 - 0000010000]
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x000377fe
[    0.000000]   HighMem  0x000377fe -> 0x0003f780
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0003f780
[    0.000000] On node 0 totalpages: 259871
[    0.000000] free_area_init_node: node 0, pgdat c04738e0, node_mem_map c1000000
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3967 pages, LIFO batch:0
[    0.000000]   Normal zone: 1744 pages used for memmap
[    0.000000]   Normal zone: 221486 pages, LIFO batch:31
[    0.000000]   HighMem zone: 256 pages used for memmap
[    0.000000]   HighMem zone: 32386 pages, LIFO batch:7
[    0.000000]   Movable zone: 0 pages used for memmap
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Allocating PCI resources starting at 40000000 (gap: 3f800000:bf600000)
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 257839
[    0.000000] Kernel command line: root=/dev/sdb2 ro quiet
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 16384 bytes)
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 900.109 MHz processor.
[    0.000999] Console: colour VGA+ 80x25
[    0.000999] console [tty0] enabled
[    0.000999] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000999] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000999] Memory: 1025948k/1039872k available (2547k kernel code, 13236k reserved, 1019k data, 256k init, 130568k highmem)
[    0.000999] virtual kernel memory layout:
[    0.000999]     fixmap  : 0xfffac000 - 0xfffff000   ( 332 kB)
[    0.000999]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000999]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000999]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000999]       .init : 0xc047e000 - 0xc04be000   ( 256 kB)
[    0.000999]       .data : 0xc037cd2a - 0xc047bcec   (1019 kB)
[    0.000999]       .text : 0xc0100000 - 0xc037cd2a   (2547 kB)
[    0.000999] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000999] SLUB: Genslabs=12, HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.001014] Calibrating delay loop (skipped), value calculated using timer frequency.. 1800.21 BogoMIPS (lpj=900109)
[    0.001038] Security Framework initialized
[    0.001059] Mount-cache hash table entries: 512
[    0.001280] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.001285] CPU: L2 cache: 512K
[    0.001289] Intel machine check architecture supported.
[    0.001297] Intel machine check reporting enabled on CPU#0.
[    0.001309] CPU: Intel(R) Celeron(R) M processor          900MHz stepping 08
[    0.001320] Checking 'hlt' instruction... OK.
[    0.005637] Freeing SMP alternatives: 0k freed
[    0.005641] ACPI: Core revision 20080926
[    0.021245] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.031995] net_namespace: 288 bytes
[    0.031995] NET: Registered protocol family 16
[    0.031995] ACPI: bus type pci registered
[    0.031995] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.031995] PCI: Not using MMCONFIG.
[    0.031995] PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=5
[    0.031995] PCI: Using configuration type 1 for base access
[    0.037011] ACPI: EC: Look up EC in DSDT
[    0.048819] ACPI: Interpreter enabled
[    0.048834] ACPI: (supports S0 S1 S3 S5)
[    0.048865] ACPI: Using IOAPIC for interrupt routing
[    0.048982] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.052330] PCI: MCFG area at e0000000 reserved in ACPI motherboard resources
[    0.052335] PCI: Using MMCONFIG for extended config space
[    0.062957] ACPI: EC: GPE = 0x18, I/O: command/status = 0x66, data = 0x62
[    0.062963] ACPI: EC: driver started in poll mode
[    0.063250] ACPI: No dock devices found.
[    0.063397] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.063552] pci 0000:00:02.0: reg 10 32bit mmio: [0xf7f00000-0xf7f7ffff]
[    0.063560] pci 0000:00:02.0: reg 14 io port: [0xec00-0xec07]
[    0.063567] pci 0000:00:02.0: reg 18 32bit mmio: [0xd0000000-0xdfffffff]
[    0.063575] pci 0000:00:02.0: reg 1c 32bit mmio: [0xf7ec0000-0xf7efffff]
[    0.063613] pci 0000:00:02.1: reg 10 32bit mmio: [0xf7f80000-0xf7ffffff]
[    0.063708] pci 0000:00:1b.0: reg 10 64bit mmio: [0xf7eb8000-0xf7ebbfff]
[    0.063743] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.063751] pci 0000:00:1b.0: PME# disabled
[    0.063803] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.063809] pci 0000:00:1c.0: PME# disabled
[    0.063863] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.063869] pci 0000:00:1c.1: PME# disabled
[    0.063922] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.063928] pci 0000:00:1c.2: PME# disabled
[    0.063982] pci 0000:00:1d.0: reg 20 io port: [0xe400-0xe41f]
[    0.064043] pci 0000:00:1d.1: reg 20 io port: [0xe480-0xe49f]
[    0.064097] pci 0000:00:1d.2: reg 20 io port: [0xe800-0xe81f]
[    0.064151] pci 0000:00:1d.3: reg 20 io port: [0xe880-0xe89f]
[    0.064211] pci 0000:00:1d.7: reg 10 32bit mmio: [0xf7eb7c00-0xf7eb7fff]
[    0.064254] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.064261] pci 0000:00:1d.7: PME# disabled
[    0.064386] pci 0000:00:1f.0: Force enabled HPET at 0xfed00000
[    0.064398] pci 0000:00:1f.0: quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
[    0.064404] pci 0000:00:1f.0: quirk: region 0480-04bf claimed by ICH6 GPIO
[    0.064437] pci 0000:00:1f.2: reg 10 io port: [0x00-0x07]
[    0.064445] pci 0000:00:1f.2: reg 14 io port: [0x00-0x03]
[    0.064453] pci 0000:00:1f.2: reg 18 io port: [0x00-0x07]
[    0.064461] pci 0000:00:1f.2: reg 1c io port: [0x00-0x03]
[    0.064470] pci 0000:00:1f.2: reg 20 io port: [0xffa0-0xffaf]
[    0.064491] pci 0000:00:1f.2: PME# supported from D3hot
[    0.064496] pci 0000:00:1f.2: PME# disabled
[    0.064547] pci 0000:00:1f.3: reg 20 io port: [0x400-0x41f]
[    0.064681] pci 0000:03:00.0: reg 10 64bit mmio: [0xfbfc0000-0xfbffffff]
[    0.064719] pci 0000:03:00.0: reg 30 32bit mmio: [0xfbfa0000-0xfbfbffff]
[    0.064734] pci 0000:03:00.0: PME# supported from D3hot D3cold
[    0.064741] pci 0000:03:00.0: PME# disabled
[    0.064795] pci 0000:00:1c.1: bridge 32bit mmio: [0xfbf00000-0xfbffffff]
[    0.064859] pci 0000:01:00.0: reg 10 64bit mmio: [0xfbef0000-0xfbefffff]
[    0.064961] pci 0000:00:1c.2: bridge 32bit mmio: [0xf8000000-0xfbefffff]
[    0.064970] pci 0000:00:1c.2: bridge 64bit mmio pref: [0xf0000000-0xf6ffffff]
[    0.065052] pci 0000:00:1e.0: transparent bridge
[    0.065084] bus 00 -> node 0
[    0.065099] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.065584] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P3._PRT]
[    0.065782] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P5._PRT]
[    0.065973] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P6._PRT]
[    0.074012] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 *5 6 7 10 11 12 14 15)
[    0.074295] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[    0.074568] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    0.074838] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *7 10 11 12 14 15)
[    0.075119] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.075391] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.075664] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.075935] ACPI: PCI Interrupt Link [LNKH] (IRQs *3 4 5 6 7 10 11 12 14 15)
[    0.076565] SCSI subsystem initialized
[    0.076609] libata version 3.00 loaded.
[    0.076761] usbcore: registered new interface driver usbfs
[    0.076816] usbcore: registered new interface driver hub
[    0.076880] usbcore: registered new device driver usb
[    0.077179] PCI: Using ACPI for IRQ routing
[    0.077344] cfg80211: Using static regulatory domain info
[    0.077344] cfg80211: Regulatory domain: US
[    0.077344]     (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[    0.077344]     (2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, 2700 mBm)
[    0.077344]     (5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.077344]     (5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.077344]     (5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.077344]     (5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.077344]     (5735000 KHz - 5835000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
[    0.077344] cfg80211: Calling CRDA for country: US
[    0.077424] hpet clockevent registered
[    0.077430] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.077438] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.077446] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.079054] pnp: PnP ACPI init
[    0.079054] ACPI: bus type pnp registered
[    0.083291] pnp: PnP ACPI: found 13 devices
[    0.083295] ACPI: ACPI bus type pnp unregistered
[    0.083320] system 00:01: iomem range 0xfed13000-0xfed19fff has been reserved
[    0.083338] system 00:08: ioport range 0x380-0x383 has been reserved
[    0.083343] system 00:08: ioport range 0x4d0-0x4d1 has been reserved
[    0.083348] system 00:08: ioport range 0x800-0x87f has been reserved
[    0.083354] system 00:08: ioport range 0x480-0x4bf has been reserved
[    0.083360] system 00:08: iomem range 0xfed1c000-0xfed1ffff has been reserved
[    0.083365] system 00:08: iomem range 0xfed20000-0xfed8ffff has been reserved
[    0.083379] system 00:08: iomem range 0xfff00000-0xffffffff could not be reserved
[    0.083389] system 00:09: iomem range 0xfec00000-0xfec00fff has been reserved
[    0.083394] system 00:09: iomem range 0xfee00000-0xfee00fff has been reserved
[    0.083404] system 00:0a: iomem range 0xe0000000-0xefffffff has been reserved
[    0.083414] system 00:0b: iomem range 0xe0000000-0xefffffff has been reserved
[    0.083424] system 00:0c: iomem range 0x0-0x9ffff could not be reserved
[    0.083430] system 00:0c: iomem range 0xe0000-0xfffff could not be reserved
[    0.083435] system 00:0c: iomem range 0x100000-0x3f7fffff could not be reserved
[    0.118712] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:04
[    0.118716] pci 0000:00:1c.0:   IO window: disabled
[    0.118724] pci 0000:00:1c.0:   MEM window: disabled
[    0.118729] pci 0000:00:1c.0:   PREFETCH window: disabled
[    0.118737] pci 0000:00:1c.1: PCI bridge, secondary bus 0000:03
[    0.118741] pci 0000:00:1c.1:   IO window: disabled
[    0.118748] pci 0000:00:1c.1:   MEM window: 0xfbf00000-0xfbffffff
[    0.118754] pci 0000:00:1c.1:   PREFETCH window: disabled
[    0.118762] pci 0000:00:1c.2: PCI bridge, secondary bus 0000:01
[    0.118766] pci 0000:00:1c.2:   IO window: disabled
[    0.118773] pci 0000:00:1c.2:   MEM window: 0xf8000000-0xfbefffff
[    0.118779] pci 0000:00:1c.2:   PREFETCH window: 0x000000f0000000-0x000000f6ffffff
[    0.118788] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:05
[    0.118792] pci 0000:00:1e.0:   IO window: disabled
[    0.118798] pci 0000:00:1e.0:   MEM window: disabled
[    0.118804] pci 0000:00:1e.0:   PREFETCH window: disabled
[    0.118830] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.118837] pci 0000:00:1c.0: setting latency timer to 64
[    0.118848] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    0.118854] pci 0000:00:1c.1: setting latency timer to 64
[    0.118865] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    0.118871] pci 0000:00:1c.2: setting latency timer to 64
[    0.118880] pci 0000:00:1e.0: setting latency timer to 64
[    0.118886] bus: 00 index 0 io port: [0x00-0xffff]
[    0.118890] bus: 00 index 1 mmio: [0x000000-0xffffffff]
[    0.118894] bus: 04 index 0 mmio: [0x0-0x0]
[    0.118897] bus: 04 index 1 mmio: [0x0-0x0]
[    0.118901] bus: 04 index 2 mmio: [0x0-0x0]
[    0.118904] bus: 04 index 3 mmio: [0x0-0x0]
[    0.118908] bus: 03 index 0 mmio: [0x0-0x0]
[    0.118912] bus: 03 index 1 mmio: [0xfbf00000-0xfbffffff]
[    0.118915] bus: 03 index 2 mmio: [0x0-0x0]
[    0.118919] bus: 03 index 3 mmio: [0x0-0x0]
[    0.118922] bus: 01 index 0 mmio: [0x0-0x0]
[    0.118926] bus: 01 index 1 mmio: [0xf8000000-0xfbefffff]
[    0.118930] bus: 01 index 2 mmio: [0xf0000000-0xf6ffffff]
[    0.118934] bus: 01 index 3 mmio: [0x0-0x0]
[    0.118938] bus: 05 index 0 mmio: [0x0-0x0]
[    0.118941] bus: 05 index 1 mmio: [0x0-0x0]
[    0.118944] bus: 05 index 2 mmio: [0x0-0x0]
[    0.118948] bus: 05 index 3 io port: [0x00-0xffff]
[    0.118952] bus: 05 index 4 mmio: [0x000000-0xffffffff]
[    0.118967] NET: Registered protocol family 2
[    0.119080] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.119214] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.120900] TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
[    0.121402] TCP: Hash tables configured (established 131072 bind 65536)
[    0.121408] TCP reno registered
[    0.121527] NET: Registered protocol family 1
[    0.121817] Machine check exception polling timer started.
[    0.122320] Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.122372] alg: cipher: Test 1 failed on encryption for aes-asm
[    0.122437] 00000000: 00 01 02 03 04 05 06 07 08 08 08 08 08 08 08 08 
[    0.122816] highmem bounce pool size: 64 pages
[    0.122930] fuse init (API version 7.10)
[    0.123046] msgmni has been set to 1749
[    0.123310] alg: No test for stdrng (krng)
[    0.123328] io scheduler noop registered
[    0.123332] io scheduler deadline registered (default)
[    0.123351] pci 0000:00:02.0: Boot video device
[    0.126408] pcieport-driver 0000:00:1c.0: setting latency timer to 64
[    0.126449] pcieport-driver 0000:00:1c.0: found MSI capability
[    0.126484] pcieport-driver 0000:00:1c.0: irq 287 for MSI/MSI-X
[    0.126499] pci_express 0000:00:1c.0:pcie00: allocate port service
[    0.126562] pci_express 0000:00:1c.0:pcie02: allocate port service
[    0.126618] pci_express 0000:00:1c.0:pcie03: allocate port service
[    0.126720] pcieport-driver 0000:00:1c.1: setting latency timer to 64
[    0.126760] pcieport-driver 0000:00:1c.1: found MSI capability
[    0.126787] pcieport-driver 0000:00:1c.1: irq 286 for MSI/MSI-X
[    0.126802] pci_express 0000:00:1c.1:pcie00: allocate port service
[    0.126857] pci_express 0000:00:1c.1:pcie02: allocate port service
[    0.126911] pci_express 0000:00:1c.1:pcie03: allocate port service
[    0.127027] pcieport-driver 0000:00:1c.2: setting latency timer to 64
[    0.127065] pcieport-driver 0000:00:1c.2: found MSI capability
[    0.127092] pcieport-driver 0000:00:1c.2: irq 285 for MSI/MSI-X
[    0.127108] pci_express 0000:00:1c.2:pcie00: allocate port service
[    0.127162] pci_express 0000:00:1c.2:pcie02: allocate port service
[    0.127215] pci_express 0000:00:1c.2:pcie03: allocate port service
[    0.127610] ACPI: AC Adapter [AC0] (on-line)
[    0.129305] ACPI: EC: non-query interrupt received, switching to interrupt mode
[    0.538989] ACPI: Battery Slot [BAT0] (battery present)
[    0.539540] input: Power Button (FF) as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.539546] ACPI: Power Button (FF) [PWRF]
[    0.539690] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input1
[    0.555939] ACPI: Lid Switch [LID]
[    0.556084] input: Sleep Button (CM) as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input2
[    0.556089] ACPI: Sleep Button (CM) [SLPB]
[    0.556210] input: Power Button (CM) as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input3
[    0.556216] ACPI: Power Button (CM) [PWRB]
[    0.557089] ACPI: CPU0 (power states: C1[C1] C2[C2] C3[C3])
[    0.557172] processor ACPI_CPU:00: registered as cooling_device0
[    0.557181] ACPI: Processor [CPU1] (supports 8 throttling states)
[    0.578040] Switched to high resolution mode on CPU 0
[    0.580430] thermal LNXTHERM:01: registered as thermal_zone0
[    0.730284] ACPI: Thermal Zone [TZ00] (53 C)
[    0.735001] Non-volatile memory driver v1.2
[    0.735015] Linux agpgart interface v0.103
[    0.735044] agpgart-intel 0000:00:00.0: Intel 915GM Chipset
[    0.735330] agpgart-intel 0000:00:00.0: detected 7932K stolen memory
[    0.738817] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    0.738942] [drm] Initialized drm 1.1.0 20060810
[    0.738979] pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.738986] pci 0000:00:02.0: setting latency timer to 64
[    0.739078] [drm:i915_gem_detect_bit_6_swizzle] *ERROR* Couldn't read from MCHBAR.  Disabling tiling.
[    0.739284] [drm] Initialized i915 1.6.0 20080730 on minor 0
[    0.740393] loop: module loaded
[    0.740432] eeepc: Eee PC Hotkey Driver
[    0.740679] eeepc: Hotkey init flags 0x41
[    0.741954] eeepc: Get control methods supported: 0x101711
[    0.742108] input: Asus EeePC extra buttons as /devices/virtual/input/input4
[    0.746513] Atheros(R) L2 Ethernet Driver - version 2.2.3
[    0.746518] Copyright (c) 2007 Atheros Corporation.
[    0.746549] atl2 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.746562] atl2 0000:03:00.0: setting latency timer to 64
[    0.785268] ath5k_pci 0000:01:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    0.785281] ath5k_pci 0000:01:00.0: setting latency timer to 64
[    0.785321] ath5k_pci 0000:01:00.0: registered as 'phy0'
[    0.825673] phy0: Selected rate control algorithm 'minstrel'
[    0.825937] ath5k phy0: Atheros AR2425 chip found (MAC: 0xe2, PHY: 0x70)
[    0.825990] Linux video capture interface: v2.00
[    0.826204] usbcore: registered new interface driver uvcvideo
[    0.826210] USB Video Class driver (v0.1.0)
[    0.826259] Driver 'sd' needs updating - please use bus_type methods
[    0.826325] ata_piix 0000:00:1f.2: version 2.12
[    0.826347] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    0.826354] ata_piix 0000:00:1f.2: MAP [ P0 P2 IDE IDE ]
[    0.826414] ata_piix 0000:00:1f.2: setting latency timer to 64
[    0.826487] scsi0 : ata_piix
[    0.826653] scsi1 : ata_piix
[    0.829891] ata1: SATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
[    0.829897] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
[    1.147363] ata2.00: ATA-5: ASUS-PHISON OB SSD, TST2.04P, max UDMA/66
[    1.147369] ata2.00: 7880544 sectors, multi 0: LBA 
[    1.147442] ata2.01: ATA-5: ASUS-PHISON SSD, TST2.04P, max UDMA/66
[    1.147446] ata2.01: 31522176 sectors, multi 0: LBA 
[    1.150339] ata2.00: configured for UDMA/66
[    1.153334] ata2.01: configured for UDMA/66
[    1.153491] scsi 1:0:0:0: Direct-Access     ATA      ASUS-PHISON OB S TST2 PQ: 0 ANSI: 5
[    1.153771] sd 1:0:0:0: [sda] 7880544 512-byte hardware sectors: (4.03 GB/3.75 GiB)
[    1.153795] sd 1:0:0:0: [sda] Write Protect is off
[    1.153800] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.153833] sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    1.153928] sd 1:0:0:0: [sda] 7880544 512-byte hardware sectors: (4.03 GB/3.75 GiB)
[    1.153948] sd 1:0:0:0: [sda] Write Protect is off
[    1.153952] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.153983] sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    1.153989]  sda: sda1 sda2 sda3 sda4
[    1.155466] sd 1:0:0:0: [sda] Attached SCSI disk
[    1.155657] scsi 1:0:1:0: Direct-Access     ATA      ASUS-PHISON SSD  TST2 PQ: 0 ANSI: 5
[    1.155903] sd 1:0:1:0: [sdb] 31522176 512-byte hardware sectors: (16.1 GB/15.0 GiB)
[    1.155926] sd 1:0:1:0: [sdb] Write Protect is off
[    1.155930] sd 1:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    1.155962] sd 1:0:1:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    1.156058] sd 1:0:1:0: [sdb] 31522176 512-byte hardware sectors: (16.1 GB/15.0 GiB)
[    1.156078] sd 1:0:1:0: [sdb] Write Protect is off
[    1.156082] sd 1:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    1.156113] sd 1:0:1:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    1.156119]  sdb: sdb1 sdb2
[    1.157754] sd 1:0:1:0: [sdb] Attached SCSI disk
[    1.157876] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.157917] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    1.157946] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    1.157952] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    1.158059] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    1.161997] ehci_hcd 0000:00:1d.7: debug port 1
[    1.162009] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
[    1.162030] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xf7eb7c00
[    1.171010] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    1.171195] usb usb1: configuration #1 chosen from 1 choice
[    1.171280] hub 1-0:1.0: USB hub found
[    1.171296] hub 1-0:1.0: 8 ports detected
[    1.171613] uhci_hcd: USB Universal Host Controller Interface driver
[    1.171645] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    1.171656] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    1.171661] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    1.171739] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    1.171770] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000e400
[    1.171943] usb usb2: configuration #1 chosen from 1 choice
[    1.172042] hub 2-0:1.0: USB hub found
[    1.172055] hub 2-0:1.0: 2 ports detected
[    1.172280] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    1.172291] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    1.172296] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    1.172368] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    1.172404] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000e480
[    1.172573] usb usb3: configuration #1 chosen from 1 choice
[    1.172659] hub 3-0:1.0: USB hub found
[    1.172671] hub 3-0:1.0: 2 ports detected
[    1.172893] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    1.172905] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    1.172911] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    1.172984] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    1.173026] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000e800
[    1.173212] usb usb4: configuration #1 chosen from 1 choice
[    1.173299] hub 4-0:1.0: USB hub found
[    1.173313] hub 4-0:1.0: 2 ports detected
[    1.173536] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 16 (level, low) -> IRQ 16
[    1.173546] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    1.173551] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    1.173622] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    1.173660] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000e880
[    1.173834] usb usb5: configuration #1 chosen from 1 choice
[    1.173917] hub 5-0:1.0: USB hub found
[    1.173930] hub 5-0:1.0: 2 ports detected
[    1.174220] Initializing USB Mass Storage driver...
[    1.174311] usbcore: registered new interface driver usb-storage
[    1.174317] USB Mass Storage support registered.
[    1.174486] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    1.207319] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.207327] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.207593] mice: PS/2 mouse device common for all mice
[    1.208880] rtc_cmos 00:03: RTC can wake from S4
[    1.208978] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    1.209017] rtc0: alarms up to one month, 114 bytes nvram, hpet irqs
[    1.209241] cpuidle: using governor ladder
[    1.209552] cpuidle: using governor menu
[    1.209618] Advanced Linux Sound Architecture Driver Version 1.0.18rc3.
[    1.209749] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.209787] HDA Intel 0000:00:1b.0: setting latency timer to 64
[    1.211060] Marking TSC unstable due to TSC halts in idle
[    1.211810] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input5
[    1.216939] hda_codec: Unknown model for ALC662, trying auto-probe from BIOS...
[    1.242422] ALSA device list:
[    1.242427]   #0: HDA Intel at 0xf7eb8000 irq 16
[    1.242470] TCP cubic registered
[    1.242474] NET: Registered protocol family 17
[    1.242537] Using IPI Shortcut mode
[    1.242950] rtc_cmos 00:03: setting system clock to
[    1.475021] usb 1-5: new high speed USB device using ehci_hcd and address 2
[    1.577471] Clocksource tsc unstable (delta = -286205456 ns)
[    1.591582] usb 1-5: configuration #1 chosen from 1 choice
[    1.591834] scsi2 : SCSI emulation for USB Mass Storage devices
[    1.592106] usb-storage: device found at 2
[    1.592110] usb-storage: waiting for device to settle before scanning
[    3.277058] input: ImPS/2 Logitech Wheel Mouse as /devices/platform/i8042/serio1/input/input6
[    3.366036] kjournald starting.  Commit interval 5 seconds
[    3.366053] EXT3-fs: mounted filesystem with ordered data mode.
[    3.366070] VFS: Mounted root (ext3 filesystem) readonly.
[    3.366279] Freeing unused kernel memory: 256k freed
[    3.366348] Write protecting the kernel text: 2548k
[    3.366382] Write protecting the kernel read-only data: 696k
[    5.655165] EXT3 FS on sdb2, internal journal
[    6.598030] usb-storage: device scan complete
[    6.598474] scsi 2:0:0:0: Direct-Access     USB2.0   CardReader SD0   0100 PQ: 0 ANSI: 0
[    7.098694] sd 2:0:0:0: [sdc] 15661056 512-byte hardware sectors: (8.01 GB/7.46 GiB)
[    7.099185] sd 2:0:0:0: [sdc] Write Protect is on
[    7.099190] sd 2:0:0:0: [sdc] Mode Sense: 03 00 80 00
[    7.099195] sd 2:0:0:0: [sdc] Assuming drive cache: write through
[    7.101942] sd 2:0:0:0: [sdc] 15661056 512-byte hardware sectors: (8.01 GB/7.46 GiB)
[    7.102433] sd 2:0:0:0: [sdc] Write Protect is on
[    7.102438] sd 2:0:0:0: [sdc] Mode Sense: 03 00 80 00
[    7.102442] sd 2:0:0:0: [sdc] Assuming drive cache: write through
[    7.102528]  sdc: sdc1 sdc2
[    7.105442] sd 2:0:0:0: [sdc] Attached SCSI removable disk
[   16.520362] warning: `avahi-daemon' uses 32-bit capabilities (legacy support in use)
[   19.072923] atl2 0000:03:00.0: irq 284 for MSI/MSI-X
[   19.278259] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[   40.658037] kjournald starting.  Commit interval 5 seconds
[   40.658064] EXT3-fs: mounted filesystem with ordered data mode.
[   60.017177] ath5k phy0: noise floor calibration timeout (2412MHz)
[   71.017226] ath5k phy0: noise floor calibration timeout (2412MHz)
[   79.795308] ath5k phy0: failed to wakeup the MAC Chip
[   79.795318] ath5k phy0: can't reset hardware (-5)
[   79.795322] phy0: failed to set freq to 2417 MHz for scan
[   79.832547] ath5k phy0: failed to wakeup the MAC Chip
[   79.832551] ath5k phy0: can't reset hardware (-5)
[   79.832554] phy0: failed to set freq to 2422 MHz for scan
[   79.869780] ath5k phy0: failed to wakeup the MAC Chip
[   79.869784] ath5k phy0: can't reset hardware (-5)
[   79.869787] phy0: failed to set freq to 2427 MHz for scan
[   79.907019] ath5k phy0: failed to wakeup the MAC Chip
[   79.907023] ath5k phy0: can't reset hardware (-5)
[   79.907026] phy0: failed to set freq to 2432 MHz for scan
[   79.944260] ath5k phy0: failed to wakeup the MAC Chip
[   79.944264] phy0: failed to set freq to 2437 MHz for scan
[   79.981494] phy0: failed to set freq to 2442 MHz for scan
[   80.018717] phy0: failed to set freq to 2447 MHz for scan
[   80.055940] phy0: failed to set freq to 2452 MHz for scan
[   80.093165] phy0: failed to set freq to 2457 MHz for scan
[   80.130388] phy0: failed to set freq to 2462 MHz for scan
[   80.167635] phy0: failed to restore operational channel after scan
[   93.017176] __ratelimit: 14 callbacks suppressed
[   93.017182] ath5k phy0: noise floor calibration timeout (2412MHz)
[  104.017155] ath5k phy0: noise floor calibration timeout (2412MHz)
[  109.803319] ath5k phy0: failed to wakeup the MAC Chip
[  109.803329] ath5k phy0: can't reset hardware (-5)
[  109.803333] phy0: failed to set freq to 2417 MHz for scan
[  109.840568] ath5k phy0: failed to wakeup the MAC Chip
[  109.840572] ath5k phy0: can't reset hardware (-5)
[  109.840575] phy0: failed to set freq to 2422 MHz for scan
[  109.877802] ath5k phy0: failed to wakeup the MAC Chip
[  109.877805] ath5k phy0: can't reset hardware (-5)
[  109.877809] phy0: failed to set freq to 2427 MHz for scan
[  109.915041] ath5k phy0: failed to wakeup the MAC Chip
[  109.915045] ath5k phy0: can't reset hardware (-5)
[  109.915048] phy0: failed to set freq to 2432 MHz for scan
[  109.952281] ath5k phy0: failed to wakeup the MAC Chip
[  109.952285] ath5k phy0: can't reset hardware (-5)
[  109.952288] phy0: failed to set freq to 2437 MHz for scan
[  109.989516] phy0: failed to set freq to 2442 MHz for scan
[  110.026749] phy0: failed to set freq to 2447 MHz for scan
[  110.063972] phy0: failed to set freq to 2452 MHz for scan
[  110.101197] phy0: failed to set freq to 2457 MHz for scan
[  110.138425] phy0: failed to set freq to 2462 MHz for scan
[  110.175664] phy0: failed to restore operational channel after scan
[  115.017159] __ratelimit: 12 callbacks suppressed
[  115.017167] ath5k phy0: noise floor calibration timeout (2412MHz)
[  126.017195] ath5k phy0: noise floor calibration timeout (2412MHz)
[  137.017190] ath5k phy0: noise floor calibration timeout (2412MHz)
[  139.810266] ath5k phy0: failed to wakeup the MAC Chip
[  139.810276] ath5k phy0: can't reset hardware (-5)
[  139.810280] phy0: failed to set freq to 2417 MHz for scan
[  139.847504] ath5k phy0: failed to wakeup the MAC Chip
[  139.847508] ath5k phy0: can't reset hardware (-5)
[  139.847511] phy0: failed to set freq to 2422 MHz for scan
[  139.884762] ath5k phy0: failed to wakeup the MAC Chip
[  139.884767] ath5k phy0: can't reset hardware (-5)
[  139.884771] phy0: failed to set freq to 2427 MHz for scan
[  139.921993] ath5k phy0: failed to wakeup the MAC Chip
[  139.921996] ath5k phy0: can't reset hardware (-5)
[  139.922000] phy0: failed to set freq to 2432 MHz for scan
[  139.959242] ath5k phy0: failed to wakeup the MAC Chip
[  139.959246] phy0: failed to set freq to 2437 MHz for scan
[  139.996473] phy0: failed to set freq to 2442 MHz for scan
[  140.033706] phy0: failed to set freq to 2447 MHz for scan
[  140.070929] phy0: failed to set freq to 2452 MHz for scan
[  140.108325] phy0: failed to set freq to 2457 MHz for scan
[  140.145636] phy0: failed to set freq to 2462 MHz for scan
[  140.182877] phy0: failed to restore operational channel after scan
[  148.017156] __ratelimit: 13 callbacks suppressed
[  148.017164] ath5k phy0: noise floor calibration timeout (2412MHz)
[  159.017155] ath5k phy0: noise floor calibration timeout (2412MHz)
[  170.017144] ath5k phy0: noise floor calibration timeout (2412MHz)
[  181.017162] ath5k phy0: noise floor calibration timeout (2412MHz)
[  192.017159] ath5k phy0: noise floor calibration timeout (2412MHz)
[  203.017160] ath5k phy0: noise floor calibration timeout (2412MHz)
[  214.017166] ath5k phy0: noise floor calibration timeout (2412MHz)
[  225.017179] ath5k phy0: noise floor calibration timeout (2412MHz)
[  236.017148] ath5k phy0: noise floor calibration timeout (2412MHz)
[  247.017143] ath5k phy0: noise floor calibration timeout (2412MHz)
[  258.017185] ath5k phy0: noise floor calibration timeout (2412MHz)
[  269.017190] ath5k phy0: noise floor calibration timeout (2412MHz)
[  269.818298] ath5k phy0: failed to wakeup the MAC Chip
[  269.818308] ath5k phy0: can't reset hardware (-5)
[  269.818312] phy0: failed to set freq to 2417 MHz for scan
[  269.855547] ath5k phy0: failed to wakeup the MAC Chip
[  269.855550] ath5k phy0: can't reset hardware (-5)
[  269.855554] phy0: failed to set freq to 2422 MHz for scan
[  269.892780] ath5k phy0: failed to wakeup the MAC Chip
[  269.892784] ath5k phy0: can't reset hardware (-5)
[  269.892787] phy0: failed to set freq to 2427 MHz for scan
[  269.930020] ath5k phy0: failed to wakeup the MAC Chip
[  269.930023] ath5k phy0: can't reset hardware (-5)
[  269.930027] phy0: failed to set freq to 2432 MHz for scan
[  269.967260] phy0: failed to set freq to 2437 MHz for scan
[  270.004483] phy0: failed to set freq to 2442 MHz for scan
[  270.041706] phy0: failed to set freq to 2447 MHz for scan
[  270.078929] phy0: failed to set freq to 2452 MHz for scan
[  270.116154] phy0: failed to set freq to 2457 MHz for scan
[  270.153388] phy0: failed to set freq to 2462 MHz for scan
[  270.190635] phy0: failed to restore operational channel after scan
[  280.017189] __ratelimit: 14 callbacks suppressed
[  280.017196] ath5k phy0: noise floor calibration timeout (2412MHz)
[  291.017186] ath5k phy0: noise floor calibration timeout (2412MHz)
[  301.330146] ath5k phy0: noise floor calibration timeout (2412MHz)
[  312.313203] ath5k phy0: noise floor calibration timeout (2412MHz)
[  323.313189] ath5k phy0: noise floor calibration timeout (2412MHz)
[  334.313146] ath5k phy0: noise floor calibration timeout (2412MHz)
[  345.313188] ath5k phy0: noise floor calibration timeout (2412MHz)
[  356.313191] ath5k phy0: noise floor calibration timeout (2412MHz)
[  367.313223] ath5k phy0: noise floor calibration timeout (2412MHz)
[  378.313220] ath5k phy0: noise floor calibration timeout (2412MHz)
[  389.313186] ath5k phy0: noise floor calibration timeout (2412MHz)
[  399.824309] ath5k phy0: failed to wakeup the MAC Chip
[  399.824318] ath5k phy0: can't reset hardware (-5)
[  399.824322] phy0: failed to set freq to 2417 MHz for scan
[  399.861561] ath5k phy0: failed to wakeup the MAC Chip
[  399.861564] ath5k phy0: can't reset hardware (-5)
[  399.861568] phy0: failed to set freq to 2422 MHz for scan
[  399.898790] ath5k phy0: failed to wakeup the MAC Chip
[  399.898794] ath5k phy0: can't reset hardware (-5)
[  399.898797] phy0: failed to set freq to 2427 MHz for scan
[  399.936028] ath5k phy0: failed to wakeup the MAC Chip
[  399.936032] ath5k phy0: can't reset hardware (-5)
[  399.936035] phy0: failed to set freq to 2432 MHz for scan
[  399.973260] ath5k phy0: failed to wakeup the MAC Chip
[  399.973264] phy0: failed to set freq to 2437 MHz for scan
[  400.323626] phy0: failed to set freq to 2442 MHz for scan
[  400.360855] phy0: failed to set freq to 2447 MHz for scan
[  400.398080] phy0: failed to set freq to 2452 MHz for scan
[  400.435303] phy0: failed to set freq to 2457 MHz for scan
[  400.472526] phy0: failed to set freq to 2462 MHz for scan
[  400.509759] phy0: failed to restore operational channel after scan
[  411.313205] __ratelimit: 14 callbacks suppressed
[  411.313212] ath5k phy0: noise floor calibration timeout (2412MHz)
[  422.313188] ath5k phy0: noise floor calibration timeout (2412MHz)
[  433.313236] ath5k phy0: noise floor calibration timeout (2412MHz)
[  444.313223] ath5k phy0: noise floor calibration timeout (2412MHz)
[  455.313231] ath5k phy0: noise floor calibration timeout (2412MHz)
[  466.313200] ath5k phy0: noise floor calibration timeout (2412MHz)
[  477.313187] ath5k phy0: noise floor calibration timeout (2412MHz)
[  488.313193] ath5k phy0: noise floor calibration timeout (2412MHz)
[  488.313213] ------------[ cut here ]------------
[  488.313218] WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x19f/0x1b0()
[  488.313222] NETDEV WATCHDOG: eth0 (atl2): transmit timed out
[  488.313228] Pid: 0, comm: swapper Not tainted 2.6.28 #3
[  488.313232] Call Trace:
[  488.313242]  [<c011f8f1>] warn_slowpath+0x71/0x90
[  488.313250]  [<c01389e2>] tick_dev_program_event+0x32/0xa0
[  488.313258]  [<c0245770>] vt_console_print+0x0/0x290
[  488.313263]  [<c011f973>] __call_console_drivers+0x43/0x60
[  488.313271]  [<c0130000>] __kfifo_put+0x10/0x90
[  488.313278]  [<c0108c32>] native_read_tsc+0x2/0x10
[  488.313285]  [<c01fa527>] delay_tsc+0x17/0x20
[  488.313291]  [<c01f8ca0>] strlcpy+0x20/0x60
[  488.313297]  [<c03183d0>] dev_watchdog+0x0/0x1b0
[  488.313303]  [<c031856f>] dev_watchdog+0x19f/0x1b0
[  488.313309]  [<c0276f00>] ath5k_hw_channel+0x730/0x790
[  488.313316]  [<c01389e2>] tick_dev_program_event+0x32/0xa0
[  488.313322]  [<c0126faf>] run_timer_softirq+0x10f/0x160
[  488.313329]  [<c0123884>] __do_softirq+0x54/0x100
[  488.313334]  [<c0105db0>] timer_interrupt+0x20/0x30
[  488.313340]  [<c013d025>] handle_IRQ_event+0x25/0x60
[  488.313346]  [<c0123957>] do_softirq+0x27/0x30
[  488.313351]  [<c0123be5>] irq_exit+0x45/0x70
[  488.313356]  [<c0105455>] do_IRQ+0x75/0x90
[  488.313362]  [<c01140aa>] read_hpet+0xa/0x10
[  488.313367]  [<c0134b47>] getnstimeofday+0x37/0xf0
[  488.313373]  [<c0103ca7>] common_interrupt+0x23/0x28
[  488.313381]  [<c022bde0>] acpi_idle_enter_bm+0x1ae/0x1df
[  488.313387]  [<c02dab25>] cpuidle_idle_call+0x65/0xb0
[  488.313392]  [<c0101dd5>] cpu_idle+0x35/0x70
[  488.313396] ---[ end trace 74a5f4e51dcf0a0e ]---
[  488.320684] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>


      
