From: Jody McIntyre <scjody@modernduck.com>
Subject: PROBLEM: e100 fails under heavy load after ACPI suspend
Date: Fri, 19 Mar 2004 13:22:52 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040319182252.GD23923@conscoop.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[1.] One line summary of the problem:

e100 fails under heavy load after ACPI suspend

[2.] Full description of the problem/report:

After an ACPI suspend to memory (echo -n mem >/sys/power/state), my e100
card stops working under heavy load.  wget of a large file on a local
server hangs after a few seconds.  Occasionally, 
NETDEV WATCHDOG: eth0: transmit timed out
appears in dmesg.  'rmmod e100; modprobe e100; dhclient eth0' solves the
problem, but only until the next heavy usage.

If I should be submitting this to the ACPI people instead of to you,
please let me know and I will do so.

[3.] Keywords (i.e., modules, networking, kernel):

e100, acpi

[4.] Kernel version (from /proc/version):

Linux version 2.6.4 (scjody@debian) (gcc version 3.3.3 (Debian)) #1 Thu Mar 18 20:18:50 EST 2004
Applied acpi-20040311-2.6.4.diff.bz2

[5.] Output of Oops.. message (if applicable) with symbolic information
     resolved (see Documentation/oops-tracing.txt)

n/a

[6.] A small shell script or example program which triggers the
     problem (if possible)

wget-ing a large file from a local server is sufficient.
apt-get install xxxxx will also do it most of the time.

[7.] Environment
[7.1.] Software (add the output of the ver_linux script here)

Linux debian 2.6.4 #1 Thu Mar 18 20:18:50 EST 2004 i686 GNU/Linux
                                                                                
Gnu C                  3.3.3
Gnu make               3.79.1
util-linux             2.11n
mount                  2.11n
module-init-tools      3.0-pre9
e2fsprogs              1.27
pcmcia-cs              3.1.33
nfs-utils              1.0
Linux C Library        2.3.2
Dynamic linker (ldd)   2.3.2
Procps                 2.0.7
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.0.91
Modules Loaded         e100 ipv6 af_packet radeon snd_mixer_oss snd soundcore ds pcmcia_core irda binfmt_misc thermal processor fan button battery asus_acpi ac mii usbkbd usb_storage usbcore scsi_mod rtc unix

[7.2.] Processor information (from /proc/cpuinfo):

processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 9
model name      : Intel(R) Pentium(R) M processor 1400MHz
stepping        : 5
cpu MHz         : 1395.873
cache size      : 1024 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr mce cx8 apic sep mtrr pge mca cmov pat clflush dts acpi mmx fxsr sse sse2 tm pbe tm2 est
bogomips        : 2768.89

[7.3.] Module information (from /proc/modules):

e100 33024 0 - Live 0xf08c3000
ipv6 251392 6 - Live 0xf0a4a000
af_packet 22280 20 - Live 0xf0964000
radeon 120492 0 - Live 0xf09e3000
snd_mixer_oss 20224 0 - Live 0xf0944000
snd 56100 1 snd_mixer_oss, Live 0xf09b0000
soundcore 10272 1 snd, Live 0xf08d7000
ds 15812 0 - Live 0xf093f000
pcmcia_core 67680 1 ds, Live 0xf0952000
irda 200704 2 - Live 0xf097e000
binfmt_misc 10632 1 - Live 0xf08cd000
thermal 18640 0 - Live 0xf0939000
processor 25712 1 thermal, Live 0xf0931000
fan 5260 0 - Live 0xf08d4000
button 7960 0 - Live 0xf08d1000
battery 12044 0 - Live 0xf08bf000
asus_acpi 10520 0 - Live 0xf08b8000
ac 6348 0 - Live 0xf08bc000
mii 5120 1 e100, Live 0xf08b5000
usbkbd 7360 0 - Live 0xf082a000
usb_storage 68288 0 - Live 0xf0916000
usbcore 106780 3 usbkbd,usb_storage, Live 0xf08fa000
scsi_mod 119928 1 usb_storage, Live 0xf08db000
rtc 12856 0 - Live 0xf08b0000
unix 28656 156 - Live 0xf082f000

[7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)

