From: adam@adammil.net
Subject: PROBLEM:  failed assertions in 2.4.48 ipv4 code (tcp.c,af_inet.c)
Date: Wed, 22 Jan 2003 21:01:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15919.30517.330774.275812@adam.adammil.net>
Reply-To: adam@adammil.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When I run rsyncd on my local machine and attempt to sync a directory,
I get an assertion in the kernel. rsyncd has failed several times in the
same way, but this is the first time I've captured the output.

There are two failed assertions. One in tcp.c and the other in af_inet.c.
I haven't been able to try this on a 2.5.59 kernel, because devfs doesn't
seem to work properly under it on my system (that's another story).

Unfortunately, I don't have a System.map file anymore, so ksymoops isn't
going to report anything extra.

I hope the following information helps in some way...

* /proc/version:
Linux version 2.5.58 (root@adam.adammil.net) (gcc version 3.2.1 20021207 (Gentoo Linux 3.2.1-20021207)) #1 SMP Mon Jan 20 22:05:30 PST 2003

* the error output
Unable to handle kernel NULL pointer dereference at virtual address 00000000
 printing eip:
 00000000
 *pde = 00000000
 Oops: 0000
 CPU:    0
 EIP:    0060:[<00000000>]    Not tainted
 EFLAGS: 00010216
 eax: 00000100   ebx: cb346860   ecx: 0882d830   edx: c2ed3e20
 esi: 00008001   edi: c2103f80   ebp: c1ef6080   esp: c2103f00
 ds: 007b   es: 007b   ss: 0068
 Process rsync (pid: 30224, threadinfo=c2102000 task=c94fad00)
 Stack: c01fc629 c2ed3e20 00000100 00000000 c015f1d5 cb346860 00000004 c016043f
        cb346860 00000004 c2103f2c 00008000 00008001 cc823000 c2103f80 c016064d
	       c2103f80 00000004 00008001 00000000 00000000 00000004 c1ef6080 00008000
	       Call Trace: [<c01fc629>]  [<c015f1d5>]  [<c016043f>]  [<c016064d>]  [<c01500e3>]  [<c015064b>]  [<c0109663>]
	       Code:  Bad EIP value.
	        KERNEL: assertion (newsk->state != TCP_SYN_RECV) failed at net/ipv4/tcp.c(2274)
		KERNEL: assertion ((1 << sk2->state) & (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT | TCPF_CLOSE)) failed at net/ipv4/af_inet.c(689)
		KERNEL: assertion (newsk->state != TCP_SYN_RECV) failed at net/ipv4/tcp.c(2274)
		KERNEL: assertion ((1 << sk2->state) & (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT | TCPF_CLOSE)) failed at net/ipv4/af_inet.c(689)

* ver_linux output
Linux adam.adammil.net 2.5.58 #1 SMP Mon Jan 20 22:05:30 PST 2003 i686 AMD Athlon(TM) MP 1600+ AuthenticAMD GNU/Linux
 
Gnu C                  3.2.1
Gnu make               3.80
util-linux             2.11y
mount                  2.11y
module-init-tools      0.9.9-pre
e2fsprogs              1.32
xfsprogs               2.3.6
Linux C Library        2.3.1
Dynamic linker (ldd)   2.3.1
Procps                 2.0.10
Net-tools              1.60
Kbd                    1.06
Sh-utils               2.0.15
Modules Loaded         usbcore snd_pcm_oss snd_mixer_oss snd_emu10k1 snd_pcm snd_timer snd_rawmidi snd_ac97_codec snd_util_mem snd_hwdep snd

* /proc/cpuinfo
processor	: 0
vendor_id	: AuthenticAMD
cpu family	: 6
model		: 6
model name	: AMD Athlon(TM) MP 1600+
stepping	: 2
cpu MHz		: 1399.658
cache size	: 256 KB
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 1
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse syscall mp mmxext 3dnowext 3dnow
bogomips	: 2744.32

processor	: 1
vendor_id	: AuthenticAMD
cpu family	: 6
model		: 6
model name	: AMD Athlon(TM) MP 1600+
stepping	: 2
cpu MHz		: 1399.658
cache size	: 256 KB
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 1
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse syscall mp mmxext 3dnowext 3dnow
bogomips	: 2793.47

* /proc/modules
usbcore 76724 1 - Live 0xd091e000
snd_pcm_oss 39428 0 - Live 0xd08f7000
snd_mixer_oss 13568 2 snd_pcm_oss, Live 0xd0889000
snd_emu10k1 51780 1 - Live 0xd087b000
snd_pcm 65344 2 snd_pcm_oss,snd_emu10k1, Live 0xd0894000
snd_timer 12672 1 snd_pcm, Live 0xd0876000
snd_rawmidi 15296 1 snd_emu10k1, Live 0xd0871000
snd_ac97_codec 32580 1 snd_emu10k1, Live 0xd0857000
snd_util_mem 1664 1 snd_emu10k1, Live 0xd0853000
snd_hwdep 3904 1 snd_emu10k1, Live 0xd0855000
snd 34628 9 snd_pcm_oss,snd_mixer_oss,snd_emu10k1,snd_pcm,snd_timer,snd_rawmidi,snd_ac97_codec,snd_util_mem,snd_hwdep, Live 0xd0860000

* /proc/ioports
0000-001f : dma1
0020-003f : pic1
0040-005f : timer
0060-006f : keyboard
0070-007f : rtc
0080-008f : dma page reg
00a0-00bf : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : ide1
01f0-01f7 : ide0
0376-0376 : ide1
03c0-03df : vga+
03f6-03f6 : ide0
0cf8-0cff : PCI conf1
c000-cfff : PCI Bus #02
  c000-c0ff : Lite-On Communicatio LNE100TX
    c000-c0ff : tulip
  c400-c407 : Creative Labs SB Live! MIDI/Game P
  c800-c81f : Creative Labs SB Live! EMU10k1
    c800-c81f : EMU10K1
d800-d80f : Advanced Micro Devic AMD-768 [Opus] IDE
  d800-d807 : ide0
  d808-d80f : ide1
e800-e803 : Advanced Micro Devic AMD-760 MP [IGD4-2P]

* /proc/iomem
00000000-0009fbff : System RAM
0009fc00-0009ffff : reserved
000a0000-000bffff : Video RAM area
000c0000-000c7fff : Video ROM
000f0000-000fffff : System ROM
00100000-0ffebfff : System RAM
  00100000-002c28a1 : Kernel code
  002c28a2-0032b707 : Kernel data
0ffec000-0ffeefff : ACPI Tables
0ffef000-0fffefff : reserved
0ffff000-0fffffff : ACPI Non-volatile Storage
eb800000-ec7fffff : PCI Bus #02
  eb800000-eb8000ff : Lite-On Communicatio LNE100TX
    eb800000-eb8000ff : tulip
ec800000-ec8000ff : NEC Corporation USB 2.0
ed000000-ed000fff : NEC Corporation USB (#2)
ed800000-ed800fff : NEC Corporation USB
ee000000-ef5fffff : PCI Bus #01
  ee000000-eeffffff : nVidia Corporation NV20 [GeForce3 Ti500
ef600000-ef6fffff : PCI Bus #02
ef700000-f77fffff : PCI Bus #01
  ef800000-ef87ffff : nVidia Corporation NV20 [GeForce3 Ti500
  f0000000-f3ffffff : nVidia Corporation NV20 [GeForce3 Ti500
f7800000-f7800fff : Advanced Micro Devic AMD-760 MP [IGD4-2P]
f8000000-fbffffff : Advanced Micro Devic AMD-760 MP [IGD4-2P]
fec00000-fec00fff : reserved
fee00000-fee00fff : reserved
ffff0000-ffffffff : reserved

* lspci -vvv
00:00.0 Host bridge: Advanced Micro Devices [AMD] AMD-760 MP [IGD4-2P] System Controller (rev 11)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 32
	Region 0: Memory at f8000000 (32-bit, prefetchable) [size=64M]
	Region 1: Memory at f7800000 (32-bit, prefetchable) [size=4K]
	Region 2: I/O ports at e800 [disabled] [size=4]
	Capabilities: [a0] AGP version 2.0
		Status: RQ=15 SBA+ 64bit- FW+ Rate=x1,x2,x4
		Command: RQ=0 SBA- AGP- 64bit- FW- Rate=<none>

00:01.0 PCI bridge: Advanced Micro Devices [AMD] AMD-760 MP [IGD4-2P] AGP Bridge (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 0000e000-0000dfff
	Memory behind bridge: ee000000-ef5fffff
	Prefetchable memory behind bridge: ef700000-f77fffff
	BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-

00:07.0 ISA bridge: Advanced Micro Devices [AMD] AMD-768 [Opus] ISA (rev 04)
	Subsystem: Asustek Computer, Inc. A7M-D Mainboard
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:07.1 IDE interface: Advanced Micro Devices [AMD] AMD-768 [Opus] IDE (rev 04) (prog-if 8a [Master SecP PriP])
	Subsystem: Advanced Micro Devices [AMD] AMD-768 [Opus] IDE
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32
	Region 4: I/O ports at d800 [size=16]

00:07.3 Bridge: Advanced Micro Devices [AMD] AMD-768 [Opus] ACPI (rev 03)
	Subsystem: Asustek Computer, Inc. A7M-D Mainboard
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-

00:09.0 USB Controller: NEC Corporation USB (rev 41) (prog-if 10 [OHCI])
	Subsystem: Unknown device 807d:0035
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (250ns min, 10500ns max), cache line size 08
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at ed800000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:09.1 USB Controller: NEC Corporation USB (rev 41) (prog-if 10 [OHCI])
	Subsystem: Unknown device 807d:0035
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (250ns min, 10500ns max), cache line size 08
	Interrupt: pin B routed to IRQ 18
	Region 0: Memory at ed000000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:09.2 USB Controller: NEC Corporation USB 2.0 (rev 02) (prog-if 20 [EHCI])
	Subsystem: Unknown device 807d:1043
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (4000ns min, 8500ns max), cache line size 08
	Interrupt: pin C routed to IRQ 19
	Region 0: Memory at ec800000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:10.0 PCI bridge: Advanced Micro Devices [AMD] AMD-768 [Opus] PCI (rev 04) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 32
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=32
	I/O behind bridge: 0000c000-0000cfff
	Memory behind bridge: eb800000-ec7fffff
	Prefetchable memory behind bridge: ef600000-ef6fffff
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-

01:05.0 VGA compatible controller: nVidia Corporation NV20 [GeForce3 Ti500] (rev a3) (prog-if 00 [VGA])
	Subsystem: LeadTek Research Inc.: Unknown device 2863
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (1250ns min, 250ns max)
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at ee000000 (32-bit, non-prefetchable) [size=16M]
	Region 1: Memory at f0000000 (32-bit, prefetchable) [size=64M]
	Region 2: Memory at ef800000 (32-bit, prefetchable) [size=512K]
	Expansion ROM at ef7f0000 [disabled] [size=64K]
	Capabilities: [60] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [44] AGP version 2.0
		Status: RQ=31 SBA- 64bit- FW- Rate=x1,x2,x4
		Command: RQ=0 SBA- AGP- 64bit- FW- Rate=<none>

02:06.0 Multimedia audio controller: Creative Labs SB Live! EMU10k1 (rev 07)
	Subsystem: Creative Labs SBLive! Player 5.1
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (500ns min, 5000ns max)
	Interrupt: pin A routed to IRQ 17
	Region 0: I/O ports at c800 [size=32]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:06.1 Input device controller: Creative Labs SB Live! MIDI/Game Port (rev 07)
	Subsystem: Creative Labs Gameport Joystick
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32
	Region 0: I/O ports at c400 [size=8]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:08.0 Ethernet controller: Lite-On Communications Inc LNE100TX (rev 20)
	Subsystem: Netgear FA310TX
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32
	Interrupt: pin A routed to IRQ 19
	Region 0: I/O ports at c000 [size=256]
	Region 1: Memory at eb800000 (32-bit, non-prefetchable) [size=256]
	Expansion ROM at <unassigned> [disabled] [size=256K]

* i have no /proc/scsi
