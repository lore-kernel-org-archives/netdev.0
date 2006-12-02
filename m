From: Marko =?iso-8859-15?q?H=E4nninen?= <m.hanninen@kymp.net>
Subject: 2.6.19: Kernel panic with "ifconfig eth0 up"
Date: Sat, 2 Dec 2006 10:30:17 +0200
Message-ID: <200612021030.17796.m.hanninen@kymp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp10.kymp.net ([80.248.96.136]:5613 "EHLO smtp10.kymp.net")
	by vger.kernel.org with ESMTP id S1162834AbWLBIa0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 03:30:26 -0500
Received: from adsl-215-248-58.kymp.net (adsl-215-248-58.kymp.net [82.215.248.58])
	by smtp10.kymp.net (8.13.6/8.13.3) with SMTP id kB28UIse004747
	for <netdev@vger.kernel.org>; Sat, 2 Dec 2006 10:30:18 +0200
Content-Disposition: inline
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm having a kernel panic issue when bringing eth0 up. It happens every=
 time=20
with command "ifconfig eth0 up". This is vanilla 2.6.19 kernel from ker=
nel.org.=20
Works ok with 2.6.18.3. The system is a Acer Aspire 5021 WLMI laptop.
Is there anything I can try? I'm not subscribed to the list, so please =
CC me.



acer ~ # ifconfig eth0 up
skb_over_panic: text:ffffffff80489669 len:56 put:16 head:ffff81003ec6e2=
00=20
data:ffff81003ec6e210 tail:ffff81003ec6e248 end:ffff81003ec6e240 dev:et=
h0
----------- [cut here ] --------- [please bite here ] ---------
Kernel BUG at net/core/skbuff.c:93
invalid opcode: 0000 [1] PREEMPT
CPU 0
Modules linked in: ohci_hcd ehci_hcd joydev
Pid: 0, comm: swapper Not tainted 2.6.19 #1
RIP: 0010:[<ffffffff80430dc1>]  [<ffffffff80430dc1>] skb_over_panic+0x5=
c/0x6b
RSP: 0018:ffffffff805f7dc0  EFLAGS: 00010286
RAX: 0000000000000097 RBX: ffff81003ec6e238 RCX: 000000000000399e
RDX: 00000000ffffff01 RSI: 000000000000399e RDI: ffffffff80538690
RBP: ffff81003f8a2000 R08: 0000000000000008 R09: 0000000000000000
R10: 0000000000000010 R11: ffff810001fcbdf0 R12: ffff81003e4a5580
R13: 0000000000000010 R14: ffffffff805f7e90 R15: ffff81003f8cd740
=46S:  00002b6c94691d80(0000) GS:ffffffff805b3000(0000) knlGS:000000000=
0000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00002b6c9434abf0 CR3: 000000003edf1000 CR4: 00000000000006e0
Process swapper (pid: 0, threadinfo ffffffff805c2000, task ffffffff8053=
0360)
Stack:  ffff81003ec6e248 ffff81003ec6e240 ffff81003f8a2000 ffffffff8048=
9671
 0000000000000010 ffff81003e4a5300 ffffffff80572d80 0000000000000000
 0000000000000002 00000000000002ff 0200000000000000 00000000000080fe
Call Trace:
 <IRQ>  [<ffffffff80489671>] ndisc_send_rs+0x1c9/0x417
 [<ffffffff8047e567>] addrconf_dad_completed+0x86/0xde
 [<ffffffff80480fdb>] addrconf_dad_timer+0x0/0x13f
 [<ffffffff8048106d>] addrconf_dad_timer+0x92/0x13f
 [<ffffffff8028019c>] run_timer_softirq+0x14b/0x1df
 [<ffffffff802118ae>] __do_softirq+0x46/0x90
 [<ffffffff8025a8dc>] call_softirq+0x1c/0x28
 [<ffffffff8026501b>] do_softirq+0x2c/0x7d
 [<ffffffff8027ce14>] irq_exit+0x3f/0x51
 [<ffffffff802652ee>] do_IRQ+0x87/0x97
 [<ffffffff8025a101>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8037d06c>] acpi_processor_idle+0x195/0x40b
 [<ffffffff8037d058>] acpi_processor_idle+0x181/0x40b
 [<ffffffff802846ef>] atomic_notifier_call_chain+0x37/0x42
 [<ffffffff8037ced7>] acpi_processor_idle+0x0/0x40b
 [<ffffffff80245001>] cpu_idle+0x3c/0x79
 [<ffffffff805c5673>] start_kernel+0x1cc/0x1d1
 [<ffffffff805c513e>] _sinittext+0x13e/0x142


Code: 0f 0b 68 f5 03 50 80 c2 5d 00 48 83 c4 18 c3 48 85 ff 74 1e
RIP  [<ffffffff80430dc1>] skb_over_panic+0x5c/0x6b
 RSP <ffffffff805f7dc0>
 <0>Kernel panic - not syncing: Aiee, killing interrupt handler!
 _



acer ~ # cat /proc/version
Linux version 2.6.19 (root@acer) (gcc version 4.1.1 (Gentoo 4.1.1-r1)) =
#1 PREEMPT Fri Dec 1 17:48:21 EET 2006



acer ~ # /usr/src/linux/scripts/ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux acer 2.6.19 #1 PREEMPT Fri Dec 1 17:48:21 EET 2006 x86_64 AMD Tur=
ion(tm) 64 Mobile Technology ML-28 AuthenticAMD GNU/Linux

Gnu C                  4.1.1
Gnu make               3.81
binutils               2.16.1
util-linux             2.12r
mount                  2.12r
module-init-tools      3.2.2
e2fsprogs              1.39
reiserfsprogs          3.6.19
Linux C Library        > libc.2.4
Dynamic linker (ldd)   2.4
Procps                 3.2.6
Net-tools              1.60
Kbd                    1.12
Sh-utils               6.4
udev                   087
Modules Loaded         ohci_hcd ehci_hcd joydev



acer ~ # cat /proc/cpuinfo
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 15
model           : 36
model name      : AMD Turion(tm) 64 Mobile Technology ML-28
stepping        : 2
cpu MHz         : 800.000
cache size      : 512 KB
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge =
mca cmov pat pse36 clflush mmx fxsr sse sse2 syscall nx mmxext fxsr_opt=
 lm 3dnowext 3dnow pni lahf_lm
bogomips        : 1601.01
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management: ts fid vid ttp tm stc



acer ~ # cat /proc/modules
ohci_hcd 21380 0 - Live 0xffffffff8800d000
ehci_hcd 32392 0 - Live 0xffffffff88004000
joydev 11328 0 - Live 0xffffffff88000000



acer ~ # cat /proc/ioports
0000-001f : dma1
0020-0021 : pic1
0040-0043 : timer0
0050-0053 : timer1
0060-006f : keyboard
0070-0077 : rtc
0080-008f : dma page reg
00a0-00a1 : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : ide1
01f0-01f7 : ide0
0376-0376 : ide1
03c0-03df : vesafb
03f6-03f6 : ide0
040b-040b : pnp 00:08
0500-051f : pnp 00:08
0cf8-0cff : PCI conf1
1080-1080 : motherboard
  1080-1080 : pnp 00:08
1200-120f : motherboard
  1200-120f : pnp 00:08
8000-805f : motherboard
  8000-8003 : ACPI PM1a_EVT_BLK
  8004-8005 : ACPI PM1a_CNT_BLK
  8008-800b : ACPI PM_TMR
  8010-8015 : ACPI CPU throttle
  8020-8027 : ACPI GPE0_BLK
8100-8100 : ACPI PM2_CNT_BLK
8104-8107 : ACPI PM1b_EVT_BLK
8400-840f : 0000:00:14.0
8410-841f : 0000:00:14.1
  8410-8417 : ide0
  8418-841f : ide1
9000-9fff : PCI Bus #01
  9000-90ff : 0000:01:00.0
a000-afff : PCI Bus #06
  a000-a0ff : 0000:06:07.0
    a000-a0ff : r8169
  a400-a4ff : PCI CardBus #07
  a800-a8ff : PCI CardBus #07



acer ~ # cat /proc/iomem
00000000-0009b7ff : System RAM
0009b800-0009ffff : reserved
000a0000-000bffff : Video RAM area
000c0000-000ce1ff : Video ROM
000f0000-000fffff : System ROM
00100000-3fe9ffff : System RAM
  00200000-0049f17e : Kernel code
  0049f17f-005b2fa7 : Kernel data
3fea0000-3feadfff : ACPI Tables
3feae000-3fefffff : ACPI Non-volatile Storage
3ff00000-3fffffff : reserved
50000000-52ffffff : PCI Bus #06
  50000000-51ffffff : PCI CardBus #07
  52000000-5201ffff : 0000:06:07.0
