From: Oliver Maurhart <oliver.maurhart@ait.ac.at>
Subject: kernel 2.6.33 kernel panic "kernel BUG at net/core/skbuff.c:147!"
Date: Thu, 18 Mar 2010 14:45:56 +0100
Message-ID: <201003181445.56645.oliver.maurhart@ait.ac.at>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary-00=_U6ioL7dcdvoJQ9I"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcss01.ait.ac.at ([62.218.164.126]:16582 "EHLO mail.ait.ac.at"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753554Ab0CRNvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 09:51:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_U6ioL7dcdvoJQ9I
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable

#!/bin/hi *

I'm experiencing a kernel panic with a recent 2.6.33 kernel ... and - frank=
ly=20
=2D don't know what to do.

I've read REPORTING-BUGS and hope I've got all right (and the right target =
for=20
this report).

[1.] Kernel panic when running heavy TUN/TAP I/O between two processes on t=
he=20
same machine.

[2.] We have an application scenario where we start 4 processes which are=20
interconnected via TCP/IP plus 2 of them via additional TUN/TUP devices. On=
 my=20
machine after doing heavy IO the kernel panics (see output [6.]).=20
Interestingly, a VM on the very same machine (VirtualBox with Ubuntu 9.10)=
=20
does not with the very same scenery. I don't know where to start looking. T=
he=20
bug is very deterministic reproduceable. The kernel stops at the very same=
=20
position in the processing of the application.

[3.] Keywords: skbuff, tun/tap, networking

[4.1.] # cat /proc/version=20
Linux version 2.6.33-gentoo (root@lanfear) (gcc version 4.4.3 (Gentoo 4.4.3=
=20
p1.0) ) #3 SMP PREEMPT Tue Mar 16 14:07:33 CET 2010

[4.2.] Kernel config attached from /proc/config.gz

[5.] Within the VM:
$ uname -a
Linux ubuntu-32-clean 2.6.31-20-generic #57-Ubuntu SMP Mon Feb 8 09:05:19 U=
TC=20
2010 i686 GNU/Linux

[6.] Output of kernel panic (got that via netconsole on a remote host):