scjody@debian:/usr/src/linux-2.6.4-acpi$ cat /proc/ioports
0000-001f : dma1
0020-0021 : pic1
0040-005f : timer
0060-006f : keyboard
0070-0077 : rtc
0080-008f : dma page reg
00a0-00a1 : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : ide1
01f0-01f7 : ide0
0376-0376 : ide1
03c0-03df : vga+
03f6-03f6 : ide0
0cf8-0cff : PCI conf1
1000-107f : 0000:00:1f.0
1180-11bf : 0000:00:1f.0
1800-181f : 0000:00:1d.0
1820-183f : 0000:00:1d.1
1840-185f : 0000:00:1d.2
1860-186f : 0000:00:1f.1
1880-189f : 0000:00:1f.3
18c0-18ff : 0000:00:1f.5
1c00-1cff : 0000:00:1f.5
2000-207f : 0000:00:1f.6
2400-24ff : 0000:00:1f.6
3000-3fff : PCI Bus #01
  3000-30ff : 0000:01:00.0
8000-803f : 0000:02:08.0
  8000-803f : e100
scjody@debian:/usr/src/linux-2.6.4-acpi$ cat /proc/iomem
00000000-0009efff : System RAM
0009f000-0009ffff : reserved
000a0000-000bffff : Video RAM area
000d0000-000d0fff : Extension ROM
000d1000-000d1fff : Extension ROM
000d2000-000d3fff : reserved
000e0000-000effff : Extension ROM
000f0000-000fffff : System ROM
00100000-2ff5ffff : System RAM
  00100000-002ba87a : Kernel code
  002ba87b-0037e53f : Kernel data
2ff60000-2ff77fff : ACPI Tables
2ff78000-2ff79fff : ACPI Non-volatile Storage
2ff80000-2fffffff : reserved
30000000-300003ff : 0000:00:1f.1
b0000000-b0000fff : 0000:02:00.0
b1000000-b1000fff : 0000:02:00.1
c0000000-c00003ff : 0000:00:1d.7
c0000800-c00008ff : 0000:00:1f.5
c0000c00-c0000dff : 0000:00:1f.5
c0100000-c01fffff : PCI Bus #01
  c0100000-c010ffff : 0000:01:00.0
c0200000-c0200fff : 0000:02:02.0
c0201000-c0201fff : 0000:02:08.0
  c0201000-c0201fff : e100
d0000000-dfffffff : 0000:00:00.0
e0000000-e7ffffff : PCI Bus #01
  e0000000-e7ffffff : 0000:01:00.0
ff800000-ffffffff : reserved

[7.5.] PCI information ('lspci -vvv' as root)

00:00.0 Host bridge: Intel Corp. 82855PM Processor to I/O Controller (rev 03)
	Subsystem: IBM: Unknown device 0529
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0
	Region 0: Memory at d0000000 (32-bit, prefetchable) [size=256M]
	Capabilities: [e4] #09 [f104]
	Capabilities: [a0] AGP version 2.0
		Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64- HTrans- 64bit- FW+ AGP3- Rate=x1,x2,x4
		Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW- Rate=x1

00:01.0 PCI bridge: Intel Corp. 82855PM Processor to AGP Controller (rev 03) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 96
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
	I/O behind bridge: 00003000-00003fff
	Memory behind bridge: c0100000-c01fffff
	Prefetchable memory behind bridge: e0000000-e7ffffff
	BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-

