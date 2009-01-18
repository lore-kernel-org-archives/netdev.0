From: Sitsofe Wheeler <sitsofe@yahoo.com>
Subject: Re: [atl2] warn_slowpath in dev_watchdog
Date: Sun, 18 Jan 2009 09:40:15 -0800 (PST)
Message-ID: <879024.62535.qm@web110609.mail.gq1.yahoo.com>
References: <gkt97e$ti0$1@ger.gmane.org> <20090117194045.649f55a0@osprey.hogchain.net> <767752.95325.qm@web110601.mail.gq1.yahoo.com> <20090118095231.2c73c448@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, Chris Snook <csnook@redhat.com>,
	jie.yang@atheros.com, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web110609.mail.gq1.yahoo.com ([67.195.13.200]:45578 "HELO
	web110609.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932210AbZARRkR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jan 2009 12:40:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Jay Cliburn <jcliburn@gmail.com>
> 
> I'd like to see the full dmesg that includes the warning, if you can

I've dug some stuff up. Here's a clean 2.6.28 dmesg:
[    0.000000] BIOS EBDA/lowmem at: 0009fc00/0009fc00
[    0.000000] Linux version 2.6.28 (@verona) (gcc version 4.2.4) #2
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
[    0.000000] TSC: PIT calibration matches PMTIMER. 1 loops
[    0.000000] Detected 900.077 MHz processor.
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
[    0.000999]       .data : 0xc037cd1a - 0xc047bcec   (1019 kB)
[    0.000999]       .text : 0xc0100000 - 0xc037cd1a   (2547 kB)
[    0.000999] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000999] SLUB: Genslabs=12, HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.001012] Calibrating delay loop (skipped), value calculated using timer frequency.. 1800.15 BogoMIPS (lpj=900077)
[    0.001037] Security Framework initialized
[    0.001056] Mount-cache hash table entries: 512
[    0.001278] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.001285] CPU: L2 cache: 512K
[    0.001289] Intel machine check architecture supported.
[    0.001296] Intel machine check reporting enabled on CPU#0.
[    0.001311] CPU: Intel(R) Celeron(R) M processor          900MHz stepping 08
[    0.001321] Checking 'hlt' instruction... OK.
[    0.005636] Freeing SMP alternatives: 0k freed
[    0.005640] ACPI: Core revision 20080926
[    0.021648] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.031995] net_namespace: 288 bytes
[    0.031995] NET: Registered protocol family 16
[    0.031995] ACPI: bus type pci registered
[    0.031995] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.031995] PCI: Not using MMCONFIG.
[    0.031995] PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=5
[    0.031995] PCI: Using configuration type 1 for base access
[    0.037050] ACPI: EC: Look up EC in DSDT
[    0.050100] ACPI: Interpreter enabled
[    0.050113] ACPI: (supports S0 S1 S3 S5)
[    0.050144] ACPI: Using IOAPIC for interrupt routing
[    0.050262] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.053605] PCI: MCFG area at e0000000 reserved in ACPI motherboard resources
[    0.053610] PCI: Using MMCONFIG for extended config space
[    0.064270] ACPI: EC: GPE = 0x18, I/O: command/status = 0x66, data = 0x62
[    0.064276] ACPI: EC: driver started in poll mode
[    0.064548] ACPI: No dock devices found.
[    0.064699] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.064856] pci 0000:00:02.0: reg 10 32bit mmio: [0xf7f00000-0xf7f7ffff]
[    0.064864] pci 0000:00:02.0: reg 14 io port: [0xec00-0xec07]
[    0.064872] pci 0000:00:02.0: reg 18 32bit mmio: [0xd0000000-0xdfffffff]
[    0.064879] pci 0000:00:02.0: reg 1c 32bit mmio: [0xf7ec0000-0xf7efffff]
[    0.064918] pci 0000:00:02.1: reg 10 32bit mmio: [0xf7f80000-0xf7ffffff]
[    0.065029] pci 0000:00:1b.0: reg 10 64bit mmio: [0xf7eb8000-0xf7ebbfff]
[    0.065063] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.065070] pci 0000:00:1b.0: PME# disabled
[    0.065122] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.065128] pci 0000:00:1c.0: PME# disabled
[    0.065182] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.065187] pci 0000:00:1c.1: PME# disabled
[    0.065241] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.065247] pci 0000:00:1c.2: PME# disabled
[    0.065300] pci 0000:00:1d.0: reg 20 io port: [0xe400-0xe41f]
[    0.065356] pci 0000:00:1d.1: reg 20 io port: [0xe480-0xe49f]
[    0.065410] pci 0000:00:1d.2: reg 20 io port: [0xe800-0xe81f]
[    0.065463] pci 0000:00:1d.3: reg 20 io port: [0xe880-0xe89f]
[    0.065521] pci 0000:00:1d.7: reg 10 32bit mmio: [0xf7eb7c00-0xf7eb7fff]
[    0.065564] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.065571] pci 0000:00:1d.7: PME# disabled
[    0.065695] pci 0000:00:1f.0: Force enabled HPET at 0xfed00000
[    0.065706] pci 0000:00:1f.0: quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
[    0.065712] pci 0000:00:1f.0: quirk: region 0480-04bf claimed by ICH6 GPIO
[    0.065745] pci 0000:00:1f.2: reg 10 io port: [0x00-0x07]
[    0.065753] pci 0000:00:1f.2: reg 14 io port: [0x00-0x03]
[    0.065762] pci 0000:00:1f.2: reg 18 io port: [0x00-0x07]
[    0.065770] pci 0000:00:1f.2: reg 1c io port: [0x00-0x03]
[    0.065778] pci 0000:00:1f.2: reg 20 io port: [0xffa0-0xffaf]
[    0.065799] pci 0000:00:1f.2: PME# supported from D3hot
[    0.065805] pci 0000:00:1f.2: PME# disabled
[    0.065854] pci 0000:00:1f.3: reg 20 io port: [0x400-0x41f]
[    0.065994] pci 0000:03:00.0: reg 10 64bit mmio: [0xfbfc0000-0xfbffffff]
[    0.066031] pci 0000:03:00.0: reg 30 32bit mmio: [0xfbfa0000-0xfbfbffff]
[    0.066046] pci 0000:03:00.0: PME# supported from D3hot D3cold
[    0.066053] pci 0000:03:00.0: PME# disabled
[    0.066107] pci 0000:00:1c.1: bridge 32bit mmio: [0xfbf00000-0xfbffffff]
[    0.066172] pci 0000:01:00.0: reg 10 64bit mmio: [0xfbef0000-0xfbefffff]
[    0.066273] pci 0000:00:1c.2: bridge 32bit mmio: [0xf8000000-0xfbefffff]
[    0.066282] pci 0000:00:1c.2: bridge 64bit mmio pref: [0xf0000000-0xf6ffffff]
[    0.066335] pci 0000:00:1e.0: transparent bridge
[    0.066366] bus 00 -> node 0
[    0.066380] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.066868] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P3._PRT]
[    0.067075] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P5._PRT]
[    0.067265] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P6._PRT]
[    0.075317] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 *5 6 7 10 11 12 14 15)
[    0.075595] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[    0.075869] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    0.076155] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *7 10 11 12 14 15)
[    0.076426] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.076701] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.076974] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.077278] ACPI: PCI Interrupt Link [LNKH] (IRQs *3 4 5 6 7 10 11 12 14 15)
[    0.077892] SCSI subsystem initialized
[    0.077930] libata version 3.00 loaded.
[    0.078094] usbcore: registered new interface driver usbfs
[    0.078147] usbcore: registered new interface driver hub
[    0.078210] usbcore: registered new device driver usb
[    0.078495] PCI: Using ACPI for IRQ routing
[    0.078661] cfg80211: Using static regulatory domain info
[    0.078661] cfg80211: Regulatory domain: US
[    0.078661]     (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[    0.078661]     (2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, 2700 mBm)
[    0.078661]     (5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.078661]     (5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.078661]     (5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.078661]     (5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.078661]     (5735000 KHz - 5835000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
[    0.078661] cfg80211: Calling CRDA for country: US
[    0.079251] hpet clockevent registered
[    0.079258] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.079266] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.079274] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.081053] pnp: PnP ACPI init
[    0.081053] ACPI: bus type pnp registered
[    0.085300] pnp: PnP ACPI: found 13 devices
[    0.085306] ACPI: ACPI bus type pnp unregistered
[    0.085331] system 00:01: iomem range 0xfed13000-0xfed19fff has been reserved
[    0.085349] system 00:08: ioport range 0x380-0x383 has been reserved
[    0.085354] system 00:08: ioport range 0x4d0-0x4d1 has been reserved
[    0.085359] system 00:08: ioport range 0x800-0x87f has been reserved
[    0.085365] system 00:08: ioport range 0x480-0x4bf has been reserved
[    0.085370] system 00:08: iomem range 0xfed1c000-0xfed1ffff has been reserved
[    0.085376] system 00:08: iomem range 0xfed20000-0xfed8ffff has been reserved
[    0.085390] system 00:08: iomem range 0xfff00000-0xffffffff could not be reserved
[    0.085399] system 00:09: iomem range 0xfec00000-0xfec00fff has been reserved
[    0.085405] system 00:09: iomem range 0xfee00000-0xfee00fff has been reserved
[    0.085415] system 00:0a: iomem range 0xe0000000-0xefffffff has been reserved
[    0.085425] system 00:0b: iomem range 0xe0000000-0xefffffff has been reserved
[    0.085435] system 00:0c: iomem range 0x0-0x9ffff could not be reserved
[    0.085441] system 00:0c: iomem range 0xe0000-0xfffff could not be reserved
[    0.085446] system 00:0c: iomem range 0x100000-0x3f7fffff could not be reserved
[    0.120720] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:04
[    0.120725] pci 0000:00:1c.0:   IO window: disabled
[    0.120732] pci 0000:00:1c.0:   MEM window: disabled
[    0.120737] pci 0000:00:1c.0:   PREFETCH window: disabled
[    0.120746] pci 0000:00:1c.1: PCI bridge, secondary bus 0000:03
[    0.120750] pci 0000:00:1c.1:   IO window: disabled
[    0.120757] pci 0000:00:1c.1:   MEM window: 0xfbf00000-0xfbffffff
[    0.120763] pci 0000:00:1c.1:   PREFETCH window: disabled
[    0.120771] pci 0000:00:1c.2: PCI bridge, secondary bus 0000:01
[    0.120775] pci 0000:00:1c.2:   IO window: disabled
[    0.120782] pci 0000:00:1c.2:   MEM window: 0xf8000000-0xfbefffff
[    0.120788] pci 0000:00:1c.2:   PREFETCH window: 0x000000f0000000-0x000000f6ffffff
[    0.120798] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:05
[    0.120801] pci 0000:00:1e.0:   IO window: disabled
[    0.120808] pci 0000:00:1e.0:   MEM window: disabled
[    0.120813] pci 0000:00:1e.0:   PREFETCH window: disabled
[    0.120840] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.120847] pci 0000:00:1c.0: setting latency timer to 64
[    0.120858] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    0.120864] pci 0000:00:1c.1: setting latency timer to 64
[    0.120875] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    0.120881] pci 0000:00:1c.2: setting latency timer to 64
[    0.120890] pci 0000:00:1e.0: setting latency timer to 64
[    0.120896] bus: 00 index 0 io port: [0x00-0xffff]
[    0.120900] bus: 00 index 1 mmio: [0x000000-0xffffffff]
[    0.120904] bus: 04 index 0 mmio: [0x0-0x0]
[    0.120908] bus: 04 index 1 mmio: [0x0-0x0]
[    0.120911] bus: 04 index 2 mmio: [0x0-0x0]
[    0.120914] bus: 04 index 3 mmio: [0x0-0x0]
[    0.120918] bus: 03 index 0 mmio: [0x0-0x0]
[    0.120922] bus: 03 index 1 mmio: [0xfbf00000-0xfbffffff]
[    0.120926] bus: 03 index 2 mmio: [0x0-0x0]
[    0.120929] bus: 03 index 3 mmio: [0x0-0x0]
[    0.120933] bus: 01 index 0 mmio: [0x0-0x0]
[    0.120937] bus: 01 index 1 mmio: [0xf8000000-0xfbefffff]
[    0.120941] bus: 01 index 2 mmio: [0xf0000000-0xf6ffffff]
[    0.120945] bus: 01 index 3 mmio: [0x0-0x0]
[    0.120948] bus: 05 index 0 mmio: [0x0-0x0]
[    0.120952] bus: 05 index 1 mmio: [0x0-0x0]
[    0.120955] bus: 05 index 2 mmio: [0x0-0x0]
[    0.120959] bus: 05 index 3 io port: [0x00-0xffff]
[    0.120963] bus: 05 index 4 mmio: [0x000000-0xffffffff]
[    0.120982] NET: Registered protocol family 2
[    0.121089] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.121225] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.122912] TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
[    0.123409] TCP: Hash tables configured (established 131072 bind 65536)
[    0.123417] TCP reno registered
[    0.123536] NET: Registered protocol family 1
[    0.123831] Machine check exception polling timer started.
[    0.124339] Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.124390] alg: cipher: Test 1 failed on encryption for aes-asm
[    0.124455] 00000000: 00 01 02 03 04 05 06 07 08 08 08 08 08 08 08 08 
[    0.124841] highmem bounce pool size: 64 pages
[    0.124955] fuse init (API version 7.10)
[    0.125072] msgmni has been set to 1749
[    0.125330] alg: No test for stdrng (krng)
[    0.125350] io scheduler noop registered
[    0.125354] io scheduler deadline registered (default)
[    0.125371] pci 0000:00:02.0: Boot video device
[    0.128434] pcieport-driver 0000:00:1c.0: setting latency timer to 64
[    0.128475] pcieport-driver 0000:00:1c.0: found MSI capability
[    0.128507] pcieport-driver 0000:00:1c.0: irq 287 for MSI/MSI-X
[    0.128522] pci_express 0000:00:1c.0:pcie00: allocate port service
[    0.128581] pci_express 0000:00:1c.0:pcie02: allocate port service
[    0.128634] pci_express 0000:00:1c.0:pcie03: allocate port service
[    0.128737] pcieport-driver 0000:00:1c.1: setting latency timer to 64
[    0.128775] pcieport-driver 0000:00:1c.1: found MSI capability
[    0.128802] pcieport-driver 0000:00:1c.1: irq 286 for MSI/MSI-X
[    0.128816] pci_express 0000:00:1c.1:pcie00: allocate port service
[    0.128871] pci_express 0000:00:1c.1:pcie02: allocate port service
[    0.128925] pci_express 0000:00:1c.1:pcie03: allocate port service
[    0.129041] pcieport-driver 0000:00:1c.2: setting latency timer to 64
[    0.129078] pcieport-driver 0000:00:1c.2: found MSI capability
[    0.129105] pcieport-driver 0000:00:1c.2: irq 285 for MSI/MSI-X
[    0.129121] pci_express 0000:00:1c.2:pcie00: allocate port service
[    0.129177] pci_express 0000:00:1c.2:pcie02: allocate port service
[    0.129231] pci_express 0000:00:1c.2:pcie03: allocate port service
[    0.129638] ACPI: AC Adapter [AC0] (on-line)
[    0.131246] ACPI: EC: non-query interrupt received, switching to interrupt mode
[    0.539943] ACPI: Battery Slot [BAT0] (battery present)
[    0.540485] input: Power Button (FF) as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.540490] ACPI: Power Button (FF) [PWRF]
[    0.540629] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input1
[    0.556582] ACPI: Lid Switch [LID]
[    0.556721] input: Sleep Button (CM) as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input2
[    0.556727] ACPI: Sleep Button (CM) [SLPB]
[    0.556851] input: Power Button (CM) as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input3
[    0.556857] ACPI: Power Button (CM) [PWRB]
[    0.557731] ACPI: CPU0 (power states: C1[C1] C2[C2] C3[C3])
[    0.557813] processor ACPI_CPU:00: registered as cooling_device0
[    0.557820] ACPI: Processor [CPU1] (supports 8 throttling states)
[    0.580677] Switched to high resolution mode on CPU 0
[    0.581797] thermal LNXTHERM:01: registered as thermal_zone0
[    0.730060] ACPI: Thermal Zone [TZ00] (61 C)
[    0.734722] Non-volatile memory driver v1.2
[    0.734727] Linux agpgart interface v0.103
[    0.734755] agpgart-intel 0000:00:00.0: Intel 915GM Chipset
[    0.735074] agpgart-intel 0000:00:00.0: detected 7932K stolen memory
[    0.738542] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    0.738666] [drm] Initialized drm 1.1.0 20060810
[    0.738705] pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.738712] pci 0000:00:02.0: setting latency timer to 64
[    0.738786] [drm:i915_gem_detect_bit_6_swizzle] *ERROR* Couldn't read from MCHBAR.  Disabling tiling.
[    0.738988] [drm] Initialized i915 1.6.0 20080730 on minor 0
[    0.740107] loop: module loaded
[    0.740146] eeepc: Eee PC Hotkey Driver
[    0.740396] eeepc: Hotkey init flags 0x41
[    0.741673] eeepc: Get control methods supported: 0x101711
[    0.741806] input: Asus EeePC extra buttons as /devices/virtual/input/input4
[    0.746232] Atheros(R) L2 Ethernet Driver - version 2.2.3
[    0.746237] Copyright (c) 2007 Atheros Corporation.
[    0.746271] atl2 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.746285] atl2 0000:03:00.0: setting latency timer to 64
[    0.785264] ath5k_pci 0000:01:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    0.785276] ath5k_pci 0000:01:00.0: setting latency timer to 64
[    0.785318] ath5k_pci 0000:01:00.0: registered as 'phy0'
[    0.825701] phy0: Selected rate control algorithm 'minstrel'
[    0.825968] ath5k phy0: Atheros AR2425 chip found (MAC: 0xe2, PHY: 0x70)
[    0.826035] Linux video capture interface: v2.00
[    0.826239] usbcore: registered new interface driver uvcvideo
[    0.826246] USB Video Class driver (v0.1.0)
[    0.826296] Driver 'sd' needs updating - please use bus_type methods
[    0.826365] ata_piix 0000:00:1f.2: version 2.12
[    0.826390] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    0.826396] ata_piix 0000:00:1f.2: MAP [ P0 P2 IDE IDE ]
[    0.826453] ata_piix 0000:00:1f.2: setting latency timer to 64
[    0.826528] scsi0 : ata_piix
[    0.826697] scsi1 : ata_piix
[    0.829926] ata1: SATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
[    0.829932] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
[    1.148364] ata2.00: ATA-5: ASUS-PHISON OB SSD, TST2.04P, max UDMA/66
[    1.148369] ata2.00: 7880544 sectors, multi 0: LBA 
[    1.148442] ata2.01: ATA-5: ASUS-PHISON SSD, TST2.04P, max UDMA/66
[    1.148447] ata2.01: 31522176 sectors, multi 0: LBA 
[    1.151339] ata2.00: configured for UDMA/66
[    1.154333] ata2.01: configured for UDMA/66
[    1.154486] scsi 1:0:0:0: Direct-Access     ATA      ASUS-PHISON OB S TST2 PQ: 0 ANSI: 5
[    1.154766] sd 1:0:0:0: [sda] 7880544 512-byte hardware sectors: (4.03 GB/3.75 GiB)
[    1.154790] sd 1:0:0:0: [sda] Write Protect is off
[    1.154795] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.154828] sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    1.154923] sd 1:0:0:0: [sda] 7880544 512-byte hardware sectors: (4.03 GB/3.75 GiB)
[    1.154943] sd 1:0:0:0: [sda] Write Protect is off
[    1.154947] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.154979] sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    1.154985]  sda: sda1 sda2 sda3 sda4
[    1.156464] sd 1:0:0:0: [sda] Attached SCSI disk
[    1.156654] scsi 1:0:1:0: Direct-Access     ATA      ASUS-PHISON SSD  TST2 PQ: 0 ANSI: 5
[    1.156905] sd 1:0:1:0: [sdb] 31522176 512-byte hardware sectors: (16.1 GB/15.0 GiB)
[    1.156927] sd 1:0:1:0: [sdb] Write Protect is off
[    1.156931] sd 1:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    1.156963] sd 1:0:1:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    1.157059] sd 1:0:1:0: [sdb] 31522176 512-byte hardware sectors: (16.1 GB/15.0 GiB)
[    1.157079] sd 1:0:1:0: [sdb] Write Protect is off
[    1.157083] sd 1:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    1.157115] sd 1:0:1:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    1.157120]  sdb: sdb1 sdb2
[    1.158667] sd 1:0:1:0: [sdb] Attached SCSI disk
[    1.158789] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.158832] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    1.158862] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    1.158868] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    1.158965] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    1.162882] ehci_hcd 0000:00:1d.7: debug port 1
[    1.162891] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
[    1.162909] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xf7eb7c00
[    1.172010] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    1.172194] usb usb1: configuration #1 chosen from 1 choice
[    1.172279] hub 1-0:1.0: USB hub found
[    1.172294] hub 1-0:1.0: 8 ports detected
[    1.172605] uhci_hcd: USB Universal Host Controller Interface driver
[    1.172640] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    1.172650] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    1.172655] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    1.172729] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    1.172758] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000e400
[    1.172928] usb usb2: configuration #1 chosen from 1 choice
[    1.173025] hub 2-0:1.0: USB hub found
[    1.173039] hub 2-0:1.0: 2 ports detected
[    1.173269] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    1.173280] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    1.173287] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    1.173358] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    1.173397] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000e480
[    1.173568] usb usb3: configuration #1 chosen from 1 choice
[    1.173653] hub 3-0:1.0: USB hub found
[    1.173668] hub 3-0:1.0: 2 ports detected
[    1.173899] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    1.173910] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    1.173915] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    1.173987] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    1.174035] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000e800
[    1.174219] usb usb4: configuration #1 chosen from 1 choice
[    1.174314] hub 4-0:1.0: USB hub found
[    1.174326] hub 4-0:1.0: 2 ports detected
[    1.174556] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 16 (level, low) -> IRQ 16
[    1.174566] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    1.174572] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    1.174642] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    1.174679] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000e880
[    1.174855] usb usb5: configuration #1 chosen from 1 choice
[    1.174941] hub 5-0:1.0: USB hub found
[    1.174953] hub 5-0:1.0: 2 ports detected
[    1.175254] Initializing USB Mass Storage driver...
[    1.175340] usbcore: registered new interface driver usb-storage
[    1.175346] USB Mass Storage support registered.
[    1.175511] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    1.207721] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.207728] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.207997] mice: PS/2 mouse device common for all mice
[    1.209199] rtc_cmos 00:03: RTC can wake from S4
[    1.209292] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    1.209322] rtc0: alarms up to one month, 114 bytes nvram, hpet irqs
[    1.209545] cpuidle: using governor ladder
[    1.209860] cpuidle: using governor menu
[    1.209927] Advanced Linux Sound Architecture Driver Version 1.0.18rc3.
[    1.210062] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.210103] HDA Intel 0000:00:1b.0: setting latency timer to 64
[    1.212056] Marking TSC unstable due to TSC halts in idle
[    1.212799] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input5
[    1.217935] hda_codec: Unknown model for ALC662, trying auto-probe from BIOS...
[    1.242786] ALSA device list:
[    1.242790]   #0: HDA Intel at 0xf7eb8000 irq 16
[    1.242833] TCP cubic registered
[    1.242839] NET: Registered protocol family 17
[    1.242902] Using IPI Shortcut mode
[    1.243332] rtc_cmos 00:03: setting system clock to
[    1.475569] usb 1-5: new high speed USB device using ehci_hcd and address 2
[    1.579015] Clocksource tsc unstable (delta = -285096727 ns)
[    1.590282] usb 1-5: configuration #1 chosen from 1 choice
[    1.590538] scsi2 : SCSI emulation for USB Mass Storage devices
[    1.590797] usb-storage: device found at 2
[    1.590801] usb-storage: waiting for device to settle before scanning
[    3.276568] input: ImPS/2 Logitech Wheel Mouse as /devices/platform/i8042/serio1/input/input6
[    3.367063] kjournald starting.  Commit interval 5 seconds
[    3.367078] EXT3-fs: mounted filesystem with ordered data mode.
[    3.367095] VFS: Mounted root (ext3 filesystem) readonly.
[    3.367307] Freeing unused kernel memory: 256k freed
[    3.367377] Write protecting the kernel text: 2548k
[    3.367410] Write protecting the kernel read-only data: 696k
[    5.992011] EXT3 FS on sdb2, internal journal
[    6.591137] usb-storage: device scan complete
[    6.591697] scsi 2:0:0:0: Direct-Access     USB2.0   CardReader SD0   0100 PQ: 0 ANSI: 0
[    7.096796] sd 2:0:0:0: [sdc] 15661056 512-byte hardware sectors: (8.01 GB/7.46 GiB)
[    7.097809] sd 2:0:0:0: [sdc] Write Protect is on
[    7.097817] sd 2:0:0:0: [sdc] Mode Sense: 03 00 80 00
[    7.097821] sd 2:0:0:0: [sdc] Assuming drive cache: write through
[    7.107302] sd 2:0:0:0: [sdc] 15661056 512-byte hardware sectors: (8.01 GB/7.46 GiB)
[    7.107911] sd 2:0:0:0: [sdc] Write Protect is on
[    7.107918] sd 2:0:0:0: [sdc] Mode Sense: 03 00 80 00
[    7.107922] sd 2:0:0:0: [sdc] Assuming drive cache: write through
[    7.108026]  sdc: sdc1 sdc2
[    7.116717] sd 2:0:0:0: [sdc] Attached SCSI removable disk
[   13.486902] warning: `avahi-daemon' uses 32-bit capabilities (legacy support in use)
[   14.906517] atl2 0000:03:00.0: irq 284 for MSI/MSI-X
[   15.111850] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[   41.683895] kjournald starting.  Commit interval 5 seconds
[   41.683912] EXT3-fs: mounted filesystem with ordered data mode.
[  295.704074] ------------[ cut here ]------------
[  295.704081] WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x19f/0x1b0()
[  295.704086] NETDEV WATCHDOG: eth0 (atl2): transmit timed out
[  295.704092] Pid: 0, comm: swapper Not tainted 2.6.28 #2
[  295.704096] Call Trace:
[  295.704105]  [<c011f8f1>] warn_slowpath+0x71/0x90
[  295.704112]  [<c011ccfb>] enqueue_task_fair+0xab/0xc0
[  295.704119]  [<c011abb2>] enqueue_task+0x12/0x30
[  295.704125]  [<c011ac76>] activate_task+0x16/0x20
[  295.704131]  [<c011adae>] __wake_up_common+0x3e/0x70
[  295.704136]  [<c01140aa>] read_hpet+0xa/0x10
[  295.704143]  [<c0134b47>] getnstimeofday+0x37/0xf0
[  295.704150]  [<c01f8ca0>] strlcpy+0x20/0x60
[  295.704156]  [<c03183c0>] dev_watchdog+0x0/0x1b0
[  295.704162]  [<c031855f>] dev_watchdog+0x19f/0x1b0
[  295.704169]  [<c01389e2>] tick_dev_program_event+0x32/0xa0
[  295.704175]  [<c0126d8c>] cascade+0x5c/0x70
[  295.704181]  [<c0126faf>] run_timer_softirq+0x10f/0x160
[  295.704187]  [<c0123884>] __do_softirq+0x54/0x100
[  295.704194]  [<c0105db0>] timer_interrupt+0x20/0x30
[  295.704200]  [<c013d025>] handle_IRQ_event+0x25/0x60
[  295.704206]  [<c0123957>] do_softirq+0x27/0x30
[  295.704211]  [<c0123be5>] irq_exit+0x45/0x70
[  295.704216]  [<c0105455>] do_IRQ+0x75/0x90
[  295.704221]  [<c01140aa>] read_hpet+0xa/0x10
[  295.704226]  [<c0134b47>] getnstimeofday+0x37/0xf0
[  295.704231]  [<c0103ca7>] common_interrupt+0x23/0x28
[  295.704240]  [<c022bde0>] acpi_idle_enter_bm+0x1ae/0x1df
[  295.704246]  [<c02dab15>] cpuidle_idle_call+0x65/0xb0
[  295.704251]  [<c0101dd5>] cpu_idle+0x35/0x70
[  295.704256] ---[ end trace bf3f8b59b09692e1 ]---
[  295.711710] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>

Here's a dmesg from a 2.6.28 with some patches applied (most likely patches not related to this) but 
with more debugging options enabled (not that these narrowed the problem down):

[    0.000000] BIOS EBDA/lowmem at: 0009fc00/0009fc00
[    0.000000] Linux version 2.6.28skw-00025-gaee9cf6 (@xenon) (gcc version 4.1.2 20070925 (Red Hat 4.1.2-33)) #7 Mon Dec 29 00:23:44 GMT 2008
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
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] modified physical RAM map:
[    0.000000]  modified: 0000000000000000 - 0000000000001000 (usable)
[    0.000000]  modified: 0000000000001000 - 0000000000010000 (reserved)
[    0.000000]  modified: 0000000000010000 - 0000000000090c00 (usable)
[    0.000000]  modified: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  modified: 00000000000e4000 - 0000000000100000 (reserved)
[    0.000000]  modified: 0000000000100000 - 000000003f780000 (usable)
[    0.000000]  modified: 000000003f780000 - 000000003f790000 (ACPI data)
[    0.000000]  modified: 000000003f790000 - 000000003f7d0000 (ACPI NVS)
[    0.000000]  modified: 000000003f7d0000 - 000000003f7de000 (reserved)
[    0.000000]  modified: 000000003f7e0000 - 000000003f800000 (reserved)
[    0.000000]  modified: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  modified: 00000000fff80000 - 0000000100000000 (reserved)
[    0.000000] kernel direct mapping tables up to 377fe000 @ a0e000-af0000
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
[    0.000000]   bootmap 00010000 - 00016f00
[    0.000000] (6 early reservations) ==> bootmem [0000000000 - 00377fe000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
[    0.000000]   #1 [0000100000 - 00009f8ab4]    TEXT DATA BSS ==> [0000100000 - 00009f8ab4]
[    0.000000]   #2 [00009f9000 - 0000a0e000]    INIT_PG_TABLE ==> [00009f9000 - 0000a0e000]
[    0.000000]   #3 [000009fc00 - 0000100000]    BIOS reserved ==> [000009fc00 - 0000100000]
[    0.000000]   #4 [0000a0e000 - 0000ad8000]          PGTABLE ==> [0000a0e000 - 0000ad8000]
[    0.000000]   #5 [0000010000 - 0000017000]          BOOTMAP ==> [0000010000 - 0000017000]
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x000377fe
[    0.000000]   HighMem  0x000377fe -> 0x0003f780
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x00000001
[    0.000000]     0: 0x00000010 -> 0x00000090
[    0.000000]     0: 0x00000100 -> 0x0003f780
[    0.000000] On node 0 totalpages: 259841
[    0.000000] free_area_init_node: node 0, pgdat c0530ca0, node_mem_map c1001000
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3937 pages, LIFO batch:0
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
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 257809
[    0.000000] Kernel command line: root=/dev/sdb2 ro quiet
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 16384 bytes)
[    0.000000] TSC: PIT calibration matches PMTIMER. 1 loops
[    0.000000] Detected 900.091 MHz processor.
[    0.000999] Console: colour VGA+ 80x25
[    0.000999] console [tty0] enabled
[    0.000999] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000999] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000999] ... MAX_LOCK_DEPTH:          48
[    0.000999] ... MAX_LOCKDEP_KEYS:        8191
[    0.000999] ... CLASSHASH_SIZE:          4096
[    0.000999] ... MAX_LOCKDEP_ENTRIES:     8192
[    0.000999] ... MAX_LOCKDEP_CHAINS:      16384
[    0.000999] ... CHAINHASH_SIZE:          8192
[    0.000999]  memory used by lock dependency info: 2335 kB
[    0.000999]  per task-struct memory footprint: 1152 bytes
[    0.000999] ------------------------
[    0.000999] | Locking API testsuite:
[    0.000999] ----------------------------------------------------------------------------
[    0.000999]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[    0.000999]   --------------------------------------------------------------------------
[    0.000999]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]   --------------------------------------------------------------------------
[    0.000999]               recursive read-lock:             |  ok  |             |  ok  |
[    0.000999]            recursive read-lock #2:             |  ok  |             |  ok  |
[    0.000999]             mixed read-write-lock:             |  ok  |             |  ok  |
[    0.000999]             mixed write-read-lock:             |  ok  |             |  ok  |
[    0.000999]   --------------------------------------------------------------------------
[    0.000999]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000999]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000999]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000999]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000999]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
[    0.000999]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
[    0.000999]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000999]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000999]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000999]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000999]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000999]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000999]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000999]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000999]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000999]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq read-recursion/123:  ok  |
[    0.000999]       soft-irq read-recursion/123:  ok  |
[    0.000999]       hard-irq read-recursion/132:  ok  |
[    0.000999]       soft-irq read-recursion/132:  ok  |
[    0.000999]       hard-irq read-recursion/213:  ok  |
[    0.000999]       soft-irq read-recursion/213:  ok  |
[    0.000999]       hard-irq read-recursion/231:  ok  |
[    0.000999]       soft-irq read-recursion/231:  ok  |
[    0.000999]       hard-irq read-recursion/312:  ok  |
[    0.000999]       soft-irq read-recursion/312:  ok  |
[    0.000999]       hard-irq read-recursion/321:  ok  |
[    0.000999]       soft-irq read-recursion/321:  ok  |
[    0.000999] -------------------------------------------------------
[    0.000999] Good, all 218 testcases passed! |
[    0.000999] ---------------------------------
[    0.000999] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000999] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000999] Scanning for low memory corruption every 60 seconds
[    0.000999] Memory: 1019912k/1039872k available (2973k kernel code, 19060k reserved, 1354k data, 288k init, 130568k highmem)
[    0.000999] virtual kernel memory layout:
[    0.000999]     fixmap  : 0xfff9e000 - 0xfffff000   ( 388 kB)
[    0.000999]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000999]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000999]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000999]       .init : 0xc053c000 - 0xc0584000   ( 288 kB)
[    0.000999]       .data : 0xc03e7599 - 0xc0539e2c   (1354 kB)
[    0.000999]       .text : 0xc0100000 - 0xc03e7599   (2973 kB)
[    0.000999] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000999] SLUB: Genslabs=12, HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.001052] Calibrating delay loop (skipped), value calculated using timer frequency.. 1800.18 BogoMIPS (lpj=900091)
[    0.001186] Security Framework initialized
[    0.001252] Mount-cache hash table entries: 512
[    0.003142] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.003151] CPU: L2 cache: 512K
[    0.003156] Intel machine check architecture supported.
[    0.003165] Intel machine check reporting enabled on CPU#0.
[    0.003183] CPU: Intel(R) Celeron(R) M processor          900MHz stepping 08
[    0.003219] Checking 'hlt' instruction... OK.
[    0.007780] debug: unmapping init memory c053c000..c053c000
[    0.007843] ACPI: Core revision 20080926
[    0.054004] ftrace: converting mcount calls to 0f 1f 44 00 00
[    0.054019] ftrace: allocating 13411 entries in 53 pages
[    0.060407] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.070989] APIC calibration not consistent with PM Timer: 119ms instead of 100ms
[    0.070989] APIC delta adjusted to PM-Timer: 625064 (749961)
[    0.071951] net_namespace: 376 bytes
[    0.072237] Time: 12:04:55  Date: 01/18/09
[    0.072594] NET: Registered protocol family 16
[    0.075767] ACPI: bus type pci registered
[    0.075853] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.075863] PCI: Not using MMCONFIG.
[    0.076101] PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=5
[    0.076108] PCI: Using configuration type 1 for base access
[    0.121560] ACPI: EC: Look up EC in DSDT
[    0.185100] ACPI: Interpreter enabled
[    0.185116] ACPI: (supports S0 S1 S3 S5)
[    0.185337] ACPI: Using IOAPIC for interrupt routing
[    0.185614] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.196255] PCI: MCFG area at e0000000 reserved in ACPI motherboard resources
[    0.196262] PCI: Using MMCONFIG for extended config space
[    0.250463] ACPI: EC: GPE = 0x18, I/O: command/status = 0x66, data = 0x62
[    0.250471] ACPI: EC: driver started in poll mode
[    0.251647] ACPI: No dock devices found.
[    0.252295] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.253674] pci 0000:00:02.0: reg 10 32bit mmio: [0xf7f00000-0xf7f7ffff]
[    0.253690] pci 0000:00:02.0: reg 14 io port: [0xec00-0xec07]
[    0.253704] pci 0000:00:02.0: reg 18 32bit mmio: [0xd0000000-0xdfffffff]
[    0.253719] pci 0000:00:02.0: reg 1c 32bit mmio: [0xf7ec0000-0xf7efffff]
[    0.253828] pci 0000:00:02.1: reg 10 32bit mmio: [0xf7f80000-0xf7ffffff]
[    0.254079] pci 0000:00:1b.0: reg 10 64bit mmio: [0xf7eb8000-0xf7ebbfff]
[    0.254150] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.254161] pci 0000:00:1b.0: PME# disabled
[    0.254286] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.254296] pci 0000:00:1c.0: PME# disabled
[    0.254425] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.254435] pci 0000:00:1c.1: PME# disabled
[    0.254564] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.254574] pci 0000:00:1c.2: PME# disabled
[    0.254699] pci 0000:00:1d.0: reg 20 io port: [0xe400-0xe41f]
[    0.254823] pci 0000:00:1d.1: reg 20 io port: [0xe480-0xe49f]
[    0.254945] pci 0000:00:1d.2: reg 20 io port: [0xe800-0xe81f]
[    0.255162] pci 0000:00:1d.3: reg 20 io port: [0xe880-0xe89f]
[    0.255294] pci 0000:00:1d.7: reg 10 32bit mmio: [0xf7eb7c00-0xf7eb7fff]
[    0.255380] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.255390] pci 0000:00:1d.7: PME# disabled
[    0.255702] pci 0000:00:1f.0: Force enabled HPET at 0xfed00000
[    0.255716] pci 0000:00:1f.0: quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
[    0.255725] pci 0000:00:1f.0: quirk: region 0480-04bf claimed by ICH6 GPIO
[    0.255806] pci 0000:00:1f.2: reg 10 io port: [0x00-0x07]
[    0.255821] pci 0000:00:1f.2: reg 14 io port: [0x00-0x03]
[    0.255835] pci 0000:00:1f.2: reg 18 io port: [0x00-0x07]
[    0.255850] pci 0000:00:1f.2: reg 1c io port: [0x00-0x03]
[    0.255865] pci 0000:00:1f.2: reg 20 io port: [0xffa0-0xffaf]
[    0.255908] pci 0000:00:1f.2: PME# supported from D3hot
[    0.255918] pci 0000:00:1f.2: PME# disabled
[    0.256036] pci 0000:00:1f.3: reg 20 io port: [0x400-0x41f]
[    0.256320] pci 0000:03:00.0: reg 10 64bit mmio: [0xfbfc0000-0xfbffffff]
[    0.256384] pci 0000:03:00.0: reg 30 32bit mmio: [0xfbfa0000-0xfbfbffff]
[    0.256410] pci 0000:03:00.0: PME# supported from D3hot D3cold
[    0.256421] pci 0000:03:00.0: PME# disabled
[    0.256540] pci 0000:00:1c.1: bridge 32bit mmio: [0xfbf00000-0xfbffffff]
[    0.256675] pci 0000:01:00.0: reg 10 64bit mmio: [0xfbef0000-0xfbefffff]
[    0.256876] pci 0000:00:1c.2: bridge 32bit mmio: [0xf8000000-0xfbefffff]
[    0.256891] pci 0000:00:1c.2: bridge 64bit mmio pref: [0xf0000000-0xf6ffffff]
[    0.257038] pci 0000:00:1e.0: transparent bridge
[    0.257103] bus 00 -> node 0
[    0.257153] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.260251] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P3._PRT]
[    0.260861] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P5._PRT]
[    0.261451] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P6._PRT]
[    0.312191] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 *5 6 7 10 11 12 14 15)
[    0.312874] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[    0.313566] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    0.314250] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *7 10 11 12 14 15)
[    0.314912] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.315592] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.316272] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.316936] ACPI: PCI Interrupt Link [LNKH] (IRQs *3 4 5 6 7 10 11 12 14 15)
[    0.320596] SCSI subsystem initialized
[    0.320799] libata version 3.00 loaded.
[    0.322113] usbcore: registered new interface driver usbfs
[    0.322478] usbcore: registered new interface driver hub
[    0.323094] usbcore: registered new device driver usb
[    0.325685] PCI: Using ACPI for IRQ routing
[    0.328089] cfg80211: Using static regulatory domain info
[    0.328097] cfg80211: Regulatory domain: US
[    0.328101]     (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[    0.328108]     (2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, 2700 mBm)
[    0.328114]     (5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.328120]     (5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.328127]     (5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.328133]     (5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[    0.328139]     (5735000 KHz - 5835000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
[    0.328146] cfg80211: Calling CRDA for country: US
[    0.329087] hpet clockevent registered
[    0.329102] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.329116] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.329129] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.332092] pnp: PnP ACPI init
[    0.332172] ACPI: bus type pnp registered
[    0.349324] pnp: PnP ACPI: found 13 devices
[    0.349332] ACPI: ACPI bus type pnp unregistered
[    0.349397] system 00:01: iomem range 0xfed13000-0xfed19fff has been reserved
[    0.349443] system 00:08: ioport range 0x380-0x383 has been reserved
[    0.349453] system 00:08: ioport range 0x4d0-0x4d1 has been reserved
[    0.349462] system 00:08: ioport range 0x800-0x87f has been reserved
[    0.349471] system 00:08: ioport range 0x480-0x4bf has been reserved
[    0.349481] system 00:08: iomem range 0xfed1c000-0xfed1ffff has been reserved
[    0.349490] system 00:08: iomem range 0xfed20000-0xfed8ffff has been reserved
[    0.349503] system 00:08: iomem range 0xfff00000-0xffffffff could not be reserved
[    0.349534] system 00:09: iomem range 0xfec00000-0xfec00fff has been reserved
[    0.349543] system 00:09: iomem range 0xfee00000-0xfee00fff has been reserved
[    0.349573] system 00:0a: iomem range 0xe0000000-0xefffffff has been reserved
[    0.349603] system 00:0b: iomem range 0xe0000000-0xefffffff has been reserved
[    0.349638] system 00:0c: iomem range 0x0-0x9ffff could not be reserved
[    0.349649] system 00:0c: iomem range 0xe0000-0xfffff could not be reserved
[    0.349661] system 00:0c: iomem range 0x100000-0x3f7fffff could not be reserved
[    0.389714] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:04
[    0.389720] pci 0000:00:1c.0:   IO window: disabled
[    0.389733] pci 0000:00:1c.0:   MEM window: disabled
[    0.389743] pci 0000:00:1c.0:   PREFETCH window: disabled
[    0.389758] pci 0000:00:1c.1: PCI bridge, secondary bus 0000:03
[    0.389762] pci 0000:00:1c.1:   IO window: disabled
[    0.389775] pci 0000:00:1c.1:   MEM window: 0xfbf00000-0xfbffffff
[    0.389784] pci 0000:00:1c.1:   PREFETCH window: disabled
[    0.389799] pci 0000:00:1c.2: PCI bridge, secondary bus 0000:01
[    0.389804] pci 0000:00:1c.2:   IO window: disabled
[    0.389816] pci 0000:00:1c.2:   MEM window: 0xf8000000-0xfbefffff
[    0.389827] pci 0000:00:1c.2:   PREFETCH window: 0x000000f0000000-0x000000f6ffffff
[    0.389842] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:05
[    0.389847] pci 0000:00:1e.0:   IO window: disabled
[    0.389858] pci 0000:00:1e.0:   MEM window: disabled
[    0.389867] pci 0000:00:1e.0:   PREFETCH window: disabled
[    0.389910] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.389925] pci 0000:00:1c.0: setting latency timer to 64
[    0.389950] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    0.389962] pci 0000:00:1c.1: setting latency timer to 64
[    0.389984] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    0.390008] pci 0000:00:1c.2: setting latency timer to 64
[    0.390025] pci 0000:00:1e.0: setting latency timer to 64
[    0.390034] bus: 00 index 0 io port: [0x00-0xffff]
[    0.390040] bus: 00 index 1 mmio: [0x000000-0xffffffff]
[    0.390045] bus: 04 index 0 mmio: [0x0-0x0]
[    0.390049] bus: 04 index 1 mmio: [0x0-0x0]
[    0.390054] bus: 04 index 2 mmio: [0x0-0x0]
[    0.390058] bus: 04 index 3 mmio: [0x0-0x0]
[    0.390063] bus: 03 index 0 mmio: [0x0-0x0]
[    0.390068] bus: 03 index 1 mmio: [0xfbf00000-0xfbffffff]
[    0.390073] bus: 03 index 2 mmio: [0x0-0x0]
[    0.390077] bus: 03 index 3 mmio: [0x0-0x0]
[    0.390082] bus: 01 index 0 mmio: [0x0-0x0]
[    0.390087] bus: 01 index 1 mmio: [0xf8000000-0xfbefffff]
[    0.390092] bus: 01 index 2 mmio: [0xf0000000-0xf6ffffff]
[    0.390097] bus: 01 index 3 mmio: [0x0-0x0]
[    0.390101] bus: 05 index 0 mmio: [0x0-0x0]
[    0.390106] bus: 05 index 1 mmio: [0x0-0x0]
[    0.390110] bus: 05 index 2 mmio: [0x0-0x0]
[    0.390115] bus: 05 index 3 io port: [0x00-0xffff]
[    0.390120] bus: 05 index 4 mmio: [0x000000-0xffffffff]
[    0.390167] NET: Registered protocol family 2
[    0.390770] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.391471] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.393324] TCP bind hash table entries: 65536 (order: 9, 2097152 bytes)
[    0.409284] TCP: Hash tables configured (established 131072 bind 65536)
[    0.409381] TCP reno registered
[    0.409762] NET: Registered protocol family 1
[    0.411596] pci 0000:00:02.0: Boot video device
[    0.424162] ACPI: EC: non-query interrupt received, switching to interrupt mode
[    0.829981] Switched to high resolution mode on CPU 0
[    2.956769] ACPI: Battery Slot [BAT0] (battery present)
[    2.958980] input: Power Button (FF) as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    2.959082] ACPI: Power Button (FF) [PWRF]
[    2.959868] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input1
[    2.974875] ACPI: Lid Switch [LID]
[    2.975563] input: Sleep Button (CM) as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input2
[    2.975578] ACPI: Sleep Button (CM) [SLPB]
[    2.976224] input: Power Button (CM) as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input3
[    2.976236] ACPI: Power Button (CM) [PWRB]
[    3.002784] thermal LNXTHERM:01: registered as thermal_zone0
[    3.731505] ACPI: Thermal Zone [TZ00] (59 C)
[    3.731881] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    3.732056] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    3.732113] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    3.732123] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    3.733792] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    3.737829] ehci_hcd 0000:00:1d.7: debug port 1
[    3.737843] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
[    3.737921] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xf7eb7c00
[    3.747027] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    3.748035] usb usb1: configuration #1 chosen from 1 choice
[    3.748726] hub 1-0:1.0: USB hub found
[    3.748849] hub 1-0:1.0: 8 ports detected
[    3.751532] uhci_hcd: USB Universal Host Controller Interface driver
[    3.751628] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    3.751654] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    3.751663] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    3.752308] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    3.752386] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000e400
[    3.753291] usb usb2: configuration #1 chosen from 1 choice
[    3.753773] hub 2-0:1.0: USB hub found
[    3.753907] hub 2-0:1.0: 2 ports detected
[    3.755267] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    3.755293] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    3.755302] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    3.755811] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    3.755913] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000e480
[    3.756866] usb usb3: configuration #1 chosen from 1 choice
[    3.757352] hub 3-0:1.0: USB hub found
[    3.757404] hub 3-0:1.0: 2 ports detected
[    3.758691] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    3.758718] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    3.758726] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    3.759227] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    3.759335] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000e800
[    3.760267] usb usb4: configuration #1 chosen from 1 choice
[    3.760737] hub 4-0:1.0: USB hub found
[    3.760783] hub 4-0:1.0: 2 ports detected
[    3.761991] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 16 (level, low) -> IRQ 16
[    3.762117] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    3.762126] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    3.762575] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    3.762675] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000e880
[    3.763522] usb usb5: configuration #1 chosen from 1 choice
[    3.763975] hub 5-0:1.0: USB hub found
[    3.764121] hub 5-0:1.0: 2 ports detected
[    3.766935] Machine check exception polling timer started.
[    3.771437] Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    3.771810] alg: cipher: Test 1 failed on encryption for aes-asm
[    3.771878] 00000000: 00 01 02 03 04 05 06 07 08 08 08 08 08 08 08 08 
[    3.773635] ====[ backtrace testing ]===========
[    3.773642] Testing a backtrace from process context.
[    3.773646] The following trace is a kernel self test and not a bug!
[    3.773654] Pid: 1, comm: swapper Not tainted 2.6.28skw-00025-gaee9cf6 #7
[    3.773661] Call Trace:
[    3.773677]  [<c01504a0>] ? backtrace_regression_test+0x0/0xe0
[    3.773687]  [<c01504d5>] backtrace_regression_test+0x35/0xe0
[    3.773698]  [<c01ba2e6>] ? proc_create_data+0x66/0xb0
[    3.773709]  [<c054e6d0>] ? kallsyms_init+0x0/0x30
[    3.773717]  [<c054e6f4>] ? kallsyms_init+0x24/0x30
[    3.773725]  [<c01504a0>] ? backtrace_regression_test+0x0/0xe0
[    3.773733]  [<c010111b>] do_one_initcall+0x2b/0x190
[    3.773741]  [<c01486db>] ? __lock_acquire+0x2db/0x1410
[    3.773750]  [<c014a08d>] ? trace_hardirqs_on_caller+0xbd/0x150
[    3.773758]  [<c014a12b>] ? trace_hardirqs_on+0xb/0x10
[    3.773767]  [<c021f5ea>] ? ida_get_new_above+0x10a/0x180
[    3.773775]  [<c021f5ea>] ? ida_get_new_above+0x10a/0x180
[    3.773784]  [<c01ba208>] ? proc_register+0x148/0x1c0
[    3.773792]  [<c03e5fe2>] ? _spin_unlock+0x22/0x30
[    3.773800]  [<c01ba208>] ? proc_register+0x148/0x1c0
[    3.773809]  [<c01ba38a>] ? create_proc_entry+0x5a/0xa0
[    3.773818]  [<c0152d4e>] ? register_irq_proc+0x8e/0xa0
[    3.773826]  [<c0152d9d>] ? init_irq_proc+0x3d/0x50
[    3.773835]  [<c053c88a>] kernel_init+0x8a/0xf0
[    3.773842]  [<c053c800>] ? kernel_init+0x0/0xf0
[    3.773850]  [<c0104033>] kernel_thread_helper+0x7/0x10
[    3.773855] Testing a backtrace from irq context.
[    3.773859] The following trace is a kernel self test and not a bug!
[    3.773879] Pid: 3, comm: ksoftirqd/0 Not tainted 2.6.28skw-00025-gaee9cf6 #7
[    3.773884] Call Trace:
[    3.773891]  [<c014a04f>] ? trace_hardirqs_on_caller+0x7f/0x150
[    3.773900]  [<c015048d>] backtrace_test_irq_callback+0xd/0x20
[    3.773911]  [<c012ae54>] tasklet_action+0x44/0x90
[    3.773919]  [<c012ab06>] __do_softirq+0x66/0x110
[    3.773926]  [<c012abd8>] ? do_softirq+0x28/0x60
[    3.773934]  [<c012acd0>] ? ksoftirqd+0x0/0xb0
[    3.773941]  [<c012acd0>] ? ksoftirqd+0x0/0xb0
[    3.773948]  [<c012ac05>] do_softirq+0x55/0x60
[    3.773956]  [<c012ad15>] ksoftirqd+0x45/0xb0
[    3.773964]  [<c0139166>] kthread+0x46/0x80
[    3.773971]  [<c0139120>] ? kthread+0x0/0x80
[    3.773978]  [<c0104033>] kernel_thread_helper+0x7/0x10
[    3.773991] Testing a saved backtrace.
[    3.773995] The following trace is a kernel self test and not a bug!
[    3.774137]  [<c010bd60>] save_stack_trace+0x30/0x50
[    3.774150]  [<c015055d>] backtrace_regression_test+0xbd/0xe0
[    3.774159]  [<c010111b>] do_one_initcall+0x2b/0x190
[    3.774166]  [<c053c88a>] kernel_init+0x8a/0xf0
[    3.774173]  [<c0104033>] kernel_thread_helper+0x7/0x10
[    3.774181]  [<ffffffff>] 0xffffffff
[    3.774187] ====[ end of backtrace testing ]====
[    3.774836] highmem bounce pool size: 64 pages
[    3.821370] fuse init (API version 7.10)
[    3.822930] msgmni has been set to 1737
[    3.824674] alg: No test for stdrng (krng)
[    3.824787] io scheduler noop registered
[    3.824794] io scheduler deadline registered (default)
[    3.825646] pcieport-driver 0000:00:1c.0: setting latency timer to 64
[    3.825735] pcieport-driver 0000:00:1c.0: found MSI capability
[    3.825803] pcieport-driver 0000:00:1c.0: irq 287 for MSI/MSI-X
[    3.825839] pci_express 0000:00:1c.0:pcie00: allocate port service
[    3.826345] pci_express 0000:00:1c.0:pcie02: allocate port service
[    3.826708] pci_express 0000:00:1c.0:pcie03: allocate port service
[    3.827205] pcieport-driver 0000:00:1c.1: setting latency timer to 64
[    3.827290] pcieport-driver 0000:00:1c.1: found MSI capability
[    3.827354] pcieport-driver 0000:00:1c.1: irq 286 for MSI/MSI-X
[    3.827388] pci_express 0000:00:1c.1:pcie00: allocate port service
[    3.827780] pci_express 0000:00:1c.1:pcie02: allocate port service
[    3.828256] pci_express 0000:00:1c.1:pcie03: allocate port service
[    3.828747] pcieport-driver 0000:00:1c.2: setting latency timer to 64
[    3.828835] pcieport-driver 0000:00:1c.2: found MSI capability
[    3.828897] pcieport-driver 0000:00:1c.2: irq 285 for MSI/MSI-X
[    3.828933] pci_express 0000:00:1c.2:pcie00: allocate port service
[    3.829321] pci_express 0000:00:1c.2:pcie02: allocate port service
[    3.829684] pci_express 0000:00:1c.2:pcie03: allocate port service
[    3.830900] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    3.834437] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    3.836923] ACPI: AC Adapter [AC0] (on-line)
[    3.841961] ACPI: CPU0 (power states: C1[C1] C2[C2] C3[C3])
[    3.842491] processor ACPI_CPU:00: registered as cooling_device0
[    3.842513] ACPI: Processor [CPU1] (supports 8 throttling states)
[    3.875825] Non-volatile memory driver v1.2
[    3.875833] Linux agpgart interface v0.103
[    3.875930] agpgart-intel 0000:00:00.0: Intel 915GM Chipset
[    3.876257] agpgart-intel 0000:00:00.0: detected 7932K stolen memory
[    3.880292] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    3.881132] [drm] Initialized drm 1.1.0 20060810
[    3.881303] pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    3.881317] pci 0000:00:02.0: setting latency timer to 64
[    3.881455] [drm:i915_gem_detect_bit_6_swizzle] *ERROR* Couldn't read from MCHBAR.  Disabling tiling.
[    3.882388] [drm] Initialized i915 1.6.0 20080730 on minor 0
[    3.890578] loop: module loaded
[    3.890685] eeepc: Eee PC Hotkey Driver
[    3.891320] eeepc: Hotkey init flags 0x41
[    3.893599] eeepc: Get control methods supported: 0x101711
[    3.894244] input: Asus EeePC extra buttons as /devices/virtual/input/input4
[    3.902985] Atheros(R) L2 Ethernet Driver - version 2.2.3
[    3.902993] Copyright (c) 2007 Atheros Corporation.
[    3.903139] atl2 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    3.903160] atl2 0000:03:00.0: setting latency timer to 64
[    3.943524] ath5k_pci 0000:01:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    3.943547] ath5k_pci 0000:01:00.0: setting latency timer to 64
[    3.943680] ath5k_pci 0000:01:00.0: registered as 'phy0'
[    3.986160] phy0: Selected rate control algorithm 'minstrel'
[    3.987801] ath5k phy0: Atheros AR2425 chip found (MAC: 0xe2, PHY: 0x70)
[    3.988225] Linux video capture interface: v2.00
[    3.989184] usbcore: registered new interface driver uvcvideo
[    3.989201] USB Video Class driver (v0.1.0)
[    3.989622] Driver 'sd' needs updating - please use bus_type methods
[    3.990111] ahci 0000:00:1f.2: version 3.0
[    3.990148] ahci 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    3.990214] ahci 0000:00:1f.2: PCI INT B disabled
[    3.990249] ahci: probe of 0000:00:1f.2 failed with error -22
[    3.990676] ata_piix 0000:00:1f.2: version 2.12
[    3.990700] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    3.990712] ata_piix 0000:00:1f.2: MAP [ P0 P2 IDE IDE ]
[    3.990893] ata_piix 0000:00:1f.2: setting latency timer to 64
[    3.991211] scsi0 : ata_piix
[    3.993921] scsi1 : ata_piix
[    4.017393] ata1: SATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
[    4.017402] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
[    4.086069] usb 1-5: new high speed USB device using ehci_hcd and address 2
[    4.201911] usb 1-5: configuration #1 chosen from 1 choice
[    4.336391] ata2.00: ATA-5: ASUS-PHISON OB SSD, TST2.04P, max UDMA/66
[    4.336398] ata2.00: 7880544 sectors, multi 0: LBA 
[    4.336475] ata2.01: ATA-5: ASUS-PHISON SSD, TST2.04P, max UDMA/66
[    4.336481] ata2.01: 31522176 sectors, multi 0: LBA 
[    4.339362] ata2.00: configured for UDMA/66
[    4.342356] ata2.01: configured for UDMA/66
[    4.343345] scsi 1:0:0:0: Direct-Access     ATA      ASUS-PHISON OB S TST2 PQ: 0 ANSI: 5
[    4.345602] sd 1:0:0:0: [sda] 7880544 512-byte hardware sectors: (4.03 GB/3.75 GiB)
[    4.345715] sd 1:0:0:0: [sda] Write Protect is off
[    4.345723] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    4.345919] sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    4.346996] sd 1:0:0:0: [sda] 7880544 512-byte hardware sectors: (4.03 GB/3.75 GiB)
[    4.347128] sd 1:0:0:0: [sda] Write Protect is off
[    4.347135] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    4.347333] sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    4.347374]  sda: sda1 sda2 sda3 sda4
[    4.351998] sd 1:0:0:0: [sda] Attached SCSI disk
[    4.352953] scsi 1:0:1:0: Direct-Access     ATA      ASUS-PHISON SSD  TST2 PQ: 0 ANSI: 5
[    4.354567] sd 1:0:1:0: [sdb] 31522176 512-byte hardware sectors: (16.1 GB/15.0 GiB)
[    4.354679] sd 1:0:1:0: [sdb] Write Protect is off
[    4.354686] sd 1:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    4.354876] sd 1:0:1:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    4.355457] sd 1:0:1:0: [sdb] 31522176 512-byte hardware sectors: (16.1 GB/15.0 GiB)
[    4.355565] sd 1:0:1:0: [sdb] Write Protect is off
[    4.355572] sd 1:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    4.355764] sd 1:0:1:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    4.355805]  sdb: sdb1 sdb2
[    4.358999] sd 1:0:1:0: [sdb] Attached SCSI disk
[    4.359790] Initializing USB Mass Storage driver...
[    4.360216] scsi2 : SCSI emulation for USB Mass Storage devices
[    4.361449] usb-storage: device found at 2
[    4.361455] usb-storage: waiting for device to settle before scanning
[    4.361537] usbcore: registered new interface driver usb-storage
[    4.361551] USB Mass Storage support registered.
[    4.362493] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    4.396124] serio: i8042 KBD port at 0x60,0x64 irq 1
[    4.396192] serio: i8042 AUX port at 0x60,0x64 irq 12
[    4.397953] mice: PS/2 mouse device common for all mice
[    4.402338] rtc_cmos 00:03: RTC can wake from S4
[    4.403088] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    4.403145] rtc0: alarms up to one month, 114 bytes nvram, hpet irqs
[    4.405089] cpuidle: using governor ladder
[    4.408209] cpuidle: using governor menu
[    4.408716] Advanced Linux Sound Architecture Driver Version 1.0.18rc3.
[    4.410090] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.410213] HDA Intel 0000:00:1b.0: setting latency timer to 64
[    4.412055] Marking TSC unstable due to TSC halts in idle
[    4.413591] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input5
[    4.418158] hda_codec: Unknown model for ALC662, trying auto-probe from BIOS...
[    4.418572] autoconfig: line_outs=1 (0x14/0x0/0x0/0x0/0x0)
[    4.418577]    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
[    4.418582]    hp_outs=1 (0x1b/0x0/0x0/0x0/0x0)
[    4.418586]    mono: mono_out=0x0
[    4.418591]    inputs: mic=0x18, fmic=0x19, line=0x0, fline=0x0, cd=0x0, aux=0x0
[    4.445883] ALSA device list:
[    4.445892]   #0: HDA Intel at 0xf7eb8000 irq 16
[    4.446105] TCP cubic registered
[    4.446114] NET: Registered protocol family 17
[    4.446413] Using IPI Shortcut mode
[    4.449490]   Magic number: 9:106:77
[    4.449741] rtc_cmos 00:03: setting system clock to
[    4.456450] kjournald starting.  Commit interval 5 seconds
[    4.456771] EXT3-fs: mounted filesystem with ordered data mode.
[    4.456946] VFS: Mounted root (ext3 filesystem) readonly.
[    4.457139] debug: unmapping init memory c053c000..c0584000
[    4.457204] Write protecting the kernel read-only data: 980k
[    4.457212] Testing CPA: undo c03e8000-c04dd000
[    4.457249] Testing CPA: write protecting again
[    4.829041] Clocksource tsc unstable (delta = -111952222 ns)
[    6.618969] input: ImPS/2 Logitech Wheel Mouse as /devices/platform/i8042/serio1/input/input6
[    9.368715] usb-storage: device scan complete
[    9.369947] scsi 2:0:0:0: Direct-Access     USB2.0   CardReader SD0   0100 PQ: 0 ANSI: 0
[    9.874742] sd 2:0:0:0: [sdc] 15661056 512-byte hardware sectors: (8.01 GB/7.46 GiB)
[    9.879780] sd 2:0:0:0: [sdc] Write Protect is on
[    9.879792] sd 2:0:0:0: [sdc] Mode Sense: 03 00 80 00
[    9.879797] sd 2:0:0:0: [sdc] Assuming drive cache: write through
[    9.888377] sd 2:0:0:0: [sdc] 15661056 512-byte hardware sectors: (8.01 GB/7.46 GiB)
[    9.889058] sd 2:0:0:0: [sdc] Write Protect is on
[    9.889070] sd 2:0:0:0: [sdc] Mode Sense: 03 00 80 00
[    9.889075] sd 2:0:0:0: [sdc] Assuming drive cache: write through
[    9.889182]  sdc: sdc1 sdc2
[    9.893096] sd 2:0:0:0: [sdc] Attached SCSI removable disk
[   10.389897] EXT3 FS on sdb2, internal journal
[   15.162588] warning: `avahi-daemon' uses 32-bit capabilities (legacy support in use)
[   21.698674] atl2 0000:03:00.0: irq 284 for MSI/MSI-X
[   21.905451] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[   33.771047] CPA self-test:
[   33.778275]  4k 227326 large 0 gb 0 x 227326[c0000000-f77fd000] miss 0
[   33.791393]  4k 227326 large 0 gb 0 x 227326[c0000000-f77fd000] miss 0
[   33.803430]  4k 227326 large 0 gb 0 x 227326[c0000000-f77fd000] miss 0
[   33.803435] ok.
[   64.089063] kjournald starting.  Commit interval 5 seconds
[   64.089137] EXT3-fs: mounted filesystem with ordered data mode.
[  125.684886] atl2: eth0 NIC Link is Down
[  127.459033] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[  148.170925] atl2: eth0 NIC Link is Down
[  149.736346] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[  199.704086] ------------[ cut here ]------------
[  199.704095] WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x22b/0x240()
[  199.704101] NETDEV WATCHDOG: eth0 (atl2): transmit timed out
[  199.704108] Pid: 0, comm: swapper Not tainted 2.6.28skw-00025-gaee9cf6 #7
[  199.704113] Call Trace:
[  199.704124]  [<c0126373>] warn_slowpath+0x63/0x80
[  199.704135]  [<c0140030>] ? timekeeping_resume+0xc0/0xf0
[  199.704146]  [<c022366e>] ? strlcpy+0x1e/0x60
[  199.704153]  [<c037bf5b>] dev_watchdog+0x22b/0x240
[  199.704162]  [<c03e5fb7>] ? _spin_unlock_irq+0x27/0x30
[  199.704170]  [<c014a04f>] ? trace_hardirqs_on_caller+0x7f/0x150
[  199.704178]  [<c014a12b>] ? trace_hardirqs_on+0xb/0x10
[  199.704186]  [<c012eafd>] run_timer_softirq+0x14d/0x1b0
[  199.704193]  [<c037bd30>] ? dev_watchdog+0x0/0x240
[  199.704202]  [<c012aadd>] ? __do_softirq+0x3d/0x110
[  199.704208]  [<c037bd30>] ? dev_watchdog+0x0/0x240
[  199.704216]  [<c012ab06>] __do_softirq+0x66/0x110
[  199.704224]  [<c012abd8>] ? do_softirq+0x28/0x60
[  199.704232]  [<c012ac05>] do_softirq+0x55/0x60
[  199.704239]  [<c012af67>] irq_exit+0x67/0x80
[  199.704247]  [<c0105745>] do_IRQ+0x65/0xc0
[  199.704254]  [<c0103ea8>] common_interrupt+0x28/0x30
[  199.704262]  [<c014007b>] ? sync_cmos_clock+0x1b/0xb0
[  199.704271]  [<c0277f13>] ? acpi_idle_enter_bm+0x1f2/0x223
[  199.704279]  [<c0337928>] cpuidle_idle_call+0x68/0xc0
[  199.704286]  [<c0101f2b>] cpu_idle+0x3b/0x80
[  199.704293]  [<c03da22d>] rest_init+0x4d/0x60
[  199.704299] ---[ end trace ca504f9549dfa3d7 ]---
[  199.721768] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[  489.684342] atl2: eth0 NIC Link is Down
[  491.228341] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[  524.229219] atl2: eth0 NIC Link is Down
[  526.230303] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[  653.678521] atl2: eth0 NIC Link is Down
[12528.044606] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[12579.050877] atl2: eth0 NIC Link is Down
[12580.586905] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[12638.602659] atl2: eth0 NIC Link is Down
[12640.146880] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[12650.004641] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[12760.004704] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[12783.604047] [drm:i915_get_vblank_counter] *ERROR* trying to get vblank count for disabled pipe 0
[12810.004779] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[12860.006681] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[12915.004765] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[12965.004910] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[13015.007530] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>

Notice the strange NIC Link is Up messages without a corresponding Link down (these could happen 
when the cable was not properly plugged in but could also happen in pairs when the cable was fully
plugged in).

> obtain it next time it occurs.  Meanwhile, please see if this patch
> helps.


      
