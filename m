From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 2.6.37 : oops in cleanup_once
Date: Wed, 02 Feb 2011 11:52:52 +0100
Message-ID: <1296643972.20445.9.camel@edumazet-laptop>
References: <4D491B8D.1000107@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62276 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480Ab1BBKxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 05:53:02 -0500
In-Reply-To: <4D491B8D.1000107@univ-nantes.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 09:53 +0100, Yann Dupont a =C3=A9=
crit :
> Hello.
> We recently upgraded one machine with vanilla 2.6.37, and experienced=
 2=20
> kernel oops since. Each oops is after ~1 week of uptime.
> The last oops was last night but we didn't had any trace.
>=20
> Here is the previous oops :
>=20
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316042=
]=20
> BUG: unable to handle kernel NULL pointer dereference at 000000000000=
000d
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316096=
]=20
> IP: [<ffffffff8130e6bf>] cleanup_once+0x3f/0xa0
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316135=
] PGD 0
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316157=
]=20
> Oops: 0002 [#1] SMP
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316188=
]=20
> last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu=
_map
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316234=
] CPU 1
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316240=
]=20
> Modules linked in: xt_physdev ip6t_LOG nf_conntrack_ipv6 nf_defrag_ip=
v6=20
> ipt_LOG xt_multiport xt_limit nf_conntrack_tftp nf_conntrack_ftp tun=20
> ip6table_filter ip6_tables ipt_MASQUERADE iptable_nat nf_nat=20
> nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT=20
> xt_tcpudp iptable_filter ip_tables x_tables kvm_intel kvm ipv6 8021q=20
> bridge stp ext2 mbcache fuse snd_pcm snd_timer snd soundcore=20
> snd_page_alloc i5000_edac edac_core psmouse evdev i5k_amb tpm_tis tpm=
=20
> joydev dcdbas tpm_bios pcspkr rng_core ghes shpchp serio_raw pci_hotp=
lug=20
> processor hed button thermal_sys xfs exportfs dm_mod sg sr_mod sd_mod=
=20
> cdrom usbhid hid usb_storage qla2xxx scsi_transport_fc scsi_tgt uhci_=
hcd=20
> mptsas mptscsih ehci_hcd mptbase bnx2 scsi_transport_sas scsi_mod [la=
st=20
> unloaded: scsi_wait_scan]
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316694=
]
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316715=
]=20
> Pid: 0, comm: kworker/0:0 Not tainted 2.6.37-dsiun-110105 #17=20
> 0MY736/PowerEdge M600
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316761=
]=20
> RIP: 0010:[<ffffffff8130e6bf>]  [<ffffffff8130e6bf>] cleanup_once+0x3=
f/0xa0
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316808=
]=20
> RSP: 0018:ffff8800cfc43e20  EFLAGS: 00010202
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316834=
]=20
> RAX: ffff8803d3158018 RBX: ffff8803d3158000 RCX: 0000000000000005
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.316878=
]=20
> RDX: 0b000209f1beadde RSI: 00000000000000ac RDI: ffffffff8152a970
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.318512=
]=20
> RBP: 00000000000248f6 R08: 00000000003d0900 R09: 0000000000000000
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.318560=
]=20
> R10: dead000000200200 R11: 0000000000000000 R12: ffff8800cfc43ea0
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.318604=
]=20
> R13: 0000000000000100 R14: ffff88040fc99fd8 R15: 0000000000000000
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.318652=
]=20
> FS:  0000000000000000(0000) GS:ffff8800cfc40000(0000) knlGS:000000000=
0000000
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.318698=
]=20
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.318725=
]=20
> CR2: 000000000000000d CR3: 00000000014f1000 CR4: 00000000000026e0
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.318768=
]=20
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.318812=
]=20
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.318855=
]=20
> Process kworker/0:0 (pid: 0, threadinfo ffff88040fc98000, task=20
> ffff88040fc6c2e0)
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.318901=
]=20
> Stack:
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.318921=
] =20
> 0000000000000082 00000001029221c1 00000000000248f6 ffffffff8130e988
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.318971=
] =20
> ffff88040fc90000 ffff88040fc90000 ffffffff8152a9a0 ffffffff8105e95f
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319021=
] =20
> ffff8800cfc43e58 ffff88040fc91020 ffffffff8130e950 ffff88040fc99fd8
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319072=
]=20
> Call Trace:
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319093=
] <IRQ>
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319116=
] =20
> [<ffffffff8130e988>] ? peer_check_expire+0x38/0x110
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319146=
] =20
> [<ffffffff8105e95f>] ? run_timer_softirq+0x16f/0x350
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319175=
] =20
> [<ffffffff8130e950>] ? peer_check_expire+0x0/0x110
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319204=
] =20
> [<ffffffff81079c6b>] ? ktime_get+0x5b/0xe0
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319232=
] =20
> [<ffffffff8105685a>] ? __do_softirq+0xaa/0x1e0
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319260=
] =20
> [<ffffffff81003ddc>] ? call_softirq+0x1c/0x30
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319288=
] =20
> [<ffffffff81005f75>] ? do_softirq+0x65/0xa0
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319315=
] =20
> [<ffffffff81056745>] ? irq_exit+0x85/0x90
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319343=
] =20
> [<ffffffff8102137a>] ? smp_apic_timer_interrupt+0x6a/0xa0
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319373=
] =20
> [<ffffffff81003893>] ? apic_timer_interrupt+0x13/0x20
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319401=
] <EOI>
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319427=
] =20
> [<ffffffffa032218c>] ? acpi_idle_enter_bm+0x243/0x27b [processor]
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319473=
] =20
> [<ffffffffa0322185>] ? acpi_idle_enter_bm+0x23c/0x27b [processor]
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319519=
] =20
> [<ffffffff812c0deb>] ? cpuidle_idle_call+0x8b/0x140
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319547=
] =20
> [<ffffffff8100208a>] ? cpu_idle+0x6a/0xf0
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319573=
]=20
> Code: 00 48 8b 05 c4 c2 21 00 48 3d 60 a9 52 81 74 5c 48 8d 58 e8 48 =
8b=20
> 15 11 02 24 00 2b 53 28 48 39 ea 72 49 48 8b 4b 18 48 8b 53 20 <48> 8=
9=20
> 51 08 48 89 0a 48 89 43 18 48 89 43 20 f0 ff 40 14 48 c7
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319768=
]=20
> RIP  [<ffffffff8130e6bf>] cleanup_once+0x3f/0xa0
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319797=
] =20
> RSP <ffff8800cfc43e20>
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.319820=
]=20
> CR2: 000000000000000d
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.320187=
]=20
> ---[ end trace eaf3ed2d46c78768 ]---
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.320257=
]=20
> Kernel panic - not syncing: Fatal exception in interrupt
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.320329=
]=20
> Pid: 0, comm: kworker/0:0 Tainted: G      D     2.6.37-dsiun-110105 #=
17
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.320418=
]=20
> Call Trace:
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.320481=
]=20
> <IRQ>  [<ffffffff8137c75e>] ? panic+0x92/0x1a2
> Jan 21 13:15:41 linkwood.u11.univ-nantes.prive kernel: [172825.320601=
] =20
> [<ffffffff81007357>] ? oops_end+0xe7/0xf0
>=20
>=20
> Any ideas ??


Hi Yann

Yes this is a known problem.

Please try commit 3408404a4c2a4eead9d73b0bbbfe3f225b65f492
(inetpeer: Use correct AVL tree base pointer in inet_getpeer())

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D3408404a4c2a4eead9d73b0bbbfe3f225b65f492

I believe David will send it to stable team shortly, if not already
done :)

Thanks