[ 3485.023866] skb_under_panic: text:ffffffff814dc389 len:46 put:14=20
head:ffff880106a73c00 data:ffff880106a73bf2 tail:0x20 end:0x40 dev:q3p1
[ 3485.023932] ------------[ cut here ]------------
[ 3485.023940] kernel BUG at net/core/skbuff.c:147!
[ 3485.023948] invalid opcode: 0000 [#1] PREEMPT SMP=20
[ 3485.023963] last sysfs file:=20
/sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0A:00/power_supply/BAT1/energy_fu=
ll
[ 3485.023972] CPU 0=20
[ 3485.023984] Pid: 26456, comm: link mgr: alice Tainted: P           2.6.3=
3-
gentoo #3 Portable PC/TECRA S10
[ 3485.023993] RIP: 0010:[<ffffffff815c57e4>]  [<ffffffff815c57e4>]=20
skb_under_panic+0x54/0x60
[ 3485.024013] RSP: 0018:ffff880028203df8  EFLAGS: 00010296
[ 3485.024015] RAX: 0000000000000092 RBX: ffff8801369cb380 RCX:=20
0000000000000000
[ 3485.024015] RDX: ffff880028200000 RSI: 0000000000000092 RDI:=20
0000000000000001
[ 3485.024015] RBP: ffff8801369cb380 R08: 0000000002000000 R09:=20
0000000000000000
[ 3485.024015] R10: 0000000000000000 R11: 0000000000000000 R12:=20
ffff8800bd29a000
[ 3485.024015] R13: ffff8800bd29a000 R14: 0000000000000000 R15:=20
000000000000a288
[ 3485.024015] FS:  00007f5f6565a710(0000) GS:ffff880028200000(0000)=20
knlGS:0000000000000000
[ 3485.024015] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3485.024015] CR2: 00007f5f65658a08 CR3: 00000000b514b000 CR4:=20
00000000000406f0
[ 3485.024015] DR0: 0000000000000000 DR1: 0000000000000000 DR2:=20
0000000000000000
[ 3485.024015] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:=20
0000000000000400
[ 3485.024015] Process link mgr: alice (pid: 26456, threadinfo=20
ffff8800b4620000, task ffff8800bd173720)
[ 3485.024015] Stack:
[ 3485.024015]  0000000000000020 0000000000000040 ffff8800bd29a000=20
ffff8801369cb380
[ 3485.024015] <0> ffff8801369cb380 ffffffff815c7c6f ffff8801369cb380=20
ffffffff814dc389
[ 3485.024015] <0> ffff880180000000 ffffffff81d06380 ffffffff81d063a0=20
ffff8801369cb380
[ 3485.024015] Call Trace:
[ 3485.024015]  <IRQ>=20
[ 3485.024015]  [<ffffffff815c7c6f>] ? skb_push+0x2f/0x40
[ 3485.024015]  [<ffffffff814dc389>] ? aoenet_rcv+0x99/0x190
[ 3485.024015]  [<ffffffff815d0caa>] ? netif_receive_skb+0x31a/0x450
[ 3485.024015]  [<ffffffff81710971>] ? _raw_spin_unlock_irq+0x11/0x40
[ 3485.024015]  [<ffffffff8104d4e0>] ? run_timer_softirq+0x210/0x270
[ 3485.024015]  [<ffffffff815d0e55>] ? process_backlog+0x75/0xc0
[ 3485.024015]  [<ffffffff815d16b6>] ? net_rx_action+0x116/0x1e0
[ 3485.024015]  [<ffffffff81048244>] ? __do_softirq+0xb4/0x140
[ 3485.024015]  [<ffffffff8100338c>] ? call_softirq+0x1c/0x30
[ 3485.024015]  <EOI>=20
[ 3485.024015]  [<ffffffff8100553d>] ? do_softirq+0x4d/0x80
[ 3485.024015]  [<ffffffff815d1a6d>] ? netif_rx_ni+0x4d/0x70
[ 3485.024015]  [<ffffffff8148fb06>] ? tun_chr_aio_write+0x356/0x4e0
[ 3485.024015]  [<ffffffff810bea6f>] ? do_sync_write+0xbf/0x100
[ 3485.024015]  [<ffffffff810a1d0b>] ? handle_mm_fault+0x4bb/0x850
[ 3485.024015]  [<ffffffff81710cde>] ? _raw_spin_lock_irqsave+0x1e/0x50
[ 3485.024015]  [<ffffffff810bf538>] ? vfs_write+0xb8/0x180
[ 3485.024015]  [<ffffffff810bf6ee>] ? sys_write+0x4e/0x90
[ 3485.024015]  [<ffffffff8100256b>] ? system_call_fastpath+0x16/0x1b
[ 3485.024015] Code: 8b 57 68 48 89 44 24 10 8b 87 b8 00 00 00 48 89 44 24 =
08=20
31 c0 8b bf b4 00 00 00 48 89 3c 24 48 c7 c7 b0 1c a9 81 e8 b9 82 14 00 <0f=
>=20
0b eb fe 0f 1f 84 00 00 00 00 00 48 83 ec 28 89 f1 4c 8b 8f=20
[ 3485.024015] RIP  [<ffffffff815c57e4>] skb_under_panic+0x54/0x60
[ 3485.024015]  RSP <ffff880028203df8>
[ 3485.024258] ------------[ cut here ]------------
[ 3485.024610] ---[ end trace 30a4557d927b50f9 ]---
[ 3485.024615] Kernel panic - not syncing: Fatal exception in interrupt
[ 3485.024621] Pid: 26456, comm: link mgr: alice Tainted: P      D    2.6.3=
3-
gentoo #3
[ 3485.024625] Call Trace:
[ 3485.024629]  <IRQ>  [<ffffffff8170d9e0>] ? panic+0x84/0x141
[ 3485.024640]  [<ffffffff81710dae>] ? _raw_spin_trylock+0xe/0x70
[ 3485.024647]  [<ffffffff81006b2b>] ? oops_end+0x9b/0xa0
[ 3485.024653]  [<ffffffff810040a4>] ? do_invalid_op+0x84/0xa0
[ 3485.024660]  [<ffffffff815c57e4>] ? skb_under_panic+0x54/0x60
[ 3485.024667]  [<ffffffff81042a03>] ? release_console_sem+0x1a3/0x1f0
[ 3485.024673]  [<ffffffff81042f8e>] ? vprintk+0x27e/0x450
[ 3485.024680]  [<ffffffff81003115>] ? invalid_op+0x15/0x20
[ 3485.024688]  [<ffffffff815c57e4>] ? skb_under_panic+0x54/0x60
[ 3485.024695]  [<ffffffff815c57e4>] ? skb_under_panic+0x54/0x60
[ 3485.024700]  [<ffffffff815c7c6f>] ? skb_push+0x2f/0x40
[ 3485.024707]  [<ffffffff814dc389>] ? aoenet_rcv+0x99/0x190
[ 3485.024714]  [<ffffffff815d0caa>] ? netif_receive_skb+0x31a/0x450
[ 3485.024720]  [<ffffffff81710971>] ? _raw_spin_unlock_irq+0x11/0x40
[ 3485.024726]  [<ffffffff8104d4e0>] ? run_timer_softirq+0x210/0x270
[ 3485.024734]  [<ffffffff815d0e55>] ? process_backlog+0x75/0xc0
[ 3485.024740]  [<ffffffff815d16b6>] ? net_rx_action+0x116/0x1e0
[ 3485.024748]  [<ffffffff81048244>] ? __do_softirq+0xb4/0x140
[ 3485.024755]  [<ffffffff8100338c>] ? call_softirq+0x1c/0x30
[ 3485.024758]  <EOI>  [<ffffffff8100553d>] ? do_softirq+0x4d/0x80
[ 3485.024769]  [<ffffffff815d1a6d>] ? netif_rx_ni+0x4d/0x70
[ 3485.024775]  [<ffffffff8148fb06>] ? tun_chr_aio_write+0x356/0x4e0
[ 3485.024782]  [<ffffffff810bea6f>] ? do_sync_write+0xbf/0x100
[ 3485.024790]  [<ffffffff810a1d0b>] ? handle_mm_fault+0x4bb/0x850
[ 3485.024797]  [<ffffffff81710cde>] ? _raw_spin_lock_irqsave+0x1e/0x50
[ 3485.024804]  [<ffffffff810bf538>] ? vfs_write+0xb8/0x180
[ 3485.024810]  [<ffffffff810bf6ee>] ? sys_write+0x4e/0x90
[ 3485.024817]  [<ffffffff8100256b>] ? system_call_fastpath+0x16/0x1b
[ 3485.024258] kernel BUG at net/core/skbuff.c:147!
[ 3485.024258] invalid opcode: 0000 [#2] PREEMPT SMP=20
[ 3485.024258] last sysfs file:=20
/sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0A:00/power_supply/BAT1/energy_fu=
ll
[ 3485.024258] CPU 1=20
[ 3485.024258] Pid: 26453, comm: link mgr: bob:a Tainted: P      D    2.6.3=
3-
gentoo #3 Portable PC/TECRA S10
[ 3485.024258] RIP: 0010:[<ffffffff815c57e4>]  [<ffffffff815c57e4>]=20
skb_under_panic+0x54/0x60
[ 3485.024258] RSP: 0018:ffff880028303df8  EFLAGS: 00010296
[ 3485.024258] RAX: 0000000000000092 RBX: ffff8800b50f33c0 RCX:=20
0000000000000000
[ 3485.024258] RDX: 0000000000000001 RSI: 0000000000000092 RDI:=20
0000000000000001
[ 3485.024258] RBP: ffff8800b50f33c0 R08: 0000000000000000 R09:=20
0000000000000001
[ 3485.024258] R10: 0000000000000000 R11: 0000000000000000 R12:=20
ffff8800bf599000
[ 3485.024258] R13: ffff8800bf599000 R14: 0000000000000000 R15:=20
000000000000a288
[ 3485.024258] FS:  00007f488bb40710(0000) GS:ffff880028300000(0000)=20
knlGS:0000000000000000
[ 3485.024258] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3485.024258] CR2: 00007f488bb3ea08 CR3: 0000000119008000 CR4:=20
00000000000406e0
[ 3485.024258] DR0: 0000000000000000 DR1: 0000000000000000 DR2:=20
0000000000000000
[ 3485.024258] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:=20
0000000000000400
[ 3485.024258] Process link mgr: bob:a (pid: 26453, threadinfo=20
ffff8800bf6ee000, task ffff8800bd103660)
[ 3485.024258] Stack:
[ 3485.024258]  0000000000000020 0000000000000040 ffff8800bf599000=20
ffff8800b50f33c0
[ 3485.024258] <0> ffff8800b50f33c0 ffffffff815c7c6f ffff8800b50f33c0=20
ffffffff814dc389
[ 3485.024258] <0> ffff8800bd102fb8 000000000000e240 ffffffff81d063a0=20
ffff8800b50f33c0
[ 3485.024258] Call Trace:
[ 3485.024258]  <IRQ>=20
[ 3485.024258]  [<ffffffff815c7c6f>] ? skb_push+0x2f/0x40
[ 3485.024258]  [<ffffffff814dc389>] ? aoenet_rcv+0x99/0x190
[ 3485.024258]  [<ffffffff815d0caa>] ? netif_receive_skb+0x31a/0x450
[ 3485.024258]  [<ffffffff81710971>] ? _raw_spin_unlock_irq+0x11/0x40
[ 3485.024258]  [<ffffffff815d0e55>] ? process_backlog+0x75/0xc0
[ 3485.024258]  [<ffffffff8103e8c7>] ? run_rebalance_domains+0x37/0xe0
[ 3485.024258]  [<ffffffff815d16b6>] ? net_rx_action+0x116/0x1e0
[ 3485.024258]  [<ffffffff81048244>] ? __do_softirq+0xb4/0x140
[ 3485.024258]  [<ffffffff8100338c>] ? call_softirq+0x1c/0x30
[ 3485.024258]  <EOI>=20
[ 3485.024258]  [<ffffffff8100553d>] ? do_softirq+0x4d/0x80
[ 3485.024258]  [<ffffffff815d1a6d>] ? netif_rx_ni+0x4d/0x70
[ 3485.024258]  [<ffffffff8148fb06>] ? tun_chr_aio_write+0x356/0x4e0
[ 3485.024258]  [<ffffffff8102797c>] ? flush_tlb_page+0x5c/0xe0
[ 3485.024258]  [<ffffffff810bea6f>] ? do_sync_write+0xbf/0x100
[ 3485.024258]  [<ffffffff810a1d0b>] ? handle_mm_fault+0x4bb/0x850
[ 3485.024258]  [<ffffffff81710cde>] ? _raw_spin_lock_irqsave+0x1e/0x50
[ 3485.024258]  [<ffffffff810bf538>] ? vfs_write+0xb8/0x180
[ 3485.024258]  [<ffffffff810bf6ee>] ? sys_write+0x4e/0x90
[ 3485.024258]  [<ffffffff8100256b>] ? system_call_fastpath+0x16/0x1b
[ 3485.024258] Code: 8b 57 68 48 89 44 24 10 8b 87 b8 00 00 00 48 89 44 24 =
08=20
31 c0 8b bf b4 00 00 00 48 89 3c 24 48 c7 c7 b0 1c a9 81 e8 b9 82 14 00 <0f=
>=20
0b eb fe 0f 1f 84 00 00 00 00 00 48 83 ec 28 89 f1 4c 8b 8f=20
[ 3485.024258] RIP  [<ffffffff815c57e4>] skb_under_panic+0x54/0x60
[ 3485.024258]  RSP <ffff880028303df8>

