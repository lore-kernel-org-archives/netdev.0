From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Tue, 29 Dec 2009 10:33:10 +0100
Message-ID: <20091229103310.46b8c670@pluto.restena.lu>
References: <20091229084929.54912c0c@pluto.restena.lu>
	<1262077540.12520.4.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/Dkc_9.owEn1_UJCXzpdneHl"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Benjamin Li" <benli@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppp-156-114.adsl.restena.lu ([158.64.156.114]:55567 "EHLO
	bonbons.gotdns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbZL2JdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 04:33:20 -0500
In-Reply-To: <1262077540.12520.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/Dkc_9.owEn1_UJCXzpdneHl
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Benjamin,

On Tue, 29 Dec 2009 01:05:40 "Benjamin Li" <benli@broadcom.com> wrote:
> Hi Bruno,
>=20
> It looks like the the NULL dereference is happening at a0fc.
>=20
> a0f8:       48 8b 42 70             mov 0x70(%rdx),%rax=20
> a0fc:       0f b7 10                movzwl (%rax),%edx
> a0ff:       31 c0                   xor    %eax,%eax

Thanks for confirming my guess

> The offset of 0x70 is the bp field in the bnx2_napi structure.  (Seen
> in the bnx2_napi structure dump below)  These lines are found in the
> routine, bnx2_get_hw_tx_cons() which look like they were inlined by
> the compiler.  More specifically it looks like the dereference of the
> hw_tx_cons_ptr failed.
>=20
> cons =3D *bnapi->hw_tx_cons_ptr;
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dbl=
ob;f=3Ddrivers/net/bnx2.c;h=3D06b901152d4487fa04164437cc179661b44657fe;hb=
=3D74fca6a42863ffacaf7ba6f1936a9f228950f657#l2761
>=20
> To be sure this is the case, could you send the .config file you are
> using or if you could send me the bnx2 kernel module built with the
> CFLAG '-g', then we can definitely verify where in the code it is
> crashing.

See attached .config, if needed I can recompile with the module with
'-g', but the original instance does not contain debugging info.

> Did you see anything suspicious in the system kernel logs?  If you
> could isolate the logs from when the machine booted to when it crash
> and send it to us it would be very helpful.=20

Unfortunately there is nothing suspicious in there, all I have is
attached dmesg (with IP addresses, MAC addresses replaced by '*'s)

I've not appended the crash dump gathered via netconsole which didn't
make it to the affected system's disk (see previous mail for it).


Regards,
Bruno



> Thanks again for your time.
>=20
> -Ben
>=20
>=20
> <--snip snip structure dump from pahole-->
> struct bnx2_napi {
>         struct napi_struct         napi;                 /*     0
> 96 */
>         /* --- cacheline 1 boundary (64 bytes) was 32 bytes ago --- */
>         struct bnx2 *              bp;                   /*    96
> 8 */
>         union {
>                 struct status_block * msi;               /*
> 8 */
>                 struct status_block_msix * msix;         /*
> 8 */
>         } status_blk;                                    /*   104
> 8 */
>         u16 *                      hw_tx_cons_ptr;       /*   112
> 8 */
>         u16 *                      hw_rx_cons_ptr;       /*   120
> 8 */
>         /* --- cacheline 2 boundary (128 bytes) --- */
>         u32                        last_status_idx;      /*   128
> 4 */
>         u32                        int_num;              /*   132
> 4 */
>         struct bnx2_rx_ring_info   rx_ring;              /*   136
> 360 */
>         /* --- cacheline 7 boundary (448 bytes) was 48 bytes ago ---
> */ struct bnx2_tx_ring_info   tx_ring;              /*   496    48
> */
>         /* --- cacheline 8 boundary (512 bytes) was 32 bytes ago ---
> */
>=20
>         /* size: 576, cachelines: 9 */
>         /* padding: 32 */
> };
> <--snip snip-->
>=20
> On Mon, 2009-12-28 at 23:49 -0800, Bruno Pr=C3=A9mont wrote:=20
> > On a system that was running 2.6.31 since last September I got two
> > crashes this December at night (cause unknown), yesterday after
> > second crash I updated kernel to 2.6.31.9 and enabled netconsole in
> > the hope to get some information about the cause of the crash.
> >=20
> > Today system crashed once again and all I got is the following
> > incomplete trace on the receiving side of netconsole:
> >=20
> > [24701.841185] BUG: unable to handle kernel NULL pointer
> > dereference at (null) [24701.841188] IP: [<ffffffffa00610fc>]
> > bnx2_poll_work+0x2c/0x12d0 [bnx2] [24701.841197] PGD 16509067 PUD
> > 4e776067 PMD 0 [24701.841199] Oops: 0000 [#1] SMP
> > [24701.841202] last sysfs file: /sys/kernel/uevent_seqnum
> > [24701.841204] CPU 0
> > [24701.841205] Modules linked in: ipmi_devintf squashfs ext2
> > zlib_inflate netconsole configfs loop dm_round_robin scsi_dh_rdac
> > dm_multipath scsi_dh dm_mod sg sr_mod cdrom ata_piix i pmi_si
> > ipmi_msghandler qla2xxx ahci bnx2 hpwdt uhci_hcd ehci_hcd libata
> > [24701.841218] Pid: 11273, comm: php-cgi Not tainted
> > 2.6.31.9-x86_64 #1 ProLiant DL360 G5 [24701.841220] RIP:
> > 0010:[<ffffffffa00610fc>]  [<ffffffffa00610fc>]
> > bnx2_poll_work+0x2c/0x12d0 [bnx2]
> >=20
> >=20
> > Running objdump on the bnx2.ko module I get the following:
> > 000000000000a0d0 <bnx2_poll_work>:
> >     a0d0:       41 57                   push   %r15
> >     a0d2:       41 56                   push   %r14
> >     a0d4:       41 55                   push   %r13
> >     a0d6:       41 54                   push   %r12
> >     a0d8:       55                      push   %rbp
> >     a0d9:       53                      push   %rbx
> >     a0da:       48 81 ec 28 01 00 00    sub    $0x128,%rsp
> >     a0e1:       48 89 7c 24 18          mov    %rdi,0x18(%rsp)
> >     a0e6:       48 89 74 24 10          mov    %rsi,0x10(%rsp)
> >     a0eb:       89 54 24 0c             mov    %edx,0xc(%rsp)
> >     a0ef:       89 4c 24 08             mov    %ecx,0x8(%rsp)
> >     a0f3:       48 8b 54 24 10          mov    0x10(%rsp),%rdx
> >     a0f8:       48 8b 42 70             mov    0x70(%rdx),%rax
> >     a0fc:       0f b7 10                movzwl (%rax),%edx
> >     a0ff:       31 c0                   xor    %eax,%eax
> >     a101:       48 8b 4c 24 10          mov    0x10(%rsp),%rcx
> >     a106:       80 fa ff                cmp    $0xff,%dl
> >     a109:       0f 94 c0                sete   %al
> >     a10c:       01 c2                   add    %eax,%edx
> >     a10e:       66 39 91 1a 02 00 00    cmp    %dx,0x21a(%rcx)
> >     a115:       0f 84 78 01 00 00       je     a293
> > <bnx2_poll_work+0x1c3> a11b:       48 8b 57 08             mov
> > 0x8(%rdi),%rdx a11f:       48 89 f8                mov    %rdi,%rax
> >     a122:       48 8b 9a 00 03 00 00    mov    0x300(%rdx),%rbx
> >     a129:       48 83 c0 40             add    $0x40,%rax
> >     a12d:       48 29 c1                sub    %rax,%rcx
> >     a130:       48 89 c8                mov    %rcx,%rax
> >     a133:       48 c1 f8 06             sar    $0x6,%rax
> >     a137:       69 c0 39 8e e3 38       imul   $0x38e38e39,%eax,%eax
> >     a13d:       48 c1 e0 07             shl    $0x7,%rax
> >     a141:       48 01 d8                add    %rbx,%rax
> >     a144:       48 89 44 24 20          mov    %rax,0x20(%rsp)
> >     a149:       48 8b 7c 24 10          mov    0x10(%rsp),%rdi
> >     a14e:       48 8b 47 70             mov    0x70(%rdi),%rax
> >     a152:       44 0f b7 30             movzwl (%rax),%r14d
> >     a156:       31 c0                   xor    %eax,%eax
> >     a158:       0f b7 9f 18 02 00 00    movzwl 0x218(%rdi),%ebx
> >     a15f:       41 80 fe ff             cmp    $0xff,%r14b
> >     a163:       0f 94 c0                sete   %al
> >     a166:       45 31 ff                xor    %r15d,%r15d
> >     a169:       41 01 c6                add    %eax,%r14d
> >     a16c:       66 44 39 f3             cmp    %r14w,%bx
> >     a170:       0f 84 ee 00 00 00       je     a264
> > <bnx2_poll_work+0x194> a176:       66 2e 0f 1f 84 00 00    nopw
> > %cs:0x0(%rax,%rax,1) a17d:       00 00 00=20
> >     a180:       0f b6 cb                movzbl %bl,%ecx
> >     a183:       48 8b 44 24 10          mov    0x10(%rsp),%rax
> >     a188:       44 0f b7 e1             movzwl %cx,%r12d
> >     a18c:       49 c1 e4 04             shl    $0x4,%r12
> >     a190:       4c 03 a0 10 02 00 00    add    0x210(%rax),%r12
> >     a197:       4d 8b 2c 24             mov    (%r12),%r13
> >     a19b:       66 41 83 7c 24 08 00    cmpw   $0x0,0x8(%r12)
> >     a1a2:       41 0f 18 8d bc 00 00    prefetcht0 0xbc(%r13)
> >     a1a9:       00=20
> >                 ...
> >=20
> >=20
> > Kernel is compiled on Gentoo (64bit):
> >   Linux version 2.6.31.9-x86_64 () (gcc version 4.3.4 (Gentoo 4.3.4
> > p1.0, pie-10.1.5) ) #1 SMP Mon Dec 28 15:49:16 CET 2009 The
> > affected server (HP DL360 G5) is running OpenSuSE-11.1, 32bit
> > userspace
> >=20
> > Any idea if there is a recent patch that could fix this issue? At
> > the crashing time the server was not specifically loaded and had
> > around 200 packets/s network traffic.
> >=20
> > Regards,
> > Bruno


--MP_/Dkc_9.owEn1_UJCXzpdneHl
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=dmesg

[    0.000000] Linux version 2.6.31.9-x86_64 (...) (gcc version 4.3.4 (Gentoo 4.3.4 p1.0, pie-10.1.5) ) #1 SMP Mon Dec 28 15:49:16 CET 2009
[    0.000000] Command line: root=/dev/cciss/c0d0p2
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
[    0.000000]  BIOS-e820: 000000000009f400 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007fe58000 (usable)
[    0.000000]  BIOS-e820: 000000007fe58000 - 000000007fe60000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007fe60000 - 0000000080000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fed00000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee10000 (reserved)
[    0.000000]  BIOS-e820: 00000000ffc00000 - 0000000100000000 (reserved)
[    0.000000] DMI 2.3 present.
[    0.000000] last_pfn = 0x7fe58 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 080000000 mask F80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] init_memory_mapping: 0000000000000000-000000007fe58000
[    0.000000]  0000000000 - 007fe00000 page 2M
[    0.000000]  007fe00000 - 007fe58000 page 4k
[    0.000000] kernel direct mapping tables up to 7fe58000 @ 8000-c000
[    0.000000] ACPI: RSDP 00000000000f4f00 00024 (v02 HP    )
[    0.000000] ACPI: XSDT 000000007fe58300 00054 (v01 HP     P58      00000002   Ò 0000162E)
[    0.000000] ACPI: FACP 000000007fe58380 000F4 (v03 HP     P58      00000002   Ò 0000162E)
[    0.000000] ACPI Warning: Invalid length for Pm1aControlBlock: 32, using default 16 20090521 tbfadt-608
[    0.000000] ACPI: DSDT 000000007fe58480 01E95 (v01 HP         DSDT 00000001 INTL 20030228)
[    0.000000] ACPI: FACS 000000007fe580c0 00040
[    0.000000] ACPI: SPCR 000000007fe58100 00050 (v01 HP     SPCRRBSU 00000001   Ò 0000162E)
[    0.000000] ACPI: MCFG 000000007fe58180 0003C (v01 HP     ProLiant 00000001      00000000)
[    0.000000] ACPI: HPET 000000007fe581c0 00038 (v01 HP     P58      00000002   Ò 0000162E)
[    0.000000] ACPI: SPMI 000000007fe58200 00040 (v05 HP     ProLiant 00000001   Ò 0000162E)
[    0.000000] ACPI: APIC 000000007fe58240 0009E (v01 HP     00000083 00000002      00000000)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] (6 early reservations) ==> bootmem [0000000000 - 007fe58000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
[    0.000000]   #2 [0001000000 - 00015f3b90]    TEXT DATA BSS ==> [0001000000 - 00015f3b90]
[    0.000000]   #3 [000009f400 - 0000100000]    BIOS reserved ==> [000009f400 - 0000100000]
[    0.000000]   #4 [00015f4000 - 00015f4110]              BRK ==> [00015f4000 - 00015f4110]
[    0.000000]   #5 [0000008000 - 000000a000]          PGTABLE ==> [0000008000 - 000000a000]
[    0.000000] found SMP MP-table at [ffff8800000f4f80] f4f80
[    0.000000]  [ffffea0000000000-ffffea0001bfffff] PMD -> [ffff880001a00000-ffff8800035fffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x00100000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0007fe58
[    0.000000] On node 0 totalpages: 523767
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 101 pages reserved
[    0.000000]   DMA zone: 3842 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 7107 pages used for memmap
[    0.000000]   DMA32 zone: 512661 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x908
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec80000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec80000, GSI 24-47
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] 8 Processors exceeds NR_CPUS limit of 4
[    0.000000] SMP: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 48
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 80000000:7ec00000)
[    0.000000] NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 25 pages at ffff880001605000, static data 71712 bytes
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 516503
[    0.000000] Kernel command line: vga=normal root=/dev/cciss/c0d0p2
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.000000] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 2056296k/2095456k available (3687k kernel code, 388k absent, 38376k reserved, 1665k data, 380k init)
[    0.000000] SLUB: Genslabs=13, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] NR_IRQS:384
[    0.000000] Extended CMOS year: 2000
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 2999.749 MHz processor.
[    0.002574] Console: colour VGA+ 80x25
[    0.002576] console [tty0] enabled
[    0.010000] hpet clockevent registered
[    0.010000] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.010000] Calibrating delay loop (skipped), value calculated using timer frequency.. 5999.49 BogoMIPS (lpj=29997490)
[    0.010000] Mount-cache hash table entries: 256
[    0.010000] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.010000] CPU: L2 cache: 4096K
[    0.010000] CPU: Physical Processor ID: 0
[    0.010000] CPU: Processor Core ID: 0
[    0.010000] mce: CPU supports 6 MCE banks
[    0.010000] CPU0: Thermal monitoring enabled (TM2)
[    0.010000] using mwait in idle threads.
[    0.010000] Freeing SMP alternatives: 27k freed
[    0.010000] ACPI: Core revision 20090521
[    0.010000] Setting APIC routing to flat
[    0.010000] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.106185] CPU0: Intel(R) Xeon(R) CPU            5160  @ 3.00GHz stepping 06
[    0.110000] Booting processor 1 APIC 0x6 ip 0x6000
[    0.010000] Initializing CPU#1
[    0.010000] Calibrating delay using timer specific routine.. 6000.28 BogoMIPS (lpj=30001442)
[    0.010000] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.010000] CPU: L2 cache: 4096K
[    0.010000] CPU: Physical Processor ID: 3
[    0.010000] CPU: Processor Core ID: 0
[    0.010000] mce: CPU supports 6 MCE banks
[    0.010000] CPU1: Thermal monitoring enabled (TM2)
[    0.010000] x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
[    0.261578] CPU1: Intel(R) Xeon(R) CPU            5160  @ 3.00GHz stepping 06
[    0.262987] checking TSC synchronization [CPU#0 -> CPU#1]: passed.
[    0.270066] Booting processor 2 APIC 0x1 ip 0x6000
[    0.010000] Initializing CPU#2
[    0.010000] Calibrating delay using timer specific routine.. 6000.27 BogoMIPS (lpj=30001395)
[    0.010000] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.010000] CPU: L2 cache: 4096K
[    0.010000] CPU: Physical Processor ID: 0
[    0.010000] CPU: Processor Core ID: 1
[    0.010000] mce: CPU supports 6 MCE banks
[    0.010000] CPU2: Thermal monitoring enabled (TM2)
[    0.010000] x86 PAT enabled: cpu 2, old 0x7040600070406, new 0x7010600070106
[    0.431325] CPU2: Intel(R) Xeon(R) CPU            5160  @ 3.00GHz stepping 06
[    0.432685] checking TSC synchronization [CPU#0 -> CPU#2]: passed.
[    0.440097] Booting processor 3 APIC 0x7 ip 0x6000
[    0.010000] Initializing CPU#3
[    0.010000] Calibrating delay using timer specific routine.. 6000.29 BogoMIPS (lpj=30001451)
[    0.010000] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.010000] CPU: L2 cache: 4096K
[    0.010000] CPU: Physical Processor ID: 3
[    0.010000] CPU: Processor Core ID: 1
[    0.010000] mce: CPU supports 6 MCE banks
[    0.010000] CPU3: Thermal monitoring enabled (TM2)
[    0.010000] x86 PAT enabled: cpu 3, old 0x7040600070406, new 0x7010600070106
[    0.601589] CPU3: Intel(R) Xeon(R) CPU            5160  @ 3.00GHz stepping 06
[    0.602998] checking TSC synchronization [CPU#0 -> CPU#3]: passed.
[    0.610024] Brought up 4 CPUs
[    0.610146] Total of 4 processors activated (24000.35 BogoMIPS).
[    0.610334] NET: Registered protocol family 16
[    0.610334] ACPI: bus type pci registered
[    0.610334] dca service started, version 1.8
[    0.610334] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.610334] PCI: Not using MMCONFIG.
[    0.610334] PCI: Using configuration type 1 for base access
[    0.610428] PCI: HP ProLiant DL360 detected, enabling pci=bfsort.
[    0.610566] bio: create slab <bio-0> at 0
[    0.610566] ACPI: EC: Look up EC in DSDT
[    0.620307] ACPI: Interpreter enabled
[    0.620409] ACPI: (supports S0 S5)
[    0.620579] ACPI: Using IOAPIC for interrupt routing
[    0.620707] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.621215] PCI: MCFG area at e0000000 reserved in ACPI motherboard resources
[    0.623460] PCI: Using MMCONFIG at e0000000 - efffffff
[    0.623599] ACPI: No dock devices found.
[    0.623599] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.623599] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[    0.623599] pci 0000:00:00.0: PME# disabled
[    0.623599] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    0.623599] pci 0000:00:02.0: PME# disabled
[    0.623599] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    0.623599] pci 0000:00:03.0: PME# disabled
[    0.623599] pci 0000:00:04.0: PME# supported from D0 D3hot D3cold
[    0.623599] pci 0000:00:04.0: PME# disabled
[    0.623599] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
[    0.623599] pci 0000:00:05.0: PME# disabled
[    0.623599] pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
[    0.623599] pci 0000:00:06.0: PME# disabled
[    0.623599] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
[    0.623599] pci 0000:00:07.0: PME# disabled
[    0.623599] pci 0000:00:1d.0: reg 20 io port: [0x1000-0x101f]
[    0.623599] pci 0000:00:1d.1: reg 20 io port: [0x1020-0x103f]
[    0.623599] pci 0000:00:1d.2: reg 20 io port: [0x1040-0x105f]
[    0.623599] pci 0000:00:1d.3: reg 20 io port: [0x1060-0x107f]
[    0.623599] pci 0000:00:1d.7: reg 10 32bit mmio: [0xf7df0000-0xf7df03ff]
[    0.623599] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.623599] pci 0000:00:1d.7: PME# disabled
[    0.623599] pci 0000:00:1f.1: reg 10 io port: [0x1f0-0x1f7]
[    0.623599] pci 0000:00:1f.1: reg 14 io port: [0x3f4-0x3f7]
[    0.623599] pci 0000:00:1f.1: reg 18 io port: [0x170-0x177]
[    0.623599] pci 0000:00:1f.1: reg 1c io port: [0x374-0x377]
[    0.623599] pci 0000:00:1f.1: reg 20 io port: [0x500-0x50f]
[    0.630685] pci 0000:09:00.0: PME# supported from D0 D3hot D3cold
[    0.630822] pci 0000:09:00.0: PME# disabled
[    0.632194] pci 0000:09:00.3: PME# supported from D0 D3hot D3cold
[    0.632332] pci 0000:09:00.3: PME# disabled
[    0.632771] pci 0000:00:02.0: bridge 32bit mmio: [0xfde00000-0xfdefffff]
[    0.634024] pci 0000:0a:00.0: PME# supported from D0 D3hot D3cold
[    0.635666] pci 0000:0a:00.0: PME# disabled
[    0.637176] pci 0000:0a:01.0: PME# supported from D0 D3hot D3cold
[    0.637313] pci 0000:0a:01.0: PME# disabled
[    0.638823] pci 0000:0a:02.0: PME# supported from D0 D3hot D3cold
[    0.638960] pci 0000:0a:02.0: PME# disabled
[    0.645605] pci 0000:06:00.0: reg 10 64bit mmio: [0xfdd00000-0xfddfffff]
[    0.645610] pci 0000:06:00.0: reg 18 io port: [0x4000-0x40ff]
[    0.645618] pci 0000:06:00.0: reg 1c 64bit mmio: [0xfdcf0000-0xfdcf0fff]
[    0.645627] pci 0000:06:00.0: reg 30 32bit mmio: [0x000000-0x03ffff]
[    0.645649] pci 0000:06:00.0: supports D1
[    0.645686] pci 0000:00:03.0: bridge io port: [0x4000-0x4fff]
[    0.645688] pci 0000:00:03.0: bridge 32bit mmio: [0xfdc00000-0xfddfffff]
[    0.645717] pci 0000:13:00.0: reg 10 io port: [0x5000-0x50ff]
[    0.645727] pci 0000:13:00.0: reg 14 64bit mmio: [0xfdff0000-0xfdff3fff]
[    0.645744] pci 0000:13:00.0: reg 30 32bit mmio: [0x000000-0x03ffff]
[    0.645807] pci 0000:00:04.0: bridge io port: [0x5000-0x5fff]
[    0.645809] pci 0000:00:04.0: bridge 32bit mmio: [0xfdf00000-0xfdffffff]
[    0.645882] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    0.646014] pci 0000:02:00.0: PME# disabled
[    0.646174] pci 0000:00:06.0: bridge 32bit mmio: [0xf8000000-0xf9ffffff]
[    0.646217] pci 0000:03:00.0: reg 10 64bit mmio: [0xf8000000-0xf9ffffff]
[    0.646236] pci 0000:03:00.0: reg 30 32bit mmio: [0x000000-0x0007ff]
[    0.646257] pci 0000:03:00.0: PME# supported from D3hot D3cold
[    0.646388] pci 0000:03:00.0: PME# disabled
[    0.646553] pci 0000:02:00.0: bridge 32bit mmio: [0xf8000000-0xf9ffffff]
[    0.646599] pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
[    0.646731] pci 0000:04:00.0: PME# disabled
[    0.646890] pci 0000:00:07.0: bridge 32bit mmio: [0xfa000000-0xfbffffff]
[    0.646931] pci 0000:05:00.0: reg 10 64bit mmio: [0xfa000000-0xfbffffff]
[    0.646951] pci 0000:05:00.0: reg 30 32bit mmio: [0x000000-0x0007ff]
[    0.646971] pci 0000:05:00.0: PME# supported from D3hot D3cold
[    0.647103] pci 0000:05:00.0: PME# disabled
[    0.647268] pci 0000:04:00.0: bridge 32bit mmio: [0xfa000000-0xfbffffff]
[    0.647311] pci 0000:01:03.0: reg 10 32bit mmio: [0xd8000000-0xdfffffff]
[    0.647317] pci 0000:01:03.0: reg 14 io port: [0x3000-0x30ff]
[    0.647323] pci 0000:01:03.0: reg 18 32bit mmio: [0xf7ff0000-0xf7ffffff]
[    0.647343] pci 0000:01:03.0: reg 30 32bit mmio: [0x000000-0x01ffff]
[    0.647361] pci 0000:01:03.0: supports D1 D2
[    0.647393] pci 0000:01:04.0: reg 10 io port: [0x2800-0x28ff]
[    0.647399] pci 0000:01:04.0: reg 14 32bit mmio: [0xf7fe0000-0xf7fe01ff]
[    0.647440] pci 0000:01:04.0: PME# supported from D0 D3hot D3cold
[    0.647573] pci 0000:01:04.0: PME# disabled
[    0.647731] pci 0000:01:04.2: reg 10 io port: [0x3400-0x34ff]
[    0.647738] pci 0000:01:04.2: reg 14 32bit mmio: [0xf7fd0000-0xf7fd07ff]
[    0.647744] pci 0000:01:04.2: reg 18 32bit mmio: [0xf7fc0000-0xf7fc3fff]
[    0.647751] pci 0000:01:04.2: reg 1c 32bit mmio: [0xf7f00000-0xf7f7ffff]
[    0.647768] pci 0000:01:04.2: reg 30 32bit mmio: [0x000000-0x00ffff]
[    0.647787] pci 0000:01:04.2: PME# supported from D0 D3hot D3cold
[    0.647921] pci 0000:01:04.2: PME# disabled
[    0.648101] pci 0000:01:04.4: reg 20 io port: [0x3800-0x381f]
[    0.648131] pci 0000:01:04.4: PME# supported from D0 D3hot D3cold
[    0.648264] pci 0000:01:04.4: PME# disabled
[    0.648421] pci 0000:01:04.6: reg 10 32bit mmio: [0xf7ef0000-0xf7ef00ff]
[    0.648467] pci 0000:01:04.6: PME# supported from D0 D3hot D3cold
[    0.648600] pci 0000:01:04.6: PME# disabled
[    0.648763] pci 0000:00:1e.0: transparent bridge
[    0.648890] pci 0000:00:1e.0: bridge io port: [0x2000-0x3fff]
[    0.648893] pci 0000:00:1e.0: bridge 32bit mmio: [0xf7e00000-0xf7ffffff]
[    0.648898] pci 0000:00:1e.0: bridge 64bit mmio pref: [0xd8000000-0xdfffffff]
[    0.648915] pci_bus 0000:00: on NUMA node 0
[    0.648918] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.648977] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.IP2P._PRT]
[    0.649016] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT02._PRT]
[    0.649033] ACPI Warning: \_SB_.PCI0.PT02._PRT: Return Package has no elements (empty) 20090521 nspredef-434
[    0.649327] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT02.IPE4._PRT]
[    0.649365] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT02.IPE4.IPE1._PRT]
[    0.649409] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT02.P2P2._PRT]
[    0.649448] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT03._PRT]
[    0.649487] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT04._PRT]
[    0.649529] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT06.NB01._PRT]
[    0.649572] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT07.NB02._PRT]
[    0.650198] ACPI: PCI Interrupt Link [LNKA] (IRQs *5 7 10 11)
[    0.650463] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *7 10 11)
[    0.650849] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 7 *10 11)
[    0.651200] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 7 *10 11)
[    0.651550] ACPI: PCI Interrupt Link [LNKE] (IRQs 5 7 10 11) *0, disabled.
[    0.651979] ACPI: PCI Interrupt Link [LNKF] (IRQs *5 7 10 11)
[    0.652367] ACPI: PCI Interrupt Link [LNKG] (IRQs 5 7 *10 11)
[    0.652754] ACPI: PCI Interrupt Link [LNKH] (IRQs 5 *7 10 11)
[    0.653121] SCSI subsystem initialized
[    0.653121] usbcore: registered new interface driver usbfs
[    0.653121] usbcore: registered new interface driver hub
[    0.653121] usbcore: registered new device driver usb
[    0.653121] PCI: Using ACPI for IRQ routing
[    0.700038] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.700317] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.730007] Switched to high resolution mode on CPU 0
[    0.732282] Switched to high resolution mode on CPU 1
[    0.732285] Switched to high resolution mode on CPU 3
[    0.732893] Switched to high resolution mode on CPU 2
[    0.760032] pnp: PnP ACPI init
[    0.760161] ACPI: bus type pnp registered
[    0.761839] pnp: PnP ACPI: found 10 devices
[    0.761965] ACPI: ACPI bus type pnp unregistered
[    0.762106] system 00:01: ioport range 0x408-0x40f has been reserved
[    0.762238] system 00:01: ioport range 0x4d0-0x4d1 has been reserved
[    0.762370] system 00:01: ioport range 0x700-0x71f has been reserved
[    0.762501] system 00:01: ioport range 0x800-0x83f has been reserved
[    0.762633] system 00:01: ioport range 0x900-0x97f has been reserved
[    0.762765] system 00:01: ioport range 0xc80-0xc83 has been reserved
[    0.762897] system 00:01: ioport range 0xcd4-0xcd7 has been reserved
[    0.763028] system 00:01: ioport range 0xf50-0xf58 has been reserved
[    0.763160] system 00:01: ioport range 0xca0-0xca1 has been reserved
[    0.763291] system 00:01: ioport range 0xca4-0xca5 has been reserved
[    0.763423] system 00:01: ioport range 0x2f8-0x2ff has been reserved
[    0.763555] system 00:01: iomem range 0xe0000000-0xefffffff has been reserved
[    0.763690] system 00:01: iomem range 0xfe000000-0xfebfffff has been reserved
[    0.769598] pci 0000:0a:00.0: PCI bridge, secondary bus 0000:0b
[    0.769729] pci 0000:0a:00.0:   IO window: disabled
[    0.769925] pci 0000:0a:00.0:   MEM window: disabled
[    0.770069] pci 0000:0a:00.0:   PREFETCH window: disabled
[    0.770251] pci 0000:0a:01.0: PCI bridge, secondary bus 0000:0e
[    0.770381] pci 0000:0a:01.0:   IO window: disabled
[    0.770571] pci 0000:0a:01.0:   MEM window: disabled
[    0.770709] pci 0000:0a:01.0:   PREFETCH window: disabled
[    0.770847] pci 0000:0a:02.0: PCI bridge, secondary bus 0000:0f
[    0.770977] pci 0000:0a:02.0:   IO window: disabled
[    0.771166] pci 0000:0a:02.0:   MEM window: disabled
[    0.771304] pci 0000:0a:02.0:   PREFETCH window: disabled
[    0.771442] pci 0000:09:00.0: PCI bridge, secondary bus 0000:0a
[    0.771571] pci 0000:09:00.0:   IO window: disabled
[    0.771761] pci 0000:09:00.0:   MEM window: disabled
[    0.771899] pci 0000:09:00.0:   PREFETCH window: disabled
[    0.772037] pci 0000:09:00.3: PCI bridge, secondary bus 0000:10
[    0.772166] pci 0000:09:00.3:   IO window: disabled
[    0.772356] pci 0000:09:00.3:   MEM window: disabled
[    0.772494] pci 0000:09:00.3:   PREFETCH window: disabled
[    0.772631] pci 0000:00:02.0: PCI bridge, secondary bus 0000:09
[    0.772762] pci 0000:00:02.0:   IO window: disabled
[    0.772890] pci 0000:00:02.0:   MEM window: 0xfde00000-0xfdefffff
[    0.773022] pci 0000:00:02.0:   PREFETCH window: disabled
[    0.773151] pci 0000:00:03.0: PCI bridge, secondary bus 0000:06
[    0.773281] pci 0000:00:03.0:   IO window: 0x4000-0x4fff
[    0.773411] pci 0000:00:03.0:   MEM window: 0xfdc00000-0xfddfffff
[    0.773542] pci 0000:00:03.0:   PREFETCH window: 0x80000000-0x800fffff
[    0.773676] pci 0000:00:04.0: PCI bridge, secondary bus 0000:13
[    0.773806] pci 0000:00:04.0:   IO window: 0x5000-0x5fff
[    0.773935] pci 0000:00:04.0:   MEM window: 0xfdf00000-0xfdffffff
[    0.774067] pci 0000:00:04.0:   PREFETCH window: 0x80100000-0x801fffff
[    0.774200] pci 0000:00:05.0: PCI bridge, secondary bus 0000:16
[    0.774330] pci 0000:00:05.0:   IO window: disabled
[    0.774457] pci 0000:00:05.0:   MEM window: disabled
[    0.774585] pci 0000:00:05.0:   PREFETCH window: disabled
[    0.774716] pci 0000:02:00.0: PCI bridge, secondary bus 0000:03
[    0.774832] pci 0000:02:00.0:   IO window: disabled
[    0.774942] pci 0000:02:00.0:   MEM window: 0xf8000000-0xf9ffffff
[    0.775050] pci 0000:02:00.0:   PREFETCH window: 0x80200000-0x802fffff
[    0.775158] pci 0000:00:06.0: PCI bridge, secondary bus 0000:02
[    0.775263] pci 0000:00:06.0:   IO window: disabled
[    0.775368] pci 0000:00:06.0:   MEM window: 0xf8000000-0xf9ffffff
[    0.775474] pci 0000:00:06.0:   PREFETCH window: 0x80200000-0x802fffff
[    0.775583] pci 0000:04:00.0: PCI bridge, secondary bus 0000:05
[    0.775688] pci 0000:04:00.0:   IO window: disabled
[    0.775793] pci 0000:04:00.0:   MEM window: 0xfa000000-0xfbffffff
[    0.775915] pci 0000:04:00.0:   PREFETCH window: 0x80300000-0x803fffff
[    0.776049] pci 0000:00:07.0: PCI bridge, secondary bus 0000:04
[    0.776179] pci 0000:00:07.0:   IO window: disabled
[    0.776306] pci 0000:00:07.0:   MEM window: 0xfa000000-0xfbffffff
[    0.776438] pci 0000:00:07.0:   PREFETCH window: 0x80300000-0x803fffff
[    0.776572] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:01
[    0.776703] pci 0000:00:1e.0:   IO window: 0x2000-0x3fff
[    0.776833] pci 0000:00:1e.0:   MEM window: 0xf7e00000-0xf7ffffff
[    0.776965] pci 0000:00:1e.0:   PREFETCH window: 0x000000d8000000-0x000000dfffffff
[    0.777185] pci 0000:00:02.0: setting latency timer to 64
[    0.777325] pci 0000:09:00.0: setting latency timer to 64
[    0.777466] pci 0000:0a:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.777600] pci 0000:0a:00.0: setting latency timer to 64
[    0.777738] pci 0000:0a:01.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.777875] pci 0000:0a:01.0: setting latency timer to 64
[    0.778013] pci 0000:0a:02.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    0.778149] pci 0000:0a:02.0: setting latency timer to 64
[    0.778332] pci 0000:09:00.3: setting latency timer to 64
[    0.778380] pci 0000:00:03.0: setting latency timer to 64
[    0.778384] pci 0000:00:04.0: setting latency timer to 64
[    0.778389] pci 0000:00:05.0: setting latency timer to 64
[    0.778393] pci 0000:00:06.0: setting latency timer to 64
[    0.778399] pci 0000:02:00.0: setting latency timer to 64
[    0.778403] pci 0000:00:07.0: setting latency timer to 64
[    0.778409] pci 0000:04:00.0: setting latency timer to 64
[    0.778414] pci 0000:00:1e.0: setting latency timer to 64
[    0.778416] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
[    0.778418] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
[    0.778419] pci_bus 0000:09: resource 1 mem: [0xfde00000-0xfdefffff]
[    0.778421] pci_bus 0000:06: resource 0 io:  [0x4000-0x4fff]
[    0.778423] pci_bus 0000:06: resource 1 mem: [0xfdc00000-0xfddfffff]
[    0.778424] pci_bus 0000:06: resource 2 pref mem [0x80000000-0x800fffff]
[    0.778426] pci_bus 0000:13: resource 0 io:  [0x5000-0x5fff]
[    0.778427] pci_bus 0000:13: resource 1 mem: [0xfdf00000-0xfdffffff]
[    0.778429] pci_bus 0000:13: resource 2 pref mem [0x80100000-0x801fffff]
[    0.778430] pci_bus 0000:02: resource 1 mem: [0xf8000000-0xf9ffffff]
[    0.778432] pci_bus 0000:02: resource 2 pref mem [0x80200000-0x802fffff]
[    0.778433] pci_bus 0000:03: resource 1 mem: [0xf8000000-0xf9ffffff]
[    0.778434] pci_bus 0000:03: resource 2 pref mem [0x80200000-0x802fffff]
[    0.778436] pci_bus 0000:04: resource 1 mem: [0xfa000000-0xfbffffff]
[    0.778437] pci_bus 0000:04: resource 2 pref mem [0x80300000-0x803fffff]
[    0.778439] pci_bus 0000:05: resource 1 mem: [0xfa000000-0xfbffffff]
[    0.778440] pci_bus 0000:05: resource 2 pref mem [0x80300000-0x803fffff]
[    0.778442] pci_bus 0000:01: resource 0 io:  [0x2000-0x3fff]
[    0.778443] pci_bus 0000:01: resource 1 mem: [0xf7e00000-0xf7ffffff]
[    0.778444] pci_bus 0000:01: resource 2 pref mem [0xd8000000-0xdfffffff]
[    0.778446] pci_bus 0000:01: resource 3 io:  [0x00-0xffff]
[    0.778447] pci_bus 0000:01: resource 4 mem: [0x000000-0xffffffffffffffff]
[    0.778458] NET: Registered protocol family 2
[    0.778610] IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.778948] TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
[    0.780859] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.781531] TCP: Hash tables configured (established 262144 bind 65536)
[    0.781663] TCP reno registered
[    0.781864] NET: Registered protocol family 1
[    0.782240] platform rtc_cmos: registered platform RTC device (no PNP device found)
[    0.783890] microcode: CPU0 sig=0x6f6, pf=0x4, revision=0xc6
[    0.784037] microcode: CPU1 sig=0x6f6, pf=0x4, revision=0xc6
[    0.784176] microcode: CPU2 sig=0x6f6, pf=0x4, revision=0xc6
[    0.784312] microcode: CPU3 sig=0x6f6, pf=0x4, revision=0xc6
[    0.784500] Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.788777] SGI XFS with ACLs, security attributes, large block/inode numbers, no debug enabled
[    0.789674] msgmni has been set to 4017
[    0.789897] io scheduler noop registered
[    0.790031] io scheduler cfq registered (default)
[    0.810079] pci 0000:01:03.0: Boot video device
[    0.811101] pcieport-driver 0000:00:02.0: irq 48 for MSI/MSI-X
[    0.811108] pcieport-driver 0000:00:02.0: setting latency timer to 64
[    0.811264] pcieport-driver 0000:00:03.0: irq 49 for MSI/MSI-X
[    0.811269] pcieport-driver 0000:00:03.0: setting latency timer to 64
[    0.811424] pcieport-driver 0000:00:04.0: irq 50 for MSI/MSI-X
[    0.811429] pcieport-driver 0000:00:04.0: setting latency timer to 64
[    0.811601] pcieport-driver 0000:00:05.0: irq 51 for MSI/MSI-X
[    0.811607] pcieport-driver 0000:00:05.0: setting latency timer to 64
[    0.811765] pcieport-driver 0000:00:06.0: irq 52 for MSI/MSI-X
[    0.811770] pcieport-driver 0000:00:06.0: setting latency timer to 64
[    0.811924] pcieport-driver 0000:00:07.0: irq 53 for MSI/MSI-X
[    0.811930] pcieport-driver 0000:00:07.0: setting latency timer to 64
[    0.814244] pcieport-driver 0000:0a:00.0: irq 54 for MSI/MSI-X
[    0.814381] pcieport-driver 0000:0a:00.0: setting latency timer to 64
[    0.816580] pcieport-driver 0000:0a:01.0: irq 55 for MSI/MSI-X
[    0.816763] pcieport-driver 0000:0a:01.0: setting latency timer to 64
[    0.818961] pcieport-driver 0000:0a:02.0: irq 56 for MSI/MSI-X
[    0.819099] pcieport-driver 0000:0a:02.0: setting latency timer to 64
[    0.820259] aer 0000:00:02.0:pcie02: AER service couldn't init device: no _OSC support
[    0.820265] aer 0000:00:03.0:pcie02: AER service couldn't init device: no _OSC support
[    0.820271] aer 0000:00:04.0:pcie02: AER service couldn't init device: no _OSC support
[    0.820276] aer 0000:00:05.0:pcie02: AER service couldn't init device: no _OSC support
[    0.820282] aer 0000:00:06.0:pcie02: AER service couldn't init device: no _OSC support
[    0.820287] aer 0000:00:07.0:pcie02: AER service couldn't init device: no _OSC support
[    0.820554] input: Power Button as /class/input/input0
[    0.820660] ACPI: Power Button [PWRF]
[    0.820958] processor LNXCPU:00: registered as cooling_device0
[    0.821131] processor LNXCPU:01: registered as cooling_device1
[    0.821360] processor LNXCPU:06: registered as cooling_device2
[    0.821531] processor LNXCPU:07: registered as cooling_device3
[    0.821956] thermal LNXTHERM:01: registered as thermal_zone0
[    0.822070] ACPI: Thermal Zone [THM0] (8 C)
[    0.825530] Linux agpgart interface v0.103
[    0.825680] [drm] Initialized drm 1.1.0 20060810
[    0.825785] [drm] radeon default to kernel modesetting.
[    0.825900] [drm] radeon kernel modesetting enabled.
[    0.826036] radeon 0000:01:03.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    0.828279] [drm] radeon: Initializing kernel modesetting.
[    0.828404] [drm] register mmio base: 0xF7FF0000
[    0.828509] [drm] register mmio size: 65536
[    0.828873] [drm] GPU reset succeed (RBBM_STATUS=0x00000140)
[    0.838975] [drm] Clocks initialized !
[    0.841643] [drm] Detected VRAM RAM=32M, BAR=128M
[    0.841750] [drm] RAM width 64bits SDR
[    0.842057] [drm] radeon: VRAM 32M
[    0.842159] [drm] radeon: VRAM from 0x00000000 to 0x03FFFFFF
[    0.842264] [drm] radeon: VRAM less than aperture workaround enabled
[    0.842370] [drm] radeon: GTT 512M
[    0.842471] [drm] radeon: GTT from 0x20000000 to 0x3FFFFFFF
[    0.855894] [drm] radeon: irq initialized.
[    0.856061] [TTM] TTM available graphics memory: 1004 MiB
[    0.856167] [TTM] TTM available object memory: 1004 MiB
[    0.856285] [drm] radeon: 32M of VRAM memory ready
[    0.856390] [drm] radeon: 512M of GTT memory ready.
[    0.856496] [drm] GART: num cpu pages 131072, num gpu pages 131072
[    0.857420] [drm] radeon: cp idle (0x00008080)
[    0.857526] [drm] Loading R100 Microcode
[    0.857770] [drm] radeon: ring at 0x0000000020000000
[    0.857895] [drm] ring test succeeded in 1 usecs
[    0.858053] [drm] radeon: ib pool ready.
[    2.850150] [drm] ib test succeeded in 0 usecs
[    2.850637] [drm] Radeon Display Connectors
[    2.850742] [drm] Connector 0:
[    2.850844] [drm]   VGA
[    2.850954] [drm]   DDC: 0x60 0x60 0x60 0x60 0x60 0x60 0x60 0x60
[    2.851059] [drm]   Encoders:
[    2.851160] [drm]     CRT1: INTERNAL_DAC1
[    2.852687] [drm] Connector 1:
[    2.852786] [drm]   VGA
[    2.852885] [drm]   DDC: 0x6c 0x6c 0x6c 0x6c 0x6c 0x6c 0x6c 0x6c
[    2.852990] [drm]   Encoders:
[    2.853090] [drm]     CRT2: INTERNAL_DAC2
[    2.906778] i2c-adapter i2c-0: Overriding HP KVM Module EDID with manual EDID for HP TFT7600
[    2.908986] i2c-adapter i2c-1: unable to read EDID block.
[    2.909090] radeon 0000:01:03.0: VGA-2: no EDID data
[    2.965340] i2c-adapter i2c-0: Overriding HP KVM Module EDID with manual EDID for HP TFT7600
[    3.041271] [drm] fb mappable at 0xD8040000
[    3.041376] [drm] vram apper at 0xD8000000
[    3.041478] [drm] size 5184000
[    3.041578] [drm] fb depth is 24
[    3.041678] [drm]    pitch is 5760
[    3.193318] [drm] DAC-5: set mode 1440x900 1a
[    3.291120] Console: switching to colour frame buffer device 180x56
[    3.337157] fb0: radeondrmfb frame buffer device
[    3.337432] registered panic notifier
[    3.337647] [drm] radeon: kernel modesetting successfully initialized.
[    3.338029] [drm] Initialized radeon 2.0.0 20080528 for 0000:01:03.0 on minor 0
[    3.338525] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    3.339031] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    3.339487] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    3.340314] 00:09: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    3.340820] HP CISS Driver (v 3.6.20)
[    3.341280] cciss 0000:06:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    3.341714] cciss 0000:06:00.0: irq 57 for MSI/MSI-X
[    3.341716] cciss 0000:06:00.0: irq 58 for MSI/MSI-X
[    3.341718] cciss 0000:06:00.0: irq 59 for MSI/MSI-X
[    3.341720] cciss 0000:06:00.0: irq 60 for MSI/MSI-X
[    3.440100] IRQ 59/cciss0: IRQF_DISABLED is not guaranteed on shared IRQs
[    3.440509] cciss0: <0x3230> at PCI 0000:06:00.0 IRQ 59 using DAC
[    3.441541]       blocks= 71065440 block_size= 512
[    3.441885]       heads=255, sectors=32, cylinders=8709
[    3.441886] 
[    3.442476]       blocks= 71065440 block_size= 512
[    3.442798]       heads=255, sectors=32, cylinders=8709
[    3.442799] 
[    3.443215]  cciss/c0d0: p1 p2
[    3.444021] hpilo 0000:01:04.2: PCI INT B -> GSI 22 (level, low) -> IRQ 22
[    3.445205] PNP: PS/2 Controller [PNP0303:KBD,PNP0f0e:PS2M] at 0x60,0x64 irq 1,12
[    3.447121] serio: i8042 KBD port at 0x60,0x64 irq 1
[    3.447420] serio: i8042 AUX port at 0x60,0x64 irq 12
[    3.447810] mice: PS/2 mouse device common for all mice
[    3.448233] rtc_cmos rtc_cmos: RTC can wake from S4
[    3.448557] rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0
[    3.448948] rtc0: alarms up to one year, y3k, 114 bytes nvram, hpet irqs
[    3.449408] cpuidle: using governor ladder
[    3.449654] cpuidle: using governor menu
[    3.450509] usbcore: registered new interface driver usbhid
[    3.460058] usbhid: v2.6:USB HID core driver
[    3.469772] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[    3.480084] CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
[    3.490670] nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or
[    3.501667] sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
[    3.513352] ip_tables: (C) 2000-2006 Netfilter Core Team
[    3.524952] TCP cubic registered
[    3.536729] input: AT Translated Set 2 keyboard as /class/input/input1
[    3.536980] NET: Registered protocol family 10
[    3.537170] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    3.537189] NET: Registered protocol family 17
[    3.587021] rtc_cmos rtc_cmos: setting system clock to 2009-12-28 15:21:02 UTC (1262013662)
[    4.462539] input: ImExPS/2 Generic Explorer Mouse as /class/input/input2
[    4.480669] Filesystem "cciss/c0d0p2": Disabling barriers, trial barrier write failed
[    4.507937] XFS mounting filesystem cciss/c0d0p2
[    4.617359] Ending clean XFS mount for filesystem: cciss/c0d0p2
[    4.617397] VFS: Mounted root (xfs filesystem) readonly on device 104:2.
[    4.632486] Freeing unused kernel memory: 380k freed
[    4.647938] Write protecting the kernel read-only data: 4956k
[    5.158884] ioctl32(showconsole:626): Unknown cmd fd(0) cmd(80045432){t:'T';sz:4} arg(ffa3e5f8) on /dev/console
[    5.636185] udevd version 128 started
[    5.881067] libata version 3.00 loaded.
[    5.891595] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    5.902153] uhci_hcd: USB Universal Host Controller Interface driver
[    5.902239] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    5.902250] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    5.902255] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    5.902262] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
[    5.902334] uhci_hcd 0000:00:1d.0: irq 16, io base 0x00001000
[    5.902384] usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
[    5.902386] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.902388] usb usb1: Product: UHCI Host Controller
[    5.902390] usb usb1: Manufacturer: Linux 2.6.31.9-x86_64 uhci_hcd
[    5.902391] usb usb1: SerialNumber: 0000:00:1d.0
[    5.902448] usb usb1: configuration #1 chosen from 1 choice
[    5.902474] hub 1-0:1.0: USB hub found
[    5.902480] hub 1-0:1.0: 2 ports detected
[    5.902546] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    5.902557] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    5.902563] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    5.902567] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 2
[    5.902633] uhci_hcd 0000:00:1d.1: irq 17, io base 0x00001020
[    5.902666] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    5.902668] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.902670] usb usb2: Product: UHCI Host Controller
[    5.902671] usb usb2: Manufacturer: Linux 2.6.31.9-x86_64 uhci_hcd
[    5.902672] usb usb2: SerialNumber: 0000:00:1d.1
[    5.902708] usb usb2: configuration #1 chosen from 1 choice
[    5.902733] hub 2-0:1.0: USB hub found
[    5.902738] hub 2-0:1.0: 2 ports detected
[    5.902794] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    5.902803] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    5.902809] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    5.902813] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 3
[    5.902887] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00001040
[    5.902932] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    5.902934] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.902936] usb usb3: Product: UHCI Host Controller
[    5.902937] usb usb3: Manufacturer: Linux 2.6.31.9-x86_64 uhci_hcd
[    5.902939] usb usb3: SerialNumber: 0000:00:1d.2
[    5.902975] usb usb3: configuration #1 chosen from 1 choice
[    5.902998] hub 3-0:1.0: USB hub found
[    5.903003] hub 3-0:1.0: 2 ports detected
[    5.903057] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    5.903064] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    5.903067] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    5.903072] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 4
[    5.903120] uhci_hcd 0000:00:1d.3: irq 19, io base 0x00001060
[    5.903162] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    5.903164] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.903166] usb usb4: Product: UHCI Host Controller
[    5.903167] usb usb4: Manufacturer: Linux 2.6.31.9-x86_64 uhci_hcd
[    5.903169] usb usb4: SerialNumber: 0000:00:1d.3
[    5.903204] usb usb4: configuration #1 chosen from 1 choice
[    5.903229] hub 4-0:1.0: USB hub found
[    5.903234] hub 4-0:1.0: 2 ports detected
[    5.903303] uhci_hcd 0000:01:04.4: PCI INT B -> GSI 22 (level, low) -> IRQ 22
[    5.903317] uhci_hcd 0000:01:04.4: UHCI Host Controller
[    5.903322] uhci_hcd 0000:01:04.4: new USB bus registered, assigned bus number 5
[    5.903352] uhci_hcd 0000:01:04.4: port count misdetected? forcing to 2 ports
[    5.904303] uhci_hcd 0000:01:04.4: irq 22, io base 0x00003800
[    5.904534] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    5.904536] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.904538] usb usb5: Product: UHCI Host Controller
[    5.904539] usb usb5: Manufacturer: Linux 2.6.31.9-x86_64 uhci_hcd
[    5.904541] usb usb5: SerialNumber: 0000:01:04.4
[    5.904578] usb usb5: configuration #1 chosen from 1 choice
[    5.904602] hub 5-0:1.0: USB hub found
[    5.904607] hub 5-0:1.0: 2 ports detected
[    6.849125] Warning! ehci_hcd should always be loaded before uhci_hcd and ohci_hcd, not after
[    6.863240] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    6.877328] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    6.877331] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    6.877724] hpwdt 0000:01:04.0: PCI INT A -> GSI 21 (level, low) -> IRQ 21
[    6.877731] hpwdt: New timer passed in is 30 seconds.
[    6.886790] Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.1 (May 6, 2009)
[    6.886811] bnx2 0000:03:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    6.934318] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 6
[    6.934349] hp Watchdog Timer Driver: 1.1.1, timer margin: 30 seconds (nowayout=0), allow kernel dump: OFF (default = 0/OFF), priority: LAST (default = 0/LAST).
[    6.968179] ehci_hcd 0000:00:1d.7: debug port 1
[    6.983599] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
[    6.983607] ehci_hcd 0000:00:1d.7: irq 16, io mem 0xf7df0000
[    7.022578] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    7.038001] usb usb6: New USB device found, idVendor=1d6b, idProduct=0002
[    7.047330] QLogic Fibre Channel HBA Driver: 8.03.01-k4
[    7.047368] qla2xxx 0000:13:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    7.047391] qla2xxx 0000:13:00.0: Found an ISP2432, irq 17, iobase 0xffffc90000028000
[    7.047590] qla2xxx 0000:13:00.0: irq 61 for MSI/MSI-X
[    7.047618] qla2xxx 0000:13:00.0: Configuring PCI space...
[    7.047622] qla2xxx 0000:13:00.0: setting latency timer to 64
[    7.056415] ipmi message handler version 39.2
[    7.078240] qla2xxx 0000:13:00.0: Configure NVRAM parameters...
[    7.114025] qla2xxx 0000:13:00.0: Verifying loaded RISC code...
[    7.163871] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    7.173984] qla2xxx 0000:13:00.0: firmware: requesting ql2400_fw.bin
[    7.195674] usb usb6: Product: EHCI Host Controller
[    7.195675] usb usb6: Manufacturer: Linux 2.6.31.9-x86_64 ehci_hcd
[    7.195676] usb usb6: SerialNumber: 0000:00:1d.7
[    7.195726] usb usb6: configuration #1 chosen from 1 choice
[    7.195753] hub 6-0:1.0: USB hub found
[    7.195759] hub 6-0:1.0: 8 ports detected
[    7.272578] IPMI System Interface driver.
[    7.272582] ipmi_si: Trying SMBIOS-specified kcs state machine at i/o address 0xca2, slave address 0x20, irq 0
[    7.323995] qla2xxx 0000:13:00.0: FW: Loading via request-firmware...
[    7.325402] ata_piix 0000:00:1f.1: version 2.13
[    7.325417] ata_piix 0000:00:1f.1: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    7.325476] ata_piix 0000:00:1f.1: setting latency timer to 64
[    7.327089] scsi1 : ata_piix
[    7.327187] scsi2 : ata_piix
[    7.327214] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x500 irq 14
[    7.327216] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x508 irq 15
[    7.425772] usb 5-1: new full speed USB device using uhci_hcd and address 2
[    7.602798] ata1.00: ATAPI: HL-DT-STCD-RW/DVD DRIVE GCC-4244N, 2.00, max UDMA/33
[    7.626918] usb 5-1: New USB device found, idVendor=03f0, idProduct=1027
[    7.643621] usb 5-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    7.650493] ata1.00: configured for UDMA/33
[    7.676999] usb 5-1: Product: Virtual Keyboard
[    7.678983] scsi 1:0:0:0: CD-ROM            HL-DT-ST RW/DVD GCC-4244N 2.00 PQ: 0 ANSI: 5
[    7.710897] usb 5-1: Manufacturer: HP
[    7.727860] usb 5-1: configuration #1 chosen from 1 choice
[    7.749919] ipmi: Found new BMC (man_id: 0x00000b,  prod_id: 0x0000, dev_id: 0x11)
[    7.750910] sr0: scsi3-mmc drive: 24x/24x writer cd/rw xa/form2 cdda tray
[    7.750912] Uniform CD-ROM driver Revision: 3.20
[    7.750980] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    7.754119] sr 1:0:0:0: Attached scsi generic sg0 type 5
[    7.810014] bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
[    7.837714] IPMI kcs interface initialized
[    7.840148] input: HP Virtual Keyboard as /class/input/input3
[    7.840161] generic-usb 0003:03F0:1027.0001: input: USB HID v1.01 Keyboard [HP Virtual Keyboard] on usb-0000:01:04.4-1/input0
[    7.891548] ipmi_si: Trying ACPI-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[    7.910105] ipmi_si: duplicate interface
[    7.910350] input: HP Virtual Keyboard as /class/input/input4
[    7.910384] generic-usb 0003:03F0:1027.0002: input: USB HID v1.01 Mouse [HP Virtual Keyboard] on usb-0000:01:04.4-1/input1
[    7.921290] qla2xxx 0000:13:00.0: Allocated (64 KB) for EFT...
[    7.921362] qla2xxx 0000:13:00.0: Allocated (1285 KB) for firmware dump...
[    7.941327] scsi0 : qla2xxx
[    7.941546] qla2xxx 0000:13:00.0: 
[    7.941546]  QLogic Fibre Channel HBA Driver: 8.03.01-k4
[    7.941547]   QLogic QLE2460 - PCI-Express Single Channel 4Gb Fibre Channel HBA
[    7.941549]   ISP2432: PCIe (2.5GT/s x4) @ 0000:13:00.0 hdma-, host#=0, fw=4.00.16 (2)
[    8.110927] bnx2 0000:03:00.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
[    8.123846] ipmi_si 0000:01:04.6: PCI INT A -> GSI 21 (level, low) -> IRQ 21
[    8.123850] ipmi_si: Trying PCI-specified kcs state machine at mem address 0xf7ef0000, slave address 0x0, irq 21
[    8.172205] eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B2) PCI-X 64-bit 133MHz found at mem f8000000, IRQ 18, node addr **:**:**:**:**:**
[    8.181311] usb 5-2: new full speed USB device using uhci_hcd and address 3
[    8.209691] bnx2 0000:05:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[    8.338829] usb 5-2: New USB device found, idVendor=03f0, idProduct=1327
[    8.357740] usb 5-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    8.376823] usb 5-2: Product: Virtual Hub
[    8.376824] usb 5-2: Manufacturer: HP
[    8.376897] usb 5-2: configuration #1 chosen from 1 choice
[    8.413777] IRQ 21/ipmi_si: IRQF_DISABLED is not guaranteed on shared IRQs
[    8.414072]   Using irq 21
[    8.417104] hub 5-2:1.0: USB hub found
[    8.470906] hub 5-2:1.0: 7 ports detected
[    8.646605] ipmi: interfacing existing BMC (man_id: 0x00000b, prod_id: 0x0000, dev_id: 0x11)
[    8.665517] IPMI kcs interface initialized
[    8.892515] bnx2 0000:05:00.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
[    8.915605] bnx2 0000:05:00.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
[    8.937916] eth1: Broadcom NetXtreme II BCM5708 1000Base-T (B2) PCI-X 64-bit 133MHz found at mem fa000000, IRQ 19, node addr **:**:**:**:**:**
[    9.307650] Adding 2104472k swap on /dev/cciss/c0d0p1.  Priority:-1 extents:1 across:2104472k 
[    9.702173] qla2xxx 0000:13:00.0: LIP reset occurred (f8f7).
[    9.721977] qla2xxx 0000:13:00.0: LIP occurred (f8f7).
[    9.787127] qla2xxx 0000:13:00.0: LOOP UP detected (2 Gbps).
[   10.308303] scsi 0:0:0:0: Direct-Access     IBM      ********         0914 PQ: 0 ANSI: 5
[   10.332191] scsi 0:0:1:0: Direct-Access     IBM      ********         0914 PQ: 0 ANSI: 5
[   10.354694] sd 0:0:0:0: Attached scsi generic sg1 type 0
[   10.374105] sd 0:0:1:0: Attached scsi generic sg2 type 0
[   10.393342] sd 0:0:0:0: [sda] 251658240 512-byte logical blocks: (128 GB/120 GiB)
[   10.412530] sd 0:0:1:0: [sdb] 251658240 512-byte logical blocks: (128 GB/120 GiB)
[   10.412791] sd 0:0:0:0: [sda] Write Protect is off
[   10.412794] sd 0:0:0:0: [sda] Mode Sense: 77 00 10 08
[   10.450000] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, supports DPO and FUA
[   10.450176] sd 0:0:1:0: [sdb] Write Protect is off
[   10.450179] sd 0:0:1:0: [sdb] Mode Sense: 77 00 10 08
[   10.486444] sd 0:0:1:0: [sdb] Write cache: enabled, read cache: enabled, supports DPO and FUA
[   10.505254]  sda:
[   10.506247]  sdb: sda1
[   10.518144] sd 0:0:0:0: [sda] Attached SCSI disk
[   10.628887] device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initialised: dm-devel@redhat.com
[   14.959376]  sdb1
[   14.985934] sd 0:0:1:0: [sdb] Attached SCSI disk
[   15.097643] device-mapper: multipath: version 1.1.0 loaded
[   15.205644] sd 0:0:0:0: rdac: AVT mode detected
[   15.223207] sd 0:0:0:0: rdac: LUN 0 (owned (AVT mode))
[   15.261436] sd 0:0:1:0: rdac: AVT mode detected
[   15.277939] sd 0:0:1:0: rdac: LUN 0 (owned (AVT mode))
[   15.294317] rdac: device handler registered
[   15.319805] device-mapper: multipath round-robin: version 1.0.0 loaded
[   15.340899] sd 0:0:0:0: rdac: AVT mode detected
[   20.427713] sd 0:0:0:0: rdac: AVT mode detected
[   21.726586] loop: module loaded
[   21.800552] XFS mounting filesystem dm-1
[   22.252758] Ending clean XFS mount for filesystem: dm-1
[   22.441315] ioctl32(showconsole:1534): Unknown cmd fd(0) cmd(80045432){t:'T';sz:4} arg(ffa9ca78) on /dev/console
[   33.683606] ioctl32(showconsole:1801): Unknown cmd fd(0) cmd(80045432){t:'T';sz:4} arg(ffe8dc58) on /dev/console
[   35.020011] bnx2: eth0: using MSI
[   35.020271] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   35.373790] console [netcon0] enabled
[   35.387603] netconsole: network logging started
[   35.613014] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[   35.623577] ipmi device interface
[   36.957973] sd 0:0:0:0: rdac: AVT mode detected
[   38.148973] bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex
[   38.149291] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   40.500927] netconsole: local port 61561
[   40.500932] netconsole: local IP ***.***.***.***
[   40.500934] netconsole: interface eth0
[   40.500936] netconsole: remote port 514
[   40.500937] netconsole: remote IP ***.***.***.***
[   40.500939] netconsole: remote ethernet address **:**:**:**:**:**
[   40.541269] netconsole: network logging started


--MP_/Dkc_9.owEn1_UJCXzpdneHl
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=.config

#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.31.9
# Mon Dec 28 15:38:40 2009
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_FAST_CMPXCHG_LOCAL=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_GENERIC_SPINLOCK=y
# CONFIG_RWSEM_XCHGADD_ALGORITHM is not set
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_HAVE_DYNAMIC_PER_CPU_AREA=y
CONFIG_HAVE_CPUMASK_OF_CPU_MAP=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_TRAMPOLINE=y
# CONFIG_KTIME_SCALAR is not set
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION="-x86_64"
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
# CONFIG_KERNEL_GZIP is not set
CONFIG_KERNEL_BZIP2=y
# CONFIG_KERNEL_LZMA is not set
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set
# CONFIG_AUDIT is not set

#
# RCU Subsystem
#
CONFIG_CLASSIC_RCU=y
# CONFIG_TREE_RCU is not set
# CONFIG_PREEMPT_RCU is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_PREEMPT_RCU_TRACE is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_GROUP_SCHED=y
# CONFIG_FAIR_GROUP_SCHED is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_USER_SCHED=y
# CONFIG_CGROUP_SCHED is not set
# CONFIG_CGROUPS is not set
CONFIG_SYSFS_DEPRECATED=y
CONFIG_SYSFS_DEPRECATED_V2=y
# CONFIG_RELAY is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
# CONFIG_USER_NS is not set
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_BLK_DEV_INITRD is not set
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EMBEDDED is not set
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
# CONFIG_KALLSYMS_EXTRA_PASS is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_HAVE_PERF_COUNTERS=y

#
# Performance Counters
#
# CONFIG_PERF_COUNTERS is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_PROFILING is not set
# CONFIG_MARKERS is not set
CONFIG_HAVE_OPROFILE=y
# CONFIG_KPROBES is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_API_DEBUG=y

#
# GCOV-based kernel profiling
#
# CONFIG_SLOW_WORK is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
CONFIG_MODVERSIONS=y
CONFIG_MODULE_SRCVERSION_ALL=y
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
# CONFIG_BLK_DEV_BSG is not set
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=m
CONFIG_IOSCHED_DEADLINE=m
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_AS is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
# CONFIG_FREEZER is not set

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
# CONFIG_SPARSE_IRQ is not set
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_SCHED_OMIT_FRAME_POINTER=y
# CONFIG_PARAVIRT_GUEST is not set
# CONFIG_MEMTEST is not set
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MPSC is not set
CONFIG_MCORE2=y
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_CPU=y
CONFIG_X86_L1_CACHE_BYTES=64
CONFIG_X86_INTERNODE_CACHE_BYTES=64
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_P6_NOP=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
# CONFIG_X86_DS is not set
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
# CONFIG_AMD_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_IOMMU_API is not set
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=4
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_NEW_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
CONFIG_X86_THERMAL_VECTOR=y
# CONFIG_I8K is not set
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_X86_CPU_DEBUG is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
# CONFIG_DISCONTIGMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_VMEMMAP=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_HAVE_MLOCK=y
CONFIG_HAVE_MLOCKED_PAGE_BIT=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW_64K=y
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
# CONFIG_HOTPLUG_CPU is not set
# CONFIG_COMPAT_VDSO is not set
CONFIG_CMDLINE_BOOL=y
CONFIG_CMDLINE="vga=normal"
# CONFIG_CMDLINE_OVERRIDE is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
CONFIG_ACPI=y
CONFIG_ACPI_PROCFS=y
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_SYSFS_POWER=y
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=y
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
# CONFIG_CPU_FREQ_DEBUG is not set
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_STAT_DETAILS is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set

#
# CPUFreq processor drivers
#
CONFIG_X86_ACPI_CPUFREQ=y
# CONFIG_X86_POWERNOW_K8 is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y

#
# Memory power savings
#
# CONFIG_I7300_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_DMAR is not set
# CONFIG_INTR_REMAP is not set
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
# CONFIG_PCIEASPM is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_LEGACY is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_STUB is not set
# CONFIG_HT_IRQ is not set
# CONFIG_PCI_IOV is not set
CONFIG_ISA_DMA_API=y
CONFIG_K8_NB=y
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_MMAP=y
CONFIG_UNIX=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_FIB_HASH=y
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
# CONFIG_INET_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
CONFIG_INET_LRO=y
# CONFIG_INET_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_PRIVACY is not set
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
# CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET6_XFRM_MODE_TUNNEL is not set
# CONFIG_INET6_XFRM_MODE_BEET is not set
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
# CONFIG_IPV6_SIT is not set
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y

#
# Core Netfilter Configuration
#
# CONFIG_NETFILTER_NETLINK_QUEUE is not set
# CONFIG_NETFILTER_NETLINK_LOG is not set
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CT_ACCT=y
# CONFIG_NF_CONNTRACK_MARK is not set
# CONFIG_NF_CONNTRACK_EVENTS is not set
# CONFIG_NF_CT_PROTO_DCCP is not set
# CONFIG_NF_CT_PROTO_SCTP is not set
# CONFIG_NF_CT_PROTO_UDPLITE is not set
# CONFIG_NF_CONNTRACK_AMANDA is not set
CONFIG_NF_CONNTRACK_FTP=y
# CONFIG_NF_CONNTRACK_H323 is not set
# CONFIG_NF_CONNTRACK_IRC is not set
# CONFIG_NF_CONNTRACK_NETBIOS_NS is not set
# CONFIG_NF_CONNTRACK_PPTP is not set
# CONFIG_NF_CONNTRACK_SANE is not set
# CONFIG_NF_CONNTRACK_SIP is not set
# CONFIG_NF_CONNTRACK_TFTP is not set
# CONFIG_NF_CT_NETLINK is not set
CONFIG_NETFILTER_XTABLES=y
# CONFIG_NETFILTER_XT_TARGET_CLASSIFY is not set
# CONFIG_NETFILTER_XT_TARGET_CONNMARK is not set
# CONFIG_NETFILTER_XT_TARGET_MARK is not set
# CONFIG_NETFILTER_XT_TARGET_NFLOG is not set
# CONFIG_NETFILTER_XT_TARGET_NFQUEUE is not set
# CONFIG_NETFILTER_XT_TARGET_RATEEST is not set
# CONFIG_NETFILTER_XT_TARGET_TCPMSS is not set
# CONFIG_NETFILTER_XT_MATCH_CLUSTER is not set
# CONFIG_NETFILTER_XT_MATCH_COMMENT is not set
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
# CONFIG_NETFILTER_XT_MATCH_CONNMARK is not set
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
# CONFIG_NETFILTER_XT_MATCH_DCCP is not set
# CONFIG_NETFILTER_XT_MATCH_DSCP is not set
# CONFIG_NETFILTER_XT_MATCH_ESP is not set
# CONFIG_NETFILTER_XT_MATCH_HASHLIMIT is not set
CONFIG_NETFILTER_XT_MATCH_HELPER=y
# CONFIG_NETFILTER_XT_MATCH_HL is not set
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
# CONFIG_NETFILTER_XT_MATCH_LENGTH is not set
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
# CONFIG_NETFILTER_XT_MATCH_MAC is not set
# CONFIG_NETFILTER_XT_MATCH_MARK is not set
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
CONFIG_NETFILTER_XT_MATCH_OWNER=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
# CONFIG_NETFILTER_XT_MATCH_QUOTA is not set
# CONFIG_NETFILTER_XT_MATCH_RATEEST is not set
# CONFIG_NETFILTER_XT_MATCH_REALM is not set
# CONFIG_NETFILTER_XT_MATCH_RECENT is not set
# CONFIG_NETFILTER_XT_MATCH_SCTP is not set
CONFIG_NETFILTER_XT_MATCH_STATE=y
# CONFIG_NETFILTER_XT_MATCH_STATISTIC is not set
# CONFIG_NETFILTER_XT_MATCH_STRING is not set
# CONFIG_NETFILTER_XT_MATCH_TCPMSS is not set
# CONFIG_NETFILTER_XT_MATCH_TIME is not set
# CONFIG_NETFILTER_XT_MATCH_U32 is not set
# CONFIG_IP_VS is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
# CONFIG_IP_NF_QUEUE is not set
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_ADDRTYPE=y
# CONFIG_IP_NF_MATCH_AH is not set
# CONFIG_IP_NF_MATCH_ECN is not set
# CONFIG_IP_NF_MATCH_TTL is not set
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_LOG=y
# CONFIG_IP_NF_TARGET_ULOG is not set
# CONFIG_NF_NAT is not set
# CONFIG_IP_NF_MANGLE is not set
# CONFIG_IP_NF_TARGET_TTL is not set
# CONFIG_IP_NF_RAW is not set
# CONFIG_IP_NF_ARPTABLES is not set

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_CONNTRACK_IPV6=y
# CONFIG_IP6_NF_QUEUE is not set
CONFIG_IP6_NF_IPTABLES=y
# CONFIG_IP6_NF_MATCH_AH is not set
CONFIG_IP6_NF_MATCH_EUI64=y
# CONFIG_IP6_NF_MATCH_FRAG is not set
# CONFIG_IP6_NF_MATCH_OPTS is not set
# CONFIG_IP6_NF_MATCH_HL is not set
# CONFIG_IP6_NF_MATCH_IPV6HEADER is not set
# CONFIG_IP6_NF_MATCH_MH is not set
# CONFIG_IP6_NF_MATCH_RT is not set
# CONFIG_IP6_NF_TARGET_HL is not set
CONFIG_IP6_NF_TARGET_LOG=y
CONFIG_IP6_NF_FILTER=y
CONFIG_IP6_NF_TARGET_REJECT=y
# CONFIG_IP6_NF_MANGLE is not set
# CONFIG_IP6_NF_RAW is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_CPQ_DA is not set
CONFIG_BLK_CPQ_CISS_DA=y
# CONFIG_CISS_SCSI_TAPE is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_BLK_DEV_HD is not set
CONFIG_MISC_DEVICES=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_HP_ILO=y
# CONFIG_ISL29003 is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_CB710_CORE is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=m
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
# CONFIG_CHR_DEV_SCH is not set
CONFIG_SCSI_MULTI_LUN=y
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
CONFIG_SCSI_SCAN_ASYNC=y
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=m
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
CONFIG_SCSI_BNX2_ISCSI=m
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_MPT2SAS is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
CONFIG_LIBFC=m
# CONFIG_LIBFCOE is not set
# CONFIG_FCOE is not set
# CONFIG_FCOE_FNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
CONFIG_SCSI_QLA_FC=m
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_SRP is not set
CONFIG_SCSI_DH=m
CONFIG_SCSI_DH_RDAC=m
# CONFIG_SCSI_DH_HP_SW is not set
# CONFIG_SCSI_DH_EMC is not set
# CONFIG_SCSI_DH_ALUA is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=m
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_ACPI=y
# CONFIG_SATA_PMP is not set
CONFIG_SATA_AHCI=m
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y
# CONFIG_SATA_SVW is not set
CONFIG_ATA_PIIX=m
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SX4 is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set
# CONFIG_SATA_INIC162X is not set
CONFIG_PATA_ACPI=m
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_SC1200 is not set
CONFIG_PATA_SERVERWORKS=m
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set
# CONFIG_PATA_SCH is not set
CONFIG_MD=y
# CONFIG_BLK_DEV_MD is not set
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_DEBUG is not set
# CONFIG_DM_CRYPT is not set
# CONFIG_DM_SNAPSHOT is not set
# CONFIG_DM_MIRROR is not set
# CONFIG_DM_ZERO is not set
CONFIG_DM_MULTIPATH=m
# CONFIG_DM_MULTIPATH_QL is not set
# CONFIG_DM_MULTIPATH_ST is not set
# CONFIG_DM_DELAY is not set
# CONFIG_DM_UEVENT is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
# CONFIG_FUSION_FC is not set
# CONFIG_FUSION_SAS is not set
CONFIG_FUSION_MAX_SGE=128
# CONFIG_FUSION_CTL is not set
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#

#
# You can enable one or both FireWire driver stacks.
#

#
# See the help texts for more information.
#
# CONFIG_FIREWIRE is not set
# CONFIG_IEEE1394 is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
# CONFIG_MACVLAN is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_VETH is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
CONFIG_PHYLIB=m

#
# MII PHY device drivers
#
# CONFIG_MARVELL_PHY is not set
# CONFIG_DAVICOM_PHY is not set
# CONFIG_QSEMI_PHY is not set
# CONFIG_LXT_PHY is not set
# CONFIG_CICADA_PHY is not set
# CONFIG_VITESSE_PHY is not set
# CONFIG_SMSC_PHY is not set
# CONFIG_BROADCOM_PHY is not set
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MDIO_BITBANG is not set
# CONFIG_NET_ETHERNET is not set
CONFIG_NETDEV_1000=y
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
# CONFIG_E1000E is not set
# CONFIG_IP1000 is not set
# CONFIG_IGB is not set
# CONFIG_IGBVF is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_TIGON3=m
CONFIG_BNX2=m
CONFIG_CNIC=m
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_JME is not set
# CONFIG_NETDEV_10000 is not set
# CONFIG_TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
# CONFIG_WLAN_80211 is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET is not set
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
CONFIG_NETCONSOLE=m
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=800
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=600
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
# CONFIG_DEVKMEM is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_IPMI_HANDLER=m
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=m
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_ALGOBIT=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_SIMTEC is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Graphics adapter I2C/DDC channel drivers
#
# CONFIG_I2C_VOODOO3 is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_STUB is not set

#
# Miscellaneous I2C Chip support
#
# CONFIG_DS1682 is not set
# CONFIG_SENSORS_PCF8574 is not set
# CONFIG_PCF8575 is not set
# CONFIG_SENSORS_PCA9539 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I2C_DEBUG_CHIP is not set
# CONFIG_SPI is not set

#
# PPS support
#
# CONFIG_PPS is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_MAX17040 is not set
CONFIG_HWMON=y
# CONFIG_HWMON_VID is not set
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7473 is not set
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATK0110 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHER is not set
# CONFIG_SENSORS_FSCPOS is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IBMAEM is not set
# CONFIG_SENSORS_IBMPEX is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_HWMON_DEBUG_CHIP is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_WATCHDOG=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_SC520_WDT is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
# CONFIG_IBMASR is not set
# CONFIG_WAFER_WDT is not set
# CONFIG_I6300ESB_WDT is not set
# CONFIG_ITCO_WDT is not set
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
CONFIG_HP_WATCHDOG=m
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83697HF_WDT is not set
# CONFIG_W83697UG_WDT is not set
# CONFIG_W83877F_WDT is not set
# CONFIG_W83977F_WDT is not set
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_AB3100_CORE is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
# CONFIG_AGP_INTEL is not set
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_VIA is not set
CONFIG_DRM=y
CONFIG_DRM_TTM=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
CONFIG_DRM_RADEON=y
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_SIS is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
# CONFIG_FB_SYS_FILLRECT is not set
# CONFIG_FB_SYS_COPYAREA is not set
# CONFIG_FB_SYS_IMAGEBLIT is not set
# CONFIG_FB_FOREIGN_ENDIAN is not set
# CONFIG_FB_SYS_FOPS is not set
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
# CONFIG_FB_MODE_HELPERS is not set
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Display device support
#
# CONFIG_DISPLAY_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=128
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
# CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY is not set
# CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
# CONFIG_SOUND is not set
CONFIG_HID_SUPPORT=y
CONFIG_HID=y
# CONFIG_HID_DEBUG is not set
# CONFIG_HIDRAW is not set

