From: Stephen Hemminger <shemminger@osdl.org>
Subject: Fw: [Bug 3610] New: kernel-2.6.9 breaks Amanda
Date: Thu, 21 Oct 2004 13:37:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021133752.67a386fb@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


http://bugme.osdl.org/show_bug.cgi?id=3610

           Summary: kernel-2.6.9 breaks Amanda
    Kernel Version: 2.6.9
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: wralph@nswc.navy.mil


Distribution: Fedora Core 2

Hardware Environment: Pentium III @800MHz, 384 MB memory, Adaptec AIC-7892A U160
SCSI controller, SEAGATE   Model: ST39204LW drive, Lite-ON LNE100TX NIC, Gateway
GP 800 computer. This machine is the Amanda tape server.

Software Environment: Amanda 2.4.4p2 Software, Fedora Core 2 environment with
vanilla 2.6.9 kernel.

Problem Description: Amanda clients exchanges UDP packets with the server giving
it a TCP port number with which to connect in order to receive files to be
dumped to tape. Under kernel-2.6.8.1 the sofware performs perfectly. Under
kernel-2.6.9, with exactly the same Amanda software, the UDP packet exchange
seems to occur, but no TCP connection between client and server occurs. The
client eventually times out with messages like:

sendbackup: time 0.000: stream_server: waiting for connection: 0.0.0.0.32951
sendbackup: time 0.000: stream_server: waiting for connection: 0.0.0.0.32952
sendbackup: time 0.000: stream_server: waiting for connection: 0.0.0.0.32953
sendbackup: time 0.000: waiting for connect on 32951, then 32952, then 32953
sendbackup: time 29.995: stream_accept: timeout after 30 seconds
sendbackup: time 29.995: timeout on data port 32951
sendbackup: time 59.990: stream_accept: timeout after 30 seconds
sendbackup: time 59.990: timeout on mesg port 32952
sendbackup: time 89.987: stream_accept: timeout after 30 seconds
sendbackup: time 89.987: timeout on index port 32953
sendbackup: time 89.987: pid 3008 finish time Thu Oct 21 12:30:38 2004

Running tcpdump on both client and server shows no TCP traffic at all. I have
completely disabled iptables in an effort to allow the traffic to pass. No
effect. Re-compiling the Amanda software had no effect. Switching back to
kernel-2.6.8.1 allows it to run normally.lspci -vvv
00:00.0 Host bridge: Intel Corp. 440BX/ZX/DX - 82443BX/ZX/DX Host bridge (rev 03)
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
        Latency: 64
        Region 0: Memory at f8000000 (32-bit, prefetchable)
        Capabilities: [a0] AGP version 1.0
                Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64- HTrans-
64bit- FW- AGP3- Rate=x1,x2
                Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW- Rate=<none>

00:01.0 PCI bridge: Intel Corp. 440BX/ZX/DX - 82443BX/ZX/DX AGP bridge (rev 03)
(prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV+ VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap- 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 128
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: f5000000-f5ffffff
        Prefetchable memory behind bridge: fc000000-fdffffff
        BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B+

00:07.0 ISA bridge: Intel Corp. 82371AB/EB/MB PIIX4 ISA (rev 02)
        Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0

00:07.1 IDE interface: Intel Corp. 82371AB/EB/MB PIIX4 IDE (rev 01) (prog-if 80
[Master])
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64
        Region 4: I/O ports at 1820 [size=16]

00:07.2 USB Controller: Intel Corp. 82371AB/EB/MB PIIX4 USB (rev 01) (prog-if 00
[UHCI])
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64
        Interrupt: pin D routed to IRQ 9
        Region 4: I/O ports at 1800 [size=32]

00:07.3 Bridge: Intel Corp. 82371AB/EB/MB PIIX4 ACPI (rev 02)
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Interrupt: pin ? routed to IRQ 9

00:0e.0 SCSI storage controller: Adaptec AIC-7892A U160/m (rev 02)
        Subsystem: Adaptec 29160 Ultra160 SCSI Controller
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 72 (10000ns min, 6250ns max), Cache Line Size 08
        Interrupt: pin A routed to IRQ 11
        BIST result: 00
        Region 0: I/O ports at 1000 [disabled]
        Region 1: Memory at f4000000 (64-bit, non-prefetchable) [size=4K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:10.0 Ethernet controller: Lite-On Communications Inc LNE100TX (rev 20)
        Subsystem: Netgear FA310TX
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64
        Interrupt: pin A routed to IRQ 9
        Region 0: I/O ports at 1400
        Region 1: Memory at f4001000 (32-bit, non-prefetchable) [size=256]

01:00.0 VGA compatible controller: nVidia Corporation NV5M64 [RIVA TNT2 Model
64/Model 64 Pro] (rev 15) (prog-if 00 [VGA])
        Subsystem: VISIONTEK: Unknown device 0002
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (1250ns min, 250ns max)
        Interrupt: pin A routed to IRQ 11
        Region 0: Memory at f5000000 (32-bit, non-prefetchable)
        Region 1: Memory at fc000000 (32-bit, prefetchable) [size=32M]
        Capabilities: [60] Power Management version 1
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [44] AGP version 2.0
                Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA- ITACoh- GART64- HTrans-
64bit- FW- AGP3- Rate=x1,x2,x4
                Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW- Rate=<none>

more /proc/cpuinfo
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 8
model name      : Pentium III (Coppermine)
stepping        : 3
cpu MHz         : 795.899
cache size      : 256 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 sep mtrr pge mca cmov pat
pse36 mmx fxsr sse
bogomips        : 1572.86

more /proc/modules
uhci_hcd 29136 0 - Live 0xd8997000

more /proc/iomem
00000000-0009f3ff : System RAM
0009f400-0009ffff : reserved
000a0000-000bffff : Video RAM area
000c0000-000cffff : Video ROM
000d0000-000d65ff : Adapter ROM
000e4000-000effff : Adapter ROM
000f0000-000fffff : System ROM
00100000-040fd7ff : System RAM
  00100000-003296b0 : Kernel code
  003296b1-003fbcbf : Kernel data
040fd800-040ff7ff : ACPI Tables
040ff800-040ffbff : ACPI Non-volatile Storage
040ffc00-17ffffff : System RAM
f4000000-f4000fff : 0000:00:0e.0
  f4000000-f4000fff : aic7xxx
f4001000-f40010ff : 0000:00:10.0
  f4001000-f40010ff : tulip
f5000000-f5ffffff : PCI Bus #01
  f5000000-f5ffffff : 0000:01:00.0
f8000000-fbffffff : 0000:00:00.0
fc000000-fdffffff : PCI Bus #01
  fc000000-fdffffff : 0000:01:00.0
    fc000000-fc17ffff : vesafb
fffe7000-ffffffff : reserved

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
02f8-02ff : serial
0376-0376 : ide1
03c0-03df : vesafb
03f6-03f6 : ide0
03f8-03ff : serial
0cf8-0cff : PCI conf1
1000-10ff : 0000:00:0e.0
1400-14ff : 0000:00:10.0
  1400-14ff : tulip
1800-181f : 0000:00:07.2
  1800-181f : uhci_hcd
1820-182f : 0000:00:07.1
  1820-1827 : ide0
  1828-182f : ide1
7000-701f : 0000:00:07.3
8000-803f : 0000:00:07.3

more /proc/scsi/scsi
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: SEAGATE  Model: ST39204LW        Rev: 0006
  Type:   Direct-Access                    ANSI SCSI revision: 03
Host: scsi0 Channel: 00 Id: 06 Lun: 00
  Vendor: SEAGATE  Model: DAT    06240-XXX Rev: 8110
  Type:   Sequential-Access                ANSI SCSI revision: 03



Steps to reproduce: Run Amanda server on kernel-2.6.9.

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
