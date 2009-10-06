From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3: bug report, driver freeze (transmit timed out),
 ifdown+ifup makes interface work again
Date: Mon, 5 Oct 2009 21:21:34 -0700
Message-ID: <20091006042134.GA18517@xw6200.broadcom.net>
References: <1254386068.5551.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sander.contrib@gmail.com" <sander.contrib@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Jesper Dangaard Brouer" <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1294 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751459AbZJFEWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2009 00:22:31 -0400
In-Reply-To: <1254386068.5551.25.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the detailed bug report.  There are lots of things to think
about.

While I think about the next step, can you tell me whether or not jumbo
frames is enabled?

On Thu, Oct 01, 2009 at 01:34:28AM -0700, Jesper Dangaard Brouer wrote:
> 
> A friend of mine is experiencing problems with his tg3 based NIC.  He is
> experiencing the net stops working (transmit timed out), and he hade to
> access the console to get it working again.
> 
> Kernel: 2.6.26-2-686 (standard Debian package)
> OS: Debian Lenny 5.0 (all upgrades)
> 
> Ethernet controller: Broadcom Corporation NetXtreme BCM5700 Gigabit Ethernet (rev 12)
>  Subsystem: Dell Broadcom BCM5700
>  eth1: Tigon3 [partno(none) rev 7102 PHY(5401)]
> 
> Is this a known issue? (If so what kernel is it fixed in... that I can
> make him test...)
> 
> Cite:
> According to the kernel log the tg3 driver tries to reset it self.
> However, even though it looks like the interface is up, it is not!
> 
> A manuel ifdown eth1 && ifup eth1 does the trick.
> 
> According to my rtorrent I had used about 4GB of traffic (combined
> down/up)..  so a qualified guess could be a 32-bit limitation in the
> tg3-driver?
> 
> 
> Server specs:
>  DELL PowerEdge 2550
>  2 GB Ram
>  2x1 Ghz Pentium III (Coppermine)
> 
> 
> Sep 30 11:45:46 samurai kernel: [1145615.063992] NETDEV WATCHDOG: eth1: transmit timed out
> Sep 30 11:45:46 samurai kernel: [1145615.064028] tg3: eth1: transmit timed out, resetting
> Sep 30 11:45:46 samurai kernel: [1145615.064052] tg3: DEBUG: MAC_TX_STATUS[00000008] MAC_RX_STATUS[00000008]
> Sep 30 11:45:46 samurai kernel: [1145615.064078] tg3: DEBUG: RDMAC_STATUS[00000000] WDMAC_STATUS[00000000]
> Sep 30 11:45:46 samurai kernel: [1145615.064119] ------------[ cut here]------------
> Sep 30 11:45:46 samurai kernel: [1145615.064141] WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0x8f/0xdc()
> Sep 30 11:45:46 samurai kernel: [1145615.064174] Modules linked in: iptable_mangle iptable_nat nf_nat ipt_LOG nf_conntrack_ip
> v4 xt_state nf_conntrack xt_tcpudp iptable_filter ip_tables x_tables ipv6 dm_snapshot dm_mirror dm_log dm_mod loop parport_pc
>  parport evdev psmouse snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw pcspkr shpchp pci_hotplug i2c_piix4 i2c_core
> button sworks_agp agpgart dcdbas ext3 jbd mbcache sg sd_mod ide_cd_mod cdrom ide_pci_generic serverworks ide_core floppy aacr
> aid aic7xxx scsi_transport_spi ata_generic e100 ohci_hcd libata scsi_mod dock tg3 usbcore 8139cp 8139too mii thermal processo
> r fan thermal_sys [last unloaded: scsi_wait_scan]
> Sep 30 11:45:46 samurai kernel: [1145615.064517] Pid: 0, comm: swapper Not tainted 2.6.26-2-686 #1
> Sep 30 11:45:46 samurai kernel: [1145615.064549]  [<c01225f3>] warn_on_slowpath+0x40/0x66
> Sep 30 11:45:46 samurai kernel: [1145615.064594]  [<c0119160>] hrtick_start_fair+0xeb/0x12c
> Sep 30 11:45:46 samurai kernel: [1145615.064635]  [<c0118926>] enqueue_task+0x52/0x5d
> Sep 30 11:45:46 samurai kernel: [1145615.064663]  [<c011894c>] activate_task+0x1b/0x26
> Sep 30 11:45:46 samurai kernel: [1145615.064690]  [<c011b6f3>] try_to_wake_up+0xe8/0xf1
> Sep 30 11:45:46 samurai kernel: [1145615.064723]  [<c01319a9>] autoremove_wake_function+0xd/0x2d
> Sep 30 11:45:46 samurai kernel: [1145615.064760]  [<c01184d1>] __wake_up_common+0x2e/0x58
> Sep 30 11:45:46 samurai kernel: [1145615.064792]  [<c011a6bb>] __wake_up+0x29/0x39
> Sep 30 11:45:46 samurai kernel: [1145615.064822]  [<c012f11f>] insert_work+0x58/0x5c
> Sep 30 11:45:46 samurai kernel: [1145615.064849]  [<c012f40d>] __queue_work+0x1c/0x28
> Sep 30 11:45:46 samurai kernel: [1145615.064876]  [<c012f468>] queue_work+0x33/0x3c
> Sep 30 11:45:46 samurai kernel: [1145615.064903]  [<c0267035>] dev_watchdog+0x8f/0xdc
> Sep 30 11:45:46 samurai kernel: [1145615.064930]  [<c01296d4>] run_timer_softirq+0x11a/0x17c
> Sep 30 11:45:46 samurai kernel: [1145615.064960]  [<c0266fa6>] dev_watchdog+0x0/0xdc
> Sep 30 11:45:46 samurai kernel: [1145615.064993]  [<c01265f5>] __do_softirq+0x66/0xd3
> Sep 30 11:45:46 samurai kernel: [1145615.065022]  [<c01266a7>] do_softirq+0x45/0x53
> Sep 30 11:45:46 samurai kernel: [1145615.065047]  [<c012695e>] irq_exit+0x35/0x67
> Sep 30 11:45:46 samurai kernel: [1145615.065070]  [<c01101c9>] smp_apic_timer_interrupt+0x6b/0x76
> Sep 30 11:45:46 samurai kernel: [1145615.065098]  [<c0102656>] default_idle+0x0/0x53
> Sep 30 11:45:46 samurai kernel: [1145615.065127]  [<c0104364>] apic_timer_interrupt+0x28/0x30
> Sep 30 11:45:46 samurai kernel: [1145615.065156]  [<c0102656>] default_idle+0x0/0x53
> Sep 30 11:45:46 samurai kernel: [1145615.065189]  [<c0114d78>] native_safe_halt+0x2/0x3
> Sep 30 11:45:46 samurai kernel: [1145615.065225]  [<c0102683>] default_idle+0x2d/0x53
> Sep 30 11:45:46 samurai kernel: [1145615.065250]  [<c01025ce>] cpu_idle+0xab/0xcb
> Sep 30 11:45:46 samurai kernel: [1145615.065291]  =======================
> Sep 30 11:45:46 samurai kernel: [1145615.065311] ---[ end trace 0dbb94f68d53053b ]---
> Sep 30 11:45:46 samurai kernel: [1145615.457820] tg3: tg3_stop_block timed out, ofs=2c00 enable_bit=2
> Sep 30 11:45:46 samurai kernel: [1145615.557909] tg3: tg3_stop_block timed out, ofs=3400 enable_bit=2
> Sep 30 11:45:46 samurai kernel: [1145615.657903] tg3: tg3_stop_block timed out, ofs=2400 enable_bit=2
> Sep 30 11:45:46 samurai kernel: [1145615.758203] tg3: tg3_stop_block timed out, ofs=1800 enable_bit=2
> Sep 30 11:45:47 samurai kernel: [1145615.858203] tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2
> Sep 30 11:45:47 samurai kernel: [1145615.958203] tg3: tg3_stop_block timed out, ofs=4800 enable_bit=2
> Sep 30 11:45:47 samurai kernel: [1145616.089213] tg3: eth1: Link is down.
> Sep 30 11:45:49 samurai kernel: [1145618.565251] tg3: eth1: Link is up at 100 Mbps, full duplex.
> Sep 30 11:45:49 samurai kernel: [1145618.565288] tg3: eth1: Flow control is off for TX and off for RX.
> 
> Sep 30 14:02:09 samurai kernel: [1154721.802641] NETDEV WATCHDOG: eth1: transmit timed out
> Sep 30 14:02:09 samurai kernel: [1154721.802679] tg3: eth1: transmit timed out, resetting
> Sep 30 14:02:09 samurai kernel: [1154721.802702] tg3: DEBUG: MAC_TX_STATUS[00000008] MAC_RX_STATUS[00000008]
> Sep 30 14:02:09 samurai kernel: [1154721.802729] tg3: DEBUG: RDMAC_STATUS[00000000] WDMAC_STATUS[00000000]
> Sep 30 14:02:09 samurai kernel: [1154721.974663] tg3: tg3_stop_block timed out, ofs=1800 enable_bit=2
> Sep 30 14:02:09 samurai kernel: [1154722.078613] tg3: tg3_stop_block timed out, ofs=4800 enable_bit=2
> Sep 30 14:02:09 samurai kernel: [1154722.206614] tg3: eth1: Link is down.
> Sep 30 14:02:11 samurai kernel: [1154724.209290] tg3: eth1: Link is up at 100 Mbps, full duplex.
> Sep 30 14:02:11 samurai kernel: [1154724.209328] tg3: eth1: Flow control is off for TX and off for RX.
> 
> -- 
> Med venlig hilsen / Best regards
>   Jesper Brouer
>   ComX Networks A/S
>   Linux Network developer
>   Cand. Scient Datalog / MSc.
>   Author of http://adsl-optimizer.dk
>   LinkedIn: http://www.linkedin.com/in/brouer
> 
> lspci -vvv
> 01:08.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5700 Gigabit Ethernet (rev 12)
>         Subsystem: Dell Broadcom BCM5700
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-<TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 32 (16000ns min), Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 17
>         Region 0: Memory at feb00000 (64-bit, non-prefetchable) [size=64K]
>         Capabilities: [40] PCI-X non-bridge device
>                 Command: DPERE- ERO- RBC=512 OST=1
>                 Status: Dev=ff:1f.1 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=512 DMOST=1 DMCRS=8 RSCEM- 266MHz- 533MHz-
>         Capabilities: [48] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>         Capabilities: [50] Vital Product Data <?>
>         Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 Enable-
>                 Address: da6771daee5b44a4  Data: 889a
>         Kernel driver in use: tg3
>         Kernel modules: tg3
> 
> 
> ethtool -i eth1:
> driver: tg3
> version: 3.92.1
> firmware-version:
> bus-info: 0000:01:08.0
> 
> Sep 18 22:34:19 samurai kernel: [ 4.707217] eth1: Tigon3 [partno(none) rev 7102 PHY(5401)] (PCI:66MHz:64-bit) 10/100/1000B
> ase-T Ethernet 00:06:5b:39:d3:4a
> Sep 18 22:34:19 samurai kernel: [ 4.707217] eth1: RXcsums[1] LinkChgREG[1] MIirq[1] ASF[0] WireSpeed[0] TSOcap[0]
> Sep 18 22:34:19 samurai kernel: [ 4.707217] eth1: dma_rwctrl[76ff000f] dma_mask[64-bit]
> 

