From: Neil Jeffery <nwjeffery@gmail.com>
Subject: PROBLEM: Realtek RTL8101/2/6E unstable with both r8169 and r8101 drivers
Date: Thu, 12 Jan 2017 18:51:18 +0000
Message-ID: <CAFwfgc1i0SRTzu+0drT2zO+TduP0bwd_YPxbUFpjzf16H_SS2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35107 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdALSvU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 13:51:20 -0500
Received: by mail-qk0-f194.google.com with SMTP id u25so3959798qki.2
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 10:51:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[1.] One line summary of the problem: Realtek RTL8101/2/6E is unstable
with both r8169 and r8101 drivers. (Intel D945GCLF with kernel
4.10rc2) (NOTE: 4.10rc3 fails during dpkg -i)

[2.] Full description of the problem/report: Immediately following
boot (or depmod r8101) the Ethernet interface works and I can
successfully communicate over the interface I have seen consistent
downloads of 6MB/s. At a seemingly random point later, connectivity
will cease without warning. At this time the stats (RX/TX
bytes/packets) in ifconfig cease to increase but the interface remains
UP. A ping to the locally configured static IP returns successfully.
"ifdown && ifup" does not fix the problem, but "rmmod && depmod" does.
The point at which the connectivity ceases does not appear to be
consistent in either time or amount of data transferred. I have tried
v1.030 and v1.029 of the r8101 driver. Note that with the native r8169
driver I get no Ethernet functionality at all. The interface shows as
up but I can't transfer any data over it.

[3.] Keywords (i.e., modules, networking, kernel):

[4.] Kernel version (from /proc/version): Linux version
4.10.0-041000rc2-generic (kernel@tangerine) (gcc version 6.2.0
20161005 (Ubuntu 6.2.0-5ubuntu12) ) #201701011831 SMP Sun Jan 1
23:50:26 UTC 2017

[5.] Output of Oops.. message (if applicable) with symbolic information
     resolved (see Documentation/oops-tracing.txt)

[6.] A small shell script or example program which triggers the
     problem (if possible)

[7.] Environment: Description: Ubuntu 16.04.1 LTS Release: 16.04

[7.1.] Software (add the output of the ver_linux script here)

[7.2.] Processor information (from /proc/cpuinfo): processor : 0
vendor_id : GenuineIntel
cpu family : 6
model  : 28
model name : Intel(R) Atom(TM) CPU  230   @ 1.60GHz
stepping : 2
cpu MHz  : 1596.122
cache size : 512 KB
physical id : 0
siblings : 2
core id  : 0
cpu cores : 1
apicid  : 0
initial apicid : 0
fdiv_bug : no
f00f_bug : no
coma_bug : no
fpu  : yes
fpu_exception : yes
cpuid level : 10
wp  : yes
flags  : fpu vme de tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat
clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm constant_tsc
arch_perfmon pebs bts aperfmperf pni dtes64 monitor ds_cpl tm2 ssse3
cx16 xtpr pdcm movbe lahf_lm dtherm
bugs  :
bogomips : 3192.24
clflush size : 64
cache_alignment : 64
address sizes : 32 bits physical, 48 bits virtual
power management:
processor : 1
vendor_id : GenuineIntel
cpu family : 6
model  : 28
model name : Intel(R) Atom(TM) CPU  230   @ 1.60GHz
stepping : 2
cpu MHz  : 1596.122
cache size : 512 KB
physical id : 0
siblings : 2
core id  : 0
cpu cores : 1
apicid  : 1
initial apicid : 1
fdiv_bug : no
f00f_bug : no
coma_bug : no
fpu  : yes
fpu_exception : yes
cpuid level : 10
wp  : yes
flags  : fpu vme de tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat
clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm constant_tsc
arch_perfmon pebs bts aperfmperf pni dtes64 monitor ds_cpl tm2 ssse3
cx16 xtpr pdcm movbe lahf_lm dtherm
bugs  :
bogomips : 3192.26
clflush size : 64
cache_alignment : 64
address sizes : 32 bits physical, 48 bits virtual
power management:


[7.3.] Module information (from /proc/modules): nls_iso8859_1 16384 1
- Live 0xf8611000
nfnetlink_log 20480 1 - Live 0xf868f000
nfnetlink 16384 2 nfnetlink_log, Live 0xf8686000
snd_hda_codec_realtek 77824 1 - Live 0xf8735000
snd_hda_codec_generic 69632 1 snd_hda_codec_realtek, Live 0xf874b000
snd_hda_intel 32768 0 - Live 0xf8716000
snd_hda_codec 118784 3
snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_intel, Live
0xf86b6000
gpio_ich 16384 0 - Live 0xf8646000
snd_hda_core 73728 4
snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_intel,snd_hda_codec,
Live 0xf86f3000
snd_hwdep 16384 1 snd_hda_codec, Live 0xf86a9000
snd_pcm 98304 3 snd_hda_intel,snd_hda_codec,snd_hda_core, Live 0xf86d6000
ppdev 20480 0 - Live 0xf8677000
snd_seq_midi 16384 0 - Live 0xf8641000
snd_seq_midi_event 16384 1 snd_seq_midi, Live 0xf862d000
snd_rawmidi 28672 1 snd_seq_midi, Live 0xf86ae000
snd_seq 57344 2 snd_seq_midi,snd_seq_midi_event, Live 0xf869a000
input_leds 16384 0 - Live 0xf866e000
coretemp 16384 0 - Live 0xf85d9000
serio_raw 16384 0 - Live 0xf8695000
lpc_ich 20480 0 - Live 0xf8627000
snd_seq_device 16384 3 snd_seq_midi,snd_rawmidi,snd_seq, Live 0xf8622000
snd_timer 32768 2 snd_pcm,snd_seq, Live 0xf8665000
snd 69632 10 snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm,snd_rawmidi,snd_seq,snd_seq_device,snd_timer,
Live 0xf8653000
soundcore 16384 1 snd, Live 0xf852b000
shpchp 32768 0 - Live 0xf8619000
parport_pc 32768 1 - Live 0xf8633000
mac_hid 16384 0 - Live 0xf85bd000
smsc47m192 16384 0 - Live 0xf85c3000
hwmon_vid 16384 1 smsc47m192, Live 0xf8553000
lp 20480 0 - Live 0xf8559000
parport 49152 3 ppdev,parport_pc,lp, Live 0xf8601000
autofs4 40960 2 - Live 0xf85aa000
uas 20480 0 - Live 0xf85d3000
usb_storage 57344 2 uas, Live 0xf8e0f000
i915 1187840 1 - Live 0xf903a000
video 36864 1 i915, Live 0xf85c9000
i2c_algo_bit 16384 1 i915, Live 0xf8536000
drm_kms_helper 151552 1 i915, Live 0xf856c000
syscopyarea 16384 1 drm_kms_helper, Live 0xf854e000
sysfillrect 16384 1 drm_kms_helper, Live 0xf8531000
sysimgblt 16384 1 drm_kms_helper, Live 0xf8563000
pata_acpi 16384 0 - Live 0xf8546000
fb_sys_fops 16384 1 drm_kms_helper, Live 0xf853f000
drm 319488 3 i915,drm_kms_helper, Live 0xf8e75000
r8101 176128 0 - Live 0xf8de3000 (OE)
fjes 61440 0 - Live 0xf8595000

[7.4.] Loaded driver and hardware information (/proc/ioports,
/proc/iomem): 0000-0cf7 : PCI Bus 0000:00
  0000-001f : dma1
  0020-0021 : pic1
  0040-0043 : timer0
  0050-0053 : timer1
  0060-0060 : keyboard
  0061-0061 : PNP0800:00
  0064-0064 : keyboard
  0070-0071 : rtc0
  0080-008f : dma page reg
  00a0-00a1 : pic2
  00c0-00df : dma2
  00f0-00ff : fpu
    00f0-00f0 : PNP0C04:00
  0170-0177 : 0000:00:1f.1
    0170-0177 : ata_piix
  01f0-01f7 : 0000:00:1f.1
    01f0-01f7 : ata_piix
  0376-0376 : 0000:00:1f.1
    0376-0376 : ata_piix
  0378-037a : parport0
  037b-037f : parport0
  03c0-03df : vesafb
  03f6-03f6 : 0000:00:1f.1
    03f6-03f6 : ata_piix
  03f8-03ff : serial
  0400-047f : 0000:00:1f.0
    0400-047f : pnp 00:02
      0400-0403 : ACPI PM1a_EVT_BLK
      0404-0405 : ACPI PM1a_CNT_BLK
      0408-040b : ACPI PM_TMR
      0420-0420 : ACPI PM2_CNT_BLK
      0428-042f : ACPI GPE0_BLK
      0430-0433 : iTCO_wdt.0.auto
      0460-047f : iTCO_wdt.0.auto
  0500-053f : gpio_ich.1.auto
    0500-053f : 0000:00:1f.0
      0500-053f : pnp 00:02
        0530-053f : gpio_ich
  0680-06ff : pnp 00:02
  0778-077a : parport0
