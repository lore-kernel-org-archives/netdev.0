From: jamal <hadi@cyberus.ca>
Subject: Re: Kernel BUG: Qos seg. fault
Date: 24 May 2004 14:11:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1085422317.1043.9.camel@jzny.localdomain>
References: <40B1E325.80408@upf.edu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jaume Catarineu <jaume.catarineu@upf.edu>
In-Reply-To: <40B1E325.80408@upf.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Can you try to reproduce this problem without the new changes to the
tbf qdisc?
Example can you reproduce this without tbf being at the root?
I have access to a 2.4.21 and 2.6.1 machines which i cant upgrade right
now. I also have a few spare cycles today so i could chase this.
Get rid of tbf at root and see if this still happens

cheers,
jamal

On Mon, 2004-05-24 at 07:57, Jaume Catarineu wrote:
> Hi all,
> 
> I've configured succesfuly different QoS configurations, but there is
> one that *allways* returns a segmentation fault in the kernel module (or
> code). This part of the kernel seems to crash when installing an IP
> filter. I've tried the code in 2 different computers with different
> hardware and even different kernel version (2.4.25 and 2.6.4)
> 
> The code is the following:
> -------START--------
> tc qdisc add dev lo root handle 1: tbf rate 250kbit burst 5k limit 5k
> tc qdisc add dev lo parent 1: handle 20:  prio
> tc qdisc add dev lo parent 20:1 handle 210: sfq perturb 10
> tc qdisc add dev lo parent 20:2 handle 220: tbf rate 250kbit burst 5k \
>                                                      limit  5k
> tc qdisc add dev lo parent 20:3 handle 230: sfq perturb 10
> 
> tc filter add dev $ETH_IPSEC protocol ip parent 1:0 prio 1 handle 2 \
>                                                  fw flowid 20:3
> -------END----------
> 
> The line "tc filter..." produces the system crash. Actually, the system
> is usable, but any command refering the QoS hangs (tc, iptables...).
> Even the system shutdown is not available because Linux freezes when
> stopping the network. It seems that is something related to the filter
> section in the QoS modules.
> 
> In the files attached are described the technical characteristics of the
> computers.
> 
> Thank you for your work.
> Jaume,
> 
> 
> 
> 
> ______________________________________________________________________
> 
> processor       : 0
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 8
> model name      : Pentium III (Coppermine)
> stepping        : 3
> cpu MHz         : 731.474
> cache size      : 256 KB
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 2
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse
> bogomips        : 1458.17
> 
> 
> 
> Linux version 2.4.25 (root@servidor) (gcc version 3.2.2 20030222 (Red Hat Linux 3.2.2-5)) #2 Tue Mar 23 19:36:49 CET 2004
> 
> 
> =======modules after the seg fault========
> sch_sfq                 4128   2 (autoclean)
> sch_prio                3968   1 (autoclean)
> sch_tbf                 4160   2 (autoclean)
> ipt_MARK                1368   0 (autoclean)
> iptable_mangle          2776   0 (autoclean)
> ipt_MASQUERADE          2200   1 (autoclean)
> iptable_nat            21208   1 (autoclean) [ipt_MASQUERADE]
> ip_conntrack           29800   0 (autoclean) [ipt_MASQUERADE iptable_nat]
> 3c59x                  29456   2
> ipt_REJECT              4344   0 (autoclean)
> iptable_filter          2412   0 (autoclean)
> ip_tables              15712   8 [ipt_MARK iptable_mangle ipt_MASQUERADE iptable_nat ipt_REJECT iptable_filter]
> keybdev                 3136   0 (unused)
> mousedev                5556   0 (unused)
> input                   5760   0 [keybdev mousedev]
> hid                    12408   0 (unused)
> 
> 
> ========= PCI DEVICES =========
> 00:00.0 Host bridge: VIA Technologies, Inc. VT8605 [ProSavage PM133] (rev 81)
>         Subsystem: Asustek Computer, Inc.: Unknown device 802c
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
>         Latency: 0
>         Region 0: Memory at e4000000 (32-bit, prefetchable) [size=64M]
>         Capabilities: [a0] AGP version 2.0
>                 Status: RQ=31 SBA+ 64bit- FW- Rate=x1,x2,x4
>                 Command: RQ=0 SBA- AGP- 64bit- FW- Rate=<none>
>         Capabilities: [c0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:01.0 PCI bridge: VIA Technologies, Inc. VT8605 [PM133 AGP] (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR+
>         Latency: 0
>         Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
>         I/O behind bridge: 0000e000-0000dfff
>         Memory behind bridge: e2000000-e2dfffff
>         Prefetchable memory behind bridge: e2f00000-e3ffffff
>         BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:04.0 ISA bridge: VIA Technologies, Inc. VT82C686 [Apollo Super South] (rev 22)
>         Subsystem: Asustek Computer, Inc.: Unknown device 802c
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
>         Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
> 
> 00:04.1 IDE interface: VIA Technologies, Inc. VT82C586/B/686A/B PIPC Bus Master IDE (rev 10) (prog-if 8a [Master SecP PriP])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
>         Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32
>         Region 4: I/O ports at d800 [size=16]
>         Capabilities: [c0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:04.2 USB Controller: VIA Technologies, Inc. USB (rev 10) (prog-if 00 [UHCI])
>         Subsystem: VIA Technologies, Inc. (Wrong ID) USB Controller
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32, cache line size 08
>         Interrupt: pin D routed to IRQ 9
>         Region 4: I/O ports at d400 [size=32]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:04.3 USB Controller: VIA Technologies, Inc. USB (rev 10) (prog-if 00 [UHCI])
>         Subsystem: VIA Technologies, Inc. (Wrong ID) USB Controller
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32, cache line size 08
>         Interrupt: pin D routed to IRQ 9
>         Region 4: I/O ports at d000 [size=32]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:04.4 Host bridge: VIA Technologies, Inc. VT82C686 [Apollo Super ACPI] (rev 30)
>         Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Capabilities: [68] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:0e.0 SCSI storage controller: LSI Logic / Symbios Logic 53c896 (rev 05)
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+ Stepping- SERR- FastB2B-
>         Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 72 (4250ns min, 16000ns max), cache line size 08
>         Interrupt: pin A routed to IRQ 10
>         Region 0: I/O ports at b800 [size=256]
>         Region 1: Memory at e1800000 (64-bit, non-prefetchable) [size=1K]
>         Region 3: Memory at e1000000 (64-bit, non-prefetchable) [size=8K]
>         Expansion ROM at <unassigned> [disabled] [size=128K]
>         Capabilities: [40] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:0e.1 SCSI storage controller: LSI Logic / Symbios Logic 53c896 (rev 05)
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+ Stepping- SERR- FastB2B-
>         Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 72 (4250ns min, 16000ns max), cache line size 08
>         Interrupt: pin B routed to IRQ 5
>         Region 0: I/O ports at b400 [size=256]
>         Region 1: Memory at e0800000 (64-bit, non-prefetchable) [size=1K]
>         Region 3: Memory at e0000000 (64-bit, non-prefetchable) [size=8K]
>         Expansion ROM at <unassigned> [disabled] [size=128K]
>         Capabilities: [40] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:0f.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado] (rev 74)
>         Subsystem: 3Com Corporation 3C905C-TX Fast Etherlink for PC Management NIC
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32 (2500ns min, 2500ns max), cache line size 08
>         Interrupt: pin A routed to IRQ 5
>         Region 0: I/O ports at b000 [size=128]
>         Region 1: Memory at df800000 (32-bit, non-prefetchable) [size=128]
>         Expansion ROM at <unassigned> [disabled] [size=128K]
>         Capabilities: [dc] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=2 PME-
> 
> 00:10.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado] (rev 74)
>         Subsystem: 3Com Corporation 3C905C-TX Fast Etherlink for PC Management NIC
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32 (2500ns min, 2500ns max), cache line size 08
>         Interrupt: pin A routed to IRQ 9
>         Region 0: I/O ports at a800 [size=128]
>         Region 1: Memory at df000000 (32-bit, non-prefetchable) [size=128]
>         Expansion ROM at <unassigned> [disabled] [size=128K]
>         Capabilities: [dc] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=2 PME-
> 
> 01:00.0 VGA compatible controller: Intel Corp. i740 (rev 21) (prog-if
> 00 [VGA])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> 	ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium
> 	>TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 11
>         Region 0: Memory at e3000000 (32-bit, prefetchable) [size=16M]
>         Region 1: Memory at e2000000 (32-bit, non-prefetchable)
> 	[size=512K]
>         Expansion ROM at e2fc0000 [disabled] [size=256K]
>         Capabilities: [d0] AGP version 1.0
>                 Status: RQ=31 SBA+ 64bit- FW- Rate=x1,x2
>                 Command: RQ=0 SBA- AGP- 64bit- FW- Rate=<none>
>         Capabilities: [dc] Power Management version 1
>                 Flags: PMEClk- DSI+ D1+ D2- AuxCurrent=0mA
> 		PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 
> 
> 
> 
> ______________________________________________________________________
> 
> processor       : 0
> vendor_id       : AuthenticAMD
> cpu family      : 6
> model           : 6
> model name      : AMD Athlon(TM) XP 2000+
> stepping        : 2
> cpu MHz         : 1666.562
> cache size      : 256 KB
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 1
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
> mca cmov pat pse36 mmx fxsr sse syscall mmxext 3dnowext 3dnow
> bogomips        : 3301.37
> 
> 
> =======MODULES AFTER SEG FAULT ============
> sch_sfq 5568 2 - Live 0xe1e4e000
> sch_prio 5376 1 - Live 0xe1e2c000
> sch_tbf 6592 2 - Live 0xe1e29000
> vmnet 30608 8 - Live 0xe1e58000
> vmmon 48664 0 - Live 0xe1e36000
> sg 38752 0 - Live 0xe1e43000
> sr_mod 17764 0 - Live 0xe1e30000
> lp 12200 0 - Live 0xe1e25000
> md5 4160 1 - Live 0xe0ab6000
> ipv6 252288 8 - Live 0xe0d7a000
> nls_cp437 5632 4 - Live 0xe0ab3000
> smbfs 67768 5 - Live 0xe0b02000
> snd_seq_oss 34112 0 - Live 0xe0a48000
> snd_seq_midi_event 8192 1 snd_seq_oss, Live 0xe0a2b000
> snd_seq 56336 4 snd_seq_oss,snd_seq_midi_event, Live 0xe0af3000
> snd_pcm_oss 52388 0 - Live 0xe0ae5000
> snd_mixer_oss 18688 1 snd_pcm_oss, Live 0xe0aad000
> snd_cmipci 33588 1 - Live 0xe0a53000
> snd_pcm 99236 2 snd_pcm_oss,snd_cmipci, Live 0xe0acb000
> snd_page_alloc 11972 1 snd_pcm, Live 0xe0a27000
> snd_opl3_lib 10752 1 snd_cmipci, Live 0xe0a17000
> snd_timer 25220 3 snd_seq,snd_pcm,snd_opl3_lib, Live 0xe0a30000
> snd_hwdep 9696 1 snd_opl3_lib, Live 0xe0a13000
> gameport 4736 1 snd_cmipci, Live 0xe0a10000
> snd_mpu401_uart 7808 1 snd_cmipci, Live 0xe0a0d000
> snd_rawmidi 25312 1 snd_mpu401_uart, Live 0xe09d7000
> snd_seq_device 7880 4 snd_seq_oss,snd_seq,snd_opl3_lib,snd_rawmidi,
> Live 0xe09d4000
> snd 53828 15
> snd_seq_oss,snd_seq_midi_event,snd_seq,snd_pcm_oss,snd_mixer_oss,snd_cmipci,snd_pcm,snd_opl3_lib,snd_timer,snd_hwdep,snd_mpu401_uart,snd_rawmidi,snd_seq_device,
> Live 0xe0a39000
> soundcore 9888 1 snd, Live 0xe08f5000
> af_packet 22536 2 - Live 0xe09a6000
> hid 44608 0 - Live 0xe0a1b000
> ide_floppy 17408 0 - Live 0xe09a0000
> ide_cd 41156 0 - Live 0xe09c8000
> cdrom 38048 2 sr_mod,ide_cd, Live 0xe09bd000
> floppy 60628 0 - Live 0xe09fd000
> 8139too 24384 0 - Live 0xe0999000
> mii 5248 1 8139too, Live 0xe08ed000
> ohci1394 34180 0 - Live 0xe0949000
> ieee1394 319032 1 ohci1394, Live 0xe0a5e000
> ext3 117288 1 - Live 0xe09df000
> jbd 61272 1 ext3, Live 0xe09ad000
> nls_cp850 4800 2 - Live 0xe08d7000
> vfat 15680 2 - Live 0xe08da000
> fat 48000 1 vfat, Live 0xe098c000
> nls_iso8859_1 3968 7 - Live 0xe0802000
> ntfs 92108 1 - Live 0xe0953000
> nvidia 2074216 12 - Live 0xe0b7e000
> via_agp 7680 1 - Live 0xe0829000
> agpgart 30952 2 via_agp, Live 0xe08bf000
> parport_pc 33088 1 - Live 0xe08e0000
> imm 12296 0 - Live 0xe08ba000
> scsi_mod 118328 3 sg,sr_mod,imm, Live 0xe08f9000
> parport 42440 3 lp,parport_pc,imm, Live 0xe08c8000
> usblp 12928 0 - Live 0xe0813000
> ehci_hcd 25732 0 - Live 0xe0821000
> uhci_hcd 31120 0 - Live 0xe0818000
> usbcore 104668 6 hid,usblp,ehci_hcd,uhci_hcd, Live 0xe082c000
> rtc 12920 0 - Live 0xe0808000
> 
> 
> Linux version 2.6.4 (root@Amadeus) (gcc version 3.3.2 (Mandrake Linux
> 10.0 3.3.2-6mdk)) #1 Tue Mar 23 01:52:21 GMT 2004
> 
> ========== PCI ==============
> 00:00.0 Host bridge: VIA Technologies, Inc. VT8366/A/7 [Apollo KT266/A/333]
> 	Subsystem: Asustek Computer, Inc. A7V333 Mainboard
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
> 	Latency: 0
> 	Region 0: Memory at e0000000 (32-bit, prefetchable) [size=128M]
> 	Capabilities: <available only to root>
> 
> 00:01.0 PCI bridge: VIA Technologies, Inc. VT8366/A/7 [Apollo KT266/A/333 AGP] (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
> 	Latency: 0
> 	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
> 	I/O behind bridge: 0000e000-0000dfff
> 	Memory behind bridge: d6000000-d76fffff
> 	Prefetchable memory behind bridge: d7700000-dfffffff
> 	BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
> 	Capabilities: <available only to root>
> 
> 00:05.0 Multimedia audio controller: C-Media Electronics Inc CM8738 (rev 10)
> 	Subsystem: Asustek Computer, Inc. CMI8738 6ch-MX
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32 (500ns min, 6000ns max)
> 	Interrupt: pin A routed to IRQ 10
> 	Region 0: I/O ports at d800 [size=256]
> 	Capabilities: <available only to root>
> 
> 00:09.0 USB Controller: VIA Technologies, Inc. USB (rev 50) (prog-if 00 [UHCI])
> 	Subsystem: Asustek Computer, Inc.: Unknown device 8080
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32, cache line size 08
> 	Interrupt: pin A routed to IRQ 5
> 	Region 4: I/O ports at d400 [size=32]
> 	Capabilities: <available only to root>
> 
> 00:09.1 USB Controller: VIA Technologies, Inc. USB (rev 50) (prog-if 00 [UHCI])
> 	Subsystem: Asustek Computer, Inc.: Unknown device 8080
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32, cache line size 08
> 	Interrupt: pin B routed to IRQ 11
> 	Region 4: I/O ports at d000 [size=32]
> 	Capabilities: <available only to root>
> 
> 00:09.2 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 51) (prog-if 20 [EHCI])
> 	Subsystem: Asustek Computer, Inc.: Unknown device 8080
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32, cache line size 10
> 	Interrupt: pin C routed to IRQ 10
> 	Region 0: Memory at d5800000 (32-bit, non-prefetchable) [size=256]
> 	Capabilities: <available only to root>
> 
> 00:0c.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+ (rev 10)
> 	Subsystem: Realtek Semiconductor Co., Ltd. RT8139
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32 (8000ns min, 16000ns max)
> 	Interrupt: pin A routed to IRQ 5
> 	Region 0: I/O ports at b800 [size=256]
> 	Region 1: Memory at d5000000 (32-bit, non-prefetchable) [size=256]
> 	Capabilities: <available only to root>
> 
> 00:0d.0 FireWire (IEEE 1394): VIA Technologies, Inc. IEEE 1394 Host Controller (rev 46) (prog-if 10 [OHCI])
> 	Subsystem: VIA Technologies, Inc. IEEE 1394 Host Controller
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping+ SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32 (8000ns max), cache line size 08
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: Memory at d4800000 (32-bit, non-prefetchable) [size=2K]
> 	Region 1: I/O ports at b400 [size=128]
> 	Capabilities: <available only to root>
> 
> 00:11.0 ISA bridge: VIA Technologies, Inc. VT8233A ISA Bridge
> 	Subsystem: Asustek Computer, Inc.: Unknown device 808c
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 0
> 	Capabilities: <available only to root>
> 
> 00:11.1 IDE interface: VIA Technologies, Inc. VT82C586A/B/VT82C686/A/B/VT8233/A/C/VT8235 PIPC Bus Master IDE (rev 06) (prog-if 8a [Master SecP PriP])
> 	Subsystem: Asustek Computer, Inc. A7V8X motherboard
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32
> 	Interrupt: pin A routed to IRQ 0
> 	Region 4: I/O ports at b000 [size=16]
> 	Capabilities: <available only to root>
> 
> 00:11.2 USB Controller: VIA Technologies, Inc. USB (rev 23) (prog-if 00 [UHCI])
> 	Subsystem: Asustek Computer, Inc. A7V8X motherboard
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32, cache line size 08
> 	Interrupt: pin D routed to IRQ 9
> 	Region 4: I/O ports at a800 [size=32]
> 	Capabilities: <available only to root>
> 
> 00:11.3 USB Controller: VIA Technologies, Inc. USB (rev 23) (prog-if 00 [UHCI])
> 	Subsystem: Asustek Computer, Inc. A7V8X motherboard
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32, cache line size 08
> 	Interrupt: pin D routed to IRQ 9
> 	Region 4: I/O ports at a400 [size=32]
> 	Capabilities: <available only to root>
> 
> 01:00.0 VGA compatible controller: nVidia Corporation NV17 [GeForce4 MX 460] (rev a3) (prog-if 00 [VGA])
> 	Subsystem: Micro-Star International Co., Ltd.: Unknown device 8670
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 248 (1250ns min, 250ns max)
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: Memory at d6000000 (32-bit, non-prefetchable) [size=16M]
> 	Region 1: Memory at d8000000 (32-bit, prefetchable) [size=128M]
> 	Region 2: Memory at d7800000 (32-bit, prefetchable) [size=512K]
> 	Expansion ROM at d77e0000 [disabled] [size=128K]
> 	Capabilities: <available only to root>
> 
> 
> 
> 
