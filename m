From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: APIC error on 32-bit kernel
Date: Fri, 23 Mar 2007 20:08:17 -0500
Message-ID: <20070323200817.1f3e39b9@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_AJAMQsa=RERfbfFmaQBZEfB"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf24aec.mail.bellsouth.net ([205.152.59.72]:35040 "EHLO
	imf24aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S2992654AbXCXBIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 21:08:45 -0400
Received: from ibm70aec.bellsouth.net ([70.144.210.96])
          by imf24aec.mail.bellsouth.net with ESMTP
          id <20070324010843.RDTV806.imf24aec.mail.bellsouth.net@ibm70aec.bellsouth.net>
          for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 21:08:43 -0400
Received: from osprey.hogchain.net ([70.144.210.96])
          by ibm70aec.bellsouth.net with ESMTP
          id <20070324010840.RWTE29680.ibm70aec.bellsouth.net@osprey.hogchain.net>
          for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 21:08:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--MP_AJAMQsa=RERfbfFmaQBZEfB
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

We're trying to track down the source of a problem that occurs whenever
the atl1 network driver is activated on a 32-bit 2.6.21-rc4 kernel.  We
need help from netdev.

We can load the driver just fine, but whenever we activate the
network, we see APIC errors (a sample of them are shown here,
captured from a serial console):