54000000-55ffffff : PCI CardBus #07
c0000000-c0000fff : 0000:00:13.0
  c0000000-c0000fff : ohci_hcd
c0001000-c0001fff : 0000:00:13.1
  c0001000-c0001fff : ohci_hcd
c0002000-c0002fff : 0000:00:13.2
  c0002000-c0002fff : ehci_hcd
c0003000-c00033ff : 0000:00:14.0
c0003400-c00034ff : 0000:00:14.5
  c0003400-c00034ff : ATI IXP AC97
c0003800-c00038ff : 0000:00:14.6
c0100000-c01fffff : PCI Bus #01
  c0100000-c010ffff : 0000:01:00.0
  c0120000-c013ffff : 0000:01:00.0
c0200000-c02fffff : PCI Bus #06
  c0200000-c0203fff : 0000:06:06.2
  c0204000-c0205fff : 0000:06:05.0
  c0206000-c0207fff : 0000:06:06.3
  c0208000-c02087ff : 0000:06:06.2
  c0208800-c02088ff : 0000:06:06.4
  c0208c00-c0208cff : 0000:06:06.4
  c0209000-c02090ff : 0000:06:06.4
  c0209400-c02094ff : 0000:06:07.0
    c0209400-c02094ff : r8169
  c020a000-c020afff : 0000:06:06.0
c8000000-cfffffff : PCI Bus #01
  c8000000-cfffffff : 0000:01:00.0
    c8000000-c8ffffff : vesafb
fec00000-fec0ffff : reserved
fee00000-fee00fff : reserved
fff80000-ffffffff : reserved



acer ~ # lspci -vvv
00:00.0 Host bridge: ATI Technologies Inc RS480 Host Bridge (rev 01)
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort+ >SERR- <PERR-
        Latency: 64

00:02.0 PCI bridge: ATI Technologies Inc RS480 PCI-X Root Port (prog-if=
 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size 08
        Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latenc=
y=3D0
        I/O behind bridge: 00009000-00009fff
        Memory behind bridge: c0100000-c01fffff
        Prefetchable memory behind bridge: c8000000-cfffffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1=
-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
        Capabilities: [58] Express Root Port (Slot-) IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, E=
xtTag+
                Device: Latency L0s <64ns, L1 <1us
                Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsuppor=
ted+
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
                Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, =
Port 0
                Link: Latency L0s <64ns, L1 <1us
                Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
                Link: Speed 2.5Gb/s, Width x16
                Root: Correctable- Non-Fatal- Fatal- PME-
        Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=3D=
0/0 Enable+
                Address: fee0100c  Data: 4139
        Capabilities: [b0] #0d [0000]
        Capabilities: [b8] HyperTransport: MSI Mapping

00:06.0 PCI bridge: ATI Technologies Inc RS480 PCI Bridge (prog-if 00 [=
Normal decode])
        Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size 08
        Bus: primary=3D00, secondary=3D09, subordinate=3D09, sec-latenc=
y=3D0
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: fff00000-000fffff
        Prefetchable memory behind bridge: fff00000-000fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1=
-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
        Capabilities: [58] Express Root Port (Slot-) IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, E=
xtTag+
                Device: Latency L0s <64ns, L1 <1us
                Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsuppor=
ted+
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, P=
ort 247
                Link: Latency L0s <64ns, L1 <1us
                Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
                Link: Speed 2.5Gb/s, Width x1
                Root: Correctable- Non-Fatal- Fatal- PME-
        Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=3D=
0/0 Enable+
                Address: fee0100c  Data: 4141
        Capabilities: [b0] #0d [0000]
        Capabilities: [b8] HyperTransport: MSI Mapping

00:07.0 PCI bridge: ATI Technologies Inc Unknown device 5a39 (prog-if 0=
0 [Normal decode])
        Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Bus: primary=3D00, secondary=3D04, subordinate=3D05, sec-latenc=
y=3D0
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: fff00000-000fffff
        Prefetchable memory behind bridge: fff00000-000fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1=
-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
        Capabilities: [58] Express Root Port (Slot-) IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, E=
xtTag+
                Device: Latency L0s <64ns, L1 <1us
                Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsuppor=
ted+
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, P=
ort 247
                Link: Latency L0s <64ns, L1 <1us
                Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
                Link: Speed 2.5Gb/s, Width x1
                Root: Correctable- Non-Fatal- Fatal- PME-
        Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=3D=
0/0 Enable+
                Address: fee0100c  Data: 4149
        Capabilities: [b0] #0d [0000]
        Capabilities: [b8] HyperTransport: MSI Mapping

00:13.0 USB Controller: ATI Technologies Inc IXP SB400 USB Host Control=
ler (prog-if 10 [OHCI])
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64, Cache Line Size 10
        Interrupt: pin A routed to IRQ 11
        Region 0: Memory at c0000000 (32-bit, non-prefetchable) [size=3D=
4K]
        Capabilities: [d0] Message Signalled Interrupts: 64bit- Queue=3D=
0/0 Enable-
                Address: 00000000  Data: 0000

00:13.1 USB Controller: ATI Technologies Inc IXP SB400 USB Host Control=
ler (prog-if 10 [OHCI])
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64, Cache Line Size 10
        Interrupt: pin A routed to IRQ 11
        Region 0: Memory at c0001000 (32-bit, non-prefetchable) [size=3D=
4K]
        Capabilities: [d0] Message Signalled Interrupts: 64bit- Queue=3D=
0/0 Enable-
                Address: 00000000  Data: 0000

00:13.2 USB Controller: ATI Technologies Inc IXP SB400 USB2 Host Contro=
ller (prog-if 20 [EHCI])
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64, Cache Line Size 10
        Interrupt: pin A routed to IRQ 11
        Region 0: Memory at c0002000 (32-bit, non-prefetchable) [size=3D=
4K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1=
+,D2+,D3hot+,D3cold-)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
                Bridge: PM- B3+
        Capabilities: [d0] Message Signalled Interrupts: 64bit- Queue=3D=
0/0 Enable-
                Address: 00000000  Data: 0000

00:14.0 SMBus: ATI Technologies Inc IXP SB400 SMBus Controller (rev 11)
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR-
        Region 0: I/O ports at 8400 [size=3D16]
        Region 1: Memory at c0003000 (32-bit, non-prefetchable) [size=3D=
1K]
        Capabilities: [b0] HyperTransport: MSI Mapping

00:14.1 IDE interface: ATI Technologies Inc Standard Dual Channel PCI I=
DE Controller ATI (prog-if 8a [Master SecP PriP])
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin A routed to IRQ 10
        Region 0: I/O ports at <ignored>
        Region 1: I/O ports at <ignored>
        Region 2: I/O ports at <ignored>
        Region 3: I/O ports at <ignored>
        Region 4: I/O ports at 8410 [size=3D16]
        Capabilities: [70] Message Signalled Interrupts: 64bit- Queue=3D=
0/0 Enable-
                Address: 00000000  Data: 0000

00:14.3 ISA bridge: ATI Technologies Inc IXP SB400 PCI-ISA Bridge
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0

00:14.4 PCI bridge: ATI Technologies Inc IXP SB400 PCI-PCI Bridge (prog=
-if 01 [Subtractive decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64
        Bus: primary=3D00, secondary=3D06, subordinate=3D06, sec-latenc=
y=3D64
        I/O behind bridge: 0000a000-0000afff
        Memory behind bridge: c0200000-c02fffff
        Prefetchable memory behind bridge: 50000000-52ffffff
        Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-

00:14.5 Multimedia audio controller: ATI Technologies Inc IXP SB400 AC'=
97 Audio Controller (rev 02)
        Subsystem: Acer Incorporated [ALI] Unknown device 0079
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dslow >TAbort=
- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (500ns min), Cache Line Size 08
        Interrupt: pin B routed to IRQ 11
        Region 0: Memory at c0003400 (32-bit, non-prefetchable) [size=3D=
256]
        Capabilities: [40] Message Signalled Interrupts: 64bit- Queue=3D=
0/0 Enable-
                Address: 00000000  Data: 0000

00:14.6 Modem: ATI Technologies Inc ATI SB400 - AC'97 Modem Controller =
(rev 02) (prog-if 00 [Generic])
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dslow >TAbort=
- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (500ns min), Cache Line Size 08
        Interrupt: pin B routed to IRQ 11
        Region 0: Memory at c0003800 (32-bit, non-prefetchable) [size=3D=
256]
        Capabilities: [40] Message Signalled Interrupts: 64bit- Queue=3D=
0/0 Enable-
                Address: 00000000  Data: 0000

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron]=
 HyperTransport Technology Configuration
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR-
        Capabilities: [80] HyperTransport: Host or Secondary Interface
                !!! Possibly incomplete decoding
                Command: WarmRst+ DblEnd-
                Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- =
<CRCErr=3D8
                Link Config: MLWI=3D16bit MLWO=3D16bit LWI=3D16bit LWO=3D=
16bit
                Revision ID: 1.02

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron]=
 Address Map
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR-

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron]=
 DRAM Controller
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR-

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron]=
 Miscellaneous Control
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR-

