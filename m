From: Luca Osvaldo Mastromatteo <lukycrociato@gmail.com>
Subject: [PROBLEM] 10ec:8168 r8169 won't connect
Date: Sun, 21 Feb 2016 18:30:38 +0100
Message-ID: <CAOy2C-jSe0hBwc7Bk+4cL09RThC1jWK2FvPTjL3F48ACG1SSiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35402 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbcBURak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:30:40 -0500
Received: by mail-lf0-f68.google.com with SMTP id j99so4585726lfi.2
        for <netdev@vger.kernel.org>; Sun, 21 Feb 2016 09:30:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Realtek Maintainers, I'm writing this mail for letting you know a
bug regarding the kernel module `r8169`.

Downstream bug report (Ubuntu):
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1547151

Extended description:

At school when I connect with my Ethernet cable to its network it
doesn't see my cable, like it is disconnected. This also occurs with a
different computer using the same kernel driver with the same LAN
chip. The realtek r8168 works flawlessly but it disconnects randomly.
I don't have problems in Windows (speed is 100Mbps), or with other
computers using the same cable. After some tests it looks like the
problem is only with gigabit networks using a megabit cable.


WORKAROUND: using ethtool, `ethtool -s enp1s0f1 autoneg off speed 100
duplex full`


/proc/cpuinfo:

Linux version 4.5.0-040500rc4-generic (kernel@gomeisa) (gcc version
5.2.1 20151010 (Ubuntu 5.2.1-22ubuntu2) ) #201602141731 SMP Sun Feb 14
22:33:37 UTC 2016

Also tried with previous version of the kernel.

cat /proc/modules:

rfcomm 69632 0 - Live 0x0000000000000000
drbg 32768 1 - Live 0x0000000000000000
ansi_cprng 16384 0 - Live 0x0000000000000000
ctr 16384 1 - Live 0x0000000000000000
ccm 20480 1 - Live 0x0000000000000000
nvram 16384 0 - Live 0x0000000000000000
msr 16384 0 - Live 0x0000000000000000
binfmt_misc 20480 1 - Live 0x0000000000000000
bnep 20480 2 - Live 0x0000000000000000
ath3k 20480 0 - Live 0x0000000000000000
uvcvideo 90112 0 - Live 0x0000000000000000
videobuf2_vmalloc 16384 1 uvcvideo, Live 0x0000000000000000
videobuf2_memops 16384 1 videobuf2_vmalloc, Live 0x0000000000000000
videobuf2_v4l2 24576 1 uvcvideo, Live 0x0000000000000000
videobuf2_core 40960 2 uvcvideo,videobuf2_v4l2, Live 0x0000000000000000
videodev 176128 3 uvcvideo,videobuf2_v4l2,videobuf2_core, Live
0x0000000000000000
media 32768 2 uvcvideo,videodev, Live 0x0000000000000000
btusb 45056 0 - Live 0x0000000000000000
btrtl 16384 1 btusb, Live 0x0000000000000000
btbcm 16384 1 btusb, Live 0x0000000000000000
btintel 16384 1 btusb, Live 0x0000000000000000
bluetooth 520192 30 rfcomm,bnep,ath3k,btusb,btrtl,btbcm,btintel, Live
0x0000000000000000
nls_iso8859_1 16384 1 - Live 0x0000000000000000
acer_wmi 20480 0 - Live 0x0000000000000000
sparse_keymap 16384 1 acer_wmi, Live 0x0000000000000000
intel_rapl 20480 0 - Live 0x0000000000000000
x86_pkg_temp_thermal 16384 0 - Live 0x0000000000000000
intel_powerclamp 16384 0 - Live 0x0000000000000000
coretemp 16384 0 - Live 0x0000000000000000
f2fs 319488 1 - Live 0x0000000000000000
kvm_intel 184320 0 - Live 0x0000000000000000
kvm 557056 1 kvm_intel, Live 0x0000000000000000
irqbypass 16384 1 kvm, Live 0x0000000000000000
crct10dif_pclmul 16384 0 - Live 0x0000000000000000
arc4 16384 2 - Live 0x0000000000000000
crc32_pclmul 16384 0 - Live 0x0000000000000000
ghash_clmulni_intel 16384 0 - Live 0x0000000000000000
ath9k 147456 0 - Live 0x0000000000000000
aesni_intel 167936 2 - Live 0x0000000000000000
aes_x86_64 20480 1 aesni_intel, Live 0x0000000000000000
ath9k_common 36864 1 ath9k, Live 0x0000000000000000
lrw 16384 1 aesni_intel, Live 0x0000000000000000
ath9k_hw 466944 2 ath9k,ath9k_common, Live 0x0000000000000000
gf128mul 16384 1 lrw, Live 0x0000000000000000
glue_helper 16384 1 aesni_intel, Live 0x0000000000000000
ablk_helper 16384 1 aesni_intel, Live 0x0000000000000000
cryptd 20480 3 ghash_clmulni_intel,aesni_intel,ablk_helper, Live
0x0000000000000000
ath 32768 3 ath9k,ath9k_common,ath9k_hw, Live 0x0000000000000000
mac80211 733184 1 ath9k, Live 0x0000000000000000
cfg80211 565248 4 ath9k,ath9k_common,ath,mac80211, Live 0x0000000000000000
snd_soc_rt5640 114688 0 - Live 0x0000000000000000
joydev 20480 0 - Live 0x0000000000000000
input_leds 16384 0 - Live 0x0000000000000000
snd_soc_rl6231 16384 1 snd_soc_rt5640, Live 0x0000000000000000
snd_hda_codec_hdmi 53248 1 - Live 0x0000000000000000
snd_soc_core 229376 1 snd_soc_rt5640, Live 0x0000000000000000
serio_raw 16384 0 - Live 0x0000000000000000
snd_hda_codec_realtek 81920 1 - Live 0x0000000000000000
snd_hda_codec_generic 73728 1 snd_hda_codec_realtek, Live 0x0000000000000000
rtsx_pci_ms 20480 0 - Live 0x0000000000000000
lpc_ich 24576 0 - Live 0x0000000000000000
snd_compress 20480 1 snd_soc_core, Live 0x0000000000000000
ac97_bus 16384 1 snd_soc_core, Live 0x0000000000000000
snd_pcm_dmaengine 16384 1 snd_soc_core, Live 0x0000000000000000
memstick 20480 1 rtsx_pci_ms, Live 0x0000000000000000
snd_hda_intel 36864 5 - Live 0x0000000000000000
snd_hda_codec 135168 4
snd_hda_codec_hdmi,snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_intel,
Live 0x0000000000000000
snd_seq_midi 16384 0 - Live 0x0000000000000000
snd_seq_midi_event 16384 1 snd_seq_midi, Live 0x0000000000000000
snd_hda_core 73728 5
snd_hda_codec_hdmi,snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_intel,snd_hda_codec,
Live 0x0000000000000000
snd_hwdep 16384 1 snd_hda_codec, Live 0x0000000000000000
snd_rawmidi 32768 1 snd_seq_midi, Live 0x0000000000000000
snd_pcm 102400 7
snd_soc_rt5640,snd_hda_codec_hdmi,snd_soc_core,snd_pcm_dmaengine,snd_hda_intel,snd_hda_codec,snd_hda_core,
Live 0x0000000000000000
mei_me 32768 0 - Live 0x0000000000000000
mei 98304 1 mei_me, Live 0x0000000000000000
shpchp 36864 0 - Live 0x0000000000000000
snd_seq 69632 2 snd_seq_midi,snd_seq_midi_event, Live 0x0000000000000000
snd_seq_device 16384 3 snd_seq_midi,snd_rawmidi,snd_seq, Live 0x0000000000000000
snd_timer 32768 2 snd_pcm,snd_seq, Live 0x0000000000000000
snd 81920 23 snd_hda_codec_hdmi,snd_soc_core,snd_hda_codec_realtek,snd_hda_codec_generic,snd_compress,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_rawmidi,snd_pcm,snd_seq,snd_seq_device,snd_timer,
Live 0x0000000000000000
soundcore 16384 1 snd, Live 0x0000000000000000
8250_dw 16384 0 - Live 0x0000000000000000
dw_dmac 16384 0 - Live 0x0000000000000000
dw_dmac_core 24576 1 dw_dmac, Live 0x0000000000000000
i2c_designware_platform 16384 0 - Live 0x0000000000000000
wmi 20480 1 acer_wmi, Live 0x0000000000000000
snd_soc_sst_acpi 16384 0 - Live 0x0000000000000000
mac_hid 16384 0 - Live 0x0000000000000000
i2c_designware_core 20480 1 i2c_designware_platform, Live 0x0000000000000000
snd_soc_sst_match 16384 1 snd_soc_sst_acpi, Live 0x0000000000000000
spi_pxa2xx_platform 24576 0 - Live 0x0000000000000000
soc_button_array 16384 0 - Live 0x0000000000000000
parport_pc 32768 0 - Live 0x0000000000000000
ppdev 20480 0 - Live 0x0000000000000000
lp 20480 0 - Live 0x0000000000000000
parport 49152 3 parport_pc,ppdev,lp, Live 0x0000000000000000
autofs4 40960 2 - Live 0x0000000000000000
rtsx_pci_sdmmc 24576 0 - Live 0x0000000000000000
i915 1216512 22 - Live 0x0000000000000000
i2c_algo_bit 16384 1 i915, Live 0x0000000000000000
drm_kms_helper 147456 1 i915, Live 0x0000000000000000
psmouse 126976 0 - Live 0x0000000000000000
syscopyarea 16384 1 drm_kms_helper, Live 0x0000000000000000
sysfillrect 16384 1 drm_kms_helper, Live 0x0000000000000000
sysimgblt 16384 1 drm_kms_helper, Live 0x0000000000000000
fb_sys_fops 16384 1 drm_kms_helper, Live 0x0000000000000000
drm 364544 6 i915,drm_kms_helper, Live 0x0000000000000000
ahci 36864 4 - Live 0x0000000000000000
r8169 81920 0 - Live 0x0000000000000000
libahci 32768 1 ahci, Live 0x0000000000000000
rtsx_pci 53248 2 rtsx_pci_ms,rtsx_pci_sdmmc, Live 0x0000000000000000
mii 16384 1 r8169, Live 0x0000000000000000
sdhci_acpi 16384 0 - Live 0x0000000000000000
video 40960 2 acer_wmi,i915, Live 0x0000000000000000
sdhci 45056 1 sdhci_acpi, Live 0x0000000000000000
i2c_hid 20480 0 - Live 0x0000000000000000
hid 118784 1 i2c_hid, Live 0x0000000000000000
fjes 28672 0 - Live 0x0000000000000000

lspci -vvv

01:00.1 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 12)
Subsystem: Acer Incorporated [ALI] Device 0866
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 64 bytes
Interrupt: pin A routed to IRQ 46
Region 0: I/O ports at 4000 [size=256]
Region 2: Memory at b3504000 (64-bit, non-prefetchable) [size=4K]
Region 4: Memory at b3500000 (64-bit, non-prefetchable) [size=16K]
Capabilities: [40] Power Management version 3
Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
Address: 00000000fee0f00c  Data: 4162
Capabilities: [70] Express (v2) Endpoint, MSI 01
DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
MaxPayload 128 bytes, MaxReadReq 4096 bytes
DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s unlimited, L1 <64us
ClockPM+ Surprise- LLActRep- BwNot- ASPMOptComp+
LnkCtl: ASPM L1 Enabled; RCB 64 bytes Disabled- CommClk+
ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR+, OBFF Via
message/WAKE#
DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
EqualizationPhase1-
EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
Vector table: BAR=4 offset=00000000
PBA: BAR=4 offset=00000800
Capabilities: [d0] Vital Product Data
Unknown small resource type 00, will not decode more.
Capabilities: [100 v2] Advanced Error Reporting
UESta: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
UEMsk: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
MalfTLP+ ECRC- UnsupReq- ACSViol-
CESta: RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
CEMsk: RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
Capabilities: [160 v1] Device Serial Number 01-00-00-00-68-4c-e0-00
Capabilities: [170 v1] Latency Tolerance Reporting
Max snoop latency: 3145728ns
Max no snoop latency: 3145728ns
Capabilities: [178 v1] L1 PM Substates
L1SubCap: PCI-PM_L1.2+ PCI-PM_L1.1+ ASPM_L1.2+ ASPM_L1.1+ L1_PM_Substates+
 PortCommonModeRestoreTime=150us PortTPowerOnTime=150us
Kernel driver in use: r8169

Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Samsung SSD 850  Rev: 2B6Q
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi1 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: ST500LT012-1DG14 Rev: SDM1
  Type:   Direct-Access                    ANSI  SCSI revision: 05

cat /proc/ioports

0000-0cf7 : PCI Bus 0000:00
  0000-001f : dma1
  0020-0021 : pic1
  0040-0043 : timer0
  0050-0053 : timer1
  0060-0060 : keyboard
  0062-0062 : PNP0C09:00
    0062-0062 : EC data
  0064-0064 : keyboard
  0066-0066 : PNP0C09:00
    0066-0066 : EC cmd
  0070-0077 : rtc0
  0080-008f : dma page reg
  00a0-00a1 : pic2
  00c0-00df : dma2
  00f0-00ff : fpu
  0680-069f : pnp 00:00
0cf8-0cff : PCI conf1
0d00-ffff : PCI Bus 0000:00
  164e-164f : pnp 00:00
  1800-1803 : ACPI PM1a_EVT_BLK
  1804-1805 : ACPI PM1a_CNT_BLK
  1808-180b : ACPI PM_TMR
  1810-1815 : ACPI CPU throttle
  1830-1833 : iTCO_wdt.0.auto
  1850-1850 : ACPI PM2_CNT_BLK
  1854-1857 : pnp 00:02
  1860-187f : iTCO_wdt.0.auto
  1880-189f : ACPI GPE0_BLK
  3000-3fff : PCI Bus 0000:03
    3000-307f : 0000:03:00.0
  4000-4fff : PCI Bus 0000:01
    4000-40ff : 0000:01:00.1
      4000-40ff : r8169
  5000-503f : 0000:00:02.0
  5040-505f : 0000:00:1f.3
  5060-507f : 0000:00:1f.2
    5060-507f : ahci
  5080-5087 : 0000:00:1f.2
    5080-5087 : ahci
  5088-508f : 0000:00:1f.2
    5088-508f : ahci
  5090-5093 : 0000:00:1f.2
    5090-5093 : ahci
  5094-5097 : 0000:00:1f.2
    5094-5097 : ahci
  fd60-fd63 : pnp 00:00
  ffff-ffff : pnp 00:00
    ffff-ffff : pnp 00:00
      ffff-ffff : pnp 00:00

cat /proc/iomem

00000000-00000fff : reserved
00001000-0006efff : System RAM
0006f000-0006ffff : reserved
00070000-00087fff : System RAM
00088000-000bffff : reserved
  000a0000-000bffff : PCI Bus 0000:00
000c0000-000c3fff : PCI Bus 0000:00
000c4000-000c7fff : PCI Bus 0000:00
000c8000-000cbfff : PCI Bus 0000:00
000cc000-000cffff : PCI Bus 0000:00
000d0000-000d3fff : PCI Bus 0000:00
000d4000-000d7fff : PCI Bus 0000:00
000d8000-000dbfff : PCI Bus 0000:00
000dc000-000dffff : PCI Bus 0000:00
000e0000-000e3fff : PCI Bus 0000:00
000e4000-000e7fff : PCI Bus 0000:00
000e8000-000ebfff : PCI Bus 0000:00
000ec000-000effff : PCI Bus 0000:00
000f0000-000fffff : PCI Bus 0000:00
  000f0000-000fffff : System ROM
00100000-9551ffff : System RAM
  02000000-02821eb9 : Kernel code
  02821eba-02f44b3f : Kernel data
  030c3000-03205fff : Kernel bss
95520000-95e1ffff : reserved
95e20000-9c6befff : System RAM
9c6bf000-9c8befff : reserved
9c8bf000-9cebefff : reserved
9cebf000-9cfbefff : ACPI Non-volatile Storage
9cfbf000-9cffefff : ACPI Tables
9cfff000-9cffffff : System RAM
9d000000-9f9fffff : reserved
  9da00000-9f9fffff : Graphics Stolen Memory
9fa00000-feafffff : PCI Bus 0000:00
  9fa10000-9fa1ffff : pnp 00:05
  9fa20000-9fa20fff : pnp 00:05
  a0000000-b1ffffff : PCI Bus 0000:03
    a0000000-afffffff : 0000:03:00.0
    b0000000-b1ffffff : 0000:03:00.0
  b2000000-b2ffffff : PCI Bus 0000:03
    b2000000-b2ffffff : 0000:03:00.0
  b3000000-b33fffff : 0000:00:02.0
  b3400000-b34fffff : PCI Bus 0000:02
    b3400000-b347ffff : 0000:02:00.0
      b3400000-b347ffff : ath9k
    b3480000-b348ffff : 0000:02:00.0
  b3500000-b35fffff : PCI Bus 0000:01
    b3500000-b3503fff : 0000:01:00.1
      b3500000-b3503fff : r8169
    b3504000-b3504fff : 0000:01:00.1
      b3504000-b3504fff : r8169
    b3505000-b3505fff : 0000:01:00.0
      b3505000-b3505fff : rtsx_pci
    b3510000-b351ffff : 0000:01:00.0
  b3600000-b360ffff : 0000:00:14.0
    b3600000-b360ffff : xhci-hcd
  b3610000-b3613fff : 0000:00:03.0
    b3610000-b3613fff : ICH HD audio
  b3614000-b3617fff : 0000:00:1b.0
    b3614000-b3617fff : ICH HD audio
  b3618000-b361801f : 0000:00:16.0
    b3618000-b361801f : mei_me
  b3619000-b36190ff : 0000:00:1f.3
  b361b000-b361b7ff : 0000:00:1f.2
    b361b000-b361b7ff : ahci
  b361c000-b361c3ff : 0000:00:1d.0
    b361c000-b361c3ff : ehci_hcd
  c0000000-cfffffff : 0000:00:02.0
  e0000000-efffffff : PCI MMCONFIG 0000 [bus 00-ff]
    e0000000-efffffff : reserved
      e0000000-efffffff : pnp 00:05
  fe101000-fe112fff : reserved
feb00000-feb0ffff : reserved
fec00000-fec00fff : reserved
  fec00000-fec003ff : IOAPIC 0
fed00000-fee00fff : reserved
  fed00000-fed003ff : HPET 0
    fed00000-fed003ff : PNP0103:00
  fed10000-fed17fff : pnp 00:05
  fed18000-fed18fff : pnp 00:05
  fed19000-fed19fff : pnp 00:05
  fed1c000-fed1ffff : pnp 00:05
    fed1f410-fed1f414 : iTCO_wdt.0.auto
  fed20000-fed3ffff : pnp 00:05
  fed90000-fed93fff : pnp 00:05
  fee00000-fee00fff : Local APIC
ff000000-ff000fff : pnp 00:05
ff010000-ffffffff : INT0800:00
  ffa00000-ffffffff : reserved
100000000-25f5fffff : System RAM
25f600000-25fffffff : RAM buffer
