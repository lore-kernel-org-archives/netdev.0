From: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Fri, 16 Jul 2010 14:25:41 +0200
Message-ID: <4C404FC5.6040107@nets.rwth-aachen.de>
References: <4C358AAA.9080400@kernel.org> <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi> <4C3EF7EA.2040900@nets.rwth-aachen.de> <1279195528.2496.2.camel@edumazet-laptop> <4C3F053F.7090704@nets.rwth-aachen.de> <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Tejun Heo <tj@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-i4.nets.RWTH-Aachen.DE ([137.226.12.21]:42378 "EHLO
	MAIL-i4.nets.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965280Ab0GPMZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 08:25:44 -0400
In-Reply-To: <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.07.2010 14:02, Ilpo J=E4rvinen wrote:
>
>>>> [ 2754.413150] NULL head, pkts 0
>>>> [ 2754.413156] Errors caught so far 1
>>>>         =20
> Thanks for reporting the results.
>
> Could you post the oops too or double check do the timestamps really =
match
> (and there wasn't more "Errors caught" prints in between)? Since this
> condition doesn't seem to crash the kernel as also send_head should b=
e
> NULL, which saves the day here exiting the loop (unless send head wou=
ld
> too be corrupt).
>   =20
I can try to do some more testing, perhaps then I will get other=20
results. But until now I've always gotten something like above.

With the debug patch the kernel doesn't crash, but I have an oops from =
a=20
run before the patch:

[ 3214.498061] BUG: unable to handle kernel NULL pointer dereference at=
=20
(null)
[ 3214.498085] IP: [<c12657dc>] tcp_xmit_retransmit_queue+0x4c/0x2b0
[ 3214.498121] *pdpt =3D 00000002cf6fa001
[ 3214.498130] Thread overran stack, or stack corrupted
[ 3214.498138] Oops: 0000 [#1] SMP
[ 3214.498154] last sysfs file: /sys/kernel/uevent_seqnum
[ 3214.498161] Modules linked in: tcp_ancr tcp_ncr
[ 3214.498174]
[ 3214.498180] Pid: 0, comm: swapper Not tainted (2.6.31.9-pae-um-wolff=
=20
#79)
[ 3214.498188] EIP: 0061:[<c12657dc>] EFLAGS: 00010246 CPU: 0
[ 3214.498196] EIP is at tcp_xmit_retransmit_queue+0x4c/0x2b0
[ 3214.498203] EAX: c6da2900 EBX: c6da2880 ECX: 00000000 EDX: e50c512e
[ 3214.498211] ESI: 00000000 EDI: 0000051b EBP: c6da2900 ESP: c13d5cf0
[ 3214.498219]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0069
[ 3214.498227] Process swapper (pid: 0, ti=3Dc13d4000 task=3Dc13e7a20=20
task.ti=3Dc13d4000)
[ 3214.498236] Stack:
[ 3214.498240]  c1005a0b 00000001 00000000 e50c512e c7804300 00000013=20
c6da2880 0000051b
[ 3214.498264] <0> e50c512e c1260709 c6cbf840 c6d42000 c1031826 c1288bb=
d=20
c6da2900 c6e09320
[ 3214.498290] <0> c6e09300 00000000 00000000 00000001 e50c512d e521a34=
6=20
e50c512e 00000000
[ 3214.498318] Call Trace:
[ 3214.498329]  [<c1005a0b>] ? xen_restore_fl_direct_end+0x0/0x1
[ 3214.498339]  [<c1260709>] ? tcp_ack+0x7f9/0x10d0
[ 3214.498350]  [<c1031826>] ? local_bh_enable+0x56/0x80
[ 3214.498359]  [<c1288bbd>] ? ipt_do_table+0x2dd/0x590
[ 3214.498369]  [<c1261eef>] ? tcp_rcv_state_process+0x41f/0x970
[ 3214.498378]  [<c1267e7f>] ? tcp_v4_do_rcv+0x8f/0x1e0
[ 3214.498387]  [<c1269ccd>] ? tcp_v4_rcv+0x68d/0x7d0
[ 3214.498397]  [<c124d5f0>] ? ip_local_deliver_finish+0x0/0x1e0
[ 3214.498406]  [<c124d687>] ? ip_local_deliver_finish+0x97/0x1e0
[ 3214.498416]  [<c124d5f0>] ? ip_local_deliver_finish+0x0/0x1e0
[ 3214.498425]  [<c124d3eb>] ? ip_rcv_finish+0x13b/0x340
[ 3214.498434]  [<c124d2b0>] ? ip_rcv_finish+0x0/0x340
[ 3214.498442]  [<c124d8c0>] ? ip_rcv+0x0/0x2e0
[ 3214.498452]  [<c1211037>] ? netif_receive_skb+0x2f7/0x4c0
[ 3214.498468]  [<c1213fe0>] ? process_backlog+0x70/0xb0
[ 3214.498476]  [<c1213d98>] ? net_rx_action+0xe8/0x1a0
[ 3214.498486]  [<c103116d>] ? __do_softirq+0x8d/0x120
[ 3214.498494]  [<c100360d>] ? xen_mc_flush+0xed/0x1a0
[ 3214.498504]  [<c1057891>] ? move_native_irq+0x11/0x50
[ 3214.498513]  [<c1031238>] ? do_softirq+0x38/0x40
[ 3214.498523]  [<c11930e2>] ? xen_evtchn_do_upcall+0x142/0x160
[ 3214.498534]  [<c10087d7>] ? xen_do_upcall+0x7/0xc
[ 3214.498543]  [<c10013a7>] ? hypercall_page+0x3a7/0x1010
[ 3214.498552]  [<c100520f>] ? xen_safe_halt+0xf/0x20
[ 3214.498560]  [<c100349c>] ? xen_idle+0x1c/0x30
[ 3214.498569]  [<c1006bba>] ? cpu_idle+0x3a/0x60
[ 3214.498578]  [<c141692a>] ? start_kernel+0x26a/0x300
[ 3214.498616]  [<c1416280>] ? unknown_bootoption+0x0/0x1c0
[ 3214.498630]  [<c141938e>] ? xen_start_kernel+0x3be/0x3e0
[ 3214.498637] Code: 00 00 8b b3 a0 03 00 00 85 f6 0f 84 53 02 00 00 8b=
=20
46 3c 8d ab 80 00 00 00 8b 93 04 04 00 00 39 c2 89 54 24 0c 0f 89 1c 02=
=20
00 00 <8b> 06 0f 18 00 90 39 ee 0f 84 30 01 00 00 39 b3 28 01 00 00 8d
[ 3214.498820] EIP: [<c12657dc>] tcp_xmit_retransmit_queue+0x4c/0x2b0=20
SS:ESP 0069:c13d5cf0
[ 3214.498836] CR2: 0000000000000000
[ 3214.498846] ---[ end trace 709a97adf87834a7 ]---
[ 3214.498852] Kernel panic - not syncing: Fatal exception in interrupt
[ 3214.498862] Pid: 0, comm: swapper Tainted: G      D   =20
2.6.31.9-pae-um-wolff #79
[ 3214.498870] Call Trace:
[ 3214.498878]  [<c102c896>] ? panic+0x46/0x100
[ 3214.498904]  [<c100b428>] ? oops_end+0x98/0xa0
[ 3214.498922]  [<c1019eff>] ? no_context+0x11f/0x1b0
[ 3214.498930]  [<c101a516>] ? do_page_fault+0x66/0x240
[ 3214.498939]  [<c101a4b0>] ? do_page_fault+0x0/0x240
[ 3214.498947]  [<c101a23f>] ? bad_area_nosemaphore+0xf/0x20
[ 3214.498955]  [<c1308b7e>] ? error_code+0x66/0x6c
[ 3214.498963]  [<c101a4b0>] ? do_page_fault+0x0/0x240
[ 3214.498972]  [<c12657dc>] ? tcp_xmit_retransmit_queue+0x4c/0x2b0
[ 3214.498982]  [<c1005a0b>] ? xen_restore_fl_direct_end+0x0/0x1
[ 3214.498991]  [<c1260709>] ? tcp_ack+0x7f9/0x10d0
[ 3214.498999]  [<c1031826>] ? local_bh_enable+0x56/0x80
[ 3214.499009]  [<c1288bbd>] ? ipt_do_table+0x2dd/0x590
[ 3214.499017]  [<c1261eef>] ? tcp_rcv_state_process+0x41f/0x970
[ 3214.499025]  [<c1267e7f>] ? tcp_v4_do_rcv+0x8f/0x1e0
[ 3214.499034]  [<c1269ccd>] ? tcp_v4_rcv+0x68d/0x7d0
[ 3214.499044]  [<c124d5f0>] ? ip_local_deliver_finish+0x0/0x1e0
[ 3214.499053]  [<c124d687>] ? ip_local_deliver_finish+0x97/0x1e0
[ 3214.499063]  [<c124d5f0>] ? ip_local_deliver_finish+0x0/0x1e0
[ 3214.499072]  [<c124d3eb>] ? ip_rcv_finish+0x13b/0x340
[ 3214.499079]  [<c124d2b0>] ? ip_rcv_finish+0x0/0x340
[ 3214.499087]  [<c124d8c0>] ? ip_rcv+0x0/0x2e0
[ 3214.499101]  [<c1211037>] ? netif_receive_skb+0x2f7/0x4c0
[ 3214.499115]  [<c1213fe0>] ? process_backlog+0x70/0xb0
[ 3214.499123]  [<c1213d98>] ? net_rx_action+0xe8/0x1a0
[ 3214.499131]  [<c103116d>] ? __do_softirq+0x8d/0x120
[ 3214.499143]  [<c100360d>] ? xen_mc_flush+0xed/0x1a0
[ 3214.499152]  [<c1057891>] ? move_native_irq+0x11/0x50
[ 3214.499160]  [<c1031238>] ? do_softirq+0x38/0x40
[ 3214.499174]  [<c11930e2>] ? xen_evtchn_do_upcall+0x142/0x160
[ 3214.499188]  [<c10087d7>] ? xen_do_upcall+0x7/0xc
[ 3214.499195]  [<c10013a7>] ? hypercall_page+0x3a7/0x1010
[ 3214.499203]  [<c100520f>] ? xen_safe_halt+0xf/0x20
[ 3214.499214]  [<c100349c>] ? xen_idle+0x1c/0x30
[ 3214.499223]  [<c1006bba>] ? cpu_idle+0x3a/0x60
[ 3214.499231]  [<c141692a>] ? start_kernel+0x26a/0x300
[ 3214.499239]  [<c1416280>] ? unknown_bootoption+0x0/0x1c0
[ 3214.499247]  [<c141938e>] ? xen_start_kernel+0x3be/0x3e0
