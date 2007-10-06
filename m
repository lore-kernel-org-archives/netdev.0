From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: kernel BUG at net/core/dev.c:1383 skb_checksum_help: BUG_ON(offset
 > (int)skb->len)
Date: Sat, 6 Oct 2007 14:15:06 +0200
Message-ID: <20071006141506.785a6683@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g19.free.fr ([212.27.42.29]:40057 "EHLO smtp3-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755808AbXJFMRf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2007 08:17:35 -0400
Received: from smtp3-g19.free.fr (localhost.localdomain [127.0.0.1])
	by smtp3-g19.free.fr (Postfix) with ESMTP id 3398A17B562
	for <netdev@vger.kernel.org>; Sat,  6 Oct 2007 14:17:33 +0200 (CEST)
Received: from localhost.localdomain (bar06-2-82-224-157-131.fbx.proxad.net [82.224.157.131])
	by smtp3-g19.free.fr (Postfix) with ESMTP id 09C4917B57F
	for <netdev@vger.kernel.org>; Sat,  6 Oct 2007 14:17:31 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I just had my laptop crash with:

<2>kernel BUG at net/core/dev.c:1383!
<0>invalid opcode: 0000 [#1] PREEMPT=20
<0>last sysfs file: /devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
<4>Modules linked in: michael_mic arc4 ecb blkcipher ieee80211_crypt_tk=
ip radeon drm acpi_cpufreq kqemu usbhid hid lm90 hwmon ipv6 binfmt_misc=
 dm_mirror dm_mod snd_intel8x0m snd_intel8x0 snd_ac97_codec ac97_bus sn=
d_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_p=
cm_oss snd_mixer_oss snd_pcm snd_timer ac snd hci_usb irda ohci1394 sou=
ndcore bluetooth battery power_supply ieee1394 serio_raw video firewire=
_ohci rtc_cmos snd_page_alloc sg ipw2200 skge firewire_core output butt=
on rtc_core rtc_lib crc_ccitt iTCO_wdt asus_laptop led_class sr_mod cdr=
om pcspkr sdhci mmc_core i2c_i801 i2c_core ieee80211 crc_itu_t watchdog=
_core watchdog_dev ieee80211_crypt ehci_hcd ohci_hcd uhci_hcd
<4>
<4>Pid: 11914, comm: xmoto Not tainted (2.6.23-rc8-mm2-taskstats #27)
<4>EIP: 0060:[<c0336bb2>] EFLAGS: 00010283 CPU: 0
<4>EIP is at skb_checksum_help+0xe2/0xf0
<4>EAX: 0000040e EBX: c73c8cb0 ECX: 00000292 EDX: d0805800
<4>ESI: 00003822 EDI: c71b0000 EBP: c82da380 ESP: c0556c68
<4> DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
<0>Process xmoto (pid: 11914, ti=3Dc0556000 task=3Dc73a10e0 task.ti=3Dc=
843e000)
<0>last branch before last exception/interrupt
<0> from c0125808 (vprintk+0x1c8/0x370)
<0> to c0107520 (irq_entries_start+0x88/0x840)
<0>Stack: 00000020 c82da394 c73c8cb0 c033921d 00004108 c71b0380 c82da39=
4 c73c8cb0=20
<0>       d082241c c82da380 c035dcab c71b0414 00000800 00000001 0000000=
1 0000000e=20
<0>       c73c8cb0 c73c8cb0 d082241c c743bb80 6a649d53 00000000 c035d19=
9 00000000=20
<0>Call Trace:
<0> [<c033921d>] dev_queue_xmit+0x1bd/0x380
<0> [<c035dcab>] ip_output+0x17b/0x300
<0> [<c035d199>] ip_queue_xmit+0x1d9/0x410
<0> [<c036dfa1>] tcp_transmit_skb+0x3d1/0x790
<0> [<c036eec0>] tcp_retransmit_skb+0x150/0x630
<0> [<c036f49c>] tcp_xmit_retransmit_queue+0xfc/0x320
<0> [<c03694db>] tcp_ack+0x130b/0x1c40
<0> [<c036d00d>] tcp_rcv_established+0x46d/0x6c0
<0> [<c0372fb3>] tcp_v4_do_rcv+0xb3/0x3c0
<0> [<c0375835>] tcp_v4_rcv+0xa05/0xa70
<0> [<c0358303>] ip_local_deliver+0x153/0x300
<0> [<c0357ee2>] ip_rcv+0x2c2/0x590
<0> [<c033619a>] netif_receive_skb+0x27a/0x500
<0> [<c03388a9>] process_backlog+0x59/0xd0
<0> [<c033848d>] net_rx_action+0x9d/0x1d0
<0> [<c012a528>] __do_softirq+0x48/0xb0
<0> [<c0109622>] do_softirq+0x82/0xe0
<0> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
<0>Code: 66 83 38 01 0f 84 72 ff ff ff 31 c9 31 d2 89 d8 c7 04 24 20 00=
 00 00 e8 ad 98 ff ff 85 c0 0f 84 58 ff ff ff eb d6 0f 0b 90 eb fd <0f>=
 0b eb fe 0f 0b eb fe 8d b6 00 00 00 00 83 ec 0c 89 5c 24 04=20
<0>EIP: [<c0336bb2>] skb_checksum_help+0xe2/0xf0 SS:ESP 0068:c0556c68

The currently used NIC is an Intel ipw2200 integrated wifi controller.
I don't have any iptables/tc rules, just a quite standard Fedora 7.
It's the first time I see this, so even if I can test patches, I
will not be able to say if the bug is fixed or not. I got the dmesg
dump from a kdump /proc/vmcore memory dump, so with some assistance I
can dig some more into it.

Here are some hopefully interesting values:

#0  skb_checksum_help (skb=3D0xc73c8cb0) at net/core/dev.c:1383
1383            BUG_ON(offset > (int)skb->len);
(gdb) p offset
$1 =3D 14370
(gdb) p skb
$2 =3D (struct sk_buff *) 0xc73c8cb0
(gdb) p *skb
$3 =3D {next =3D 0x0, prev =3D 0x0, sk =3D 0xc743bb80, tstamp =3D {tv64=
 =3D 0}, dev =3D 0xc71b0000, dst =3D 0xc99ca900, sp =3D 0x0,=20
  cb =3D '\0' <repeats 24 times>, "7=EF=BF=BDyp\207=EF=BF=BDyp\030?\\\0=
00\020\004\000\000\000\000\000\000\000\000\000", len =3D 658,=20
  data_len =3D 0, mac_len =3D 0, hdr_len =3D 0, {csum =3D 1063984, {csu=
m_start =3D 15408, csum_offset =3D 16}}, priority =3D 2,=20
  local_df =3D 0 '\0', cloned =3D 0 '\0', ip_summed =3D 3 '\003', nohdr=
 =3D 0 '\0', nfctinfo =3D 0 '\0', pkt_type =3D 0 '\0',=20
  fclone =3D 2 '\002', ipvs_property =3D 0 '\0', nf_trace =3D 0 '\0', p=
rotocol =3D 8, destructor =3D 0xc032e4e0 <sock_wfree>,=20
  nfct =3D 0x0, nfct_reasm =3D 0x0, nf_bridge =3D 0x0, iif =3D 0, queue=
_mapping =3D 0, tc_index =3D 0, tc_verd =3D 0, secmark =3D 0,=20
  mark =3D 0, transport_header =3D 0xd0805c30 "\032=EF=BF=BD=EF=BF=BD\2=
30py=EF=BF=BD7y=EF=BF=BD=EF=BF=BD=EF=BF=BD\200\020\001=EF=BF=BD{)", net=
work_header =3D 0xd0805c1c "E\b\002\204`=EF=BF=BD@",=20
  mac_header =3D 0xfffe3800 <Address 0xfffe3800 out of bounds>, tail =3D=
 0xd0805ea0 "Q=EF=BF=BD}D\207E=EF=BF=BD2\035=EF=BF=BDH\002\001\001@D",=20
  end =3D 0xd0805ec0 "\001", head =3D 0xd0805800 "", data =3D 0xd0805c0=
e "", truesize =3D 1056, users =3D {counter =3D 1}}
(gdb) p skb->len
$4 =3D 658


<5>Linux version 2.6.23-rc8-mm2-taskstats (g@localhost.localdomain) (gc=
c version 4.1.2 20070925 (Red Hat 4.1.2-27)) #27 PREEMPT Tue Oct 2 23:0=
9:59 CEST 2007
<6>BIOS-provided physical RAM map:
<4> BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
<4> BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
<4> BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
<4> BIOS-e820: 0000000000100000 - 000000007ffa0000 (usable)
<4> BIOS-e820: 000000007ffa0000 - 000000007ffb0000 (ACPI data)
<4> BIOS-e820: 000000007ffb0000 - 000000007fff0000 (ACPI NVS)
<4> BIOS-e820: 000000007fff0000 - 0000000080000000 (reserved)
<4> BIOS-e820: 00000000ffb80000 - 0000000100000000 (reserved)
<5>1151MB HIGHMEM available.
<5>896MB LOWMEM available.
<6>found SMP MP-table at 000ff780
<6>Reserving 64MB of memory at 16MB for crashkernel (System RAM: 2041MB=
)
<7>Entering add_active_range(0, 0, 524192) 0 entries of 256 used
<7>sizeof(struct page) =3D 32
<4>Zone PFN ranges:
<4>  DMA             0 ->     4096
<4>  Normal       4096 ->   229376
<4>  HighMem    229376 ->   524192
<4>Movable zone start PFN for each node
<4>early_node_map[1] active PFN ranges
<4>    0:        0 ->   524192
<7>On node 0 totalpages: 524192
<7>Node 0 memmap at 0xc5000000 size 16777216 first pfn 0xc5000000
<7>  DMA zone: 32 pages used for memmap
<7>  DMA zone: 0 pages reserved
<7>  DMA zone: 4064 pages, LIFO batch:0
<7>  Normal zone: 1760 pages used for memmap
<7>  Normal zone: 223520 pages, LIFO batch:31
<7>  HighMem zone: 2303 pages used for memmap
<7>  HighMem zone: 292513 pages, LIFO batch:31
<7>  Movable zone: 0 pages used for memmap
<6>DMI 2.3 present.
<4>ACPI: RSDP 000FB5E0, 0014 (r0 ACPIAM)
<4>ACPI: RSDT 7FFA0000, 003C (r1 A M I  OEMRSDT  10000512 MSFT       97=
)
<4>ACPI: FACP 7FFA0200, 0081 (r1 A M I  OEMFACP  10000512 MSFT       97=
)
<4>ACPI: DSDT 7FFA0400, 5630 (r1  A0348 A0348000        0 INTL  2002026=
)
<4>ACPI: FACS 7FFB0000, 0040
<4>ACPI: APIC 7FFA0390, 0070 (r1 A M I  OEMAPIC  10000512 MSFT       97=
)
<4>ACPI: OEMB 7FFB0040, 0046 (r1 A M I  AMI_OEM  10000512 MSFT       97=
)
<4>ACPI: MCFG 7FFA5A30, 003C (r1 A M I  OEMMCFG  10000512 MSFT       97=
)
<4>ACPI: SSDT 7FFA5A70, 0137 (r1    AMI   CPU1CS        1 INTL 20030522=
)
<4>ACPI: SSDT 7FFA5BB0, 02F0 (r1    AMI   CPU1PM        1 INTL 20030522=
)
<6>ACPI: PM-Timer IO Port: 0x808
<7>ACPI: Local APIC address 0xfee00000
<6>ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
<4>Processor #0 6:13 APIC version 20
<6>ACPI: LAPIC (acpi_id[0x02] lapic_id[0x81] disabled)
<6>ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
<4>IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
<6>ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
<6>ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
<6>ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
<6>ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
<7>ACPI: IRQ0 used by override.
<7>ACPI: IRQ2 used by override.
<7>ACPI: IRQ9 used by override.
<4>Enabling APIC mode:  Flat.  Using 1 I/O APICs
<6>Using ACPI (MADT) for SMP configuration information
<4>Allocating PCI resources starting at 88000000 (gap: 80000000:7fb8000=
0)
<4>swsusp: Registered nosave memory region: 000000000009f000 - 00000000=
000a0000
<4>swsusp: Registered nosave memory region: 00000000000a0000 - 00000000=
000e0000
<4>swsusp: Registered nosave memory region: 00000000000e0000 - 00000000=
00100000
<4>Built 1 zonelists in Zone order, mobility grouping on.  Total pages:=
 520097
<5>Kernel command line: ro root=3DLABEL=3D/ crashkernel=3D64M@16M
<7>mapped APIC to ffffb000 (fee00000)
<7>mapped IOAPIC to ffffa000 (fec00000)
<6>Enabling fast FPU save and restore... done.
<6>Enabling unmasked SIMD FPU exception support... done.
<6>Initializing CPU#0
<4>CPU 0 irqstacks, hard=3Dc0557000 soft=3Dc0556000
<4>PID hash table entries: 4096 (order: 12, 16384 bytes)
<4>Detected 1995.145 MHz processor.
<4>Console: colour VGA+ 80x25
<6>console [tty0] enabled
<6>Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
<6>Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
<6>Memory: 2005432k/2096768k available (2741k kernel code, 90216k reser=
ved, 1409k data, 268k init, 1179264k highmem)
<4>virtual kernel memory layout:
<4>    fixmap  : 0xfffa7000 - 0xfffff000   ( 352 kB)
<4>    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
<4>    vmalloc : 0xf8800000 - 0xff7fe000   ( 111 MB)
<4>    lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
<4>      .init : 0xc050f000 - 0xc0552000   ( 268 kB)
<4>      .data : 0xc03ad7f8 - 0xc050dd44   (1409 kB)
<4>      .text : 0xc0100000 - 0xc03ad7f8   (2741 kB)
<4>Checking if this processor honours the WP bit even in supervisor mod=
e... Ok.
<6>SLUB: Genslabs=3D11, HWalign=3D64, Order=3D0-3, MinObjects=3D16, CPU=
s=3D1, Nodes=3D1
<4>Calibrating delay using timer specific routine.. 3991.61 BogoMIPS (l=
pj=3D1995809)
<6>kswapd reclaim order set to 3
<6>Security Framework initialized
<6>SELinux:  Initializing.
<7>SELinux:  Starting in permissive mode
<6>selinux_register_security:  Registering secondary module capability
<6>Capability LSM initialized as secondary
<4>Mount-cache hash table entries: 512
<7>CPU: After generic identify, caps: afe9fbff 00000000 00000000 000000=
00 00000180 00000000 00000000 00000000
<6>CPU: L1 I cache: 32K, L1 D cache: 32K
<6>CPU: L2 cache: 2048K
<7>CPU: After all inits, caps: afe9fbff 00000000 00000000 00002040 0000=
0180 00000000 00000000 00000000
<6>Intel machine check architecture supported.
<6>Intel machine check reporting enabled on CPU#0.
<4>Compat vDSO mapped to ffffe000.
<4>CPU: Intel(R) Pentium(R) M processor 2.00GHz stepping 08
<6>Checking 'hlt' instruction... OK.
<6>ACPI: Core revision 20070126
<4>ENABLING IO-APIC IRQs
<6>..TIMER: vector=3D0x31 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1
<6>net_namespace: 60 bytes
<6>Booting paravirtualized kernel on bare hardware
<6>NET: Registered protocol family 16
<6>ACPI: bus type pci registered
<6>PCI: PCI BIOS revision 2.10 entry at 0xf0031, last bus=3D4
<6>PCI: Using configuration type 1
<4>Setting up standard PCI resources
<7>ACPI: EC: Look up EC in DSDT
<6>ACPI: Interpreter enabled
<6>ACPI: (supports S0 S1 S3 S4 S5)
<6>ACPI: Using IOAPIC for interrupt routing
<5>PCI: MCFG configuration 0: base 3758096384 segment 0 buses 0 - 255
<5>PCI: MCFG area at e0000000 reserved in ACPI motherboard resources
<6>PCI: Using MMCONFIG
<6>ACPI: EC: GPE =3D 0x1c, I/O: command/status =3D 0x66, data =3D 0x62
<6>ACPI: PCI Root Bridge [PCI0] (0000:00)
<6>PCI: Enabled ICH6/i801 SMBus device
<4>PCI quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
<4>PCI quirk: region 0480-04bf claimed by ICH6 GPIO
<6>PCI: Transparent bridge - 0000:00:1e.0
<7>ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
<7>ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
<7>ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P3._PRT]
<6>ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 *10 11 12 14 15)
<6>ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 *6 7 10 11 12 14 15)
<6>ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 10 11 12 14 15)
<6>ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *7 10 11 12 14 15)
<6>ACPI: PCI Interrupt Link [LNKE] (IRQs 3 *4 5 6 7 10 11 12 14 15)
<6>ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, =
disabled.
<6>ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, =
disabled.
<6>ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 10 *11 12 14 15)
<6>Linux Plug and Play Support v0.97 (c) Adam Belay
<6>pnp: PnP ACPI init
<6>ACPI: bus type pnp registered
<6>pnp: PnP ACPI: found 17 devices
<6>ACPI: ACPI bus type pnp unregistered
<5>SCSI subsystem initialized
<7>libata version 2.21 loaded.
<6>usbcore: registered new interface driver usbfs
<6>usbcore: registered new interface driver hub
<6>usbcore: registered new device driver usb
<6>PCI: Using ACPI for IRQ routing
<6>PCI: If a device doesn't work, try "pci=3Drouteirq".  If it helps, p=
ost a report
<4>ACPI: RTC can wake from S4
<6>Time: tsc clocksource has been installed.
<6>pnp: 00:01: iomem range 0xfed13000-0xfed19fff has been reserved
<6>pnp: 00:09: ioport range 0x6c0-0x6cf has been reserved
<6>pnp: 00:0a: iomem range 0xfed1c000-0xfed1ffff has been reserved
<6>pnp: 00:0a: iomem range 0xfed20000-0xfed8ffff has been reserved
<6>pnp: 00:0c: iomem range 0xffc00000-0xfff7ffff could not be reserved
<6>pnp: 00:0d: iomem range 0xfec00000-0xfec00fff has been reserved
<6>pnp: 00:0d: iomem range 0xfee00000-0xfee00fff has been reserved
<6>pnp: 00:0e: iomem range 0xe0000000-0xefffffff has been reserved
<6>pnp: 00:0f: iomem range 0xe0000000-0xefffffff has been reserved
<6>pnp: 00:10: iomem range 0x0-0x9ffff could not be reserved
<6>pnp: 00:10: iomem range 0xc0000-0xcffff could not be reserved
<6>pnp: 00:10: iomem range 0xe0000-0xfffff could not be reserved
<6>pnp: 00:10: iomem range 0x100000-0x7fffffff could not be reserved
<6>PCI: Bridge: 0000:00:01.0
<6>  IO window: b000-bfff
<6>  MEM window: fbe00000-fbefffff
<6>  PREFETCH window: f0000000-faffffff
<6>PCI: Bridge: 0000:00:1c.0
<6>  IO window: c000-cfff
<6>  MEM window: disabled.
<6>  PREFETCH window: disabled.
<4>PCI: Bus 4, cardbus bridge: 0000:03:01.0
<4>  IO window: 0000d000-0000d0ff
<4>  IO window: 0000d400-0000d4ff
<4>  PREFETCH window: 88000000-8bffffff
<4>  MEM window: 90000000-93ffffff
<6>PCI: Bridge: 0000:00:1e.0
<6>  IO window: d000-efff
<6>  MEM window: fbf00000-fbffffff
<6>  PREFETCH window: 88000000-8dffffff
<6>ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 16 (level, low) -> IRQ 16
<7>PCI: Setting latency timer of device 0000:00:01.0 to 64
<6>ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 16 (level, low) -> IRQ 16
<7>PCI: Setting latency timer of device 0000:00:1c.0 to 64
<7>PCI: Setting latency timer of device 0000:00:1e.0 to 64
<6>ACPI: PCI Interrupt 0000:03:01.0[A] -> GSI 17 (level, low) -> IRQ 17
<6>NET: Registered protocol family 2
<6>IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
<6>TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
<6>TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
<6>TCP: Hash tables configured (established 131072 bind 65536)
<6>TCP reno registered
<6>checking if image is initramfs... it is
<6>Freeing initrd memory: 2609k freed
<6>Machine check exception polling timer started.
<6>apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)
<5>apm: overridden by ACPI.
<6>audit: initializing netlink socket (disabled)
<5>audit(1191665028.415:1): initialized
<4>highmem bounce pool size: 64 pages
<4>Total HugeTLB memory allocated, 0
<5>VFS: Disk quotas dquot_6.5.1
<4>Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
<7>SELinux:  Registering netfilter hooks
<6>Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
<6>io scheduler noop registered
<6>io scheduler cfq registered (default)
<7>Boot video device is 0000:01:00.0
<7>PCI: Setting latency timer of device 0000:00:01.0 to 64
<4>assign_interrupt_mode Found MSI capability
<7>Allocate Port Service[0000:00:01.0:pcie00]
<7>Allocate Port Service[0000:00:01.0:pcie03]
<7>PCI: Setting latency timer of device 0000:00:1c.0 to 64
<4>assign_interrupt_mode Found MSI capability
<7>Allocate Port Service[0000:00:1c.0:pcie00]
<7>Allocate Port Service[0000:00:1c.0:pcie02]
<7>Allocate Port Service[0000:00:1c.0:pcie03]
<6>ACPI: CPU0 (power states: C1[C1] C2[C2] C3[C3])
<6>ACPI: Processor [CPU1] (supports 8 throttling states)
<6>ACPI: Thermal Zone [TZ00] (40 C)
<6>Real Time Clock Driver v1.12ac
<6>Non-volatile memory driver v1.2
<6>Linux agpgart interface v0.102
<6>agpgart: suspend/resume problematic: resume with 3D/DRI active may l=
ockup X.Org
<4>on some chipset/BIOS combos (see DEBUG_AGP_PM in intel-agp.c)
<6>Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing ena=
bled
<4>Marking TSC unstable due to: possible TSC halt in C2.
<6>Time: acpi_pm clocksource has been installed.
<6>Switched to high resolution mode on CPU 0
<6>serial8250: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
<6>ACPI: PCI Interrupt 0000:00:1e.3[B] -> GSI 20 (level, low) -> IRQ 18
<6>ACPI: PCI interrupt for device 0000:00:1e.3 disabled
<4>RAMDISK driver initialized: 16 RAM disks of 16384K size 1024 blocksi=
ze
<6>Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
<6>ide: Assuming 33MHz system bus speed for PIO modes; override with id=
ebus=3Dxx
<7>ata_piix 0000:00:1f.1: version 2.12
<6>ACPI: PCI Interrupt 0000:00:1f.1[A] -> GSI 18 (level, low) -> IRQ 19
<7>PCI: Setting latency timer of device 0000:00:1f.1 to 64
<6>scsi0 : ata_piix
<6>scsi1 : ata_piix
<6>ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
<6>ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
<6>ata1.00: ATA-6: HTS541010G9AT00, MBZOA60A, max UDMA/100
<6>ata1.00: 195371568 sectors, multi 16: LBA48=20
<6>ata1.01: ATAPI: MATSHITADVD-RAM UJ-832S, 1.00, max UDMA/33
<6>ata1.00: configured for UDMA/100
<6>ata1.01: configured for UDMA/33
<7>ata2: port disabled. ignoring.
<5>scsi 0:0:0:0: Direct-Access     ATA      HTS541010G9AT00  MBZO PQ: 0=
 ANSI: 5
