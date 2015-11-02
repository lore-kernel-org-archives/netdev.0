From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: kernel panic in 4.2.3, rb_erase in sch_fq
Date: Mon, 02 Nov 2015 16:11:54 +0200
Message-ID: <d66d455afe6dd28bed32ed3e17f797b7@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:42572 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413AbbKBOME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 09:12:04 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 9362E481EFF
	for <netdev@vger.kernel.org>; Mon,  2 Nov 2015 16:12:00 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Actually seems i was getting this panic for a while (once per week) on 
loaded pppoe server, but just now was able to get full panic message.
After checking commit logs on sch_fq.c i didnt seen any fixes, so 
probably upgrading to newer kernel wont help?


<remote> [237470.633382] general protection fault: 0000 [#1]
<remote> SMP
<remote>
<remote> [237470.633832] Modules linked in:
<remote> netconsole
<remote> configfs
<remote> act_skbedit
<remote> sch_fq
<remote> cls_fw
<remote> act_police
<remote> cls_u32
<remote> sch_ingress
<remote> sch_sfq
<remote> sch_htb
<remote> pppoe
<remote> pppox
<remote> ppp_generic
<remote> slhc
<remote> xt_nat
<remote> ts_bm
<remote> xt_string
<remote> xt_connmark
<remote> xt_TCPMSS
<remote> xt_tcpudp
<remote> xt_mark
<remote> iptable_filter
<remote> iptable_nat
<remote> nf_conntrack_ipv4
<remote> nf_defrag_ipv4
<remote> nf_nat_ipv4
<remote> nf_nat
<remote> nf_conntrack
<remote> iptable_mangle
<remote> ip_tables
<remote> x_tables
<remote> 8021q
<remote> garp
<remote> mrp
<remote> stp
<remote> llc
<remote>
<remote> [237470.637835] CPU: 1 PID: 14035 Comm: accel-pppd Not tainted 
4.2.3-build-0087 #3
<remote> [237470.638342] Hardware name: Intel Corporation 
S2600GZ/S2600GZ, BIOS SE5C600.86B.01.03.0002.062020121504 06/20/2012
<remote> [237470.638859] task: ffff8803ef8b5080 ti: ffff8803ed7e0000 
task.ti: ffff8803ed7e0000
<remote> [237470.639370] RIP: 0010:[<ffffffff8125af5d>]
<remote> [<ffffffff8125af5d>] rb_erase+0x37/0x2c4
<remote> [237470.639960] RSP: 0018:ffff8803ed7e3b88  EFLAGS: 00010286
<remote> [237470.644863] RAX: 0000000000000000 RBX: ffff8804106ab000 
RCX: 0000000000000001
<remote> [237470.645366] RDX: ffa2050402210218 RSI: ffff88040cfe2cf0 
RDI: ffff8803f50d00e0
<remote> [237470.645872] RBP: ffff8803ed7e3b88 R08: 0000000000000000 
R09: ffff88042ee37d50
<remote> [237470.646376] R10: ffffea000fe7a9c0 R11: 0000000094f1b850 
R12: 000000000000019e
<remote> [237470.646881] R13: ffff88040cfe2cf0 R14: ffff8803f50d00d0 
R15: 0000000000000000
<remote> [237470.647381] FS:  00007fcd5d384700(0000) 
GS:ffff88042ee20000(0000) knlGS:0000000000000000
<remote> [237470.647889] CS:  0010 DS: 0000 ES: 0000 CR0: 
0000000080050033
<remote> [237470.648209] CR2: 00007fcd003efa90 CR3: 0000000424b6e000 
CR4: 00000000000406e0
<remote> [237470.648707] Stack:
<remote> [237470.648990]  ffff8803ed7e3bb8
<remote> ffffffffa00ef38b
<remote> ffff8804106ab000
<remote> ffff880416079000
<remote>
<remote> [237470.649791]  0000000000000002
<remote> ffff8804160790d8
<remote> ffff8803ed7e3bd8
<remote> ffffffff8183785c
<remote>
<remote> [237470.650589]  0000000000000002
<remote> ffff8800b021d000
<remote> ffff8803ed7e3c18
<remote> ffffffffa00d247a
<remote>
<remote> [237470.651387] Call Trace:
<remote> [237470.651716]  [<ffffffffa00ef38b>] fq_reset+0x7a/0xf2 
[sch_fq]
<remote> [237470.652084]  [<ffffffff8183785c>] qdisc_reset+0x18/0x42
<remote> [237470.652444]  [<ffffffffa00d247a>] htb_reset+0x96/0x14d 
[sch_htb]
<remote> [237470.652780]  [<ffffffff8183785c>] qdisc_reset+0x18/0x42
<remote> [237470.653146]  [<ffffffff81837e3d>] 
dev_deactivate_queue.constprop.34+0x43/0x53
<remote> [237470.653726]  [<ffffffff81838543>] 
dev_deactivate_many+0x53/0x206
<remote> [237470.654088]  [<ffffffff81819ce2>] 
__dev_close_many+0x73/0xbf
<remote> [237470.654436]  [<ffffffff81819e5d>] __dev_close+0x2c/0x41
<remote> [237470.654784]  [<ffffffff818a5569>] ? 
_raw_spin_unlock_bh+0x15/0x17
<remote> [237470.655106]  [<ffffffff8181ff25>] 
__dev_change_flags+0xa5/0x13c
<remote> [237470.655427]  [<ffffffff8181ffdf>] 
dev_change_flags+0x23/0x59
<remote> [237470.655777]  [<ffffffff818a437b>] ? mutex_lock+0x13/0x24
<remote> [237470.656073]  [<ffffffff81874197>] devinet_ioctl+0x246/0x533
<remote> [237470.656372]  [<ffffffff8187572d>] inet_ioctl+0x8c/0xa6
<remote> [237470.656667]  [<ffffffff81807e06>] sock_do_ioctl+0x22/0x40
<remote> [237470.656960]  [<ffffffff81808016>] sock_ioctl+0x1f2/0x200
<remote> [237470.657253]  [<ffffffff8115f5b5>] do_vfs_ioctl+0x360/0x41a
<remote> [237470.657549]  [<ffffffff81151989>] ? vfs_write+0x105/0x164
<remote> [237470.657841]  [<ffffffff8115f6a8>] SyS_ioctl+0x39/0x61
<remote> [237470.658134]  [<ffffffff818a591b>] 
entry_SYSCALL_64_fastpath+0x16/0x6e
<remote> [237470.658431] Code:
<remote> 48
<remote> 85
<remote> c0
<remote> 75
<remote> 36
<remote> 48
<remote> 8b
<remote> 0f
<remote> 48
<remote> 89
<remote> c8
<remote> 48
<remote> 83
<remote> e0
<remote> fc
<remote> 74
<remote> 12
<remote> 48
<remote> 39
<remote> 78
<remote> 10
<remote> 75
<remote> 06
<remote> 48
<remote> 89
<remote> 50
<remote> 10
<remote> eb
<remote> 09
<remote> 48
<remote> 89
<remote> 50
<remote> 08
<remote> eb
<remote> 03
<remote> 48
<remote> 89
<remote> 16
<remote> 48
<remote> 85
<remote> d2
<remote> 74
<remote> 08
<remote>
<remote> 89
<remote> 0a
<remote> e9
<remote> 83
<remote> 02
<remote> 00
<remote> 00
<remote> 80
<remote> e1
<remote> 01
<remote> e9
<remote> c3
<remote> 00
<remote> 00
<remote> 00
<remote> 48
<remote> 85
<remote> d2
<remote> 75
<remote> 2c
<remote>
<remote> [237470.663930] RIP
<remote> [<ffffffff8125af5d>] rb_erase+0x37/0x2c4
<remote> [237470.664296]  RSP <ffff8803ed7e3b88>
<remote> [237470.664598] ---[ end trace 32ea40a7de450892 ]---
<remote> [237470.673272] Kernel panic - not syncing: Fatal exception in 
interrupt
<remote> [237470.673577] Kernel Offset: disabled
<remote> [237470.704654] Rebooting in 5 seconds..
