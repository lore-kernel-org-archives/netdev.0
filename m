From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: [BUG] icmpv6fuzz creates bad paging request
Date: Thu, 1 Jan 2009 21:13:04 +0100
Message-ID: <20090101201304.GA6698@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:48374 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750741AbZAAUNL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2009 15:13:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

running "icmpv6fuzz -r 2187" gives me the following oops with current -=
git


[ 4320.851654] BUG: unable to handle kernel paging request at c9527000
[ 4320.851749] IP: [<c04e5668>] __copy_from_user_ll+0x8c/0xd8
[ 4320.851898] *pde =3D 0001f067 *pte =3D 09527160=20
[ 4320.851977] Oops: 0002 [#1] PREEMPT DEBUG_PAGEALLOC
[ 4320.852011] last sysfs file: /sys/devices/pci0000:00/0000:00:01.0/00=
00:01:00.0/resource
[ 4320.852011] Modules linked in:
[ 4320.852011]=20
[ 4320.852011] Pid: 5065, comm: icmpv6fuzz Tainted: G        W  (2.6.28=
-04928-g6a94cb7 #152) System Name
[ 4320.852011] EIP: 0060:[<c04e5668>] EFLAGS: 00010202 CPU: 0
[ 4320.852011] EIP is at __copy_from_user_ll+0x8c/0xd8
[ 4320.852011] EAX: 00000000 EBX: 4b17b3d7 ECX: 4b1782d7 EDX: 00000000
[ 4320.852011] ESI: 097d5f24 EDI: c9526fc8 EBP: c9523da0 ESP: c9523d98
[ 4320.852011]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[ 4320.852011] Process icmpv6fuzz (pid: 5065, ti=3Dc9523000 task=3Dcee1=
5b00 task.ti=3Dc9523000)
[ 4320.852011] Stack:
[ 4320.852011]  c9523ec8 097d2e24 c9523db4 c04e5907 00000000 c9523ec8 c=
ee431fc c9523f1c
[ 4320.852011]  c06fd4db 00000032 cee42f00 00000000 cee15b00 00000002 0=
0000000 00000000
[ 4320.852011]  c951ea64 cee15b00 00000002 00000000 00000000 c951ea64 c=
ee15b00 00000246
[ 4320.852011] Call Trace:
[ 4320.852011]  [<c04e5907>] ? copy_from_user+0x36/0x59
[ 4320.852011]  [<c06fd4db>] ? ipv6_setsockopt+0x4ed/0xb8e
[ 4320.852011]  [<c017c674>] ? might_fault+0x42/0x7e
[ 4320.852011]  [<c04e5b25>] ? copy_to_user+0x38/0x43
[ 4320.852011]  [<c01421d1>] ? print_lock_contention_bug+0x11/0xb2
[ 4320.852011]  [<c0143f37>] ? trace_hardirqs_on+0xb/0xd
[ 4320.852011] Code: 1c 8b 46 20 8b 56 24 89 47 20 89 57 24 8b 46 28 8b=
 56 2c 89 47 28 89 57 2c 8b 46 30 8b 56 34 89 47 30 89 57 34 8b 46 38 8=
b 56 3c <89> 47 38 89 57 3c 83 c1 c0 83 c6 40 83 c7 40 83 f9 3f 77 88 8=
9=20
[ 4320.852011] EIP: [<c04e5668>] __copy_from_user_ll+0x8c/0xd8 SS:ESP 0=
068:c9523d98
[ 4320.852011] ---[ end trace 4eaa2a86a8e2da22 ]---
[ 4320.868860] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[ 4320.868910] BUG fs_cache: Redzone overwritten
[ 4320.868938] --------------------------------------------------------=
---------------------
[ 4320.868943]=20
[ 4320.868991] INFO: 0xc9525138-0xc952513b. First byte 0x0 instead of 0=
xbb
[ 4320.869012] INFO: Slab 0xc12bd4a0 objects=3D32 used=3D4 fp=3D0xc9525=
100 flags=3D0x400000c3
[ 4320.869012] INFO: Object 0xc9525100 @offset=3D256 fp=3D0x00000000
[ 4320.869012]=20
[ 4320.869012] Bytes b4 0xc95250f0:  00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00 ................
[ 4320.869012]   Object 0xc9525100:  00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00 ................
[ 4320.869012]   Object 0xc9525110:  00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00 ................
[ 4320.869012]   Object 0xc9525120:  00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00 ................
[ 4320.869012]   Object 0xc9525130:  00 00 00 00 00 00 00 00           =
              ........       =20
[ 4320.869012]  Redzone 0xc9525138:  00 00 00 00                       =
              ....           =20
[ 4320.869012]  Padding 0xc9525160:  00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00 ................
[ 4320.869012]  Padding 0xc9525170:  00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00 ................
[ 4320.869012] Pid: 4096, comm: syslogd Tainted: G      D W  2.6.28-049=
28-g6a94cb7 #152
[ 4320.869012] Call Trace:
[ 4320.869012]  [<c018ca58>] print_trailer+0xcd/0xd5
[ 4320.869012]  [<c018cad8>] check_bytes_and_report+0x78/0x94
[ 4320.869012]  [<c018ccf7>] check_object+0x49/0x191
[ 4320.869012]  [<c018da8b>] __slab_alloc+0x446/0x508
[ 4320.869012]  [<c079f416>] ? _spin_unlock+0x2c/0x41
[ 4320.869012]  [<c018de1e>] ? kmem_cache_alloc+0x4a/0xea
[ 4320.869012]  [<c018de50>] kmem_cache_alloc+0x7c/0xea
[ 4320.869012]  [<c0124231>] ? __copy_fs_struct+0x1c/0x80
[ 4320.869012]  [<c0124231>] ? __copy_fs_struct+0x1c/0x80
[ 4320.869012]  [<c0124231>] __copy_fs_struct+0x1c/0x80
[ 4320.869012]  [<c0124ed1>] copy_process+0x631/0xfe9
[ 4320.869012]  [<c0143f37>] ? trace_hardirqs_on+0xb/0xd
[ 4320.869012]  [<c01259e9>] do_fork+0x121/0x2b8
[ 4320.869012]  [<c04e54f0>] ? trace_hardirqs_on_thunk+0xc/0x10
[ 4320.869012]  [<c0102ecf>] ? sysenter_exit+0xf/0x16
[ 4320.869012]  [<c01015c8>] sys_clone+0x24/0x26
[ 4320.869012]  [<c0102ea1>] sysenter_do_call+0x12/0x31
[ 4320.869012] FIX fs_cache: Restoring 0xc9525138-0xc952513b=3D0xbb
[ 4320.869012]=20
[ 4320.869012] FIX fs_cache: Marking all objects used
[ 4328.729876] BUG: unable to handle kernel NULL pointer dereference at=
 0000002c
[ 4328.730066] IP: [<c01c5021>] dnotify_flush+0x16/0x79
[ 4328.730159] *pde =3D 00000000=20
[ 4328.730231] Oops: 0000 [#2] PREEMPT DEBUG_PAGEALLOC
[ 4328.730332] last sysfs file: /sys/devices/pci0000:00/0000:00:01.0/00=
00:01:00.0/resource
[ 4328.730434] Modules linked in:
[ 4328.730486]=20
[ 4328.730518] Pid: 5058, comm: kerneloops Tainted: G      D W  (2.6.28=
-04928-g6a94cb7 #152) System Name
[ 4328.730611] EIP: 0060:[<c01c5021>] EFLAGS: 00010282 CPU: 0
[ 4328.730644] EIP is at dnotify_flush+0x16/0x79
[ 4328.730675] EAX: 00000000 EBX: c9524300 ECX: c01902e4 EDX: cf89f600
[ 4328.730706] ESI: cf89f600 EDI: c9524300 EBP: c94f8f84 ESP: c94f8f70
[ 4328.730797]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[ 4328.730829] Process kerneloops (pid: 5058, ti=3Dc94f8000 task=3Dc941=
6800 task.ti=3Dc94f8000)
[ 4328.730860] Stack:
[ 4328.730887]  cf89f600 00000001 c9524300 cf89f600 00000000 c94f8f98 c=
0190267 cf89f600
[ 4328.731033]  00000003 c9524300 c94f8fb0 c01902ed cf89f624 00000003 0=
0000003 ffffffff
[ 4328.731033]  c94f8000 c0102ea1 00000003 b7ef6174 b801aff4 00000003 f=
fffffff bf8625a8
[ 4328.731033] Call Trace:
[ 4328.731033]  [<c0190267>] ? filp_close+0x45/0x5f
[ 4328.731033]  [<c01902ed>] ? sys_close+0x6c/0xa5
[ 4328.731033]  [<c0102ea1>] ? sysenter_do_call+0x12/0x31
[ 4328.731033] Code: 89 d8 e8 e7 a6 fd ff eb 07 89 f0 e8 e4 a3 5d 00 5b=
 5e 5f 5d c3 55 89 e5 57 56 53 83 ec 08 0f 1f 44 00 00 89 55 ec 89 c7 8=
b 40 0c <8b> 70 2c 0f b7 46 6e 25 00 f0 00 00 3d 00 40 00 00 75 49 8d 4=
6=20
[ 4328.731033] EIP: [<c01c5021>] dnotify_flush+0x16/0x79 SS:ESP 0068:c9=
4f8f70
[ 4328.735123] ---[ end trace 4eaa2a86a8e2da22 ]---
[ 4328.735274] Bad page state in process 'kerneloops'
[ 4328.735278] page:c11b5f80 flags:0x40000400 mapping:00000000 mapcount=
:0 count:0
[ 4328.735348] Trying to fix it up, but a reboot is needed
[ 4328.735352] Backtrace:
[ 4328.735420] Pid: 5058, comm: kerneloops Tainted: G      D W  2.6.28-=
04928-g6a94cb7 #152
[ 4328.735451] Call Trace:
[ 4328.735504]  [<c0171ea8>] bad_page+0x4d/0x78
[ 4328.735541]  [<c01725e5>] free_hot_cold_page+0xa3/0x20a
[ 4328.735592]  [<c017279a>] free_hot_page+0xf/0x11
[ 4328.735632]  [<c017568b>] put_page+0xc2/0xc7
[ 4328.735694]  [<c0183fa2>] free_page_and_swap_cache+0x36/0x3c
[ 4328.735744]  [<c011888f>] __pte_free_tlb+0x2d/0x2f
[ 4328.735805]  [<c017c58d>] free_pgd_range+0x139/0x151
[ 4328.735849]  [<c0400000>] ? ocfs2_merge_rec_left+0x19f/0xc29
[ 4328.735902]  [<c017c963>] free_pgtables+0x8c/0x9a
[ 4328.735937]  [<c017e407>] exit_mmap+0x9c/0x104
[ 4328.736002]  [<c01244f8>] mmput+0x39/0x89
[ 4328.736075]  [<c012791e>] exit_mm+0xc3/0xcb
[ 4328.736112]  [<c0128bd9>] do_exit+0x199/0x6d5
[ 4328.736163]  [<c0127102>] ? printk+0x1a/0x1c
[ 4328.736197]  [<c01262e8>] ? print_oops_end_marker+0x23/0x28
[ 4328.736261]  [<c07a01a1>] oops_end+0x95/0x9d
[ 4328.736302]  [<c0104ffe>] die+0x58/0x5e
[ 4328.736356]  [<c07a1447>] do_page_fault+0x538/0x601
[ 4328.736392]  [<c07a0f0f>] ? do_page_fault+0x0/0x601
[ 4328.736443]  [<c079f7ef>] error_code+0x6f/0x74
[ 4328.736481]  [<c01902e4>] ? sys_close+0x63/0xa5
[ 4328.736533]  [<c01c5021>] ? dnotify_flush+0x16/0x79
[ 4328.736569]  [<c0190267>] filp_close+0x45/0x5f
[ 4328.736620]  [<c01902ed>] sys_close+0x6c/0xa5
[ 4328.736655]  [<c0102ea1>] sysenter_do_call+0x12/0x31


(gdb) l *(ipv6_setsockopt+0x4ed)
0xc06fd677 is in ipv6_setsockopt (net/ipv6/ipv6_sockglue.c:407).
402			if (optlen =3D=3D 0)
403				goto e_inval;
404			else if (optlen < sizeof(struct in6_pktinfo) || optval =3D=3D NUL=
L)
405				goto e_inval;
406=09
407			if (copy_from_user(&pkt, optval, optlen)) {
408					retv =3D -EFAULT;
409					break;
410			}
411			if (sk->sk_bound_dev_if && pkt.ipi6_ifindex !=3D sk->sk_bound_dev=
_if)



I can reproduce this on another box:

[ 2139.689945] BUG: unable to handle kernel paging request at c7d78000
[ 2139.690390] IP: [<c05ad652>] iret_exc+0x7a6/0xb04
[ 2139.690707] Oops: 0002 [#1] DEBUG_PAGEALLOC
[ 2139.690914] last sysfs file: /sys/block/sda/size
[ 2139.691096] Modules linked in: nfsd exportfs nfs lockd nfs_acl auth_=
rpcgss sunrpc ipv6 fuse unix
[ 2139.691976]=20
[ 2139.692046] Pid: 4182, comm: icmpv6fuzz Not tainted (2.6.28 #77)=20
[ 2139.692046] EIP: 0060:[<c05ad652>] EFLAGS: 00010246 CPU: 0
[ 2139.692046] EIP is at iret_exc+0x7a6/0xb04
[ 2139.692046] EAX: 00000000 EBX: 4b17b3d7 ECX: 4b13f27b EDX: 00000000
[ 2139.692046] ESI: 09a8e000 EDI: c7d78000 EBP: c7d3bd78 ESP: c7d3bd64
[ 2139.692046]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[ 2139.692046] Process icmpv6fuzz (pid: 4182, ti=3Dc7d3b000 task=3Dc8f7=
8710 task.ti=3Dc7d3b000)
[ 2139.692046] Stack:
[ 2139.692046]  00000003 4b15e1f3 c7d3bea4 09a70e1c 00000032 c7d3bef8 d=
1893f7d c7d854a0
[ 2139.692046]  c7d3bed4 c011afd9 c011afd9 c7b7ecb0 c8f7d2c7 c7b7ef70 0=
0000000 00000000
[ 2139.692046]  00000002 00000316 000003be 00000000 c8f78728 c8f78acc c=
8f78710 00000001
[ 2139.692046] Call Trace:
[ 2139.692046]  [<d1893f7d>] ? do_ipv6_setsockopt+0x95d/0xe90 [ipv6]
[ 2139.692046]  [<c011afd9>] ? do_page_fault+0x249/0x7d0
[ 2139.692046]  [<c011afd9>] ? do_page_fault+0x249/0x7d0
[ 2139.692046]  [<c014e82c>] ? __lock_acquire+0x26c/0x1110
[ 2139.692046]  [<c014e82c>] ? __lock_acquire+0x26c/0x1110
[ 2139.692046]  [<c014e82c>] ? __lock_acquire+0x26c/0x1110
[ 2139.692046]  [<c014e321>] ? trace_hardirqs_on_caller+0x151/0x1c0
[ 2139.692046] Code: f3 aa 58 59 e9 2e 24 cf ff 01 c1 e9 81 24 cf ff 8d=
 0c 88 e9 79 24 cf ff 8d 0c 88 e9 27 25 cf ff 01 c1 eb 03 8d 0c 88 51 5=
0 31 c0 <f3> aa 58 59 e9 81 25 cf ff 8d 0c 88 51 50 31 c0 f3 aa 58 59 e=
9=20
[ 2139.692046] EIP: [<c05ad652>] iret_exc+0x7a6/0xb04 SS:ESP 0068:c7d3b=
d64
[ 2139.692046] ---[ end trace 1503b93caf7b40a5 ]---
[ 2139.703551] BUG: unable to handle kernel NULL pointer dereference at=
 00000008
[ 2139.703841] IP: [<c029c346>] rb_insert_color+0x46/0x110
[ 2139.704079] *pde =3D 00000000=20
[ 2139.704224] Oops: 0000 [#2] DEBUG_PAGEALLOC
[ 2139.704479] last sysfs file: /sys/block/sda/size
[ 2139.704597] Modules linked in: nfsd exportfs nfs lockd nfs_acl auth_=
rpcgss sunrpc ipv6 fuse unix
[ 2139.705470]=20
[ 2139.705568] Pid: 4182, comm: icmpv6fuzz Tainted: G      D    (2.6.28=
 #77)=20
[ 2139.705764] EIP: 0060:[<c029c346>] EFLAGS: 00010046 CPU: 0
[ 2139.705894] EIP is at rb_insert_color+0x46/0x110
[ 2139.706018] EAX: 00000000 EBX: c7d4aaf8 ECX: 304bfe00 EDX: 00000000
[ 2139.706151] ESI: c7d4aafc EDI: 00000000 EBP: c0901f20 ESP: c0901f08
[ 2139.706341]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[ 2139.706469] Process icmpv6fuzz (pid: 4182, ti=3Dc0901000 task=3Dc8f7=
8710 task.ti=3Dc7d3b000)
[ 2139.706647] Stack:
[ 2139.706744]  c0836e30 c09367a0 00000000 c09367a0 c7d4aafc 00000000 c=
0901f68 c0140950
[ 2139.707329]  00000000 00000002 00000001 c0836e30 00000000 c0836e28 c=
7d4aaf8 c09367a0
[ 2139.707530]  c0836e28 c0901f68 c05ac55a 00000000 00000002 00000001 c=
09367a0 c0836e28
[ 2139.707530] Call Trace:
[ 2139.707530]  [<c0140950>] ? enqueue_hrtimer+0x90/0x180
[ 2139.707530]  [<c05ac55a>] ? _spin_lock+0x3a/0x40
[ 2139.707530]  [<c0140ae1>] ? __run_hrtimer+0xa1/0xe0
[ 2139.707530]  [<c0149a10>] ? tick_sched_timer+0x0/0xc0
[ 2139.707530]  [<c014128d>] ? hrtimer_interrupt+0xed/0x190
[ 2139.707530]  [<c01059cb>] ? timer_interrupt+0x3b/0x50
[ 2139.707530]  [<c016a779>] ? handle_IRQ_event+0x29/0x60
[ 2139.707530]  [<c016c505>] ? handle_level_irq+0x65/0xe0
[ 2139.707530]  [<c016c4a0>] ? handle_level_irq+0x0/0xe0
[ 2139.707530]  <IRQ> <0> [<c0103bac>] ? common_interrupt+0x2c/0x34
[ 2139.707530]  [<c05ac3b4>] ? _spin_unlock_irq+0x24/0x30
[ 2139.707530]  [<c015fa86>] ? acct_collect+0x126/0x170
[ 2139.707530]  [<c012caf6>] ? do_exit+0x606/0x800
[ 2139.707530]  [<c032e2f7>] ? set_cursor+0x57/0x80
[ 2139.707530]  [<c05a99f6>] ? printk+0x18/0x1a
[ 2139.707530]  [<c01294ff>] ? oops_exit+0x2f/0x40
[ 2139.707530]  [<c0106432>] ? oops_end+0x92/0xa0
[ 2139.707530]  [<c01065f0>] ? die+0x50/0x70
[ 2139.707530]  [<c011b04a>] ? do_page_fault+0x2ba/0x7d0
[ 2139.707530]  [<c014e82c>] ? __lock_acquire+0x26c/0x1110
[ 2139.707530]  [<c010d5ba>] ? save_stack_trace+0x2a/0x50
[ 2139.707530]  [<c014e82c>] ? __lock_acquire+0x26c/0x1110
[ 2139.707530]  [<c011ad90>] ? do_page_fault+0x0/0x7d0
[ 2139.707530]  [<c05ac9f7>] ? error_code+0x6f/0x74
[ 2139.707530]  [<c0290000>] ? sg_io+0x2d0/0x360
[ 2139.707530]  [<c05ad652>] ? iret_exc+0x7a6/0xb04
[ 2139.707530]  [<d1893f7d>] ? do_ipv6_setsockopt+0x95d/0xe90 [ipv6]
[ 2139.707530]  [<c011afd9>] ? do_page_fault+0x249/0x7d0
[ 2139.707530]  [<c011afd9>] ? do_page_fault+0x249/0x7d0
[ 2139.707530]  [<c014e82c>] ? __lock_acquire+0x26c/0x1110
[ 2139.707530]  [<c014e82c>] ? __lock_acquire+0x26c/0x1110
[ 2139.707530]  [<c014e82c>] ? __lock_acquire+0x26c/0x1110
[ 2139.707530]  [<c014e321>] ? trace_hardirqs_on_caller+0x151/0x1c0
[ 2139.707530] Code: 89 06 83 0b 01 8b 55 f0 83 22 fe 89 d6 89 75 ec 8b=
 55 ec 8b 02 89 c3 83 e3 fc 74 71 8b 13 f6 c2 01 75 6a 89 d0 83 e0 fc 8=
9 45 f0 <8b> 70 08 39 de 74 33 85 f6 74 06 8b 06 a8 01 74 c1 8b 7b 08 3=
b=20
[ 2139.707530] EIP: [<c029c346>] rb_insert_color+0x46/0x110 SS:ESP 0068=
:c0901f08
[ 2139.707530] ---[ end trace 1503b93caf7b40a5 ]---
[ 2139.707530] Kernel panic - not syncing: Fatal exception in interrupt



Here is the fuzzer, original website seems currently down

Greetings, Eric

-------------------------------8<-----------------------
/*
 * ICMPv6 or ICMPv4 socket fuzzer.
 *
 * Copyright (c) 2006, Cl=C3=A9ment Lecigne
 */
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/param.h>
#include <net/if.h>
//#include <net/if_var.h>
#include <sys/uio.h>
//#include <netinet6/ip6_mroute.h>
//#include <netinet6/in6_var.h>


#define SIOCGETMIFCNT_IN6       SIOCPROTOPRIVATE        /* IP protocol =
privates */
#define SIOCGETSGCNT_IN6        (SIOCPROTOPRIVATE+1)
#define SIOCGETRPF      (SIOCPROTOPRIVATE+2)


/* functions */
unsigned int randaddr(void);
void randsoopt(int);
void randgoopt(int);
void randioctl(int);
void usage(char *);

/*
* boucle until we hit a valid socket option
*/
void randsoopt(int sock)
{
	unsigned int optval;
	int optlen, optname, level, ret, on =3D rand() % 2;
	do
	{
		switch (rand() % 5)
		{
			case 0:
				level =3D IPPROTO_IPV6;
				break;
			case 1:
				level =3D SOL_SOCKET;
				break;
			case 2:
				level =3D IPPROTO_RAW;
				break;
			case 3:
				level =3D rand() & 0xFF;
				break;
			case 4:
				level =3D IPPROTO_IP;
				break;
		}
	=09
		if (rand() % 6)
		{
			optlen =3D rand();
			optval =3D (unsigned int)randaddr();
		}
		else
		{
		/*=20
			* In some cases, kernel excepts that
			* optlen =3D=3D sizeof (int) and that's
			* the first bound checking.
			*/
			optlen =3D sizeof (int);
			on =3D rand();
			optval =3D (unsigned int)&on;
		}
	=09
		if (rand() % 8)
			optname =3D rand() % 255;
		else
			optname =3D rand();
#if 0
		/*
		 * anti well know FreeBSD mbufs exhaustion.
		 */
		if (optname =3D=3D 25 || optname =3D=3D IPV6_IPSEC_POLICY ||=20
				optname =3D=3D IPV6_FW_ADD || optname =3D=3D IPV6_FW_FLUSH
				|| optname =3D=3D IPV6_FW_DEL || optname =3D=3D IPV6_FW_ZERO)
			continue;
		/*printf("level : %d - optname : %d - optlen : %d\n",=20
				level, optname, optlen);*/
#endif
		ret =3D setsockopt(sock, level, optname, (void *)optval, optlen);

	}while(ret =3D=3D -1);
	return;
}


/*
* ioctl ipv6 socket fuzzer.
*/
void randioctl(int sock)
{
	unsigned long reqs[] =3D { SIOCGETSGCNT_IN6, SIOCGETMIFCNT_IN6,
		SIOCGETRPF};
/*
		GSCOPE6DEF, SIOCGLIFADDR, SIOCSIFPHYADDR_IN6, SIOCGIFNETMASK_IN6,
		SIOCAIFADDR_IN6, SIOCGIFDSTADDR_IN6, SIOCSIFALIFETIME_IN6,=20
		SIOCGIFADDR_IN6, SIOCGIFDSTADDR_IN6, SIOCGIFNETMASK_IN6, SIOCGIFAFLAG=
_IN6,
		SIOCGIFSTAT_IN6, SIOCGIFSTAT_ICMP6, SIOCGIFALIFETIME_IN6, SIOCSIFALIF=
ETIME_IN6,
		SIOCAIFADDR_IN6, SIOCDIFADDR_IN6 }; */
	unsigned int arg;
	int ret;
	unsigned long request;
=09
	if (rand() % 8)
		request =3D reqs[rand() % (sizeof (reqs) / sizeof (reqs[0]))];
	else
		request =3D rand() + rand();
	if (rand() % 2)
	{
		arg =3D randaddr();
		ret =3D ioctl(sock, request, (caddr_t)arg);
	}
	else
	{
		arg =3D rand();
		ret =3D ioctl(sock, request, (int)arg);
	}
}


/*
* return a random address
*/
unsigned int randaddr(void)
{
	char *p =3D malloc(1);
	unsigned int heap =3D (unsigned int)p;
	free(p);
	switch (rand() % 4)
	{
		case 0:
			return (heap + (rand() & 0xFFF));
		case 1:
			return ((unsigned int)&heap + (rand() & 0xFFF));
		case 2:
			return (0xc0000000 + (rand() & 0xFFFF));
		case 3:
			return (rand());
	}
	return (0);
}


int main(int ac, char **av)=20
{
	int32_t cc, s, occ, i, j, a, try, count, opts;
	u_int32_t seed, maxsize;
	u_int8_t ip6;
	char c, *buf;
	struct addrinfo *res, hints;
	struct sockaddr_in6 from;
	socklen_t fromlen;
	struct msghdr msg;
	struct cmsghdr *cmsg =3D NULL;
	struct iovec iov;
=09
	/* default values */
	seed =3D getpid();
	count =3D 50;
	occ =3D 10000;
	maxsize =3D 4096;
	opts =3D 50;
	ip6 =3D 1;
	fromlen =3D sizeof(from);
=09
	if (getuid())
	{
		fprintf(stderr, " - you must be root.\n");
		exit(EXIT_FAILURE);
	}
=09
	while ((c =3D getopt(ac, av, "r:n:c:m:o:46")) !=3D EOF)
	{
		switch (c)
		{
			case '6':
				ip6 =3D 1;
				break;
			case '4':
				ip6 =3D 0;
				break;
			case 'r':
				seed =3D atoi(optarg);
				break;
			case 'n':
				occ =3D atoi(optarg);
				break;
			case 'c':
				count =3D atoi(optarg);
				break;
			case 'm':
				maxsize =3D atoi(optarg);
				break;
			case 'o':
				opts =3D atoi(optarg);
				break;
			default:
				usage(av[0]);
				break;
		}
	}
=09
	printf("seeding with %u\n", seed);
	srand(seed);

	buf =3D malloc(maxsize);
	if (buf =3D=3D NULL)
	{
		printf("%s: out of memory.\n", av[0]);
		exit(EXIT_FAILURE);
	}

	memset(&hints, 0, sizeof(hints));
	hints.ai_flags =3D AI_CANONNAME;
	hints.ai_socktype =3D SOCK_RAW;
=09
	if(ip6)
	{
		hints.ai_family =3D AF_INET6;
		hints.ai_protocol =3D IPPROTO_ICMPV6;
		getaddrinfo("::1", NULL, &hints, &res);=20
	}
	else
	{
		hints.ai_family =3D AF_INET;
		hints.ai_protocol =3D IPPROTO_ICMP;
		getaddrinfo("127.0.0.1", NULL, &hints, &res);
	}

	for (i =3D 0; i < occ; i++)
	{
		printf(".\n");
		s =3D socket(res->ai_family, res->ai_socktype, res->ai_protocol);
		//cc =3D bind(s, res->ai_addr, res->ai_addrlen);


		for (j =3D 0; j < opts; j++)
		{
			randsoopt(s);
			//randgoopt(s);
			randioctl(s);

			for (a =3D 0; a < 32; a++)
				buf[a] =3D rand() % 255;

			try =3D 0;
			do
			{
				switch(rand() % 3)
				{
				case 0:
					cc =3D sendto(s, buf, rand() % maxsize, 0,
							(struct sockaddr *)res->ai_addr, res->ai_addrlen);
					break;
				case 1:
				case 2:
					msg.msg_controllen =3D (rand() % 2) ? rand() & maxsize : 0;
					if (msg.msg_controllen)
					{
						if (msg.msg_controllen < sizeof (struct cmsghdr))
							cmsg =3D (struct cmsghdr *)malloc(sizeof (struct cmsghdr));
						else
							cmsg =3D (struct cmsghdr *)malloc(msg.msg_controllen);
						if (cmsg =3D=3D NULL) goto nocmsghdr;
						msg.msg_control =3D cmsg;
						cmsg->cmsg_level =3D (rand() % 2) ? IPPROTO_IPV6 : rand();
						cmsg->cmsg_type =3D (rand() % 2) ? rand() % 255 : rand();
						cmsg->cmsg_len =3D (rand() % 2) ? msg.msg_controllen : rand();
					}
					else
					{
nocmsghdr:
						msg.msg_control =3D (rand() % 5) ? NULL : (void*)randaddr();
						msg.msg_controllen =3D (rand() % 2) ? rand() : 0;
					}
					iov.iov_len =3D (rand() % 2) ? rand() : rand() & maxsize;
					iov.iov_base =3D (rand() % 2) ? (void*)randaddr() : &buf;
					msg.msg_iov =3D (rand() % 2) ? (void*)randaddr() : &iov;
					if (rand() % 5)
					{
						msg.msg_name =3D res->ai_addr;
						msg.msg_namelen =3D res->ai_addrlen;
					}
					else
					{
						msg.msg_name =3D (caddr_t)randaddr();
						msg.msg_namelen =3D rand();
					}
					msg.msg_flags =3D rand();
					cc =3D sendmsg (s, &msg, rand());
				}
				if (cmsg !=3D NULL)
				{=09
				//	free(cmsg);
				//	cmsg =3D NULL;
				}
				try++;
			} while(cc =3D=3D -1 && try !=3D count);=20
			recvmsg(s, &msg, MSG_DONTWAIT);
		}
		close(s);
	}
	free(buf);
	freeaddrinfo(res);
	exit(EXIT_SUCCESS);
}

/*=20
* usage
*/
void usage(char *prog)
{
	printf("usage: %s [-4] [-6] [-r seed] [-c sendto-timeout]\n"
		"          [-m maxsize] [-o maxsetsockopt] [-n occ]\n", prog);
	exit(EXIT_FAILURE);
}
