From: Dirk Kraft <dirk.kraft@gmail.com>
Subject: Bug - regression - Via velocity interface coming up freezes kernel
Date: Sun, 22 Sep 2013 19:28:52 +0200
Message-ID: <CAFES+i+OYq_dDtEqAqkW7qYDrtdzkqc9hBGBDODQuqgvFJE7zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Julia Lawall <Julia.Lawall@lip6.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:53129 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188Ab3IVR2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 13:28:54 -0400
Received: by mail-wg0-f52.google.com with SMTP id m15so2302060wgh.19
        for <netdev@vger.kernel.org>; Sun, 22 Sep 2013 10:28:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I observe problems with my machine freezing when bringing up the
network interface (via velocity based). Detailed report below.

First message was rejected because of html. Julia Lawall, sorry about
sending multiple copies.

[1.] One line summary of the problem:
Via_velocity interface coming up freezes kernel - WARNING: CPU: 0 PID:
1529 at /build/buildd/linux-3.11.0/kernel/softirq.c:159
local_bh_enable+0x60/0x90()

[2.] Full description of the problem/report:
Bringing up the network interface (using ifup) serviced by the
via_velocity driver the machine freezes once an ip address is assigned
via dhcp. No further interaction, neither via the just brought up
interface nor the serial console, is possible. A git bisect shows that
this behaviour was introduced with
2fdac010bdcf10a30711b6924612dfc40daf19b8.
During some of the freezes a kernel warning is printed to syslog. I
was unable to see this with 3.12.0-rc1. I was able to observe this
with v3.11-rc6 and different ubuntu kernels. The warning looks like:
WARNING: CPU: 0 PID: 1529 at
/build/buildd/linux-3.11.0/kernel/softirq.c:159
local_bh_enable+0x60/0x90(). Detailed message under point 10.
The second network interface on the board (using the via_rhine driver)
does not show this behaviour. The board in question is a via epia
sn18000g.

[3.] Keywords (i.e., modules, networking, kernel):