0cf8-0cff : PCI conf1
0d00-ffff : PCI Bus 0000:00
  1000-1fff : PCI Bus 0000:01
    1000-10ff : 0000:01:00.0
      1000-10ff : r8101
  2000-201f : 0000:00:1f.3
  2020-203f : 0000:00:1d.3
    2020-203f : uhci_hcd
  2040-205f : 0000:00:1d.1
    2040-205f : uhci_hcd
  2060-207f : 0000:00:1d.0
    2060-207f : uhci_hcd
  2080-208f : 0000:00:1f.2
    2080-208f : ata_piix
  2090-209f : 0000:00:1f.1
    2090-209f : ata_piix
  20a0-20a7 : 0000:00:1f.2
    20a0-20a7 : ata_piix
  20a8-20af : 0000:00:1f.2
    20a8-20af : ata_piix
  20c0-20c7 : 0000:00:02.0
  20c8-20cb : 0000:00:1f.2
    20c8-20cb : ata_piix
  20cc-20cf : 0000:00:1f.2
    20cc-20cf : ata_piix
  3000-3fff : PCI Bus 0000:02
  4000-4fff : PCI Bus 0000:03
00000000-00000fff : reserved
00001000-0008efff : System RAM
0008f000-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
  000a0000-000bffff : Video RAM area
000c0000-000c7fff : Video ROM
000cb000-000cbfff : Adapter ROM
000e0000-000fffff : reserved
  000e0000-000effff : PCI Bus 0000:00
  000f0000-000fffff : System ROM
00100000-7f532fff : System RAM
  16000000-1681281e : Kernel code
  1681281f-16c4287f : Kernel data
  16d44000-16e28fff : Kernel bss
7f533000-7f53afff : reserved
7f53b000-7f5cafff : System RAM
7f5cb000-7f5cefff : reserved
7f5cf000-7f65ffff : System RAM
7f660000-7f6effff : ACPI Non-volatile Storage
7f6f0000-7f6f2fff : System RAM
7f6f3000-7f6fefff : ACPI Tables
7f6ff000-7f6fffff : System RAM
7f700000-7fffffff : reserved
  7f800000-7ffbffff : Graphics Stolen Memory
80000000-ffffffff : reserved
  80000000-f0000000 : PCI Bus 0000:00
    80000000-8fffffff : 0000:00:02.0
    90000000-900fffff : PCI Bus 0000:01
      90000000-9000ffff : 0000:01:00.0
        90000000-9000ffff : r8101
    90100000-901fffff : PCI Bus 0000:01
      90100000-90100fff : 0000:01:00.0
        90100000-90100fff : r8101
      90120000-9013ffff : 0000:01:00.0
    90200000-9027ffff : 0000:00:02.0
    90280000-902bffff : 0000:00:02.0
    902c0000-902c3fff : 0000:00:1b.0
      902c0000-902c3fff : ICH HD audio
    902c4000-902c43ff : 0000:00:1d.7
      902c4000-902c43ff : ehci_hcd
    90300000-904fffff : PCI Bus 0000:02
    90500000-906fffff : PCI Bus 0000:02
    90700000-908fffff : PCI Bus 0000:03
    90900000-90afffff : PCI Bus 0000:03
  f8000000-febfffff : PCI Bus 0000:00
  fec00000-fec003ff : IOAPIC 0
    fec00000-fec000ff : PNP0003:00
  fed13000-fed13fff : pnp 00:00
  fed14000-fed17fff : pnp 00:00
  fed18000-fed18fff : pnp 00:00
  fed19000-fed19fff : pnp 00:00
  fed1c000-fed1ffff : pnp 00:00
    fed1f410-fed1f414 : iTCO_wdt.0.auto
  fed20000-fed3ffff : pnp 00:00
  fed45000-fed99fff : pnp 00:00
  fee00000-fee00fff : Local APIC