#
# USB Input Devices
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_APPLE=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
CONFIG_HID_EZKEY=y
CONFIG_HID_KYE=y
CONFIG_HID_GYRATION=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LOGITECH=y
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_NTRIG=y
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
# CONFIG_USB_DEVICEFS is not set
# CONFIG_USB_DEVICE_CLASS is not set
CONFIG_USB_DYNAMIC_MINORS=y
# CONFIG_USB_SUSPEND is not set
# CONFIG_USB_OTG is not set
# CONFIG_USB_MON is not set
# CONFIG_USB_WUSB is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=m
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
CONFIG_USB_UHCI_HCD=m
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
# CONFIG_USB_HWA_HCD is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_DATAFAB=m
CONFIG_USB_STORAGE_FREECOM=m
CONFIG_USB_STORAGE_ISD200=m
CONFIG_USB_STORAGE_USBAT=m
CONFIG_USB_STORAGE_SDDR09=m
CONFIG_USB_STORAGE_SDDR55=m
CONFIG_USB_STORAGE_JUMPSHOT=m
CONFIG_USB_STORAGE_ALAUDA=m
CONFIG_USB_STORAGE_ONETOUCH=m
CONFIG_USB_STORAGE_KARMA=m
CONFIG_USB_STORAGE_CYPRESS_ATACB=m
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_BERRY_CHARGE is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_VST is not set
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8581 is not set
# CONFIG_RTC_DRV_RX8025 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_V3020 is not set