[4.] Kernel version (from /proc/version):
Linux version 3.12.0-031200rc1-generic (apw@gomeisa) (gcc version
4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #201309161735 SMP Mon Sep 16
21:51:46 UTC 2013

[5.] Output of Oops.. message (if applicable) with symbolic
information resolved (see Documentation/oops-tracing.txt)

[6.] A small shell script or example program which triggers the
problem (if possible)

[7.] Environment
Description:    Ubuntu Saucy Salamander (development branch)
Release:        13.10

[7.1.] Software (add the output of the ver_linux script here)
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux nas 3.12.0-031200rc1-generic #201309161735 SMP Mon Sep 16
21:51:46 UTC 2013 i686 i686 i686 GNU/Linux

Gnu C                  4.8
Gnu make               3.81
binutils               2.23.52.20130913
util-linux             2.20.1
mount                  support
module-init-tools      9
e2fsprogs              1.42.8
reiserfsprogs          3.6.21
Linux C Library        2.17
Dynamic linker (ldd)   2.17
/usr/bin/ldd: line 41: printf: write error: Broken pipe
/usr/bin/ldd: line 43: printf: write error: Broken pipe
Procps                 3.3.3
Net-tools              1.60
Kbd                    1.15.5
Sh-utils               8.20
wireless-tools         30
Modules Loaded         snd_hda_codec_via snd_hda_intel snd_hda_codec
snd_hwdep snd_pcm snd_page_alloc snd_seq_midi snd_seq_midi_event
snd_rawmidi snd_seq snd_seq_device snd_timer snd psmouse via_cputemp
soundcore serio_raw i2c_viapro shpchp mac_hid hwmon_vid lp parport
binfmt_misc raid10 raid1 raid0 multipath linear dm_crypt raid456
async_raid6_recov async_memcpy async_pq async_xor async_tx xor
raid6_pq padlock_sha pata_acpi padlock_aes via_rhine via_rng ahci
via_velocity mii libahci pata_via crc_ccitt

[7.2.] Processor information (from /proc/cpuinfo):
dirk@nas:~$ cat /proc/cpuinfo
processor       : 0
vendor_id       : CentaurHauls
cpu family      : 6
model           : 13
model name      : VIA C7 Processor 1800MHz
stepping        : 0
cpu MHz         : 800.000
cache size      : 128 KB
fdiv_bug        : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
cmov pat clflush acpi mmx fxsr sse sse2 tm nx pni est tm2 xtpr rng
rng_en ace ace_en ace2 ace2_en phe phe_en pmm pmm_en
bogomips        : 1595.96
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 32 bits virtual
power management:

[7.3.] Module information (from /proc/modules):
snd_hda_codec_via 23198 1 - Live 0x00000000
snd_hda_intel 43367 0 - Live 0x00000000
snd_hda_codec 169632 2 snd_hda_codec_via,snd_hda_intel, Live 0x00000000
snd_hwdep 13276 1 snd_hda_codec, Live 0x00000000
snd_pcm 90501 2 snd_hda_intel,snd_hda_codec, Live 0x00000000
snd_page_alloc 18398 2 snd_hda_intel,snd_pcm, Live 0x00000000
snd_seq_midi 13132 0 - Live 0x00000000
snd_seq_midi_event 14475 1 snd_seq_midi, Live 0x00000000
snd_rawmidi 25198 1 snd_seq_midi, Live 0x00000000
snd_seq 55716 2 snd_seq_midi,snd_seq_midi_event, Live 0x00000000
snd_seq_device 14137 3 snd_seq_midi,snd_rawmidi,snd_seq, Live 0x00000000
snd_timer 28971 2 snd_pcm,snd_seq, Live 0x00000000
snd 61311 10 snd_hda_codec_via,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm,snd_seq_midi,snd_rawmidi,snd_seq,snd_seq_device,snd_timer,
Live 0x00000000
psmouse 92689 0 - Live 0x00000000
via_cputemp 12995 0 - Live 0x00000000
soundcore 12600 1 snd, Live 0x00000000
serio_raw 13230 0 - Live 0x00000000
i2c_viapro 13130 0 - Live 0x00000000
shpchp 32265 0 - Live 0x00000000
mac_hid 13077 0 - Live 0x00000000
hwmon_vid 12723 1 via_cputemp, Live 0x00000000
lp 13359 0 - Live 0x00000000
parport 40945 1 lp, Live 0x00000000
binfmt_misc 13172 1 - Live 0x00000000
raid10 48030 0 - Live 0x00000000
raid1 35268 0 - Live 0x00000000
raid0 17594 0 - Live 0x00000000
multipath 12977 0 - Live 0x00000000
linear 12766 0 - Live 0x00000000
dm_crypt 22524 0 - Live 0x00000000
raid456 81541 1 - Live 0x00000000
async_raid6_recov 13000 1 raid456, Live 0x00000000
async_memcpy 12578 2 raid456,async_raid6_recov, Live 0x00000000
async_pq 13082 2 raid456,async_raid6_recov, Live 0x00000000
async_xor 12932 3 raid456,async_raid6_recov,async_pq, Live 0x00000000
async_tx 13251 5
raid456,async_raid6_recov,async_memcpy,async_pq,async_xor, Live
0x00000000
xor 26221 1 async_xor, Live 0x00000000
raid6_pq 97455 2 async_raid6_recov,async_pq, Live 0x00000000
padlock_sha 13317 0 - Live 0x00000000
pata_acpi 12886 0 - Live 0x00000000
padlock_aes 12899 0 - Live 0x00000000
via_rhine 27895 0 - Live 0x00000000
via_rng 12588 0 - Live 0x00000000
ahci 25703 8 - Live 0x00000000
via_velocity 37949 0 - Live 0x00000000
mii 13693 1 via_rhine, Live 0x00000000
libahci 30834 1 ahci, Live 0x00000000
pata_via 13439 3 - Live 0x00000000
crc_ccitt 12627 1 via_velocity, Live 0x00000000

[7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
dirk@nas:~$ cat /proc/ioports
0000-001f : dma1
0020-0021 : pic1
0040-0043 : timer0
0050-0053 : timer1
0060-0060 : keyboard
0064-0064 : keyboard
0070-0071 : rtc0
0080-008f : dma page reg
00a0-00a1 : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : 0000:00:0f.1
  0170-0177 : pata_via
01f0-01f7 : 0000:00:0f.1
  01f0-01f7 : pata_via
02f8-02ff : serial
0400-041f : pnp 00:07
  0400-0407 : vt596_smbus
04d0-04d1 : pnp 00:07
0800-0803 : ACPI PM1a_EVT_BLK
0804-0805 : ACPI PM1a_CNT_BLK
0808-080b : ACPI PM_TMR
0810-0815 : ACPI CPU throttle
0820-0823 : ACPI GPE0_BLK
0850-0853 : ACPI GPE1_BLK
0a00-0a7f : pnp 00:06
0cf8-0cff : PCI conf1
162e-162f : pnp 00:06
2000-2fff : PCI Bus 0000:02
c800-c8ff : 0000:00:12.0
  c800-c8ff : via-rhine
cc00-cc1f : 0000:00:10.0
  cc00-cc1f : uhci_hcd
d000-d01f : 0000:00:10.1
  d000-d01f : uhci_hcd
d080-d09f : 0000:00:10.2
  d080-d09f : uhci_hcd
d400-d40f : 0000:00:0f.0
  d400-d40f : ahci
d480-d483 : 0000:00:0f.0
  d480-d483 : ahci
d800-d807 : 0000:00:0f.0
  d800-d807 : ahci
d880-d883 : 0000:00:0f.0
  d880-d883 : ahci
dc00-dc07 : 0000:00:0f.0
  dc00-dc07 : ahci
e000-efff : PCI Bus 0000:03
  e800-e8ff : 0000:03:00.0
    e800-e8ff : via-velocity
fc00-fc0f : 0000:00:0f.1
  fc00-fc0f : pata_via

dirk@nas:~$ cat /proc/iomem
00000000-00000fff : reserved
00001000-0009b3ff : System RAM
0009b400-0009ffff : reserved
000a0000-000bffff : Video RAM area
000c0000-000cddff : Video ROM
000ce000-000cefff : Adapter ROM
000e0000-000fffff : reserved
  000f0000-000fffff : System ROM
00100000-cfeaffff : System RAM
  01000000-0168a762 : Kernel code
  0168a763-019f077f : Kernel data
  01ad3000-01bc6fff : Kernel bss
  18000000-1fffffff : Crash kernel
cfeb0000-cfebdfff : ACPI Tables
cfebe000-cfefffff : ACPI Non-volatile Storage
cff00000-cfffffff : RAM buffer
d0000000-d01fffff : PCI Bus 0000:02
d0200000-d03fffff : PCI Bus 0000:02
d0400000-d05fffff : PCI Bus 0000:03
d8000000-dfffffff : PCI Bus 0000:01
  d8000000-dfffffff : 0000:01:00.0
e0000000-efffffff : PCI MMCONFIG 0000 [bus 00-ff]
  e0000000-efffffff : pnp 00:09
f0000000-f7ffffff : 0000:00:00.0
fcfff400-fcfff4ff : 0000:00:12.0
  fcfff400-fcfff4ff : via-rhine
fcfff800-fcfff8ff : 0000:00:10.4
  fcfff800-fcfff8ff : ehci_hcd
fcfffc00-fcffffff : 0000:00:0f.0
  fcfffc00-fcffffff : ahci
fd000000-fe9fffff : PCI Bus 0000:01
  fd000000-fdffffff : 0000:01:00.0
  fe9f0000-fe9fffff : 0000:01:00.0
fea00000-feafffff : PCI Bus 0000:03
  feaffc00-feaffcff : 0000:03:00.0
    feaffc00-feaffcff : via-velocity
febfc000-febfffff : 0000:80:01.0
  febfc000-febfffff : ICH HD audio
fec00000-fec00fff : reserved
  fec00000-fec003ff : IOAPIC 0
fecc0000-fecc0fff : reserved
  fecc0000-fecc03ff : IOAPIC 1
fed1c000-fed1ffff : pnp 00:07
fee00000-fee00fff : Local APIC
  fee00000-fee00fff : reserved
    fee00000-fee00fff : pnp 00:08
ff780000-ffffffff : reserved

[7.5.] PCI information ('lspci -vvv' as root)
dirk@nas:~$ sudo lspci -vvv
00:00.0 Host bridge: VIA Technologies, Inc. CN896/VN896/P4M900 Host Bridge
        Subsystem: VIA Technologies, Inc. CN896/VN896/P4M900 Host Bridge
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
        Latency: 8
        Region 0: Memory at f0000000 (32-bit, prefetchable) [size=128M]
        Capabilities: [80] AGP version 3.5
                Status: RQ=8 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64-
HTrans- 64bit- FW- AGP3+ Rate=x4,x8
                Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit-
FW- Rate=<none>
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: agpgart-via

00:00.1 Host bridge: VIA Technologies, Inc. CN896/VN896/P4M900 Host Bridge
        Subsystem: VIA Technologies, Inc. CN896/VN896/P4M900 Host Bridge
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0

00:00.2 Host bridge: VIA Technologies, Inc. CN896/VN896/P4M900 Host Bridge
        Subsystem: VIA Technologies, Inc. CN896/VN896/P4M900 Host Bridge
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0

00:00.3 Host bridge: VIA Technologies, Inc. CN896/VN896/P4M900 Host Bridge
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0

00:00.4 Host bridge: VIA Technologies, Inc. CN896/VN896/P4M900 Host Bridge
        Subsystem: VIA Technologies, Inc. CN896/VN896/P4M900 Host Bridge
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0

00:00.5 PIC: VIA Technologies, Inc. CN896/VN896/P4M900 I/O APIC
Interrupt Controller (prog-if 20 [IO(X)-APIC])
        Subsystem: VIA Technologies, Inc. CN896/VN896/P4M900 I/O APIC
Interrupt Controller
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0

00:00.6 Host bridge: VIA Technologies, Inc. CN896/VN896/P4M900 Security Device
        Subsystem: VIA Technologies, Inc. CN896/VN896/P4M900 Security Device
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0

00:00.7 Host bridge: VIA Technologies, Inc. CN896/VN896/P4M900 Host Bridge
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0

00:01.0 PCI bridge: VIA Technologies, Inc. VT8237/VX700 PCI Bridge
(prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: fd000000-fe9fffff
        Prefetchable memory behind bridge: d8000000-dfffffff
        Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity+ SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [70] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-

00:02.0 PCI bridge: VIA Technologies, Inc. CN896/VN896/P4M900 PCI to
PCI Bridge Controller (rev 80) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
        I/O behind bridge: 00002000-00002fff
        Memory behind bridge: d0000000-d01fffff
        Prefetchable memory behind bridge: 00000000d0200000-00000000d03fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
<64ns, L1 <1us
                        ExtTag- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s
L1, Latency L0 <512ns, L1 <1us
                        ClockPM- Surprise+ LLActRep+ BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train-
SlotClk+ DLActive- BWMgmt- ABWMgmt-
                SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd-
HotPlug+ Surprise+
                        Slot #0, PowerLimit 150.000W; Interlock- NoCompl-
                SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet+
CmdCplt+ HPIrq+ LinkChg-
                        Control: AttnInd Unknown, PwrInd Unknown,
Power- Interlock-
                SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt-
PresDet- Interlock-
                        Changed: MRL- PresDet- LinkState-
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
PMEIntEna+ CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
        Capabilities: [68] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [70] MSI: Enable- Count=1/1 Maskable- 64bit+
                Address: 0000000000000000  Data: 0000
        Capabilities: [88] HyperTransport: MSI Mapping Enable- Fixed+
        Capabilities: [98] Subsystem: VIA Technologies, Inc. Device c323
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt-
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
        Capabilities: [140 v1] Virtual Channel
                Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
                Arb:    Fixed- WRR32- WRR64- WRR128-
                Ctrl:   ArbSelect=Fixed
                Status: InProgress-
                VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
                        Status: NegoPending- InProgress-
                VC1:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable- ID=1 ArbSelect=Fixed TC/VC=00
                        Status: NegoPending- InProgress-
        Capabilities: [180 v1] Root Complex Link
                Desc:   PortNumber=01 ComponentID=01 EltType=Config
                Link0:  Desc:   TargetPort=00 TargetComponent=01
AssocRCRB- LinkType=MemMapped LinkValid+
                        Addr:   0000000000000000
        Kernel driver in use: pcieport

00:03.0 PCI bridge: VIA Technologies, Inc. CN896/VN896/P4M900 PCI to
PCI Bridge Controller (rev 80) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
        I/O behind bridge: 0000e000-0000efff
        Memory behind bridge: fea00000-feafffff
        Prefetchable memory behind bridge: 00000000d0400000-00000000d05fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
<64ns, L1 <1us
                        ExtTag- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1,
Latency L0 <512ns, L1 <1us
                        ClockPM- Surprise+ LLActRep+ BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train-
SlotClk+ DLActive+ BWMgmt- ABWMgmt-
                SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd-
HotPlug+ Surprise+
                        Slot #0, PowerLimit 150.000W; Interlock- NoCompl-
                SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet+
CmdCplt+ HPIrq+ LinkChg-
                        Control: AttnInd Unknown, PwrInd Unknown,
Power- Interlock-
                SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt-
PresDet+ Interlock-
                        Changed: MRL- PresDet- LinkState-
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
PMEIntEna+ CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
        Capabilities: [68] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [70] MSI: Enable- Count=1/1 Maskable- 64bit+
                Address: 0000000000000000  Data: 0000
        Capabilities: [88] HyperTransport: MSI Mapping Enable- Fixed+
        Capabilities: [98] Subsystem: VIA Technologies, Inc. Device c323
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt-
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
        Capabilities: [140 v1] Virtual Channel
                Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
                Arb:    Fixed- WRR32- WRR64- WRR128-
                Ctrl:   ArbSelect=Fixed
                Status: InProgress-
                VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
                        Status: NegoPending- InProgress-
                VC1:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable- ID=1 ArbSelect=Fixed TC/VC=00
                        Status: NegoPending- InProgress-
        Capabilities: [180 v1] Root Complex Link
                Desc:   PortNumber=02 ComponentID=01 EltType=Config
                Link0:  Desc:   TargetPort=00 TargetComponent=01
AssocRCRB- LinkType=MemMapped LinkValid+
                        Addr:   0000000000000000
        Kernel driver in use: pcieport

00:0f.0 SATA controller: VIA Technologies, Inc. SATA RAID Controller
(rev 20) (prog-if 01 [AHCI 1.0])
        Subsystem: VIA Technologies, Inc. SATA RAID Controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64
        Interrupt: pin B routed to IRQ 21
        Region 0: I/O ports at dc00 [size=8]
        Region 1: I/O ports at d880 [size=4]
        Region 2: I/O ports at d800 [size=8]
        Region 3: I/O ports at d480 [size=4]
        Region 4: I/O ports at d400 [size=16]
        Region 5: Memory at fcfffc00 (32-bit, non-prefetchable) [size=1K]
        Capabilities: [c0] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot+,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [e0] MSI: Enable- Count=1/1 Maskable- 64bit-
                Address: 00000000  Data: 0000
        Kernel driver in use: ahci

00:0f.1 IDE interface: VIA Technologies, Inc.
VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 07)
(prog-if 8a [Master SecP PriP])
        Subsystem: VIA Technologies, Inc.
VT82C586/B/VT82C686/A/B/VT8233/A/C/VT8235 PIPC Bus Master IDE
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32
        Region 0: [virtual] Memory at 000001f0 (32-bit,
non-prefetchable) [size=8]
        Region 1: [virtual] Memory at 000003f0 (type 3,
non-prefetchable) [size=1]
        Region 2: [virtual] Memory at 00000170 (32-bit,
non-prefetchable) [size=8]
        Region 3: [virtual] Memory at 00000370 (type 3,
non-prefetchable) [size=1]
        Region 4: I/O ports at fc00 [size=16]
        Capabilities: [c0] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: pata_via

00:10.0 USB controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev 91) (prog-if 00 [UHCI])
        Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 20
        Region 4: I/O ports at cc00 [size=32]
        Capabilities: [80] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: uhci_hcd

00:10.1 USB controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev 91) (prog-if 00 [UHCI])
        Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 32 bytes
        Interrupt: pin C routed to IRQ 22
        Region 4: I/O ports at d000 [size=32]
        Capabilities: [80] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: uhci_hcd