[8.1.] # ./ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
=20
Linux lanfear 2.6.33-gentoo #3 SMP PREEMPT Tue Mar 16 14:07:33 CET 2010 x86=
_64=20
Intel(R) Core(TM)2 Duo CPU T9550 @ 2.66GHz GenuineIntel GNU/Linux
=20
Gnu C                  4.4.3
Gnu make               3.81
binutils               2.20.1.20100303
util-linux             2.17.1
mount                  support
module-init-tools      3.11.1
e2fsprogs              1.41.10
pcmciautils            016
PPP                    2.4.4
Linux C Library        2.11
Dynamic linker (ldd)   2.11
Procps                 3.2.8
Net-tools              1.60_p20100101055920
Kbd                    1.15.1
oprofile               0.9.6
Sh-utils               8.4
wireless-tools         29
Modules Loaded         option snd_seq snd_seq_device snd_pcm_oss snd_mixer_=
oss=20
sco bnep rfcomm l2cap vmmon vmci vmblock vboxnetflt vboxnetadp vboxdrv nvid=
ia=20
btusb bluetooth snd_hda_codec_realtek zaurus pl2303 uvcvideo snd_hda_intel=
=20
cdc_ether usbnet iwlagn usbserial snd_hda_codec iwlcore mii usblp cdc_wdm=20
cdc_acm snd_hwdep snd_pcm mac80211 video psmouse toshiba_acpi pcspkr cfg802=
11=20
snd_timer backlight serio_raw output snd_page_alloc toshiba_bluetooth rfkil=
l=20
libiscsi scsi_wait_scan sl811_hcd