01:00.0 VGA compatible controller: ATI Technologies Inc Radeon Mobility=
 X700 (PCIE) (prog-if 00 [VGA])
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR-
        Interrupt: pin A routed to IRQ 11
        Region 0: Memory at c8000000 (32-bit, prefetchable) [size=3D128=
M]
        Region 1: I/O ports at 9000 [size=3D256]
        Region 2: Memory at c0100000 (32-bit, non-prefetchable) [size=3D=
64K]
        [virtual] Expansion ROM at c0120000 [disabled] [size=3D128K]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0-,D1=
-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
        Capabilities: [58] Express Endpoint IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, E=
xtTag+
                Device: Latency L0s <256ns, L1 <4us
                Device: AtnBtn- AtnInd- PwrInd-
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsuppor=
ted-
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
                Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, =
Port 0
                Link: Latency L0s <256ns, L1 <2us
                Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
                Link: Speed 2.5Gb/s, Width x16
        Capabilities: [80] Message Signalled Interrupts: 64bit+ Queue=3D=
0/0 Enable-
                Address: 0000000000000000  Data: 0000

06:05.0 Network controller: Broadcom Corporation BCM4318 [AirForce One =
54g] 802.11g Wireless LAN Controller (rev 02)
        Subsystem: AMBIT Microsystem Corp. Aspire 3022WLMi
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64
        Interrupt: pin A routed to IRQ 10
        Region 0: Memory at c0204000 (32-bit, non-prefetchable) [size=3D=
8K]

06:06.0 CardBus bridge: Texas Instruments PCIxx21/x515 Cardbus Controll=
er
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64, Cache Line Size 10
        Interrupt: pin A routed to IRQ 11
        Region 0: Memory at c020a000 (32-bit, non-prefetchable) [size=3D=
4K]
        Bus: primary=3D06, secondary=3D07, subordinate=3D08, sec-latenc=
y=3D176
        Memory window 0: 50000000-51fff000 (prefetchable)
        Memory window 1: 54000000-55fff000 (prefetchable)
        I/O window 0: 0000a400-0000a4ff
        I/O window 1: 0000a800-0000a8ff
        BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset+ 16bInt+ Post=
Write-
        16-bit legacy interface ports at 0001

06:06.2 FireWire (IEEE 1394): Texas Instruments OHCI Compliant IEEE 139=
4 Host Controller (prog-if 10 [OHCI])
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (500ns min, 1000ns max), Cache Line Size 08
        Interrupt: pin C routed to IRQ 11
        Region 0: Memory at c0208000 (32-bit, non-prefetchable) [size=3D=
2K]
        Region 1: Memory at c0200000 (32-bit, non-prefetchable) [size=3D=
16K]
        Capabilities: [44] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1=
+,D2+,D3hot+,D3cold-)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

06:06.3 Mass storage controller: Texas Instruments PCIxx21 Integrated F=
lashMedia Controller
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (1750ns min, 1000ns max), Cache Line Size 08
        Interrupt: pin A routed to IRQ 11
        Region 0: Memory at c0206000 (32-bit, non-prefetchable) [size=3D=
8K]
        Capabilities: [44] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1=
+,D2+,D3hot+,D3cold-)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

06:06.4 Class 0805: Texas Instruments PCI6411, PCI6421, PCI6611, PCI662=
1, PCI7411, PCI7421, PCI7611, PCI7621 Secure Digital (SD) Controller
        Subsystem: Acer Incorporated [ALI] Unknown device 0080
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (1750ns min, 1000ns max), Cache Line Size 08
        Interrupt: pin A routed to IRQ 11
        Region 0: Memory at c0209000 (32-bit, non-prefetchable) [size=3D=
256]
        Region 1: Memory at c0208c00 (32-bit, non-prefetchable) [size=3D=
256]
        Region 2: Memory at c0208800 (32-bit, non-prefetchable) [size=3D=
256]
        Capabilities: [80] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1=
+,D2+,D3hot+,D3cold-)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

06:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 G=
igabit Ethernet (rev 10)
        Subsystem: Acer Incorporated [ALI] Unknown device 0079
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- Par=
Err- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (8000ns min, 16000ns max), Cache Line Size 10
        Interrupt: pin A routed to IRQ 10
        Region 0: I/O ports at a000 [size=3D256]
        Region 1: Memory at c0209400 (32-bit, non-prefetchable) [size=3D=
256]
        [virtual] Expansion ROM at 52000000 [disabled] [size=3D128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0-,=
D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-



acer ~ # cat /usr/src/linux/.config
#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.19
# Fri Dec  1 17:32:21 2006
#
CONFIG_X86_64=3Dy
CONFIG_64BIT=3Dy
CONFIG_X86=3Dy
CONFIG_ZONE_DMA32=3Dy
CONFIG_LOCKDEP_SUPPORT=3Dy
CONFIG_STACKTRACE_SUPPORT=3Dy
CONFIG_SEMAPHORE_SLEEPERS=3Dy
CONFIG_MMU=3Dy
CONFIG_RWSEM_GENERIC_SPINLOCK=3Dy
CONFIG_GENERIC_HWEIGHT=3Dy
CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
CONFIG_X86_CMPXCHG=3Dy
CONFIG_EARLY_PRINTK=3Dy
CONFIG_GENERIC_ISA_DMA=3Dy
CONFIG_GENERIC_IOMAP=3Dy
CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy
CONFIG_ARCH_POPULATES_NODE_MAP=3Dy
CONFIG_DMI=3Dy
CONFIG_AUDIT_ARCH=3Dy
CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"

#
# Code maturity level options
#
CONFIG_EXPERIMENTAL=3Dy
CONFIG_BROKEN_ON_SMP=3Dy
CONFIG_LOCK_KERNEL=3Dy
CONFIG_INIT_ENV_ARG_LIMIT=3D32

#
# General setup
#
CONFIG_LOCALVERSION=3D""
CONFIG_LOCALVERSION_AUTO=3Dy
CONFIG_SWAP=3Dy
CONFIG_SYSVIPC=3Dy
# CONFIG_IPC_NS is not set
CONFIG_POSIX_MQUEUE=3Dy
CONFIG_BSD_PROCESS_ACCT=3Dy
CONFIG_BSD_PROCESS_ACCT_V3=3Dy
# CONFIG_TASKSTATS is not set
# CONFIG_UTS_NS is not set
# CONFIG_AUDIT is not set
CONFIG_IKCONFIG=3Dy
CONFIG_IKCONFIG_PROC=3Dy
# CONFIG_RELAY is not set
CONFIG_INITRAMFS_SOURCE=3D""
CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy
CONFIG_SYSCTL=3Dy
# CONFIG_EMBEDDED is not set
CONFIG_UID16=3Dy
CONFIG_SYSCTL_SYSCALL=3Dy
CONFIG_KALLSYMS=3Dy
# CONFIG_KALLSYMS_EXTRA_PASS is not set
CONFIG_HOTPLUG=3Dy
CONFIG_PRINTK=3Dy
CONFIG_BUG=3Dy
CONFIG_ELF_CORE=3Dy
CONFIG_BASE_FULL=3Dy
CONFIG_FUTEX=3Dy
CONFIG_EPOLL=3Dy
CONFIG_SHMEM=3Dy
CONFIG_SLAB=3Dy
CONFIG_VM_EVENT_COUNTERS=3Dy
CONFIG_RT_MUTEXES=3Dy
# CONFIG_TINY_SHMEM is not set
CONFIG_BASE_SMALL=3D0
# CONFIG_SLOB is not set

#
# Loadable module support
#
CONFIG_MODULES=3Dy
CONFIG_MODULE_UNLOAD=3Dy
# CONFIG_MODULE_FORCE_UNLOAD is not set
CONFIG_MODVERSIONS=3Dy
CONFIG_MODULE_SRCVERSION_ALL=3Dy
CONFIG_KMOD=3Dy

#
# Block layer
#
CONFIG_BLOCK=3Dy
# CONFIG_LBD is not set
# CONFIG_BLK_DEV_IO_TRACE is not set
# CONFIG_LSF is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=3Dy
# CONFIG_IOSCHED_AS is not set
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_IOSCHED_CFQ=3Dy
# CONFIG_DEFAULT_AS is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=3Dy
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED=3D"cfq"

#
# Processor type and features
#
CONFIG_X86_PC=3Dy
# CONFIG_X86_VSMP is not set
CONFIG_MK8=3Dy
# CONFIG_MPSC is not set
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_L1_CACHE_BYTES=3D64
CONFIG_X86_L1_CACHE_SHIFT=3D6
CONFIG_X86_INTERNODE_CACHE_BYTES=3D64
CONFIG_X86_TSC=3Dy
CONFIG_X86_GOOD_APIC=3Dy
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=3Dy
CONFIG_X86_CPUID=3Dy
CONFIG_X86_IO_APIC=3Dy
CONFIG_X86_LOCAL_APIC=3Dy
CONFIG_MTRR=3Dy
# CONFIG_SMP is not set
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=3Dy
CONFIG_PREEMPT_BKL=3Dy
CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
CONFIG_ARCH_FLATMEM_ENABLE=3Dy
CONFIG_SELECT_MEMORY_MODEL=3Dy
CONFIG_FLATMEM_MANUAL=3Dy
# CONFIG_DISCONTIGMEM_MANUAL is not set
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=3Dy
CONFIG_FLAT_NODE_MEM_MAP=3Dy
# CONFIG_SPARSEMEM_STATIC is not set
CONFIG_SPLIT_PTLOCK_CPUS=3D4
CONFIG_RESOURCES_64BIT=3Dy
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy
CONFIG_HPET_TIMER=3Dy
CONFIG_HPET_EMULATE_RTC=3Dy
CONFIG_IOMMU=3Dy
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=3Dy
CONFIG_X86_MCE=3Dy
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=3Dy
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=3D0x200000
CONFIG_SECCOMP=3Dy
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_1000=3Dy
CONFIG_HZ=3D1000
CONFIG_REORDER=3Dy
CONFIG_K8_NB=3Dy
CONFIG_GENERIC_HARDIRQS=3Dy
CONFIG_GENERIC_IRQ_PROBE=3Dy
CONFIG_ISA_DMA_API=3Dy

#
# Power management options
#
CONFIG_PM=3Dy
# CONFIG_PM_LEGACY is not set
# CONFIG_PM_DEBUG is not set
# CONFIG_PM_SYSFS_DEPRECATED is not set
CONFIG_SOFTWARE_SUSPEND=3Dy
CONFIG_PM_STD_PARTITION=3D"/dev/hda5"

#
# ACPI (Advanced Configuration and Power Interface) Support
#
CONFIG_ACPI=3Dy
CONFIG_ACPI_SLEEP=3Dy
CONFIG_ACPI_SLEEP_PROC_FS=3Dy
# CONFIG_ACPI_SLEEP_PROC_SLEEP is not set
CONFIG_ACPI_AC=3Dy
CONFIG_ACPI_BATTERY=3Dy
CONFIG_ACPI_BUTTON=3Dy
CONFIG_ACPI_VIDEO=3Dy
CONFIG_ACPI_HOTKEY=3Dy
CONFIG_ACPI_FAN=3Dy
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=3Dy
CONFIG_ACPI_THERMAL=3Dy
# CONFIG_ACPI_ASUS is not set
# CONFIG_ACPI_IBM is not set
# CONFIG_ACPI_TOSHIBA is not set
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=3D0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_EC=3Dy
CONFIG_ACPI_POWER=3Dy
CONFIG_ACPI_SYSTEM=3Dy
CONFIG_X86_PM_TIMER=3Dy
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_SBS=3Dy

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=3Dy
CONFIG_CPU_FREQ_TABLE=3Dy
# CONFIG_CPU_FREQ_DEBUG is not set
CONFIG_CPU_FREQ_STAT=3Dy
CONFIG_CPU_FREQ_STAT_DETAILS=3Dy
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=3Dy
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=3Dy
CONFIG_CPU_FREQ_GOV_POWERSAVE=3Dy
CONFIG_CPU_FREQ_GOV_USERSPACE=3Dy
CONFIG_CPU_FREQ_GOV_ONDEMAND=3Dy
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=3Dy

#
# CPUFreq processor drivers
#
CONFIG_X86_POWERNOW_K8=3Dy
CONFIG_X86_POWERNOW_K8_ACPI=3Dy
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_ACPI_CPUFREQ=3Dy

#
# shared options
#
# CONFIG_X86_ACPI_CPUFREQ_PROC_INTF is not set
# CONFIG_X86_SPEEDSTEP_LIB is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=3Dy
CONFIG_PCI_DIRECT=3Dy
CONFIG_PCI_MMCONFIG=3Dy
CONFIG_PCIEPORTBUS=3Dy
CONFIG_PCIEAER=3Dy
CONFIG_PCI_MSI=3Dy
CONFIG_HT_IRQ=3Dy

#
# PCCARD (PCMCIA/CardBus) support
#
CONFIG_PCCARD=3Dm
# CONFIG_PCMCIA_DEBUG is not set
CONFIG_PCMCIA=3Dm
CONFIG_PCMCIA_LOAD_CIS=3Dy
CONFIG_PCMCIA_IOCTL=3Dy
CONFIG_CARDBUS=3Dy

#
# PC-card bridges
#
CONFIG_YENTA=3Dm
CONFIG_YENTA_O2=3Dy
CONFIG_YENTA_RICOH=3Dy
CONFIG_YENTA_TI=3Dy
CONFIG_YENTA_ENE_TUNE=3Dy
CONFIG_YENTA_TOSHIBA=3Dy
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
CONFIG_PCCARD_NONSTATIC=3Dm

#
# PCI Hotplug Support
#
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=3Dy
CONFIG_BINFMT_MISC=3Dm
CONFIG_IA32_EMULATION=3Dy
# CONFIG_IA32_AOUT is not set
CONFIG_COMPAT=3Dy
CONFIG_SYSVIPC_COMPAT=3Dy

#
# Networking
#
CONFIG_NET=3Dy

#
# Networking options
#
# CONFIG_NETDEBUG is not set
CONFIG_PACKET=3Dy
CONFIG_PACKET_MMAP=3Dy
CONFIG_UNIX=3Dy
# CONFIG_NET_KEY is not set
CONFIG_INET=3Dy
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_FIB_HASH=3Dy
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_ARPD is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
# CONFIG_INET_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
CONFIG_INET_DIAG=3Dy
CONFIG_INET_TCP_DIAG=3Dy
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=3Dy
CONFIG_DEFAULT_TCP_CONG=3D"cubic"

#
# IP: Virtual Server Configuration
#
# CONFIG_IP_VS is not set
CONFIG_IPV6=3Dy
# CONFIG_IPV6_PRIVACY is not set
# CONFIG_IPV6_ROUTER_PREF is not set
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
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NETFILTER=3Dy
# CONFIG_NETFILTER_DEBUG is not set

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=3Dm
# CONFIG_NETFILTER_NETLINK_QUEUE is not set
# CONFIG_NETFILTER_NETLINK_LOG is not set
CONFIG_NETFILTER_XTABLES=3Dy
# CONFIG_NETFILTER_XT_TARGET_CLASSIFY is not set
# CONFIG_NETFILTER_XT_TARGET_MARK is not set
# CONFIG_NETFILTER_XT_TARGET_NFQUEUE is not set
CONFIG_NETFILTER_XT_MATCH_COMMENT=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=3Dm
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=3Dm
# CONFIG_NETFILTER_XT_MATCH_DCCP is not set
# CONFIG_NETFILTER_XT_MATCH_DSCP is not set
# CONFIG_NETFILTER_XT_MATCH_ESP is not set
CONFIG_NETFILTER_XT_MATCH_HELPER=3Dm
CONFIG_NETFILTER_XT_MATCH_LENGTH=3Dm
CONFIG_NETFILTER_XT_MATCH_LIMIT=3Dy
CONFIG_NETFILTER_XT_MATCH_MAC=3Dm
# CONFIG_NETFILTER_XT_MATCH_MARK is not set
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=3Dy
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=3Dm
CONFIG_NETFILTER_XT_MATCH_QUOTA=3Dm
# CONFIG_NETFILTER_XT_MATCH_REALM is not set
# CONFIG_NETFILTER_XT_MATCH_SCTP is not set
CONFIG_NETFILTER_XT_MATCH_STATE=3Dy
CONFIG_NETFILTER_XT_MATCH_STATISTIC=3Dm
CONFIG_NETFILTER_XT_MATCH_STRING=3Dm
# CONFIG_NETFILTER_XT_MATCH_TCPMSS is not set

#
# IP: Netfilter Configuration
#
CONFIG_IP_NF_CONNTRACK=3Dy
CONFIG_IP_NF_CT_ACCT=3Dy
# CONFIG_IP_NF_CONNTRACK_MARK is not set
# CONFIG_IP_NF_CONNTRACK_EVENTS is not set
# CONFIG_IP_NF_CT_PROTO_SCTP is not set
CONFIG_IP_NF_FTP=3Dy
CONFIG_IP_NF_IRC=3Dy
# CONFIG_IP_NF_NETBIOS_NS is not set
# CONFIG_IP_NF_TFTP is not set
# CONFIG_IP_NF_AMANDA is not set
# CONFIG_IP_NF_PPTP is not set
CONFIG_IP_NF_H323=3Dm
CONFIG_IP_NF_SIP=3Dm
# CONFIG_IP_NF_QUEUE is not set
CONFIG_IP_NF_IPTABLES=3Dy
CONFIG_IP_NF_MATCH_IPRANGE=3Dy
CONFIG_IP_NF_MATCH_TOS=3Dm
CONFIG_IP_NF_MATCH_RECENT=3Dy
# CONFIG_IP_NF_MATCH_ECN is not set
# CONFIG_IP_NF_MATCH_AH is not set
CONFIG_IP_NF_MATCH_TTL=3Dm
CONFIG_IP_NF_MATCH_OWNER=3Dy
CONFIG_IP_NF_MATCH_ADDRTYPE=3Dy
CONFIG_IP_NF_MATCH_HASHLIMIT=3Dm
CONFIG_IP_NF_FILTER=3Dy
CONFIG_IP_NF_TARGET_REJECT=3Dm
CONFIG_IP_NF_TARGET_LOG=3Dy
CONFIG_IP_NF_TARGET_ULOG=3Dm
# CONFIG_IP_NF_TARGET_TCPMSS is not set
# CONFIG_IP_NF_NAT is not set
# CONFIG_IP_NF_MANGLE is not set
# CONFIG_IP_NF_RAW is not set
# CONFIG_IP_NF_ARPTABLES is not set

#
# IPv6: Netfilter Configuration (EXPERIMENTAL)
#
# CONFIG_IP6_NF_QUEUE is not set
CONFIG_IP6_NF_IPTABLES=3Dy
CONFIG_IP6_NF_MATCH_RT=3Dm
CONFIG_IP6_NF_MATCH_OPTS=3Dm
# CONFIG_IP6_NF_MATCH_FRAG is not set
# CONFIG_IP6_NF_MATCH_HL is not set
CONFIG_IP6_NF_MATCH_OWNER=3Dm
# CONFIG_IP6_NF_MATCH_IPV6HEADER is not set
# CONFIG_IP6_NF_MATCH_AH is not set
# CONFIG_IP6_NF_MATCH_EUI64 is not set
CONFIG_IP6_NF_FILTER=3Dy
CONFIG_IP6_NF_TARGET_LOG=3Dy
# CONFIG_IP6_NF_TARGET_REJECT is not set
# CONFIG_IP6_NF_MANGLE is not set
# CONFIG_IP6_NF_RAW is not set

#
# DCCP Configuration (EXPERIMENTAL)
#
# CONFIG_IP_DCCP is not set

#
# SCTP Configuration (EXPERIMENTAL)
#
# CONFIG_IP_SCTP is not set

#
# TIPC Configuration (EXPERIMENTAL)
#
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
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
# CONFIG_NET_SCH_CLK_JIFFIES is not set
# CONFIG_NET_SCH_CLK_GETTIMEOFDAY is not set
CONFIG_NET_SCH_CLK_CPU=3Dy

#
# Queueing/Scheduling
#
# CONFIG_NET_SCH_CBQ is not set
# CONFIG_NET_SCH_HTB is not set
CONFIG_NET_SCH_HFSC=3Dy
# CONFIG_NET_SCH_PRIO is not set
# CONFIG_NET_SCH_RED is not set
# CONFIG_NET_SCH_SFQ is not set
# CONFIG_NET_SCH_TEQL is not set
# CONFIG_NET_SCH_TBF is not set
# CONFIG_NET_SCH_GRED is not set
# CONFIG_NET_SCH_DSMARK is not set
# CONFIG_NET_SCH_NETEM is not set
# CONFIG_NET_SCH_INGRESS is not set

#
# Classification
#
# CONFIG_NET_CLS_BASIC is not set
# CONFIG_NET_CLS_TCINDEX is not set
# CONFIG_NET_CLS_ROUTE4 is not set
# CONFIG_NET_CLS_FW is not set
# CONFIG_NET_CLS_U32 is not set
# CONFIG_NET_CLS_RSVP is not set
# CONFIG_NET_CLS_RSVP6 is not set
# CONFIG_NET_EMATCH is not set
# CONFIG_NET_CLS_ACT is not set
# CONFIG_NET_CLS_POLICE is not set
# CONFIG_NET_ESTIMATOR is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
CONFIG_IRDA=3Dm

#
# IrDA protocols
#
# CONFIG_IRLAN is not set
# CONFIG_IRNET is not set
# CONFIG_IRCOMM is not set
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
# CONFIG_IRDA_CACHE_LAST_LSAP is not set
# CONFIG_IRDA_FAST_RR is not set
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
# CONFIG_IRTTY_SIR is not set

#
# Dongle support
#

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
# CONFIG_USB_IRDA is not set
# CONFIG_SIGMATEL_FIR is not set
CONFIG_NSC_FIR=3Dm
# CONFIG_WINBOND_FIR is not set
# CONFIG_SMC_IRCC_FIR is not set
# CONFIG_ALI_FIR is not set
# CONFIG_VLSI_FIR is not set
# CONFIG_VIA_FIR is not set
# CONFIG_MCS_FIR is not set
# CONFIG_BT is not set
CONFIG_IEEE80211=3Dm
CONFIG_IEEE80211_DEBUG=3Dy
CONFIG_IEEE80211_CRYPT_WEP=3Dm
CONFIG_IEEE80211_CRYPT_CCMP=3Dm
CONFIG_IEEE80211_CRYPT_TKIP=3Dm
CONFIG_IEEE80211_SOFTMAC=3Dm
CONFIG_IEEE80211_SOFTMAC_DEBUG=3Dy
CONFIG_WIRELESS_EXT=3Dy

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=3Dy
CONFIG_FW_LOADER=3Dy
# CONFIG_SYS_HYPERVISOR is not set

#
# Connector - unified userspace <-> kernelspace linker
#
# CONFIG_CONNECTOR is not set

#
# Memory Technology Devices (MTD)
#
# CONFIG_MTD is not set

#
# Parallel port support
#
# CONFIG_PARPORT is not set

#
# Plug and Play support
#
CONFIG_PNP=3Dy
# CONFIG_PNP_DEBUG is not set

#
# Protocols
#
CONFIG_PNPACPI=3Dy

#
# Block devices
#
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=3Dm
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_BLK_DEV_INITRD is not set
CONFIG_CDROM_PKTCDVD=3Dm
CONFIG_CDROM_PKTCDVD_BUFFERS=3D8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
# CONFIG_ATA_OVER_ETH is not set

#
# Misc devices
#
# CONFIG_IBM_ASM is not set
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=3Dm
CONFIG_TIFM_7XX1=3Dm
# CONFIG_MSI_LAPTOP is not set

#
# ATA/ATAPI/MFM/RLL support
#
CONFIG_IDE=3Dy
CONFIG_BLK_DEV_IDE=3Dy

#
# Please see Documentation/ide.txt for help/info on IDE drives
#
# CONFIG_BLK_DEV_IDE_SATA is not set
# CONFIG_BLK_DEV_HD_IDE is not set
CONFIG_BLK_DEV_IDEDISK=3Dy
CONFIG_IDEDISK_MULTI_MODE=3Dy
# CONFIG_BLK_DEV_IDECS is not set
CONFIG_BLK_DEV_IDECD=3Dy
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEFLOPPY is not set
# CONFIG_BLK_DEV_IDESCSI is not set
# CONFIG_IDE_TASK_IOCTL is not set

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=3Dy
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEPCI=3Dy
# CONFIG_IDEPCI_SHARE_IRQ is not set
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=3Dy
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=3Dy
# CONFIG_BLK_DEV_IDEDMA_FORCED is not set
CONFIG_IDEDMA_PCI_AUTO=3Dy
# CONFIG_IDEDMA_ONLYDISK is not set
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
CONFIG_BLK_DEV_ATIIXP=3Dy
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CY82C693 is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_HPT34X is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
# CONFIG_BLK_DEV_PIIX is not set
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
# CONFIG_IDE_ARM is not set
CONFIG_BLK_DEV_IDEDMA=3Dy
# CONFIG_IDEDMA_IVB is not set
CONFIG_IDEDMA_AUTO=3Dy
# CONFIG_BLK_DEV_HD is not set

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=3Dy
# CONFIG_SCSI_NETLINK is not set
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=3Dy
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=3Dy
# CONFIG_CHR_DEV_SCH is not set

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
# CONFIG_SCSI_MULTI_LUN is not set
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set

#
# SCSI low-level drivers
#
# CONFIG_ISCSI_TCP is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
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
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set

#
# PCMCIA SCSI adapter support
#
# CONFIG_PCMCIA_FDOMAIN is not set
# CONFIG_PCMCIA_QLOGIC is not set
# CONFIG_PCMCIA_SYM53C500 is not set

#
# Serial ATA (prod) and Parallel ATA (experimental) drivers
#
CONFIG_ATA=3Dy
# CONFIG_SATA_AHCI is not set
# CONFIG_SATA_SVW is not set
# CONFIG_ATA_PIIX is not set
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
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
CONFIG_PATA_ATIIXP=3Dy
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
CONFIG_ATA_GENERIC=3Dy
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PCMCIA is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# Multi-device support (RAID and LVM)
#
CONFIG_MD=3Dy
# CONFIG_BLK_DEV_MD is not set
CONFIG_BLK_DEV_DM=3Dm
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=3Dm
# CONFIG_DM_SNAPSHOT is not set
# CONFIG_DM_MIRROR is not set
# CONFIG_DM_ZERO is not set
# CONFIG_DM_MULTIPATH is not set

#
# Fusion MPT device support
#
# CONFIG_FUSION is not set
# CONFIG_FUSION_SPI is not set
# CONFIG_FUSION_FC is not set
# CONFIG_FUSION_SAS is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_IEEE1394=3Dm

#
# Subsystem Options
#
# CONFIG_IEEE1394_VERBOSEDEBUG is not set
CONFIG_IEEE1394_OUI_DB=3Dy
CONFIG_IEEE1394_EXTRA_CONFIG_ROMS=3Dy
CONFIG_IEEE1394_CONFIG_ROM_IP1394=3Dy
# CONFIG_IEEE1394_EXPORT_FULL_API is not set

#
# Device Drivers
#
# CONFIG_IEEE1394_PCILYNX is not set
CONFIG_IEEE1394_OHCI1394=3Dm

#
# Protocol Drivers
#
CONFIG_IEEE1394_VIDEO1394=3Dm
CONFIG_IEEE1394_SBP2=3Dm
# CONFIG_IEEE1394_ETH1394 is not set
CONFIG_IEEE1394_DV1394=3Dm
CONFIG_IEEE1394_RAWIO=3Dm

#
# I2O device support
#
# CONFIG_I2O is not set

#
# Network device support
#
CONFIG_NETDEVICES=3Dy
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_NET_SB1000 is not set

#
# ARCnet devices
#
# CONFIG_ARCNET is not set

#
# PHY device support
#

#
# Ethernet (10 or 100Mbit)
#
# CONFIG_NET_ETHERNET is not set

#
# Ethernet (1000 Mbit)
#
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_R8169=3Dy
CONFIG_R8169_NAPI=3Dy
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
# CONFIG_SK98LIN is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2 is not set
# CONFIG_QLA3XXX is not set

#
# Ethernet (10000 Mbit)
#
# CONFIG_CHELSIO_T1 is not set
# CONFIG_IXGB is not set
# CONFIG_S2IO is not set
# CONFIG_MYRI10GE is not set

#
# Token Ring devices
#
# CONFIG_TR is not set

#
# Wireless LAN (non-hamradio)
#
CONFIG_NET_RADIO=3Dy
# CONFIG_NET_WIRELESS_RTNETLINK is not set

#
# Obsolete Wireless cards support (pre-802.11)
#
# CONFIG_STRIP is not set
# CONFIG_PCMCIA_WAVELAN is not set
# CONFIG_PCMCIA_NETWAVE is not set

#
# Wireless 802.11 Frequency Hopping cards support
#
# CONFIG_PCMCIA_RAYCS is not set

#
# Wireless 802.11b ISA/PCI cards support
#
# CONFIG_IPW2100 is not set
# CONFIG_IPW2200 is not set
# CONFIG_AIRO is not set
# CONFIG_HERMES is not set
# CONFIG_ATMEL is not set

#
# Wireless 802.11b Pcmcia/Cardbus cards support
#
# CONFIG_AIRO_CS is not set
# CONFIG_PCMCIA_WL3501 is not set

#
# Prism GT/Duette 802.11(a/b/g) PCI/Cardbus support
#
# CONFIG_PRISM54 is not set
# CONFIG_USB_ZD1201 is not set
# CONFIG_HOSTAP is not set
CONFIG_BCM43XX=3Dm
CONFIG_BCM43XX_DEBUG=3Dy
CONFIG_BCM43XX_DMA=3Dy
CONFIG_BCM43XX_PIO=3Dy
CONFIG_BCM43XX_DMA_AND_PIO_MODE=3Dy
# CONFIG_BCM43XX_DMA_MODE is not set
# CONFIG_BCM43XX_PIO_MODE is not set
# CONFIG_ZD1211RW is not set
CONFIG_NET_WIRELESS=3Dy

#
# PCMCIA network device support
#
# CONFIG_NET_PCMCIA is not set

#
# Wan interfaces
#
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
CONFIG_PPP=3Dm
# CONFIG_PPP_MULTILINK is not set
CONFIG_PPP_FILTER=3Dy
CONFIG_PPP_ASYNC=3Dm
CONFIG_PPP_SYNC_TTY=3Dm
CONFIG_PPP_DEFLATE=3Dm
CONFIG_PPP_BSDCOMP=3Dm
CONFIG_PPP_MPPE=3Dm
# CONFIG_PPPOE is not set
# CONFIG_SLIP is not set
CONFIG_SLHC=3Dm
# CONFIG_NET_FC is not set
# CONFIG_SHAPER is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set

#
# ISDN subsystem
#
# CONFIG_ISDN is not set

#
# Telephony Support
#
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=3Dy
CONFIG_INPUT_FF_MEMLESS=3Dm

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=3Dy
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1280
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D800
CONFIG_INPUT_JOYDEV=3Dm
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
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_VSXXXAA is not set
CONFIG_INPUT_JOYSTICK=3Dy
# CONFIG_JOYSTICK_ANALOG is not set
# CONFIG_JOYSTICK_A3D is not set
# CONFIG_JOYSTICK_ADI is not set
# CONFIG_JOYSTICK_COBRA is not set
# CONFIG_JOYSTICK_GF2K is not set
# CONFIG_JOYSTICK_GRIP is not set
# CONFIG_JOYSTICK_GRIP_MP is not set
# CONFIG_JOYSTICK_GUILLEMOT is not set
# CONFIG_JOYSTICK_INTERACT is not set
# CONFIG_JOYSTICK_SIDEWINDER is not set
# CONFIG_JOYSTICK_TMDC is not set
CONFIG_JOYSTICK_IFORCE=3Dm
CONFIG_JOYSTICK_IFORCE_USB=3Dy
# CONFIG_JOYSTICK_IFORCE_232 is not set
# CONFIG_JOYSTICK_WARRIOR is not set
# CONFIG_JOYSTICK_MAGELLAN is not set
# CONFIG_JOYSTICK_SPACEORB is not set
# CONFIG_JOYSTICK_SPACEBALL is not set
# CONFIG_JOYSTICK_STINGER is not set
# CONFIG_JOYSTICK_TWIDJOY is not set
# CONFIG_JOYSTICK_JOYDUMP is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=3Dy
CONFIG_SERIO_I8042=3Dy
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=3Dy
# CONFIG_SERIO_RAW is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=3Dy
CONFIG_VT_CONSOLE=3Dy
CONFIG_HW_CONSOLE=3Dy
CONFIG_VT_HW_CONSOLE_BINDING=3Dy
# CONFIG_SERIAL_NONSTANDARD is not set

#
# Serial drivers
#
# CONFIG_SERIAL_8250 is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=3Dy
# CONFIG_LEGACY_PTYS is not set

#
# IPMI
#
# CONFIG_IPMI_HANDLER is not set

#
# Watchdog Cards
#
# CONFIG_WATCHDOG is not set
CONFIG_HW_RANDOM=3Dy
# CONFIG_HW_RANDOM_INTEL is not set
# CONFIG_HW_RANDOM_AMD is not set
# CONFIG_HW_RANDOM_GEODE is not set
# CONFIG_NVRAM is not set
CONFIG_RTC=3Dy
# CONFIG_DTLK is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# Ftape, the floppy tape device driver
#
# CONFIG_FTAPE is not set
CONFIG_AGP=3Dy
CONFIG_AGP_AMD64=3Dy
# CONFIG_AGP_INTEL is not set
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_VIA is not set
CONFIG_DRM=3Dm
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
CONFIG_DRM_RADEON=3Dm
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
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=3Dy
# CONFIG_HPET_RTC_IRQ is not set
CONFIG_HPET_MMAP=3Dy
CONFIG_HANGCHECK_TIMER=3Dy

#
# TPM devices
#
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set

#
# I2C support
#
CONFIG_I2C=3Dy
# CONFIG_I2C_CHARDEV is not set

#
# I2C Algorithms
#
# CONFIG_I2C_ALGOBIT is not set
# CONFIG_I2C_ALGOPCF is not set
# CONFIG_I2C_ALGOPCA is not set

#
# I2C Hardware Bus support
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_I810 is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_PROSAVAGE is not set
# CONFIG_I2C_SAVAGE4 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_STUB is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set
# CONFIG_I2C_VOODOO3 is not set
# CONFIG_I2C_PCA_ISA is not set

#
# Miscellaneous I2C Chip support
#
# CONFIG_SENSORS_DS1337 is not set
# CONFIG_SENSORS_DS1374 is not set
# CONFIG_SENSORS_EEPROM is not set
# CONFIG_SENSORS_PCF8574 is not set
# CONFIG_SENSORS_PCA9539 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_SENSORS_MAX6875 is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I2C_DEBUG_CHIP is not set

#
# SPI support
#
# CONFIG_SPI is not set
# CONFIG_SPI_MASTER is not set

#
# Dallas's 1-wire bus
#
# CONFIG_W1 is not set

#
# Hardware Monitoring support
#
CONFIG_HWMON=3Dy
# CONFIG_HWMON_VID is not set
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_K8TEMP=3Dy
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_FSCHER is not set
# CONFIG_SENSORS_FSCPOS is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
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
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Multimedia devices
#
# CONFIG_VIDEO_DEV is not set

#
# Digital Video Broadcasting Devices
#
# CONFIG_DVB is not set
# CONFIG_USB_DABUSB is not set

#
# Graphics support
#
CONFIG_FIRMWARE_EDID=3Dy
CONFIG_FB=3Dy
CONFIG_FB_CFB_FILLRECT=3Dy
CONFIG_FB_CFB_COPYAREA=3Dy
CONFIG_FB_CFB_IMAGEBLIT=3Dy
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=3Dy
# CONFIG_FB_TILEBLITTING is not set
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_VESA=3Dy
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_INTEL is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_VIRTUAL is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=3Dy
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_VIDEO_SELECT=3Dy
CONFIG_DUMMY_CONSOLE=3Dy
CONFIG_FRAMEBUFFER_CONSOLE=3Dy
# CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=3Dy
CONFIG_FONT_8x16=3Dy

#
# Logo configuration
#
# CONFIG_LOGO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=3Dy
CONFIG_BACKLIGHT_CLASS_DEVICE=3Dy
CONFIG_BACKLIGHT_DEVICE=3Dy
CONFIG_LCD_CLASS_DEVICE=3Dy
CONFIG_LCD_DEVICE=3Dy

#
# Sound
#
CONFIG_SOUND=3Dy

#
# Advanced Linux Sound Architecture
#
CONFIG_SND=3Dy
CONFIG_SND_TIMER=3Dy
CONFIG_SND_PCM=3Dy
CONFIG_SND_SEQUENCER=3Dy
# CONFIG_SND_SEQ_DUMMY is not set
CONFIG_SND_OSSEMUL=3Dy
CONFIG_SND_MIXER_OSS=3Dy
CONFIG_SND_PCM_OSS=3Dy
CONFIG_SND_PCM_OSS_PLUGINS=3Dy
CONFIG_SND_SEQUENCER_OSS=3Dy
CONFIG_SND_RTCTIMER=3Dy
CONFIG_SND_SEQ_RTCTIMER_DEFAULT=3Dy
# CONFIG_SND_DYNAMIC_MINORS is not set
# CONFIG_SND_SUPPORT_OLD_API is not set
# CONFIG_SND_VERBOSE_PROCFS is not set
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set

#
# Generic devices
#
CONFIG_SND_AC97_CODEC=3Dy
CONFIG_SND_AC97_BUS=3Dy
# CONFIG_SND_DUMMY is not set
# CONFIG_SND_VIRMIDI is not set
# CONFIG_SND_MTPAV is not set
# CONFIG_SND_SERIAL_U16550 is not set
# CONFIG_SND_MPU401 is not set

#
# PCI devices
#
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
# CONFIG_SND_ALI5451 is not set
CONFIG_SND_ATIIXP=3Dy
CONFIG_SND_ATIIXP_MODEM=3Dm
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
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
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
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

#
# USB devices
#
# CONFIG_SND_USB_AUDIO is not set
# CONFIG_SND_USB_USX2Y is not set

#
# PCMCIA devices
#
# CONFIG_SND_VXPOCKET is not set
# CONFIG_SND_PDAUDIOCF is not set

#
# Open Sound System
#
# CONFIG_SOUND_PRIME is not set

#
# USB support
#
CONFIG_USB_ARCH_HAS_HCD=3Dy
CONFIG_USB_ARCH_HAS_OHCI=3Dy
CONFIG_USB_ARCH_HAS_EHCI=3Dy
CONFIG_USB=3Dy
# CONFIG_USB_DEBUG is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=3Dy
CONFIG_USB_BANDWIDTH=3Dy
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_SUSPEND is not set
# CONFIG_USB_OTG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_EHCI_HCD=3Dm
CONFIG_USB_EHCI_SPLIT_ISO=3Dy
CONFIG_USB_EHCI_ROOT_HUB_TT=3Dy
CONFIG_USB_EHCI_TT_NEWSCHED=3Dy
# CONFIG_USB_ISP116X_HCD is not set
CONFIG_USB_OHCI_HCD=3Dm
# CONFIG_USB_OHCI_BIG_ENDIAN is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=3Dy
# CONFIG_USB_UHCI_HCD is not set
# CONFIG_USB_SL811_HCD is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set

#
# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
#

#
# may also be needed; see USB_STORAGE Help for more information
#
CONFIG_USB_STORAGE=3Dy
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
# USB Input Devices
#
CONFIG_USB_HID=3Dy
CONFIG_USB_HIDINPUT=3Dy
# CONFIG_USB_HIDINPUT_POWERBOOK is not set
CONFIG_HID_FF=3Dy
# CONFIG_HID_PID is not set
# CONFIG_LOGITECH_FF is not set
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_USB_HIDDEV is not set
# CONFIG_USB_AIPTEK is not set
# CONFIG_USB_WACOM is not set
# CONFIG_USB_ACECAD is not set
# CONFIG_USB_KBTAB is not set
# CONFIG_USB_POWERMATE is not set
# CONFIG_USB_TOUCHSCREEN is not set
# CONFIG_USB_YEALINK is not set
# CONFIG_USB_XPAD is not set
# CONFIG_USB_ATI_REMOTE is not set
# CONFIG_USB_ATI_REMOTE2 is not set
# CONFIG_USB_KEYSPAN_REMOTE is not set
# CONFIG_USB_APPLETOUCH is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET_MII is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_MON is not set

#
# USB port drivers
#

#
# USB Serial Converter support
#
CONFIG_USB_SERIAL=3Dm
# CONFIG_USB_SERIAL_GENERIC is not set
# CONFIG_USB_SERIAL_AIRCABLE is not set
# CONFIG_USB_SERIAL_AIRPRIME is not set
# CONFIG_USB_SERIAL_ARK3116 is not set
# CONFIG_USB_SERIAL_BELKIN is not set
# CONFIG_USB_SERIAL_WHITEHEAT is not set
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
# CONFIG_USB_SERIAL_CP2101 is not set
# CONFIG_USB_SERIAL_CYPRESS_M8 is not set
# CONFIG_USB_SERIAL_EMPEG is not set
CONFIG_USB_SERIAL_FTDI_SIO=3Dm
# CONFIG_USB_SERIAL_FUNSOFT is not set
# CONFIG_USB_SERIAL_VISOR is not set
# CONFIG_USB_SERIAL_IPAQ is not set
# CONFIG_USB_SERIAL_IR is not set
# CONFIG_USB_SERIAL_EDGEPORT is not set
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
# CONFIG_USB_SERIAL_GARMIN is not set
# CONFIG_USB_SERIAL_IPW is not set
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
# CONFIG_USB_SERIAL_KEYSPAN is not set
# CONFIG_USB_SERIAL_KLSI is not set
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
# CONFIG_USB_SERIAL_MCT_U232 is not set
# CONFIG_USB_SERIAL_MOS7720 is not set
# CONFIG_USB_SERIAL_MOS7840 is not set
# CONFIG_USB_SERIAL_NAVMAN is not set
# CONFIG_USB_SERIAL_PL2303 is not set
# CONFIG_USB_SERIAL_HP4X is not set
# CONFIG_USB_SERIAL_SAFE is not set
# CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
# CONFIG_USB_SERIAL_TI is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
# CONFIG_USB_SERIAL_XIRCOM is not set
# CONFIG_USB_SERIAL_OPTION is not set
# CONFIG_USB_SERIAL_OMNINET is not set

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
# CONFIG_USB_TEST is not set

#
# USB DSL modem support
#

#
# USB Gadget Support
#
# CONFIG_USB_GADGET is not set

#
# MMC/SD Card support
#
CONFIG_MMC=3Dm
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_BLOCK=3Dm
# CONFIG_MMC_SDHCI is not set
# CONFIG_MMC_WBSD is not set
CONFIG_MMC_TIFM_SD=3Dm

#
# LED devices
#
# CONFIG_NEW_LEDS is not set

#
# LED drivers
#

#
# LED Triggers
#

#
# InfiniBand support
#
# CONFIG_INFINIBAND is not set

#
# EDAC - error detection and reporting (RAS) (EXPERIMENTAL)
#
# CONFIG_EDAC is not set

#
# Real Time Clock
#
# CONFIG_RTC_CLASS is not set

#
# DMA Engine support
#
CONFIG_DMA_ENGINE=3Dy

#
# DMA Clients
#
CONFIG_NET_DMA=3Dy

#
# DMA Devices
#
# CONFIG_INTEL_IOATDMA is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set

#
# File systems
#
CONFIG_EXT2_FS=3Dm
CONFIG_EXT2_FS_XATTR=3Dy
CONFIG_EXT2_FS_POSIX_ACL=3Dy
# CONFIG_EXT2_FS_SECURITY is not set
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=3Dy
CONFIG_EXT3_FS_XATTR=3Dy
CONFIG_EXT3_FS_POSIX_ACL=3Dy
# CONFIG_EXT3_FS_SECURITY is not set
# CONFIG_EXT4DEV_FS is not set
CONFIG_JBD=3Dy
# CONFIG_JBD_DEBUG is not set
CONFIG_FS_MBCACHE=3Dy
CONFIG_REISERFS_FS=3Dy
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=3Dy
CONFIG_REISERFS_FS_POSIX_ACL=3Dy
# CONFIG_REISERFS_FS_SECURITY is not set
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=3Dy
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_INOTIFY=3Dy
CONFIG_INOTIFY_USER=3Dy
CONFIG_QUOTA=3Dy
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=3Dy
CONFIG_QUOTACTL=3Dy
CONFIG_DNOTIFY=3Dy
# CONFIG_AUTOFS_FS is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=3Dm

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=3Dy
CONFIG_JOLIET=3Dy
# CONFIG_ZISOFS is not set
CONFIG_UDF_FS=3Dy
CONFIG_UDF_NLS=3Dy

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=3Dy
CONFIG_MSDOS_FS=3Dm
CONFIG_VFAT_FS=3Dy
CONFIG_FAT_DEFAULT_CODEPAGE=3D852
CONFIG_FAT_DEFAULT_IOCHARSET=3D"iso8859-1"
CONFIG_NTFS_FS=3Dm
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=3Dy
CONFIG_PROC_KCORE=3Dy
CONFIG_PROC_SYSCTL=3Dy
CONFIG_SYSFS=3Dy
CONFIG_TMPFS=3Dy
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_RAMFS=3Dy
CONFIG_CONFIGFS_FS=3Dm

#
# Miscellaneous filesystems
#
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set

#
# Network File Systems
#
CONFIG_NFS_FS=3Dm
CONFIG_NFS_V3=3Dy
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=3Dy
# CONFIG_NFS_DIRECTIO is not set
CONFIG_NFSD=3Dm
CONFIG_NFSD_V3=3Dy
# CONFIG_NFSD_V3_ACL is not set
CONFIG_NFSD_V4=3Dy
CONFIG_NFSD_TCP=3Dy
CONFIG_LOCKD=3Dm
CONFIG_LOCKD_V4=3Dy
CONFIG_EXPORTFS=3Dm
CONFIG_NFS_COMMON=3Dy
CONFIG_SUNRPC=3Dm
CONFIG_SUNRPC_GSS=3Dm
CONFIG_RPCSEC_GSS_KRB5=3Dm
# CONFIG_RPCSEC_GSS_SPKM3 is not set
CONFIG_SMB_FS=3Dm
CONFIG_SMB_NLS_DEFAULT=3Dy
CONFIG_SMB_NLS_REMOTE=3D"852"
CONFIG_CIFS=3Dm
CONFIG_CIFS_STATS=3Dy
# CONFIG_CIFS_STATS2 is not set
# CONFIG_CIFS_WEAK_PW_HASH is not set
CONFIG_CIFS_XATTR=3Dy
CONFIG_CIFS_POSIX=3Dy
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_EXPERIMENTAL is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
# CONFIG_9P_FS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=3Dy

#
# Native Language Support
#
CONFIG_NLS=3Dy
CONFIG_NLS_DEFAULT=3D"utf8"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=3Dy
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
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=3Dy
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=3Dy
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=3Dy

#
# Instrumentation Support
#
# CONFIG_PROFILING is not set
# CONFIG_KPROBES is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy
# CONFIG_PRINTK_TIME is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_MAGIC_SYSRQ=3Dy
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_DEBUG_KERNEL is not set
CONFIG_LOG_BUF_SHIFT=3D14
# CONFIG_DEBUG_FS is not set
# CONFIG_UNWIND_INFO is not set
# CONFIG_HEADERS_CHECK is not set

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY is not set

#
# Cryptographic options
#
CONFIG_CRYPTO=3Dy
CONFIG_CRYPTO_ALGAPI=3Dm
CONFIG_CRYPTO_BLKCIPHER=3Dm
CONFIG_CRYPTO_HASH=3Dm
CONFIG_CRYPTO_MANAGER=3Dm
CONFIG_CRYPTO_HMAC=3Dm
CONFIG_CRYPTO_NULL=3Dm
CONFIG_CRYPTO_MD4=3Dm
CONFIG_CRYPTO_MD5=3Dm
CONFIG_CRYPTO_SHA1=3Dm
CONFIG_CRYPTO_SHA256=3Dm
CONFIG_CRYPTO_SHA512=3Dm
CONFIG_CRYPTO_WP512=3Dm
CONFIG_CRYPTO_TGR192=3Dm
CONFIG_CRYPTO_ECB=3Dm
CONFIG_CRYPTO_CBC=3Dm
CONFIG_CRYPTO_DES=3Dm
CONFIG_CRYPTO_BLOWFISH=3Dm
CONFIG_CRYPTO_TWOFISH=3Dm
CONFIG_CRYPTO_TWOFISH_COMMON=3Dm
CONFIG_CRYPTO_TWOFISH_X86_64=3Dm
CONFIG_CRYPTO_SERPENT=3Dm
CONFIG_CRYPTO_AES=3Dm
CONFIG_CRYPTO_AES_X86_64=3Dm
CONFIG_CRYPTO_CAST5=3Dm
CONFIG_CRYPTO_CAST6=3Dm
CONFIG_CRYPTO_TEA=3Dm
CONFIG_CRYPTO_ARC4=3Dm
CONFIG_CRYPTO_KHAZAD=3Dm
CONFIG_CRYPTO_ANUBIS=3Dm
CONFIG_CRYPTO_DEFLATE=3Dm
CONFIG_CRYPTO_MICHAEL_MIC=3Dm
CONFIG_CRYPTO_CRC32C=3Dm
# CONFIG_CRYPTO_TEST is not set

#
# Hardware crypto devices
#

#
# Library routines
#
CONFIG_CRC_CCITT=3Dm
CONFIG_CRC16=3Dm
CONFIG_CRC32=3Dy
CONFIG_LIBCRC32C=3Dm
CONFIG_ZLIB_INFLATE=3Dm
CONFIG_ZLIB_DEFLATE=3Dm
CONFIG_TEXTSEARCH=3Dy
CONFIG_TEXTSEARCH_KMP=3Dm
CONFIG_TEXTSEARCH_BM=3Dm
CONFIG_TEXTSEARCH_FSM=3Dm
CONFIG_PLIST=3Dy


--=20
Marko H=E4nninen
m (dot) hanninen (at) kymp (dot) net

