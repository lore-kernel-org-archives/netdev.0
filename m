From: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Subject: Re: kernel 2.6.37 : oops in cleanup_once
Date: Wed, 02 Feb 2011 18:59:45 +0100
Message-ID: <4D499B91.7080701@univ-nantes.fr>
References: <4D491B8D.1000107@univ-nantes.fr>	 <1296643972.20445.9.camel@edumazet-laptop>	 <1296645887.20445.11.camel@edumazet-laptop>	 <4D495765.4090806@univ-nantes.fr>	 <1296658407.20445.19.camel@edumazet-laptop>	 <4D49726C.6020103@univ-nantes.fr> <1296659336.20445.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296659336.20445.22.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 02/02/2011 16:08, Eric Dumazet a =C3=A9crit :
> Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 16:04 +0100, Yann Dupont a =C3=
=A9crit :
>> Ok, will do it at 18:30 CET (to minimize impact)
>> It the suspected bug SLUB related ?
>>
> no : It can be a corruption from another part of kernel.
>
>> The 2.6.34.2 kernel previously used on that server used SLAB.
>>
>>
>> 2 questions :
>> -How can I be sure slub_nomerge is active ? Boot message ?
>
> # ls -l /sys/kernel/slab/
>
> If you have symlinks : merge is on (default)
>
> If you dont have symlinks : nomerge is in action
>
>> -Is there a very severe impact on performance ?
>>
> not at all
>
>> Regards,
>>
>
well. The server had the good taste to oops at 18H05, 25 minutes before=
=20
the planned reboot :)

here is the oops (I think it's quite the same) :


=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.128042]=
=20
BUG: unable to handle kernel NULL pointer dereference at 00000000000000=
0d
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.128097]=
=20
IP: [<ffffffff8130e6bf>] cleanup_once+0x3f/0xa0
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.128146]=
 PGD 0
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.128173]=
=20
Oops: 0002 [#1] SMP
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.128200]=
=20
last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_m=
ap
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.128250]=
 CPU 7
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.128260]=
=20
Modules linked in: dell_rbu acpi_cpufreq freq_table mperf nls_utf8=20
nls_cp437 btrfs zlib_deflate crc32c libcrc32c ufs qnx4 hfsplus hfs mini=
x=20
ntfs vfat msdos fat jfs rei
serfs ext4 jbd2 crc16 ext3 jbd tun ipt_MASQUERADE iptable_nat nf_nat=20
ipt_REJECT kvm_intel kvm xt_physdev ip6t_LOG nf_conntrack_ipv6=20
nf_defrag_ipv6 ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit=
=20
xt_tcpudp xt_state iptable_filter
  ip_tables x_tables nf_conntrack_tftp nf_conntrack_ftp=20
nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ipv6 8021q bridge stp ext=
2=20
mbcache fuse snd_pcm snd_timer ghes hed button snd soundcore i5000_edac=
=20
edac_core processor shpchp tpm_tis pc
i_hotplug tpm rng_core snd_page_alloc i5k_amb dcdbas tpm_bios joydev=20
evdev psmouse pcspkr serio_raw thermal_sys xfs exportfs dm_mod sg sr_mo=
d=20
cdrom sd_mod usbhid hid usb_storage qla2xxx scsi_transport_fc scsi_tgt=20
uhci_hcd mptsas mptscsih
  mptbase bnx2 scsi_transport_sas scsi_mod ehci_hcd [last unloaded:=20
scsi_wait_scan]
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.128834]
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.128855]=
=20
Pid: 0, comm: kworker/0:1 Not tainted 2.6.37-dsiun-110105 #17=20
0MY736/PowerEdge M600
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.128901]=
=20
RIP: 0010:[<ffffffff8130e6bf>]  [<ffffffff8130e6bf>] cleanup_once+0x3f/=
0xa0
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.128948]=
=20
RSP: 0018:ffff8800cfdc3e20  EFLAGS: 00010206
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.128974]=
=20
RAX: ffff8803a7e0ea18 RBX: ffff8803a7e0ea00 RCX: 0000000000000005
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129003]=
=20
RDX: adde806c0d860b00 RSI: 0000000000000096 RDI: ffffffff8152a970
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129032]=
=20
RBP: 00000000000248f6 R08: 00000000003d0900 R09: 0000000000000000
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129062]=
=20
R10: dead000000200200 R11: 0000000000000000 R12: ffff8800cfdc3ea0
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129091]=
=20
R13: 0000000000000100 R14: ffff88040fd29fd8 R15: 0000000000000000
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129121]=
=20
=46S:  0000000000000000(0000) GS:ffff8800cfdc0000(0000) knlGS:000000000=
0000000
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129166]=
=20
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129193]=
=20
CR2: 000000000000000d CR3: 00000000014f1000 CR4: 00000000000026e0
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129223]=
=20
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129252]=
=20
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129282]=
=20
Process kworker/0:1 (pid: 0, threadinfo ffff88040fd28000, task=20
ffff88040fce6450)
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129327]=
 Stack:
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129347]=
 =20