[8.2] # cat /proc/cpuinfo=20
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 23
model name      : Intel(R) Core(TM)2 Duo CPU     T9550  @ 2.66GHz
stepping        : 10
cpu MHz         : 2661.000
cache size      : 6144 KB
physical id     : 0
siblings        : 2
core id         : 0
cpu cores       : 2
apicid          : 0
initial apicid  : 0
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx l=
m=20
constant_tsc arch_perfmon pebs bts rep_good aperfmperf pni dtes64 monitor=20
ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 xsave lahf_lm ida=20
tpr_shadow vnmi flexpriority
bogomips        : 5319.97
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

processor       : 1
vendor_id       : GenuineIntel
cpu family      : 6
model           : 23
model name      : Intel(R) Core(TM)2 Duo CPU     T9550  @ 2.66GHz
stepping        : 10
cpu MHz         : 2661.000
cache size      : 6144 KB
physical id     : 0
siblings        : 2
core id         : 1
cpu cores       : 2
apicid          : 1
initial apicid  : 1
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx l=
m=20
constant_tsc arch_perfmon pebs bts rep_good aperfmperf pni dtes64 monitor=20
ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 xsave lahf_lm ida=20
tpr_shadow vnmi flexpriority
bogomips        : 5317.47
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

[8.3.] # cat /proc/modules=20
option 17826 0 - Live 0xffffffffa00ab000
snd_seq 51917 1 - Live 0xffffffffa0e48000
snd_seq_device 6266 1 snd_seq, Live 0xffffffffa0e41000
snd_pcm_oss 37689 0 - Live 0xffffffffa0e30000
snd_mixer_oss 14766 1 snd_pcm_oss, Live 0xffffffffa0e26000
sco 8699 2 - Live 0xffffffffa01af000
bnep 11167 2 - Live 0xffffffffa0130000
rfcomm 36509 4 - Live 0xffffffffa01ec000
l2cap 33696 16 bnep,rfcomm, Live 0xffffffffa0106000
vmmon 70844 0 - Live 0xffffffffa0e12000
vmci 53612 0 - Live 0xffffffffa0e02000
vmblock 11094 0 - Live 0xffffffffa0087000
vboxnetflt 10286 0 - Live 0xffffffffa0036000
vboxnetadp 4246 0 - Live 0xffffffffa000b000
vboxdrv 1723405 3 vboxnetflt,vboxnetadp, Live 0xffffffffa0c5b000
nvidia 9622117 40 - Live 0xffffffffa0254000 (P)
btusb 12243 2 - Live 0xffffffffa0056000
bluetooth 57375 9 sco,bnep,rfcomm,l2cap,btusb, Live 0xffffffffa0243000
snd_hda_codec_realtek 277964 1 - Live 0xffffffffa01fd000
zaurus 3116 0 - Live 0xffffffffa003d000
pl2303 16737 0 - Live 0xffffffffa0080000
uvcvideo 60397 0 - Live 0xffffffffa0172000
snd_hda_intel 22353 14 - Live 0xffffffffa001b000
cdc_ether 4471 1 zaurus, Live 0xffffffffa0005000
usbnet 18998 2 zaurus,cdc_ether, Live 0xffffffffa01f6000
iwlagn 216120 0 - Live 0xffffffffa01b5000
usbserial 37199 2 option,pl2303, Live 0xffffffffa01a3000
snd_hda_codec 81024 2 snd_hda_codec_realtek,snd_hda_intel, Live=20
0xffffffffa0182000
iwlcore 214518 1 iwlagn, Live 0xffffffffa013b000
mii 4973 1 usbnet, Live 0xffffffffa0134000
usblp 11258 0 - Live 0xffffffffa012b000
cdc_wdm 9012 0 - Live 0xffffffffa0123000
cdc_acm 16317 2 - Live 0xffffffffa0118000
snd_hwdep 6258 1 snd_hda_codec, Live 0xffffffffa0110000
snd_pcm 80714 7 snd_pcm_oss,snd_hda_intel,snd_hda_codec, Live=20
0xffffffffa00f0000
mac80211 146328 2 iwlagn,iwlcore, Live 0xffffffffa00bf000
video 19430 0 - Live 0xffffffffa00b3000
psmouse 57566 0 - Live 0xffffffffa009a000
toshiba_acpi 7734 0 - Live 0xffffffffa0092000
pcspkr 1830 0 - Live 0xffffffffa008c000
cfg80211 143104 3 iwlagn,iwlcore,mac80211, Live 0xffffffffa005b000
snd_timer 20483 6 snd_seq,snd_pcm, Live 0xffffffffa004e000
backlight 4636 2 video,toshiba_acpi, Live 0xffffffffa0047000
serio_raw 4463 0 - Live 0xffffffffa0040000
output 2207 1 video, Live 0xffffffffa003a000
snd_page_alloc 8012 2 snd_hda_intel,snd_pcm, Live 0xffffffffa0032000
toshiba_bluetooth 2031 0 - Live 0xffffffffa002c000
rfkill 12568 4 bluetooth,toshiba_acpi,cfg80211, Live 0xffffffffa0022000
libiscsi 44581 0 - Live 0xffffffffa000e000
scsi_wait_scan 693 0 - Live 0xffffffffa0008000
sl811_hcd 10564 0 - Live 0xffffffffa0000000

[8.4] # cat /proc/ioports=20
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
0170-0177 : ide_generic
01e0-01ef : pnp 00:09
01f0-01f7 : ide_generic
0376-0376 : ide_generic
03c0-03df : vga+
  03c0-03df : uvesafb
03f6-03f6 : ide_generic
03f8-03ff : serial
0480-048f : pnp 00:09
04d0-04d1 : pnp 00:09
0690-06ff : pnp 00:09
0cf8-0cff : PCI conf1
1000-1fff : PCI Bus 0000:06
  1000-10ff : PCI CardBus 0000:07
  1400-14ff : PCI CardBus 0000:07
7f20-7f3f : 0000:00:1f.2
  7f20-7f3f : ahci
7f44-7f47 : 0000:00:1f.2
  7f44-7f47 : ahci
7f48-7f4f : 0000:00:1f.2
  7f48-7f4f : ahci
7f54-7f57 : 0000:00:1f.2
  7f54-7f57 : ahci
7f58-7f5f : 0000:00:1f.2
  7f58-7f5f : ahci
7f60-7f7f : 0000:00:1d.2
  7f60-7f7f : uhci_hcd
7f80-7f9f : 0000:00:1d.1
  7f80-7f9f : uhci_hcd
7fe0-7fff : 0000:00:1d.0
  7fe0-7fff : uhci_hcd
8000-8fff : PCI Bus 0000:05
9000-9fff : PCI Bus 0000:03
a000-afff : PCI Bus 0000:02
bf40-bf5f : 0000:00:1a.2
  bf40-bf5f : uhci_hcd
bf60-bf7f : 0000:00:1a.1
  bf60-bf7f : uhci_hcd
bf80-bf9f : 0000:00:1a.0
  bf80-bf9f : uhci_hcd
bfe0-bfff : 0000:00:19.0
c000-cfff : PCI Bus 0000:01
  cf00-cf7f : 0000:01:00.0
d800-d87f : pnp 00:09
  d800-d803 : ACPI PM1a_EVT_BLK
  d804-d805 : ACPI PM1a_CNT_BLK
  d808-d80b : ACPI PM_TMR
  d810-d815 : ACPI CPU throttle
  d820-d82f : ACPI GPE0_BLK
  d850-d850 : ACPI PM2_CNT_BLK
d880-d89f : pnp 00:09
e000-e07f : pnp 00:09
e080-e0ff : pnp 00:09
e400-e47f : pnp 00:09
e480-e4ff : pnp 00:09
e800-e87f : pnp 00:09
e880-e8ff : pnp 00:09
ec00-ec7f : pnp 00:09
ec80-ecff : pnp 00:09
ee80-eeff : pnp 00:09

# cat /proc/iomem
00000000-0009bbff : System RAM
0009bc00-0009ffff : reserved
000e8000-000eedff : reserved
000eee00-000eefff : ACPI Non-volatile Storage
000ef000-000fffff : reserved
00100000-bfb9ffff : System RAM
  01000000-01713a60 : Kernel code
  01713a61-01d0a627 : Kernel data
  01daf000-01eb50a3 : Kernel bss
bfba0000-bfffffff : reserved
  bfba0000-bfbaffff : pnp 00:00
  bfbb0000-bfefffff : pnp 00:00
  bff00000-bfffffff : pnp 00:00
c0000000-c3ffffff : PCI Bus 0000:06
  c0000000-c3ffffff : PCI CardBus 0000:07
c4000000-c7ffffff : PCI CardBus 0000:07
e0000000-efffffff : PCI Bus 0000:01
  e0000000-efffffff : 0000:01:00.0
f0000000-f3ffffff : PCI MMCONFIG 0000 [bus 00-3f]
  f0000000-f3ffffff : pnp 00:01
f6000000-f7ffffff : PCI Bus 0000:03
f8000000-f9ffffff : PCI Bus 0000:03
fa000000-fdffffff : PCI Bus 0000:01
  fa000000-fbffffff : 0000:01:00.0
    fb000000-fb9fffff : uvesafb
  fc000000-fc01ffff : 0000:01:00.0
  fd000000-fdffffff : 0000:01:00.0
    fd000000-fdffffff : nvidia
fec00000-fec27fff : reserved
  fec00000-fec003ff : IOAPIC 0
fed00000-fed004ff : reserved
  fed00000-fed003ff : HPET 0
  fed00400-fed004ff : pnp 00:00
fed10000-fed19fff : reserved
  fed10000-fed19fff : pnp 00:00
fed1c000-fed93fff : reserved
  fed1c000-fed1ffff : pnp 00:00
  fed20000-fed3ffff : pnp 00:00
  fed45000-fed8ffff : pnp 00:00
  fed90000-fed93fff : pnp 00:00
fee00000-fee00fff : Local APIC
  fee00000-fee00fff : reserved
    fee00000-fee00fff : pnp 00:00
ff200000-ff3fffff : PCI Bus 0000:05
ff400000-ff5fffff : PCI Bus 0000:02
ff600000-ff6fffff : PCI Bus 0000:06
  ff600000-ff600fff : 0000:06:0b.0
    ff600000-ff600fff : yenta_socket
  ff6fb000-ff6fb0ff : 0000:06:0b.5
  ff6fc000-ff6fc0ff : 0000:06:0b.4
  ff6fd000-ff6fd0ff : 0000:06:0b.3
  ff6fe000-ff6fe0ff : 0000:06:0b.2
    ff6fe000-ff6fe0ff : mmc0
  ff6ff000-ff6ff7ff : 0000:06:0b.1
    ff6ff000-ff6ff7ff : firewire_ohci
ff700000-ff8fffff : PCI Bus 0000:05
ff900000-ff9fffff : PCI Bus 0000:02
  ff9fe000-ff9fffff : 0000:02:00.0
    ff9fe000-ff9fffff : iwlagn
ffa00000-ffbfffff : reserved
  ffa00000-ffbfffff : pnp 00:00
ffcc0000-ffcdffff : 0000:00:19.0
  ffcc0000-ffcdffff : e1000e
ffcf7000-ffcf77ff : 0000:00:1f.2
  ffcf7000-ffcf77ff : ahci
ffcf8000-ffcfbfff : 0000:00:1b.0
  ffcf8000-ffcfbfff : ICH HD audio
ffcfc000-ffcfc3ff : 0000:00:1d.7
  ffcfc000-ffcfc3ff : ehci_hcd
ffcfd000-ffcfd3ff : 0000:00:1a.7
  ffcfd000-ffcfd3ff : ehci_hcd
ffcfe000-ffcfefff : 0000:00:19.0
  ffcfe000-ffcfefff : e1000e
ffcff000-ffcff00f : 0000:00:03.0
ffd00000-ffffffff : reserved
  ffd00000-ffffffff : pnp 00:00
100000000-13bffffff : System RAM

[8.5.] lspci.vvv.txt attached

[8.6.] # cat /proc/scsi/scsi=20
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Hitachi HTS72323 Rev: FC4O
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi1 Channel: 00 Id: 00 Lun: 00
  Vendor: TEAC     Model: DV-W28S-RT       Rev: 7.0D
  Type:   CD-ROM                           ANSI  SCSI revision: 05
Host: scsi5 Channel: 00 Id: 00 Lun: 00
  Vendor: LITE-ON  Model: DVDRW SOHW-1653S Rev: CS09
  Type:   CD-ROM                           ANSI  SCSI revision: 00


[8.7] -


Hopefully I gathered all what's needed.

Machine works very well besides this kernel bug. No problem at all so far.=
=20
However, I'm still not quite sure=20