[7.5.] PCI information ('lspci -vvv' as root): 00:00.0 Host bridge:
Intel Corporation 82945G/GZ/P/PL Memory Controller Hub (rev 02)
 Subsystem: Intel Corporation 82945G/GZ/P/PL Memory Controller Hub
 Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
 Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ >SERR- <PERR- INTx-
 Latency: 0
 Capabilities: [e0] Vendor Specific Information: Len=09 <?>
00:02.0 VGA compatible controller: Intel Corporation 82945G/GZ
Integrated Graphics Controller (rev 02) (prog-if 00 [VGA controller])
 Subsystem: Intel Corporation 82945G/GZ Integrated Graphics Controller
 Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
 Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0
 Interrupt: pin A routed to IRQ 16
 Region 0: Memory at 90200000 (32-bit, non-prefetchable) [size=512K]
 Region 1: I/O ports at 20c0 [size=8]
 Region 2: Memory at 80000000 (32-bit, prefetchable) [size=256M]
 Region 3: Memory at 90280000 (32-bit, non-prefetchable) [size=256K]
 [virtual] Expansion ROM at 000c0000 [disabled] [size=128K]
 Capabilities: [90] MSI: Enable- Count=1/1 Maskable- 64bit-
  Address: 00000000  Data: 0000
 Capabilities: [d0] Power Management version 2
  Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
  Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
 Kernel driver in use: i915
 Kernel modules: i915, intelfb
00:1b.0 Audio device: Intel Corporation NM10/ICH7 Family High
Definition Audio Controller (rev 01)
 Subsystem: Intel Corporation NM10/ICH7 Family High Definition Audio Controller
 Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
 Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0, Cache Line Size: 64 bytes
 Interrupt: pin A routed to IRQ 27
 Region 0: Memory at 902c0000 (64-bit, non-prefetchable) [size=16K]
 Capabilities: [50] Power Management version 2
  Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
  Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
 Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
  Address: 00000000fee0300c  Data: 4152
 Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
  DevCap: MaxPayload 128 bytes, PhantFunc 0
   ExtTag- RBE-
  DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
   RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
   MaxPayload 128 bytes, MaxReadReq 128 bytes
  DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
 Capabilities: [100 v1] Virtual Channel
  Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
  Arb: Fixed- WRR32- WRR64- WRR128-
  Ctrl: ArbSelect=Fixed
  Status: InProgress-
  VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
   Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
   Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
   Status: NegoPending- InProgress-
  VC1: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
   Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
   Ctrl: Enable+ ID=1 ArbSelect=Fixed TC/VC=80
   Status: NegoPending- InProgress-
 Capabilities: [130 v1] Root Complex Link
  Desc: PortNumber=0f ComponentID=00 EltType=Config
  Link0: Desc: TargetPort=00 TargetComponent=00 AssocRCRB-
LinkType=MemMapped LinkValid+
   Addr: 00000000fed1c000
 Kernel driver in use: snd_hda_intel
 Kernel modules: snd_hda_intel
00:1c.0 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 1 (rev 01) (prog-if 00 [Normal decode])
 Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
 Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0, Cache Line Size: 64 bytes
 Interrupt: pin A routed to IRQ 24
 Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
 I/O behind bridge: 00001000-00001fff
 Memory behind bridge: 90100000-901fffff
 Prefetchable memory behind bridge: 0000000090000000-00000000900fffff
 Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
 BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
  PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
 Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
  DevCap: MaxPayload 128 bytes, PhantFunc 0
   ExtTag- RBE-
  DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
   RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
   MaxPayload 128 bytes, MaxReadReq 128 bytes
  DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
  LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s <256ns, L1 <4us
   ClockPM- Surprise- LLActRep+ BwNot- ASPMOptComp-
  LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
   ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
  LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
