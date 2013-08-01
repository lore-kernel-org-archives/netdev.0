From: Sebastiano Spicuglia <spicuglia.sebastiano@gmail.com>
Subject: PROBLEM: 3.11.0-rc2+ lost of connectivity
Date: Thu, 1 Aug 2013 16:34:00 +0200
Message-ID: <CAOSRKdTOcYOZ4fD5gXe_57dA028rGmR30T32FQ6MeruAq2p04g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, davem@davemloft.net,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Summary]

the network layer stops to work without any message.

[Description]

The machine suddenly stops to be connected to the network.
Running "ifdown eth0" "ifup eth0" the network starts to work
again for few minutes and then the failure happens again.
It is not even possible to ping the machine.
/var/log/messages does not report anything wrong.

I instrumented the kernel with SystemTap to see what happens when the
machine is in the failure state.

the function ip_rcv is invoked.
the function ip_rcv_finish is invoked.
the function ip_local_deliver is invoked
the function ip_local_deliver_finish is invoked
the function tcp_v4_rcv is NOT invoked

When the network works the function tcp_v4_rcv is invoked.

Let me know if you need more information.
Below all the detail about the machine.

Thank you in advance
Sebastiano

[Kernel version from /proc/version ]

Linux version 3.11.0-rc2+ (root@cache.pdbg) (gcc version 4.7.2 (Debian
4.7.2-5) ) #5 SMP Thu Aug 1 14:20:35 CEST 2013

[Processor information from /proc/cpuinfo]

processor : 0
vendor_id : GenuineIntel
cpu family : 6
model : 15
model name : Intel(R) Core(TM)2 Duo CPU     E6550  @ 2.33GHz
stepping : 11
microcode : 0xb3
cpu MHz : 1998.000
cache size : 4096 KB
physical id : 0
siblings : 2
core id : 0
cpu cores : 2
apicid : 0
initial apicid : 0
fpu : yes
fpu_exception : yes
cpuid level : 10
wp : yes
flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx
lm constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni
dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm lahf_lm
dtherm tpr_shadow vnmi flexpriority
bogomips : 4654.65
clflush size : 64
cache_alignment : 64
address sizes : 36 bits physical, 48 bits virtual
power management:

processor : 1
vendor_id : GenuineIntel
cpu family : 6
model : 15
model name : Intel(R) Core(TM)2 Duo CPU     E6550  @ 2.33GHz
stepping : 11
microcode : 0xb3
cpu MHz : 1998.000
cache size : 4096 KB
physical id : 0
siblings : 2
core id : 1
cpu cores : 2
apicid : 1
initial apicid : 1
fpu : yes
fpu_exception : yes
cpuid level : 10
wp : yes
flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx
lm constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni
dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm lahf_lm
dtherm tpr_shadow vnmi flexpriority
bogomips : 4654.65
clflush size : 64
cache_alignment : 64
address sizes : 36 bits physical, 48 bits virtual
power management:

[Module information from /proc/modules]