KR,


Oliver

=2D-=20
DI Oliver Maurhart
Safety & Security Department
Secure Quantum Technologies

AIT Austrian Institute of Technology GmbH
Donau-City-Stra=EF=BF=BDe 1 | 1220 Vienna | Austria\nT +43(0) 50550-4771 | =
M +43(0)=20
664 8251205\noliver.maurhart@ait.ac.at | http://www.ait.ac.at\n\nFN: 115980=
 i=20
HG Wien | UID: ATU14703506\nRSA2048

--Boundary-00=_U6ioL7dcdvoJQ9I
Content-Type: application/x-gzip; name="config.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="config.gz"

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

--Boundary-00=_U6ioL7dcdvoJQ9I
Content-Type: text/plain; charset="UTF-8"; name="lspci.vvv.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="lspci.vvv.txt"

00:00.0 Host bridge: Intel Corporation Mobile 4 Series Chipset Memory Controller Hub (rev 07)
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information <?>

00:01.0 PCI bridge: Intel Corporation Mobile 4 Series Chipset PCI Express Graphics Port (rev 07) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 0000c000-0000cfff
	Memory behind bridge: fa000000-fdffffff
	Prefetchable memory behind bridge: 00000000e0000000-00000000efffffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [88] Subsystem: Toshiba America Info Systems Device 0001
	Capabilities: [80] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4169
	Capabilities: [a0] Express (v1) Root Port (Slot-), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x16, ASPM L0s L1, Latency L0 <256ns, L1 <4us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [100] Virtual Channel <?>
	Capabilities: [140] Root Complex Link <?>
	Kernel driver in use: pcieport

00:03.0 Communication controller: Intel Corporation Mobile 4 Series Chipset MEI Controller (rev 07)
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at ffcff000 (64-bit, non-prefetchable) [size=16]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [8c] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000

00:19.0 Ethernet controller: Intel Corporation 82567LM Gigabit Network Connection (rev 03)
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 29
	Region 0: Memory at ffcc0000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at ffcfe000 (32-bit, non-prefetchable) [size=4K]
	Region 2: I/O ports at bfe0 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 41d1
	Capabilities: [e0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: e1000e

00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #4 (rev 03) (prog-if 00 [UHCI])
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 4: I/O ports at bf80 [size=32]
	Capabilities: [50] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: uhci_hcd

00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #5 (rev 03) (prog-if 00 [UHCI])
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 21
	Region 4: I/O ports at bf60 [size=32]
	Capabilities: [50] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: uhci_hcd

00:1a.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #6 (rev 03) (prog-if 00 [UHCI])
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 19
	Region 4: I/O ports at bf40 [size=32]
	Capabilities: [50] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: uhci_hcd

00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #2 (rev 03) (prog-if 20 [EHCI])
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 19
	Region 0: Memory at ffcfd000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ehci_hcd

00:1b.0 Audio device: Intel Corporation 82801I (ICH9 Family) HD Audio Controller (rev 03)
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 31
	Region 0: Memory at ffcf8000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 41c1
	Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0 <64ns, L1 <1us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive- BWMgmt- ABWMgmt-
	Capabilities: [100] Virtual Channel <?>
	Capabilities: [130] Root Complex Link <?>
	Kernel driver in use: HDA Intel
	Kernel modules: snd-hda-intel

00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 1 (rev 03) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 0000a000-0000afff
	Memory behind bridge: ff900000-ff9fffff
	Prefetchable memory behind bridge: 00000000ff400000-00000000ff5fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4171
	Capabilities: [90] Subsystem: Toshiba America Info Systems Device 0001
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100] Virtual Channel <?>
	Capabilities: [180] Root Complex Link <?>
	Kernel driver in use: pcieport

00:1c.1 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 2 (rev 03) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=03, subordinate=04, sec-latency=0
	I/O behind bridge: 00009000-00009fff
	Memory behind bridge: f8000000-f9ffffff
	Prefetchable memory behind bridge: 00000000f6000000-00000000f7ffffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
			Slot #  1, PowerLimit 6.500000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn+ PwrFlt- MRL- PresDet+ CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4179
	Capabilities: [90] Subsystem: Toshiba America Info Systems Device 0001
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100] Virtual Channel <?>
	Capabilities: [180] Root Complex Link <?>
	Kernel driver in use: pcieport

00:1c.2 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 3 (rev 03) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
	I/O behind bridge: 00008000-00008fff
	Memory behind bridge: ff700000-ff8fffff
	Prefetchable memory behind bridge: 00000000ff200000-00000000ff3fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4181
	Capabilities: [90] Subsystem: Toshiba America Info Systems Device 0001
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100] Virtual Channel <?>
	Capabilities: [180] Root Complex Link <?>
	Kernel driver in use: pcieport

00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #1 (rev 03) (prog-if 00 [UHCI])
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 4: I/O ports at 7fe0 [size=32]
	Capabilities: [50] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: uhci_hcd

00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #2 (rev 03) (prog-if 00 [UHCI])
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 7f80 [size=32]
	Capabilities: [50] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: uhci_hcd