BWMgmt- ABWMgmt-
  SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
   Slot #1, PowerLimit 10.000W; Interlock- NoCompl-
  SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
   Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
  SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
   Changed: MRL- PresDet+ LinkState+
  RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
  RootCap: CRSVisible-
  RootSta: PME ReqID 0000, PMEStatus- PMEPending-
 Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
  Address: fee0300c  Data: 4191
 Capabilities: [90] Subsystem: Device 0000:0000
 Capabilities: [a0] Power Management version 2
  Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
  Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
 Capabilities: [100 v1] Virtual Channel
  Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
  Arb: Fixed+ WRR32- WRR64- WRR128-
  Ctrl: ArbSelect=Fixed
  Status: InProgress-
  VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
   Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
   Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
   Status: NegoPending- InProgress-
  VC1: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
   Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
   Ctrl: Enable- ID=0 ArbSelect=Fixed TC/VC=00
   Status: NegoPending- InProgress-
 Capabilities: [180 v1] Root Complex Link
  Desc: PortNumber=01 ComponentID=00 EltType=Config
  Link0: Desc: TargetPort=00 TargetComponent=00 AssocRCRB-
LinkType=MemMapped LinkValid+
   Addr: 00000000fed1c001
 Kernel driver in use: pcieport
 Kernel modules: shpchp
00:1c.2 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 3 (rev 01) (prog-if 00 [Normal decode])
 Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
 Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0, Cache Line Size: 64 bytes
 Interrupt: pin C routed to IRQ 25
 Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
 I/O behind bridge: 00003000-00003fff
 Memory behind bridge: 90300000-904fffff
 Prefetchable memory behind bridge: 0000000090500000-00000000906fffff
 Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
 BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
  PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
 Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
  DevCap: MaxPayload 128 bytes, PhantFunc 0
   ExtTag- RBE-
  DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
   RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
   MaxPayload 128 bytes, MaxReadReq 128 bytes
  DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
  LnkCap: Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s <1us, L1 <4us
   ClockPM- Surprise- LLActRep+ BwNot- ASPMOptComp-
  LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
   ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
  LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
  SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
   Slot #3, PowerLimit 10.000W; Interlock- NoCompl-
  SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
   Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
  SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
   Changed: MRL- PresDet- LinkState-
  RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
  RootCap: CRSVisible-
  RootSta: PME ReqID 0000, PMEStatus- PMEPending-
 Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
  Address: fee0300c  Data: 41b1
 Capabilities: [90] Subsystem: Device 0000:0000
 Capabilities: [a0] Power Management version 2
  Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
  Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
 Capabilities: [100 v1] Virtual Channel
  Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
  Arb: Fixed+ WRR32- WRR64- WRR128-
  Ctrl: ArbSelect=Fixed
  Status: InProgress-
  VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
   Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
   Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
   Status: NegoPending- InProgress-
  VC1: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
   Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
   Ctrl: Enable- ID=0 ArbSelect=Fixed TC/VC=00
   Status: NegoPending- InProgress-
 Capabilities: [180 v1] Root Complex Link
  Desc: PortNumber=03 ComponentID=00 EltType=Config
  Link0: Desc: TargetPort=00 TargetComponent=00 AssocRCRB-
LinkType=MemMapped LinkValid+
   Addr: 00000000fed1c001
 Kernel driver in use: pcieport
 Kernel modules: shpchp
00:1c.3 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 4 (rev 01) (prog-if 00 [Normal decode])
 Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
 Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0, Cache Line Size: 64 bytes
 Interrupt: pin D routed to IRQ 26
 Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
 I/O behind bridge: 00004000-00004fff
 Memory behind bridge: 90700000-908fffff
 Prefetchable memory behind bridge: 0000000090900000-0000000090afffff
 Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
 BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
  PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
 Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
  DevCap: MaxPayload 128 bytes, PhantFunc 0
   ExtTag- RBE-
  DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
   RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
   MaxPayload 128 bytes, MaxReadReq 128 bytes
  DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
  LnkCap: Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s <1us, L1 <4us
   ClockPM- Surprise- LLActRep+ BwNot- ASPMOptComp-
  LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
   ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
  LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
  SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
   Slot #4, PowerLimit 10.000W; Interlock- NoCompl-
  SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
   Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
  SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
   Changed: MRL- PresDet- LinkState-
  RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
  RootCap: CRSVisible-
  RootSta: PME ReqID 0000, PMEStatus- PMEPending-
 Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
  Address: fee0300c  Data: 41d1
 Capabilities: [90] Subsystem: Device 0000:0000
 Capabilities: [a0] Power Management version 2
  Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
  Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
 Capabilities: [100 v1] Virtual Channel
  Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
  Arb: Fixed+ WRR32- WRR64- WRR128-
  Ctrl: ArbSelect=Fixed
  Status: InProgress-
  VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
   Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
   Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
   Status: NegoPending- InProgress-
  VC1: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
   Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
   Ctrl: Enable- ID=0 ArbSelect=Fixed TC/VC=00
   Status: NegoPending- InProgress-
 Capabilities: [180 v1] Root Complex Link
  Desc: PortNumber=04 ComponentID=00 EltType=Config
  Link0: Desc: TargetPort=00 TargetComponent=00 AssocRCRB-