00:10.2 USB controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev 91) (prog-if 00 [UHCI])
        Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 32 bytes
        Interrupt: pin B routed to IRQ 21
        Region 4: I/O ports at d080 [size=32]
        Capabilities: [80] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: uhci_hcd

00:10.4 USB controller: VIA Technologies, Inc. USB 2.0 (rev 90)
(prog-if 20 [EHCI])
        Subsystem: VIA Technologies, Inc. USB 2.0 Controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 32 bytes
        Interrupt: pin C routed to IRQ 22
        Region 0: Memory at fcfff800 (32-bit, non-prefetchable) [size=256]
        Capabilities: [80] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [88] Debug port: BAR=1 offset=00a0
        Kernel driver in use: ehci-pci

00:11.0 ISA bridge: VIA Technologies, Inc. VT8251 PCI to ISA Bridge
        Subsystem: VIA Technologies, Inc. VT8251 PCI to ISA Bridge
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Capabilities: [c0] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-

00:11.7 Host bridge: VIA Technologies, Inc. VT8237/8251 Ultra VLINK Controller
        Subsystem: VIA Technologies, Inc. VT8237/8251 Ultra VLINK Controller
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
        Latency: 128
        Capabilities: [58] HyperTransport: Interrupt Discovery and Configuration