nfnetlink_log 17396 0 - Live 0xffffffffa0325000
nfnetlink 12989 1 nfnetlink_log, Live 0xffffffffa01b5000
nfsd 192144 2 - Live 0xffffffffa0360000
auth_rpcgss 39122 1 nfsd, Live 0xffffffffa0355000
oid_registry 12419 1 auth_rpcgss, Live 0xffffffffa0107000
nfs_acl 12511 1 nfsd, Live 0xffffffffa00ba000
nfs 105664 0 - Live 0xffffffffa033a000
lockd 55654 2 nfsd,nfs, Live 0xffffffffa0316000
fscache 38267 1 nfs, Live 0xffffffffa032f000
sunrpc 160404 6 nfsd,auth_rpcgss,nfs_acl,nfs,lockd, Live 0xffffffffa02ed000
loop 22869 0 - Live 0xffffffffa023d000
snd_hda_codec_analog 78587 1 - Live 0xffffffffa0228000
snd_hda_intel 31234 0 - Live 0xffffffffa0157000
snd_hda_codec 122851 2 snd_hda_codec_analog,snd_hda_intel, Live
0xffffffffa0209000
snd_hwdep 13189 1 snd_hda_codec, Live 0xffffffffa00a5000
snd_pcm 68479 2 snd_hda_intel,snd_hda_codec, Live 0xffffffffa01a3000
snd_page_alloc 13018 2 snd_hda_intel,snd_pcm, Live 0xffffffffa00b5000
snd_timer 22773 1 snd_pcm, Live 0xffffffffa0126000
snd 53014 6 snd_hda_codec_analog,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm,snd_timer,
Live 0xffffffffa00ce000
i915 518452 1 - Live 0xffffffffa026d000
tpm_infineon 12985 0 - Live 0xffffffffa0060000
coretemp 12898 0 - Live 0xffffffffa00c9000
hid_apple 12633 0 - Live 0xffffffffa00aa000
drm_kms_helper 31837 1 i915, Live 0xffffffffa0057000
drm 208643 2 i915,drm_kms_helper, Live 0xffffffffa016f000
kvm_intel 123456 0 - Live 0xffffffffa024d000
kvm 309880 1 kvm_intel, Live 0xffffffffa01bc000
usbhid 40964 0 - Live 0xffffffffa0163000
hid 81894 2 hid_apple,usbhid, Live 0xffffffffa0142000
hp_wmi 13362 0 - Live 0xffffffffa0121000
psmouse 74786 0 - Live 0xffffffffa012e000
soundcore 13026 1 snd, Live 0xffffffffa011c000
sparse_keymap 12760 1 hp_wmi, Live 0xffffffffa0117000
iTCO_wdt 12831 0 - Live 0xffffffffa010d000
iTCO_vendor_support 12704 1 iTCO_wdt, Live 0xffffffffa0112000
rfkill 19242 1 hp_wmi, Live 0xffffffffa0101000
parport_pc 22409 0 - Live 0xffffffffa00eb000
parport 31855 1 parport_pc, Live 0xffffffffa00f8000
lpc_ich 16764 0 - Live 0xffffffffa00df000
mfd_core 12601 1 lpc_ich, Live 0xffffffffa00f3000
evdev 17610 10 - Live 0xffffffffa00e5000
acpi_cpufreq 13277 0 - Live 0xffffffffa00a0000
tpm_tis 17320 0 - Live 0xffffffffa00bf000
mperf 12411 1 acpi_cpufreq, Live 0xffffffffa007c000
tpm 18071 2 tpm_infineon,tpm_tis, Live 0xffffffffa0092000
tpm_bios 17540 1 tpm, Live 0xffffffffa0086000
processor 28184 3 acpi_cpufreq, Live 0xffffffffa0098000
video 17844 1 i915, Live 0xffffffffa008c000
serio_raw 12940 0 - Live 0xffffffffa0081000
i2c_algo_bit 12841 1 i915, Live 0xffffffffa0077000
pcspkr 12595 0 - Live 0xffffffffa00b0000
thermal_sys 23293 2 processor,video, Live 0xffffffffa0069000
wmi 13243 1 hp_wmi, Live 0xffffffffa0072000
microcode 26065 0 - Live 0xffffffffa0024000
button 12944 1 i915, Live 0xffffffffa0039000
floppy 53102 0 - Live 0xffffffffa0049000
sr_mod 21988 0 - Live 0xffffffffa003e000
cdrom 35173 1 sr_mod, Live 0xffffffffa002f000
e1000e 139582 0 - Live 0xffffffffa0000000

[Loaded driver and hardware information from /proc/ioports]

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
0170-0177 : 0000:00:1f.2
  0170-0177 : ata_piix
01f0-01f7 : 0000:00:1f.2
  01f0-01f7 : ata_piix
0376-0376 : 0000:00:1f.2
  0376-0376 : ata_piix
0378-037a : parport0
03c0-03df : vga+
03f2-03f2 : floppy
03f4-03f5 : floppy
03f6-03f6 : 0000:00:1f.2
  03f6-03f6 : ata_piix
03f7-03f7 : floppy
03f8-03ff : serial
0400-041f : pnp 00:0d
0420-043f : pnp 00:0d
0440-045f : pnp 00:0d
0460-047f : pnp 00:0d
  0460-0461 : ACPI PM1b_CNT_BLK