LinkType=MemMapped LinkValid+
   Addr: 00000000fed1c001
 Kernel driver in use: pcieport
 Kernel modules: shpchp
00:1d.0 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #1 (rev 01) (prog-if 00 [UHCI])
 Subsystem: Intel Corporation NM10/ICH7 Family USB UHCI Controller
 Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
 Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0
 Interrupt: pin A routed to IRQ 23
 Region 4: I/O ports at 2060 [size=32]
 Kernel driver in use: uhci_hcd
00:1d.1 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #2 (rev 01) (prog-if 00 [UHCI])
 Subsystem: Intel Corporation NM10/ICH7 Family USB UHCI Controller
 Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
 Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0
 Interrupt: pin B routed to IRQ 19
 Region 4: I/O ports at 2040 [size=32]
 Kernel driver in use: uhci_hcd
00:1d.3 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #4 (rev 01) (prog-if 00 [UHCI])
 Subsystem: Intel Corporation NM10/ICH7 Family USB UHCI Controller
 Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
 Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0
 Interrupt: pin D routed to IRQ 16
 Region 4: I/O ports at 2020 [size=32]
 Kernel driver in use: uhci_hcd
00:1d.7 USB controller: Intel Corporation NM10/ICH7 Family USB2 EHCI
Controller (rev 01) (prog-if 20 [EHCI])
 Subsystem: Intel Corporation NM10/ICH7 Family USB2 EHCI Controller
 Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
 Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0
 Interrupt: pin A routed to IRQ 23
 Region 0: Memory at 902c4000 (32-bit, non-prefetchable) [size=1K]
 Capabilities: [50] Power Management version 2
  Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
  Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
 Capabilities: [58] Debug port: BAR=1 offset=00a0
 Kernel driver in use: ehci-pci
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev e1)
(prog-if 01 [Subtractive decode])
 Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
 Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0
 Bus: primary=00, secondary=04, subordinate=04, sec-latency=32
 I/O behind bridge: 0000f000-00000fff
 Memory behind bridge: fff00000-000fffff
 Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
 Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
 BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
  PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
 Capabilities: [50] Subsystem: Intel Corporation 82801 PCI Bridge
00:1f.0 ISA bridge: Intel Corporation 82801GB/GR (ICH7 Family) LPC
Interface Bridge (rev 01)
 Subsystem: Intel Corporation 82801GB/GR (ICH7 Family) LPC Interface Bridge
 Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
 Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0
 Capabilities: [e0] Vendor Specific Information: Len=0c <?>
 Kernel driver in use: lpc_ich
 Kernel modules: intel_rng, lpc_ich, leds_ss4200
00:1f.1 IDE interface: Intel Corporation 82801G (ICH7 Family) IDE
Controller (rev 01) (prog-if 8a [Master SecP PriP])
 Subsystem: Intel Corporation 82801G (ICH7 Family) IDE Controller
 Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
 Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0
 Interrupt: pin A routed to IRQ 18
 Region 0: I/O ports at 01f0 [size=8]
 Region 1: I/O ports at 03f4
 Region 2: I/O ports at 0170 [size=8]
 Region 3: I/O ports at 0374
 Region 4: I/O ports at 2090 [size=16]
 Kernel driver in use: ata_piix
 Kernel modules: pata_acpi