#
# on-CPU RTC drivers
#
CONFIG_DMADEVICES=y

#
# DMA Devices
#
CONFIG_INTEL_IOATDMA=y
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
# CONFIG_ASYNC_TX_DMA is not set
# CONFIG_DMATEST is not set
CONFIG_DCA=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=m
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
# CONFIG_UIO_SMX is not set
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set

#
# TI VLYNQ
#
CONFIG_STAGING=y
# CONFIG_STAGING_EXCLUDE_BUILD is not set
# CONFIG_ET131X is not set
# CONFIG_SLICOSS is not set
# CONFIG_ME4000 is not set
# CONFIG_MEILHAUS is not set
# CONFIG_USB_IP_COMMON is not set
# CONFIG_ECHO is not set
# CONFIG_POCH is not set
# CONFIG_COMEDI is not set
# CONFIG_ASUS_OLED is not set
# CONFIG_ALTERA_PCIE_CHDMA is not set
# CONFIG_INPUT_MIMIO is not set
# CONFIG_TRANZPORT is not set
# CONFIG_EPL is not set

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_POHMELFS is not set
# CONFIG_B3DFG is not set
# CONFIG_IDE_PHISON is not set
# CONFIG_HECI is not set
CONFIG_DRM_RADEON_KMS=y
# CONFIG_VT6655 is not set
# CONFIG_USB_CPC is not set
# CONFIG_RDC_17F3101X is not set
# CONFIG_FB_UDL is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_ACPI_ASUS is not set
# CONFIG_ACPI_TOSHIBA is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
# CONFIG_ISCSI_IBFT_FIND is not set

#
# File systems
#
CONFIG_EXT2_FS=m
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
# CONFIG_EXT4_FS is not set
CONFIG_JBD=y
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
# CONFIG_XFS_DEBUG is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_QUOTA is not set
# CONFIG_AUTOFS_FS is not set
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set
CONFIG_GENERIC_ACL=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
# CONFIG_MSDOS_FS is not set
# CONFIG_VFAT_FS is not set
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=m
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_CRAMFS is not set
CONFIG_SQUASHFS=m
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_NILFS2_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
# CONFIG_NFS_V4 is not set
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
# CONFIG_NFSD_V4 is not set
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=y
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m
# CONFIG_RPCSEC_GSS_KRB5 is not set
# CONFIG_RPCSEC_GSS_SPKM3 is not set
# CONFIG_SMB_FS is not set
# CONFIG_CIFS is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_DEBUG_FS is not set
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
# CONFIG_DETECT_SOFTLOCKUP is not set
CONFIG_DETECT_HUNG_TASK=y
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_INFO is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
# CONFIG_FRAME_POINTER is not set
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_CPU_STALL_DETECTOR is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
# CONFIG_SYSCTL_SYSCALL_CHECK is not set
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_FTRACE_SYSCALLS=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_NX_TEST is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
CONFIG_SECURITY_FILE_CAPABILITIES=y
# CONFIG_IMA is not set
# CONFIG_CRYPTO is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_FIND_NEXT_BIT=y
CONFIG_GENERIC_FIND_LAST_BIT=y
# CONFIG_CRC_CCITT is not set
# CONFIG_CRC16 is not set
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
# CONFIG_CRC7 is not set
# CONFIG_LIBCRC32C is not set
CONFIG_ZLIB_INFLATE=m
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_NLATTR=y

--MP_/Dkc_9.owEn1_UJCXzpdneHl--