00:1d.0 USB Controller: Intel Corp. 82801DB USB (Hub #1) (rev 01) (prog-if 00 [UHCI])
	Subsystem: IBM: Unknown device 052d
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 11
	Region 4: I/O ports at 1800 [disabled] [size=32]

00:1d.1 USB Controller: Intel Corp. 82801DB USB (Hub #2) (rev 01) (prog-if 00 [UHCI])
	Subsystem: IBM: Unknown device 052d
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin B routed to IRQ 11
	Region 4: I/O ports at 1820 [disabled] [size=32]

00:1d.2 USB Controller: Intel Corp. 82801DB USB (Hub #3) (rev 01) (prog-if 00 [UHCI])
	Subsystem: IBM: Unknown device 052d
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin C routed to IRQ 11
	Region 4: I/O ports at 1840 [disabled] [size=32]

00:1d.7 USB Controller: Intel Corp. 82801DB USB2 (rev 01) (prog-if 20 [EHCI])
	Subsystem: IBM: Unknown device 052e
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin D routed to IRQ 11
	Region 0: [virtual] Memory at c0000000 (32-bit, non-prefetchable) [disabled] [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] #0a [2080]

00:1e.0 PCI bridge: Intel Corp. 82801BAM/CAM PCI Bridge (rev 81) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR+
	Latency: 0
	Bus: primary=00, secondary=02, subordinate=08, sec-latency=64
	I/O behind bridge: 00004000-00008fff
	Memory behind bridge: c0200000-cfffffff
	Prefetchable memory behind bridge: e8000000-efffffff
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-

00:1f.0 ISA bridge: Intel Corp. 82801DBM LPC Interface Controller (rev 01)
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:1f.1 IDE interface: Intel Corp. 82801DBM Ultra ATA Storage Controller (rev 01) (prog-if 8a [Master SecP PriP])
	Subsystem: IBM: Unknown device 052d
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: I/O ports at <unassigned>
	Region 1: I/O ports at <unassigned>
	Region 2: I/O ports at <unassigned>
	Region 3: I/O ports at <unassigned>
	Region 4: I/O ports at 1860 [size=16]
	Region 5: [virtual] Memory at 30000000 (32-bit, non-prefetchable) [disabled] [size=1K]

00:1f.3 SMBus: Intel Corp. 82801DB/DBM SMBus Controller (rev 01)
	Subsystem: IBM: Unknown device 052d
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin B routed to IRQ 11
	Region 4: I/O ports at 1880 [size=32]

00:1f.5 Multimedia audio controller: Intel Corp. 82801DB AC'97 Audio Controller (rev 01)
	Subsystem: IBM: Unknown device 0537
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin B routed to IRQ 11
	Region 0: I/O ports at 1c00 [size=256]
	Region 1: I/O ports at 18c0 [size=64]
	Region 2: Memory at c0000c00 (32-bit, non-prefetchable) [size=512]
	Region 3: Memory at c0000800 (32-bit, non-prefetchable) [size=256]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:1f.6 Modem: Intel Corp. 82801DB AC'97 Modem Controller (rev 01) (prog-if 00 [Generic])
	Subsystem: IBM: Unknown device 0524
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin B routed to IRQ 11
	Region 0: I/O ports at 2400 [size=256]
	Region 1: I/O ports at 2000 [size=128]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

01:00.0 VGA compatible controller: ATI Technologies Inc Radeon Mobility M7 LW [Radeon Mobility 7500] (prog-if 00 [VGA])
	Subsystem: IBM: Unknown device 0530
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR+ FastB2B+
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 66 (2000ns min), Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at e0000000 (32-bit, prefetchable) [size=128M]
	Region 1: I/O ports at 3000 [size=256]
	Region 2: Memory at c0100000 (32-bit, non-prefetchable) [size=64K]
	Expansion ROM at <unassigned> [disabled] [size=128K]
	Capabilities: [58] AGP version 2.0
		Status: RQ=48 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64- HTrans- 64bit- FW- AGP3- Rate=x1,x2,x4
		Command: RQ=1 ArqSz=0 Cal=0 SBA+ AGP- GART64- 64bit- FW- Rate=<none>
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:00.0 CardBus bridge: Texas Instruments PCI1250 PC card Cardbus Controller (rev 01)
	Subsystem: IBM ThinkPad T30
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at b0000000 (32-bit, non-prefetchable) [size=4K]
	Bus: primary=02, secondary=03, subordinate=06, sec-latency=176
	Memory window 0: ffff0000-00000000 (prefetchable)
	Memory window 1: 00000000-00000000 (prefetchable)
	I/O window 0: 00000000-00000003
	I/O window 1: 00000000-00000003
	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset+ 16bInt+ PostWrite-
	16-bit legacy interface ports at 0001

02:00.1 CardBus bridge: Texas Instruments PCI1250 PC card Cardbus Controller (rev 01)
	Subsystem: IBM ThinkPad T30
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin B routed to IRQ 11
	Region 0: Memory at b1000000 (32-bit, non-prefetchable) [size=4K]
	Bus: primary=02, secondary=07, subordinate=0a, sec-latency=176
	Memory window 0: ffff0000-00000000 (prefetchable)
	Memory window 1: 00000000-00000000 (prefetchable)
	I/O window 0: 00000000-00000003
	I/O window 1: 00000000-00000003
	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset+ 16bInt+ PostWrite-
	16-bit legacy interface ports at 0001

02:02.0 Network controller: Intel Corp. PRO/Wireless LAN 2100 3B Mini PCI Adapter (rev 04)
	Subsystem: Intel Corp.: Unknown device 2551
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (500ns min, 8500ns max), Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at c0200000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-

02:08.0 Ethernet controller: Intel Corp. 82801BD PRO/100 VE (MOB) Ethernet Controller (rev 81)
	Subsystem: IBM: Unknown device 0522
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 66 (2000ns min, 14000ns max), Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at c0201000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at 8000 [size=64]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable+ DSel=0 DScale=2 PME-

[7.6.] SCSI information (from /proc/scsi/scsi)

Attached devices:

[7.7.] Other information that might be relevant to the problem
       (please look in /proc and include all information that you
       think to be relevant):

(none that I can think of)