0000000000000082 00000001008d3b66 00000000000248f6 ffffffff8130e988
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129397]=
 =20
ffff88040fd24000 ffff88040fd24000 ffffffff8152a9a0 ffffffff8105e95f
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129446]=
 =20
ffff8800cfdc3e58 ffff88040fd25020 ffffffff8130e950 ffff88040fd29fd8
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129496]=
=20
Call Trace:
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129523]=
 <IRQ>
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129551]=
 =20
[<ffffffff8130e988>] ? peer_check_expire+0x38/0x110
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129581]=
 =20
[<ffffffff8105e95f>] ? run_timer_softirq+0x16f/0x350
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129609]=
 =20
[<ffffffff8130e950>] ? peer_check_expire+0x0/0x110
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129638]=
 =20
[<ffffffff81079c6b>] ? ktime_get+0x5b/0xe0
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129666]=
 =20
[<ffffffff8105685a>] ? __do_softirq+0xaa/0x1e0
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129694]=
 =20
[<ffffffff81003ddc>] ? call_softirq+0x1c/0x30
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129722]=
 =20
[<ffffffff81005f75>] ? do_softirq+0x65/0xa0
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129748]=
 =20
[<ffffffff81056745>] ? irq_exit+0x85/0x90
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129776]=
 =20
[<ffffffff8102137a>] ? smp_apic_timer_interrupt+0x6a/0xa0
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129806]=
 =20
[<ffffffff81003893>] ? apic_timer_interrupt+0x13/0x20
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129833]=
 <EOI>
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129857]=
 =20
[<ffffffff8123f5ce>] ? acpi_hw_register_read+0x54/0xe2
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129890]=
 =20
[<ffffffffa01c52b8>] ? acpi_idle_enter_simple+0xf4/0x126 [processor]
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.129936]=
 =20
[<ffffffffa01c52b1>] ? acpi_idle_enter_simple+0xed/0x126 [processor]
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.131555]=
 =20
[<ffffffffa01c5034>] ? acpi_idle_enter_bm+0xeb/0x27b [processor]
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.131591]=
 =20
[<ffffffff812c0deb>] ? cpuidle_idle_call+0x8b/0x140
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.131619]=
 =20
[<ffffffff8100208a>] ? cpu_idle+0x6a/0xf0
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.131645]=
=20
Code: 00 48 8b 05 c4 c2 21 00 48 3d 60 a9 52 81 74 5c 48 8d 58 e8 48 8b=
=20
15 11 02 24 00 2b 53 28 48 39 ea 72 49 48 8b 4b 18 48 8b 53 20 <48> 89=20
51 08 48 89 0a 48 89 43 18 48 89 43 20 f0 ff 40 14 48 c7
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.131847]=
=20
RIP  [<ffffffff8130e6bf>] cleanup_once+0x3f/0xa0
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.131876]=
 =20
RSP <ffff8800cfdc3e20>
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.131898]=
=20
CR2: 000000000000000d
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.132280]=
=20
---[ end trace a9f45436c3b7c143 ]---
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.132350]=
=20
Kernel panic - not syncing: Fatal exception in interrupt
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.132422]=
=20
Pid: 0, comm: kworker/0:1 Tainted: G      D     2.6.37-dsiun-110105 #17
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.132510]=
=20
Call Trace:
=46eb  2 18:05:33 linkwood.u11.univ-nantes.prive kernel: [37323.132574]=
=20
<IRQ>  [<ffffffff8137c75e>] ? panic+0x92/0x1a2

and I also have a screenshot with more details. I'll send it in a=20
private message.



Since 18H30, the server runs with slub_nomerge.

--=20
Yann Dupont - Service IRTS, DSI Universit=C3=A9 de Nantes
Tel : 02.53.48.49.20 - Mail/Jabber : Yann.Dupont@univ-nantes.fr