[root@hawk ~]# echo 8 > /proc/sys/kernel/printk
[root@hawk ~]# [   93.942012] process `sysctl' is using deprecated
sysctl (sysc.
[   94.396609] atl1: eth0 link is up 1000 Mbps full duplex
[   94.498887] APIC error on CPU0: 00(08)
[   94.498534] APIC error on CPU1: 00(08)
[   94.550079] APIC error on CPU0: 08(08)
[   94.549725] APIC error on CPU1: 08(08)
[   94.600915] APIC error on CPU1: 08(08)
[   94.601276] APIC error on CPU0: 08(08)
[   94.652108] APIC error on CPU1: 08(08)
[   94.652470] APIC error on CPU0: 08(08)
[   94.703659] APIC error on CPU0: 08(08)
[   94.703305] APIC error on CPU1: 08(08)
[   94.754852] APIC error on CPU0: 08(40)
[   94.806045] APIC error on CPU0: 40(08)
[   94.805692] APIC error on CPU1: 08(08)
[   94.857238] APIC error on CPU0: 08(08)
[   94.856884] APIC error on CPU1: 08(08)
[   94.908432] APIC error on CPU0: 08(08)
[   94.908078] APIC error on CPU1: 08(08)
[snip, more of the same]
[   98.901156] APIC error on CPU1: 08(08)
[   98.952702] APIC error on CPU0: 08(08)
[   98.952349] APIC error on CPU1: 08(08)
[   99.003895] APIC error on CPU0: 08(08)
[   99.003542] APIC error on CPU1: 08(08)

The machine hangs for about 5-10 seconds, then spontaneously reboots
without further console output.

This is an Asus M2V (Via K8T890) motherboard.

The problem does not occur on a 32-bit kernel if we boot with
pci=nomsi, and it doesn't occur at all on a 64-bit kernel on the same
motherboard.

We also do not see this problem on Intel-based motherboards, with
either 32- or 64-bit kernels.

We'd appreciate any pointers to get this solved.  Full error text,
dmesg (with atl1 device disabled), lspci, and /proc/interrupts attached.

Thanks,
Jay


--MP_AJAMQsa=RERfbfFmaQBZEfB
Content-Type: text/plain; name=hawk-apic-error-20070321.txt
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=hawk-apic-error-20070321.txt

[root@hawk ~]# echo 8 > /proc/sys/kernel/printk
[root@hawk ~]# [   93.942012] process `sysctl' is using deprecated sysctl (sysc.
[   94.396609] atl1: eth0 link is up 1000 Mbps full duplex
[   94.498887] APIC error on CPU0: 00(08)
[   94.498534] APIC error on CPU1: 00(08)
[   94.550079] APIC error on CPU0: 08(08)
[   94.549725] APIC error on CPU1: 08(08)
[   94.600915] APIC error on CPU1: 08(08)
[   94.601276] APIC error on CPU0: 08(08)
[   94.652108] APIC error on CPU1: 08(08)
[   94.652470] APIC error on CPU0: 08(08)
[   94.703659] APIC error on CPU0: 08(08)
[   94.703305] APIC error on CPU1: 08(08)
[   94.754852] APIC error on CPU0: 08(40)
[   94.806045] APIC error on CPU0: 40(08)
[   94.805692] APIC error on CPU1: 08(08)
[   94.857238] APIC error on CPU0: 08(08)
[   94.856884] APIC error on CPU1: 08(08)
[   94.908432] APIC error on CPU0: 08(08)
[   94.908078] APIC error on CPU1: 08(08)
[   94.959625] APIC error on CPU0: 08(08)
[   94.959271] APIC error on CPU1: 08(08)
[   95.010462] APIC error on CPU1: 08(08)
[   95.010824] APIC error on CPU0: 08(08)
[   95.062012] APIC error on CPU0: 08(08)
[   95.061658] APIC error on CPU1: 08(08)
[   95.113205] APIC error on CPU0: 08(08)
[   95.112851] APIC error on CPU1: 08(08)
[   95.164398] APIC error on CPU0: 08(08)
[   95.164044] APIC error on CPU1: 08(08)
[   95.215235] APIC error on CPU1: 08(08)
[   95.215596] APIC error on CPU0: 08(08)
[   95.266785] APIC error on CPU0: 08(08)
[   95.266431] APIC error on CPU1: 08(08)
[   95.317978] APIC error on CPU0: 08(08)
[   95.317624] APIC error on CPU1: 08(08)
[   95.368814] APIC error on CPU1: 08(08)
[   95.369175] APIC error on CPU0: 08(08)
[   95.420365] APIC error on CPU0: 08(08)
[   95.420011] APIC error on CPU1: 08(08)
[   95.471201] APIC error on CPU1: 08(08)
[   95.471561] APIC error on CPU0: 08(08)
[   95.522751] APIC error on CPU0: 08(08)
[   95.522398] APIC error on CPU1: 08(08)
[   95.573944] APIC error on CPU0: 08(08)
[   95.573591] APIC error on CPU1: 08(08)
[   95.625138] APIC error on CPU0: 08(08)
[   95.624784] APIC error on CPU1: 08(08)
[   95.675974] APIC error on CPU1: 08(08)
[   95.676335] APIC error on CPU0: 08(08)
[   95.727167] APIC error on CPU1: 08(08)
[   95.727527] APIC error on CPU0: 08(08)
[   95.778720] APIC error on CPU0: 08(08)
[   95.778367] APIC error on CPU1: 08(08)
[   95.829911] APIC error on CPU0: 08(08)
[   95.829557] APIC error on CPU1: 08(08)
[   95.881104] APIC error on CPU0: 08(08)
[   95.880750] APIC error on CPU1: 08(08)
[   95.932297] APIC error on CPU0: 08(08)
[   95.931943] APIC error on CPU1: 08(08)
[   95.983490] APIC error on CPU0: 08(08)
[   95.983137] APIC error on CPU1: 08(08)
[   96.034327] APIC error on CPU1: 08(08)
[   96.034689] APIC error on CPU0: 08(08)
[   96.085520] APIC error on CPU1: 08(08)
[   96.085881] APIC error on CPU0: 08(08)
[   96.136714] APIC error on CPU1: 08(08)
[   96.137074] APIC error on CPU0: 08(08)
[   96.188264] APIC error on CPU0: 08(08)
[   96.187910] APIC error on CPU1: 08(08)
[   96.239457] APIC error on CPU0: 08(08)
[   96.239103] APIC error on CPU1: 08(08)
[   96.290650] APIC error on CPU0: 08(08)
[   96.290297] APIC error on CPU1: 08(08)
[   96.341844] APIC error on CPU0: 08(08)
[   96.341490] APIC error on CPU1: 08(08)
[   96.392680] APIC error on CPU1: 08(08)
[   96.393042] APIC error on CPU0: 08(08)
[   96.443873] APIC error on CPU1: 08(08)
[   96.444234] APIC error on CPU0: 08(08)
[   96.495425] APIC error on CPU0: 08(08)
[   96.495073] APIC error on CPU1: 08(08)
[   96.546620] APIC error on CPU0: 08(08)
[   96.546268] APIC error on CPU1: 08(08)
[   96.597456] APIC error on CPU1: 08(08)
[   96.597818] APIC error on CPU0: 08(08)
[   96.648649] APIC error on CPU1: 08(08)
[   96.649012] APIC error on CPU0: 08(08)
[   96.700199] APIC error on CPU0: 08(08)
[   96.699848] APIC error on CPU1: 08(08)
[   96.751391] APIC error on CPU0: 08(08)
[   96.751038] APIC error on CPU1: 08(08)
[   96.802584] APIC error on CPU0: 08(08)
[   96.802231] APIC error on CPU1: 08(08)
[   96.853777] APIC error on CPU0: 08(08)
[   96.853424] APIC error on CPU1: 08(08)
[   96.904970] APIC error on CPU0: 08(08)
[   96.904617] APIC error on CPU1: 08(08)
[   96.956164] APIC error on CPU0: 08(08)
[   96.955810] APIC error on CPU1: 08(08)
[   97.007357] APIC error on CPU0: 08(08)
[   97.007004] APIC error on CPU1: 08(08)
[   97.058551] APIC error on CPU0: 08(08)
[   97.058197] APIC error on CPU1: 08(08)
[   97.109744] APIC error on CPU0: 08(08)
[   97.109391] APIC error on CPU1: 08(08)
[   97.160937] APIC error on CPU0: 08(08)
[   97.160583] APIC error on CPU1: 08(08)
[   97.212130] APIC error on CPU0: 08(08)
[   97.211777] APIC error on CPU1: 08(08)
[   97.263324] APIC error on CPU0: 08(08)
[   97.262970] APIC error on CPU1: 08(08)
[   97.314517] APIC error on CPU0: 08(08)
[   97.314163] APIC error on CPU1: 08(08)
[   97.365710] APIC error on CPU0: 08(08)
[   97.365357] APIC error on CPU1: 08(08)
[   97.416904] APIC error on CPU0: 08(08)
[   97.416551] APIC error on CPU1: 08(08)
[   97.467741] APIC error on CPU1: 08(08)
[   97.468102] APIC error on CPU0: 08(08)
[   97.518934] APIC error on CPU1: 08(08)
[   97.519294] APIC error on CPU0: 08(08)
[   97.570127] APIC error on CPU1: 08(08)
[   97.570487] APIC error on CPU0: 08(08)
[   97.621677] APIC error on CPU0: 08(08)
[   97.621325] APIC error on CPU1: 08(08)
[   97.672870] APIC error on CPU0: 08(08)
[   97.672518] APIC error on CPU1: 08(08)
[   97.724063] APIC error on CPU0: 08(08)
[   97.723710] APIC error on CPU1: 08(08)
[   97.775256] APIC error on CPU0: 08(08)
[   97.774903] APIC error on CPU1: 08(08)
[   97.826450] APIC error on CPU0: 08(08)
[   97.826096] APIC error on CPU1: 08(08)
[   97.877643] APIC error on CPU0: 08(08)
[   97.877290] APIC error on CPU1: 08(08)
[   97.928480] APIC error on CPU1: 08(08)
[   97.928840] APIC error on CPU0: 08(08)
[   97.980030] APIC error on CPU0: 08(08)
[   97.979676] APIC error on CPU1: 08(08)
[   98.031223] APIC error on CPU0: 08(08)
[   98.030870] APIC error on CPU1: 08(08)
[   98.082416] APIC error on CPU0: 08(08)
[   98.082063] APIC error on CPU1: 08(08)
[   98.133253] APIC error on CPU1: 08(08)
[   98.133613] APIC error on CPU0: 08(08)
[   98.184446] APIC error on CPU1: 08(08)
[   98.184806] APIC error on CPU0: 08(08)
[   98.235996] APIC error on CPU0: 08(08)
[   98.235643] APIC error on CPU1: 08(08)
[   98.287189] APIC error on CPU0: 08(08)
[   98.286837] APIC error on CPU1: 08(08)
[   98.338383] APIC error on CPU0: 08(08)
[   98.338029] APIC error on CPU1: 08(08)
[   98.389576] APIC error on CPU0: 08(08)
[   98.389223] APIC error on CPU1: 08(08)
[   98.440770] APIC error on CPU0: 08(08)
[   98.440417] APIC error on CPU1: 08(08)
[   98.491963] APIC error on CPU0: 08(08)
[   98.491609] APIC error on CPU1: 08(08)
[   98.543156] APIC error on CPU0: 08(08)
[   98.542805] APIC error on CPU1: 08(08)
[   98.594349] APIC error on CPU0: 08(08)
[   98.593997] APIC error on CPU1: 08(08)
[   98.645543] APIC error on CPU0: 08(08)
[   98.645189] APIC error on CPU1: 08(08)
[   98.696736] APIC error on CPU0: 08(08)
[   98.696383] APIC error on CPU1: 08(08)
[   98.747929] APIC error on CPU0: 08(08)
[   98.747576] APIC error on CPU1: 08(08)
[   98.799122] APIC error on CPU0: 08(08)
[   98.798769] APIC error on CPU1: 08(08)
[   98.850316] APIC error on CPU0: 08(08)
[   98.849963] APIC error on CPU1: 08(08)
[   98.901509] APIC error on CPU0: 08(08)
[   98.901156] APIC error on CPU1: 08(08)
[   98.952702] APIC error on CPU0: 08(08)
[   98.952349] APIC error on CPU1: 08(08)
[   99.003895] APIC error on CPU0: 08(08)
[   99.003542] APIC error on CPU1: 08(08)

 CTRL-A Z for help | 38400 8N1 | NOR | Minicom 2.1    | VT102 |      Offline   


--MP_AJAMQsa=RERfbfFmaQBZEfB
Content-Type: text/plain; name=hawk-dmesg-20070321.txt
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=hawk-dmesg-20070321.txt

Linux version 2.6.21-rc4 (jcliburn@hawk.hogchain.net) (gcc version 4.1.1 20070105 (Red Hat 4.1.1-51)) #1 SMP Mon Mar 19 08:18:18 CDT 2007
BIOS-provided physical RAM map:
sanitize start
sanitize end
copy_e820_map() start: 0000000000000000 size: 000000000009fc00 end: 000000000009fc00 type: 1
copy_e820_map() type is E820_RAM
copy_e820_map() start: 000000000009fc00 size: 0000000000000400 end: 00000000000a0000 type: 2
copy_e820_map() start: 00000000000e4000 size: 000000000001c000 end: 0000000000100000 type: 2
copy_e820_map() start: 0000000000100000 size: 000000003feb0000 end: 000000003ffb0000 type: 1
copy_e820_map() type is E820_RAM
copy_e820_map() start: 000000003ffb0000 size: 000000000000e000 end: 000000003ffbe000 type: 3
copy_e820_map() start: 000000003ffbe000 size: 0000000000022000 end: 000000003ffe0000 type: 4
copy_e820_map() start: 000000003ffe0000 size: 0000000000020000 end: 0000000040000000 type: 2
copy_e820_map() start: 00000000fec00000 size: 0000000000001000 end: 00000000fec01000 type: 2
copy_e820_map() start: 00000000fecc0000 size: 0000000000001000 end: 00000000fecc1000 type: 2
copy_e820_map() start: 00000000ff780000 size: 0000000000880000 end: 0000000100000000 type: 2
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000003ffb0000 (usable)
 BIOS-e820: 000000003ffb0000 - 000000003ffbe000 (ACPI data)
 BIOS-e820: 000000003ffbe000 - 000000003ffe0000 (ACPI NVS)
 BIOS-e820: 000000003ffe0000 - 0000000040000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
 BIOS-e820: 00000000fecc0000 - 00000000fecc1000 (reserved)
 BIOS-e820: 00000000ff780000 - 0000000100000000 (reserved)
127MB HIGHMEM available.
896MB LOWMEM available.
found SMP MP-table at 000ff780
Entering add_active_range(0, 0, 262064) 0 entries of 256 used
Zone PFN ranges:
  DMA             0 ->     4096
  Normal       4096 ->   229376
  HighMem    229376 ->   262064
early_node_map[1] active PFN ranges
    0:        0 ->   262064
On node 0 totalpages: 262064
  DMA zone: 40 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 4056 pages, LIFO batch:0
  Normal zone: 2200 pages used for memmap
  Normal zone: 223080 pages, LIFO batch:31
  HighMem zone: 319 pages used for memmap
  HighMem zone: 32369 pages, LIFO batch:7
DMI present.
Using APIC driver default
ACPI: RSDP 000FA960, 0014 (r0 ACPIAM)
ACPI: RSDT 3FFB0000, 0038 (r1 A M I  OEMRSDT   7000611 MSFT       97)
ACPI: FACP 3FFB0200, 0084 (r2 A M I  OEMFACP   7000611 MSFT       97)
ACPI: DSDT 3FFB0440, 4CCB (r1  A0498 A0498000        0 INTL 20060113)
ACPI: FACS 3FFBE000, 0040
ACPI: APIC 3FFB0390, 0068 (r1 A M I  OEMAPIC   7000611 MSFT       97)
ACPI: MCFG 3FFB0400, 003C (r1 A M I  OEMMCFG   7000611 MSFT       97)
ACPI: OEMB 3FFBE040, 0060 (r1 A M I  AMI_OEM   7000611 MSFT       97)
ACPI: SSDT 3FFB5110, 01C4 (r1 A M I  POWERNOW        1 AMD         1)
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
Processor #0 15:11 APIC version 16
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
Processor #1 15:11 APIC version 16
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 3, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x03] address[0xfecc0000] gsi_base[24])
IOAPIC[1]: apic_id 3, version 3, address 0xfecc0000, GSI 24-47
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 2 I/O APICs
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at 50000000 (gap: 40000000:bec00000)
Built 1 zonelists.  Total pages: 259505
Kernel command line: ro root=/dev/VolGroup00/LogVol00 console=ttyS0,38400 console=tty0
mapped APIC to ffffd000 (fee00000)
mapped IOAPIC to ffffc000 (fec00000)
mapped IOAPIC to ffffb000 (fecc0000)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
CPU 0 irqstacks, hard=c07a5000 soft=c0785000
PID hash table entries: 4096 (order: 12, 16384 bytes)
Detected 1999.904 MHz processor.
Console: colour VGA+ 80x25
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 1029744k/1048256k available (2158k kernel code, 17728k reserved, 1162k data, 240k init, 130752k highmem)
virtual kernel memory layout:
    fixmap  : 0xffc56000 - 0xfffff000   (3748 kB)
    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
    vmalloc : 0xf8800000 - 0xff7fe000   ( 111 MB)
    lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
      .init : 0xc0744000 - 0xc0780000   ( 240 kB)
      .data : 0xc061b9f3 - 0xc073e4d4   (1162 kB)
      .text : 0xc0400000 - 0xc061b9f3   (2158 kB)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay using timer specific routine.. 4000.65 BogoMIPS (lpj=2000329)
