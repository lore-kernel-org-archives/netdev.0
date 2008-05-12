From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10682] New: (net 8139too) dual ethernet
 system, any reasonable network causes: NETDEV WATCHDOG: ethN: transmit
 timed out
Date: Sun, 11 May 2008 21:10:55 -0700
Message-ID: <20080511211055.af2595e9.akpm@linux-foundation.org>
References: <bug-10682-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: bkuhn@ebb.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34637 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759922AbYELELG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 00:11:06 -0400
In-Reply-To: <bug-10682-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 11 May 2008 16:34:29 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10682
> 
>            Summary: (net 8139too) dual ethernet system, any reasonable
>                     network causes: NETDEV WATCHDOG: ethN: transmit timed
>                     out
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.25.3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: bkuhn@ebb.org
> 
> 
> Latest working kernel version: Unknown
> Earliest failing kernel version: 2.6.24
> Distribution: Ubuntu
> Hardware Environment: eBox-4852
> Software Environment: Standard Ubuntu Hardy install, with self-compiled kernel
> direct from kernel.org used fakeroot make-kpkg --initrd kernel_image
> 
> Problem Description:
> 
> I have an eBox-4852 which has two of these ethernet cards in it:
>      Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+
> (rev 10
> 
> As soon as I get both ethernet cards up and running and put any reasonable
> load (using the system as a packet-forwarding firewall), one or both of
> them fail for a number of minutes.  Eventually, they usually come back up
> on their own, at which time the following message appears in the syslog:
> 
> kernel: [ 2242.871816] NETDEV WATCHDOG: eth0: transmit timed out
> kernel: [ 2245.885704] eth0: Transmit timeout, status 0d 0000 c07f media 10.
> kernel: [ 2245.885704] eth0: Tx queue start entry 7227  dirty entry 7223.
> kernel: [ 2245.885704] eth0:  Tx descriptor 0 is 0008003c.
> kernel: [ 2245.885704] eth0:  Tx descriptor 1 is 0008003c.
> kernel: [ 2245.885704] eth0:  Tx descriptor 2 is 0008003c.
> kernel: [ 2245.885704] eth0:  Tx descriptor 3 is 00080042. (queue head)
> kernel: [ 2245.885704] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
> 
> They are both recognized at boot time to use the 8139too module:
> 
> kernel: [   15.531666] 8139too Fast Ethernet driver 0.9.28
> kernel: [   15.532287] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
> kernel: [   15.532343] PCI: setting IRQ 10 as level-triggered
> kernel: [   15.532352] ACPI: PCI Interrupt 0000:00:08.0[A] -> Link [LNKA] ->
> GSI 10 (level, low) -> I
> RQ 10
> kernel: [   15.533338] eth0: RealTek RTL8139 at 0xe800, 44:4d:50:02:e1:cb, IRQ
> 10
> kernel: [   15.533394] eth0:  Identified 8139 chip type 'RTL-8100B/8139D'
> kernel: [   15.533817] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
> kernel: [   15.533870] PCI: setting IRQ 11 as level-triggered
> kernel: [   15.533878] ACPI: PCI Interrupt 0000:00:0b.0[A] -> Link [LNKD] ->
> GSI 11 (level, low) -> IRQ 11
> kernel: [   15.534759] eth1: RealTek RTL8139 at 0xe400, 44:4d:50:43:41:74, IRQ
> 11
> kernel: [   15.534814] eth1:  Identified 8139 chip type 'RTL-8100B/8139D'
> 
> Steps to reproduce:
> 
> It's very simple, one needs only to have this box and run both cards with
> any amount of reasonable load and it occurs within an hour, usually much
> faster.  I read online that sometimes WATCHDOG TIMEOUT means that there is
> bad network infrastructure of some sort.  I have tried many different
> network topologies, hubs, and cables and it always produces the same
> error.  I have also tried all different possible BIOS settings related to
> IRQs.
> 
> Based on advice from online forums and the like, I have also tried the
> following kernel command line settings, in sequence and together in
> various ways, and the behavior is still the same:
> 
> nosmp
> irqpoll
> pci=biosirq
> pci=irqmasq
> pci=routeirq
> 
> 
> Here is all the data from the running system:
> 
> ###############################################################################
> /proc/cpuinfo:
> processor       : 0
> vendor_id       : CentaurHauls
> cpu family      : 6
> model           : 13
> model name      : VIA Eden Processor 1200MHz
> stepping        : 0
> cpu MHz         : 1196.956
> cache size      : 128 KB
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 1
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge cmov pat
> clflush acpi mmx fxsr sse sse2 tm nx pni est tm2 xtpr rng rng_en ace ace_en
> ace2 ace2_en phe phe_en pmm pmm_en
> bogomips        : 2395.59
> clflush size    : 64
> ###############################################################################
> /proc/interrupts:
>            CPU0       
>   0:     131574    XT-PIC-XT        timer
>   1:        761    XT-PIC-XT        i8042
>   2:          0    XT-PIC-XT        cascade
>   7:          0    XT-PIC-XT        parport0
>   8:          7    XT-PIC-XT        rtc
>   9:          0    XT-PIC-XT        acpi
>  10:      38862    XT-PIC-XT        uhci_hcd:usb2, eth0
>  11:    1151499    XT-PIC-XT        ehci_hcd:usb1, eth1
>  14:          0    XT-PIC-XT        pata_via
>  15:      16369    XT-PIC-XT        pata_via
> NMI:          0   Non-maskable interrupts
> TRM:          0   Thermal event interrupts
> SPU:          0   Spurious interrupts
> ERR:          0
> ###############################################################################
> /proc/iomem:
> 
> 00000000-0009fbff : System RAM
> 0009fc00-0009ffff : reserved
> 000a0000-000bffff : Video RAM area
> 000c0000-000ce5ff : Video ROM
> 000f0000-000fffff : System ROM
> 00100000-1bfbffff : System RAM
>   00100000-002f182f : Kernel code
>   002f1830-003db41f : Kernel data
>   00433000-0048ed9b : Kernel bss
> 1bfc0000-1bfcdfff : ACPI Tables
> 1bfce000-1bffffff : ACPI Non-volatile Storage
> c0000000-dfffffff : PCI Bus #01
>   c0000000-dfffffff : 0000:01:00.0
> e0000000-efffffff : pnp 00:0d
> f0000000-f7ffffff : 0000:00:00.0
> fcfff400-fcfff4ff : 0000:00:10.4
>   fcfff400-fcfff4ff : ehci_hcd
> fcfff800-fcfff8ff : 0000:00:0b.0
>   fcfff800-fcfff8ff : 8139too
> fcfffc00-fcfffcff : 0000:00:08.0
>   fcfffc00-fcfffcff : 8139too
> fd000000-feafffff : PCI Bus #01
>   fd000000-fdffffff : 0000:01:00.0
>   feaf0000-feafffff : 0000:01:00.0
> feb00000-febfffff : PCI Bus #02
>   febfc000-febfffff : 0000:02:01.0
> fec00000-fec00fff : reserved
> fed00000-fed003ff : HPET 0
> fee00000-fee00fff : reserved
> fff80000-ffffffff : reserved
> ###############################################################################
> /proc/ioports:
> 0000-001f : dma1
> 0020-0021 : pic1
> 0040-0043 : timer0
> 0050-0053 : timer1
> 0060-006f : keyboard
> 0070-0077 : rtc
> 0080-008f : dma page reg
> 00a0-00a1 : pic2
> 00c0-00df : dma2
> 00f0-00ff : fpu
> 0170-0177 : 0000:00:0f.0
>   0170-0177 : pata_via
> 01f0-01f7 : 0000:00:0f.0
>   01f0-01f7 : pata_via
> 02f8-02ff : serial
> 0376-0376 : 0000:00:0f.0
>   0376-0376 : pata_via
> 0378-037a : parport0
> 03c0-03df : vga+
> 03e0-03e7 : pnp 00:09
> 03f6-03f6 : 0000:00:0f.0
>   03f6-03f6 : pata_via
> 03f8-03ff : serial
> 0400-041f : pnp 00:09
>   0400-0407 : vt596_smbus
> 04d0-04d1 : pnp 00:09
> 0800-087f : pnp 00:09
>   0800-0803 : ACPI PM1a_EVT_BLK
>   0804-0805 : ACPI PM1a_CNT_BLK
>   0808-080b : ACPI PM_TMR
>   0810-0815 : ACPI CPU throttle
>   0820-0823 : ACPI GPE0_BLK
> 0a00-0a0f : pnp 00:08
> 0a10-0a1f : pnp 00:08
> 0a20-0a2f : pnp 00:08
> 0a30-0a3f : pnp 00:08
> 0a40-0a4f : pnp 00:08
> 0a50-0a5f : pnp 00:08
> 0a60-0a61 : pnp 00:08
> 0cf8-0cff : PCI conf1
> e400-e4ff : 0000:00:0b.0
>   e400-e4ff : 8139too
> e800-e8ff : 0000:00:08.0
>   e800-e8ff : 8139too
> ec00-ec1f : 0000:00:10.0
>   ec00-ec1f : uhci_hcd
> fc00-fc0f : 0000:00:0f.0
>   fc00-fc0f : pata_via
> ###############################################################################
> $ lsmod
> Module                  Size  Used by
> af_packet              21760  2 
> video                  19600  0 
> output                  3968  1 video
> sbs                    13960  0 
> sbshc                   6912  1 sbs
> container               4864  0 
> battery                13188  0 
> ac                      6148  0 
> quota_v1                3456  1 
> ext3                  133768  1 
> jbd                    42900  1 ext3
> mbcache                 8448  1 ext3
> lp                     11812  0 
> loop                   18052  0 
> parport_pc             35108  1 
> parport                36168  2 lp,parport_pc
> xt_limit                2816  6 
> pcspkr                  3200  0 
> button                  8336  0 
> i2c_viapro              9236  0 
> xt_multiport            3584  3 
> i2c_core               24848  1 i2c_viapro
> via_agp                10368  1 
> shpchp                 33428  0 
> pci_hotplug            30116  1 shpchp
> agpgart                33840  1 via_agp
> xt_state                2688  60 
> xt_tcpudp               3456  61 
> evdev                  12032  0 
> nf_nat_tftp             2048  0 
> nf_conntrack_tftp       5396  1 nf_nat_tftp
> nf_nat_snmp_basic      10372  0 
> nf_nat_sip              4992  0 
> nf_conntrack_sip        9364  1 nf_nat_sip
> nf_nat_pptp             3968  0 
> nf_conntrack_pptp       7296  1 nf_nat_pptp
> nf_conntrack_proto_gre     5760  1 nf_conntrack_pptp
> nf_nat_proto_gre        3076  1 nf_nat_pptp
> nf_nat_irc              3072  0 
> nf_conntrack_irc        6936  1 nf_nat_irc
> nf_nat_h323             7808  0 
> nf_conntrack_h323      49576  1 nf_nat_h323
> nf_nat_ftp              3584  0 
> nf_conntrack_ftp        8992  1 nf_nat_ftp
> nf_nat_amanda           2688  0 
> ts_kmp                  2304  5 
> nf_conntrack_amanda     5248  1 nf_nat_amanda
> iptable_raw             3072  0 
> iptable_nat             7560  1 
> iptable_mangle          3456  0 
> iptable_filter          3584  1 
> ipt_ttl                 2048  0 
> ipt_recent              9496  0 
> ipt_ecn                 2432  0 
> ipt_ah                  2176  0 
> ipt_addrtype            3072  0 
> ipt_ULOG                9220  0 
> ipt_TTL                 2560  0 
> ipt_REJECT              4352  0 
> ipt_REDIRECT            2176  0 
> ipt_NETMAP              2176  0 
> ipt_MASQUERADE          3712  0 
> nf_nat                 19472  12
> nf_nat_tftp,nf_nat_sip,nf_nat_pptp,nf_nat_proto_gre,nf_nat_irc,nf_nat_h323,nf_nat_ftp,nf_nat_amanda,iptable_nat,ipt_REDIRECT,ipt_NETMAP,ipt_MASQUERADE
> nf_conntrack_ipv4      17800  63 iptable_nat,nf_nat
> ipt_LOG                 6400  8 
> ipt_ECN                 3200  0 
> ipt_CLUSTERIP           8580  0 
> nf_conntrack           62884  22
> xt_state,nf_nat_tftp,nf_conntrack_tftp,nf_nat_snmp_basic,nf_nat_sip,nf_conntrack_sip,nf_nat_pptp,nf_conntrack_pptp,nf_conntrack_proto_gre,nf_nat_irc,nf_conntrack_irc,nf_nat_h323,nf_conntrack_h323,nf_nat_ftp,nf_conntrack_ftp,nf_nat_amanda,nf_conntrack_amanda,iptable_nat,ipt_MASQUERADE,nf_nat,nf_conntrack_ipv4,ipt_CLUSTERIP
> ip_tables              13328  4
> iptable_raw,iptable_nat,iptable_mangle,iptable_filter
> ip_queue               10000  0 
> arptable_filter         2816  0 
> arpt_mangle             2432  0 
> arp_tables             11792  1 arptable_filter
> x_tables               16516  22
> xt_limit,xt_multiport,xt_state,xt_tcpudp,iptable_nat,ipt_ttl,ipt_recent,ipt_ecn,ipt_ah,ipt_addrtype,ipt_ULOG,ipt_TTL,ipt_REJECT,ipt_REDIRECT,ipt_NETMAP,ipt_MASQUERADE,ipt_LOG,ipt_ECN,ipt_CLUSTERIP,ip_tables,arpt_mangle,arp_tables
> jfs                   187716  1 
> sg                     37168  0 
> sd_mod                 29968  5 
> pata_via               12548  4 
> pata_acpi               7424  0 
> ata_generic             8324  0 
> uhci_hcd               24848  0 
> ehci_hcd               36492  0 
> libata                161936  3 pata_via,pata_acpi,ata_generic
> usbcore               145264  3 uhci_hcd,ehci_hcd
> scsi_mod              151180  3 sg,sd_mod,libata
> dock                   10380  1 libata
> 8139too                27136  0 
> mii                     5760  1 8139too
> thermal                18972  0 
> processor              33332  1 thermal
> fan                     5764  0 
> fuse                   48412  1 
> ###############################################################################
> $ lspci -vvv
> 00:00.0 Host bridge: VIA Technologies, Inc. CX700 Host Bridge (rev 03)
>         Subsystem: VIA Technologies, Inc. CX700 Host Bridge
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 8
>         Region 0: Memory at f0000000 (32-bit, prefetchable) [size=128M]
>         Capabilities: [80] AGP version 3.5
>                 Status: RQ=8 Iso- ArqSz=0 Cal=2 SBA+ ITACoh- GART64- HTrans-
> 64bit- FW+ AGP3+ Rate=x4,x8
>                 Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW-
> Rate=<none>
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:00.1 Host bridge: VIA Technologies, Inc. CX700 Host Bridge
>         Subsystem: VIA Technologies, Inc. CX700 Host Bridge
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
> 
> 00:00.2 Host bridge: VIA Technologies, Inc. CX700 Host Bridge
>         Subsystem: VIA Technologies, Inc. CX700 Host Bridge
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
> 
> 00:00.3 Host bridge: VIA Technologies, Inc. CX700 Host Bridge
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
> 
> 00:00.4 Host bridge: VIA Technologies, Inc. CX700 Host Bridge
>         Subsystem: VIA Technologies, Inc. CX700 Host Bridge
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
> 
> 00:00.7 Host bridge: VIA Technologies, Inc. CX700 Host Bridge
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
> 
> 00:01.0 PCI bridge: VIA Technologies, Inc. VT8237 PCI Bridge (prog-if 00
> [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
>         I/O behind bridge: 0000f000-00000fff
>         Memory behind bridge: fd000000-feafffff
>         Prefetchable memory behind bridge: c0000000-dfffffff
>         Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort+ <SERR- <PERR+
>         BridgeCtl: Parity+ SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
>         Capabilities: [70] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:08.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10)
>         Subsystem: Realtek Semiconductor Co., Ltd. RT8139
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64 (8000ns min, 16000ns max)
>         Interrupt: pin A routed to IRQ 10
>         Region 0: I/O ports at e800 [size=256]
>         Region 1: Memory at fcfffc00 (32-bit, non-prefetchable) [size=256]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
> PME(D0-,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:0b.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10)
>         Subsystem: Realtek Semiconductor Co., Ltd. RT8139
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64 (8000ns min, 16000ns max)
>         Interrupt: pin A routed to IRQ 11
>         Region 0: I/O ports at e400 [size=256]
>         Region 1: Memory at fcfff800 (32-bit, non-prefetchable) [size=256]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
> PME(D0-,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:0f.0 IDE interface: VIA Technologies, Inc. CX700M2 IDE (prog-if 8a [Master
> SecP PriP])
>         Subsystem: VIA Technologies, Inc. Unknown device 0581
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32
>         Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable)
> [size=8]
>         Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable)
> [size=1]
>         Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable)
> [size=8]
>         Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable)
> [size=1]
>         Region 4: I/O ports at fc00 [size=16]
>         Capabilities: [b0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:10.0 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
> Controller (rev 90) (prog-if 00 [UHCI])
>         Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 10
>         Region 4: I/O ports at ec00 [size=32]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
> PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:10.4 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 90) (prog-if 20
> [EHCI])
>         Subsystem: VIA Technologies, Inc. USB 2.0
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64, Cache Line Size: 32 bytes
>         Interrupt: pin D routed to IRQ 11
>         Region 0: Memory at fcfff400 (32-bit, non-prefetchable) [size=256]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
> PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [88] Debug port
> 
> 00:11.0 ISA bridge: VIA Technologies, Inc. CX700 PCI to ISA Bridge
>         Subsystem: VIA Technologies, Inc. CX700 PCI to ISA Bridge
>         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Capabilities: [c0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:11.7 Host bridge: VIA Technologies, Inc. CX700 Internal Module Bus
>         Subsystem: VIA Technologies, Inc. CX700 Internal Module Bus
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort+ >SERR- <PERR-
>         Latency: 128
>         Capabilities: [58] HyperTransport: Interrupt Discovery and
> Configuration
> 
> 00:13.0 PCI bridge: VIA Technologies, Inc. CX700 Host Bridge (prog-if 00
> [Normal decode])
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
> <MAbort+ >SERR- <PERR-
>         Latency: 0
>         Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
>         I/O behind bridge: 0000f000-00000fff
>         Memory behind bridge: feb00000-febfffff
>         Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
> 
> 01:00.0 VGA compatible controller: VIA Technologies, Inc. CX700M2 UniChrome PRO
> II Graphics (rev 03) (prog-if 00 [VGA controller])
>         Subsystem: Unknown device 0908:1975
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64 (500ns min)
>         Interrupt: pin A routed to IRQ 0
>         Region 0: Memory at c0000000 (32-bit, prefetchable) [size=512M]
>         Region 1: Memory at fd000000 (32-bit, non-prefetchable) [size=16M]
>         Expansion ROM at feaf0000 [disabled] [size=64K]
>         Capabilities: [60] Power Management version 2
>                 Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [70] AGP version 3.0
>                 Status: RQ=256 Iso- ArqSz=0 Cal=7 SBA+ ITACoh- GART64- HTrans-
> 64bit- FW- AGP3+ Rate=x4,x8
>                 Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW-
> Rate=<none>
> 
> 02:01.0 Audio device: VIA Technologies, Inc. VIA High Definition Audio
> Controller (rev 10)
>         Subsystem: VIA Technologies, Inc. VIA High Definition Audio Controller
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
> <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 5
>         Region 0: Memory at febfc000 (64-bit, non-prefetchable) [size=16K]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [60] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0
> Enable-
>                 Address: 0000000000000000  Data: 0000
>         Capabilities: [70] Express Unknown type IRQ 0
>                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
>                 Device: Latency L0s <64ns, L1 <1us
>                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 Link: Supported Speed unknown, Width x0, ASPM unknown, Port 0
>                 Link: Latency L0s <64ns, L1 <1us
>                 Link: ASPM Disabled CommClk- ExtSynch-
>                 Link: Speed unknown, Width x0
> ###############################################################################
> /proc/modules:
> af_packet 21760 2 - Live 0xdcd1c000
> video 19600 0 - Live 0xdcd16000
> output 3968 1 video, Live 0xdcc06000
> sbs 13960 0 - Live 0xdcd3a000
> sbshc 6912 1 sbs, Live 0xdcc31000
> container 4864 0 - Live 0xdcc17000
> battery 13188 0 - Live 0xdcc2c000
> ac 6148 0 - Live 0xdcc14000
> quota_v1 3456 1 - Live 0xdcc04000
> ext3 133768 1 - Live 0xdcef6000
> jbd 42900 1 ext3, Live 0xdcc40000
> mbcache 8448 1 ext3, Live 0xdcc00000
> lp 11812 0 - Live 0xdcbfc000
> loop 18052 0 - Live 0xdcbf6000
> parport_pc 35108 1 - Live 0xdcc22000
> parport 36168 2 lp,parport_pc, Live 0xdcc0a000
> xt_limit 2816 6 - Live 0xdcc08000
> pcspkr 3200 0 - Live 0xdcbe1000
> button 8336 0 - Live 0xdcbf2000
> i2c_viapro 9236 0 - Live 0xdcbdd000
> xt_multiport 3584 3 - Live 0xdc9f7000
> i2c_core 24848 1 i2c_viapro, Live 0xdcc1a000
> via_agp 10368 1 - Live 0xdc9ef000
> shpchp 33428 0 - Live 0xdcbe3000
> pci_hotplug 30116 1 shpchp, Live 0xdcc56000
> agpgart 33840 1 via_agp, Live 0xdcc4c000
> xt_state 2688 60 - Live 0xdc9f3000
> xt_tcpudp 3456 61 - Live 0xdc9f5000
> evdev 12032 0 - Live 0xdc9eb000
> nf_nat_tftp 2048 0 - Live 0xdc9e9000
> nf_conntrack_tftp 5396 1 nf_nat_tftp, Live 0xdc9e6000
> nf_nat_snmp_basic 10372 0 - Live 0xdc9e2000
> nf_nat_sip 4992 0 - Live 0xdc9df000
> nf_conntrack_sip 9364 1 nf_nat_sip, Live 0xdc9db000
> nf_nat_pptp 3968 0 - Live 0xdc9c7000
> nf_conntrack_pptp 7296 1 nf_nat_pptp, Live 0xdc9c4000
> nf_conntrack_proto_gre 5760 1 nf_conntrack_pptp, Live 0xdc9c1000
> nf_nat_proto_gre 3076 1 nf_nat_pptp, Live 0xdc9bf000
> nf_nat_irc 3072 0 - Live 0xdc9ba000
> nf_conntrack_irc 6936 1 nf_nat_irc, Live 0xdc9b7000
> nf_nat_h323 7808 0 - Live 0xdc9b4000
> nf_conntrack_h323 49576 1 nf_nat_h323, Live 0xdc9cd000
> nf_nat_ftp 3584 0 - Live 0xdc9b2000
> nf_conntrack_ftp 8992 1 nf_nat_ftp, Live 0xdc9ae000
> nf_nat_amanda 2688 0 - Live 0xdc9ac000
> ts_kmp 2304 5 - Live 0xdc9bd000
> nf_conntrack_amanda 5248 1 nf_nat_amanda, Live 0xdc9a9000
> iptable_raw 3072 0 - Live 0xdc9a7000
> iptable_nat 7560 1 - Live 0xdc9a4000
> iptable_mangle 3456 0 - Live 0xdc9cb000
> iptable_filter 3584 1 - Live 0xdc9c9000
> ipt_ttl 2048 0 - Live 0xdc99e000
> ipt_recent 9496 0 - Live 0xdc99a000
> ipt_ecn 2432 0 - Live 0xdc998000
> ipt_ah 2176 0 - Live 0xdc996000
> ipt_addrtype 3072 0 - Live 0xdc994000
> ipt_ULOG 9220 0 - Live 0xdc990000
> ipt_TTL 2560 0 - Live 0xdc98e000
> ipt_REJECT 4352 0 - Live 0xdc98b000
> ipt_REDIRECT 2176 0 - Live 0xdc989000
> ipt_NETMAP 2176 0 - Live 0xdc987000
> ipt_MASQUERADE 3712 0 - Live 0xdc985000
> nf_nat 19472 12
> nf_nat_tftp,nf_nat_sip,nf_nat_pptp,nf_nat_proto_gre,nf_nat_irc,nf_nat_h323,nf_nat_ftp,nf_nat_amanda,iptable_nat,ipt_REDIRECT,ipt_NETMAP,ipt_MASQUERADE,
> Live 0xdc97f000
> nf_conntrack_ipv4 17800 63 iptable_nat,nf_nat, Live 0xdc979000
> ipt_LOG 6400 8 - Live 0xdc9a1000
> ipt_ECN 3200 0 - Live 0xdc8b0000
> ipt_CLUSTERIP 8580 0 - Live 0xdc8e6000
> nf_conntrack 62884 22
> xt_state,nf_nat_tftp,nf_conntrack_tftp,nf_nat_snmp_basic,nf_nat_sip,nf_conntrack_sip,nf_nat_pptp,nf_conntrack_pptp,nf_conntrack_proto_gre,nf_nat_irc,nf_conntrack_irc,nf_nat_h323,nf_conntrack_h323,nf_nat_ftp,nf_conntrack_ftp,nf_nat_amanda,nf_conntrack_amanda,iptable_nat,ipt_MASQUERADE,nf_nat,nf_conntrack_ipv4,ipt_CLUSTERIP,
> Live 0xdc968000
> ip_tables 13328 4 iptable_raw,iptable_nat,iptable_mangle,iptable_filter, Live
> 0xdc8e1000
> ip_queue 10000 0 - Live 0xdc8dd000
> arptable_filter 2816 0 - Live 0xdc8aa000
> arpt_mangle 2432 0 - Live 0xdc89d000
> arp_tables 11792 1 arptable_filter, Live 0xdc8d9000
> x_tables 16516 22
> xt_limit,xt_multiport,xt_state,xt_tcpudp,iptable_nat,ipt_ttl,ipt_recent,ipt_ecn,ipt_ah,ipt_addrtype,ipt_ULOG,ipt_TTL,ipt_REJECT,ipt_REDIRECT,ipt_NETMAP,ipt_MASQUERADE,ipt_LOG,ipt_ECN,ipt_CLUSTERIP,ip_tables,arpt_mangle,arp_tables,
> Live 0xdc8d3000
> jfs 187716 1 - Live 0xdc8ef000
> sg 37168 0 - Live 0xdc8c8000
> sd_mod 29968 5 - Live 0xdc8bf000
> pata_via 12548 4 - Live 0xdc8ea000
> pata_acpi 7424 0 - Live 0xdc839000
> ata_generic 8324 0 - Live 0xdc8ac000
> uhci_hcd 24848 0 - Live 0xdc8a2000
> ehci_hcd 36492 0 - Live 0xdc865000
> libata 161936 3 pata_via,pata_acpi,ata_generic, Live 0xdc9fa000
> usbcore 145264 3 uhci_hcd,ehci_hcd, Live 0xdc878000
> scsi_mod 151180 3 sg,sd_mod,libata, Live 0xdc83f000
> dock 10380 1 libata, Live 0xdc835000
> 8139too 27136 0 - Live 0xdc870000
> mii 5760 1 8139too, Live 0xdc832000
> thermal 18972 0 - Live 0xdc82c000
> processor 33332 1 thermal, Live 0xdc822000
> fan 5764 0 - Live 0xdc83c000
> fuse 48412 1 - Live 0xdc8b2000
> ###############################################################################
> $ ver_linux:
> 
> If some fields are empty or look unusual you may have an old version.
> Compare to the current minimal requirements in Documentation/Changes.
> 
> Linux buddhist 2.6.25.3 #2 Sun May 11 15:35:44 EDT 2008 i686 GNU/Linux
> 
> Gnu C                  4.2.3
> Gnu make               3.81
> binutils               2.18.0.20080103
> util-linux             2.13.1
> mount                  2.13.1
> module-init-tools      3.3-pre11
> e2fsprogs              1.40.8
> jfsutils               1.1.11
> reiserfsprogs          3.6.19
> pcmciautils            014
> quota-tools            3.15.
> PPP                    2.4.4
> Linux C Library        2.7
> Dynamic linker (ldd)   2.7
> Procps                 3.2.7
> Net-tools              1.60
> Console-tools          0.2.3
> Sh-utils               6.10
> udev                   117
> wireless-tools         29
> Modules Loaded         af_packet video output sbs sbshc container battery ac
> quota_v1 ext3 jbd mbcache lp loop parport_pc parport xt_limit pcspkr button
> i2c_viapro xt_multiport i2c_core via_agp shpchp pci_hotplug agpgart xt_state
> xt_tcpudp evdev nf_nat_tftp nf_conntrack_tftp nf_nat_snmp_basic nf_nat_sip
> nf_conntrack_sip nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre
> nf_nat_proto_gre nf_nat_irc nf_conntrack_irc nf_nat_h323 nf_conntrack_h323
> nf_nat_ftp nf_conntrack_ftp nf_nat_amanda ts_kmp nf_conntrack_amanda
> iptable_raw iptable_nat iptable_mangle iptable_filter ipt_ttl ipt_recent
> ipt_ecn ipt_ah ipt_addrtype ipt_ULOG ipt_TTL ipt_REJECT ipt_REDIRECT ipt_NETMAP
> ipt_MASQUERADE nf_nat nf_conntrack_ipv4 ipt_LOG ipt_ECN ipt_CLUSTERIP
> nf_conntrack ip_tables ip_queue arptable_filter arpt_mangle arp_tables x_tables
> jfs sg sd_mod pata_via pata_acpi ata_generic uhci_hcd ehci_hcd libata usbcore
> scsi_mod dock 8139too mii thermal processor fan fuse
> ###############################################################################
> /proc/version:
> Linux version 2.6.25.3 (root@hughes) (gcc version 4.2.3 (Ubuntu
> 4.2.3-2ubuntu7)) #2 Sun May 11 15:35:44 EDT 2008

I really dont' know where to begin with this, sorry.  It's _probably_ some
platform-related IRQ delivery problem.  But then again it might be
something else :(

It would certainly be valuable to try some older kernels.