00:1f.2 IDE interface: Intel Corporation NM10/ICH7 Family SATA
Controller [IDE mode] (rev 01) (prog-if 8f [Master SecP SecO PriP
PriO])
 Subsystem: Intel Corporation NM10/ICH7 Family SATA Controller [IDE mode]
 Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
 Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0
 Interrupt: pin B routed to IRQ 19
 Region 0: I/O ports at 20a8 [size=8]
 Region 1: I/O ports at 20cc [size=4]
 Region 2: I/O ports at 20a0 [size=8]
 Region 3: I/O ports at 20c8 [size=4]
 Region 4: I/O ports at 2080 [size=16]
 Capabilities: [70] Power Management version 2
  Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
  Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
 Kernel driver in use: ata_piix
 Kernel modules: pata_acpi
00:1f.3 SMBus: Intel Corporation NM10/ICH7 Family SMBus Controller (rev 01)
 Subsystem: Intel Corporation NM10/ICH7 Family SMBus Controller
 Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
 Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Interrupt: pin B routed to IRQ 11
 Region 4: I/O ports at 2000 [size=32]
 Kernel modules: i2c_i801
01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8101/2/6E PCI Express Fast/Gigabit Ethernet controller (rev 02)
 Subsystem: Intel Corporation RTL8101/2/6E PCI Express Fast/Gigabit
Ethernet controller
 Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
 Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
 Latency: 0, Cache Line Size: 64 bytes
 Interrupt: pin A routed to IRQ 16
 Region 0: I/O ports at 1000 [size=256]
 Region 2: Memory at 90100000 (64-bit, non-prefetchable) [size=4K]
 Region 4: Memory at 90000000 (64-bit, prefetchable) [size=64K]
 [virtual] Expansion ROM at 90120000 [disabled] [size=128K]
 Capabilities: [40] Power Management version 3
  Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
  Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
 Capabilities: [50] MSI: Enable- Count=1/1 Maskable- 64bit+
  Address: 0000000000000000  Data: 0000
 Capabilities: [70] Express (v2) Endpoint, MSI 01
  DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <8us
   ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
  DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
   RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
   MaxPayload 128 bytes, MaxReadReq 4096 bytes
  DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
  LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s <512ns, L1 <64us
   ClockPM+ Surprise- LLActRep- BwNot- ASPMOptComp-
  LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
   ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
  LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
  DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF
Not Supported
  DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
  LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
    Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
ComplianceSOS-
    Compliance De-emphasis: -6dB
  LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
EqualizationPhase1-
    EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
 Capabilities: [ac] MSI-X: Enable- Count=2 Masked-
  Vector table: BAR=4 offset=00000000
  PBA: BAR=4 offset=00000800
 Capabilities: [cc] Vital Product Data
  Not readable
 Capabilities: [100 v1] Advanced Error Reporting
  UESta: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
  UEMsk: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq+ ACSViol-
  UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
MalfTLP+ ECRC- UnsupReq- ACSViol-
  CESta: RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
  CEMsk: RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
  AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
 Capabilities: [140 v1] Virtual Channel
  Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
  Arb: Fixed- WRR32- WRR64- WRR128-
  Ctrl: ArbSelect=Fixed
  Status: InProgress-
  VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
   Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
   Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
   Status: NegoPending- InProgress-
 Capabilities: [160 v1] Device Serial Number 01-00-00-00-36-4c-e0-00
 Kernel driver in use: r8101
 Kernel modules: r8101


[7.6.] SCSI information (from /proc/scsi/scsi): Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: PHILIPS  Model: PCRW5232P        Rev: P2.2
  Type:   CD-ROM                           ANSI  SCSI revision: 05
Host: scsi0 Channel: 00 Id: 01 Lun: 00
  Vendor: ATA      Model: ST380011A        Rev: 3.06
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi2 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: SAMSUNG HD103UJ  Rev: 1113
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi3 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: SAMSUNG HD103UJ  Rev: 1112
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi4 Channel: 00 Id: 00 Lun: 00
  Vendor: Ut161    Model: USB2FlashStorage Rev: 0.00
  Type:   Direct-Access                    ANSI  SCSI revision: 02


[7.7.] Other information that might be relevant to the problem
       (please look in /proc and include all information that you
       think to be relevant):

[X.] Other notes, patches, fixes, workarounds:
