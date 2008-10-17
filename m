From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: 2.6.27-05178-g2e532d6: list_add corruption
Date: Fri, 17 Oct 2008 23:20:28 +0400
Message-ID: <a4423d670810171220t4d5602fekcb66e18758149925@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>,
	"Kernel Testers List" <kernel-testers@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:36602 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755176AbYJQTUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 15:20:30 -0400
Received: by gxk9 with SMTP id 9so1591652gxk.13
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2008 12:20:28 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am afraid I do not know how to reproduce this.

WARNING: at lib/list_debug.c:30 __list_add+0x44/0x5c()
list_add corruption. prev->next should be next (f6638448), but was
f26f078c. (prev=f26f078c).
Modules linked in: w83627hf hwmon_vid i2c_nforce2
Pid: 1933, comm: rtorrent Not tainted 2.6.27-05178-g2e532d6 #6
Call Trace:
 [<c011de4b>] warn_slowpath+0x4b/0x69
 [<c0137a03>] ? trace_hardirqs_off+0xb/0xd
 [<c01070ab>] ? native_sched_clock+0x76/0x88
 [<c0138cc5>] ? trace_hardirqs_on+0xb/0xd
 [<c0138c93>] ? trace_hardirqs_on_caller+0xe6/0x10d
 [<c031aa43>] ? release_sock+0xac/0xb4
 [<c0138cc5>] ? trace_hardirqs_on+0xb/0xd
 [<c0139d4e>] ? __lock_acquire+0xaeb/0xafa
 [<c0139d4e>] ? __lock_acquire+0xaeb/0xafa
 [<c0137a39>] ? put_lock_stats+0xd/0x21
 [<c026a404>] __list_add+0x44/0x5c
 [<c0186be0>] ep_poll_callback+0x5b/0xb4
 [<c011735b>] __wake_up_common+0x35/0x5b
 [<c0117c6d>] __wake_up_sync+0x31/0x44
 [<c031ae39>] sock_def_readable+0x38/0x63
 [<c03467eb>] tcp_rcv_established+0x37c/0x49d
 [<c034c2cc>] tcp_v4_do_rcv+0x25/0x151
 [<c0386269>] ? _spin_lock_nested+0x51/0x59
 [<c034c6e9>] tcp_v4_rcv+0x2f1/0x4a2
 [<c0336a65>] ip_local_deliver+0x86/0xd6
 [<c03369c1>] ip_rcv+0x361/0x37f
 [<c0322ad7>] netif_receive_skb+0x1af/0x1cf
 [<c02e5892>] nv_napi_poll+0x201/0x4f8
 [<c0138cc5>] ? trace_hardirqs_on+0xb/0xd
 [<c03217f0>] net_rx_action+0x98/0x155
 [<c0121d94>] __do_softirq+0x6a/0xf1
 [<c0121e4a>] do_softirq+0x2f/0x47
 [<c0121fb9>] irq_exit+0x3b/0x84
 [<c01046fb>] do_IRQ+0x6d/0x82
 [<c01038d0>] common_interrupt+0x28/0x30
---[ end trace 71f919bde0b515ac ]---
------------[ cut here ]------------
WARNING: at lib/list_debug.c:30 __list_add+0x44/0x5c()
list_add corruption. prev->next should be next (f6638448), but was
f26f078c. (prev=f26f078c).
Modules linked in: w83627hf hwmon_vid i2c_nforce2
Pid: 1933, comm: rtorrent Tainted: G        W 2.6.27-05178-g2e532d6 #6
Call Trace:
 [<c011de4b>] warn_slowpath+0x4b/0x69
 [<c0160063>] ? shmem_writepage+0x147/0x1ad
 [<c0139de8>] ? print_lock_contention_bug+0x14/0xd7
 [<c0138cc5>] ? trace_hardirqs_on+0xb/0xd
 [<c0137a39>] ? put_lock_stats+0xd/0x21
 [<c026a404>] __list_add+0x44/0x5c
 [<c0187600>] sys_epoll_ctl+0x36f/0x405
 [<c0137a03>] ? trace_hardirqs_off+0xb/0xd
 [<c0102ea9>] sysenter_do_call+0x12/0x35
---[ end trace 71f919bde0b515ac ]---
------------[ cut here ]------------
WARNING: at lib/list_debug.c:30 __list_add+0x44/0x5c()
list_add corruption. prev->next should be next (f6638448), but was
f26e4a8c. (prev=f26e4a8c).
Modules linked in: w83627hf hwmon_vid i2c_nforce2
Pid: 1933, comm: rtorrent Tainted: G        W 2.6.27-05178-g2e532d6 #6
Call Trace:
 [<c011de4b>] warn_slowpath+0x4b/0x69
 [<c0138cc5>] ? trace_hardirqs_on+0xb/0xd
 [<c0321890>] ? net_rx_action+0x138/0x155
 [<c0121d28>] ? _local_bh_enable+0x86/0x88
 [<c0137a39>] ? put_lock_stats+0xd/0x21
 [<c026a404>] __list_add+0x44/0x5c
 [<c0187600>] sys_epoll_ctl+0x36f/0x405
 [<c0102ea9>] sysenter_do_call+0x12/0x35
---[ end trace 71f919bde0b515ac ]---
------------[ cut here ]------------
WARNING: at lib/list_debug.c:30 __list_add+0x44/0x5c()
list_add corruption. prev->next should be next (f6638448), but was
f26e4a8c. (prev=f26e4a8c).
Modules linked in: w83627hf hwmon_vid i2c_nforce2
Pid: 1933, comm: rtorrent Tainted: G        W 2.6.27-05178-g2e532d6 #6
Call Trace:
 [<c011de4b>] warn_slowpath+0x4b/0x69
 [<c0138cc5>] ? trace_hardirqs_on+0xb/0xd
 [<c0321890>] ? net_rx_action+0x138/0x155
 [<c0121d28>] ? _local_bh_enable+0x86/0x88
 [<c0137a39>] ? put_lock_stats+0xd/0x21
 [<c026a404>] __list_add+0x44/0x5c
 [<c0187600>] sys_epoll_ctl+0x36f/0x405
 [<c0102ea9>] sysenter_do_call+0x12/0x35
---[ end trace 71f919bde0b515ac ]---
BUG: unable to handle kernel paging request at 6b6b6b7b
IP: [<c0187068>] sys_epoll_wait+0x24c/0x3c2
*pde = 00000000
Oops: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/devices/platform/w83627hf.656/name
Modules linked in: w83627hf hwmon_vid i2c_nforce2

Pid: 1933, comm: rtorrent Tainted: G        W (2.6.27-05178-g2e532d6 #6)
EIP: 0060:[<c0187068>] EFLAGS: 00010246 CPU: 0
EIP is at sys_epoll_wait+0x24c/0x3c2
EAX: 6b6b6b6b EBX: f26e4a8c ECX: f673e000 EDX: 00000000
ESI: f26e4a80 EDI: f6638390 EBP: f673ffb0 ESP: f673ff4c
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process rtorrent (pid: 1933, ti=f673e000 task=f6735100 task.ti=f673e000)
Stack:
 f673ff9c c0176bda 00000000 f670ef00 f6638418 0000000b f6638448 f6638440
 f26e4a8c f6638420 f66383f8 00000008 f66383b0 f673ff94 c025db74 f673ff9c
 bfbed370 00000000 f673ffb0 bfbed370 f673ff9c f673ff9c 00000006 00000022
Call Trace:
 [<c0176bda>] ? mntput_no_expire+0x16/0xb4
 [<c025db74>] ? copy_to_user+0x36/0x106
 [<c0102ea9>] ? sysenter_do_call+0x12/0x35
Code: c7 45 a4 00 00 00 00 e9 8e 00 00 00 8b 75 bc 83 ee 0c 8b 56 0c
8b 46 10 89 42 04 89 10 8b 55 bc 8b 46 18 89 56 0c 89 56 10 31 d2 <8b>
48 10 ff 51 1c 8b 5e 38 21 d8 89 5d c8 89 45 d0 74 3f 6b 45
EIP: [<c0187068>] sys_epoll_wait+0x24c/0x3c2 SS:ESP 0068:f673ff4c