00:12.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (rev 7c)
        Subsystem: VIA Technologies, Inc. VT6102 [Rhine II] Embeded
Ethernet Controller on VT8235
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (750ns min, 2000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 23
        Region 0: I/O ports at c800 [size=256]
        Region 1: Memory at fcfff400 (32-bit, non-prefetchable) [size=256]
        Capabilities: [40] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: via-rhine

00:13.0 Host bridge: VIA Technologies, Inc. VT8251 Host Bridge
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ >SERR- <PERR- INTx-
        Latency: 0

01:00.0 VGA compatible controller: VIA Technologies, Inc.
CN896/VN896/P4M900 [Chrome 9 HC] (rev 01) (prog-if 00 [VGA
controller])
        Subsystem: Device 0908:1975
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (500ns min)
        Interrupt: pin A routed to IRQ 11
        Region 0: Memory at d8000000 (32-bit, prefetchable) [size=128M]
        Region 1: Memory at fd000000 (32-bit, non-prefetchable) [size=16M]
        Expansion ROM at fe9f0000 [disabled] [size=64K]
        Capabilities: [60] Power Management version 2
                Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [70] AGP version 3.0
                Status: RQ=256 Iso- ArqSz=0 Cal=7 SBA+ ITACoh- GART64-
HTrans- 64bit- FW- AGP3+ Rate=x4,x8
                Command: RQ=1 ArqSz=0 Cal=0 SBA+ AGP- GART64- 64bit-
FW- Rate=<none>

03:00.0 Ethernet controller: VIA Technologies, Inc.
VT6120/VT6121/VT6122 Gigabit Ethernet Adapter (rev 82)
        Subsystem: VIA Technologies, Inc. Device 0110
        Physical Slot: 0-1
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Interrupt: pin A routed to IRQ 28
        Region 0: I/O ports at e800 [size=256]
        Region 1: Memory at feaffc00 (64-bit, non-prefetchable) [size=256]
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D3 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [90] Express (v1) Endpoint, MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
<64ns, L1 <1us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
Latency L0 <1us, L1 <2us
                        ClockPM+ Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train-
SlotClk- DLActive- BWMgmt- ABWMgmt-
        Capabilities: [c0] MSI: Enable- Count=1/1 Maskable+ 64bit+
                Address: 0000000000000000  Data: 0000
                Masking: 00000000  Pending: 00000000
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt-
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr+ BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
        Capabilities: [130 v1] Device Serial Number 00-40-45-ff-ff-78-90-08
        Kernel driver in use: via-velocity

80:00.0 PCI bridge: VIA Technologies, Inc. VT8251 PCIE Root Port
(prog-if 00 [Normal decode])
        Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0
        Bus: primary=80, secondary=82, subordinate=82, sec-latency=0
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: fff00000-000fffff
        Prefetchable memory behind bridge: fff00000-000fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
<64ns, L1 unlimited
                        ExtTag- RBE- FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #1, Speed 2.5GT/s, Width x2, ASPM L0s L1,
Latency L0 <64ns, L1 <1us
                        ClockPM- Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train-
SlotClk- DLActive- BWMgmt- ABWMgmt-
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
PMEIntEna- CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
        Capabilities: [68] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [70] MSI: Enable- Count=1/1 Maskable+ 64bit+
                Address: 0000000000000000  Data: 0000
                Masking: 00000000  Pending: 00000000
        Capabilities: [88] HyperTransport: MSI Mapping Enable- Fixed+
        Capabilities: [90] Subsystem: Device 0000:0000
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt-
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
        Capabilities: [140 v1] Virtual Channel
                Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
                Arb:    Fixed+ WRR32- WRR64- WRR128-
                Ctrl:   ArbSelect=Fixed
                Status: InProgress-
                VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
                        Status: NegoPending- InProgress-
                VC1:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable- ID=1 ArbSelect=Fixed TC/VC=00
                        Status: NegoPending- InProgress-
        Capabilities: [180 v1] Root Complex Link
                Desc:   PortNumber=01 ComponentID=01 EltType=Config
                Link0:  Desc:   TargetPort=00 TargetComponent=01
AssocRCRB- LinkType=MemMapped LinkValid+
                        Addr:   00000000fed1c000
        Kernel driver in use: pcieport

80:00.1 PCI bridge: VIA Technologies, Inc. VT8251 PCIE Root Port
(prog-if 00 [Normal decode])
        Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0
        Bus: primary=80, secondary=81, subordinate=81, sec-latency=0
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: fff00000-000fffff
        Prefetchable memory behind bridge: fff00000-000fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
<64ns, L1 unlimited
                        ExtTag- RBE- FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1,
Latency L0 <64ns, L1 <1us
                        ClockPM- Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train-
SlotClk- DLActive- BWMgmt- ABWMgmt-
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
PMEIntEna- CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
        Capabilities: [68] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [70] MSI: Enable- Count=1/1 Maskable+ 64bit+
                Address: 0000000000000000  Data: 0000
                Masking: 00000000  Pending: 00000000
        Capabilities: [88] HyperTransport: MSI Mapping Enable- Fixed+
        Capabilities: [90] Subsystem: Device 0000:0000
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt-
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
        Capabilities: [140 v1] Virtual Channel
                Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
                Arb:    Fixed+ WRR32- WRR64- WRR128-
                Ctrl:   ArbSelect=Fixed
                Status: InProgress-
                VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
                        Status: NegoPending- InProgress-
                VC1:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable- ID=1 ArbSelect=Fixed TC/VC=00
                        Status: NegoPending- InProgress-
        Capabilities: [180 v1] Root Complex Link
                Desc:   PortNumber=02 ComponentID=01 EltType=Config
                Link0:  Desc:   TargetPort=00 TargetComponent=01
AssocRCRB- LinkType=MemMapped LinkValid+
                        Addr:   00000000fed1c000
        Kernel driver in use: pcieport

80:01.0 Audio device: VIA Technologies, Inc. VT8237A/VT8251 HDA Controller
        Subsystem: VIA Technologies, Inc. VT8237A/VT8251 HDA Controller
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 17
        Region 0: Memory at febfc000 (32-bit, non-prefetchable) [size=16K]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [60] MSI: Enable- Count=1/1 Maskable- 64bit-
                Address: 00000000  Data: 0000
        Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
<64ns, L1 <1us
                        ExtTag- RBE- FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend+
                LnkCap: Port #0, Speed unknown, Width x0, ASPM
unknown, Latency L0 <64ns, L1 <1us
                        ClockPM- Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed unknown, Width x0, TrErr- Train-
SlotClk- DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100 v1] Virtual Channel
                Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
                Arb:    Fixed- WRR32- WRR64- WRR128-
                Ctrl:   ArbSelect=Fixed
                Status: InProgress-
                VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
                        Status: NegoPending- InProgress-
                VC1:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable- ID=1 ArbSelect=Fixed TC/VC=00
                        Status: NegoPending- InProgress-
        Capabilities: [130 v1] Root Complex Link
                Desc:   PortNumber=03 ComponentID=01 EltType=Config
                Link0:  Desc:   TargetPort=00 TargetComponent=01
