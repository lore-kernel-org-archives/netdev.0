From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: PROBLEM: oops w/ bridge in 2.6.32.7
Date: Mon, 8 Feb 2010 14:20:44 -0800
Message-ID: <20100208142044.6be97024.akpm@linux-foundation.org>
References: <20100206165351.GA9411@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel-Liste <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	bridge@lists.linux-foundation.org
To: lkml@Think-Future.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51708 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750946Ab0BHWVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 17:21:24 -0500
In-Reply-To: <20100206165351.GA9411@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 6 Feb 2010 17:53:52 +0100
lkml@Think-Future.de wrote:

>   Hi, 
> 
> 
> One line summary of the problem:    
> With vboxdrv module loaded, tap0 device (no IP assigned), adding a bridge if w/ tap0 as single port: kernel ooops @brctl
> command. See oops msg below.
> 

Thanks.  let's cc the appropriate lists and individuals.

> A small shell script or example program which triggers the problem:
> ifup br0 did it already. 
> Goal was to use tap0 as bridge port and enable host to guest networking with virtualbox bridge networking.
> virtualbox-ose              3.1.2-dfsg-1+b1
> virtualbox-ose-source       3.1.2-dfsg-1
> 
> 
> Keywords (i.e., modules, networking, kernel):
> bridge, tap, uml, virtualbox, kernel is bigmem, 4gb, lxc enabled
> 
> 
> /proc/version:
> --------------
> Linux version 2.6.32.7 (me@mypole) (gcc version 4.3.4 (Debian 4.3.4-6) ) #8 SMP PREEMPT Thu Feb 4 22:01:23 CET 2010
> 
> 
> Output of Oops.. message:
> 
> Feb  6 16:40:27 localhost kernel: [463555.689331] BUG: unable to handle kernel NULL pointer dereference at 00000022
> Feb  6 16:40:27 localhost kernel: [463555.689343] IP: [<c1134a3a>] sysfs_addrm_start+0x2a/0xb0
> Feb  6 16:40:27 localhost kernel: [463555.689361] *pdpt = 0000000027de2001 *pde = 0000000000000000
> Feb  6 16:40:27 localhost kernel: [463555.689371] Oops: 0000 [#1] PREEMPT SMP
> Feb  6 16:40:27 localhost kernel: [463555.689379] last sysfs file: /sys/devices/virtual/net/br0/address
> Feb  6 16:40:27 localhost kernel: [463555.689386] Modules linked in: bridge vboxdrv iwlagn iwlcore btusb stp tp_smapi thinkpad_ec uvcvideo nf_conntrack_netlink iptable_nat nf_nat iptable_mangle ipt_LOG xt_tcpudp xt_state xt_multiport iptable_filter ip_tables x_tables e1000e rtc_cmos [last unloaded: vboxdrv]
> Feb  6 16:40:27 localhost kernel: [463555.689433]
> Feb  6 16:40:27 localhost kernel: [463555.689440] Pid: 30082, comm: brctl Not tainted (2.6.32.7 #7) 7666B4G
> Feb  6 16:40:27 localhost kernel: [463555.689447] EIP: 0060:[<c1134a3a>] EFLAGS: 00210282 CPU: 1
> Feb  6 16:40:27 localhost kernel: [463555.689455] EIP is at sysfs_addrm_start+0x2a/0xb0
> Feb  6 16:40:27 localhost kernel: [463555.689461] EAX: c19bf5c8 EBX: 00000002 ECX: 00000000 EDX: ee27a000
> Feb  6 16:40:27 localhost kernel: [463555.689467] ESI: ee27be34 EDI: ee27be44 EBP: 00000002 ESP: ee27be20
> Feb  6 16:40:27 localhost kernel: [463555.689473]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Feb  6 16:40:27 localhost kernel: [463555.689480] Process brctl (pid: 30082, ti=ee27a000 task=f016aa70 task.ti=ee27a000)
> Feb  6 16:40:27 localhost kernel: [463555.689486] Stack:
> Feb  6 16:40:27 localhost kernel: [463555.689489]  f02372bc f02372bc e8e81400 fffffff4 c1134f9f 00000002 00000000 00000000
> Feb  6 16:40:27 localhost kernel: [463555.689504] <0> 00000000 fa2f6cda 00000002 f0237000 c1b5be80 c1135053 ee27be74 00000000
> Feb  6 16:40:27 localhost kernel: [463555.689520] <0> c1136522 00000000 fa2f7380 00000000 f02372bc 00000010 00000000 f02372bc
> Feb  6 16:40:27 localhost kernel: [463555.689537] Call Trace:
> Feb  6 16:40:27 localhost kernel: [463555.689548]  [<c1134f9f>] ? create_dir+0x3f/0x90
> Feb  6 16:40:27 localhost kernel: [463555.689558]  [<c1135053>] ? sysfs_create_subdir+0x13/0x20
> Feb  6 16:40:27 localhost kernel: [463555.689568]  [<c1136522>] ? internal_create_group+0x52/0x180
> Feb  6 16:40:27 localhost kernel: [463555.689582]  [<fa2f4973>] ? br_sysfs_addbr+0x23/0xf0 [bridge]
> Feb  6 16:40:27 localhost kernel: [463555.689594]  [<fa2f0b2f>] ? br_add_bridge+0x18f/0x1a0 [bridge]
> Feb  6 16:40:27 localhost kernel: [463555.689605]  [<fa2f1799>] ? br_ioctl_deviceless_stub+0x209/0x230 [bridge]
> Feb  6 16:40:27 localhost kernel: [463555.689617]  [<fa2f1590>] ? br_ioctl_deviceless_stub+0x0/0x230 [bridge]
> Feb  6 16:40:27 localhost kernel: [463555.689629]  [<c15b234d>] ? sock_ioctl+0xcd/0x260
> Feb  6 16:40:27 localhost kernel: [463555.689638]  [<c15b2280>] ? sock_ioctl+0x0/0x260
> Feb  6 16:40:27 localhost kernel: [463555.689647]  [<c10ec05b>] ? vfs_ioctl+0x2b/0x90
> Feb  6 16:40:27 localhost kernel: [463555.689656]  [<c10ec553>] ? do_vfs_ioctl+0x3b3/0x5d0
> Feb  6 16:40:27 localhost kernel: [463555.689664]  [<c15b3be0>] ? sys_socket+0x60/0x80
> Feb  6 16:40:27 localhost kernel: [463555.689675]  [<c1024f1e>] ? do_page_fault+0x12e/0x300
> Feb  6 16:40:27 localhost kernel: [463555.689684]  [<c10ec7d6>] ? sys_ioctl+0x66/0x70
> Feb  6 16:40:27 localhost kernel: [463555.689692]  [<c1002ef0>] ? sysenter_do_call+0x12/0x22
> Feb  6 16:40:27 localhost kernel: [463555.689698] Code: 00 83 ec 10 b9 04 00 00 00 89 5c 24 04 89 d3 89 74 24 08 89 c6 89 7c 24 0c 89 c7 31 c0 f3 ab b8 c8 f5 9b c1 89 16 e8 56 bc 5f 00 <8b> 53 20 b9 20 44 13 c1 a1 24 38 b3 c1 89 1c 24 e8 41 d5 fb ff
> Feb  6 16:40:27 localhost kernel: [463555.689793] EIP: [<c1134a3a>] sysfs_addrm_start+0x2a/0xb0 SS:ESP 0068:ee27be20
> Feb  6 16:40:27 localhost kernel: [463555.689807] CR2: 0000000000000022
> Feb  6 16:40:27 localhost kernel: [463555.689814] ---[ end trace 9bf3a7ef2bd853ba ]---
> 
> 
> /usr/src/linux/scripts/ver_linux:
> ---------------------------------
> Linux mypole 2.6.32.7 #8 SMP PREEMPT Thu Feb 4 22:01:23 CET 2010 i686 GNU/Linux
>  
> Gnu C                  4.3.4
> Gnu make               3.81
> binutils               2.20
> util-linux             2.16.2
> mount                  support
> module-init-tools      3.11
> e2fsprogs              1.41.9
> PPP                    2.4.4
> Linux C Library        2.10.2
> Dynamic linker (ldd)   2.10.2
> Procps                 3.2.8
> Net-tools              1.60
> Kbd                    1.15.1
> Sh-utils               7.4
> wireless-tools         30
> Modules Loaded         vboxdrv ipt_LOG xt_tcpudp xt_state iptable_filter iptable_mangle iptable_nat nf_nat ip_tables x_tables tp_smapi thinkpad_ec iwlagn rtc_cmos e1000e iwlcore
> 
> 
> /proc/cpuinfo:
> --------------
> 
> processor	: 0
> vendor_id	: GenuineIntel
> cpu family	: 6
> model		: 15
> model name	: Intel(R) Core(TM)2 Duo CPU     L7700  @ 1.80GHz
> stepping	: 11
> cpu MHz		: 1800.000
> cache size	: 4096 KB
> physical id	: 0
> siblings	: 2
> core id		: 0
> cpu cores	: 2
> apicid		: 0
> initial apicid	: 0
> fdiv_bug	: no
> hlt_bug		: no
> f00f_bug	: no
> coma_bug	: no
> fpu		: yes
> fpu_exception	: yes
> cpuid level	: 10
> wp		: yes
> flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm constant_tsc arch_perfmon pebs bts aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm lahf_lm ida tpr_shadow vnmi flexpriority
> bogomips	: 3591.04
> clflush size	: 64
> cache_alignment	: 64
> address sizes	: 36 bits physical, 48 bits virtual
> power management:
> 
> processor	: 1
> vendor_id	: GenuineIntel
> cpu family	: 6
> model		: 15
> model name	: Intel(R) Core(TM)2 Duo CPU     L7700  @ 1.80GHz
> stepping	: 11
> cpu MHz		: 1801.000
> cache size	: 4096 KB
> physical id	: 0
> siblings	: 2
> core id		: 1
> cpu cores	: 2
> apicid		: 1
> initial apicid	: 1
> fdiv_bug	: no
> hlt_bug		: no
> f00f_bug	: no
> coma_bug	: no
> fpu		: yes
> fpu_exception	: yes
> cpuid level	: 10
> wp		: yes
> flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm constant_tsc arch_perfmon pebs bts aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm lahf_lm ida tpr_shadow vnmi flexpriority
> bogomips	: 3590.82
> clflush size	: 64
> cache_alignment	: 64
> address sizes	: 36 bits physical, 48 bits virtual
> power management:
> 
> 
> 
> /proc/modules:
> --------------
> 
> vboxdrv 140109 1 - Live 0xfd2be000
> ipt_LOG 4487 5 - Live 0xf8ec8000
> xt_tcpudp 1887 15 - Live 0xf8ebd000
> xt_state 975 12 - Live 0xf8eb3000
> iptable_filter 1898 1 - Live 0xf8e9f000
> iptable_mangle 2425 0 - Live 0xf8e8c000
> iptable_nat 3979 1 - Live 0xf8e79000
> nf_nat 12235 1 iptable_nat, Live 0xf8e6c000
> ip_tables 9034 3 iptable_filter,iptable_mangle,iptable_nat, Live 0xf8e5f000
> x_tables 10572 5 ipt_LOG,xt_tcpudp,xt_state,iptable_nat,ip_tables, Live 0xf8e50000
> tp_smapi 15816 0 - Live 0xf89e4000
> thinkpad_ec 3782 1 tp_smapi, Live 0xf89d5000
> iwlagn 71544 0 - Live 0xf88bd000
> rtc_cmos 7728 0 - Live 0xf883c000
> e1000e 115466 0 - Live 0xf880f000
> iwlcore 83530 1 iwlagn, Live 0xf87c9000
> 
> 
> /proc/ioports:
> --------------
> 
> 0000-001f : dma1
> 0020-0021 : pic1
> 0040-0043 : timer0
> 004f-004f : smapi
> 0050-0053 : timer1
> 0060-0060 : keyboard
> 0064-0064 : keyboard
> 0070-0071 : rtc0
> 0080-008f : dma page reg
> 00a0-00a1 : pic2
> 00b2-00b2 : smapi
> 00c0-00df : dma2
> 00f0-00ff : fpu
> 0170-0177 : 0000:00:1f.1
>   0170-0177 : ata_piix
> 01f0-01f7 : 0000:00:1f.1
>   01f0-01f7 : ata_piix
> 02f8-02ff : serial
> 0376-0376 : 0000:00:1f.1
>   0376-0376 : ata_piix
> 03c0-03df : vga+
> 03f6-03f6 : 0000:00:1f.1
>   03f6-03f6 : ata_piix
> 03f8-03ff : serial
> 0800-080f : pnp 00:02
> 0cf8-0cff : PCI conf1
> 1000-107f : 0000:00:1f.0
>   1000-107f : pnp 00:02
>     1000-1003 : ACPI PM1a_EVT_BLK
>     1004-1005 : ACPI PM1a_CNT_BLK
>     1008-100b : ACPI PM_TMR
>     1010-1015 : ACPI CPU throttle
>     1020-1020 : ACPI PM2_CNT_BLK
>     1028-102f : ACPI GPE0_BLK
> 1180-11bf : 0000:00:1f.0
>   1180-11bf : pnp 00:02
> 15e0-15ef : pnp 00:02
> 1600-161f : thinkpad_ec
> 164e-164f : pnp 00:02
> 1800-1807 : 0000:00:02.0
> 1840-185f : 0000:00:19.0
> 1860-187f : 0000:00:1a.0
>   1860-187f : uhci_hcd
> 1880-189f : 0000:00:1a.1
>   1880-189f : uhci_hcd
> 18a0-18bf : 0000:00:1d.0
>   18a0-18bf : uhci_hcd
> 18c0-18df : 0000:00:1d.1
>   18c0-18df : uhci_hcd
> 18e0-18ef : 0000:00:1f.1
>   18e0-18ef : ata_piix
> 1c00-1c1f : 0000:00:1f.2
>   1c00-1c1f : ahci
> 1c20-1c23 : 0000:00:1f.2
>   1c20-1c23 : ahci
> 1c24-1c27 : 0000:00:1f.2
>   1c24-1c27 : ahci
> 1c28-1c2f : 0000:00:1f.2
>   1c28-1c2f : ahci
> 1c30-1c37 : 0000:00:1f.2
>   1c30-1c37 : ahci
> 1c40-1c5f : 0000:00:1f.3
>   1c40-1c5f : i801_smbus
> 2000-2fff : PCI Bus 0000:02
> 3000-3fff : PCI Bus 0000:03
> 4000-7fff : PCI Bus 0000:05
>   4000-40ff : PCI CardBus 0000:06
>   4400-44ff : PCI CardBus 0000:06
> 
> 
> /proc/iomem:
> ------------
> 
> 00000000-00001fff : System RAM
> 00002000-00005fff : reserved
> 00006000-0009d7ff : System RAM
> 0009d800-0009ffff : reserved
> 000a0000-000bffff : Video RAM area
> 000c0000-000c7fff : Video ROM
> 000c8000-000cbfff : pnp 00:00
> 000cc000-000cffff : pnp 00:00
> 000e0000-000fffff : reserved
>   000f0000-000fffff : System ROM
> 00100000-bf6affff : System RAM
>   01000000-01747a89 : Kernel code
>   01747a8a-01a5b6b7 : Kernel data
>   01ada000-01b7d5a7 : Kernel bss
> bf6b0000-bf6cbfff : ACPI Tables
> bf6cc000-bf6fffff : ACPI Non-volatile Storage
> bf700000-bfffffff : reserved
> c0000000-c3ffffff : PCI CardBus 0000:06
> c4000000-c4000fff : Intel Flush Page
> d4000000-d7efffff : PCI Bus 0000:05
>   d7efe400-d7efe4ff : 0000:05:00.2
>     d7efe400-d7efe4ff : mmc0
>   d7efe800-d7efefff : 0000:05:00.1
>   d7eff000-d7efffff : 0000:05:00.0
>     d7eff000-d7efffff : yenta_socket
> d8000000-dbffffff : PCI Bus 0000:05
>   d8000000-dbffffff : PCI CardBus 0000:06
> e0000000-efffffff : 0000:00:02.0
> f0000000-f3ffffff : PCI MMCONFIG 0 [00-3f]
>   f0000000-f3ffffff : reserved
>     f0000000-f3ffffff : pnp 00:02
> f4000000-f5ffffff : PCI Bus 0000:02
> f6000000-f7ffffff : PCI Bus 0000:03
>   f7f00000-f7f01fff : 0000:03:00.0
>     f7f00000-f7f01fff : iwlagn
> f8000000-f80fffff : 0000:00:02.0
> f8100000-f81fffff : 0000:00:02.1
> f8200000-f821ffff : 0000:00:19.0
>   f8200000-f821ffff : e1000e
> f8220000-f8223fff : 0000:00:1b.0
>   f8220000-f8223fff : ICH HD audio
> f8225000-f8225fff : 0000:00:19.0
>   f8225000-f8225fff : e1000e
> f8426000-f84267ff : 0000:00:1f.2
>   f8426000-f84267ff : ahci
> f8426c00-f8426fff : 0000:00:1a.7
>   f8426c00-f8426fff : ehci_hcd
> f8427000-f84273ff : 0000:00:1d.7
>   f8427000-f84273ff : ehci_hcd
> f8427400-f84274ff : 0000:00:1f.3
> f8500000-f85fffff : PCI Bus 0000:02
> f8600000-f86fffff : PCI Bus 0000:03
> fec00000-fec0ffff : reserved
>   fec00000-fec00fff : IOAPIC 0
> fed00000-fed003ff : HPET 0
>   fed00000-fed003ff : reserved
> fed14000-fed19fff : reserved
>   fed14000-fed17fff : pnp 00:02
>   fed18000-fed18fff : pnp 00:02
>   fed19000-fed19fff : pnp 00:02
> fed1c000-fed8ffff : reserved
>   fed1c000-fed1ffff : pnp 00:02
>   fed45000-fed4bfff : pnp 00:02
> fee00000-fee00fff : Local APIC
>   fee00000-fee00fff : reserved
> ff000000-ffffffff : reserved
> 100000000-13bffffff : System RAM
> 
> 
> lspci -vvv:
> -----------
> 
> 00:00.0 Host bridge: Intel Corporation Mobile PM965/GM965/GL960 Memory Controller Hub (rev 0c)
> 	Subsystem: Lenovo T61
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> 	Latency: 0
> 	Capabilities: <access denied>
> 	Kernel driver in use: agpgart-intel
> 
> 00:02.0 VGA compatible controller: Intel Corporation Mobile GM965/GL960 Integrated Graphics Controller (rev 0c) (prog-if 00 [VGA controller])
> 	Subsystem: Lenovo T61
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 26
> 	Region 0: Memory at f8000000 (64-bit, non-prefetchable) [size=1M]
> 	Region 2: Memory at e0000000 (64-bit, prefetchable) [size=256M]
> 	Region 4: I/O ports at 1800 [size=8]
> 	Expansion ROM at <unassigned> [disabled]
> 	Capabilities: <access denied>
> 	Kernel driver in use: i915
> 
> 00:02.1 Display controller: Intel Corporation Mobile GM965/GL960 Integrated Graphics Controller (rev 0c)
> 	Subsystem: Lenovo T61
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Region 0: Memory at f8100000 (64-bit, non-prefetchable) [size=1M]
> 	Capabilities: <access denied>
> 
> 00:19.0 Ethernet controller: Intel Corporation 82566MM Gigabit Network Connection (rev 03)
> 	Subsystem: Lenovo Device 20de
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 28
> 	Region 0: Memory at f8200000 (32-bit, non-prefetchable) [size=128K]
> 	Region 1: Memory at f8225000 (32-bit, non-prefetchable) [size=4K]
> 	Region 2: I/O ports at 1840 [size=32]
> 	Capabilities: <access denied>
> 	Kernel driver in use: e1000e
> 
> 00:1a.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #4 (rev 03) (prog-if 00 [UHCI])
> 	Subsystem: Lenovo ThinkPad T61
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 20
> 	Region 4: I/O ports at 1860 [size=32]
> 	Kernel driver in use: uhci_hcd
> 
> 00:1a.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #5 (rev 03) (prog-if 00 [UHCI])
> 	Subsystem: Lenovo ThinkPad T60
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 21
> 	Region 4: I/O ports at 1880 [size=32]
> 	Kernel driver in use: uhci_hcd
> 
> 00:1a.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #2 (rev 03) (prog-if 20 [EHCI])
> 	Subsystem: Lenovo ThinkPad T61
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin C routed to IRQ 22
> 	Region 0: Memory at f8426c00 (32-bit, non-prefetchable) [size=1K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: ehci_hcd
> 
> 00:1b.0 Audio device: Intel Corporation 82801H (ICH8 Family) HD Audio Controller (rev 03)
> 	Subsystem: Lenovo ThinkPad T61
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin B routed to IRQ 17
> 	Region 0: Memory at f8220000 (64-bit, non-prefetchable) [size=16K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: HDA Intel
> 
> 00:1c.0 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 1 (rev 03) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
> 	I/O behind bridge: 00002000-00002fff
> 	Memory behind bridge: f4000000-f5ffffff
> 	Prefetchable memory behind bridge: 00000000f8500000-00000000f85fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: <access denied>
> 	Kernel driver in use: pcieport
> 
> 00:1c.1 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 2 (rev 03) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
> 	I/O behind bridge: 00003000-00003fff
> 	Memory behind bridge: f6000000-f7ffffff
> 	Prefetchable memory behind bridge: 00000000f8600000-00000000f86fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: <access denied>
> 	Kernel driver in use: pcieport
> 
> 00:1d.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #1 (rev 03) (prog-if 00 [UHCI])
> 	Subsystem: Lenovo ThinkPad T61
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 16
> 	Region 4: I/O ports at 18a0 [size=32]
> 	Kernel driver in use: uhci_hcd
> 
> 00:1d.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #2 (rev 03) (prog-if 00 [UHCI])
> 	Subsystem: Lenovo ThinkPad T61
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 17
> 	Region 4: I/O ports at 18c0 [size=32]
> 	Kernel driver in use: uhci_hcd
> 
> 00:1d.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #1 (rev 03) (prog-if 20 [EHCI])
> 	Subsystem: Lenovo ThinkPad T61
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin D routed to IRQ 19
> 	Region 0: Memory at f8427000 (32-bit, non-prefetchable) [size=1K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: ehci_hcd
> 
> 00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev f3) (prog-if 01 [Subtractive decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Bus: primary=00, secondary=05, subordinate=08, sec-latency=32
> 	I/O behind bridge: 00004000-00007fff
> 	Memory behind bridge: d4000000-d7efffff
> 	Prefetchable memory behind bridge: 00000000d8000000-00000000dbffffff
> 	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: <access denied>
> 
> 00:1f.0 ISA bridge: Intel Corporation 82801HBM (ICH8M-E) LPC Interface Controller (rev 03)
> 	Subsystem: Lenovo T61
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Capabilities: <access denied>
> 
> 00:1f.1 IDE interface: Intel Corporation 82801HBM/HEM (ICH8M/ICH8M-E) IDE Controller (rev 03) (prog-if 8a [Master SecP PriP])
> 	Subsystem: Lenovo ThinkPad T61
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx+
> 	Latency: 0
> 	Interrupt: pin C routed to IRQ 16
> 	Region 0: I/O ports at 01f0 [size=8]
> 	Region 1: I/O ports at 03f4 [size=1]
> 	Region 2: I/O ports at 0170 [size=8]
> 	Region 3: I/O ports at 0374 [size=1]
> 	Region 4: I/O ports at 18e0 [size=16]
> 	Kernel driver in use: ata_piix
> 
> 00:1f.2 SATA controller: Intel Corporation 82801HBM/HEM (ICH8M/ICH8M-E) SATA AHCI Controller (rev 03) (prog-if 01 [AHCI 1.0])
> 	Subsystem: Lenovo ThinkPad T61
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 27
> 	Region 0: I/O ports at 1c30 [size=8]
> 	Region 1: I/O ports at 1c24 [size=4]
> 	Region 2: I/O ports at 1c28 [size=8]
> 	Region 3: I/O ports at 1c20 [size=4]
> 	Region 4: I/O ports at 1c00 [size=32]
> 	Region 5: Memory at f8426000 (32-bit, non-prefetchable) [size=2K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: ahci
> 
> 00:1f.3 SMBus: Intel Corporation 82801H (ICH8 Family) SMBus Controller (rev 03)
> 	Subsystem: Lenovo ThinkPad T61
> 	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Interrupt: pin A routed to IRQ 23
> 	Region 0: Memory at f8427400 (32-bit, non-prefetchable) [size=256]
> 	Region 4: I/O ports at 1c40 [size=32]
> 	Kernel driver in use: i801_smbus
> 
> 03:00.0 Network controller: Intel Corporation PRO/Wireless 4965 AG or AGN [Kedron] Network Connection (rev 61)
> 	Subsystem: Intel Corporation Lenovo ThinkPad T61
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 29
> 	Region 0: Memory at f7f00000 (64-bit, non-prefetchable) [size=8K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: iwlagn
> 
> 05:00.0 CardBus bridge: Ricoh Co Ltd RL5c476 II (rev ba)
> 	Subsystem: Lenovo Device 20c6
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 168, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 16
> 	Region 0: Memory at d7eff000 (32-bit, non-prefetchable) [size=4K]
> 	Bus: primary=05, secondary=06, subordinate=07, sec-latency=176
> 	Memory window 0: d8000000-dbfff000 (prefetchable)
> 	Memory window 1: c0000000-c3fff000
> 	I/O window 0: 00004000-000040ff
> 	I/O window 1: 00004400-000044ff
> 	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset- 16bInt+ PostWrite+
> 	16-bit legacy interface ports at 0001
> 	Kernel driver in use: yenta_cardbus
> 
> 05:00.1 FireWire (IEEE 1394): Ricoh Co Ltd R5C832 IEEE 1394 Controller (rev 04) (prog-if 10 [OHCI])
> 	Subsystem: Lenovo Device 20c7
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 32 (500ns min, 1000ns max)
> 	Interrupt: pin B routed to IRQ 11
> 	Region 0: Memory at d7efe800 (32-bit, non-prefetchable) [size=2K]
> 	Capabilities: <access denied>
> 
> 05:00.2 SD Host controller: Ricoh Co Ltd R5C822 SD/SDIO/MMC/MS/MSPro Host Adapter (rev 21)
> 	Subsystem: Lenovo Device 20c8
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64
> 	Interrupt: pin C routed to IRQ 18
> 	Region 0: Memory at d7efe400 (32-bit, non-prefetchable) [size=256]
> 	Capabilities: <access denied>
> 	Kernel driver in use: sdhci-pci
> 
> 
> /proc/cmdline:
> --------------
> 
> root=/dev/sda1 ro selinux=0 quiet thinkpad_acpi.experimental=1 thinkpad_acpi.fan_control=1 fastboot i915.modeset=1 video=intelfb:off
> 
> 
> /proc/interrupts:
> -----------------
> 
>            CPU0       CPU1       
>   0:     301541     304446   IO-APIC-edge      timer
>   1:          4          4   IO-APIC-edge      i8042
>   8:          0          1   IO-APIC-edge      rtc0
>   9:       4160       4240   IO-APIC-fasteoi   acpi
>  12:         82         72   IO-APIC-edge      i8042
>  14:          0          0   IO-APIC-edge      ata_piix
>  15:          0          0   IO-APIC-edge      ata_piix
>  16:       7058       7346   IO-APIC-fasteoi   yenta, uhci_hcd:usb5
>  17:       2286       2268   IO-APIC-fasteoi   uhci_hcd:usb6, HDA Intel
>  18:          0          0   IO-APIC-fasteoi   mmc0
>  19:          0          3   IO-APIC-fasteoi   ehci_hcd:usb2
>  20:         30         26   IO-APIC-fasteoi   uhci_hcd:usb3
>  21:          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
>  22:          1          2   IO-APIC-fasteoi   ehci_hcd:usb1
>  26:       7304       7248   PCI-MSI-edge      i915
>  27:      16997      16401   PCI-MSI-edge      ahci
>  28:       2648       2738   PCI-MSI-edge      eth0
>  29:      36782      33811   PCI-MSI-edge      iwlagn
> NMI:          0          0   Non-maskable interrupts
> LOC:     295497     234740   Local timer interrupts
> SPU:          0          0   Spurious interrupts
> PMI:          0          0   Performance monitoring interrupts
> PND:          0          0   Performance pending work
> RES:     169127     182977   Rescheduling interrupts
> CAL:      13546      17347   Function call interrupts
> TLB:        832       1097   TLB shootdowns
> TRM:          0          0   Thermal event interrupts
> THR:          0          0   Threshold APIC interrupts
> MCE:          0          0   Machine check exceptions
> MCP:          4          4   Machine check polls
> ERR:          1
> MIS:          0
> 
> 
> 

<config trimmed>

> uptime:
> -------
> 
>  17:38:41 up 17 min, 14 users,  load average: 0.12, 0.43, 0.45
> 
> 
> free:
> -----
> 
>              total       used       free     shared    buffers     cached
> Mem:       4040720    1589392    2451328          0      38248     758072
> -/+ buffers/cache:     793072    3247648
> Swap:      1951856          0    1951856
> 
> 
> dmesg:
> ------
> 
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 2.6.32.7 (me@mypole) (gcc version 4.3.4 (Debian 4.3.4-6) ) #8 SMP PREEMPT Thu Feb 4 22:01:23 CET 2010
> [    0.000000] KERNEL supported cpus:
> [    0.000000]   Intel GenuineIntel
> [    0.000000]   AMD AuthenticAMD
> [    0.000000]   NSC Geode by NSC
> [    0.000000]   Cyrix CyrixInstead
> [    0.000000]   Centaur CentaurHauls
> [    0.000000]   Transmeta GenuineTMx86
> [    0.000000]   Transmeta TransmetaCPU
> [    0.000000]   UMC UMC UMC UMC
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000]  BIOS-e820: 0000000000000000 - 000000000009d800 (usable)
> [    0.000000]  BIOS-e820: 000000000009d800 - 00000000000a0000 (reserved)
> [    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
> [    0.000000]  BIOS-e820: 0000000000100000 - 00000000bf6b0000 (usable)
> [    0.000000]  BIOS-e820: 00000000bf6b0000 - 00000000bf6cc000 (ACPI data)
> [    0.000000]  BIOS-e820: 00000000bf6cc000 - 00000000bf700000 (ACPI NVS)
> [    0.000000]  BIOS-e820: 00000000bf700000 - 00000000c0000000 (reserved)
> [    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fed00000 - 00000000fed00400 (reserved)
> [    0.000000]  BIOS-e820: 00000000fed14000 - 00000000fed1a000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed90000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
> [    0.000000]  BIOS-e820: 00000000ff000000 - 0000000100000000 (reserved)
> [    0.000000]  BIOS-e820: 0000000100000000 - 000000013c000000 (usable)
> [    0.000000] DMI present.
> [    0.000000] last_pfn = 0x13c000 max_arch_pfn = 0x1000000
> [    0.000000] MTRR default type: uncachable
> [    0.000000] MTRR fixed ranges enabled:
> [    0.000000]   00000-9FFFF write-back
> [    0.000000]   A0000-BFFFF uncachable
> [    0.000000]   C0000-CFFFF write-protect
> [    0.000000]   D0000-DFFFF uncachable
> [    0.000000]   E0000-FFFFF write-protect
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 0C0000000 mask FC0000000 uncachable
> [    0.000000]   1 base 13C000000 mask FFC000000 uncachable
> [    0.000000]   2 base 000000000 mask F00000000 write-back
> [    0.000000]   3 base 100000000 mask FC0000000 write-back
> [    0.000000]   4 base 0BF700000 mask FFFF00000 uncachable
> [    0.000000]   5 base 0BF800000 mask FFF800000 uncachable
> [    0.000000]   6 disabled
> [    0.000000]   7 disabled
> [    0.000000] e820 update range: 00000000bf700000 - 0000000100000000 (usable) ==> (reserved)
> [    0.000000] e820 update range: 0000000000002000 - 0000000000006000 (usable) ==> (reserved)
> [    0.000000] Scanning 1 areas for low memory corruption
> [    0.000000] modified physical RAM map:
> [    0.000000]  modified: 0000000000000000 - 0000000000002000 (usable)
> [    0.000000]  modified: 0000000000002000 - 0000000000006000 (reserved)
> [    0.000000]  modified: 0000000000006000 - 000000000009d800 (usable)
> [    0.000000]  modified: 000000000009d800 - 00000000000a0000 (reserved)
> [    0.000000]  modified: 00000000000e0000 - 0000000000100000 (reserved)
> [    0.000000]  modified: 0000000000100000 - 00000000bf6b0000 (usable)
> [    0.000000]  modified: 00000000bf6b0000 - 00000000bf6cc000 (ACPI data)
> [    0.000000]  modified: 00000000bf6cc000 - 00000000bf700000 (ACPI NVS)
> [    0.000000]  modified: 00000000bf700000 - 00000000c0000000 (reserved)
> [    0.000000]  modified: 00000000f0000000 - 00000000f4000000 (reserved)
> [    0.000000]  modified: 00000000fec00000 - 00000000fec10000 (reserved)
> [    0.000000]  modified: 00000000fed00000 - 00000000fed00400 (reserved)
> [    0.000000]  modified: 00000000fed14000 - 00000000fed1a000 (reserved)
> [    0.000000]  modified: 00000000fed1c000 - 00000000fed90000 (reserved)
> [    0.000000]  modified: 00000000fee00000 - 00000000fee01000 (reserved)
> [    0.000000]  modified: 00000000ff000000 - 0000000100000000 (reserved)
> [    0.000000]  modified: 0000000100000000 - 000000013c000000 (usable)
> [    0.000000] initial memory mapped : 0 - 02000000
> [    0.000000] init_memory_mapping: 0000000000000000-00000000379fe000
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000]  0000000000 - 0000200000 page 4k
> [    0.000000]  0000200000 - 0037800000 page 2M
> [    0.000000]  0037800000 - 00379fe000 page 4k
> [    0.000000] kernel direct mapping tables up to 379fe000 @ 7000-d000
> [    0.000000] RAMDISK: 7fe7c000 - 7ffef118
> [    0.000000] Allocated new RAMDISK: 00100000 - 00273118
> [    0.000000] Move RAMDISK from 000000007fe7c000 - 000000007ffef117 to 00100000 - 00273117
> [    0.000000] ACPI: RSDP 000f6950 00024 (v02 LENOVO)
> [    0.000000] ACPI: XSDT bf6bd368 00094 (v01 LENOVO TP-7N    00002190  LTP 00000000)
> [    0.000000] ACPI: FACP bf6bd500 000F4 (v03 LENOVO TP-7N    00002190 LNVO 00000001)
> [    0.000000] ACPI Warning: 32/64X length mismatch in Gpe1Block: 0/32 (20090903/tbfadt-526)
> [    0.000000] ACPI Warning: Optional field Gpe1Block has zero address or length: 000000000000102C/0 (20090903/tbfadt-557)
> [    0.000000] ACPI: DSDT bf6bd8db 0E32A (v01 LENOVO TP-7N    00002190 MSFT 03000000)
> [    0.000000] ACPI: FACS bf6e4000 00040
> [    0.000000] ACPI: SSDT bf6bd6b4 00227 (v01 LENOVO TP-7N    00002190 MSFT 03000000)
> [    0.000000] ACPI: ECDT bf6cbc05 00052 (v01 LENOVO TP-7N    00002190 LNVO 00000001)
> [    0.000000] ACPI: TCPA bf6cbc57 00032 (v02 LENOVO TP-7N    00002190 LNVO 00000001)
> [    0.000000] ACPI: APIC bf6cbc89 00068 (v01 LENOVO TP-7N    00002190 LNVO 00000001)
> [    0.000000] ACPI: MCFG bf6cbcf1 0003C (v01 LENOVO TP-7N    00002190 LNVO 00000001)
> [    0.000000] ACPI: HPET bf6cbd2d 00038 (v01 LENOVO TP-7N    00002190 LNVO 00000001)
> [    0.000000] ACPI: SLIC bf6cbdf0 00176 (v01 LENOVO TP-7N    00002190  LTP 00000000)
> [    0.000000] ACPI: BOOT bf6cbf66 00028 (v01 LENOVO TP-7N    00002190  LTP 00000001)
> [    0.000000] ACPI: ASF! bf6cbf8e 00072 (v16 LENOVO TP-7N    00002190 PTL  00000001)
> [    0.000000] ACPI: SSDT bf6e2697 0025F (v01 LENOVO TP-7N    00002190 INTL 20050513)
> [    0.000000] ACPI: SSDT bf6e28f6 000A6 (v01 LENOVO TP-7N    00002190 INTL 20050513)
> [    0.000000] ACPI: SSDT bf6e299c 004F7 (v01 LENOVO TP-7N    00002190 INTL 20050513)
> [    0.000000] ACPI: SSDT bf6e2e93 001D8 (v01 LENOVO TP-7N    00002190 INTL 20050513)
> [    0.000000] ACPI: DMI detected: Lenovo ThinkPad X61
> [    0.000000] ACPI: Added _OSI(Linux)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] 4166MB HIGHMEM available.
> [    0.000000] 889MB LOWMEM available.
> [    0.000000]   mapped low ram: 0 - 379fe000
> [    0.000000]   low ram: 0 - 379fe000
> [    0.000000]   node 0 low ram: 00000000 - 379fe000
> [    0.000000]   node 0 bootmap 00009000 - 0000ff40
> [    0.000000] (9 early reservations) ==> bootmem [0000000000 - 00379fe000]
> [    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
> [    0.000000]   #1 [0000001000 - 0000002000]    EX TRAMPOLINE ==> [0000001000 - 0000002000]
> [    0.000000]   #2 [0000006000 - 0000007000]       TRAMPOLINE ==> [0000006000 - 0000007000]
> [    0.000000]   #3 [0001000000 - 0001b7d5a8]    TEXT DATA BSS ==> [0001000000 - 0001b7d5a8]
> [    0.000000]   #4 [000009d800 - 0000100000]    BIOS reserved ==> [000009d800 - 0000100000]
> [    0.000000]   #5 [0001b7e000 - 0001b8e138]              BRK ==> [0001b7e000 - 0001b8e138]
> [    0.000000]   #6 [0000007000 - 0000009000]          PGTABLE ==> [0000007000 - 0000009000]
> [    0.000000]   #7 [0000100000 - 0000273118]      NEW RAMDISK ==> [0000100000 - 0000273118]
> [    0.000000]   #8 [0000009000 - 0000010000]          BOOTMAP ==> [0000009000 - 0000010000]
> [    0.000000] found SMP MP-table at [c00f6980] f6980
> [    0.000000] Zone PFN ranges:
> [    0.000000]   DMA      0x00000000 -> 0x00001000
> [    0.000000]   Normal   0x00001000 -> 0x000379fe
> [    0.000000]   HighMem  0x000379fe -> 0x0013c000
> [    0.000000] Movable zone start PFN for each node
> [    0.000000] early_node_map[4] active PFN ranges
> [    0.000000]     0: 0x00000000 -> 0x00000002
> [    0.000000]     0: 0x00000006 -> 0x0000009d
> [    0.000000]     0: 0x00000100 -> 0x000bf6b0
> [    0.000000]     0: 0x00100000 -> 0x0013c000
> [    0.000000] On node 0 totalpages: 1029705
> [    0.000000] free_area_init_node: node 0, pgdat c1a4f780, node_mem_map c1b90000
> [    0.000000]   DMA zone: 32 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved
> [    0.000000]   DMA zone: 3961 pages, LIFO batch:0
> [    0.000000]   Normal zone: 1748 pages used for memmap
> [    0.000000]   Normal zone: 221994 pages, LIFO batch:31
> [    0.000000]   HighMem zone: 8333 pages used for memmap
> [    0.000000]   HighMem zone: 793637 pages, LIFO batch:31
> [    0.000000] Using APIC driver default
> [    0.000000] ACPI: PM-Timer IO Port: 0x1008
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
> [    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
> [    0.000000] IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [    0.000000] ACPI: IRQ0 used by override.
> [    0.000000] ACPI: IRQ2 used by override.
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
> [    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
> [    0.000000] nr_irqs_gsi: 24
> [    0.000000] Allocating PCI resources starting at c0000000 (gap: c0000000:30000000)
> [    0.000000] NR_CPUS:2 nr_cpumask_bits:2 nr_cpu_ids:2 nr_node_ids:1
> [    0.000000] PERCPU: Embedded 14 pages/cpu @c4400000 s35224 r0 d22120 u1048576
> [    0.000000] pcpu-alloc: s35224 r0 d22120 u1048576 alloc=1*2097152
> [    0.000000] pcpu-alloc: [0] 0 1 
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1019592
> [    0.000000] Kernel command line: root=/dev/sda1 ro selinux=0 quiet thinkpad_acpi.experimental=1 thinkpad_acpi.fan_control=1 fastboot i915.modeset=1 video=intelfb:off
> [    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
> [    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
> [    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
> [    0.000000] Enabling fast FPU save and restore... done.
> [    0.000000] Enabling unmasked SIMD FPU exception support... done.
> [    0.000000] Initializing CPU#0
> [    0.000000] allocated 25886720 bytes of page_cgroup
> [    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
> [    0.000000] Initializing HighMem for node 0 (000379fe:0013c000)
> [    0.000000] Memory: 4037836k/5177344k available (7454k kernel code, 80060k reserved, 3151k data, 476k init, 3207880k highmem)
> [    0.000000] virtual kernel memory layout:
> [    0.000000]     fixmap  : 0xfff91000 - 0xfffff000   ( 440 kB)
> [    0.000000]     pkmap   : 0xffa00000 - 0xffc00000   (2048 kB)
> [    0.000000]     vmalloc : 0xf81fe000 - 0xff9fe000   ( 120 MB)
> [    0.000000]     lowmem  : 0xc0000000 - 0xf79fe000   ( 889 MB)
> [    0.000000]       .init : 0xc1a5c000 - 0xc1ad3000   ( 476 kB)
> [    0.000000]       .data : 0xc1747a8a - 0xc1a5b6b8   (3151 kB)
> [    0.000000]       .text : 0xc1000000 - 0xc1747a8a   (7454 kB)
> [    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
> [    0.000000] Experimental preemptable hierarchical RCU implementation.
> [    0.000000] NR_IRQS:320
> [    0.000000] Extended CMOS year: 2000
> [    0.000000] Console: colour VGA+ 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] hpet clockevent registered
> [    0.000000] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
> [    0.000000] Fast TSC calibration using PIT
> [    0.000000] Detected 1795.523 MHz processor.
> [    0.001005] Calibrating delay loop (skipped), value calculated using timer frequency.. 3591.04 BogoMIPS (lpj=1795523)
> [    0.001044] Security Framework initialized
> [    0.001051] SELinux:  Disabled at boot.
> [    0.001067] Mount-cache hash table entries: 512
> [    0.001182] Initializing cgroup subsys debug
> [    0.001185] Initializing cgroup subsys ns
> [    0.001188] Initializing cgroup subsys cpuacct
> [    0.001191] Initializing cgroup subsys memory
> [    0.001197] Initializing cgroup subsys devices
> [    0.001199] Initializing cgroup subsys freezer
> [    0.001223] CPU: L1 I cache: 32K, L1 D cache: 32K
> [    0.001225] CPU: L2 cache: 4096K
> [    0.001228] CPU: Physical Processor ID: 0
> [    0.001229] CPU: Processor Core ID: 0
> [    0.001233] mce: CPU supports 6 MCE banks
> [    0.001240] CPU0: Thermal monitoring enabled (TM2)
> [    0.001244] using mwait in idle threads.
> [    0.001250] Performance Events: Core2 events, Intel PMU driver.
> [    0.001255] ... version:                2
> [    0.001257] ... bit width:              40
> [    0.001258] ... generic registers:      2
> [    0.001260] ... value mask:             000000ffffffffff
> [    0.001261] ... max period:             000000007fffffff
> [    0.001263] ... fixed-purpose events:   3
> [    0.001264] ... event mask:             0000000700000003
> [    0.001268] Checking 'hlt' instruction... OK.
> [    0.005985] ACPI: Core revision 20090903
> [    0.026451] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.036743] CPU0: Intel(R) Core(TM)2 Duo CPU     L7700  @ 1.80GHz stepping 0b
> [    0.037015] Booting processor 1 APIC 0x1 ip 0x6000
> [    0.001999] Initializing CPU#1
> [    0.001999] CPU: L1 I cache: 32K, L1 D cache: 32K
> [    0.001999] CPU: L2 cache: 4096K
> [    0.001999] CPU: Physical Processor ID: 0
> [    0.001999] CPU: Processor Core ID: 1
> [    0.001999] CPU1: Thermal monitoring enabled (TM2)
> [    0.108101] CPU1: Intel(R) Core(TM)2 Duo CPU     L7700  @ 1.80GHz stepping 0b
> [    0.108114] checking TSC synchronization [CPU#0 -> CPU#1]:
> [    0.108983] Measured 924102 cycles TSC warp between CPUs, turning off TSC clock.
> [    0.108983] Marking TSC unstable due to check_tsc_sync_source failed
> [    0.109007] Brought up 2 CPUs
> [    0.109010] Total of 2 processors activated (7181.87 BogoMIPS).
> [    0.109628] CPU0 attaching sched-domain:
> [    0.109632]  domain 0: span 0-1 level MC
> [    0.109634]   groups: 0 1
> [    0.109640] CPU1 attaching sched-domain:
> [    0.109643]  domain 0: span 0-1 level MC
> [    0.109645]   groups: 1 0
> [    0.111209] regulator: core version 0.5
> [    0.111230] NET: Registered protocol family 16
> [    0.112014] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
> [    0.112014] ACPI: bus type pci registered
> [    0.112028] PCI: MCFG configuration 0: base f0000000 segment 0 buses 0 - 63
> [    0.112028] PCI: MCFG area at f0000000 reserved in E820
> [    0.112028] PCI: Using MMCONFIG for extended config space
> [    0.112028] PCI: Using configuration type 1 for base access
> [    0.122054] bio: create slab <bio-0> at 0
> [    0.125498] ACPI: EC: EC description table is found, configuring boot EC
> [    0.132054] ACPI: BIOS _OSI(Linux) query honored via DMI
> [    0.140805] ACPI: Interpreter enabled
> [    0.140812] ACPI: (supports S0 S3 S5)
> [    0.140833] ACPI: Using IOAPIC for interrupt routing
> [    0.152185] ACPI: EC: GPE = 0x12, I/O: command/status = 0x66, data = 0x62
> [    0.152185] ACPI: Power Resource [PUBS] (on)
> [    0.155176] ACPI: ACPI Dock Station Driver: 3 docks/bays found
> [    0.155569] ACPI: PCI Root Bridge [PCI0] (0000:00)
> [    0.155608] pci 0000:00:02.0: reg 10 64bit mmio: [0xf8000000-0xf80fffff]
> [    0.155608] pci 0000:00:02.0: reg 18 64bit mmio pref: [0xe0000000-0xefffffff]
> [    0.155608] pci 0000:00:02.0: reg 20 io port: [0x1800-0x1807]
> [    0.155608] pci 0000:00:02.1: reg 10 64bit mmio: [0xf8100000-0xf81fffff]
> [    0.155990] pci 0000:00:19.0: reg 10 32bit mmio: [0xf8200000-0xf821ffff]
> [    0.156006] pci 0000:00:19.0: reg 14 32bit mmio: [0xf8225000-0xf8225fff]
> [    0.156023] pci 0000:00:19.0: reg 18 io port: [0x1840-0x185f]
> [    0.156154] pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
> [    0.156163] pci 0000:00:19.0: PME# disabled
> [    0.156295] pci 0000:00:1a.0: reg 20 io port: [0x1860-0x187f]
> [    0.156454] pci 0000:00:1a.1: reg 20 io port: [0x1880-0x189f]
> [    0.156609] pci 0000:00:1a.7: reg 10 32bit mmio: [0xf8426c00-0xf8426fff]
> [    0.156754] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
> [    0.156764] pci 0000:00:1a.7: PME# disabled
> [    0.156884] pci 0000:00:1b.0: reg 10 64bit mmio: [0xf8220000-0xf8223fff]
> [    0.157042] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
> [    0.157051] pci 0000:00:1b.0: PME# disabled
> [    0.157277] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
> [    0.157287] pci 0000:00:1c.0: PME# disabled
> [    0.157520] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
> [    0.157527] pci 0000:00:1c.1: PME# disabled
> [    0.157695] pci 0000:00:1d.0: reg 20 io port: [0x18a0-0x18bf]
> [    0.157856] pci 0000:00:1d.1: reg 20 io port: [0x18c0-0x18df]
> [    0.158035] pci 0000:00:1d.7: reg 10 32bit mmio: [0xf8427000-0xf84273ff]
> [    0.158192] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
> [    0.158202] pci 0000:00:1d.7: PME# disabled
> [    0.158584] pci 0000:00:1f.0: quirk: region 1000-107f claimed by ICH6 ACPI/GPIO/TCO
> [    0.158591] pci 0000:00:1f.0: quirk: region 1180-11bf claimed by ICH6 GPIO
> [    0.158598] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 1600 (mask 007f)
> [    0.158605] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 15e0 (mask 000f)
> [    0.158611] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 1680 (mask 001f)
> [    0.158723] pci 0000:00:1f.1: reg 10 io port: [0x00-0x07]
> [    0.158740] pci 0000:00:1f.1: reg 14 io port: [0x00-0x03]
> [    0.158758] pci 0000:00:1f.1: reg 18 io port: [0x00-0x07]
> [    0.158775] pci 0000:00:1f.1: reg 1c io port: [0x00-0x03]
> [    0.158792] pci 0000:00:1f.1: reg 20 io port: [0x18e0-0x18ef]
> [    0.158982] pci 0000:00:1f.2: reg 10 io port: [0x1c30-0x1c37]
> [    0.158999] pci 0000:00:1f.2: reg 14 io port: [0x1c24-0x1c27]
> [    0.159017] pci 0000:00:1f.2: reg 18 io port: [0x1c28-0x1c2f]
> [    0.159034] pci 0000:00:1f.2: reg 1c io port: [0x1c20-0x1c23]
> [    0.159051] pci 0000:00:1f.2: reg 20 io port: [0x1c00-0x1c1f]
> [    0.159069] pci 0000:00:1f.2: reg 24 32bit mmio: [0xf8426000-0xf84267ff]
> [    0.159178] pci 0000:00:1f.2: PME# supported from D3hot
> [    0.159188] pci 0000:00:1f.2: PME# disabled
> [    0.159265] pci 0000:00:1f.3: reg 10 32bit mmio: [0xf8427400-0xf84274ff]
> [    0.159325] pci 0000:00:1f.3: reg 20 io port: [0x1c40-0x1c5f]
> [    0.159534] pci 0000:00:1c.0: bridge io port: [0x2000-0x2fff]
> [    0.159543] pci 0000:00:1c.0: bridge 32bit mmio: [0xf4000000-0xf5ffffff]
> [    0.159559] pci 0000:00:1c.0: bridge 64bit mmio pref: [0xf8500000-0xf85fffff]
> [    0.159709] pci 0000:03:00.0: reg 10 64bit mmio: [0xf7f00000-0xf7f01fff]
> [    0.159859] pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
> [    0.159871] pci 0000:03:00.0: PME# disabled
> [    0.160029] pci 0000:00:1c.1: bridge io port: [0x3000-0x3fff]
> [    0.160039] pci 0000:00:1c.1: bridge 32bit mmio: [0xf6000000-0xf7ffffff]
> [    0.160056] pci 0000:00:1c.1: bridge 64bit mmio pref: [0xf8600000-0xf86fffff]
> [    0.160154] pci 0000:05:00.0: reg 10 32bit mmio: [0xd7eff000-0xd7efffff]
> [    0.160210] pci 0000:05:00.0: supports D1 D2
> [    0.160212] pci 0000:05:00.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.160222] pci 0000:05:00.0: PME# disabled
> [    0.160324] pci 0000:05:00.1: reg 10 32bit mmio: [0xd7efe800-0xd7efefff]
> [    0.160473] pci 0000:05:00.1: supports D1 D2
> [    0.160476] pci 0000:05:00.1: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.160486] pci 0000:05:00.1: PME# disabled
> [    0.160587] pci 0000:05:00.2: reg 10 32bit mmio: [0xd7efe400-0xd7efe4ff]
> [    0.160736] pci 0000:05:00.2: supports D1 D2
> [    0.160739] pci 0000:05:00.2: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.160749] pci 0000:05:00.2: PME# disabled
> [    0.160903] pci 0000:00:1e.0: transparent bridge
> [    0.160913] pci 0000:00:1e.0: bridge io port: [0x4000-0x7fff]
> [    0.160923] pci 0000:00:1e.0: bridge 32bit mmio: [0xd4000000-0xd7efffff]
> [    0.160941] pci 0000:00:1e.0: bridge 64bit mmio pref: [0xd8000000-0xdbffffff]
> [    0.161039] pci_bus 0000:00: on NUMA node 0
> [    0.161044] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> [    0.161216] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP0._PRT]
> [    0.161289] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP1._PRT]
> [    0.161373] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCI1._PRT]
> [    0.168125] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 *10 11)
> [    0.168333] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 *11)
> [    0.168537] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 *11)
> [    0.168740] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 *11)
> [    0.169098] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 *11)
> [    0.169301] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 *11)
> [    0.169504] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 *11)
> [    0.169706] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 *11)
> [    0.169805] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
> [    0.169805] vgaarb: loaded
> [    0.170079] SCSI subsystem initialized
> [    0.171991] libata version 3.00 loaded.
> [    0.172012] usbcore: registered new interface driver usbfs
> [    0.172012] usbcore: registered new interface driver hub
> [    0.172013] usbcore: registered new device driver usb
> [    0.172013] PCI: Using ACPI for IRQ routing
> [    0.172238] NET: Registered protocol family 23
> [    0.172238] Bluetooth: Core ver 2.15
> [    0.172986] NET: Registered protocol family 31
> [    0.172986] Bluetooth: HCI device and connection manager initialized
> [    0.172986] Bluetooth: HCI socket layer initialized
> [    0.173017] cfg80211: Using static regulatory domain info
> [    0.173017] cfg80211: Regulatory domain: US
> [    0.173017] 	(start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
> [    0.173017] 	(2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, 2700 mBm)
> [    0.173017] 	(5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
> [    0.173017] 	(5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
> [    0.173017] 	(5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
> [    0.173017] 	(5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
> [    0.173017] 	(5735000 KHz - 5835000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
> [    0.173017] cfg80211: Calling CRDA for country: US
> [    0.173024] NetLabel: Initializing
> [    0.173024] NetLabel:  domain hash size = 128
> [    0.173024] NetLabel:  protocols = UNLABELED CIPSOv4
> [    0.173024] NetLabel:  unlabeled traffic allowed by default
> [    0.173990] Switching to clocksource hpet
> [    0.178279] pnp: PnP ACPI init
> [    0.178289] ACPI: bus type pnp registered
> [    0.182336] pnp: PnP ACPI: found 11 devices
> [    0.182338] ACPI: ACPI bus type pnp unregistered
> [    0.182349] system 00:00: iomem range 0x0-0x9ffff could not be reserved
> [    0.182353] system 00:00: iomem range 0xc0000-0xc3fff could not be reserved
> [    0.182357] system 00:00: iomem range 0xc4000-0xc7fff could not be reserved
> [    0.182360] system 00:00: iomem range 0xc8000-0xcbfff has been reserved
> [    0.182363] system 00:00: iomem range 0xcc000-0xcffff has been reserved
> [    0.182366] system 00:00: iomem range 0xe0000-0xe3fff could not be reserved
> [    0.182370] system 00:00: iomem range 0xe4000-0xe7fff could not be reserved
> [    0.182373] system 00:00: iomem range 0xe8000-0xebfff could not be reserved
> [    0.182376] system 00:00: iomem range 0xec000-0xeffff could not be reserved
> [    0.182379] system 00:00: iomem range 0xf0000-0xfffff could not be reserved
> [    0.182383] system 00:00: iomem range 0x100000-0xbfffffff could not be reserved
> [    0.182386] system 00:00: iomem range 0xfec00000-0xfed3ffff could not be reserved
> [    0.182390] system 00:00: iomem range 0xfed4c000-0xffffffff could not be reserved
> [    0.182398] system 00:02: ioport range 0x164e-0x164f has been reserved
> [    0.182402] system 00:02: ioport range 0x1000-0x107f has been reserved
> [    0.182405] system 00:02: ioport range 0x1180-0x11bf has been reserved
> [    0.182408] system 00:02: ioport range 0x800-0x80f has been reserved
> [    0.182411] system 00:02: ioport range 0x15e0-0x15ef has been reserved
> [    0.182414] system 00:02: ioport range 0x1600-0x165f could not be reserved
> [    0.182418] system 00:02: iomem range 0xf0000000-0xf3ffffff has been reserved
> [    0.182421] system 00:02: iomem range 0xfed1c000-0xfed1ffff has been reserved
> [    0.182425] system 00:02: iomem range 0xfed14000-0xfed17fff has been reserved
> [    0.182428] system 00:02: iomem range 0xfed18000-0xfed18fff has been reserved
> [    0.182431] system 00:02: iomem range 0xfed19000-0xfed19fff has been reserved
> [    0.182435] system 00:02: iomem range 0xfed45000-0xfed4bfff has been reserved
> [    0.219681] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:02
> [    0.219687] pci 0000:00:1c.0:   IO window: 0x2000-0x2fff
> [    0.219699] pci 0000:00:1c.0:   MEM window: 0xf4000000-0xf5ffffff
> [    0.219709] pci 0000:00:1c.0:   PREFETCH window: 0x000000f8500000-0x000000f85fffff
> [    0.219727] pci 0000:00:1c.1: PCI bridge, secondary bus 0000:03
> [    0.219733] pci 0000:00:1c.1:   IO window: 0x3000-0x3fff
> [    0.219746] pci 0000:00:1c.1:   MEM window: 0xf6000000-0xf7ffffff
> [    0.219756] pci 0000:00:1c.1:   PREFETCH window: 0x000000f8600000-0x000000f86fffff
> [    0.219777] pci 0000:05:00.0: CardBus bridge, secondary bus 0000:06
> [    0.219780] pci 0000:05:00.0:   IO window: 0x004000-0x0040ff
> [    0.219788] pci 0000:05:00.0:   IO window: 0x004400-0x0044ff
> [    0.219798] pci 0000:05:00.0:   PREFETCH window: 0xd8000000-0xdbffffff
> [    0.219808] pci 0000:05:00.0:   MEM window: 0xc0000000-0xc3ffffff
> [    0.219818] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:05
> [    0.219824] pci 0000:00:1e.0:   IO window: 0x4000-0x7fff
> [    0.219838] pci 0000:00:1e.0:   MEM window: 0xd4000000-0xd7efffff
> [    0.219848] pci 0000:00:1e.0:   PREFETCH window: 0x000000d8000000-0x000000dbffffff
> [    0.219886] pci 0000:00:1c.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
> [    0.219896] pci 0000:00:1c.0: setting latency timer to 64
> [    0.219919] pci 0000:00:1c.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
> [    0.219927] pci 0000:00:1c.1: setting latency timer to 64
> [    0.219938] pci 0000:00:1e.0: enabling device (0005 -> 0007)
> [    0.219951] pci 0000:00:1e.0: setting latency timer to 64
> [    0.219973] pci 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> [    0.219985] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
> [    0.219987] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
> [    0.219990] pci_bus 0000:02: resource 0 io:  [0x2000-0x2fff]
> [    0.219993] pci_bus 0000:02: resource 1 mem: [0xf4000000-0xf5ffffff]
> [    0.219996] pci_bus 0000:02: resource 2 pref mem [0xf8500000-0xf85fffff]
> [    0.219999] pci_bus 0000:03: resource 0 io:  [0x3000-0x3fff]
> [    0.220002] pci_bus 0000:03: resource 1 mem: [0xf6000000-0xf7ffffff]
> [    0.220017] pci_bus 0000:03: resource 2 pref mem [0xf8600000-0xf86fffff]
> [    0.220020] pci_bus 0000:05: resource 0 io:  [0x4000-0x7fff]
> [    0.220023] pci_bus 0000:05: resource 1 mem: [0xd4000000-0xd7efffff]
> [    0.220025] pci_bus 0000:05: resource 2 pref mem [0xd8000000-0xdbffffff]
> [    0.220028] pci_bus 0000:05: resource 3 io:  [0x00-0xffff]
> [    0.220031] pci_bus 0000:05: resource 4 mem: [0x000000-0xffffffffffffffff]
> [    0.220034] pci_bus 0000:06: resource 0 io:  [0x4000-0x40ff]
> [    0.220036] pci_bus 0000:06: resource 1 io:  [0x4400-0x44ff]
> [    0.220039] pci_bus 0000:06: resource 2 pref mem [0xd8000000-0xdbffffff]
> [    0.220041] pci_bus 0000:06: resource 3 mem: [0xc0000000-0xc3ffffff]
> [    0.220115] NET: Registered protocol family 2
> [    0.220227] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
> [    0.220581] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
> [    0.220926] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
> [    0.221120] TCP: Hash tables configured (established 131072 bind 65536)
> [    0.221123] TCP reno registered
> [    0.221217] NET: Registered protocol family 1
> [    0.223081] RPC: Registered udp transport module.
> [    0.223083] RPC: Registered tcp transport module.
> [    0.223085] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [    0.223095] pci 0000:00:02.0: Boot video device
> [    0.223308] Trying to unpack rootfs image as initramfs...
> [    0.264622] Freeing initrd memory: 1484k freed
> [    0.265286] Simple Boot Flag at 0x35 set to 0x1
> [    0.266392] cpu0(2) debug files 152
> [    0.269405] cpu1(2) debug files 152
> [    0.269972] microcode: CPU0 sig=0x6fb, pf=0x80, revision=0xb6
> [    0.269984] microcode: CPU1 sig=0x6fb, pf=0x80, revision=0xb6
> [    0.270054] Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
> [    0.270057] Scanning for low memory corruption every 60 seconds
> [    0.270503] audit: initializing netlink socket (disabled)
> [    0.270515] type=2000 audit(1265476886.270:1): initialized
> [    0.270755] highmem bounce pool size: 64 pages
> [    0.273019] VFS: Disk quotas dquot_6.5.2
> [    0.273061] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
> [    0.273299] DLM (built Feb  4 2010 21:32:56) installed
> [    0.273520] squashfs: version 4.0 (2009/01/31) Phillip Lougher
> [    0.273711] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> [    0.273978] Slow work thread pool: Starting up
> [    0.274033] Slow work thread pool: Ready
> [    0.274035] NTFS driver 2.1.29 [Flags: R/W].
> [    0.274096] ROMFS MTD (C) 2007 Red Hat, Inc.
> [    0.274115] fuse init (API version 7.13)
> [    0.274312] msgmni has been set to 1625
> [    0.277050] alg: No test for cipher_null (cipher_null-generic)
> [    0.277083] alg: No test for ecb(cipher_null) (ecb-cipher_null)
> [    0.277112] alg: No test for digest_null (digest_null-generic)
> [    0.277141] alg: No test for compress_null (compress_null-generic)
> [    0.280361] alg: No test for stdrng (krng)
> [    0.287375] alg: No test for ghash (ghash-generic)
> [    0.287388] io scheduler noop registered
> [    0.287390] io scheduler anticipatory registered
> [    0.287392] io scheduler deadline registered
> [    0.287419] io scheduler cfq registered (default)
> [    0.287720] pcieport 0000:00:1c.0: irq 24 for MSI/MSI-X
> [    0.287747] pcieport 0000:00:1c.0: setting latency timer to 64
> [    0.288224] pcieport 0000:00:1c.1: irq 25 for MSI/MSI-X
> [    0.288249] pcieport 0000:00:1c.1: setting latency timer to 64
> [    0.289119] ACPI: AC Adapter [AC] (on-line)
> [    0.289284] input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input0
> [    0.289481] ACPI: Lid Switch [LID]
> [    0.289565] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input1
> [    0.289574] ACPI: Sleep Button [SLPB]
> [    0.289665] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
> [    0.289668] ACPI: Power Button [PWRF]
> [    0.290248] ACPI: SSDT bf6e1b32 00282 (v01  PmRef  Cpu0Ist 00000100 INTL 20050513)
> [    0.290969] ACPI: SSDT bf6e1e39 0085E (v01  PmRef  Cpu0Cst 00000100 INTL 20050513)
> [    0.294023] Monitor-Mwait will be used to enter C-1 state
> [    0.295022] Monitor-Mwait will be used to enter C-2 state
> [    0.296022] Monitor-Mwait will be used to enter C-3 state
> [    0.296142] processor LNXCPU:00: registered as cooling_device0
> [    0.296502] ACPI: SSDT bf6e1a6a 000C8 (v01  PmRef  Cpu1Ist 00000100 INTL 20050513)
> [    0.296975] ACPI: SSDT bf6e1db4 00085 (v01  PmRef  Cpu1Cst 00000100 INTL 20050513)
> [    0.298694] processor LNXCPU:01: registered as cooling_device1
> [    0.303866] thermal LNXTHERM:01: registered as thermal_zone0
> [    0.303874] ACPI: Thermal Zone [THM0] (67 C)
> [    0.305513] thermal LNXTHERM:02: registered as thermal_zone1
> [    0.305522] ACPI: Thermal Zone [THM1] (67 C)
> [    0.316432] ACPI: Battery Slot [BAT0] (battery present)
> [    0.349266] Non-volatile memory driver v1.3
> [    0.349355] Linux agpgart interface v0.103
> [    0.349371] agpgart-intel 0000:00:00.0: Intel 965GM Chipset
> [    0.350650] agpgart-intel 0000:00:00.0: detected 7676K stolen memory
> [    0.355710] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xe0000000
> [    0.355776] Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 seconds, margin is 60 seconds).
> [    0.355779] Hangcheck: Using get_cycles().
> [    0.355845] [drm] Initialized drm 1.1.0 20060810
> [    0.355922] i915 0000:00:02.0: power state changed by ACPI to D0
> [    0.355929] i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> [    0.355934] i915 0000:00:02.0: setting latency timer to 64
> [    0.357195] mtrr: type mismatch for e0000000,10000000 old: write-back new: write-combining
> [    0.357198] [drm] MTRR allocation failed.  Graphics performance may suffer.
> [    0.357298] i915 0000:00:02.0: irq 26 for MSI/MSI-X
> [    0.357305] [drm] set up 7M of stolen space
> [    0.992597] [drm] LVDS-8: set mode 1024x768 c
> [    1.081420] Console: switching to colour frame buffer device 128x48
> [    1.103621] fb0: inteldrmfb frame buffer device
> [    1.103623] registered panic notifier
> [    1.106087] acpi device:01: registered as cooling_device2
> [    1.106356] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:00/input/input3
> [    1.106364] ACPI: Video Device [VID] (multi-head: yes  rom: no  post: no)
> [    1.106448] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
> [    1.106518] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> [    4.118058] floppy0: no floppy controllers found
> [    4.120435] brd: module loaded
> [    4.121572] loop: module loaded
> [    4.121846] nbd: registered device at major 43
> [    4.124535] ahci 0000:00:1f.2: version 3.0
> [    4.124560] ahci 0000:00:1f.2: PCI INT B -> GSI 16 (level, low) -> IRQ 16
> [    4.124644] ahci 0000:00:1f.2: irq 27 for MSI/MSI-X
> [    4.124722] ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 3 ports 1.5 Gbps 0x5 impl SATA mode
> [    4.124726] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ccc 
> [    4.124737] ahci 0000:00:1f.2: setting latency timer to 64
> [    4.124904] scsi0 : ahci
> [    4.125097] scsi1 : ahci
> [    4.125239] scsi2 : ahci
> [    4.125418] ata1: SATA max UDMA/133 abar m2048@0xf8426000 port 0xf8426100 irq 27
> [    4.125421] ata2: DUMMY
> [    4.125426] ata3: SATA max UDMA/133 abar m2048@0xf8426000 port 0xf8426200 irq 27
> [    4.125494] ata_piix 0000:00:1f.1: version 2.13
> [    4.125505] ata_piix 0000:00:1f.1: PCI INT C -> GSI 16 (level, low) -> IRQ 16
> [    4.125551] ata_piix 0000:00:1f.1: setting latency timer to 64
> [    4.125663] scsi3 : ata_piix
> [    4.125797] scsi4 : ata_piix
> [    4.126645] ata4: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x18e0 irq 14
> [    4.126649] ata5: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x18e8 irq 15
> [    4.126706] PPP generic driver version 2.4.2
> [    4.126830] PPP Deflate Compression module registered
> [    4.126835] PPP BSD Compression module registered
> [    4.127065] ata5: port disabled. ignoring.
> [    4.127175] PPP MPPE Compression module registered
> [    4.127178] NET: Registered protocol family 24
> [    4.127192] PPPoL2TP kernel driver, V1.0
> [    4.127195] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=256) (6 bit encapsulation enabled).
> [    4.127197] CSLIP: code copyright 1989 Regents of the University of California.
> [    4.127199] SLIP linefill/keepalive option.
> [    4.127202] tun: Universal TUN/TAP device driver, 1.6
> [    4.127204] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
> [    4.127323] usbcore: registered new interface driver cdc_ether
> [    4.127368] usbcore: registered new interface driver rndis_host
> [    4.127420] usbcore: registered new interface driver irda-usb
> [    4.127424] USB IrDA support registered
> [    4.127473] yenta_cardbus 0000:05:00.0: CardBus bridge found [17aa:20c6]
> [    4.430041] ata3: SATA link down (SStatus 0 SControl 300)
> [    4.430070] ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> [    4.431143] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) succeeded
> [    4.431147] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZE LOCK) filtered out
> [    4.431151] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filtered out
> [    4.431945] ata1.00: ATA-7: ST9120822AS, 3.ALC, max UDMA/133
> [    4.431948] ata1.00: 234441648 sectors, multi 16: LBA48 NCQ (depth 31/32)
> [    4.433123] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) succeeded
> [    4.433127] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZE LOCK) filtered out
> [    4.433130] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filtered out
> [    4.433998] ata1.00: configured for UDMA/133
> [    4.446930] ata1.00: configured for UDMA/133
> [    4.446933] ata1: EH complete
> [    4.447047] scsi 0:0:0:0: Direct-Access     ATA      ST9120822AS      3.AL PQ: 0 ANSI: 5
> [    4.447387] sd 0:0:0:0: Attached scsi generic sg0 type 0
> [    4.447423] sd 0:0:0:0: [sda] 234441648 512-byte logical blocks: (120 GB/111 GiB)
> [    4.447474] sd 0:0:0:0: [sda] Write Protect is off
> [    4.447477] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> [    4.447502] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [    4.447632]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 >
> [    4.483593] sd 0:0:0:0: [sda] Attached SCSI disk
> [    4.605880] yenta_cardbus 0000:05:00.0: ISA IRQ mask 0x0cb8, PCI irq 16
> [    4.605886] yenta_cardbus 0000:05:00.0: Socket status: 30000006
> [    4.605891] yenta_cardbus 0000:05:00.0: pcmcia: parent PCI bridge I/O window: 0x4000 - 0x7fff
> [    4.605894] yenta_cardbus 0000:05:00.0: pcmcia: parent PCI bridge Memory window: 0xd4000000 - 0xd7efffff
> [    4.605897] yenta_cardbus 0000:05:00.0: pcmcia: parent PCI bridge Memory window: 0xd8000000 - 0xdbffffff
> [    4.857330] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [    4.857552] ehci_hcd 0000:00:1a.7: power state changed by ACPI to D0
> [    4.857567] ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 22 (level, low) -> IRQ 22
> [    4.857582] ehci_hcd 0000:00:1a.7: setting latency timer to 64
> [    4.857588] ehci_hcd 0000:00:1a.7: EHCI Host Controller
> [    4.857678] ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
> [    4.861618] ehci_hcd 0000:00:1a.7: cache line size of 32 is not supported
> [    4.861634] ehci_hcd 0000:00:1a.7: irq 22, io mem 0xf8426c00
> [    4.871024] ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
> [    4.871046] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
> [    4.871048] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    4.871051] usb usb1: Product: EHCI Host Controller
> [    4.871053] usb usb1: Manufacturer: Linux 2.6.32.7 ehci_hcd
> [    4.871055] usb usb1: SerialNumber: 0000:00:1a.7
> [    4.871158] usb usb1: configuration #1 chosen from 1 choice
> [    4.871223] hub 1-0:1.0: USB hub found
> [    4.871232] hub 1-0:1.0: 4 ports detected
> [    4.871530] ehci_hcd 0000:00:1d.7: power state changed by ACPI to D0
> [    4.871545] ehci_hcd 0000:00:1d.7: PCI INT D -> GSI 19 (level, low) -> IRQ 19
> [    4.871560] ehci_hcd 0000:00:1d.7: setting latency timer to 64
> [    4.871566] ehci_hcd 0000:00:1d.7: EHCI Host Controller
> [    4.871647] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
> [    4.871690] ehci_hcd 0000:00:1d.7: debug port 1
> [    4.875599] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
> [    4.875615] ehci_hcd 0000:00:1d.7: irq 19, io mem 0xf8427000
> [    4.885028] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
> [    4.885045] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
> [    4.885048] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    4.885051] usb usb2: Product: EHCI Host Controller
> [    4.885053] usb usb2: Manufacturer: Linux 2.6.32.7 ehci_hcd
> [    4.885055] usb usb2: SerialNumber: 0000:00:1d.7
> [    4.885161] usb usb2: configuration #1 chosen from 1 choice
> [    4.885230] hub 2-0:1.0: USB hub found
> [    4.885237] hub 2-0:1.0: 4 ports detected
> [    4.885388] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> [    4.885438] uhci_hcd: USB Universal Host Controller Interface driver
> [    4.885472] uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
> [    4.885483] uhci_hcd 0000:00:1a.0: setting latency timer to 64
> [    4.885489] uhci_hcd 0000:00:1a.0: UHCI Host Controller
> [    4.885565] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
> [    4.885609] uhci_hcd 0000:00:1a.0: irq 20, io base 0x00001860
> [    4.885648] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
> [    4.885650] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    4.885653] usb usb3: Product: UHCI Host Controller
> [    4.885655] usb usb3: Manufacturer: Linux 2.6.32.7 uhci_hcd
> [    4.885657] usb usb3: SerialNumber: 0000:00:1a.0
> [    4.885751] usb usb3: configuration #1 chosen from 1 choice
> [    4.885813] hub 3-0:1.0: USB hub found
> [    4.885820] hub 3-0:1.0: 2 ports detected
> [    4.886084] uhci_hcd 0000:00:1a.1: power state changed by ACPI to D0
> [    4.886093] uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
> [    4.886104] uhci_hcd 0000:00:1a.1: setting latency timer to 64
> [    4.886110] uhci_hcd 0000:00:1a.1: UHCI Host Controller
> [    4.886202] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
> [    4.886248] uhci_hcd 0000:00:1a.1: irq 21, io base 0x00001880
> [    4.886287] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
> [    4.886290] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    4.886292] usb usb4: Product: UHCI Host Controller
> [    4.886294] usb usb4: Manufacturer: Linux 2.6.32.7 uhci_hcd
> [    4.886297] usb usb4: SerialNumber: 0000:00:1a.1
> [    4.886389] usb usb4: configuration #1 chosen from 1 choice
> [    4.886451] hub 4-0:1.0: USB hub found
> [    4.886458] hub 4-0:1.0: 2 ports detected
> [    4.886752] uhci_hcd 0000:00:1d.0: power state changed by ACPI to D0
> [    4.886761] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> [    4.886772] uhci_hcd 0000:00:1d.0: setting latency timer to 64
> [    4.886777] uhci_hcd 0000:00:1d.0: UHCI Host Controller
> [    4.886858] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 5
> [    4.886894] uhci_hcd 0000:00:1d.0: irq 16, io base 0x000018a0
> [    4.886930] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
> [    4.886933] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    4.886936] usb usb5: Product: UHCI Host Controller
> [    4.886938] usb usb5: Manufacturer: Linux 2.6.32.7 uhci_hcd
> [    4.886940] usb usb5: SerialNumber: 0000:00:1d.0
> [    4.887067] usb usb5: configuration #1 chosen from 1 choice
> [    4.887132] hub 5-0:1.0: USB hub found
> [    4.887139] hub 5-0:1.0: 2 ports detected
> [    4.887246] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
> [    4.887258] uhci_hcd 0000:00:1d.1: setting latency timer to 64
> [    4.887262] uhci_hcd 0000:00:1d.1: UHCI Host Controller
> [    4.887338] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 6
> [    4.887379] uhci_hcd 0000:00:1d.1: irq 17, io base 0x000018c0
> [    4.887415] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
> [    4.887417] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    4.887420] usb usb6: Product: UHCI Host Controller
> [    4.887422] usb usb6: Manufacturer: Linux 2.6.32.7 uhci_hcd
> [    4.887424] usb usb6: SerialNumber: 0000:00:1d.1
> [    4.887516] usb usb6: configuration #1 chosen from 1 choice
> [    4.887580] hub 6-0:1.0: USB hub found
> [    4.887587] hub 6-0:1.0: 2 ports detected
> [    4.887743] sl811: driver sl811-hcd, 19 May 2005
> [    4.887881] usbcore: registered new interface driver cdc_acm
> [    4.887885] cdc_acm: v0.26:USB Abstract Control Model driver for USB modems and ISDN adapters
> [    4.887935] usbcore: registered new interface driver usblp
> [    4.887984] usbcore: registered new interface driver cdc_wdm
> [    4.887987] Initializing USB Mass Storage driver...
> [    4.888071] usbcore: registered new interface driver usb-storage
> [    4.888074] USB Mass Storage support registered.
> [    4.888140] usbcore: registered new interface driver libusual
> [    4.888188] usbcore: registered new interface driver ums-alauda
> [    4.888238] usbcore: registered new interface driver ums-datafab
> [    4.888298] usbcore: registered new interface driver ums-freecom
> [    4.888346] usbcore: registered new interface driver ums-isd200
> [    4.888392] usbcore: registered new interface driver ums-jumpshot
> [    4.888439] usbcore: registered new interface driver ums-karma
> [    4.888486] usbcore: registered new interface driver ums-onetouch
> [    4.888533] usbcore: registered new interface driver ums-sddr09
> [    4.888580] usbcore: registered new interface driver ums-sddr55
> [    4.888628] usbcore: registered new interface driver ums-usbat
> [    4.888678] usbcore: registered new interface driver berry_charge
> [    4.888797] PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
> [    4.900359] serio: i8042 KBD port at 0x60,0x64 irq 1
> [    4.900365] serio: i8042 AUX port at 0x60,0x64 irq 12
> [    4.900591] mice: PS/2 mouse device common for all mice
> [    4.901067] i2c /dev entries driver
> [    4.901306] i801_smbus 0000:00:1f.3: PCI INT A -> GSI 23 (level, low) -> IRQ 23
> [    4.901493] Linux video capture interface: v2.00
> [    4.901537] gspca: main v2.7.0 registered
> [    4.902236] device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initialised: dm-devel@redhat.com
> [    4.904334] device-mapper: multipath: version 1.1.0 loaded
> [    4.904337] device-mapper: multipath round-robin: version 1.0.0 loaded
> [    4.904410] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
> [    4.904458] EDAC MC: Ver: 2.1.0 Feb  4 2010
> [    4.907489] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input4
> [    4.908386] cpuidle: using governor ladder
> [    4.909167] cpuidle: using governor menu
> [    4.909365] sdhci: Secure Digital Host Controller Interface driver
> [    4.909367] sdhci: Copyright(c) Pierre Ossman
> [    4.909385] sdhci-pci 0000:05:00.2: SDHCI controller found [1180:0822] (rev 21)
> [    4.909419] sdhci-pci 0000:05:00.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
> [    4.910439] sdhci-pci 0000:05:00.2: Will use DMA mode even though HW doesn't fully claim to support it.
> [    4.910450] sdhci-pci 0000:05:00.2: setting latency timer to 64
> [    4.911608] Registered led device: mmc0::
> [    4.912766] mmc0: SDHCI controller on PCI [0000:05:00.2] using DMA
> [    4.912870] ricoh-mmc: Ricoh MMC Controller disabling driver
> [    4.912872] ricoh-mmc: Copyright(c) Philip Langdale
> [    4.912972] wbsd: Winbond W83L51xD SD/MMC card interface driver
> [    4.912974] wbsd: Copyright(c) Pierre Ossman
> [    4.918841] wacom driver registered
> [    4.919292] usbcore: registered new interface driver hiddev
> [    4.919415] usbcore: registered new interface driver usbhid
> [    4.919418] usbhid: v2.6:USB HID core driver
> [    4.920050] thinkpad_acpi: ThinkPad ACPI Extras v0.23
> [    4.920053] thinkpad_acpi: http://ibm-acpi.sf.net/
> [    4.920055] thinkpad_acpi: ThinkPad BIOS 7NETB9WW (2.19 ), EC 7MHT25WW-1.03
> [    4.920057] thinkpad_acpi: Lenovo ThinkPad X61s, model 7666B4G
> [    4.920353] thinkpad_acpi: radio switch found; radios are enabled
> [    4.920464] thinkpad_acpi: This ThinkPad has standard ACPI backlight brightness control, supported by the ACPI video driver
> [    4.920466] thinkpad_acpi: Disabling thinkpad-acpi brightness events by default...
> [    4.926615] Registered led device: tpacpi::thinklight
> [    4.926759] Registered led device: tpacpi::power
> [    4.926885] Registered led device: tpacpi::standby
> [    4.927036] Registered led device: tpacpi::thinkvantage
> [    4.930329] thinkpad_acpi: Standard ACPI backlight interface available, not loading native one.
> [    4.930829] input: ThinkPad Extra Buttons as /devices/virtual/input/input5
> [    4.931076] Advanced Linux Sound Architecture Driver Version 1.0.21.
> [    4.932503] HDA Intel 0000:00:1b.0: PCI INT B -> GSI 17 (level, low) -> IRQ 17
> [    4.932507] hda_intel: probe_mask set to 0x1 for device 17aa:20ac
> [    4.932529] HDA Intel 0000:00:1b.0: setting latency timer to 64
> [    5.336295] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:1b.0/input/input6
> [    5.340030] usbcore: registered new interface driver snd-usb-audio
> [    5.340034] ALSA device list:
> [    5.340036]   #0: HDA Intel at 0xf8220000 irq 17
> [    5.340130] NET: Registered protocol family 26
> [    5.340133] Mirror/redirect action on
> [    5.340493] netem: version 1.2
> [    5.340495] u32 classifier
> [    5.340496]     Performance counters on
> [    5.340498]     input device check on 
> [    5.340499]     Actions configured 
> [    5.340503] Netfilter messages via NETLINK v0.30.
> [    5.340519] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> [    5.340644] CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
> [    5.340647] nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or
> [    5.340649] sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
> [    5.341164] IPv4 over IPv4 tunneling driver
> [    5.341529] GRE over IPv4 tunneling driver
> [    5.342318] TCP cubic registered
> [    5.342320] Initializing XFRM netlink socket
> [    5.342324] NET: Registered protocol family 17
> [    5.342329] NET: Registered protocol family 15
> [    5.343115] IrCOMM protocol (Dag Brattli)
> [    5.348059] Bluetooth: L2CAP ver 2.14
> [    5.348061] Bluetooth: L2CAP socket layer initialized
> [    5.348064] Bluetooth: SCO (Voice Link) ver 0.6
> [    5.348066] Bluetooth: SCO socket layer initialized
> [    5.348089] Bluetooth: RFCOMM TTY layer initialized
> [    5.348092] Bluetooth: RFCOMM socket layer initialized
> [    5.348094] Bluetooth: RFCOMM ver 1.11
> [    5.348096] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
> [    5.348098] Bluetooth: BNEP filters: protocol multicast
> [    5.348100] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
> [    5.348674] SCTP: Hash tables configured (established 65536 bind 65536)
> [    5.349862] Using IPI No-Shortcut mode
> [    5.350311] registered taskstats version 1
> [    5.351252] drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
> [    5.351355] Freeing unused kernel memory: 476k freed
> [    5.351642] Write protecting the kernel text: 7456k
> [    5.351774] Write protecting the kernel read-only data: 2504k
> [    5.434116] IBM TrackPoint firmware: 0x0e, buttons: 3/3
> [    5.452387] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio1/input/input7
> [    5.583125] usb 3-1: new full speed USB device using uhci_hcd and address 2
> [    5.732704] usb 3-1: New USB device found, idVendor=0a5c, idProduct=2110
> [    5.732711] usb 3-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    5.732717] usb 3-1: Product: BCM2045B
> [    5.732722] usb 3-1: Manufacturer: Broadcom Corp
> [    5.733069] usb 3-1: configuration #1 chosen from 1 choice
> [    5.942124] usb 3-2: new full speed USB device using uhci_hcd and address 3
> [    6.102703] usb 3-2: New USB device found, idVendor=0483, idProduct=2016
> [    6.102710] usb 3-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> [    6.102716] usb 3-2: Product: Biometric Coprocessor
> [    6.102721] usb 3-2: Manufacturer: STMicroelectronics
> [    6.103073] usb 3-2: configuration #1 chosen from 1 choice
> [   12.753713] EXT3-fs: INFO: recovery required on readonly filesystem.
> [   12.753720] EXT3-fs: write access will be enabled during recovery.
> [   13.059470] EXT3-fs: recovery complete.
> [   13.059668] kjournald starting.  Commit interval 5 seconds
> [   13.066962] EXT3-fs: mounted filesystem with writeback data mode.
> [   18.334910] e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
> [   18.334917] e1000e: Copyright (c) 1999-2008 Intel Corporation.
> [   18.335051] e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
> [   18.335075] e1000e 0000:00:19.0: setting latency timer to 64
> [   18.336604] e1000e 0000:00:19.0: irq 28 for MSI/MSI-X
> [   18.339011] rtc_cmos 00:07: RTC can wake from S4
> [   18.339365] rtc_cmos 00:07: rtc core: registered rtc_cmos as rtc0
> [   18.339433] rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
> [   18.345437] Bluetooth: Generic Bluetooth USB driver ver 0.6
> [   18.346241] usbcore: registered new interface driver btusb
> [   18.408803] iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux, 1.3.27ks
> [   18.408806] iwlagn: Copyright(c) 2003-2009 Intel Corporation
> [   18.408904] iwlagn 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
> [   18.408941] iwlagn 0000:03:00.0: setting latency timer to 64
> [   18.408996] iwlagn 0000:03:00.0: Detected Intel Wireless WiFi Link 4965AGN REV=0x4
> [   18.461043] iwlagn 0000:03:00.0: Tunable channels: 13 802.11bg, 19 802.11a channels
> [   18.461141] iwlagn 0000:03:00.0: irq 29 for MSI/MSI-X
> [   18.465767] phy0: Selected rate control algorithm 'iwl-agn-rs'
> [   18.476812] udev: renamed network interface wlan0 to eth1
> [   18.570366] 0000:00:19.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:16:d3:c6:d1:c1
> [   18.570373] 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
> [   18.570412] 0000:00:19.0: eth0: MAC: 6, PHY: 6, PBA No: ffffff-0ff
> [   19.671561] EXT3 FS on dm-0, internal journal
> [   23.387140] thinkpad_ec: thinkpad_ec 0.40 loaded.
> [   23.397492] tp_smapi 0.40 loading...
> [   23.397958] tp_smapi successfully loaded (smapi_port=0xb2).
> [   23.498470] vboxdrv: Trying to deactivate the NMI watchdog permanently...
> [   23.498474] vboxdrv: Successfully done.
> [   23.498475] vboxdrv: Found 2 processor cores.
> [   23.498654] vboxdrv: fAsync=1 offMin=0xe1024 offMax=0xe1024
> [   23.498945] vboxdrv: TSC mode is 'asynchronous', kernel timer mode is 'normal'.
> [   23.498947] vboxdrv: Successfully loaded version 1.6.6_OSE (interface 0x00100001).
> [   23.911188] EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
> [   23.911220] kjournald starting.  Commit interval 5 seconds
> [   23.911643] EXT3 FS on sda1, internal journal
> [   23.911649] EXT3-fs: recovery complete.
> [   23.911656] EXT3-fs: mounted filesystem with writeback data mode.
> [   24.409303] kjournald starting.  Commit interval 5 seconds
> [   24.420536] EXT3 FS on dm-1, internal journal
> [   24.420542] EXT3-fs: recovery complete.
> [   24.420919] EXT3-fs: mounted filesystem with writeback data mode.
> [   24.506354] EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
> [   24.506534] kjournald starting.  Commit interval 5 seconds
> [   24.514296] EXT3 FS on dm-2, internal journal
> [   24.514302] EXT3-fs: recovery complete.
> [   24.514309] EXT3-fs: mounted filesystem with writeback data mode.
> [   24.673459] Adding 1951856k swap on /dev/mapper/cswap.  Priority:-1 extents:1 across:1951856k 
> [   26.253756] ip_tables: (C) 2000-2006 Netfilter Core Team
> [   28.078446] iwlagn 0000:03:00.0: firmware: requesting iwlwifi-4965-2.ucode
> [   28.190080] iwlagn 0000:03:00.0: loaded firmware version 228.61.2.24
> [   28.407977] Registered led device: iwl-phy0::radio
> [   28.407996] Registered led device: iwl-phy0::assoc
> [   28.408012] Registered led device: iwl-phy0::RX
> [   28.408028] Registered led device: iwl-phy0::TX
> [   29.747044] ttyS0: LSR safety check engaged!
> [   29.748210] ttyS0: LSR safety check engaged!
> [   29.749735] ttyS1: LSR safety check engaged!
> [   29.755419] ttyS1: LSR safety check engaged!
> [   30.404058] input: ACPI Virtual Keyboard Device as /devices/virtual/input/input11
> [   34.982146] smapi smapi: set_real_thresh: set start to 79 for bat=0
> [   35.190171] smapi smapi: set_real_thresh: set stop to 93 for bat=0
> [   42.954199] usb 3-1: USB disconnect, address 2
> [   43.002415] usbcore: deregistering interface driver btusb
> [   44.105667] e1000e 0000:00:19.0: irq 28 for MSI/MSI-X
> [   44.156225] e1000e 0000:00:19.0: irq 28 for MSI/MSI-X
> [   45.993769] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: None
> [   45.993778] 0000:00:19.0: eth0: 10/100 speed: disabling TSO
> [   47.590769] ttyS0: LSR safety check engaged!
> [   47.591892] ttyS1: LSR safety check engaged!
> [   55.803510] eth1: deauthenticating from 02:24:01:49:a6:a9 by local choice (reason=3)
> [   55.803540] eth1: direct probe to AP 02:24:01:49:a6:a9 (try 1)
> [   56.003058] eth1: direct probe to AP 02:24:01:49:a6:a9 (try 2)
> [   56.005702] eth1: direct probe responded
> [   56.005705] eth1: authenticate with AP 02:24:01:49:a6:a9 (try 1)
> [   56.205036] eth1: authenticate with AP 02:24:01:49:a6:a9 (try 2)
> [   56.207081] eth1: authenticated
> [   56.207100] eth1: associate with AP 02:24:01:49:a6:a9 (try 1)
> [   56.407106] eth1: associate with AP 02:24:01:49:a6:a9 (try 2)
> [   56.409689] eth1: RX AssocResp from 02:24:01:49:a6:a9 (capab=0x401 status=0 aid=2)
> [   56.409697] eth1: associated
> [   56.699288] eth1: deauthenticating from 02:24:01:49:a6:a9 by local choice (reason=3)
> [   56.987398] Registered led device: iwl-phy0::radio
> [   56.987418] Registered led device: iwl-phy0::assoc
> [   56.987436] Registered led device: iwl-phy0::RX
> [   56.987452] Registered led device: iwl-phy0::TX
> [   57.016322] eth1: direct probe to AP 02:24:01:49:a6:a9 (try 1)
> [   57.216067] eth1: direct probe to AP 02:24:01:49:a6:a9 (try 2)
> [   57.417042] eth1: direct probe to AP 02:24:01:49:a6:a9 (try 3)
> [   57.419744] eth1: direct probe responded
> [   57.419750] eth1: authenticate with AP 02:24:01:49:a6:a9 (try 1)
> [   57.619094] eth1: authenticate with AP 02:24:01:49:a6:a9 (try 2)
> [   57.620968] eth1: authenticated
> [   57.621033] eth1: associate with AP 02:24:01:49:a6:a9 (try 1)
> [   57.821088] eth1: associate with AP 02:24:01:49:a6:a9 (try 2)
> [   57.826321] eth1: RX AssocResp from 02:24:01:49:a6:a9 (capab=0x401 status=0 aid=2)
> [   57.826328] eth1: associated
> 
> ### EOF
> ### vim:tw=256:et:sts=2:st=2:sw=2:com+=b\:###:fo+=cqtr:tags=ctags:

