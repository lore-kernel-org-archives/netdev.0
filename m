From: Nakashima Akihiro <Nakashima.Akihiro@exc.epson.co.jp>
Subject: PROBLEM: [3.4] neigh_destroy() crashes on unplug netdev.
Date: Thu, 15 Jan 2015 05:57:03 +0000
Message-ID: <E694983F62A0954788A62E997021A9C31093E1@JPEX011.apo.epson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ueda Motoki <Ueda.Motoki@exc.epson.co.jp>,
	Otsu Takahiro <Otsu.Takahiro@exc.epson.co.jp>,
	Tomono Mitsunori <Tomono.Mitsunori@exc.epson.co.jp>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: ja-JP
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear David and networking developers:

I got kernel panic on 3.4.105 kernel.
Please see a report below.
 
[1.] One line summary of the problem: [3.4] neigh_destroy() crashes on unplug netdev.
[2.] Full description of the problem/report:
I got kernel panic: neigh_destroy() crashes on unplug my wlan dongle. Please see Oops.. message for detail.
I found this problem is occured on kernel 3.4 branch, but kernel 3.6 or later do not have it.
It does not occur on every netdev device, but I think it is not a driver specific problem.
And I found 20 patches that you released on 05-Jul-2012 look effective to solve it.
Patches are below:
 01. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=a263b3093641fb1ec377582c90986a7fd0625184
 02. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=3c521f2ba9646c5543963cbc2b9c9d3f02a82594
 03. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=60d354ebebd9d0f760cb6c3b9f53a7ade0f8cd0e
 04. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=5110effee8fde2edfacac9cd12a9960ab2dc39ea
 05. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f894cbf847c9bea1955095bf37aca6c050553167
 06. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=dbedbe6d56e8944f220e34deb9ebdf4bec2a2afd
 07. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=178709bbfe9d4fe432c272ed65a34b8582703c23
 08. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=24db1ba866eebf5b516df80ea2212d2479bfb502
 09. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=0b399d46b317a6d0a73ad523e014ecfa4d449769
 10. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=c473737765c0f72ceb5b245ada7ead798d88b4f6
 11. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f9d751667fd60788fe3641738938e0968e99cece
 12. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=13a43d94ab026c423dc8902170ef27c2bd36aa87
 13. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=fccd7d5c77ff61d5283e7ce8242791d5f00dcc17
 14. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=1d248b1cf4e09dbec8cef5f7fbeda5874248bd09
 15. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=534cb283efef9fdbd9f70f4615054d26aa444dd6
 16. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=97cac0821af4474ec4ba3a9e7a36b98ed9b6db88
 17. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f187bc6efb7250afee0e2009b6106370319b0c8b
 18. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=d1e31fb02b31ba88d5650d97c35eb58f52bfe0e1
 19. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=36bdbcae2fa2a6dfa99344d4190fcea0aa7b7c25
 20. http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=a2de86f63cfc92f7aaf11e7b9d9f2150946a1622
I applied these patches to 3.4.105 kernel, and confirmed the problem is solved on my box.
Could you confirm and backport them to 3.4 branch?
[3.] Keywords (i.e., modules, networking, kernel): networking
[4.] Kernel version (from /proc/version):
Linux version 3.4.105 (root@JP1201393) (gcc version 4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #2 SMP Tue Jan 13 13:39:40 JST 2015
[5.] Output of Oops.. message (if applicable) with symbolic information 
 resolved (see Documentation/oops-tracing.txt)
BUG: unable to handle kernel paging request at f87be0ac
IP: [<c1475c5f>] neigh_destroy+0x8f/0x110
*pdpt = 00000000018c0001 *pde = 0000000032f7c067 *pte = 0000000000000000
Oops: 0000 [#1] SMP
Modules linked in: mt7603u_sta(0) nls_iso8859_1 bnep rfcomm bluetooth snd_hda_codec_realtek snd_hda_intel snd_hda_codec i915 snd_hwdep snd_pcm drm_kms_helper binfmt_misc snd_seq_midi drm snd_rawmidi snd_seq_midi_event snd_seq aesni_intel snd_timer snd_seq_device snd cryptd aes_i586 i2c_algo_bit microcode soundcore psmouse video snd_page_alloc serio_raw mac_hid ppdev parport_pc lp parport usbhid hid usb_storage ahci firewire_ohci libahci firewire_core crc_itu_te1000e
Pid: 19, comm: ksoftirqd/3 Tainted: G O 3.4.105 #1 EPSON DIRECT CORP. MR690D0F61/MR6900
EIP: 0060:[<c1475c5f>] EFLAGS: 00010206 CPU: 3
EIP is at neigh_destroy+0x8f/0x110
EAX: f87be000 EBX: f1fd461c ECX: 80150006 EDX: 00000100
ESI: f1fd4600 EDI: ec5ae000 EBP: f2d71ef4 ESP: f2d71edc
 DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
CR0: 8005003b CR2: f87be0ac CR3: 3184b000 CR4: 000407f0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
Process ksoftirqd/3 (pid: 19, ti=f2d70000 task=f2d68000 task.ti=f2d70000)
Stack:
 c1472b23 c1472b23 f1fd4614 ee27b0c0 00000000 00000005 f2d71f0c c1472b95
 c1552da3 0000000a ee26a9c0 00000005 f2d71f14 c149292c f2d71f44 c10a80f6
 f33bc0e0 0000000a f1b1cc8c f33bc0f8 c17b9ec0 f2d68000 00000000 00000003
Call Trace:
 [<c1472b23>] ? dst_destroy+0x43/0xe0
 [<c1472b23>] ? dst_destroy+0x43/0xe0
 [<c1472b95>] dst_destroy+0xb5/0xe0
 [<c1552da3>] ? _raw_spin_unlock_bh+0x13/0x20
 [<c149292c>] dst_rcu_free+0x1c/0x30
 [<c10a80f6>] __rcu_process_callbacks+0x186/0x310
 [<c10a82bc>] rcu_process_callbacks+0x3c/0xc0
 [<c1038041>] __do_softirq+0x81/0x190
 [<c15533cd>] ? apic_timer_interrupt+0x31/0x38
 [<c10381f8>] run_ksoftirqd+0xa8/0x130
 [<c1038150>] ? __do_softirq+0x190/0x190
 [<c104ff82>] kthread+0x72/0x80
 [<c104ff10>] ? flush_kthread_work+0xc0/0xc0
 [<c1559ebe>] kernel_thread_helper+0x6/0x10
Code: 40 04 00 00 00 00 89 51 04 89 0a e8 bc a2 fe ff 8b 03 39 c3 75 d6 8b 45 f0 e8 fe d0 0d 00 c7 46 2c 00 00 00 00 8b 87 34 01 00 00 <8b> 90 ac 00 00 00 85 d2 74 04 89 f0 ff d2 8b 87 98 02 00 00 64
EIP: [<c1475c5f>] neigh_destroy+0x8f/0x110 SS:ESP 0068:f2d71edc
CR2: 00000000f87be0ac
Kernel panic - not syncing: Fatal exception in interrupt
panic occurred, switching back to text console

call trace indicate these code line:
<c1475c5f>: net/core/neighbour.c:729
<c1472b23>: net/core/dst.c:250
<c1472b95>: include/net/neighbour.h:294
<c1552da3>: kernel/spinlock.c:194
<c149292c>: include/net/dst.h:385
[6.] A small shell script or example program which triggers the
 problem (if possible)
Method to reproduce the problem:
 1. run shell script below:
#/bin/sh
while [ true ]
do
 ifconfig wlan0 192.168.1.2 up
done
 2. unplug and plug a netdev dongle. (repeat)
[7.] Environment
[7.1.] Software (add the output of the ver_linux script here)
--- ver_linux ---
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux JP1201393 3.4.105 #2 SMP Tue Jan 13 13:39:40 JST 2015 i686 i686 i386 GNU/Linux
 
Gnu C 4.6
Gnu make 3.81
binutils 2.22
util-linux 2.20.1
mount support
module-init-tools 3.16
e2fsprogs 1.42
pcmciautils 018
PPP 2.4.5
Linux C Library 2.15
Dynamic linker (ldd) 2.15
Procps 3.2.8
Net-tools 1.60
Kbd 1.15.2
Sh-utils 8.13
wireless-tools 30
Modules Loaded mt7603u_sta nls_iso8859_1 rfcomm bnep bluetooth snd_hda_codec_realtek snd_hda_intel snd_hda_codec i915 snd_hwdep snd_pcm snd_seq_midi snd_rawmidi snd_seq_midi_event drm_kms_helper aesni_intel snd_seq drm cryptd psmouse snd_timer snd_seq_device aes_i586 microcode binfmt_misc serio_raw snd soundcore snd_page_alloc i2c_algo_bit mac_hid video ppdev parport_pc lp parport usbhid hid usb_storage ahci libahci e1000e firewire_ohci firewire_core crc_itu_t
[7.2.] Processor information (from /proc/cpuinfo):
I think this is no relationship about the problem.
If it is needed, I will gather it.
[7.3.] Module information (from /proc/modules):
--- /proc/modules ---
mt7603u_sta 1114536 1 - Live 0x00000000 (O)
nls_iso8859_1 12618 1 - Live 0x00000000
rfcomm 57545 0 - Live 0x00000000
bnep 18868 2 - Live 0x00000000
bluetooth 263846 10 rfcomm,bnep, Live 0x00000000
snd_hda_codec_realtek 63163 1 - Live 0x00000000
snd_hda_intel 31907 3 - Live 0x00000000
snd_hda_codec 102579 2 snd_hda_codec_realtek,snd_hda_intel, Live 0x00000000
i915 427399 2 - Live 0x00000000
snd_hwdep 13277 1 snd_hda_codec, Live 0x00000000
snd_pcm 84645 2 snd_hda_intel,snd_hda_codec, Live 0x00000000
snd_seq_midi 13133 0 - Live 0x00000000
snd_rawmidi 25115 1 snd_seq_midi, Live 0x00000000
snd_seq_midi_event 14476 1 snd_seq_midi, Live 0x00000000
drm_kms_helper 45322 1 i915, Live 0x00000000
aesni_intel 18135 0 - Live 0x00000000
snd_seq 55404 2 snd_seq_midi,snd_seq_midi_event, Live 0x00000000
drm 215637 3 i915,drm_kms_helper, Live 0x00000000
cryptd 15580 1 aesni_intel, Live 0x00000000
psmouse 81253 0 - Live 0x00000000
snd_timer 24503 2 snd_pcm,snd_seq, Live 0x00000000
snd_seq_device 14138 3 snd_seq_midi,snd_rawmidi,snd_seq, Live 0x00000000
aes_i586 16996 1 aesni_intel, Live 0x00000000
microcode 18819 0 - Live 0x00000000
binfmt_misc 17208 1 - Live 0x00000000
serio_raw 13156 0 - Live 0x00000000
snd 60917 16 snd_hda_codec_realtek,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm,snd_seq_midi,snd_rawmidi,snd_seq,snd_timer,snd_seq_device, Live 0x00000000
soundcore 12601 1 snd, Live 0x00000000
snd_page_alloc 14037 2 snd_hda_intel,snd_pcm, Live 0x00000000
i2c_algo_bit 13198 1 i915, Live 0x00000000
mac_hid 13038 0 - Live 0x00000000
video 18688 1 i915, Live 0x00000000
ppdev 17364 0 - Live 0x00000000
parport_pc 27505 1 - Live 0x00000000
lp 13300 0 - Live 0x00000000
parport 40763 3 ppdev,parport_pc,lp, Live 0x00000000
usbhid 47307 0 - Live 0x00000000
hid 81906 1 usbhid, Live 0x00000000
usb_storage 48081 1 - Live 0x00000000
ahci 25497 2 - Live 0x00000000
libahci 25871 1 ahci, Live 0x00000000
e1000e 175750 0 - Live 0x00000000
firewire_ohci 35480 0 - Live 0x00000000
firewire_core 56954 1 firewire_ohci, Live 0x00000000
crc_itu_t 12628 1 firewire_core, Live 0x00000000
[7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
--- /proc/ioports ---
0000-03af : PCI Bus 0000:00
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
 0200-0201 : pnp 00:02
 0378-037a : parport0
03b0-03df : PCI Bus 0000:00
03e0-0cf7 : PCI Bus 0000:00
 03f8-03ff : serial
 0400-0453 : pnp 00:0a
 0400-0403 : ACPI PM1a_EVT_BLK
 0404-0405 : ACPI PM1a_CNT_BLK
 0408-040b : ACPI PM_TMR
 0410-0415 : ACPI CPU throttle
 0420-042f : ACPI GPE0_BLK
 0450-0450 : ACPI PM2_CNT_BLK
 0454-0457 : pnp 00:0b
 0458-047f : pnp 00:0a
 04d0-04d1 : pnp 00:08
 0500-057f : pnp 00:0a
0cf8-0cff : PCI conf1
0d00-ffff : PCI Bus 0000:00
 1180-119f : pnp 00:0a
 d000-dfff : PCI Bus 0000:04
 d000-d01f : 0000:04:00.0
 e000-efff : PCI Bus 0000:03
 e000-e0ff : 0000:03:00.0
 f000-f03f : 0000:00:02.0
 f040-f05f : 0000:00:1f.3
 f060-f07f : 0000:00:1f.2
 f060-f07f : ahci
 f080-f09f : 0000:00:19.0
 f0a0-f0a3 : 0000:00:1f.2
 f0a0-f0a3 : ahci
 f0b0-f0b7 : 0000:00:1f.2
 f0b0-f0b7 : ahci
 f0c0-f0c3 : 0000:00:1f.2
 f0c0-f0c3 : ahci
 f0d0-f0d7 : 0000:00:1f.2
 f0d0-f0d7 : ahci
--- /proc/iomem ---
00000000-0000ffff : reserved
00010000-0009d7ff : System RAM
0009d800-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
 000a0000-000bffff : Video RAM area
000c0000-000dffff : PCI Bus 0000:00
 000c0000-000cd7ff : Video ROM
000e0000-000fffff : reserved
 000f0000-000fffff : System ROM
00100000-1fffffff : System RAM
 01000000-0155addd : Kernel code
 0155adde-01813f3f : Kernel data
 018c0000-0194bfff : Kernel bss
20000000-201fffff : reserved
20200000-3fffffff : System RAM
40000000-401fffff : reserved
40200000-bad8bfff : System RAM
bad8c000-badd8fff : ACPI Non-volatile Storage
badd9000-bade0fff : ACPI Tables
bade1000-badf5fff : reserved
badf6000-badf7fff : System RAM
badf8000-bae04fff : ACPI Non-volatile Storage
bae05000-bae2bfff : reserved
bae2c000-bae6efff : ACPI Non-volatile Storage
bae6f000-baffffff : System RAM
bb000000-bb7fffff : RAM buffer
bb800000-bf9fffff : reserved
bfa00000-ffffffff : PCI Bus 0000:00
 d0000000-dfffffff : 0000:00:02.0
 e0000000-efffffff : PCI MMCONFIG 0000 [bus 00-ff]
 e0000000-efffffff : pnp 00:01
 fe000000-fe3fffff : 0000:00:02.0
 fe400000-fe4fffff : PCI Bus 0000:04
 fe400000-fe47ffff : 0000:04:00.0
 fe400000-fe47ffff : e1000e
 fe480000-fe4bffff : 0000:04:00.0
 fe4c0000-fe4dffff : 0000:04:00.0
 fe4c0000-fe4dffff : e1000e
 fe4e0000-fe4e3fff : 0000:04:00.0
 fe4e0000-fe4e3fff : e1000e
 fe500000-fe5fffff : PCI Bus 0000:03
 fe500000-fe5007ff : 0000:03:00.0
 fe500000-fe5007ff : firewire_ohci
 fe600000-fe61ffff : 0000:00:19.0
 fe600000-fe61ffff : e1000e
 fe620000-fe623fff : 0000:00:1b.0
 fe620000-fe623fff : ICH HD audio
 fe624000-fe6240ff : 0000:00:1f.3
 fe625000-fe6257ff : 0000:00:1f.2
 fe625000-fe6257ff : ahci
 fe626000-fe6263ff : 0000:00:1d.0
 fe626000-fe6263ff : ehci_hcd
 fe627000-fe6273ff : 0000:00:1a.0
 fe627000-fe6273ff : ehci_hcd
 fe628000-fe628fff : 0000:00:19.0
 fe628000-fe628fff : e1000e
 fe629000-fe62900f : 0000:00:16.0
 fec00000-fec003ff : IOAPIC 0
 fed00000-fed003ff : HPET 0
 fed08000-fed08fff : pnp 00:0a
 fed10000-fed19fff : pnp 00:01
 fed1c000-fed1ffff : reserved
 fed1c000-fed1ffff : pnp 00:0a
 fed20000-fed3ffff : pnp 00:01
 fed90000-fed93fff : pnp 00:01
 fee00000-fee0ffff : pnp 00:01
 fee00000-fee00fff : Local APIC
 ff000000-ffffffff : reserved
 ff000000-ffffffff : pnp 00:0a
100000000-23f7fffff : System RAM
23f800000-23fffffff : RAM buffer
[7.5.] PCI information ('lspci -vvv' as root)
I think this is no relationship about the problem.
If it is needed, I will gather it.
[7.6.] SCSI information (from /proc/scsi/scsi):
I don't think no relationship about this issue.
If it is needed, I will gather it.
[7.7.] Other information that might be relevant to the problem
 (please look in /proc and include all information that you
 think to be relevant):
[X.] Other notes, patches, fixes, workarounds:
patches I described on [2.] look effective.

Best regards,
Akihiro Nakashima

----------------------------------
NAKASHIMA Akihiro
Nakashima.Akihiro@exc.epson.co.jp
----------------------------------