AssocRCRB- LinkType=MemMapped LinkValid+
                        Addr:   00000000fed1c000
        Kernel driver in use: snd_hda_intel

[7.6.] SCSI information (from /proc/scsi/scsi)
dirk@nas:~$ cat /proc/scsi/scsi
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: SAMSUNG HM160HC  Rev: LQ10
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi2 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: ST31500341AS     Rev: CC1H
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi3 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: ST31500341AS     Rev: CC1H
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi4 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: ST31500341AS     Rev: CC1H
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi5 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: ST31500341AS     Rev: CC1H
  Type:   Direct-Access                    ANSI  SCSI revision: 05

[7.7.] Other information that might be relevant to the problem (please
look in /proc and include all information that you think to be
relevant):
dirk@nas:~$ ls /proc/
1     1223  132   1509  163   1965  2054  26    42   597   asound
driver       key-users      mounts        stat           vmstat
10    1224  134   151   1656  1975  21    2609  45   65    buddyinfo
execdomains  kmsg           mtrr          swaps          zoneinfo
1097  123   137   152   166   1978  2165  263   46   66    bus
fb           kpagecount     net           sys
11    1242  1383  1541  1667  1981  2198  264   473  668   cgroups
filesystems  kpageflags     pagetypeinfo  sysrq-trigger
1124  1243  14    1542  167   1983  22    27    5    7     cmdline
fs           latency_stats  partitions    sysvipc
1130  125   1423  1550  170   1985  2217  28    504  793   consoles
interrupts   loadavg        sched_debug   timer_list
1151  13    1428  159   172   1986  2285  29    534  8     cpuinfo
iomem        locks          schedstat     timer_stats
1154  130   1442  1591  18    2     23    3     552  830   crypto
ioports      mdstat         scsi          tty
1164  1303  1458  16    1828  20    24    30    564  842   devices
irq          meminfo        self          uptime
12    131   15    160   19    2034  25    407   587  9     diskstats
kallsyms     misc           slabinfo      version
122   1319  150   162   1949  2035  2572  408   588  acpi  dma
kcore        modules        softirqs      vmallocinfo

