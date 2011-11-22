From: Milan Kocian <milon@wq.cz>
Subject: Re: sky2 tx watchdog timeout with 1Gb speed
Date: Tue, 22 Nov 2011 10:42:34 +0100
Message-ID: <20111122094234.GA28500@ntm.wq.cz>
References: <20111120232118.GA29748@ntm.wq.cz>
 <20111121160543.2ae9c04c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srw1.wq.cz ([80.92.240.72]:50900 "EHLO srw1.wq.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753655Ab1KVJmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Nov 2011 04:42:45 -0500
Content-Disposition: inline
In-Reply-To: <20111121160543.2ae9c04c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi stephen,

many thanks for reply.

On Mon, Nov 21, 2011 at 04:05:43PM -0800, Stephen Hemminger wrote:
> On Mon, 21 Nov 2011 00:21:18 +0100
> Milan Kocian <milon@wq.cz> wrote:
> 
> > hi all,
> > 
> > I switched my home pc from 100Mb/s to 1000Mb/s and I see 
> > this warning below.
> > 
> > The original kernel was 2.6.39.4 then I tested 3.1.1 with the same
> > result. (self compiled 32bit vanilla). The workaround is to force 10/100 speed
> > on my new switch (hp).
> > 
> > lspci:
> > 
> > 03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller (rev 13)
> >         Subsystem: Giga-byte Technology Device e000
> >         Flags: bus master, fast devsel, latency 0, IRQ 45
> >         Memory at f5000000 (64-bit, non-prefetchable) [size=16K]
> >         I/O ports at 9000 [size=256]
> >         [virtual] Expansion ROM at 80300000 [disabled] [size=128K]
> >         Capabilities: [48] Power Management version 3
> >         Capabilities: [50] Vital Product Data
> >         Capabilities: [5c] MSI: Enable+ Count=1/1 Maskable- 64bit+
> >         Capabilities: [e0] Express Legacy Endpoint, MSI 00
> >         Capabilities: [100] Advanced Error Reporting
> >         Kernel driver in use: sky2
> > 
> > 
> > Nov 20 21:32:54 milu kernel: sky2 0000:03:00.0: eth0: Link is up at 1000 Mbps, full duplex, flow control both
> > Nov 20 21:35:29 milu kernel: ------------[ cut here ]------------
> > Nov 20 21:35:29 milu kernel: WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x1fa/0x206()
> > Nov 20 21:35:29 milu kernel: Hardware name: 965GM-S2
> > Nov 20 21:35:29 milu kernel: NETDEV WATCHDOG: eth0 (sky2): transmit queue 0 timed out
> > Nov 20 21:35:29 milu kernel: Modules linked in: parport_pc parport fuse nfsd ipv6 nfs lockd auth_rpcgss nfs_acl sunrpc usbhid snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_intel8x0 sg snd_ac97_codec sr_mod ac97_bus cdrom sky2 snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss intel_agp snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd bitrev i2c_i801 crc32 intel_gtt uhci_hcd i2c_core ehci_hcd soundcore usbcore agpgart evdev snd_page_alloc
> > Nov 20 21:35:29 milu kernel: Pid: 0, comm: swapper Not tainted 3.1.1 #2
> > Nov 20 21:35:29 milu kernel: Call Trace:
> > Nov 20 21:35:29 milu kernel: [<c102cd5d>] ? warn_slowpath_common+0x6c/0x94
> > Nov 20 21:35:29 milu kernel: [<c1254deb>] ? dev_watchdog+0x1fa/0x206
> > Nov 20 21:35:29 milu kernel: [<c1254deb>] ? dev_watchdog+0x1fa/0x206
> > Nov 20 21:35:29 milu kernel: [<c102ce0e>] ? warn_slowpath_fmt+0x33/0x37
> > Nov 20 21:35:29 milu kernel: [<c1254deb>] ? dev_watchdog+0x1fa/0x206
> > Nov 20 21:35:29 milu kernel: [<c1254bf1>] ? qdisc_reset+0x2d/0x2d
> > Nov 20 21:35:29 milu kernel: [<c1036434>] ? run_timer_softirq+0xc6/0x1c4
> > Nov 20 21:35:29 milu kernel: [<c1027e9b>] ? run_rebalance_domains+0x148/0x169
> > Nov 20 21:35:29 milu kernel: [<c103163b>] ? __do_softirq+0x6e/0xea
> > Nov 20 21:35:29 milu kernel: [<c10315cd>] ? remote_softirq_receive+0x11/0x11
> > Nov 20 21:35:29 milu kernel: <IRQ>  [<c1031906>] ? irq_exit+0x5b/0x67
> > Nov 20 21:35:29 milu kernel: [<c101631f>] ? smp_apic_timer_interrupt+0x51/0x81
> > Nov 20 21:35:29 milu kernel: [<c12ccd96>] ? apic_timer_interrupt+0x2a/0x30
> > Nov 20 21:35:29 milu kernel: [<c13f007b>] ? asus_hides_smbus_hostbridge+0xcb/0x249
> > Nov 20 21:35:29 milu kernel: [<c1008732>] ? mwait_idle+0x41/0x51
> > Nov 20 21:35:29 milu kernel: [<c10015d8>] ? cpu_idle+0x74/0x84
> > Nov 20 21:35:29 milu kernel: [<c13d6638>] ? start_kernel+0x28a/0x28f
> > Nov 20 21:35:29 milu kernel: [<c13d615e>] ? loglevel+0x2b/0x2b
> > Nov 20 21:35:29 milu kernel: ---[ end trace ef84175f674c7842 ]---
> > Nov 20 21:35:29 milu kernel: sky2 0000:03:00.0: eth0: tx timeout
> > Nov 20 21:35:29 milu kernel: sky2 0000:03:00.0: eth0: transmit ring 52 .. 30 report=52 done=52
> > Nov 20 21:35:32 milu kernel: sky2 0000:03:00.0: eth0: Link is up at 1000 Mbps, full duplex, flow control both
> > Nov 20 21:37:13 milu kernel: sky2 0000:03:00.0: eth0: tx timeout
> > Nov 20 21:37:13 milu kernel: sky2 0000:03:00.0: eth0: transmit ring 37 .. 15 report=37 done=37
> > Nov 20 21:37:16 milu kernel: sky2 0000:03:00.0: eth0: Link is up at 1000 Mbps, full duplex, flow control both
> > 
> > Any suggestion ? As I said its home machine so I can test what you want :-).
> 
> I haven't seen this, is it under heavy or light traffic.

Imho heavy traffic is not needed (will do more tests). After boot all seems ok,
ping is working. But when I start something to do, net is freezing. It's not possible
to copy something over net.

> Are you running something that might cause device to miss interrupts?
> 

Imho no. In pc is nvidia card but the warning happens without nvidia driver
loaded (i tested sending data over net without X, no nvidia driver loaded
with the same result). For sure I'm sending /proc/interrupts and list of all devices.

I noticed one thing, when 1Gb is set I see this in kerne.log too:

Nov 20 21:49:31 milu kernel: ata1.00: exception Emask 0x10 SAct 0x0 SErr 0x400100 action 0x6 frozen
Nov 20 21:49:31 milu kernel: ata1.00: irq_stat 0x08000000, interface fatal error
Nov 20 21:49:31 milu kernel: ata1: SError: { UnrecovData Handshk }
Nov 20 21:49:31 milu kernel: ata1.00: failed command: WRITE DMA EXT
Nov 20 21:49:31 milu kernel: ata1.00: cmd 35/00:00:4f:d3:04/00:03:00:00:00/e0 tag 0 dma 393216 out
Nov 20 21:49:31 milu kernel:         res 50/00:00:f6:0c:e6/00:00:06:00:00/e6 Emask 0x10 (ATA bus error)
Nov 20 21:49:31 milu kernel: ata1.00: status: { DRDY }
Nov 20 21:49:31 milu kernel: ata1: hard resetting link
Nov 20 21:49:31 milu kernel: ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
Nov 20 21:49:31 milu kernel: ata1.00: configured for UDMA/133
Nov 20 21:49:31 milu kernel: ata1: EH complete
Nov 20 21:50:12 milu kernel: ata1.00: exception Emask 0x10 SAct 0x0 SErr 0x400100 action 0x6 frozen
Nov 20 21:50:12 milu kernel: ata1.00: irq_stat 0x08000000, interface fatal error
Nov 20 21:50:12 milu kernel: ata1: SError: { UnrecovData Handshk }
Nov 20 21:50:12 milu kernel: ata1.00: failed command: WRITE DMA EXT
Nov 20 21:50:12 milu kernel: ata1.00: cmd 35/00:e0:17:a2:15/00:03:08:00:00/e0 tag 0 dma 507904 out
Nov 20 21:50:12 milu kernel:         res 50/00:00:16:a2:15/00:00:08:00:00/e0 Emask 0x10 (ATA bus error)
Nov 20 21:50:12 milu kernel: ata1.00: status: { DRDY }
Nov 20 21:50:12 milu kernel: ata1: hard resetting link
Nov 20 21:50:12 milu kernel: ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
Nov 20 21:50:12 milu kernel: ata1.00: configured for UDMA/133
Nov 20 21:50:12 milu kernel: ata1: EH complete
Nov 20 21:50:12 milu kernel: ata1.00: exception Emask 0x10 SAct 0x0 SErr 0x400100 action 0x6 frozen
Nov 20 21:50:12 milu kernel: ata1.00: irq_stat 0x08000000, interface fatal error
Nov 20 21:50:12 milu kernel: ata1: SError: { UnrecovData Handshk }
Nov 20 21:50:12 milu kernel: ata1.00: failed command: WRITE DMA EXT
Nov 20 21:50:12 milu kernel: ata1.00: cmd 35/00:e0:c7:95:a9/00:03:08:00:00/e0 tag 0 dma 507904 out
Nov 20 21:50:12 milu kernel:         res 50/00:00:c6:95:a9/00:00:08:00:00/e0 Emask 0x10 (ATA bus error)


milu:~# cat /proc/interrupts 
           CPU0       CPU1       
  0:        555          0   IO-APIC-edge      timer
  1:      58816          0   IO-APIC-edge      i8042
  8:          1          0   IO-APIC-edge      rtc0
  9:          0          0   IO-APIC-fasteoi   acpi
 16:    2757269          0   IO-APIC-fasteoi   uhci_hcd:usb3, nvidia
 18:     206547          0   IO-APIC-fasteoi   ahci, ehci_hcd:usb1, uhci_hcd:usb7
 19:     770339          0   IO-APIC-fasteoi   pata_jmicron, uhci_hcd:usb6
 21:          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
 23:          2          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb5
 44:       1606      50210   PCI-MSI-edge      ahci
 45:    1092296          0   PCI-MSI-edge      sky2@pci:0000:03:00.0
 46:        377          0   PCI-MSI-edge      snd_hda_intel
NMI:          0          0   Non-maskable interrupts
LOC:  133229573  133104650   Local timer interrupts
SPU:          0          0   Spurious interrupts
PMI:          0          0   Performance monitoring interrupts
IWI:          0          0   IRQ work interrupts
RES:    1719676    2541118   Rescheduling interrupts
CAL:      72289     222200   Function call interrupts
TLB:      69670      53360   TLB shootdowns
TRM:          0          0   Thermal event interrupts
THR:          0          0   Threshold APIC interrupts
MCE:          0          0   Machine check exceptions
MCP:        438        438   Machine check polls
ERR:          0
MIS:          0

milu:~# lspci
00:00.0 Host bridge: Intel Corporation 82P965/G965 Memory Controller Hub (rev 02)
00:01.0 PCI bridge: Intel Corporation 82P965/G965 PCI Express Root Port (rev 02)
00:1a.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #4 (rev 02)
00:1a.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #5 (rev 02)
00:1a.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #2 (rev 02)
00:1b.0 Audio device: Intel Corporation 82801H (ICH8 Family) HD Audio Controller (rev 02)
00:1c.0 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 1 (rev 02)
00:1c.1 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 2 (rev 02)
00:1c.2 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 3 (rev 02)
00:1d.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #1 (rev 02)
00:1d.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #2 (rev 02)
00:1d.2 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #3 (rev 02)
00:1d.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #1 (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev f2)
00:1f.0 ISA bridge: Intel Corporation 82801HB/HR (ICH8/R) LPC Interface Controller (rev 02)
00:1f.2 SATA controller: Intel Corporation 82801HB (ICH8) 4 port SATA AHCI Controller (rev 02)
00:1f.3 SMBus: Intel Corporation 82801H (ICH8 Family) SMBus Controller (rev 02)
01:00.0 VGA compatible controller: nVidia Corporation G94 [GeForce 9600 GT] (rev a1)
03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller (rev 13)
04:00.0 SATA controller: JMicron Technology Corp. JMB362/JMB363 Serial ATA Controller (rev 02)
04:00.1 IDE interface: JMicron Technology Corp. JMB362/JMB363 Serial ATA Controller (rev 02)
05:07.0 FireWire (IEEE 1394): Texas Instruments TSB43AB23 IEEE-1394a-2000 Controller (PHY/Link)

Best regards,

-- 
Milan Kocian
