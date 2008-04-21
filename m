From: "Andrew Paprocki" <andrew@ishiboo.com>
Subject: Re: kernel BUG at /usr/src/linux-2.6.25/kernel/workqueue.c:224! (r8169?)
Date: Sun, 20 Apr 2008 23:16:28 -0400
Message-ID: <76366b180804202016l19ac362cyb814781449f81e9a@mail.gmail.com>
References: <76366b180804201548g309ae6cci286ed6552f3cb71e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shuchen@realtek.com.tw, "Francois Romieu" <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:13393 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754521AbYDUDQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 23:16:29 -0400
Received: by py-out-1112.google.com with SMTP id u52so2362950pyb.10
        for <netdev@vger.kernel.org>; Sun, 20 Apr 2008 20:16:28 -0700 (PDT)
In-Reply-To: <76366b180804201548g309ae6cci286ed6552f3cb71e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just received a similar bug on workqueue.c:223 while I was not doing
anything with the card. These bugs seem to have increased with
frequency when running under 2.6.25. It used to take me some time to
cause a problem to appear under 2.6.24, but under 2.6.25 they appear
very readily. I was actually not touching the machine at all when this
appeared on the console:

r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
------------[ cut here ]------------
kernel BUG at /usr/src/linux-2.6.25/kernel/workqueue.c:223!
invalid opcode: 0000 [#1]

Pid: 4, comm: events/0 Not tainted (2.6.25 #2)
EIP: 0060:[<c0223446>] EFLAGS: 00010286 CPU: 0
EIP is at queue_delayed_work_on+0x1c/0x7b
EAX: 00000000 EBX: cf0ae9f0 ECX: cf0ae9e0 EDX: 00000000
ESI: cf002840 EDI: ffffffff EBP: cf0ae360 ESP: cf037ea4
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process events/0 (pid: 4, ti=cf036000 task=cf02e590 task.ti=cf036000)
Stack: cf0b7400 cf0ae000 cf0ae360 c02234cb 00000004 c037a1a5 d002e03e 00000050
       00000014 d002e000 d002e03e d002e000 cf1d6000 cf0f8400 c2b00157 cf1c9c80
       00000080 00000001 0000000a c0230811 c0537ae0 0000000a 00000000 0000000a
Call Trace:
 [<c02234cb>] queue_delayed_work+0x16/0x18
 [<c037a1a5>] rtl8169_interrupt+0x1bb/0x2ef
 [<c0230811>] handle_IRQ_event+0x1a/0x3f
 [<c023176c>] handle_level_irq+0x7a/0x8a
 [<c02064d4>] do_IRQ+0x4b/0x60
 [<c0204fbf>] common_interrupt+0x23/0x28
 [<c0300000>] elevator_init+0x5a/0xcd
 [<c0247e68>] kfree+0x6a/0x6e
 [<c041060c>] __kfree_skb+0x8/0x61
 [<c0379d55>] rtl8169_rx_clear+0x1f/0x48
 [<c037a48f>] rtl8169_close+0x13/0x67
 [<c037b21e>] rtl8169_reinit_task+0x25/0x64
 [<c037b1f9>] rtl8169_reinit_task+0x0/0x64
 [<c0222fef>] run_workqueue+0x63/0xca
 [<c02234db>] worker_thread+0x0/0xb7
 [<c0223587>] worker_thread+0xac/0xb7
 [<c02253e9>] autoremove_wake_function+0x0/0x2b
 [<c02234db>] worker_thread+0x0/0xb7
 [<c022528f>] kthread+0x36/0x5b
 [<c0225259>] kthread+0x0/0x5b
 [<c020512f>] kernel_thread_helper+0x7/0x10
 =======================
Code: 8d 50 10 e9 46 ff ff ff 31 d2 e9 3f ff ff ff 57 89 c7 56 89 d6 53 8d 59 1
EIP: [<c0223446>] queue_delayed_work_on+0x1c/0x7b SS:ESP 0068:cf037ea4
Kernel panic - not syncing: Fatal exception in interrupt



On Sun, Apr 20, 2008 at 6:48 PM, Andrew Paprocki <andrew@ishiboo.com> wrote:
> I received this while testing the network card on a AMD Geode LX800 board.
>  (cat /dev/zero | nc remote-host remote-port) The machine config is attached.
>
>  ------------[ cut here ]------------
>  kernel BUG at /usr/src/linux-2.6.25/kernel/workqueue.c:224!
>  invalid opcode: 0000 [#1]
>
>  Pid: 719, comm: nc Not tainted (2.6.25 #2)
>  EIP: 0060:[<c0223452>] EFLAGS: 00010283 CPU: 0
>  EIP is at queue_delayed_work_on+0x28/0x7b
>  EAX: cf0ae9e4 EBX: cf0ae9f0 ECX: cf0ae9e0 EDX: 00000000
>  ESI: cf002840 EDI: ffffffff EBP: cf0ae360 ESP: cc07fd08
>   DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
>  Process nc (pid: 719, ti=cc07e000 task=ce7b73f0 task.ti=cc07e000)
>  Stack: cf059400 cf0ae000 cf0ae360 c02234cb 00000004 c037a1a5 d002e03e 00000050
>        00000014 d002e000 d002e03e d002e000 cf0cc000 cf0f8400 c2b00157 cf1c9c80
>        00000080 00000001 0000000a c0230811 c0537ae0 0000000a 00000000 0000000a
>  Call Trace:
>   [<c02234cb>] queue_delayed_work+0x16/0x18
>   [<c037a1a5>] rtl8169_interrupt+0x1bb/0x2ef
>   [<c0230811>] handle_IRQ_event+0x1a/0x3f
>   [<c023176c>] handle_level_irq+0x7a/0x8a
>   [<c02064d4>] do_IRQ+0x4b/0x60
>   [<c0204fbf>] common_interrupt+0x23/0x28
>   [<c0430000>] tcp_recvmsg+0x475/0x6cc
>   [<c043631d>] tcp_rcv_established+0x42/0x611
>   [<c043af07>] tcp_v4_do_rcv+0x1f/0x13f
>   [<c040dac1>] release_sock+0x30/0x6c
>   [<c042fab3>] tcp_sendmsg+0x896/0x96e
>   [<c021438e>] __wake_up_common+0x2d/0x52
>   [<c040ba02>] sock_aio_write+0xb2/0xbb
>   [<c024a72d>] do_sync_write+0xbd/0x104
>   [<c02253e9>] autoremove_wake_function+0x0/0x2b
>   [<c0227a03>] ktime_get_ts+0x11/0x3a
>   [<c0227a3b>] ktime_get+0xf/0x2b
>   [<c02151ae>] hrtick_start_fair+0xb3/0xec
>   [<c024ae31>] vfs_write+0x94/0xfc
>   [<c024b280>] sys_write+0x3c/0x63
>   [<c0204616>] syscall_call+0x7/0xb
>   =======================
>  Code: ff ff ff 57 89 c7 56 89 d6 53 8d 59 10 0f ba 29 00 19 c0 31 d2 85 c0 75 5
>  EIP: [<c0223452>] queue_delayed_work_on+0x28/0x7b SS:ESP 0068:cc07fd08
>  Kernel panic - not syncing: Fatal exception in interrupt
>