Security Framework v1.0.0 initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
selinux_register_security:  Registering secondary module capability
Capability LSM initialized as secondary
Mount-cache hash table entries: 512
CPU: After generic identify, caps: 178bfbff ebd3fbff 00000000 00000000 00002001 00000000 0000001f
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 0(2) -> Core 0
CPU: After all inits, caps: 178bfbff ebd3fbff 00000000 00000410 00002001 00000000 0000001f
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
Checking 'hlt' instruction... OK.
SMP alternatives: switching to UP code
ACPI: Core revision 20070126
CPU0: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ stepping 02
SMP alternatives: switching to SMP code
Booting processor 1/1 eip 3000
CPU 1 irqstacks, hard=c07a6000 soft=c0786000
Initializing CPU#1
Calibrating delay using timer specific routine.. 3999.04 BogoMIPS (lpj=1999521)
CPU: After generic identify, caps: 178bfbff ebd3fbff 00000000 00000000 00002001 00000000 0000001f
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 1(2) -> Core 1
CPU: After all inits, caps: 178bfbff ebd3fbff 00000000 00000410 00002001 00000000 0000001f
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#1.
CPU1: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ stepping 02
Total of 2 processors activated (7999.70 BogoMIPS).
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 apic1=0 pin1=2 apic2=0 pin2=0
Brought up 2 CPUs
migration_cost=182
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: BIOS Bug: MCFG area at e0000000 is not E820-reserved
PCI: Not using MMCONFIG.
PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=8
PCI: Using configuration type 1
Setting up standard PCI resources
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S3 S4 S5)
ACPI: Using IOAPIC for interrupt routing
Error attaching device data
Error attaching device data
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Probing PCI hardware (bus 00)
0000:00:0f.1: cannot adjust BAR0 (not I/O)
0000:00:0f.1: cannot adjust BAR1 (not I/O)
0000:00:0f.1: cannot adjust BAR2 (not I/O)
0000:00:0f.1: cannot adjust BAR3 (not I/O)
Boot video device is 0000:02:00.0
PCI: Transparent bridge - 0000:00:13.1
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NBPG._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NBP0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NBP1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NBP2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NBP3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P7._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0PA._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs *3 4 5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 10 *11 12 14 15)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
pnp: PnP ACPI: found 16 devices
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
pnp: 00:07: ioport range 0xc00-0xc0f has been reserved
Time: tsc clocksource has been installed.
pnp: 00:07: ioport range 0xd00-0xd0f has been reserved
pnp: 00:07: ioport range 0xa20-0xa2f has been reserved
pnp: 00:07: ioport range 0xa30-0xa3f has been reserved
pnp: 00:0a: iomem range 0xfec00000-0xfec00fff has been reserved
pnp: 00:0a: iomem range 0xfee00000-0xfee00fff has been reserved
pnp: 00:0e: iomem range 0xe0000000-0xefffffff has been reserved
pnp: 00:0f: iomem range 0x0-0x9ffff could not be reserved
pnp: 00:0f: iomem range 0xc0000-0xcffff could not be reserved
pnp: 00:0f: iomem range 0xe0000-0xfffff could not be reserved
pnp: 00:0f: iomem range 0x100000-0x3fffffff could not be reserved
PCI: Bridge: 0000:00:01.0
Time: acpi_pm clocksource has been installed.
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:02.0
  IO window: disabled.
  MEM window: f9000000-fbcfffff
  PREFETCH window: d0000000-dfffffff
