From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: networking oops after resume from s2ram (2.6.28-rc6)
Date: Fri, 28 Nov 2008 22:15:40 +0100
Message-ID: <20081128211538.GA6750@joi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:27608 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbYK1VP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 16:15:57 -0500
Received: by ug-out-1314.google.com with SMTP id 39so2085379ugf.37
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2008 13:15:55 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Sometimes after resume from s2ram networking doesn't work, so I restart it by
/etc/init.d/net.eth1 restart. Recently it started to lock up my box completely,
but today it oopsed only (and killed my keyboard, so I had to save dmesg with
mouse :D).

It looks like it tries to use netconsole without working network interface...

[ 1621.013789] BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
[ 1621.013793] IP: [<ffffffff803f5db9>] skge_xmit_frame+0xb8/0x3ba
[ 1621.013802] PGD 16880067 PUD 16894067 PMD 0 
[ 1621.013806] Oops: 0000 [#1] PREEMPT 
[ 1621.013808] last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
[ 1621.013812] Dumping ftrace buffer:
[ 1621.013814]    (ftrace buffer empty)
[ 1621.013816] CPU 0 
[ 1621.013819] Pid: 6725, comm: ip Not tainted 2.6.28-rc6-stack+mode #51
[ 1621.013821] RIP: 0010:[<ffffffff803f5db9>]  [<ffffffff803f5db9>] skge_xmit_frame+0xb8/0x3ba
[ 1621.013825] RSP: 0018:ffff8800168c38b8  EFLAGS: 00010006
[ 1621.013827] RAX: 000000000000007f RBX: ffff88003e9c7090 RCX: 0000000000000001
[ 1621.013829] RDX: 0000000000000001 RSI: ffff88003e8b2840 RDI: ffff88003e95d700
[ 1621.013832] RBP: ffff8800168c3918 R08: 0000000000000002 R09: 0000000000000000
[ 1621.013834] R10: 0000000000000006 R11: 0000000000000000 R12: ffff88003e95d700
[ 1621.013836] R13: ffff88003e9c7090 R14: 0000000000000000 R15: 0000000000000001
[ 1621.013838] FS:  00007f47e467f6f0(0000) GS:ffffffff80738180(0000) knlGS:0000000000000000
[ 1621.013841] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1621.013843] CR2: 0000000000000000 CR3: 000000001689a000 CR4: 00000000000006e0
[ 1621.013845] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1621.013847] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1621.013850] Process ip (pid: 6725, threadinfo ffff8800168c2000, task ffff88001688da30)
[ 1621.013851] Stack:
[ 1621.013853]  ffff880026921800 0000000080737c20 ffff88003e8b2000 ffff88003e8b2840
[ 1621.013856]  ffff88003e87cf00 ffff88003e8b2000 0000000000000000 ffff88003e9ec120
[ 1621.013860]  0000000000000082 ffff88003e8b2000 0000000000000000 0000000000000001
[ 1621.013864] Call Trace:
[ 1621.013866]  [<ffffffff804f5a28>] netpoll_send_skb+0xcd/0x196
[ 1621.013871]  [<ffffffff804f5fe7>] netpoll_send_udp+0x202/0x20e
[ 1621.013874]  [<ffffffff80400081>] write_msg+0x80/0xbf
[ 1621.013879]  [<ffffffff8023220d>] __call_console_drivers+0x58/0x69
[ 1621.013884]  [<ffffffff8023227f>] _call_console_drivers+0x61/0x66
[ 1621.013887]  [<ffffffff802323b5>] release_console_sem+0x131/0x1d4
[ 1621.013890]  [<ffffffff80232a08>] vprintk+0x389/0x3b8
[ 1621.013894]  [<ffffffff80232a9e>] printk+0x67/0x69
[ 1621.013897]  [<ffffffff804e7785>] ? dev_set_rx_mode+0x19/0x2e
[ 1621.013902]  [<ffffffff80252e95>] ? __lock_acquire+0x6dd/0x73b
[ 1621.013905]  [<ffffffff80251379>] ? mark_held_locks+0x52/0x72
[ 1621.013908]  [<ffffffff802361f5>] ? local_bh_enable_ip+0xba/0xd6
[ 1621.013912]  [<ffffffff803f2a07>] skge_up+0x7c/0x88a
[ 1621.013916]  [<ffffffff804e7795>] ? dev_set_rx_mode+0x29/0x2e
[ 1621.013920]  [<ffffffff802361f5>] ? local_bh_enable_ip+0xba/0xd6
[ 1621.013923]  [<ffffffff804eb050>] dev_open+0x72/0xa6
[ 1621.013926]  [<ffffffff804e9211>] dev_change_flags+0xa8/0x167
[ 1621.013929]  [<ffffffff80527683>] devinet_ioctl+0x26a/0x5df
[ 1621.013933]  [<ffffffff8052845a>] inet_ioctl+0x92/0xaa
[ 1621.013936]  [<ffffffff804de260>] sock_ioctl+0x18c/0x1b8
[ 1621.013939]  [<ffffffff8029ed28>] vfs_ioctl+0x2a/0x77
[ 1621.013943]  [<ffffffff8029f110>] do_vfs_ioctl+0x39b/0x3e5
[ 1621.013946]  [<ffffffff802479ad>] ? up_read+0x26/0x2b
[ 1621.013950]  [<ffffffff8020b36c>] ? sysret_check+0x27/0x62
[ 1621.013953]  [<ffffffff8029f19c>] sys_ioctl+0x42/0x65
[ 1621.013956]  [<ffffffff8020b33b>] system_call_fastpath+0x16/0x1b
[ 1621.013960] Code: 48 c1 f8 03 0f b7 52 04 69 c0 cd cc cc cc 8d 44 30 ff ff c2 39 d0 0f 8c 00 03 00 00 48 8b 75 b8 4c 8b ae 98 00 00 00 4d 8b 75 08 <41> 83 3e 00 79 04 0f 0b eb fe 4d 89 65 10 41 8b 44 24 68 45 31 
[ 1621.013988] RIP  [<ffffffff803f5db9>] skge_xmit_frame+0xb8/0x3ba
[ 1621.013991]  RSP <ffff8800168c38b8>
[ 1621.013993] CR2: 0000000000000000
[ 1621.013995] ---[ end trace 50a82573cfe89df3 ]---
[ 1621.013998] note: ip[6725] exited with preempt_count 3

Full demsg and config can be found at:
http://www.kadu.net/~joi/kernel/2008.11.28/skge-net.oops/

Marcin