[8.]
Downstream bug report is here:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1225571

[9.]
Bisect log:
git bisect start
# good: [d4e4ab86bcba5a72779c43dc1459f71fea3d89c8] Linux 3.11-rc5
git bisect good d4e4ab86bcba5a72779c43dc1459f71fea3d89c8
# bad: [b36f4be3de1b123d8601de062e7dbfc904f305fb] Linux 3.11-rc6
git bisect bad b36f4be3de1b123d8601de062e7dbfc904f305fb
# good: [1b244081af462c223cfa6a1ae881a902af64c306] Do not attempt to
do cifs operations reading symlinks with SMB2
git bisect good 1b244081af462c223cfa6a1ae881a902af64c306
# good: [cde2d7a796f7e895e25b43471ed658079345636d] ext4: flush the
extent status cache during EXT4_IOC_SWAP_BOOT
git bisect good cde2d7a796f7e895e25b43471ed658079345636d
# good: [c95eb3184ea1a3a2551df57190c81da695e2144b] ARM: 7809/1: perf:
fix event validation for software group leaders
git bisect good c95eb3184ea1a3a2551df57190c81da695e2144b
# bad: [e180383f569e9d9247af45403d352b06444c34ca] MAINTAINERS: Change
ownership for SGI specific modules.
git bisect bad e180383f569e9d9247af45403d352b06444c34ca
# good: [dfa9771a7c4784bafd0673bc7abcee3813088b77] microblaze: fix clone syscall
git bisect good dfa9771a7c4784bafd0673bc7abcee3813088b77
# good: [ea077b1b96e073eac5c3c5590529e964767fc5f7] m68k: Truncate base
in do_div()
git bisect good ea077b1b96e073eac5c3c5590529e964767fc5f7
# bad: [89cb9ae2382b59585381c3ae619840e64df8df97] Merge tag
'usb-3.11-rc6' of
git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb
git bisect bad 89cb9ae2382b59585381c3ae619840e64df8df97
# good: [2b047252d087be7f2ba088b4933cd904f92e6fce] Fix TLB gather
virtual address range invalidation corner cases
git bisect good 2b047252d087be7f2ba088b4933cd904f92e6fce
# bad: [ddea368c78ff9acf45261a7c82635b98e9c1fcd6] Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect bad ddea368c78ff9acf45261a7c82635b98e9c1fcd6
# good: [9d2c9488cedb666bc8206fbdcdc1575e0fbc5929] batman-adv: fix
potential kernel paging errors for unicast transmissions
git bisect good 9d2c9488cedb666bc8206fbdcdc1575e0fbc5929
# good: [50f850fdf91a9ed21bfca982932520ee21a4ccb9] Merge branch 'bnx2x'
git bisect good 50f850fdf91a9ed21bfca982932520ee21a4ccb9
# bad: [09a8f03197d4799bc9969b35240e5606c026ded6] Merge branch 'fixes'
of git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch
git bisect bad 09a8f03197d4799bc9969b35240e5606c026ded6
# good: [728e2ccaa3c4d20cf4d54b73a47956bf4d334a9f] Revert "cxgb3:
Check and handle the dma mapping errors"
git bisect good 728e2ccaa3c4d20cf4d54b73a47956bf4d334a9f
# bad: [2fdac010bdcf10a30711b6924612dfc40daf19b8]
drivers/net/ethernet/via/via-velocity.c: update napi implementation
git bisect bad 2fdac010bdcf10a30711b6924612dfc40daf19b8