PCI: Bridge: 0000:00:03.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: f7f00000-f7ffffff
PCI: Bridge: 0000:00:03.1
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: f7e00000-f7efffff
PCI: Bridge: 0000:00:03.2
  IO window: disabled.
  MEM window: fbd00000-fbdfffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:03.3
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: f7d00000-f7dfffff
PCI: Bridge: 0000:00:13.0
  IO window: disabled.
  MEM window: fbf00000-fbffffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:13.1
  IO window: e000-efff
  MEM window: fbe00000-fbefffff
  PREFETCH window: 50000000-500fffff
PCI: Setting latency timer of device 0000:00:01.0 to 64
ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 27 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:02.0 to 64
ACPI: PCI Interrupt 0000:00:03.0[A] -> GSI 31 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:03.0 to 64
ACPI: PCI Interrupt 0000:00:03.1[B] -> GSI 35 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:03.1 to 64
ACPI: PCI Interrupt 0000:00:03.2[C] -> GSI 39 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:03.2 to 64
ACPI: PCI Interrupt 0000:00:03.3[D] -> GSI 43 (level, low) -> IRQ 20
PCI: Setting latency timer of device 0000:00:03.3 to 64
PCI: Setting latency timer of device 0000:00:13.0 to 64
PCI: Setting latency timer of device 0000:00:13.1 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 9, 3145728 bytes)
TCP bind hash table entries: 65536 (order: 8, 1310720 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
checking if image is initramfs... it is
Freeing initrd memory: 2263k freed
apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)
apm: disabled - APM is not SMP safe.
audit: initializing netlink socket (disabled)
audit(1174469313.375:1): initialized
highmem bounce pool size: 64 pages
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
SELinux:  Registering netfilter hooks
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
PCI: Setting latency timer of device 0000:00:02.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:02.0:pcie00]
Allocate Port Service[0000:00:02.0:pcie02]
PCI: Setting latency timer of device 0000:00:03.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:03.0:pcie00]
Allocate Port Service[0000:00:03.0:pcie02]
PCI: Setting latency timer of device 0000:00:03.1 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:03.1:pcie00]
Allocate Port Service[0000:00:03.1:pcie02]
PCI: Setting latency timer of device 0000:00:03.2 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:03.2:pcie00]
Allocate Port Service[0000:00:03.2:pcie02]
PCI: Setting latency timer of device 0000:00:03.3 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:03.3:pcie00]
Allocate Port Service[0000:00:03.3:pcie02]
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
ACPI: Processor [P001] (supports 16 throttling states)
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
Real Time Clock Driver v1.12ac
Non-volatile memory driver v1.2
Linux agpgart interface v0.102 (c) Dave Jones
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:0b: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 16384K size 4096 blocksize
input: Macintosh mouse button emulation as /class/input/input0
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
VP_IDE: IDE controller at PCI slot 0000:00:0f.1
VP_IDE: chipset revision 7
VP_IDE: not 100% native mode: will probe irqs later
VP_IDE: VIA vt8237a (rev 00) IDE UDMA133 controller on pci0000:00:0f.1
    ide0: BM-DMA at 0xfc00-0xfc07, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0xfc08-0xfc0f, BIOS settings: hdc:pio, hdd:pio