0480-048f : pnp 00:0d
04d0-04d1 : pnp 00:0e
0cf8-0cff : PCI conf1
1100-111f : 0000:00:19.0
1120-113f : 0000:00:1a.0
  1120-113f : uhci_hcd
1140-115f : 0000:00:1a.1
  1140-115f : uhci_hcd
1160-117f : 0000:00:1a.2
  1160-117f : uhci_hcd
1180-119f : 0000:00:1d.0
  1180-119f : uhci_hcd
11a0-11bf : 0000:00:1d.1
  11a0-11bf : uhci_hcd
11e0-11ef : 0000:00:03.2
  11e0-11ef : ata_generic
11f0-11ff : 0000:00:1f.2
  11f0-11ff : ata_piix
1200-120f : 0000:00:1f.2
  1200-120f : ata_piix
1210-121f : 0000:00:1f.5
  1210-121f : ata_piix
1220-122f : 0000:00:1f.5
  1220-122f : ata_piix
1230-1237 : 0000:00:02.0
1238-123f : 0000:00:03.2
  1238-123f : ata_generic
1240-1247 : 0000:00:03.2
  1240-1247 : ata_generic
1248-124f : 0000:00:03.3
  1248-124f : serial
1260-1267 : 0000:00:1f.5
  1260-1267 : ata_piix
1268-126f : 0000:00:1f.5
  1268-126f : ata_piix
1270-1273 : 0000:00:03.2
  1270-1273 : ata_generic
1274-1277 : 0000:00:03.2
  1274-1277 : ata_generic
1280-1283 : 0000:00:1f.5
  1280-1283 : ata_piix
1284-1287 : 0000:00:1f.5
  1284-1287 : ata_piix
2000-2fff : PCI Bus 0000:20
3000-3fff : PCI Bus 0000:30
f800-f803 : ACPI PM1a_EVT_BLK
f804-f805 : ACPI PM1a_CNT_BLK
f808-f80b : ACPI PM_TMR
f810-f815 : ACPI CPU throttle
f820-f82f : ACPI GPE0_BLK
  f828-f82f : gpio_ich
f830-f833 : iTCO_wdt
  f830-f833 : iTCO_wdt
f860-f87f : iTCO_wdt
  f860-f87f : iTCO_wdt
fa00-fa3f : gpio_ich
  fa00-fa3f : 0000:00:1f.0
    fa00-fa3f : pnp 00:0d
fc00-fc7f : pnp 00:0d
fc80-fcff : pnp 00:0d
fe00-fe7f : pnp 00:0d
fe80-feff : pnp 00:0d

[Loaded driver and hardware information from /proc/iomem]

00000000-00000fff : reserved
00001000-0009fbff : System RAM
0009fc00-0009ffff : reserved
000c0000-000c7fff : Video ROM
000cd400-000e3fff : pnp 00:0f
000e8000-000fffff : reserved
  000f0000-000fffff : System ROM
00100000-7d2afdff : System RAM
  01000000-0169bda8 : Kernel code
  0169bda9-01ccf6ff : Kernel data
  01dc0000-01eb1fff : Kernel bss
7d2afe00-7d2b1e9f : ACPI Non-volatile Storage
7d2b1ea0-7dffffff : reserved
7e000000-7fffffff : RAM buffer
80000000-801fffff : PCI Bus 0000:20
80200000-803fffff : PCI Bus 0000:20
80400000-805fffff : PCI Bus 0000:30
80600000-807fffff : PCI Bus 0000:30
80800000-80800fff : Intel Flush Page
80804000-80807fff : i915 MCHBAR
e0000000-efffffff : 0000:00:02.0
f0000000-f00fffff : 0000:00:02.0
f0100000-f017ffff : 0000:00:02.0
f0180000-f019ffff : 0000:00:19.0
  f0180000-f019ffff : e1000e
f01a0000-f01a3fff : 0000:00:1b.0
  f01a0000-f01a3fff : ICH HD audio
f01a4000-f01a4fff : 0000:00:03.3
f01a5000-f01a5fff : 0000:00:19.0
  f01a5000-f01a5fff : e1000e
f01a6000-f01a63ff : 0000:00:1a.7
  f01a6000-f01a63ff : ehci_hcd