<5>sd 0:0:0:0: [sda] 195371568 512-byte hardware sectors (100030 MB)
<5>sd 0:0:0:0: [sda] Write Protect is off
<7>sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
<5>sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't=
 support DPO or FUA
<5>sd 0:0:0:0: [sda] 195371568 512-byte hardware sectors (100030 MB)
<5>sd 0:0:0:0: [sda] Write Protect is off
<7>sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
<5>sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't=
 support DPO or FUA
<6> sda: sda1 sda2
<4>Clocksource tsc unstable (delta =3D -447125710 ns)
<5>sd 0:0:0:0: [sda] Attached SCSI disk
<5>scsi 0:0:1:0: CD-ROM            MATSHITA DVD-RAM UJ-832S  1.00 PQ: 0=
 ANSI: 5
<6>Yenta: CardBus bridge found at 0000:03:01.0 [1043:1967]
<6>Yenta: ISA IRQ mask 0x04b8, PCI irq 17
<6>Socket status: 30000006
<6>Yenta: Raising subordinate bus# of parent bus (#03) from #04 to #07
<6>pcmcia: parent PCI bridge I/O window: 0xd000 - 0xefff
<6>cs: IO port probe 0xd000-0xefff: clean.
<6>pcmcia: parent PCI bridge Memory window: 0xfbf00000 - 0xfbffffff
<6>pcmcia: parent PCI bridge Memory window: 0x88000000 - 0x8dffffff
<6>PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,=
12
<6>i8042.c: Detected active multiplexing controller, rev 1.1.
<6>serio: i8042 KBD port at 0x60,0x64 irq 1
<6>serio: i8042 AUX0 port at 0x60,0x64 irq 12
<6>serio: i8042 AUX1 port at 0x60,0x64 irq 12
<6>serio: i8042 AUX2 port at 0x60,0x64 irq 12
<6>serio: i8042 AUX3 port at 0x60,0x64 irq 12
<6>mice: PS/2 mouse device common for all mice
<6>TCP cubic registered
<6>Initializing XFRM netlink socket
<6>NET: Registered protocol family 1
<6>NET: Registered protocol family 17
<4>Using IPI Shortcut mode
<4>registered taskstats version 1
<6>Freeing unused kernel memory: 268k freed
<6>USB Universal Host Controller Interface driver v3.0
<6>ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 23 (level, low) -> IRQ 20
<7>PCI: Setting latency timer of device 0000:00:1d.0 to 64
<6>uhci_hcd 0000:00:1d.0: UHCI Host Controller
<6>uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
<6>uhci_hcd 0000:00:1d.0: irq 20, io base 0x00009800
<6>usb usb1: configuration #1 chosen from 1 choice
<6>hub 1-0:1.0: USB hub found
<6>hub 1-0:1.0: 2 ports detected
<6>usb usb1: new device found, idVendor=3D0000, idProduct=3D0000
<6>usb usb1: new device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
<6>usb usb1: Product: UHCI Host Controller
<6>usb usb1: Manufacturer: Linux 2.6.23-rc8-mm2-taskstats uhci_hcd
<6>usb usb1: SerialNumber: 0000:00:1d.0
<6>ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 21
<7>PCI: Setting latency timer of device 0000:00:1d.1 to 64
<6>uhci_hcd 0000:00:1d.1: UHCI Host Controller
<6>uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 2
<6>uhci_hcd 0000:00:1d.1: irq 21, io base 0x0000a000
<6>usb usb2: configuration #1 chosen from 1 choice
<6>hub 2-0:1.0: USB hub found
<6>hub 2-0:1.0: 2 ports detected
<6>usb usb2: new device found, idVendor=3D0000, idProduct=3D0000
<6>usb usb2: new device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
<6>usb usb2: Product: UHCI Host Controller
<6>usb usb2: Manufacturer: Linux 2.6.23-rc8-mm2-taskstats uhci_hcd
<6>usb usb2: SerialNumber: 0000:00:1d.1
<6>ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 19
<7>PCI: Setting latency timer of device 0000:00:1d.2 to 64
<6>uhci_hcd 0000:00:1d.2: UHCI Host Controller
<6>uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 3
<6>uhci_hcd 0000:00:1d.2: irq 19, io base 0x0000a400
<6>usb usb3: configuration #1 chosen from 1 choice
<6>hub 3-0:1.0: USB hub found
<6>hub 3-0:1.0: 2 ports detected
<6>usb usb3: new device found, idVendor=3D0000, idProduct=3D0000
<6>usb usb3: new device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
<6>usb usb3: Product: UHCI Host Controller
<6>usb usb3: Manufacturer: Linux 2.6.23-rc8-mm2-taskstats uhci_hcd
<6>usb usb3: SerialNumber: 0000:00:1d.2
<6>ACPI: PCI Interrupt 0000:00:1d.3[D] -> GSI 16 (level, low) -> IRQ 16
<7>PCI: Setting latency timer of device 0000:00:1d.3 to 64
<6>uhci_hcd 0000:00:1d.3: UHCI Host Controller
<6>uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 4
<6>uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000a800
<6>usb usb4: configuration #1 chosen from 1 choice
<6>hub 4-0:1.0: USB hub found
<6>hub 4-0:1.0: 2 ports detected
<6>usb usb4: new device found, idVendor=3D0000, idProduct=3D0000
<6>usb usb4: new device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
<6>usb usb4: Product: UHCI Host Controller
<6>usb usb4: Manufacturer: Linux 2.6.23-rc8-mm2-taskstats uhci_hcd
<6>usb usb4: SerialNumber: 0000:00:1d.3
<7>ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Drive=
r
<6>ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 23 (level, low) -> IRQ 20
<7>PCI: Setting latency timer of device 0000:00:1d.7 to 64
<6>ehci_hcd 0000:00:1d.7: EHCI Host Controller
<6>ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 5
<6>ehci_hcd 0000:00:1d.7: debug port 1
<7>PCI: cache line size of 32 is not supported by device 0000:00:1d.7
<6>ehci_hcd 0000:00:1d.7: irq 20, io mem 0xfbdffc00
<6>ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 200=
4
<6>usb usb5: configuration #1 chosen from 1 choice
<6>hub 5-0:1.0: USB hub found
<6>hub 5-0:1.0: 8 ports detected
<6>Synaptics Touchpad, model: 1, fw: 5.9, id: 0x256eb1, caps: 0x804713/=
0x0
<6>input: SynPS/2 Synaptics TouchPad as /class/input/input0
<6>input: AT Translated Set 2 keyboard as /class/input/input1
<6>usb usb5: new device found, idVendor=3D0000, idProduct=3D0000
<6>usb usb5: new device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
<6>usb usb5: Product: EHCI Host Controller
<6>usb usb5: Manufacturer: Linux 2.6.23-rc8-mm2-taskstats ehci_hcd
<6>usb usb5: SerialNumber: 0000:00:1d.7
<6>kjournald starting.  Commit interval 5 seconds
<6>EXT3-fs: mounted filesystem with ordered data mode.
<6>SELinux:  Disabled at runtime.
<7>SELinux:  Unregistering netfilter hooks
<5>audit(1191665031.243:2): selinux=3D0 auid=3D4294967295
<7>ieee80211_crypt: registered algorithm 'NULL'
<6>cs: IO port probe 0x100-0x3af: clean.
<6>cs: IO port probe 0x3e0-0x4ff: excluding 0x4d0-0x4d7
<6>cs: IO port probe 0x820-0x8ff: clean.
<6>cs: IO port probe 0xc00-0xcf7: clean.
<6>cs: IO port probe 0xa00-0xaff: clean.
<6>Uniform watchdog device driver v0.01 loaded
<6>ieee80211: 802.11 data/management/control stack, git-1.1.13
<6>ieee80211: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux=
=2Eintel.com>
<6>ACPI: PCI Interrupt 0000:00:1f.3[B] -> GSI 19 (level, low) -> IRQ 21
<6>sdhci: Secure Digital Host Controller Interface driver
<6>sdhci: Copyright(c) Pierre Ossman
<6>sdhci: SDHCI controller found at 0000:03:01.2 [1180:0822] (rev 17)
<6>ACPI: PCI Interrupt 0000:03:01.2[C] -> GSI 18 (level, low) -> IRQ 19
<6>mmc0: SDHCI at 0xfbffb400 irq 19 DMA
<6>input: PC Speaker as /class/input/input2
<4>sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tra=
y
<6>Uniform CD-ROM driver Revision: 3.20
<7>sr 0:0:1:0: Attached scsi CD-ROM sr0
<5>asus-laptop: Asus Laptop Support version 0.42
<4>asus-laptop: Error calling BSTS
<5>asus-laptop:   V6VA model detected
<6>Registered led device: asus:touchpad
<6>iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10 (17-Aug-2007)
<6>iTCO_wdt: Found a ICH6-M TCO device (Version=3D2, TCOBASE=3D0x0860)
<6>iTCO_wdt: initialized. heartbeat=3D30 sec (nowayout=3D0)
<6>input: Power Button (FF) as /class/input/input3
<6>ACPI: Power Button (FF) [PWRF]
<6>input: Sleep Button (CM) as /class/input/input4
<6>ACPI: Sleep Button (CM) [SLPB]
<6>input: Lid Switch as /class/input/input5
<6>ACPI: Lid Switch [LID]
<6>input: Power Button (CM) as /class/input/input6
<6>ACPI: Power Button (CM) [PWRB]
<6>ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 18 (level, low) -> IRQ 19
<6>skge 1.11 addr 0xfbffc000 irq 19 chip Yukon-Lite rev 9
<6>skge eth0: addr 00:15:f2:46:d3:3b
<6>ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kmprq
<6>ipw2200: Copyright(c) 2003-2006 Intel Corporation
<6>ACPI: PCI Interrupt 0000:03:02.0[A] -> GSI 17 (level, low) -> IRQ 17
<6>ipw2200: Detected Intel PRO/Wireless 2200BG Network Connection
<6>usb 4-1: new full speed USB device using uhci_hcd and address 2
<3>intel_rng: FWH not detected
<6>usb 4-1: configuration #1 chosen from 1 choice
<6>usb 4-1: new device found, idVendor=3D044e, idProduct=3D3001
<6>usb 4-1: new device strings: Mfr=3D1, Product=3D2, SerialNumber=3D0
<6>usb 4-1: Product: UGPZ
<6>usb 4-1: Manufacturer: ALPS
<5>sd 0:0:0:0: Attached scsi generic sg0 type 0
<5>sr 0:0:1:0: Attached scsi generic sg1 type 5
<4>Duplicate file names "rtc" detected. [<c01085c4>] dump_trace+0x1e4/0=
x200
<4> [<c01085f8>] show_trace_log_lvl+0x18/0x30
<4> [<c010911f>] show_trace+0xf/0x20
<4> [<c0109261>] dump_stack+0x11/0x20
<4> [<c01caf23>] proc_register+0x123/0x1a0
<4> [<c01cafef>] create_proc_entry+0x4f/0xb0
<4> [<f888c11e>] rtc_proc_add_device+0x1e/0x40 [rtc_core]
<4> [<f888b259>] rtc_device_register+0x1c9/0x200 [rtc_core]
<4> [<f88c66d9>] cmos_do_probe+0xa9/0x230 [rtc_cmos]
<4> [<f88c687f>] cmos_pnp_probe+0x1f/0x50 [rtc_cmos]
<4> [<c0289a8f>] pnp_device_probe+0x4f/0xb0
<4> [<c02bcfdd>] driver_probe_device+0x8d/0x190
<4> [<c02bd216>] __driver_attach+0x76/0x80
<4> [<c02bc3e8>] bus_for_each_dev+0x38/0x60
<4> [<c02bce56>] driver_attach+0x16/0x20
<4> [<c02bc7cb>] bus_add_driver+0x8b/0x1e0
<4> [<c02bd3bf>] driver_register+0x3f/0x70
<4> [<c0289834>] pnp_register_driver+0x14/0x20
<4> [<f88b500a>] cmos_init+0xa/0xb [rtc_cmos]
<4> [<c0148725>] sys_init_module+0x175/0x16d0
<4> [<c0107296>] sysenter_past_esp+0x6b/0xa1
<4> [<b7ff9410>] 0xb7ff9410
<4> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
<6>rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
<4>rtc_cmos: probe of 00:03 failed with error -16
<6>ipw2200: Detected geography ZZM (11 802.11bg channels, 0 802.11a cha=
nnels)
<6>ACPI: PCI Interrupt 0000:03:01.1[B] -> GSI 16 (level, low) -> IRQ 16
<5>firewire_ohci: Added fw-ohci device 0000:03:01.1, OHCI version 1.0
<6>input: Video Bus as /class/input/input7
<6>ACPI: Video Device [VGA] (multi-head: yes  rom: no  post: no)
<6>ACPI: Battery Slot [BAT0] (battery present)
<6>Bluetooth: Core ver 2.11
<6>NET: Registered protocol family 31
<6>Bluetooth: HCI device and connection manager initialized
<6>Bluetooth: HCI socket layer initialized
<6>NET: Registered protocol family 23
<5>firewire_core: created new fw device fw0 (0 config rom retries, S400=
)
<6>Bluetooth: HCI USB driver ver 2.9
<6>usbcore: registered new interface driver hci_usb
<6>ACPI: AC Adapter [AC0] (off-line)
<6>ACPI: PCI Interrupt 0000:00:1e.2[A] -> GSI 17 (level, low) -> IRQ 17
<7>PCI: Setting latency timer of device 0000:00:1e.2 to 64
<6>intel8x0_measure_ac97_clock: measured 50443 usecs
<6>intel8x0: clocking to 48000
<6>ACPI: PCI Interrupt 0000:00:1e.3[B] -> GSI 20 (level, low) -> IRQ 18
<7>PCI: Setting latency timer of device 0000:00:1e.3 to 64
<4>ALSA sound/pci/ac97/ac97_codec.c:2153: MC'97 1 converters and GPIO n=
ot ready (0xff00)
<6>device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-deve=
l@redhat.com
<6>EXT3 FS on sda1, internal journal
<6>Adding 3478064k swap on /dev/sda2.  Priority:-1 extents:1 across:347=
8064k
<6>NET: Registered protocol family 10
<6>lo: Disabled Privacy Extensions
<6>usb 2-2: new low speed USB device using uhci_hcd and address 2
<6>usb 2-2: configuration #1 chosen from 1 choice
<6>usb 2-2: new device found, idVendor=3D046d, idProduct=3Dc016
<6>usb 2-2: new device strings: Mfr=3D1, Product=3D2, SerialNumber=3D0
<6>usb 2-2: Product: Optical USB Mouse
<6>usb 2-2: Manufacturer: Logitech
<6>usbcore: registered new interface driver hiddev
<6>input: Logitech Optical USB Mouse as /class/input/input8
<6>input,hidraw0: USB HID v1.10 Mouse [Logitech Optical USB Mouse] on u=
sb-0000:00:1d.1-2
<6>usbcore: registered new interface driver usbhid
<6>drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
<4>QEMU Accelerator Module version 1.3.0, Copyright (c) 2005-2007 Fabri=
ce Bellard
<4>KQEMU installed, max_locked_mem=3D1004520kB.
<6>skge eth0: enabling interface
<6>ADDRCONF(NETDEV_UP): eth0: link is not ready
<6>ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 16 (level, low) -> IRQ 16
<6>[drm] Initialized drm 1.1.0 20060810
<6>[drm] Initialized radeon 1.28.0 20060524 on minor 0
<6>[drm] Setting GART location based on new memory map
<6>[drm] Loading R300 Microcode
<6>[drm] writeback test succeeded in 1 usecs
<6>ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
<7>ieee80211_crypt: registered algorithm 'TKIP'
<7>eth1: no IPv6 routers present
<4>printk: 4 messages suppressed.
<0>------------[ cut here ]------------
<2>kernel BUG at net/core/dev.c:1383!
<0>invalid opcode: 0000 [#1] PREEMPT=20
<0>last sysfs file: /devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
<4>Modules linked in: michael_mic arc4 ecb blkcipher ieee80211_crypt_tk=
ip radeon drm acpi_cpufreq kqemu usbhid hid lm90 hwmon ipv6 binfmt_misc=
 dm_mirror dm_mod snd_intel8x0m snd_intel8x0 snd_ac97_codec ac97_bus sn=
d_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_p=
cm_oss snd_mixer_oss snd_pcm snd_timer ac snd hci_usb irda ohci1394 sou=
ndcore bluetooth battery power_supply ieee1394 serio_raw video firewire=
_ohci rtc_cmos snd_page_alloc sg ipw2200 skge firewire_core output butt=
on rtc_core rtc_lib crc_ccitt iTCO_wdt asus_laptop led_class sr_mod cdr=
om pcspkr sdhci mmc_core i2c_i801 i2c_core ieee80211 crc_itu_t watchdog=
_core watchdog_dev ieee80211_crypt ehci_hcd ohci_hcd uhci_hcd
<4>
<4>Pid: 11914, comm: xmoto Not tainted (2.6.23-rc8-mm2-taskstats #27)
<4>EIP: 0060:[<c0336bb2>] EFLAGS: 00010283 CPU: 0
<4>EIP is at skb_checksum_help+0xe2/0xf0
<4>EAX: 0000040e EBX: c73c8cb0 ECX: 00000292 EDX: d0805800
<4>ESI: 00003822 EDI: c71b0000 EBP: c82da380 ESP: c0556c68
<4> DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
<0>Process xmoto (pid: 11914, ti=3Dc0556000 task=3Dc73a10e0 task.ti=3Dc=
843e000)
<0>last branch before last exception/interrupt
<0> from c0125808 (vprintk+0x1c8/0x370)
<0> to c0107520 (irq_entries_start+0x88/0x840)
<0>Stack: 00000020 c82da394 c73c8cb0 c033921d 00004108 c71b0380 c82da39=
4 c73c8cb0=20
<0>       d082241c c82da380 c035dcab c71b0414 00000800 00000001 0000000=
1 0000000e=20
<0>       c73c8cb0 c73c8cb0 d082241c c743bb80 6a649d53 00000000 c035d19=
9 00000000=20
<0>Call Trace:
<0> [<c033921d>] dev_queue_xmit+0x1bd/0x380
<0> [<c035dcab>] ip_output+0x17b/0x300
<0> [<c035d199>] ip_queue_xmit+0x1d9/0x410
<0> [<c036dfa1>] tcp_transmit_skb+0x3d1/0x790
<0> [<c036eec0>] tcp_retransmit_skb+0x150/0x630
<0> [<c036f49c>] tcp_xmit_retransmit_queue+0xfc/0x320
<0> [<c03694db>] tcp_ack+0x130b/0x1c40
<0> [<c036d00d>] tcp_rcv_established+0x46d/0x6c0
<0> [<c0372fb3>] tcp_v4_do_rcv+0xb3/0x3c0
<0> [<c0375835>] tcp_v4_rcv+0xa05/0xa70
<0> [<c0358303>] ip_local_deliver+0x153/0x300
<0> [<c0357ee2>] ip_rcv+0x2c2/0x590
<0> [<c033619a>] netif_receive_skb+0x27a/0x500
<0> [<c03388a9>] process_backlog+0x59/0xd0
<0> [<c033848d>] net_rx_action+0x9d/0x1d0
<0> [<c012a528>] __do_softirq+0x48/0xb0
<0> [<c0109622>] do_softirq+0x82/0xe0
<0> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
<0>Code: 66 83 38 01 0f 84 72 ff ff ff 31 c9 31 d2 89 d8 c7 04 24 20 00=
 00 00 e8 ad 98 ff ff 85 c0 0f 84 58 ff ff ff eb d6 0f 0b 90 eb fd <0f>=
 0b eb fe 0f 0b eb fe 8d b6 00 00 00 00 83 ec 0c 89 5c 24 04=20
<0>EIP: [<c0336bb2>] skb_checksum_help+0xe2/0xf0 SS:ESP 0068:c0556c68

#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.23-rc8-mm2
# Tue Oct  2 20:37:16 2007
#
CONFIG_X86_32=3Dy
CONFIG_GENERIC_TIME=3Dy
CONFIG_GENERIC_CMOS_UPDATE=3Dy
CONFIG_CLOCKSOURCE_WATCHDOG=3Dy
CONFIG_GENERIC_CLOCKEVENTS=3Dy
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=3Dy
CONFIG_LOCKDEP_SUPPORT=3Dy
CONFIG_STACKTRACE_SUPPORT=3Dy
CONFIG_SEMAPHORE_SLEEPERS=3Dy
CONFIG_X86=3Dy
CONFIG_MMU=3Dy
CONFIG_ZONE_DMA=3Dy
CONFIG_QUICKLIST=3Dy
CONFIG_GENERIC_ISA_DMA=3Dy
CONFIG_GENERIC_IOMAP=3Dy
CONFIG_GENERIC_BUG=3Dy
CONFIG_GENERIC_HWEIGHT=3Dy
CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy
CONFIG_DMI=3Dy
CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"

#
# General setup
#
CONFIG_EXPERIMENTAL=3Dy
CONFIG_BROKEN_ON_SMP=3Dy
CONFIG_LOCK_KERNEL=3Dy
CONFIG_INIT_ENV_ARG_LIMIT=3D32
CONFIG_LOCALVERSION=3D"-taskstats"
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_SWAP=3Dy
CONFIG_SYSVIPC=3Dy
CONFIG_SYSVIPC_SYSCTL=3Dy
CONFIG_POSIX_MQUEUE=3Dy
CONFIG_BSD_PROCESS_ACCT=3Dy
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
CONFIG_TASKSTATS=3Dy
CONFIG_TASK_DELAY_ACCT=3Dy
CONFIG_TASK_XACCT=3Dy
CONFIG_TASK_IO_ACCOUNTING=3Dy
CONFIG_USER_NS=3Dy
CONFIG_AUDIT=3Dy
CONFIG_AUDITSYSCALL=3Dy
CONFIG_AUDIT_TREE=3Dy
CONFIG_IKCONFIG=3Dy
CONFIG_IKCONFIG_PROC=3Dy
CONFIG_LOG_BUF_SHIFT=3D17
# CONFIG_CGROUPS is not set
# CONFIG_FAIR_GROUP_SCHED is not set
CONFIG_SYSFS_DEPRECATED=3Dy
CONFIG_RELAY=3Dy
CONFIG_BLK_DEV_INITRD=3Dy
CONFIG_INITRAMFS_SOURCE=3D""
CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy
CONFIG_SYSCTL=3Dy
# CONFIG_EMBEDDED is not set
CONFIG_UID16=3Dy
CONFIG_SYSCTL_SYSCALL=3Dy
CONFIG_KALLSYMS=3Dy
# CONFIG_KALLSYMS_ALL is not set
CONFIG_KALLSYMS_EXTRA_PASS=3Dy
CONFIG_HOTPLUG=3Dy
CONFIG_PRINTK=3Dy
CONFIG_BUG=3Dy
CONFIG_ELF_CORE=3Dy
CONFIG_BASE_FULL=3Dy
CONFIG_FUTEX=3Dy
CONFIG_ANON_INODES=3Dy
CONFIG_EPOLL=3Dy
CONFIG_SIGNALFD=3Dy
CONFIG_EVENTFD=3Dy
CONFIG_SHMEM=3Dy
CONFIG_VM_EVENT_COUNTERS=3Dy
CONFIG_SLUB_DEBUG=3Dy
# CONFIG_SLAB is not set
CONFIG_SLUB=3Dy
# CONFIG_SLOB is not set
CONFIG_PROC_PAGE_MONITOR=3Dy
CONFIG_PROC_KPAGEMAP=3Dy
CONFIG_RT_MUTEXES=3Dy
# CONFIG_TINY_SHMEM is not set
CONFIG_BASE_SMALL=3D0
CONFIG_MODULES=3Dy
CONFIG_MODULE_UNLOAD=3Dy
CONFIG_MODULE_FORCE_UNLOAD=3Dy
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_KMOD=3Dy
CONFIG_BLOCK=3Dy
CONFIG_LBD=3Dy
CONFIG_BLK_DEV_IO_TRACE=3Dy
# CONFIG_LSF is not set
CONFIG_BLK_DEV_BSG=3Dy

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=3Dy
CONFIG_IOSCHED_AS=3Dm
CONFIG_IOSCHED_DEADLINE=3Dm
CONFIG_IOSCHED_CFQ=3Dy
# CONFIG_DEFAULT_AS is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=3Dy
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED=3D"cfq"

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=3Dy
CONFIG_NO_HZ=3Dy
CONFIG_HIGH_RES_TIMERS=3Dy
CONFIG_GENERIC_CLOCKEVENTS_BUILD=3Dy
# CONFIG_SMP is not set
CONFIG_X86_PC=3Dy
# CONFIG_X86_ELAN is not set
# CONFIG_X86_VOYAGER is not set
# CONFIG_X86_NUMAQ is not set
# CONFIG_X86_SUMMIT is not set
# CONFIG_X86_BIGSMP is not set
# CONFIG_X86_VISWS is not set
# CONFIG_X86_GENERICARCH is not set
# CONFIG_X86_ES7000 is not set
CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=3Dy
CONFIG_PARAVIRT=3Dy
CONFIG_XEN=3Dy
CONFIG_VMI=3Dy
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
CONFIG_MPENTIUMM=3Dy
# CONFIG_MPENTIUM4 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP2 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_X86_GENERIC is not set
CONFIG_X86_CMPXCHG=3Dy
CONFIG_X86_L1_CACHE_SHIFT=3D6
CONFIG_X86_XADD=3Dy
CONFIG_RWSEM_XCHGADD_ALGORITHM=3Dy
# CONFIG_ARCH_HAS_ILOG2_U32 is not set
# CONFIG_ARCH_HAS_ILOG2_U64 is not set
CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
CONFIG_X86_WP_WORKS_OK=3Dy
CONFIG_X86_INVLPG=3Dy
CONFIG_X86_BSWAP=3Dy
CONFIG_X86_POPAD_OK=3Dy
CONFIG_X86_GOOD_APIC=3Dy
CONFIG_X86_INTEL_USERCOPY=3Dy
CONFIG_X86_USE_PPRO_CHECKSUM=3Dy
CONFIG_X86_TSC=3Dy
CONFIG_X86_CMOV=3Dy
CONFIG_X86_MINIMUM_CPU_FAMILY=3D4
# CONFIG_HPET_TIMER is not set
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=3Dy
CONFIG_PREEMPT_BKL=3Dy
CONFIG_X86_UP_APIC=3Dy
CONFIG_X86_UP_IOAPIC=3Dy
CONFIG_X86_LOCAL_APIC=3Dy
CONFIG_X86_IO_APIC=3Dy
CONFIG_X86_MCE=3Dy
CONFIG_X86_MCE_NONFATAL=3Dy
# CONFIG_X86_MCE_P4THERMAL is not set
CONFIG_VM86=3Dy
# CONFIG_TOSHIBA is not set
# CONFIG_I8K is not set
# CONFIG_X86_REBOOTFIXUPS is not set
CONFIG_MICROCODE=3Dm
CONFIG_MICROCODE_OLD_INTERFACE=3Dy
CONFIG_X86_MSR=3Dm
CONFIG_X86_CPUID=3Dm

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=3Dy
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=3Dy
# CONFIG_HIGHMEM64G is not set
CONFIG_PAGE_OFFSET=3D0xC0000000
CONFIG_HIGHMEM=3Dy
CONFIG_ARCH_FLATMEM_ENABLE=3Dy
CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
CONFIG_ARCH_SELECT_MEMORY_MODEL=3Dy
CONFIG_ARCH_POPULATES_NODE_MAP=3Dy
CONFIG_SELECT_MEMORY_MODEL=3Dy
CONFIG_FLATMEM_MANUAL=3Dy
# CONFIG_DISCONTIGMEM_MANUAL is not set
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=3Dy
CONFIG_FLAT_NODE_MEM_MAP=3Dy
CONFIG_SPARSEMEM_STATIC=3Dy
# CONFIG_SPARSEMEM_VMEMMAP_ENABLE is not set
CONFIG_SPLIT_PTLOCK_CPUS=3D4
# CONFIG_RESOURCES_64BIT is not set
CONFIG_ZONE_DMA_FLAG=3D1
CONFIG_BOUNCE=3Dy
CONFIG_NR_QUICK=3D1
CONFIG_VIRT_TO_BUS=3Dy
CONFIG_HIGHPTE=3Dy
# CONFIG_MATH_EMULATION is not set
CONFIG_MTRR=3Dy
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=3Dy
CONFIG_HZ=3D1000
CONFIG_KEXEC=3Dy
CONFIG_CRASH_DUMP=3Dy
CONFIG_PHYSICAL_START=3D0x100000
CONFIG_RELOCATABLE=3Dy
CONFIG_PHYSICAL_ALIGN=3D0x100000
# CONFIG_COMPAT_VDSO is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy

#
# Power management options (ACPI, APM)
#
CONFIG_PM=3Dy
CONFIG_PM_LEGACY=3Dy
# CONFIG_PM_DEBUG is not set
CONFIG_PM_SLEEP=3Dy
CONFIG_SUSPEND_UP_POSSIBLE=3Dy
CONFIG_SUSPEND=3Dy
CONFIG_HIBERNATION_UP_POSSIBLE=3Dy
CONFIG_HIBERNATION=3Dy
CONFIG_PM_STD_PARTITION=3D""
CONFIG_ACPI=3Dy
CONFIG_ACPI_SLEEP=3Dy
CONFIG_ACPI_PROCFS=3Dy
CONFIG_ACPI_PROC_EVENT=3Dy
CONFIG_ACPI_AC=3Dm
CONFIG_ACPI_BATTERY=3Dm
CONFIG_ACPI_BUTTON=3Dm
CONFIG_ACPI_VIDEO=3Dm
CONFIG_ACPI_FAN=3Dy
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=3Dy
CONFIG_ACPI_THERMAL=3Dy
CONFIG_ACPI_ASUS=3Dm
# CONFIG_ACPI_TOSHIBA is not set
CONFIG_ACPI_BLACKLIST_YEAR=3D1999
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_EC=3Dy
CONFIG_ACPI_POWER=3Dy
CONFIG_ACPI_SYSTEM=3Dy
CONFIG_X86_PM_TIMER=3Dy
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set
CONFIG_APM=3Dy
# CONFIG_APM_IGNORE_USER_SUSPEND is not set
# CONFIG_APM_DO_ENABLE is not set
CONFIG_APM_CPU_IDLE=3Dy
# CONFIG_APM_DISPLAY_BLANK is not set
# CONFIG_APM_ALLOW_INTS is not set
# CONFIG_APM_REAL_MODE_POWER_OFF is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=3Dy
CONFIG_CPU_FREQ_TABLE=3Dy
# CONFIG_CPU_FREQ_DEBUG is not set
CONFIG_CPU_FREQ_STAT=3Dm
CONFIG_CPU_FREQ_STAT_DETAILS=3Dy
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=3Dy
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=3Dy
CONFIG_CPU_FREQ_GOV_POWERSAVE=3Dm
CONFIG_CPU_FREQ_GOV_USERSPACE=3Dm
CONFIG_CPU_FREQ_GOV_ONDEMAND=3Dy
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=3Dm

#
# CPUFreq processor drivers
#
CONFIG_X86_ACPI_CPUFREQ=3Dm
# CONFIG_X86_POWERNOW_K6 is not set
# CONFIG_X86_POWERNOW_K7 is not set
# CONFIG_X86_POWERNOW_K8 is not set
# CONFIG_X86_GX_SUSPMOD is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=3Dm
CONFIG_X86_SPEEDSTEP_CENTRINO_TABLE=3Dy
CONFIG_X86_SPEEDSTEP_ICH=3Dm
CONFIG_X86_SPEEDSTEP_SMI=3Dm
# CONFIG_X86_P4_CLOCKMOD is not set
# CONFIG_X86_CPUFREQ_NFORCE2 is not set
# CONFIG_X86_LONGRUN is not set
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
# CONFIG_X86_ACPI_CPUFREQ_PROC_INTF is not set
CONFIG_X86_SPEEDSTEP_LIB=3Dm
CONFIG_X86_SPEEDSTEP_RELAXED_CAP_CHECK=3Dy

#
# Bus options (PCI, PCMCIA, EISA, MCA, ISA)
#
CONFIG_PCI=3Dy
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
CONFIG_PCI_GOANY=3Dy
CONFIG_PCI_BIOS=3Dy
CONFIG_PCI_DIRECT=3Dy
CONFIG_PCI_MMCONFIG=3Dy
CONFIG_PCIEPORTBUS=3Dy
CONFIG_PCIEAER=3Dy
CONFIG_ARCH_SUPPORTS_MSI=3Dy
CONFIG_PCI_MSI=3Dy
# CONFIG_PCI_DEBUG is not set
CONFIG_HT_IRQ=3Dy
CONFIG_ISA_DMA_API=3Dy
CONFIG_ISA=3Dy
# CONFIG_EISA is not set
# CONFIG_MCA is not set
# CONFIG_SCx200 is not set
CONFIG_PCCARD=3Dy
# CONFIG_PCMCIA_DEBUG is not set
CONFIG_PCMCIA=3Dy
CONFIG_PCMCIA_LOAD_CIS=3Dy
CONFIG_CARDBUS=3Dy

#
# PC-card bridges
#
CONFIG_YENTA=3Dy
CONFIG_YENTA_O2=3Dy
CONFIG_YENTA_RICOH=3Dy
CONFIG_YENTA_TI=3Dy
CONFIG_YENTA_ENE_TUNE=3Dy
CONFIG_YENTA_TOSHIBA=3Dy
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_I82365 is not set
# CONFIG_TCIC is not set
CONFIG_PCMCIA_PROBE=3Dy
CONFIG_PCCARD_NONSTATIC=3Dy
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats
#
CONFIG_BINFMT_ELF=3Dy
CONFIG_BINFMT_AOUT=3Dm
CONFIG_BINFMT_MISC=3Dm

#
# Networking
#
CONFIG_NET=3Dy

#
# Networking options
#
CONFIG_PACKET=3Dy
CONFIG_PACKET_MMAP=3Dy
CONFIG_UNIX=3Dy
CONFIG_XFRM=3Dy
CONFIG_XFRM_USER=3Dy
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
CONFIG_NET_KEY=3Dm
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_INET=3Dy
CONFIG_IP_MULTICAST=3Dy
CONFIG_IP_ADVANCED_ROUTER=3Dy
CONFIG_ASK_IP_FIB_HASH=3Dy
# CONFIG_IP_FIB_TRIE is not set
CONFIG_IP_FIB_HASH=3Dy
# CONFIG_IP_MULTIPLE_TABLES is not set
# CONFIG_IP_ROUTE_MULTIPATH is not set
CONFIG_IP_ROUTE_VERBOSE=3Dy
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
CONFIG_IP_MROUTE=3Dy
CONFIG_IP_PIMSM_V1=3Dy
CONFIG_IP_PIMSM_V2=3Dy
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=3Dy
CONFIG_INET_AH=3Dm
CONFIG_INET_ESP=3Dm
CONFIG_INET_IPCOMP=3Dm
CONFIG_INET_XFRM_TUNNEL=3Dm
CONFIG_INET_TUNNEL=3Dm
CONFIG_INET_XFRM_MODE_TRANSPORT=3Dy
CONFIG_INET_XFRM_MODE_TUNNEL=3Dy
CONFIG_INET_XFRM_MODE_BEET=3Dy
CONFIG_INET_LRO=3Dy
CONFIG_INET_DIAG=3Dm
CONFIG_INET_TCP_DIAG=3Dm
CONFIG_TCP_CONG_ADVANCED=3Dy
CONFIG_TCP_CONG_BIC=3Dm
CONFIG_TCP_CONG_CUBIC=3Dy
CONFIG_TCP_CONG_WESTWOOD=3Dm
CONFIG_TCP_CONG_HTCP=3Dm
CONFIG_TCP_CONG_HSTCP=3Dm
CONFIG_TCP_CONG_HYBLA=3Dm
CONFIG_TCP_CONG_VEGAS=3Dm
CONFIG_TCP_CONG_SCALABLE=3Dm
CONFIG_TCP_CONG_LP=3Dm
CONFIG_TCP_CONG_VENO=3Dm
CONFIG_TCP_CONG_YEAH=3Dm
CONFIG_TCP_CONG_ILLINOIS=3Dm
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_CUBIC=3Dy
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG=3D"cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IP_VS is not set
CONFIG_IPV6=3Dm
CONFIG_IPV6_PRIVACY=3Dy
CONFIG_IPV6_ROUTER_PREF=3Dy
CONFIG_IPV6_ROUTE_INFO=3Dy
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
CONFIG_INET6_AH=3Dm
CONFIG_INET6_ESP=3Dm
CONFIG_INET6_IPCOMP=3Dm
# CONFIG_IPV6_MIP6 is not set
CONFIG_INET6_XFRM_TUNNEL=3Dm
CONFIG_INET6_TUNNEL=3Dm
CONFIG_INET6_XFRM_MODE_TRANSPORT=3Dm
CONFIG_INET6_XFRM_MODE_TUNNEL=3Dm
CONFIG_INET6_XFRM_MODE_BEET=3Dm
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
CONFIG_IPV6_SIT=3Dm
CONFIG_IPV6_TUNNEL=3Dm
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_NETLABEL is not set
CONFIG_NETWORK_SECMARK=3Dy
CONFIG_NETFILTER=3Dy
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_BRIDGE_NETFILTER=3Dy

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=3Dm
CONFIG_NETFILTER_NETLINK_QUEUE=3Dm
CONFIG_NETFILTER_NETLINK_LOG=3Dm
CONFIG_NF_CONNTRACK_ENABLED=3Dm
CONFIG_NF_CONNTRACK=3Dm
CONFIG_NF_CT_ACCT=3Dy
CONFIG_NF_CONNTRACK_MARK=3Dy
CONFIG_NF_CONNTRACK_SECMARK=3Dy
CONFIG_NF_CONNTRACK_EVENTS=3Dy
CONFIG_NF_CT_PROTO_GRE=3Dm
CONFIG_NF_CT_PROTO_SCTP=3Dm
CONFIG_NF_CT_PROTO_UDPLITE=3Dm
CONFIG_NF_CONNTRACK_AMANDA=3Dm
CONFIG_NF_CONNTRACK_FTP=3Dm
CONFIG_NF_CONNTRACK_H323=3Dm
CONFIG_NF_CONNTRACK_IRC=3Dm
CONFIG_NF_CONNTRACK_NETBIOS_NS=3Dm
CONFIG_NF_CONNTRACK_PPTP=3Dm
CONFIG_NF_CONNTRACK_SANE=3Dm
CONFIG_NF_CONNTRACK_SIP=3Dm
CONFIG_NF_CONNTRACK_TFTP=3Dm
CONFIG_NF_CT_NETLINK=3Dm
CONFIG_NETFILTER_XTABLES=3Dm
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=3Dm
CONFIG_NETFILTER_XT_TARGET_CONNMARK=3Dm
# CONFIG_NETFILTER_XT_TARGET_DSCP is not set
CONFIG_NETFILTER_XT_TARGET_MARK=3Dm
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=3Dm
CONFIG_NETFILTER_XT_TARGET_NFLOG=3Dm
CONFIG_NETFILTER_XT_TARGET_NOTRACK=3Dm
CONFIG_NETFILTER_XT_TARGET_TRACE=3Dm
# CONFIG_NETFILTER_XT_TARGET_SECMARK is not set
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=3Dm
CONFIG_NETFILTER_XT_TARGET_TCPMSS=3Dm
CONFIG_NETFILTER_XT_MATCH_COMMENT=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNMARK=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=3Dm
CONFIG_NETFILTER_XT_MATCH_DCCP=3Dm
# CONFIG_NETFILTER_XT_MATCH_DSCP is not set
CONFIG_NETFILTER_XT_MATCH_ESP=3Dm
CONFIG_NETFILTER_XT_MATCH_HELPER=3Dm
CONFIG_NETFILTER_XT_MATCH_LENGTH=3Dm
CONFIG_NETFILTER_XT_MATCH_LIMIT=3Dm
CONFIG_NETFILTER_XT_MATCH_MAC=3Dm
CONFIG_NETFILTER_XT_MATCH_MARK=3Dm
CONFIG_NETFILTER_XT_MATCH_POLICY=3Dm
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=3Dm
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=3Dm
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=3Dm
CONFIG_NETFILTER_XT_MATCH_QUOTA=3Dm
CONFIG_NETFILTER_XT_MATCH_REALM=3Dm
CONFIG_NETFILTER_XT_MATCH_SCTP=3Dm
CONFIG_NETFILTER_XT_MATCH_STATE=3Dm
CONFIG_NETFILTER_XT_MATCH_STATISTIC=3Dm
CONFIG_NETFILTER_XT_MATCH_STRING=3Dm
CONFIG_NETFILTER_XT_MATCH_TCPMSS=3Dm
CONFIG_NETFILTER_XT_MATCH_U32=3Dm
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=3Dm

#
# IP: Netfilter Configuration
#
CONFIG_NF_CONNTRACK_IPV4=3Dm
CONFIG_NF_CONNTRACK_PROC_COMPAT=3Dy
CONFIG_IP_NF_QUEUE=3Dm
CONFIG_IP_NF_IPTABLES=3Dm
CONFIG_IP_NF_MATCH_IPRANGE=3Dm
CONFIG_IP_NF_MATCH_TOS=3Dm
CONFIG_IP_NF_MATCH_RECENT=3Dm
CONFIG_IP_NF_MATCH_ECN=3Dm
CONFIG_IP_NF_MATCH_AH=3Dm
CONFIG_IP_NF_MATCH_TTL=3Dm
CONFIG_IP_NF_MATCH_OWNER=3Dm
CONFIG_IP_NF_MATCH_ADDRTYPE=3Dm
CONFIG_IP_NF_FILTER=3Dm
CONFIG_IP_NF_TARGET_REJECT=3Dm
CONFIG_IP_NF_TARGET_LOG=3Dm
CONFIG_IP_NF_TARGET_ULOG=3Dm
CONFIG_NF_NAT=3Dm
CONFIG_NF_NAT_NEEDED=3Dy
CONFIG_IP_NF_TARGET_MASQUERADE=3Dm
CONFIG_IP_NF_TARGET_REDIRECT=3Dm
CONFIG_IP_NF_TARGET_NETMAP=3Dm
CONFIG_IP_NF_TARGET_SAME=3Dm
CONFIG_NF_NAT_SNMP_BASIC=3Dm
CONFIG_NF_NAT_PROTO_GRE=3Dm
CONFIG_NF_NAT_FTP=3Dm
CONFIG_NF_NAT_IRC=3Dm
CONFIG_NF_NAT_TFTP=3Dm
CONFIG_NF_NAT_AMANDA=3Dm
CONFIG_NF_NAT_PPTP=3Dm
CONFIG_NF_NAT_H323=3Dm
CONFIG_NF_NAT_SIP=3Dm
CONFIG_IP_NF_MANGLE=3Dm
CONFIG_IP_NF_TARGET_TOS=3Dm
CONFIG_IP_NF_TARGET_ECN=3Dm
CONFIG_IP_NF_TARGET_TTL=3Dm
CONFIG_IP_NF_TARGET_CLUSTERIP=3Dm
CONFIG_IP_NF_RAW=3Dm
CONFIG_IP_NF_ARPTABLES=3Dm
CONFIG_IP_NF_ARPFILTER=3Dm
CONFIG_IP_NF_ARP_MANGLE=3Dm

#
# IPv6: Netfilter Configuration (EXPERIMENTAL)
#
# CONFIG_NF_CONNTRACK_IPV6 is not set
CONFIG_IP6_NF_QUEUE=3Dm
CONFIG_IP6_NF_IPTABLES=3Dm
CONFIG_IP6_NF_MATCH_RT=3Dm
CONFIG_IP6_NF_MATCH_OPTS=3Dm
CONFIG_IP6_NF_MATCH_FRAG=3Dm
CONFIG_IP6_NF_MATCH_HL=3Dm
CONFIG_IP6_NF_MATCH_OWNER=3Dm
CONFIG_IP6_NF_MATCH_IPV6HEADER=3Dm
CONFIG_IP6_NF_MATCH_AH=3Dm
CONFIG_IP6_NF_MATCH_MH=3Dm
CONFIG_IP6_NF_MATCH_EUI64=3Dm
CONFIG_IP6_NF_FILTER=3Dm
CONFIG_IP6_NF_TARGET_LOG=3Dm
CONFIG_IP6_NF_TARGET_REJECT=3Dm
CONFIG_IP6_NF_MANGLE=3Dm
CONFIG_IP6_NF_TARGET_HL=3Dm
CONFIG_IP6_NF_RAW=3Dm

#
# Bridge: Netfilter Configuration
#
CONFIG_BRIDGE_NF_EBTABLES=3Dm
CONFIG_BRIDGE_EBT_BROUTE=3Dm
CONFIG_BRIDGE_EBT_T_FILTER=3Dm
CONFIG_BRIDGE_EBT_T_NAT=3Dm
CONFIG_BRIDGE_EBT_802_3=3Dm
CONFIG_BRIDGE_EBT_AMONG=3Dm
CONFIG_BRIDGE_EBT_ARP=3Dm
CONFIG_BRIDGE_EBT_IP=3Dm
CONFIG_BRIDGE_EBT_LIMIT=3Dm
CONFIG_BRIDGE_EBT_MARK=3Dm
CONFIG_BRIDGE_EBT_PKTTYPE=3Dm
CONFIG_BRIDGE_EBT_STP=3Dm
CONFIG_BRIDGE_EBT_VLAN=3Dm
CONFIG_BRIDGE_EBT_ARPREPLY=3Dm
CONFIG_BRIDGE_EBT_DNAT=3Dm
CONFIG_BRIDGE_EBT_MARK_T=3Dm
CONFIG_BRIDGE_EBT_REDIRECT=3Dm
CONFIG_BRIDGE_EBT_SNAT=3Dm
CONFIG_BRIDGE_EBT_LOG=3Dm
CONFIG_BRIDGE_EBT_ULOG=3Dm
CONFIG_IP_DCCP=3Dm
CONFIG_INET_DCCP_DIAG=3Dm
CONFIG_IP_DCCP_ACKVEC=3Dy

#
# DCCP CCIDs Configuration (EXPERIMENTAL)
#
CONFIG_IP_DCCP_CCID2=3Dm
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=3Dm
CONFIG_IP_DCCP_TFRC_LIB=3Dm
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_CCID3_RTO=3D100

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
# CONFIG_NET_DCCPPROBE is not set
CONFIG_IP_SCTP=3Dm
# CONFIG_SCTP_DBG_MSG is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_HMAC_NONE is not set
# CONFIG_SCTP_HMAC_SHA1 is not set
CONFIG_SCTP_HMAC_MD5=3Dy
CONFIG_TIPC=3Dm
# CONFIG_TIPC_ADVANCED is not set
# CONFIG_TIPC_DEBUG is not set
# CONFIG_ATM is not set
CONFIG_BRIDGE=3Dm
CONFIG_VLAN_8021Q=3Dm
# CONFIG_DECNET is not set
CONFIG_LLC=3Dm
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set

#
# QoS and/or fair queueing
#
CONFIG_NET_SCHED=3Dy
CONFIG_NET_SCH_FIFO=3Dy

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=3Dm
CONFIG_NET_SCH_HTB=3Dm
CONFIG_NET_SCH_HFSC=3Dm
CONFIG_NET_SCH_PRIO=3Dm
CONFIG_NET_SCH_RR=3Dm
CONFIG_NET_SCH_RED=3Dm
CONFIG_NET_SCH_SFQ=3Dm
CONFIG_NET_SCH_TEQL=3Dm
CONFIG_NET_SCH_TBF=3Dm
CONFIG_NET_SCH_GRED=3Dm
CONFIG_NET_SCH_DSMARK=3Dm
CONFIG_NET_SCH_NETEM=3Dm
CONFIG_NET_SCH_INGRESS=3Dm

#
# Classification
#
CONFIG_NET_CLS=3Dy
CONFIG_NET_CLS_BASIC=3Dm
CONFIG_NET_CLS_TCINDEX=3Dm
CONFIG_NET_CLS_ROUTE4=3Dm
CONFIG_NET_CLS_ROUTE=3Dy
CONFIG_NET_CLS_FW=3Dm
CONFIG_NET_CLS_U32=3Dm
CONFIG_CLS_U32_PERF=3Dy
CONFIG_CLS_U32_MARK=3Dy
CONFIG_NET_CLS_RSVP=3Dm
CONFIG_NET_CLS_RSVP6=3Dm
CONFIG_NET_EMATCH=3Dy
CONFIG_NET_EMATCH_STACK=3D32
CONFIG_NET_EMATCH_CMP=3Dm
CONFIG_NET_EMATCH_NBYTE=3Dm
CONFIG_NET_EMATCH_U32=3Dm
CONFIG_NET_EMATCH_META=3Dm
CONFIG_NET_EMATCH_TEXT=3Dm
CONFIG_NET_CLS_ACT=3Dy
CONFIG_NET_ACT_POLICE=3Dy
CONFIG_NET_ACT_GACT=3Dm
CONFIG_GACT_PROB=3Dy
CONFIG_NET_ACT_MIRRED=3Dm
CONFIG_NET_ACT_IPT=3Dm
CONFIG_NET_ACT_PEDIT=3Dm
CONFIG_NET_ACT_SIMP=3Dm
CONFIG_NET_CLS_POLICE=3Dy
CONFIG_NET_CLS_IND=3Dy

#
# Network testing
#
CONFIG_NET_PKTGEN=3Dm
CONFIG_NET_TCPPROBE=3Dm
# CONFIG_HAMRADIO is not set
CONFIG_IRDA=3Dm

#
# IrDA protocols
#
CONFIG_IRLAN=3Dm
CONFIG_IRNET=3Dm
CONFIG_IRCOMM=3Dm
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=3Dy
CONFIG_IRDA_FAST_RR=3Dy
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=3Dm

#
# Dongle support
#
# CONFIG_DONGLE is not set
# CONFIG_KINGSUN_DONGLE is not set
# CONFIG_KSDAZZLE_DONGLE is not set
# CONFIG_KS959_DONGLE is not set

#
# Old SIR device drivers
#
# CONFIG_IRPORT_SIR is not set

#
# Old Serial dongle support
#

#
# FIR device drivers
#
CONFIG_USB_IRDA=3Dm
CONFIG_SIGMATEL_FIR=3Dm
CONFIG_NSC_FIR=3Dm
CONFIG_WINBOND_FIR=3Dm
CONFIG_TOSHIBA_FIR=3Dm
CONFIG_SMC_IRCC_FIR=3Dm
CONFIG_ALI_FIR=3Dm
CONFIG_VLSI_FIR=3Dm
CONFIG_VIA_FIR=3Dm
# CONFIG_MCS_FIR is not set
CONFIG_BT=3Dm
CONFIG_BT_L2CAP=3Dm
CONFIG_BT_SCO=3Dm
CONFIG_BT_RFCOMM=3Dm
CONFIG_BT_RFCOMM_TTY=3Dy
CONFIG_BT_BNEP=3Dm
CONFIG_BT_BNEP_MC_FILTER=3Dy
CONFIG_BT_BNEP_PROTO_FILTER=3Dy
CONFIG_BT_HIDP=3Dm

#
# Bluetooth device drivers
#
CONFIG_BT_HCIUSB=3Dm
CONFIG_BT_HCIUSB_SCO=3Dy
CONFIG_BT_HCIUART=3Dm
CONFIG_BT_HCIUART_H4=3Dy
CONFIG_BT_HCIUART_BCSP=3Dy
CONFIG_BT_HCIBCM203X=3Dm
CONFIG_BT_HCIBPA10X=3Dm
CONFIG_BT_HCIBFUSB=3Dm
CONFIG_BT_HCIDTL1=3Dm
CONFIG_BT_HCIBT3C=3Dm
CONFIG_BT_HCIBLUECARD=3Dm
CONFIG_BT_HCIBTUART=3Dm
CONFIG_BT_HCIVHCI=3Dm
# CONFIG_AF_RXRPC is not set

#
# Wireless
#
CONFIG_CFG80211=3Dm
CONFIG_NL80211=3Dy
CONFIG_WIRELESS_EXT=3Dy
CONFIG_MAC80211=3Dm
CONFIG_MAC80211_LEDS=3Dy
CONFIG_MAC80211_DEBUGFS=3Dy
# CONFIG_MAC80211_DEBUG is not set
CONFIG_IEEE80211=3Dm
# CONFIG_IEEE80211_DEBUG is not set
CONFIG_IEEE80211_CRYPT_WEP=3Dm
CONFIG_IEEE80211_CRYPT_CCMP=3Dm
CONFIG_IEEE80211_CRYPT_TKIP=3Dm
CONFIG_IEEE80211_SOFTMAC=3Dm
CONFIG_IEEE80211_SOFTMAC_DEBUG=3Dy
CONFIG_RFKILL=3Dm
CONFIG_RFKILL_INPUT=3Dm
# CONFIG_NET_9P is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=3D"/sbin/hotplug"
CONFIG_STANDALONE=3Dy
CONFIG_PREVENT_FIRMWARE_BUILD=3Dy
CONFIG_FW_LOADER=3Dy
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
CONFIG_CONNECTOR=3Dy
CONFIG_PROC_EVENTS=3Dy
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=3Dy
# CONFIG_PNP_DEBUG is not set

#
# Protocols
#
# CONFIG_ISAPNP is not set
# CONFIG_PNPBIOS is not set
CONFIG_PNPACPI=3Dy
CONFIG_BLK_DEV=3Dy
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_DEV_XD is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=3Dm
CONFIG_BLK_DEV_CRYPTOLOOP=3Dm
CONFIG_BLK_DEV_NBD=3Dm
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=3Dy
CONFIG_BLK_DEV_RAM_COUNT=3D16
CONFIG_BLK_DEV_RAM_SIZE=3D16384
CONFIG_BLK_DEV_RAM_BLOCKSIZE=3D1024
CONFIG_CDROM_PKTCDVD=3Dm
CONFIG_CDROM_PKTCDVD_BUFFERS=3D8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_XEN_BLKDEV_FRONTEND=3Dm
CONFIG_MISC_DEVICES=3Dy
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ASUS_LAPTOP=3Dm
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_IDE=3Dy
CONFIG_BLK_DEV_IDE=3Dy

#
# Please see Documentation/ide.txt for help/info on IDE drives
#
# CONFIG_BLK_DEV_IDE_SATA is not set
# CONFIG_BLK_DEV_HD_IDE is not set
# CONFIG_BLK_DEV_IDEDISK is not set
# CONFIG_IDEDISK_MULTI_MODE is not set
# CONFIG_BLK_DEV_IDECS is not set
# CONFIG_BLK_DEV_DELKIN is not set
# CONFIG_BLK_DEV_IDECD is not set
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEFLOPPY is not set
# CONFIG_BLK_DEV_IDESCSI is not set
CONFIG_BLK_DEV_IDEACPI=3Dy
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=3Dy

#
# IDE chipset support/bugfixes
#
# CONFIG_IDE_GENERIC is not set
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_IDEPNP is not set

#
# PCI IDE chipsets support
#
# CONFIG_IDEPCI_PCIBUS_ORDER is not set
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CY82C693 is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_CS5535 is not set
# CONFIG_BLK_DEV_HPT34X is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
# CONFIG_BLK_DEV_PIIX is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set
# CONFIG_IDE_ARM is not set

#
# Other IDE chipsets support
#

#
# Note: most of these also require special kernel boot parameters
#
# CONFIG_BLK_DEV_4DRIVES is not set
# CONFIG_BLK_DEV_ALI14XX is not set
# CONFIG_BLK_DEV_DTC2278 is not set
# CONFIG_BLK_DEV_HT6560B is not set
# CONFIG_BLK_DEV_QD65XX is not set
# CONFIG_BLK_DEV_UMC8672 is not set
# CONFIG_BLK_DEV_IDEDMA is not set
CONFIG_IDE_ARCH_OBSOLETE_INIT=3Dy
# CONFIG_BLK_DEV_HD is not set

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=3Dy
CONFIG_SCSI_DMA=3Dy
# CONFIG_SCSI_TGT is not set
# CONFIG_SCSI_NETLINK is not set
CONFIG_SCSI_PROC_FS=3Dy

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=3Dy
CONFIG_CHR_DEV_ST=3Dm
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=3Dm
CONFIG_BLK_DEV_SR_VENDOR=3Dy
CONFIG_CHR_DEV_SG=3Dm
CONFIG_CHR_DEV_SCH=3Dm

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
CONFIG_SCSI_MULTI_LUN=3Dy
CONFIG_SCSI_CONSTANTS=3Dy
CONFIG_SCSI_LOGGING=3Dy
# CONFIG_SCSI_SCAN_ASYNC is not set
CONFIG_SCSI_WAIT_SCAN=3Dm

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=3Dy
# CONFIG_ISCSI_TCP is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_7000FASST is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AHA152X is not set
# CONFIG_SCSI_AHA1542 is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_IN2000 is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_DTC3280 is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_GENERIC_NCR5380 is not set
# CONFIG_SCSI_GENERIC_NCR5380_MMIO is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_NCR53C406A is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_PAS16 is not set
# CONFIG_SCSI_PSI240I is not set
# CONFIG_SCSI_QLOGIC_FAS is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_SEAGATE is not set
# CONFIG_SCSI_SYM53C416 is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_T128 is not set
# CONFIG_SCSI_U14_34F is not set
# CONFIG_SCSI_ULTRASTOR is not set
# CONFIG_SCSI_NSP32 is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
CONFIG_ATA=3Dy
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_ACPI=3Dy
# CONFIG_SATA_AHCI is not set
# CONFIG_SATA_SVW is not set
CONFIG_ATA_PIIX=3Dy
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SX4 is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIL24 is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5535 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
CONFIG_ATA_GENERIC=3Dy
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_LEGACY is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PCMCIA is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_QDI is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set
# CONFIG_PATA_WINBOND_VLB is not set
CONFIG_MD=3Dy
CONFIG_BLK_DEV_MD=3Dm
CONFIG_MD_LINEAR=3Dm
CONFIG_MD_RAID0=3Dm
CONFIG_MD_RAID1=3Dm
CONFIG_MD_RAID10=3Dm
CONFIG_MD_RAID456=3Dm
CONFIG_MD_RAID5_RESHAPE=3Dy
CONFIG_MD_MULTIPATH=3Dm
CONFIG_MD_FAULTY=3Dm
CONFIG_BLK_DEV_DM=3Dm
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=3Dm
CONFIG_DM_SNAPSHOT=3Dm
CONFIG_DM_MIRROR=3Dm
CONFIG_DM_ZERO=3Dm
CONFIG_DM_MULTIPATH=3Dm
CONFIG_DM_MULTIPATH_EMC=3Dm
# CONFIG_DM_MULTIPATH_RDAC is not set
# CONFIG_DM_DELAY is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=3Dm
CONFIG_FIREWIRE_OHCI=3Dm
CONFIG_FIREWIRE_SBP2=3Dm
CONFIG_IEEE1394=3Dm

#
# Subsystem Options
#
# CONFIG_IEEE1394_VERBOSEDEBUG is not set

#
# Controllers
#
CONFIG_IEEE1394_PCILYNX=3Dm
CONFIG_IEEE1394_OHCI1394=3Dm

#
# Protocols
#
CONFIG_IEEE1394_VIDEO1394=3Dm
CONFIG_IEEE1394_SBP2=3Dm
# CONFIG_IEEE1394_SBP2_PHYS_DMA is not set
CONFIG_IEEE1394_ETH1394_ROM_ENTRY=3Dy
CONFIG_IEEE1394_ETH1394=3Dm
CONFIG_IEEE1394_DV1394=3Dm
CONFIG_IEEE1394_RAWIO=3Dm
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=3Dy
# CONFIG_MAC_EMUMOUSEBTN is not set
CONFIG_NETDEVICES=3Dy
# CONFIG_NETDEVICES_MULTIQUEUE is not set
CONFIG_IFB=3Dm
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
CONFIG_MACVLAN=3Dm
# CONFIG_EQUALIZER is not set
CONFIG_TUN=3Dm
# CONFIG_VETH is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_IP1000 is not set
# CONFIG_ARCNET is not set
# CONFIG_NET_ETHERNET is not set
CONFIG_NETDEV_1000=3Dy
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
# CONFIG_E1000E is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
CONFIG_SKGE=3Dm
# CONFIG_SKY2 is not set
# CONFIG_SK98LIN is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2 is not set
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set
# CONFIG_NETDEV_10000 is not set
# CONFIG_TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
CONFIG_WLAN_80211=3Dy
# CONFIG_PCMCIA_RAYCS is not set
# CONFIG_IPW2100 is not set
CONFIG_IPW2200=3Dm
CONFIG_IPW2200_MONITOR=3Dy
CONFIG_IPW2200_RADIOTAP=3Dy
CONFIG_IPW2200_PROMISCUOUS=3Dy
CONFIG_IPW2200_QOS=3Dy
# CONFIG_IPW2200_DEBUG is not set
# CONFIG_LIBERTAS is not set
# CONFIG_AIRO is not set
# CONFIG_HERMES is not set
# CONFIG_USB_ATMEL is not set
# CONFIG_ATMEL is not set
# CONFIG_AIRO_CS is not set
# CONFIG_PCMCIA_WL3501 is not set
# CONFIG_PRISM54 is not set
# CONFIG_USB_ZD1201 is not set
# CONFIG_RTL8187 is not set
# CONFIG_ADM8211 is not set
# CONFIG_P54_COMMON is not set
# CONFIG_ATH5K is not set
# CONFIG_IWLWIFI is not set
# CONFIG_HOSTAP is not set
# CONFIG_BCM43XX is not set
# CONFIG_B43 is not set
# CONFIG_B43LEGACY is not set
# CONFIG_ZD1211RW is not set
# CONFIG_RT2X00 is not set

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET_MII is not set
# CONFIG_USB_USBNET is not set
# CONFIG_NET_PCMCIA is not set
# CONFIG_WAN is not set
CONFIG_XEN_NETDEV_FRONTEND=3Dm
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
CONFIG_PPP=3Dm
CONFIG_PPP_MULTILINK=3Dy
CONFIG_PPP_FILTER=3Dy
CONFIG_PPP_ASYNC=3Dm
CONFIG_PPP_SYNC_TTY=3Dm
CONFIG_PPP_DEFLATE=3Dm
# CONFIG_PPP_BSDCOMP is not set
CONFIG_PPP_MPPE=3Dm
CONFIG_PPPOE=3Dm
CONFIG_PPPOL2TP=3Dm
CONFIG_SLIP=3Dm
CONFIG_SLIP_COMPRESSED=3Dy
CONFIG_SLHC=3Dm
CONFIG_SLIP_SMART=3Dy
# CONFIG_SLIP_MODE_SLIP6 is not set
# CONFIG_NET_FC is not set
# CONFIG_SHAPER is not set
CONFIG_NETCONSOLE=3Dm
CONFIG_NETCONSOLE_DYNAMIC=3Dy
CONFIG_NETPOLL=3Dy
CONFIG_NETPOLL_TRAP=3Dy
CONFIG_NET_POLL_CONTROLLER=3Dy
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=3Dy
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=3Dy
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_TSDEV is not set
CONFIG_INPUT_EVDEV=3Dy
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=3Dy
CONFIG_KEYBOARD_ATKBD=3Dy
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_INPUT_MOUSE=3Dy
CONFIG_MOUSE_PS2=3Dy
CONFIG_MOUSE_PS2_ALPS=3Dy
CONFIG_MOUSE_PS2_LOGIPS2PP=3Dy
CONFIG_MOUSE_PS2_SYNAPTICS=3Dy
CONFIG_MOUSE_PS2_LIFEBOOK=3Dy
CONFIG_MOUSE_PS2_TRACKPOINT=3Dy
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_INPORT is not set
# CONFIG_MOUSE_LOGIBM is not set
# CONFIG_MOUSE_PC110PAD is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=3Dy
CONFIG_INPUT_PCSPKR=3Dm
# CONFIG_INPUT_WISTRON_BTNS is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
CONFIG_INPUT_UINPUT=3Dm

#
# Hardware I/O ports
#
CONFIG_SERIO=3Dy
CONFIG_SERIO_I8042=3Dy
CONFIG_SERIO_SERPORT=3Dy
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=3Dy
CONFIG_SERIO_RAW=3Dm
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=3Dy
CONFIG_VT_UNICODE=3Dy
CONFIG_VT_CONSOLE=3Dy
CONFIG_HW_CONSOLE=3Dy
CONFIG_VT_HW_CONSOLE_BINDING=3Dy
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=3Dy
CONFIG_SERIAL_8250_CONSOLE=3Dy
CONFIG_FIX_EARLYCON_MEM=3Dy
CONFIG_SERIAL_8250_PCI=3Dy
CONFIG_SERIAL_8250_PNP=3Dy
CONFIG_SERIAL_8250_CS=3Dm
CONFIG_SERIAL_8250_NR_UARTS=3D32
CONFIG_SERIAL_8250_RUNTIME_UARTS=3D4
CONFIG_SERIAL_8250_EXTENDED=3Dy
CONFIG_SERIAL_8250_MANY_PORTS=3Dy
# CONFIG_SERIAL_8250_FOURPORT is not set
# CONFIG_SERIAL_8250_ACCENT is not set
# CONFIG_SERIAL_8250_BOCA is not set
# CONFIG_SERIAL_8250_EXAR_ST16C554 is not set
# CONFIG_SERIAL_8250_HUB6 is not set
CONFIG_SERIAL_8250_SHARE_IRQ=3Dy
CONFIG_SERIAL_8250_DETECT_IRQ=3Dy
CONFIG_SERIAL_8250_RSA=3Dy

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=3Dy
CONFIG_SERIAL_CORE_CONSOLE=3Dy
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=3Dy
# CONFIG_LEGACY_PTYS is not set
CONFIG_HVC_DRIVER=3Dy
CONFIG_HVC_XEN=3Dy
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=3Dy
CONFIG_HW_RANDOM_INTEL=3Dm
# CONFIG_HW_RANDOM_AMD is not set
# CONFIG_HW_RANDOM_GEODE is not set
# CONFIG_HW_RANDOM_VIA is not set
CONFIG_NVRAM=3Dy
CONFIG_RTC=3Dy
# CONFIG_DTLK is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set
CONFIG_AGP=3Dy
# CONFIG_AGP_ALI is not set
# CONFIG_AGP_ATI is not set
# CONFIG_AGP_AMD is not set
# CONFIG_AGP_AMD64 is not set
CONFIG_AGP_INTEL=3Dy
# CONFIG_AGP_NVIDIA is not set
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_SWORKS is not set
# CONFIG_AGP_VIA is not set
# CONFIG_AGP_EFFICEON is not set
CONFIG_DRM=3Dm
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
CONFIG_DRM_RADEON=3Dm
# CONFIG_DRM_I810 is not set
# CONFIG_DRM_I830 is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_SIS is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
# CONFIG_CARDMAN_4000 is not set
# CONFIG_CARDMAN_4040 is not set
# CONFIG_IPWIRELESS_CS is not set
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
# CONFIG_NSC_GPIO is not set
# CONFIG_CS5535_GPIO is not set
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=3Dm
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=3Dy
CONFIG_I2C=3Dm
CONFIG_I2C_BOARDINFO=3Dy
CONFIG_I2C_CHARDEV=3Dm

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=3Dm
CONFIG_I2C_ALGOPCF=3Dm
CONFIG_I2C_ALGOPCA=3Dm

#
# I2C Hardware Bus support
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_ELEKTOR is not set
CONFIG_I2C_I801=3Dm
# CONFIG_I2C_I810 is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_PROSAVAGE is not set
# CONFIG_I2C_SAVAGE4 is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_SCx200_ACB is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_STUB is not set
# CONFIG_I2C_TINY_USB is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set
# CONFIG_I2C_VOODOO3 is not set
# CONFIG_I2C_PCA_ISA is not set

#
# Miscellaneous I2C Chip support
#
# CONFIG_SENSORS_DS1337 is not set
# CONFIG_SENSORS_DS1374 is not set
# CONFIG_DS1682 is not set
# CONFIG_SENSORS_EEPROM is not set
# CONFIG_SENSORS_PCF8574 is not set
# CONFIG_SENSORS_PCA9539 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_SENSORS_MAX6875 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I2C_DEBUG_CHIP is not set

#
# SPI support
#
# CONFIG_SPI is not set
# CONFIG_SPI_MASTER is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=3Dm
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_BATTERY_DS2760 is not set
CONFIG_HWMON=3Dm
# CONFIG_HWMON_VID is not set
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHER is not set
# CONFIG_SENSORS_FSCPOS is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=3Dm
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Sonics Silicon Backplane
#
CONFIG_SSB_POSSIBLE=3Dy
# CONFIG_SSB is not set
CONFIG_WATCHDOG=3Dy
# CONFIG_WATCHDOG_NOWAYOUT is not set
CONFIG_WATCHDOG_CORE=3Dm
# CONFIG_WATCHDOG_DEBUG_CORE is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=3Dm
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
CONFIG_ITCO_WDT=3Dm
# CONFIG_ITCO_VENDOR_SUPPORT is not set
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83697HF_WDT is not set
# CONFIG_W83877F_WDT is not set
# CONFIG_W83977F_WDT is not set
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set

#
# ISA-based Watchdog Cards
#
# CONFIG_PCWATCHDOG is not set
# CONFIG_MIXCOMWD is not set
# CONFIG_WDT is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_SM501 is not set

#
# Multimedia devices
#
CONFIG_VIDEO_DEV=3Dm
CONFIG_VIDEO_V4L1=3Dy
CONFIG_VIDEO_V4L1_COMPAT=3Dy
CONFIG_VIDEO_V4L2=3Dy
# CONFIG_VIDEO_CAPTURE_DRIVERS is not set
# CONFIG_RADIO_ADAPTERS is not set
# CONFIG_DVB_CORE is not set
# CONFIG_DAB is not set

#
# Graphics support
#
CONFIG_BACKLIGHT_LCD_SUPPORT=3Dy
CONFIG_LCD_CLASS_DEVICE=3Dm
CONFIG_BACKLIGHT_CLASS_DEVICE=3Dy
# CONFIG_BACKLIGHT_PROGEAR is not set

#
# Display device support
#
# CONFIG_DISPLAY_SUPPORT is not set
CONFIG_VGASTATE=3Dm
CONFIG_VIDEO_OUTPUT_CONTROL=3Dm
CONFIG_FB=3Dy
CONFIG_FIRMWARE_EDID=3Dy
CONFIG_FB_DDC=3Dm
CONFIG_FB_CFB_FILLRECT=3Dy
CONFIG_FB_CFB_COPYAREA=3Dy
CONFIG_FB_CFB_IMAGEBLIT=3Dy
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
# CONFIG_FB_SYS_FILLRECT is not set
# CONFIG_FB_SYS_COPYAREA is not set
# CONFIG_FB_SYS_IMAGEBLIT is not set
# CONFIG_FB_SYS_FOPS is not set
CONFIG_FB_DEFERRED_IO=3Dy
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=3Dy
CONFIG_FB_MODE_HELPERS=3Dy
CONFIG_FB_TILEBLITTING=3Dy

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
CONFIG_FB_VGA16=3Dm
CONFIG_FB_UVESA=3Dm
CONFIG_FB_VESA=3Dy
# CONFIG_FB_EFI is not set
# CONFIG_FB_HECUBA is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I810 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_INTEL is not set
# CONFIG_FB_MATROX is not set
CONFIG_FB_RADEON=3Dm
CONFIG_FB_RADEON_I2C=3Dy
CONFIG_FB_RADEON_BACKLIGHT=3Dy
# CONFIG_FB_RADEON_DEBUG is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_CYBLA is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_VIRTUAL is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=3Dy
CONFIG_VGACON_SOFT_SCROLLBACK=3Dy
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=3D64
CONFIG_VIDEO_SELECT=3Dy
# CONFIG_MDA_CONSOLE is not set
CONFIG_DUMMY_CONSOLE=3Dy
CONFIG_FRAMEBUFFER_CONSOLE=3Dy
# CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY is not set
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=3Dy
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=3Dy
CONFIG_FONT_8x16=3Dy
# CONFIG_LOGO is not set

#
# Sound
#
CONFIG_SOUND=3Dm

#
# Advanced Linux Sound Architecture
#
CONFIG_SND=3Dm
CONFIG_SND_TIMER=3Dm
CONFIG_SND_PCM=3Dm
CONFIG_SND_RAWMIDI=3Dm
CONFIG_SND_SEQUENCER=3Dm
CONFIG_SND_SEQ_DUMMY=3Dm
CONFIG_SND_OSSEMUL=3Dy
CONFIG_SND_MIXER_OSS=3Dm
CONFIG_SND_PCM_OSS=3Dm
CONFIG_SND_PCM_OSS_PLUGINS=3Dy
CONFIG_SND_SEQUENCER_OSS=3Dy
CONFIG_SND_RTCTIMER=3Dm
CONFIG_SND_SEQ_RTCTIMER_DEFAULT=3Dy
CONFIG_SND_DYNAMIC_MINORS=3Dy
CONFIG_SND_SUPPORT_OLD_API=3Dy
CONFIG_SND_VERBOSE_PROCFS=3Dy
CONFIG_SND_VERBOSE_PRINTK=3Dy
# CONFIG_SND_DEBUG is not set

#
# Generic devices
#
CONFIG_SND_MPU401_UART=3Dm
CONFIG_SND_AC97_CODEC=3Dm
CONFIG_SND_DUMMY=3Dm
CONFIG_SND_VIRMIDI=3Dm
CONFIG_SND_MTPAV=3Dm
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=3Dm

#
# ISA devices
#
# CONFIG_SND_ADLIB is not set
# CONFIG_SND_AD1816A is not set
# CONFIG_SND_AD1848 is not set
# CONFIG_SND_ALS100 is not set
# CONFIG_SND_AZT2320 is not set
# CONFIG_SND_CMI8330 is not set
# CONFIG_SND_CS4231 is not set
# CONFIG_SND_CS4232 is not set
# CONFIG_SND_CS4236 is not set
# CONFIG_SND_DT019X is not set
# CONFIG_SND_ES968 is not set
# CONFIG_SND_ES1688 is not set
# CONFIG_SND_ES18XX is not set
# CONFIG_SND_SC6000 is not set
# CONFIG_SND_GUSCLASSIC is not set
# CONFIG_SND_GUSEXTREME is not set
# CONFIG_SND_GUSMAX is not set
# CONFIG_SND_INTERWAVE is not set
# CONFIG_SND_INTERWAVE_STB is not set
# CONFIG_SND_OPL3SA2 is not set
# CONFIG_SND_OPTI92X_AD1848 is not set
# CONFIG_SND_OPTI92X_CS4231 is not set
# CONFIG_SND_OPTI93X is not set
# CONFIG_SND_MIRO is not set
# CONFIG_SND_SB8 is not set
# CONFIG_SND_SB16 is not set
# CONFIG_SND_SBAWE is not set
# CONFIG_SND_SGALAXY is not set
# CONFIG_SND_SSCAPE is not set
# CONFIG_SND_WAVEFRONT is not set

#
# PCI devices
#
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CS5530 is not set
# CONFIG_SND_CS5535AUDIO is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
# CONFIG_SND_HDA_INTEL is not set
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
CONFIG_SND_INTEL8X0=3Dm
CONFIG_SND_INTEL8X0M=3Dm
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set
CONFIG_SND_AC97_POWER_SAVE=3Dy
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=3D0

#
# USB devices
#
# CONFIG_SND_USB_AUDIO is not set
# CONFIG_SND_USB_USX2Y is not set
# CONFIG_SND_USB_CAIAQ is not set

#
# PCMCIA devices
#
# CONFIG_SND_VXPOCKET is not set
# CONFIG_SND_PDAUDIOCF is not set

#
# System on Chip audio support
#
# CONFIG_SND_SOC is not set

#
# SoC Audio support for SuperH
#

#
# Open Sound System
#
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=3Dm
CONFIG_HID_SUPPORT=3Dy
CONFIG_HID=3Dm
# CONFIG_HID_DEBUG is not set
CONFIG_HIDRAW=3Dy

#
# USB Input Devices
#
CONFIG_USB_HID=3Dm
# CONFIG_USB_HIDINPUT_POWERBOOK is not set
# CONFIG_HID_FF is not set
CONFIG_USB_HIDDEV=3Dy

#
# USB HID Boot Protocol drivers
#
# CONFIG_USB_KBD is not set
# CONFIG_USB_MOUSE is not set
CONFIG_USB_SUPPORT=3Dy
CONFIG_USB_ARCH_HAS_HCD=3Dy
CONFIG_USB_ARCH_HAS_OHCI=3Dy
CONFIG_USB_ARCH_HAS_EHCI=3Dy
CONFIG_USB=3Dy
# CONFIG_USB_DEBUG is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=3Dy
# CONFIG_USB_DEVICE_CLASS is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_SUSPEND is not set
# CONFIG_USB_PERSIST is not set
# CONFIG_USB_OTG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_EHCI_HCD=3Dm
CONFIG_USB_EHCI_SPLIT_ISO=3Dy
CONFIG_USB_EHCI_ROOT_HUB_TT=3Dy
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
# CONFIG_USB_ISP116X_HCD is not set
CONFIG_USB_OHCI_HCD=3Dm
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=3Dy
CONFIG_USB_UHCI_HCD=3Dm
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=3Dm

#
# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
#

#
# may also be needed; see USB_STORAGE Help for more information
#
CONFIG_USB_STORAGE=3Dm
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_DPCM is not set
# CONFIG_USB_STORAGE_USBAT is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set
# CONFIG_USB_STORAGE_ALAUDA is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
CONFIG_USB_MON=3Dy

#
# USB port drivers
#

#
# USB Serial Converter support
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_AUERSWALD is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_BERRY_CHARGE is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_PHIDGET is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_GOTEMP is not set

#
# USB DSL modem support
#

#
# USB Gadget Support
#
# CONFIG_USB_GADGET is not set
CONFIG_MMC=3Dm
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set
# CONFIG_MMC_PASSWORDS is not set

#
# MMC/SD Card Drivers
#
CONFIG_MMC_BLOCK=3Dm
CONFIG_MMC_BLOCK_BOUNCE=3Dy
# CONFIG_SDIO_UART is not set

#
# MMC/SD Host Controller Drivers
#
CONFIG_MMC_SDHCI=3Dm
CONFIG_MMC_WBSD=3Dm
# CONFIG_MMC_TIFM_SD is not set
CONFIG_NEW_LEDS=3Dy
CONFIG_LEDS_CLASS=3Dm

#
# LED drivers
#

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=3Dy
CONFIG_LEDS_TRIGGER_TIMER=3Dm
CONFIG_LEDS_TRIGGER_HEARTBEAT=3Dm
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=3Dm
CONFIG_RTC_CLASS=3Dm

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=3Dy
CONFIG_RTC_INTF_PROC=3Dy
CONFIG_RTC_INTF_DEV=3Dy
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=3Dm
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_V3020 is not set

#
# on-CPU RTC drivers
#
# CONFIG_DMADEVICES is not set
CONFIG_VIRTUALIZATION=3Dy
# CONFIG_KVM is not set

#
# Userspace I/O
#
CONFIG_UIO=3Dm
# CONFIG_UIO_CIF is not set
CONFIG_LGUEST=3Dm
CONFIG_LGUEST_GUEST=3Dy
CONFIG_LGUEST_NET=3Dy
CONFIG_LGUEST_BLOCK=3Dy

#
# File systems
#
CONFIG_EXT2_FS=3Dy
CONFIG_EXT2_FS_XATTR=3Dy
CONFIG_EXT2_FS_POSIX_ACL=3Dy
CONFIG_EXT2_FS_SECURITY=3Dy
CONFIG_EXT2_FS_XIP=3Dy
CONFIG_FS_XIP=3Dy
CONFIG_EXT3_FS=3Dy
CONFIG_EXT3_FS_XATTR=3Dy
CONFIG_EXT3_FS_POSIX_ACL=3Dy
CONFIG_EXT3_FS_SECURITY=3Dy
CONFIG_EXT4DEV_FS=3Dm
CONFIG_EXT4DEV_FS_XATTR=3Dy
CONFIG_EXT4DEV_FS_POSIX_ACL=3Dy
CONFIG_EXT4DEV_FS_SECURITY=3Dy
CONFIG_JBD=3Dy
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=3Dm
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=3Dy
# CONFIG_REISER4_FS is not set
CONFIG_REISERFS_FS=3Dm
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=3Dm
# CONFIG_JFS_POSIX_ACL is not set
# CONFIG_JFS_SECURITY is not set
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
CONFIG_FS_POSIX_ACL=3Dy
CONFIG_XFS_FS=3Dm
# CONFIG_XFS_QUOTA is not set
# CONFIG_XFS_SECURITY is not set
# CONFIG_XFS_POSIX_ACL is not set
# CONFIG_XFS_RT is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_INOTIFY=3Dy
CONFIG_INOTIFY_USER=3Dy
CONFIG_QUOTA=3Dy
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
# CONFIG_PRINT_QUOTA_WARNING is not set
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=3Dy
CONFIG_QUOTACTL=3Dy
CONFIG_DNOTIFY=3Dy
CONFIG_AUTOFS_FS=3Dm
CONFIG_AUTOFS4_FS=3Dm
CONFIG_FUSE_FS=3Dm
CONFIG_GENERIC_ACL=3Dy

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=3Dy
CONFIG_JOLIET=3Dy
CONFIG_ZISOFS=3Dy
CONFIG_UDF_FS=3Dm
CONFIG_UDF_NLS=3Dy

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=3Dm
CONFIG_MSDOS_FS=3Dm
CONFIG_VFAT_FS=3Dm
CONFIG_FAT_DEFAULT_CODEPAGE=3D437
CONFIG_FAT_DEFAULT_IOCHARSET=3D"ascii"
CONFIG_NTFS_FS=3Dm
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=3Dy
CONFIG_PROC_KCORE=3Dy
CONFIG_PROC_VMCORE=3Dy
CONFIG_PROC_SYSCTL=3Dy
CONFIG_SYSFS=3Dy
CONFIG_TMPFS=3Dy
CONFIG_TMPFS_POSIX_ACL=3Dy
CONFIG_HUGETLBFS=3Dy
CONFIG_HUGETLB_PAGE=3Dy
CONFIG_CONFIGFS_FS=3Dm

#
# Layered filesystems
#
CONFIG_ECRYPT_FS=3Dm
# CONFIG_UNION_FS is not set

#
# Miscellaneous filesystems
#
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
CONFIG_HFS_FS=3Dm
CONFIG_HFSPLUS_FS=3Dm
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_SYSV_FS is not set
CONFIG_UFS_FS=3Dm
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
CONFIG_NETWORK_FILESYSTEMS=3Dy
CONFIG_NFS_FS=3Dm
CONFIG_NFS_V3=3Dy
CONFIG_NFS_V3_ACL=3Dy
CONFIG_NFS_V4=3Dy
CONFIG_NFS_DIRECTIO=3Dy
CONFIG_NFSD=3Dm
CONFIG_NFSD_V2_ACL=3Dy
CONFIG_NFSD_V3=3Dy
CONFIG_NFSD_V3_ACL=3Dy
CONFIG_NFSD_V4=3Dy
CONFIG_NFSD_TCP=3Dy
CONFIG_LOCKD=3Dm
CONFIG_LOCKD_V4=3Dy
CONFIG_EXPORTFS=3Dm
CONFIG_NFS_ACL_SUPPORT=3Dm
CONFIG_NFS_COMMON=3Dy
CONFIG_SUNRPC=3Dm
CONFIG_SUNRPC_GSS=3Dm
# CONFIG_SUNRPC_BIND34 is not set
CONFIG_RPCSEC_GSS_KRB5=3Dm
CONFIG_RPCSEC_GSS_SPKM3=3Dm
# CONFIG_SMB_FS is not set
CONFIG_CIFS=3Dm
CONFIG_CIFS_STATS=3Dy
CONFIG_CIFS_STATS2=3Dy
CONFIG_CIFS_WEAK_PW_HASH=3Dy
CONFIG_CIFS_XATTR=3Dy
CONFIG_CIFS_POSIX=3Dy
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_EXPERIMENTAL is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=3Dy
# CONFIG_ACORN_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=3Dy
CONFIG_MSDOS_PARTITION=3Dy
CONFIG_BSD_DISKLABEL=3Dy
CONFIG_MINIX_SUBPARTITION=3Dy
CONFIG_SOLARIS_X86_PARTITION=3Dy
CONFIG_UNIXWARE_DISKLABEL=3Dy
CONFIG_LDM_PARTITION=3Dy
# CONFIG_LDM_DEBUG is not set
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=3Dy
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=3Dy
# CONFIG_SYSV68_PARTITION is not set
CONFIG_NLS=3Dy
CONFIG_NLS_DEFAULT=3D"utf8"
CONFIG_NLS_CODEPAGE_437=3Dy
CONFIG_NLS_CODEPAGE_737=3Dm
CONFIG_NLS_CODEPAGE_775=3Dm
CONFIG_NLS_CODEPAGE_850=3Dm
CONFIG_NLS_CODEPAGE_852=3Dm
CONFIG_NLS_CODEPAGE_855=3Dm
CONFIG_NLS_CODEPAGE_857=3Dm
CONFIG_NLS_CODEPAGE_860=3Dm
CONFIG_NLS_CODEPAGE_861=3Dm
CONFIG_NLS_CODEPAGE_862=3Dm
CONFIG_NLS_CODEPAGE_863=3Dm
CONFIG_NLS_CODEPAGE_864=3Dm
CONFIG_NLS_CODEPAGE_865=3Dm
CONFIG_NLS_CODEPAGE_866=3Dm
CONFIG_NLS_CODEPAGE_869=3Dm
CONFIG_NLS_CODEPAGE_936=3Dm
CONFIG_NLS_CODEPAGE_950=3Dm
CONFIG_NLS_CODEPAGE_932=3Dm
CONFIG_NLS_CODEPAGE_949=3Dm
CONFIG_NLS_CODEPAGE_874=3Dm
CONFIG_NLS_ISO8859_8=3Dm
CONFIG_NLS_CODEPAGE_1250=3Dm
CONFIG_NLS_CODEPAGE_1251=3Dm
CONFIG_NLS_ASCII=3Dy
CONFIG_NLS_ISO8859_1=3Dm
CONFIG_NLS_ISO8859_2=3Dm
CONFIG_NLS_ISO8859_3=3Dm
CONFIG_NLS_ISO8859_4=3Dm
CONFIG_NLS_ISO8859_5=3Dm
CONFIG_NLS_ISO8859_6=3Dm
CONFIG_NLS_ISO8859_7=3Dm
CONFIG_NLS_ISO8859_9=3Dm
CONFIG_NLS_ISO8859_13=3Dm
CONFIG_NLS_ISO8859_14=3Dm
CONFIG_NLS_ISO8859_15=3Dm
CONFIG_NLS_KOI8_R=3Dm
CONFIG_NLS_KOI8_U=3Dm
CONFIG_NLS_UTF8=3Dm
# CONFIG_DLM is not set
CONFIG_INSTRUMENTATION=3Dy
CONFIG_PROFILING=3Dy
CONFIG_OPROFILE=3Dm
CONFIG_KPROBES=3Dy

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy
# CONFIG_PRINTK_TIME is not set
CONFIG_ENABLE_MUST_CHECK=3Dy
CONFIG_MAGIC_SYSRQ=3Dy
CONFIG_UNUSED_SYMBOLS=3Dy
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=3Dy
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=3Dy
# CONFIG_DEBUG_SHIRQ is not set
# CONFIG_DETECT_SOFTLOCKUP is not set
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_DEBUG_PREEMPT is not set
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
# CONFIG_DEBUG_HIGHMEM is not set
CONFIG_DEBUG_BUGVERBOSE=3Dy
CONFIG_DEBUG_INFO=3Dy
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_LIST is not set
CONFIG_FRAME_POINTER=3Dy
CONFIG_UNWIND_INFO=3Dy
CONFIG_STACK_UNWIND=3Dy
# CONFIG_PROFILE_LIKELY is not set
# CONFIG_FORCED_INLINING is not set
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DEBUG_SYNCHRO_TEST is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_LKDTM is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_WANT_EXTRA_DEBUG_INFORMATION is not set
# CONFIG_KGDB is not set
# CONFIG_KGDB_ATTACH_WAIT is not set
CONFIG_EARLY_PRINTK=3Dy
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_DEBUG_STACK_USAGE is not set

#
# Page alloc debug is incompatible with Software Suspend on i386
#
# CONFIG_DEBUG_RODATA is not set
CONFIG_4KSTACKS=3Dy
CONFIG_X86_FIND_SMP_CONFIG=3Dy
CONFIG_X86_MPPARSE=3Dy
CONFIG_DOUBLEFAULT=3Dy

#
# Security options
#
CONFIG_KEYS=3Dy
CONFIG_KEYS_DEBUG_PROC_KEYS=3Dy
CONFIG_SECURITY=3Dy
CONFIG_SECURITY_NETWORK=3Dy
CONFIG_SECURITY_NETWORK_XFRM=3Dy
CONFIG_SECURITY_CAPABILITIES=3Dy
# CONFIG_SECURITY_FILE_CAPABILITIES is not set
# CONFIG_SECURITY_ROOTPLUG is not set
CONFIG_SECURITY_SELINUX=3Dy
CONFIG_SECURITY_SELINUX_BOOTPARAM=3Dy
CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=3D1
CONFIG_SECURITY_SELINUX_DISABLE=3Dy
CONFIG_SECURITY_SELINUX_DEVELOP=3Dy
CONFIG_SECURITY_SELINUX_AVC_STATS=3Dy
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=3D1
# CONFIG_SECURITY_SELINUX_ENABLE_SECMARK_DEFAULT is not set
# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
CONFIG_XOR_BLOCKS=3Dm
CONFIG_ASYNC_CORE=3Dm
CONFIG_ASYNC_MEMCPY=3Dm
CONFIG_ASYNC_XOR=3Dm
CONFIG_CRYPTO=3Dy
CONFIG_CRYPTO_ALGAPI=3Dy
CONFIG_CRYPTO_ABLKCIPHER=3Dm
CONFIG_CRYPTO_BLKCIPHER=3Dm
CONFIG_CRYPTO_HASH=3Dy
CONFIG_CRYPTO_MANAGER=3Dy
CONFIG_CRYPTO_HMAC=3Dy
CONFIG_CRYPTO_XCBC=3Dy
CONFIG_CRYPTO_NULL=3Dm
CONFIG_CRYPTO_MD4=3Dm
CONFIG_CRYPTO_MD5=3Dy
CONFIG_CRYPTO_SHA1=3Dy
CONFIG_CRYPTO_SHA256=3Dm
CONFIG_CRYPTO_SHA512=3Dm
CONFIG_CRYPTO_WP512=3Dm
CONFIG_CRYPTO_TGR192=3Dm
CONFIG_CRYPTO_GF128MUL=3Dm
CONFIG_CRYPTO_ECB=3Dm
CONFIG_CRYPTO_CBC=3Dm
CONFIG_CRYPTO_PCBC=3Dm
CONFIG_CRYPTO_LRW=3Dm
# CONFIG_CRYPTO_XTS is not set
CONFIG_CRYPTO_CRYPTD=3Dm
CONFIG_CRYPTO_DES=3Dm
CONFIG_CRYPTO_FCRYPT=3Dm
CONFIG_CRYPTO_BLOWFISH=3Dm
CONFIG_CRYPTO_TWOFISH=3Dm
CONFIG_CRYPTO_TWOFISH_COMMON=3Dm
CONFIG_CRYPTO_TWOFISH_586=3Dm
CONFIG_CRYPTO_SERPENT=3Dm
CONFIG_CRYPTO_AES=3Dm
CONFIG_CRYPTO_AES_586=3Dm
CONFIG_CRYPTO_CAST5=3Dm
CONFIG_CRYPTO_CAST6=3Dm
CONFIG_CRYPTO_TEA=3Dm
CONFIG_CRYPTO_ARC4=3Dm
CONFIG_CRYPTO_KHAZAD=3Dm
CONFIG_CRYPTO_ANUBIS=3Dm
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_DEFLATE=3Dm
CONFIG_CRYPTO_MICHAEL_MIC=3Dm
CONFIG_CRYPTO_CRC32C=3Dm
CONFIG_CRYPTO_CAMELLIA=3Dm
# CONFIG_CRYPTO_TEST is not set
# CONFIG_CRYPTO_AUTHENC is not set
# CONFIG_CRYPTO_HW is not set

#
# Library routines
#
CONFIG_BITREVERSE=3Dy
CONFIG_CRC_CCITT=3Dm
CONFIG_CRC16=3Dm
CONFIG_CRC_ITU_T=3Dm
CONFIG_CRC32=3Dy
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=3Dm
CONFIG_AUDIT_GENERIC=3Dy
CONFIG_ZLIB_INFLATE=3Dy
CONFIG_ZLIB_DEFLATE=3Dm
CONFIG_TEXTSEARCH=3Dy
CONFIG_TEXTSEARCH_KMP=3Dm
CONFIG_TEXTSEARCH_BM=3Dm
CONFIG_TEXTSEARCH_FSM=3Dm
CONFIG_PLIST=3Dy
CONFIG_HAS_IOMEM=3Dy
CONFIG_HAS_IOPORT=3Dy
CONFIG_HAS_DMA=3Dy
CONFIG_GENERIC_HARDIRQS=3Dy
CONFIG_GENERIC_IRQ_PROBE=3Dy
CONFIG_X86_BIOS_REBOOT=3Dy
CONFIG_KTIME_SCALAR=3Dy

--=20
Guillaume