Probing IDE interface ide0...
hda: _NEC DVD_RW ND-3550A, ATAPI CD/DVD-ROM drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
Probing IDE interface ide1...
ide-floppy driver 0.99.newide
usbcore: registered new interface driver libusual
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
drivers/usb/input/hid-core.c: v2.6:USB HID core driver
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard as /class/input/input1
TCP bic registered
Initializing XFRM netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
powernow-k8: Found 2 AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ processors (version 2.00.00)
powernow-k8:    0 : fid 0xc (2000 MHz), vid 0x8
powernow-k8:    1 : fid 0xa (1800 MHz), vid 0xa
powernow-k8:    2 : fid 0x2 (1000 MHz), vid 0x12
Using IPI No-Shortcut mode
Freeing unused kernel memory: 240k freed
Write protecting the kernel read-only data: 862k
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:10.0[A] -> GSI 20 (level, low) -> IRQ 21
uhci_hcd 0000:00:10.0: UHCI Host Controller
uhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 1
uhci_hcd 0000:00:10.0: irq 21, io base 0x0000c480
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:10.1[B] -> GSI 22 (level, low) -> IRQ 22
uhci_hcd 0000:00:10.1: UHCI Host Controller
uhci_hcd 0000:00:10.1: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:10.1: irq 22, io base 0x0000c800
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:10.2[C] -> GSI 21 (level, low) -> IRQ 23
uhci_hcd 0000:00:10.2: UHCI Host Controller
uhci_hcd 0000:00:10.2: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:10.2: irq 23, io base 0x0000c880
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:10.3[D] -> GSI 23 (level, low) -> IRQ 24
uhci_hcd 0000:00:10.3: UHCI Host Controller
uhci_hcd 0000:00:10.3: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:10.3: irq 24, io base 0x0000cc00
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
ACPI: PCI Interrupt 0000:00:10.4[C] -> GSI 21 (level, low) -> IRQ 23
ehci_hcd 0000:00:10.4: EHCI Host Controller
ehci_hcd 0000:00:10.4: new USB bus registered, assigned bus number 5
ehci_hcd 0000:00:10.4: irq 23, io mem 0xf8fffc00
ehci_hcd 0000:00:10.4: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 8 ports detected
SCSI subsystem initialized
libata version 2.20 loaded.
sata_via 0000:00:0f.0: version 2.1
ACPI: PCI Interrupt 0000:00:0f.0[B] -> GSI 21 (level, low) -> IRQ 23
sata_via 0000:00:0f.0: routed to hard irq line 10
ata1: SATA max UDMA/133 cmd 0x0001dc00 ctl 0x0001d882 bmdma 0x0001d400 irq 23
ata2: SATA max UDMA/133 cmd 0x0001d800 ctl 0x0001d482 bmdma 0x0001d408 irq 23
scsi0 : sata_via
ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ATA: abnormal status 0x7F on port 0x0001dc07
ATA: abnormal status 0x7F on port 0x0001dc07
ata1.00: ATA-7: WDC WD2500KS-00MJB0, 02.01C03, max UDMA/133
ata1.00: 488397168 sectors, multi 16: LBA48 
ata1.00: configured for UDMA/133
scsi1 : sata_via
ata2: SATA link down 1.5 Gbps (SStatus 0 SControl 300)
ATA: abnormal status 0x7F on port 0x0001d807
scsi 0:0:0:0: Direct-Access     ATA      WDC WD2500KS-00M 02.0 PQ: 0 ANSI: 5
SCSI device sda: 488397168 512-byte hdwr sectors (250059 MB)
sda: Write Protect is off
sda: Mode Sense: 00 3a 00 00
SCSI device sda: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
SCSI device sda: 488397168 512-byte hdwr sectors (250059 MB)
sda: Write Protect is off
sda: Mode Sense: 00 3a 00 00
SCSI device sda: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: Attached scsi disk sda
device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-devel@redhat.com
usb 2-1: new low speed USB device using uhci_hcd and address 3
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
usb 2-1: configuration #1 chosen from 1 choice
input: Microsoft Basic Optical Mouse as /class/input/input2
input: USB HID v1.10 Mouse [Microsoft Basic Optical Mouse] on usb-0000:00:10.1-1
SELinux:  Disabled at runtime.
SELinux:  Unregistering netfilter hooks
audit(1174469320.046:2): selinux=0 auid=4294967295
hda: ATAPI 48X DVD-ROM DVD-R CD-R/RW drive, 2048kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20
parport: PnPBIOS parport detected.
parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE,EPP]
parport0: Printer, HEWLETT-PACKARD DESKJET 840C
Attansic L1 Ethernet Network Driver - version 2.0.7
Copyright(c) 2005-2006 Attansic Corporation.
ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 36 (level, low) -> IRQ 25
PCI: Setting latency timer of device 0000:04:00.0 to 64
input: PC Speaker as /class/input/input3
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
ACPI: PCI Interrupt 0000:08:01.0[A] -> GSI 17 (level, low) -> IRQ 26
PCI: Setting latency timer of device 0000:08:01.0 to 64
sd 0:0:0:0: Attached scsi generic sg0 type 0
lp0: using parport0 (interrupt-driven).
lp0: console ready
sonypi: Sony Programmable I/O Controller Driver v1.26.
input: Power Button (FF) as /class/input/input4
ACPI: Power Button (FF) [PWRF]
input: Sleep Button (CM) as /class/input/input5
ACPI: Sleep Button (CM) [SLPB]
input: Power Button (CM) as /class/input/input6
ACPI: Power Button (CM) [PWRB]
No dock devices found.
ibm_acpi: ec object not found
md: Autodetecting RAID arrays.
md: autorun ...
md: ... autorun DONE.
device-mapper: multipath: version 1.0.5 loaded
EXT3 FS on dm-0, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda2, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
Adding 2031608k swap on /dev/VolGroup00/LogVol01.  Priority:-1 extents:1 across:2031608k
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
Mobile IPv6
Clocksource tsc unstable (delta = -129931982 ns)
ip6_tables: (C) 2000-2006 Netfilter Core Team
ip_tables: (C) 2000-2006 Netfilter Core Team
Netfilter messages via NETLINK v0.30.
nf_conntrack version 0.5.0 (8189 buckets, 65512 max)