f01a6400-f01a67ff : 0000:00:1d.7
  f01a6400-f01a67ff : ehci_hcd
f01a6900-f01a690f : 0000:00:03.0
f4000000-f7ffffff : PCI MMCONFIG 0000 [bus 00-3f]
  f4000000-f7ffffff : reserved
    f4000000-f7ffffff : pnp 00:0f
fec00000-fed3ffff : reserved
  fec00000-fec003ff : IOAPIC 0
  fec01000-fecfffff : pnp 00:0f
  fed00000-fed003ff : HPET 0
  fed00400-fed3ffff : pnp 00:0f
    fed1f410-fed1f414 : iTCO_wdt
      fed1f410-fed1f414 : iTCO_wdt
fed45000-ffffffff : reserved
  fed90000-fed90fff : dmar0
  fed91000-fed91fff : dmar1
  fed92000-fed92fff : dmar2
  fed93000-fed93fff : dmar3
  fee00000-fee00fff : Local APIC

[PCI information with 'lspci -vvv' as root]

00:00.0 Host bridge: Intel Corporation 82Q35 Express DRAM Controller (rev 02)
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ >SERR- <PERR- INTx-
Latency: 0
Capabilities: [e0] Vendor Specific Information: Len=0b <?>
Kernel driver in use: agpgart-intel

00:02.0 VGA compatible controller: Intel Corporation 82Q35 Express
Integrated Graphics Controller (rev 02) (prog-if 00 [VGA controller])
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin A routed to IRQ 43
Region 0: Memory at f0100000 (32-bit, non-prefetchable) [size=512K]
Region 1: I/O ports at 1230 [size=8]
Region 2: Memory at e0000000 (32-bit, prefetchable) [size=256M]
Region 3: Memory at f0000000 (32-bit, non-prefetchable) [size=1M]
Expansion ROM at <unassigned> [disabled]
Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
Address: fee0300c  Data: 41e1
Capabilities: [d0] Power Management version 2
Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
Kernel driver in use: i915

00:03.0 Communication controller: Intel Corporation 82Q35 Express MEI
Controller (rev 02)
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx+
Latency: 0
Interrupt: pin A routed to IRQ 5
Region 0: Memory at f01a6900 (64-bit, non-prefetchable) [size=16]
Capabilities: [50] Power Management version 3
Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [8c] MSI: Enable- Count=1/1 Maskable- 64bit+
Address: 0000000000000000  Data: 0000

00:03.2 IDE interface: Intel Corporation 82Q35 Express PT IDER
Controller (rev 02) (prog-if 85 [Master SecO PriO])
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin C routed to IRQ 18
Region 0: I/O ports at 1238 [size=8]
Region 1: I/O ports at 1270 [size=4]
Region 2: I/O ports at 1240 [size=8]
Region 3: I/O ports at 1274 [size=4]
Region 4: I/O ports at 11e0 [size=16]
Capabilities: [c8] Power Management version 3
Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
Address: 0000000000000000  Data: 0000
Kernel driver in use: ata_generic

00:03.3 Serial controller: Intel Corporation 82Q35 Express Serial KT
Controller (rev 02) (prog-if 02 [16550])
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin B routed to IRQ 17
Region 0: I/O ports at 1248 [size=8]
Region 1: Memory at f01a4000 (32-bit, non-prefetchable) [size=4K]
Capabilities: [c8] Power Management version 3
Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
Address: 0000000000000000  Data: 0000
Kernel driver in use: serial

00:19.0 Ethernet controller: Intel Corporation 82566DM-2 Gigabit
Network Connection (rev 02)
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin B routed to IRQ 42
Region 0: Memory at f0180000 (32-bit, non-prefetchable) [size=128K]
Region 1: Memory at f01a5000 (32-bit, non-prefetchable) [size=4K]
Region 2: I/O ports at 1100 [size=32]
Capabilities: [c8] Power Management version 2
Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
Address: 00000000fee0300c  Data: 41d2
Capabilities: [e0] PCI Advanced Features
AFCap: TP+ FLR+
AFCtrl: FLR-
AFStatus: TP-
Kernel driver in use: e1000e