Because this bug is shadowed by another bug
(https://lkml.org/lkml/2013/8/3/40) I had to apply this patch
(http://lists.freedesktop.org/archives/dri-devel/2013-August/042668.html)
to the versions that would not compile to do the above bisect.

Output of last bisect step:
2fdac010bdcf10a30711b6924612dfc40daf19b8 is the first bad commit
commit 2fdac010bdcf10a30711b6924612dfc40daf19b8
Author: Julia Lawall <Julia.Lawall@lip6.fr>
Date:   Wed Aug 14 16:26:53 2013 +0200

    drivers/net/ethernet/via/via-velocity.c: update napi implementation

    Drivers supporting NAPI should use a NAPI-specific function for receiving
    packets.  Hence netif_rx is changed to netif_receive_skb.

    Furthermore netif_napi_del should be used in the probe and remove function
    to clean up the NAPI resource information.

    Thanks to Francois Romieu, David Shwatrz and Rami Rosen for their help on
    this patch.

    Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 d9315455cdfe498829f11b65554c1d906911f380
f1e8f50bfc9dd5bb71574b121160bd28a5da8114 M      drivers

[10.] syslog message produced for the same freeze with
"3.11.0-7-generic #13-Ubuntu"
Sep 15 02:25:24 nas dhclient: Internet Systems Consortium DHCP Client 4.2.4
Sep 15 02:25:24 nas dhclient: Copyright 2004-2012 Internet Systems Consortium.
Sep 15 02:25:24 nas dhclient: All rights reserved.
Sep 15 02:25:24 nas dhclient: For info, please visit
https://www.isc.org/software/dhcp/
Sep 15 02:25:24 nas dhclient:
Sep 15 02:25:25 nas kernel: [ 81.953639] Velocity is AUTO mode
Sep 15 02:25:25 nas dhclient: Listening on LPF/eth0/00:40:63:f5:15:76
Sep 15 02:25:25 nas dhclient: Sending on LPF/eth0/00:40:63:f5:15:76
Sep 15 02:25:25 nas dhclient: Sending on Socket/fallback
Sep 15 02:25:25 nas dhclient: DHCPDISCOVER on eth0 to 255.255.255.255
port 67 interval 3 (xid=0x4ff0e6ad)
Sep 15 02:25:26 nas kernel: [ 83.462216] eth0: Link auto-negotiation
speed 100M bps full duplex
Sep 15 02:25:28 nas dhclient: DHCPDISCOVER on eth0 to 255.255.255.255
port 67 interval 3 (xid=0x4ff0e6ad)
Sep 15 02:25:29 nas kernel: [ 86.675203] ------------[ cut here ]------------
Sep 15 02:25:29 nas kernel: [ 86.675227] WARNING: CPU: 0 PID: 1529 at
/build/buildd/linux-3.11.0/kernel/softirq.c:159
local_bh_enable+0x60/0x90()
Sep 15 02:25:29 nas kernel: [ 86.675231] Modules linked in:
snd_hda_codec_via snd_hda_intel snd_hda_codec snd_hwdep(F) snd_pcm(F)
snd_page_alloc(F) snd_seq_midi(F) snd_seq_midi_event(F) via_cputemp
snd_rawmidi(F) snd_seq(F) snd_seq_device(F) snd_timer(F) i2c_viapro
psmouse(F) serio_raw(F) snd(F) soundcore(F) shpchp mac_hid hwmon_vid
lp(F) parport(F) binfmt_misc(F) raid10(F) raid1(F) raid0(F)
multipath(F) linear(F) dm_crypt(F) via_rng raid456(F)
async_raid6_recov(F) async_memcpy(F) async_pq(F) async_xor(F)
async_tx(F) xor(F) raid6_pq(F) pata_acpi padlock_sha padlock_aes
pata_via via_velocity via_rhine mii(F) ahci(F) libahci(F) crc_ccitt(F)
Sep 15 02:25:29 nas kernel: [ 86.675315] CPU: 0 PID: 1529 Comm:
SpiderOak Tainted: GF 3.11.0-7-generic #13-Ubuntu
Sep 15 02:25:29 nas kernel: [ 86.675320] Hardware name: To Be Filled
By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M., BIOS 080014
12/18/2007
Sep 15 02:25:29 nas kernel: [ 86.675324] 00000000 00000000 ee803ce8
c16313c4 00000000 ee803d18 c105268e c1805af4
Sep 15 02:25:29 nas kernel: [ 86.675336] 00000000 000005f9 c1805dc8
0000009f c1056b50 c1056b50 c19566c0 efbafb80
Sep 15 02:25:29 nas kernel: [ 86.675347] 00000000 ee803d28 c1052752
00000009 00000000 ee803d30 c1056b50 ee803d4c
Sep 15 02:25:29 nas kernel: [ 86.675359] Call Trace:
Sep 15 02:25:29 nas kernel: [ 86.675371] [<c16313c4>] dump_stack+0x41/0x52
Sep 15 02:25:29 nas kernel: [ 86.675379] [<c105268e>]
warn_slowpath_common+0x7e/0xa0
Sep 15 02:25:29 nas kernel: [ 86.675387] [<c1056b50>] ?
local_bh_enable+0x60/0x90
Sep 15 02:25:29 nas kernel: [ 86.675394] [<c1056b50>] ?
local_bh_enable+0x60/0x90
Sep 15 02:25:29 nas kernel: [ 86.675401] [<c1052752>]
warn_slowpath_null+0x22/0x30
Sep 15 02:25:29 nas kernel: [ 86.675409] [<c1056b50>] local_bh_enable+0x60/0x90
Sep 15 02:25:29 nas kernel: [ 86.675421] [<c155f1ea>] dst_alloc+0x12a/0x140
Sep 15 02:25:29 nas kernel: [ 86.675431] [<c158189d>] rt_dst_alloc+0x4d/0x60
Sep 15 02:25:29 nas kernel: [ 86.675440] [<c1583fdc>]
ip_route_input_noref+0x2bc/0xa30
Sep 15 02:25:29 nas kernel: [ 86.675448] [<c107c504>] ? resched_task+0x24/0x70
Sep 15 02:25:29 nas kernel: [ 86.675456] [<c107cfd8>] ?
ttwu_do_wakeup+0x18/0x100
Sep 15 02:25:29 nas kernel: [ 86.675464] [<c1585b4b>] ip_rcv_finish+0xbb/0x340
Sep 15 02:25:29 nas kernel: [ 86.675471] [<c1586414>] ip_rcv+0x254/0x3c0
Sep 15 02:25:29 nas kernel: [ 86.675479] [<c1558217>]
__netif_receive_skb_core+0x557/0x730
Sep 15 02:25:29 nas kernel: [ 86.675487] [<c1558406>]
__netif_receive_skb+0x16/0x60
Sep 15 02:25:29 nas kernel: [ 86.675494] [<c155846f>]
netif_receive_skb+0x1f/0x80
Sep 15 02:25:29 nas kernel: [ 86.675516] [<f845e7ab>]
velocity_rx_srv+0x2ab/0x410 [via_velocity]
Sep 15 02:25:29 nas kernel: [ 86.675525] [<c13dfa19>] ?
__mix_pool_bytes+0x39/0x80
Sep 15 02:25:29 nas kernel: [ 86.675534] [<c1014790>] ?
alternatives_enable_smp+0x110/0x110
Sep 15 02:25:29 nas kernel: [ 86.675547] [<f84608ac>]
velocity_poll+0x3c/0x90 [via_velocity]
Sep 15 02:25:29 nas kernel: [ 86.675554] [<c1558725>] net_rx_action+0xf5/0x1f0
Sep 15 02:25:29 nas kernel: [ 86.675562] [<c10573c1>] __do_softirq+0xc1/0x1d0
Sep 15 02:25:29 nas kernel: [ 86.675574] [<c103cd90>] ?
ack_apic_level+0x60/0x100
Sep 15 02:25:29 nas kernel: [ 86.675584] [<c10d7100>] ?
handle_irq_event_percpu+0x150/0x1a0
Sep 15 02:25:29 nas kernel: [ 86.675591] [<c1057635>] irq_exit+0x95/0xa0
Sep 15 02:25:29 nas kernel: [ 86.675602] [<c163f1f5>] do_IRQ+0x45/0xb0
Sep 15 02:25:29 nas kernel: [ 86.675610] [<c163efb3>] common_interrupt+0x33/0x38
Sep 15 02:25:29 nas kernel: [ 86.675616] ---[ end trace 00a91aa3f264230a ]---