--MP_AJAMQsa=RERfbfFmaQBZEfB
Content-Type: text/plain; name=hawk-lspci-20070321.txt
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=hawk-lspci-20070321.txt

00:00.0 Host bridge: VIA Technologies, Inc. VT3351 Host Bridge
	Subsystem: VIA Technologies, Inc. VT3351 Host Bridge
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 64 bytes
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] HyperTransport: Slave or Primary Interface
		!!! Possibly incomplete decoding
		Command: BaseUnitID=0 UnitCnt=3 MastHost- DefDir-
		Link Control 0: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0
		Link Config 0: MLWI=16bit MLWO=16bit LWI=16bit LWO=16bit
		Link Control 1: CFlE- CST- CFE- <LkFail+ Init- EOC+ TXO+ <CRCErr=0
		Link Config 1: MLWI=8bit MLWO=8bit LWI=8bit LWO=8bit
		Revision ID: 1.02
	Capabilities: [58] #00 [0000]
00: 06 11 51 03 06 01 10 02 00 00 00 06 10 40 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 51 03
30: 00 00 00 00 50 00 00 00 00 00 00 00 00 00 00 00

00:00.1 Host bridge: VIA Technologies, Inc. VT3351 Host Bridge
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
00: 06 11 51 13 06 00 00 02 00 00 00 06 10 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:00.2 Host bridge: VIA Technologies, Inc. VT3351 Host Bridge
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
00: 06 11 51 23 06 00 00 02 00 00 00 06 10 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:00.3 Host bridge: VIA Technologies, Inc. VT3351 Host Bridge
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
00: 06 11 51 33 06 00 00 02 00 00 00 06 10 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:00.4 Host bridge: VIA Technologies, Inc. VT3351 Host Bridge
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
00: 06 11 51 43 06 00 00 02 00 00 00 06 10 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:00.5 PIC: VIA Technologies, Inc. VT3351 I/O APIC Interrupt Controller (prog-if 20 [IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
00: 06 11 51 53 06 00 00 00 00 20 00 08 10 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:00.6 Host bridge: VIA Technologies, Inc. Unknown device 6238
	Subsystem: Unknown device 0008:0000
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
00: 06 11 38 62 06 00 00 02 00 00 00 06 10 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:00.7 Host bridge: VIA Technologies, Inc. VT3351 Host Bridge
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
00: 06 11 51 73 06 00 00 02 00 00 00 06 10 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:01.0 PCI bridge: VIA Technologies, Inc. [K8T890 North / VT8237 South] PCI Bridge (prog-if 00 [Normal decode])
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: fff00000-000fffff
	Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [70] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 99 b9 04 00 30 02 00 00 04 06 10 00 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 00 f0 00 20 02
20: f0 ff 00 00 f0 ff 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 70 00 00 00 00 00 00 00 00 00 03 00

00:02.0 PCI bridge: VIA Technologies, Inc. K8T890 PCI to PCI Bridge Controller (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR+ <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: f9000000-fbcfffff
	Prefetchable memory behind bridge: 00000000d0000000-00000000dff00000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
	Capabilities: [40] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <1us, L1 unlimited
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, Port 0
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x16
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Unknown, PwrInd Unknown, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [68] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [70] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0300c  Data: 41d1
00: 06 11 38 a2 07 04 10 40 00 00 04 06 10 00 01 00
10: 00 00 00 00 00 00 00 00 00 02 02 00 f0 00 00 20
20: 00 f9 c0 fb 01 d0 f1 df 00 00 00 00 00 00 00 00
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 0c 00

00:03.0 PCI bridge: VIA Technologies, Inc. K8T890 PCI to PCI Bridge Controller (prog-if 00 [Normal decode])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=06, subordinate=06, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000f7f00000-00000000f7f00000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <512ns, L1 unlimited
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x4, ASPM L0s L1, Port 1
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM Disabled RCB 64 bytes Disabled CommClk- ExtSynch-
		Link: Speed unknown, Width x1
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Unknown, PwrInd Unknown, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [68] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [70] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0300c  Data: 41d9
00: 06 11 38 c2 06 05 10 00 00 00 04 06 10 00 81 00
10: 00 00 00 00 00 00 00 00 00 06 06 00 f0 00 00 00
20: f0 ff 00 00 f1 f7 f1 f7 00 00 00 00 00 00 00 00
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 03 00

00:03.1 PCI bridge: VIA Technologies, Inc. K8T890 PCI to PCI Bridge Controller (prog-if 00 [Normal decode])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000f7e00000-00000000f7e00000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <64ns, L1 unlimited
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 2
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed unknown, Width x0
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Unknown, PwrInd Unknown, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [68] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [70] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0300c  Data: 41e1
00: 06 11 38 d2 06 05 10 00 00 00 04 06 10 00 81 00
10: 00 00 00 00 00 00 00 00 00 05 05 00 f0 00 00 00
20: f0 ff 00 00 e1 f7 e1 f7 00 00 00 00 00 00 00 00
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 02 03 00

00:03.2 PCI bridge: VIA Technologies, Inc. K8T890 PCI to PCI Bridge Controller (prog-if 00 [Normal decode])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fbd00000-fbdfffff
	Prefetchable memory behind bridge: 00000000fff00000-0000000000000000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <4us, L1 unlimited
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 3
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Unknown, PwrInd Unknown, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [68] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [70] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0300c  Data: 41e9
00: 06 11 38 e2 06 05 10 00 00 00 04 06 10 00 81 00
10: 00 00 00 00 00 00 00 00 00 04 04 00 f0 00 00 20
20: d0 fb d0 fb f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 03 03 00

00:03.3 PCI bridge: VIA Technologies, Inc. K8T890 PCI to PCI Bridge Controller (prog-if 00 [Normal decode])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000f7d00000-00000000f7d00000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <64ns, L1 unlimited
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 4
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed unknown, Width x0
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Unknown, PwrInd Unknown, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [68] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [70] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0300c  Data: 4132
00: 06 11 38 f2 06 05 10 00 00 00 04 06 10 00 81 00
10: 00 00 00 00 00 00 00 00 00 03 03 00 f0 00 00 00
20: f0 ff 00 00 d1 f7 d1 f7 00 00 00 00 00 00 00 00
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 04 03 00

00:0f.0 IDE interface: VIA Technologies, Inc. VT8237A SATA 2-Port Controller (rev 80) (prog-if 8f [Master SecP SecO PriP PriO])
	Subsystem: VIA Technologies, Inc. VT8237A SATA 2-Port Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64
	Interrupt: pin B routed to IRQ 23
	Region 0: I/O ports at dc00 [size=8]
	Region 1: I/O ports at d880 [size=4]
	Region 2: I/O ports at d800 [size=8]
	Region 3: I/O ports at d480 [size=4]
	Region 4: I/O ports at d400 [size=16]
	Region 5: I/O ports at d000 [size=256]
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 91 05 07 00 90 02 80 8f 01 01 00 40 80 00
10: 01 dc 00 00 81 d8 00 00 01 d8 00 00 81 d4 00 00
20: 01 d4 00 00 01 d0 00 00 00 00 00 00 06 11 91 05
30: 00 00 00 00 c0 00 00 00 00 00 00 00 0a 02 00 00

00:0f.1 IDE interface: VIA Technologies, Inc. VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 07) (prog-if 8a [Master SecP PriP])
	Subsystem: VIA Technologies, Inc. VT82C586/B/VT82C686/A/B/VT8233/A/C/VT8235 PIPC Bus Master IDE
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32
	Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) [disabled] [size=8]
	Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable) [disabled] [size=1]
	Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) [disabled] [size=8]
	Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable) [disabled] [size=1]
	Region 4: I/O ports at fc00 [size=16]
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 71 05 05 00 90 02 07 8a 01 01 00 20 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 fc 00 00 00 00 00 00 00 00 00 00 06 11 71 05
30: 00 00 00 00 c0 00 00 00 00 00 00 00 ff 00 00 00