00:1a.0 USB controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #4 (rev 02) (prog-if 00 [UHCI])
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin A routed to IRQ 20
Region 4: I/O ports at 1120 [size=32]
Capabilities: [50] PCI Advanced Features
AFCap: TP+ FLR+
AFCtrl: FLR-
AFStatus: TP-
Kernel driver in use: uhci_hcd

00:1a.1 USB controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #5 (rev 02) (prog-if 00 [UHCI])
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin B routed to IRQ 21
Region 4: I/O ports at 1140 [size=32]
Capabilities: [50] PCI Advanced Features
AFCap: TP+ FLR+
AFCtrl: FLR-
AFStatus: TP-
Kernel driver in use: uhci_hcd

00:1a.2 USB controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #6 (rev 02) (prog-if 00 [UHCI])
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin C routed to IRQ 22
Region 4: I/O ports at 1160 [size=32]
Capabilities: [50] PCI Advanced Features
AFCap: TP+ FLR+
AFCtrl: FLR-
AFStatus: TP-
Kernel driver in use: uhci_hcd

00:1a.7 USB controller: Intel Corporation 82801I (ICH9 Family) USB2
EHCI Controller #2 (rev 02) (prog-if 20 [EHCI])
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin C routed to IRQ 22
Region 0: Memory at f01a6000 (32-bit, non-prefetchable) [size=1K]
Capabilities: [50] Power Management version 2
Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [58] Debug port: BAR=1 offset=00a0
Capabilities: [98] PCI Advanced Features
AFCap: TP+ FLR+
AFCtrl: FLR-
AFStatus: TP-
Kernel driver in use: ehci-pci

00:1b.0 Audio device: Intel Corporation 82801I (ICH9 Family) HD Audio
Controller (rev 02)
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 64 bytes
Interrupt: pin A routed to IRQ 44
Region 0: Memory at f01a0000 (64-bit, non-prefetchable) [size=16K]
Capabilities: [50] Power Management version 2
Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
Address: 00000000fee0300c  Data: 4122
Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
ExtTag- RBE- FLReset+
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
MaxPayload 128 bytes, MaxReadReq 128 bytes
DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
LnkCap: Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0
<64ns, L1 <1us
ClockPM- Surprise- LLActRep- BwNot-
LnkCtl: ASPM Disabled; Disabled- Retrain- CommClk-
ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
LnkSta: Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive-
BWMgmt- ABWMgmt-
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
Desc: PortNumber=0f ComponentID=02 EltType=Config
Link0: Desc: TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
Addr: 00000000fed1c000
Kernel driver in use: snd_hda_intel

00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express
Port 1 (rev 02) (prog-if 00 [Normal decode])
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 64 bytes
Bus: primary=00, secondary=20, subordinate=20, sec-latency=0
I/O behind bridge: 00002000-00002fff
Memory behind bridge: 80000000-801fffff
Prefetchable memory behind bridge: 0000000080200000-00000000803fffff
Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
ExtTag- RBE+ FLReset-
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
MaxPayload 128 bytes, MaxReadReq 128 bytes
DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
ClockPM- Surprise- LLActRep+ BwNot-
LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
Slot #2, PowerLimit 10.000W; Interlock- NoCompl-
SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
Changed: MRL- PresDet- LinkState-
RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
RootCap: CRSVisible-
RootSta: PME ReqID 0000, PMEStatus- PMEPending-
Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
Address: fee0300c  Data: 4171
Capabilities: [90] Subsystem: Hewlett-Packard Company Device 2818
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
Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
Status: NegoPending- InProgress-
Capabilities: [180 v1] Root Complex Link
Desc: PortNumber=01 ComponentID=02 EltType=Config
Link0: Desc: TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
Addr: 00000000fed1c000
Kernel driver in use: pcieport

00:1c.1 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express
Port 2 (rev 02) (prog-if 00 [Normal decode])
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 64 bytes
Bus: primary=00, secondary=30, subordinate=30, sec-latency=0
I/O behind bridge: 00003000-00003fff
Memory behind bridge: 80400000-805fffff
Prefetchable memory behind bridge: 0000000080600000-00000000807fffff
Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
ExtTag- RBE+ FLReset-
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
MaxPayload 128 bytes, MaxReadReq 128 bytes
DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
LnkCap: Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
ClockPM- Surprise- LLActRep+ BwNot-
LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
Slot #0, PowerLimit 0.000W; Interlock- NoCompl-
SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
Changed: MRL- PresDet- LinkState-
RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
RootCap: CRSVisible-
RootSta: PME ReqID 0000, PMEStatus- PMEPending-
Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
Address: fee0300c  Data: 4181
Capabilities: [90] Subsystem: Hewlett-Packard Company Device 2818
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
Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
Status: NegoPending- InProgress-
Capabilities: [180 v1] Root Complex Link
Desc: PortNumber=02 ComponentID=02 EltType=Config
Link0: Desc: TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
Addr: 00000000fed1c000
Kernel driver in use: pcieport

00:1d.0 USB controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #1 (rev 02) (prog-if 00 [UHCI])
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin A routed to IRQ 20
Region 4: I/O ports at 1180 [size=32]
Capabilities: [50] PCI Advanced Features
AFCap: TP+ FLR+
AFCtrl: FLR-
AFStatus: TP-
Kernel driver in use: uhci_hcd

00:1d.1 USB controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #2 (rev 02) (prog-if 00 [UHCI])
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin B routed to IRQ 21
Region 4: I/O ports at 11a0 [size=32]
Capabilities: [50] PCI Advanced Features
AFCap: TP+ FLR+
AFCtrl: FLR-
AFStatus: TP-
Kernel driver in use: uhci_hcd

00:1d.7 USB controller: Intel Corporation 82801I (ICH9 Family) USB2
EHCI Controller #1 (rev 02) (prog-if 20 [EHCI])
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin A routed to IRQ 20
Region 0: Memory at f01a6400 (32-bit, non-prefetchable) [size=1K]
Capabilities: [50] Power Management version 2
Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [58] Debug port: BAR=1 offset=00a0
Capabilities: [98] PCI Advanced Features
AFCap: TP+ FLR+
AFCtrl: FLR-
AFStatus: TP-
Kernel driver in use: ehci-pci

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92)
(prog-if 01 [Subtractive decode])
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Bus: primary=00, secondary=07, subordinate=07, sec-latency=32
I/O behind bridge: 0000f000-00000fff
Memory behind bridge: fff00000-000fffff
Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
Capabilities: [50] Subsystem: Hewlett-Packard Company Device 2818

00:1f.0 ISA bridge: Intel Corporation 82801IO (ICH9DO) LPC Interface
Controller (rev 02)
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Capabilities: [e0] Vendor Specific Information: Len=0c <?>
Kernel driver in use: lpc_ich

00:1f.2 IDE interface: Intel Corporation 82801IR/IO/IH (ICH9R/DO/DH) 4
port SATA Controller [IDE mode] (rev 02) (prog-if 8a [Master SecP
PriP])
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin B routed to IRQ 18
Region 0: I/O ports at 01f0 [size=8]
Region 1: I/O ports at 03f4 [size=1]
Region 2: I/O ports at 0170 [size=8]
Region 3: I/O ports at 0374 [size=1]
Region 4: I/O ports at 11f0 [size=16]
Region 5: I/O ports at 1200 [size=16]
Capabilities: [70] Power Management version 3
Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [b0] PCI Advanced Features
AFCap: TP+ FLR+
AFCtrl: FLR-
AFStatus: TP-
Kernel driver in use: ata_piix

00:1f.5 IDE interface: Intel Corporation 82801I (ICH9 Family) 2 port
SATA Controller [IDE mode] (rev 02) (prog-if 85 [Master SecO PriO])
Subsystem: Hewlett-Packard Company Device 2818
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin B routed to IRQ 18
Region 0: I/O ports at 1260 [size=8]
Region 1: I/O ports at 1280 [size=4]
Region 2: I/O ports at 1268 [size=8]
Region 3: I/O ports at 1284 [size=4]
Region 4: I/O ports at 1210 [size=16]
Region 5: I/O ports at 1220 [size=16]
Capabilities: [70] Power Management version 3
Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [b0] PCI Advanced Features
AFCap: TP+ FLR+
AFCtrl: FLR-
AFStatus: TP-
Kernel driver in use: ata_piix