00:1d.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #3 (rev 03) (prog-if 00 [UHCI])
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 7f60 [size=32]
	Capabilities: [50] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: uhci_hcd

00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #1 (rev 03) (prog-if 20 [EHCI])
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at ffcfc000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ehci_hcd

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev 93) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=06, subordinate=0a, sec-latency=32
	I/O behind bridge: 00001000-00001fff
	Memory behind bridge: ff600000-ff6fffff
	Prefetchable memory behind bridge: 00000000c0000000-00000000c3ffffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: Toshiba America Info Systems Device 0001

00:1f.0 ISA bridge: Intel Corporation ICH9M-E LPC Interface Controller (rev 03)
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information <?>

00:1f.2 SATA controller: Intel Corporation ICH9M/M-E SATA AHCI Controller (rev 03) (prog-if 01 [AHCI 1.0])
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 28
	Region 0: I/O ports at 7f58 [size=8]
	Region 1: I/O ports at 7f54 [size=4]
	Region 2: I/O ports at 7f48 [size=8]
	Region 3: I/O ports at 7f44 [size=4]
	Region 4: I/O ports at 7f20 [size=32]
	Region 5: Memory at ffcf7000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: [80] MSI: Enable+ Count=1/16 Maskable- 64bit-
		Address: fee0300c  Data: 4191
	Capabilities: [70] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a8] SATA HBA <?>
	Capabilities: [b0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ahci

01:00.0 VGA compatible controller: nVidia Corporation G86M [Quadro NVS 150M] (rev a1) (prog-if 00 [VGA controller])
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at fd000000 (32-bit, non-prefetchable) [size=16M]
	Region 1: Memory at e0000000 (64-bit, prefetchable) [size=256M]
	Region 3: Memory at fa000000 (64-bit, non-prefetchable) [size=32M]
	Region 5: I/O ports at cf00 [size=128]
	[virtual] Expansion ROM at fc000000 [disabled] [size=128K]
	Capabilities: [60] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [68] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [78] Express (v2) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <256ns, L1 <4us
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag+ PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 5GT/s, Width x16, ASPM L0s L1, Latency L0 <256ns, L1 <1us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM L0s L1 Enabled; RCB 128 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [100] Virtual Channel <?>
	Capabilities: [128] Power Budgeting <?>
	Capabilities: [600] Vendor Specific Information <?>
	Kernel driver in use: nvidia
	Kernel modules: nvidia

02:00.0 Network controller: Intel Corporation Wireless WiFi Link 5100
	Subsystem: Intel Corporation PRO/Wireless 5100AGN Network Connection
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 30
	Region 0: Memory at ff9fe000 (64-bit, non-prefetchable) [size=8K]
	Capabilities: [c8] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 41b9
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <32us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [100] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
	Capabilities: [140] Device Serial Number 00-22-fa-ff-ff-3c-77-ae
	Kernel driver in use: iwlagn
	Kernel modules: iwlagn

06:0b.0 CardBus bridge: Ricoh Co Ltd RL5c476 II (rev ba)
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 168
	Interrupt: pin A routed to IRQ 22
	Region 0: Memory at ff600000 (32-bit, non-prefetchable) [size=4K]
	Bus: primary=06, secondary=07, subordinate=0a, sec-latency=176
	Memory window 0: c0000000-c3fff000 (prefetchable)
	Memory window 1: c4000000-c7fff000
	I/O window 0: 00001000-000010ff
	I/O window 1: 00001400-000014ff
	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset- 16bInt+ PostWrite+
	16-bit legacy interface ports at 0001
	Kernel driver in use: yenta_cardbus

06:0b.1 FireWire (IEEE 1394): Ricoh Co Ltd R5C832 IEEE 1394 Controller (rev 04) (prog-if 10 [OHCI])
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (500ns min, 1000ns max), Cache Line Size: 32 bytes
	Interrupt: pin B routed to IRQ 23
	Region 0: Memory at ff6ff000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME+
	Kernel driver in use: firewire_ohci

06:0b.2 SD Host controller: Ricoh Co Ltd R5C822 SD/SDIO/MMC/MS/MSPro Host Adapter (rev 21)
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin C routed to IRQ 21
	Region 0: Memory at ff6fe000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME-
	Kernel driver in use: sdhci-pci

06:0b.3 System peripheral: Ricoh Co Ltd R5C843 MMC Host Controller (rev ff) (prog-if ff)
	!!! Unknown header type 7f
	Kernel driver in use: ricoh-mmc

06:0b.4 System peripheral: Ricoh Co Ltd R5C592 Memory Stick Bus Host Adapter (rev 11)
	Subsystem: Toshiba America Info Systems Device 0001
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin C routed to IRQ 11
	Region 0: Memory at ff6fc000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME-

06:0b.5 System peripheral: Ricoh Co Ltd xD-Picture Card Controller (rev 11)
	Subsystem: Toshiba America Info Systems Device 0001
	Physical Slot: 0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin C routed to IRQ 11
	Region 0: Memory at ff6fb000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME-


--Boundary-00=_U6ioL7dcdvoJQ9I--