00:10.0 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev a0) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 21
	Region 4: I/O ports at c480 [size=32]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 38 30 17 00 10 02 a0 00 03 0c 10 40 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 81 c4 00 00 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 0b 01 00 00

00:10.1 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev a0) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 22
	Region 4: I/O ports at c800 [size=32]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 38 30 17 00 10 02 a0 00 03 0c 10 40 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 c8 00 00 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 0a 02 00 00

00:10.2 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev a0) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin C routed to IRQ 23
	Region 4: I/O ports at c880 [size=32]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 38 30 17 00 10 02 a0 00 03 0c 10 40 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 81 c8 00 00 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 05 03 00 00

00:10.3 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev a0) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin D routed to IRQ 24
	Region 4: I/O ports at cc00 [size=32]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 38 30 17 00 10 02 a0 00 03 0c 10 40 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 cc 00 00 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 03 04 00 00

00:10.4 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 86) (prog-if 20 [EHCI])
	Subsystem: VIA Technologies, Inc. USB 2.0
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin C routed to IRQ 23
	Region 0: Memory at f8fffc00 (32-bit, non-prefetchable) [size=256]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 04 31 17 00 10 02 86 20 03 0c 10 40 80 00
10: 00 fc ff f8 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 04 31
30: 00 00 00 00 80 00 00 00 00 00 00 00 05 03 00 00

00:11.0 ISA bridge: VIA Technologies, Inc. VT8237A PCI to ISA Bridge
	Subsystem: VIA Technologies, Inc. VT8237A PCI to ISA Bridge
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 37 33 03 00 10 02 00 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 37 33
30: 00 00 00 00 c0 00 00 00 00 00 00 00 00 00 00 00

00:11.7 Host bridge: VIA Technologies, Inc. VT8251 Ultra VLINK Controller
	Subsystem: VIA Technologies, Inc. Unknown device 337e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 128
	Capabilities: [58] HyperTransport: Interrupt Discovery and Configuration
00: 06 11 7e 28 06 01 10 02 00 00 00 06 00 80 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 7e 33
30: 00 00 00 00 58 00 00 00 00 00 00 00 00 00 00 00

00:13.0 PCI bridge: VIA Technologies, Inc. VT8237A Host Bridge (prog-if 00 [Normal decode])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=08, subordinate=08, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fbf00000-fbffffff
	Prefetchable memory behind bridge: 00000000fff00000-0000000000000000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [60] HyperTransport: MSI Mapping
	Capabilities: [70] #0d [0000]
00: 06 11 7b 33 06 01 10 20 00 00 04 06 00 00 81 00
10: 00 00 00 00 00 00 00 00 00 08 08 00 f0 00 00 02
20: f0 fb f0 fb f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 60 00 00 00 00 00 00 00 00 00 03 00

00:13.1 PCI bridge: VIA Technologies, Inc. VT8237A PCI to PCI Bridge (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=07, subordinate=07, sec-latency=0
	I/O behind bridge: 0000e000-0000efff
	Memory behind bridge: fbe00000-fbefffff
	Prefetchable memory behind bridge: 0000000050000000-0000000050000000
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [60] HyperTransport: MSI Mapping
	Capabilities: [70] #0d [0000]
00: 06 11 7a 33 07 01 10 20 00 01 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 07 07 00 e0 e0 00 02
20: e0 fb e0 fb 01 50 01 50 00 00 00 00 00 00 00 00
30: 00 00 00 00 60 00 00 00 00 00 00 00 00 00 03 00

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Capabilities: [80] HyperTransport: Host or Secondary Interface
		!!! Possibly incomplete decoding
		Command: WarmRst+ DblEnd-
		Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0
		Link Config: MLWI=16bit MLWO=16bit LWI=16bit LWO=16bit
		Revision ID: 1.02
00: 22 10 00 11 00 00 10 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
00: 22 10 01 11 00 00 00 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
00: 22 10 02 11 00 00 00 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Capabilities: [f0] #0f [0010]
00: 22 10 03 11 00 00 10 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 f0 00 00 00 00 00 00 00 00 00 00 00

02:00.0 VGA compatible controller: nVidia Corporation NV43 [GeForce 6600] (rev a2) (prog-if 00 [VGA])
	Subsystem: Micro-Star International Co., Ltd. Unknown device 0410
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at fa000000 (32-bit, non-prefetchable) [size=16M]
	Region 1: Memory at d0000000 (64-bit, prefetchable) [size=256M]
	Region 3: Memory at f9000000 (64-bit, non-prefetchable) [size=16M]
	Expansion ROM at fbce0000 [disabled] [size=128K]
	Capabilities: [60] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [68] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [78] Express Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <512ns, L1 <4us
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, Port 0
		Link: Latency L0s <1us, L1 <4us
		Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x16
00: de 10 41 01 07 01 10 00 a2 00 00 03 10 00 00 00
10: 00 00 00 fa 0c 00 00 d0 00 00 00 00 04 00 00 f9
20: 00 00 00 00 00 00 00 00 00 00 00 00 62 14 10 04
30: 00 00 ce fb 60 00 00 00 00 00 00 00 0b 01 00 00

04:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit Ethernet Adapter (rev b0)
	Subsystem: ASUSTeK Computer Inc. Unknown device 8226
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR+ <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 25
	Region 0: Memory at fbdc0000 (64-bit, non-prefetchable) [size=256K]
	Expansion ROM at fbda0000 [disabled] [size=128K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [48] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [58] Express Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <4us, L1 unlimited
		Device: AtnBtn+ AtnInd+ PwrInd+
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
		Link: Latency L0s unlimited, L1 unlimited
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [6c] Vital Product Data
00: 69 19 48 10 06 01 10 40 b0 00 00 02 10 00 00 00
10: 04 00 dc fb 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 43 10 26 82
30: 00 00 da fb 40 00 00 00 00 00 00 00 0b 01 00 00

07:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
	Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 10
	Region 0: I/O ports at e800 [size=256]
	Region 1: Memory at fbeffc00 (32-bit, non-prefetchable) [size=256]
	Expansion ROM at 50000000 [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: ec 10 69 81 17 01 b0 02 10 00 00 02 10 40 00 00
10: 01 e8 00 00 00 fc ef fb 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 10 69 81
30: 00 00 ec fb dc 00 00 00 00 00 00 00 0a 01 20 40

08:01.0 Audio device: VIA Technologies, Inc. VIA High Definition Audio Controller (rev 10)
	Subsystem: ASUSTeK Computer Inc. Unknown device 81e7
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 26
	Region 0: Memory at fbffc000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [70] Express Unknown type IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed unknown, Width x0, ASPM unknown, Port 0
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM Disabled CommClk- ExtSynch-
		Link: Speed unknown, Width x0
00: 06 11 88 32 06 00 10 00 10 00 03 04 10 00 00 00
10: 04 c0 ff fb 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 43 10 e7 81
30: 00 00 00 00 50 00 00 00 00 00 00 00 0a 01 00 00


--MP_AJAMQsa=RERfbfFmaQBZEfB
Content-Type: text/plain; name=hawk-proc-int-20070321.txt
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=hawk-proc-int-20070321.txt

           CPU0       CPU1       
  0:        380          0   IO-APIC-edge      timer
  1:          3        285   IO-APIC-edge      i8042
  4:          0         10   IO-APIC-edge      serial
  6:          0          5   IO-APIC-edge      floppy
  7:          0          0   IO-APIC-edge      parport0
  8:          0          1   IO-APIC-edge      rtc
  9:          0          0   IO-APIC-fasteoi   acpi
 12:          0          4   IO-APIC-edge      i8042
 14:        738         84   IO-APIC-edge      ide0
 21:          0          0   IO-APIC-fasteoi   uhci_hcd:usb1
 22:        232         33   IO-APIC-fasteoi   uhci_hcd:usb2
 23:          4       9147   IO-APIC-fasteoi   uhci_hcd:usb3, ehci_hcd:usb5, libata
 24:          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
 26:          0        191   IO-APIC-fasteoi   HDA Intel
NMI:          0          0 
LOC:     111367     112136 
ERR:          0
MIS:          0

--MP_AJAMQsa=RERfbfFmaQBZEfB--
