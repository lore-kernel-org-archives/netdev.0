From: Holger Schurig <holgerschurig@gmail.com>
Subject: [BUG 4.4-rc4]: oops around sock_recvmsg
Date: Thu, 07 Jan 2016 09:58:14 +0100
Message-ID: <87d1td6a1l.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38638 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbcAGI6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 03:58:18 -0500
Received: by mail-wm0-f44.google.com with SMTP id b14so112028403wmb.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 00:58:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Background: Kernel was 4.4-rc4, machine was an arm-based i.MX6 one.
System load was some artificial test bench where a Java program was
doing heavy network and CAN code (network and CAN are both the i.MX6
built-in stuff). That test program manages to generate 11000 context
switches per second, for example.

This oops with sock_recvmsg() inside it now happened 3 times, just not
at my test box, only at one very remote from me. That's also the reason
why the log is truncated, the people that grabbed it from Windows with
Putty over the serial line just did give this to me ... :-(

BTW, are several places with "???" below. Is this just a "grabbing from
Windows" artifact? Or an indication that the processor/memory of the
system got completely insane?



[<c03e7964>] (wait_for_completion) from [<c005f9c8>] (__wait_rcu_gp+0xe0/0x108)
[<c005f8e8>] (__wait_rcu_gp) from [<c0062510>] (synchronize_rcu+0x4c/0x5c)
r10:00000000 r9:ee9d6c08 r8:ef100000 r7:00000020 r6:eea98444 r5:ef100000
r4:eea98400
[<c00624c4>] (synchronize_rcu) from [<c02cb234>] (evdev_release+0x84/0xe0)
[<c02cb1b0>] (evdev_release) from [<c00c1218>] (__fput+0xe0/0x1b4)
r8:ef3f0910 r7:ecc68660 r6:00000008 r5:ee1ec028 r4:ee9d6c00 r3:c02cb1b0
[<c00c1138>] (__fput) from [<c00c1350>] (____fput+0x10/0x14)
r10:00000020 r9:ee9d4e38 r8:00000001 r7:ed9a9a58 r6:ee281540 r5:ed9b48ac
r4:ed9b4440
[<c00c1340>] (____fput) from [<c00353a4>] (task_work_run+0xa4/0xbc)
[<c0035300>] (task_work_run) from [<c001fc70>] (do_exit+0x370/0x810)
r6:ed9b48bc r5:ee9d4e00 r4:ed9b4440 r3:000000d8
[<c001f900>] (do_exit) from [<c0012c28>] (die+0x2c0/0x404)
r7:ed9a9a93
[<c0012968>] (die) from [<c001b4d0>] (__do_kernel_fault.part.0+0x5c/0x1ec)
r10:c0037790 r9:ee9d4e00 r8:80000007 r7:ed9a9bf8 r6:ee9d4e00 r5:80000007
r4:fffffffe
[<c001b474>] (__do_kernel_fault.part.0) from [<c0017438>] (do_page_fault+0x274/0x28c)
r7:ed9a9bf8 r3:ed9a9bf8
[<c00171c4>] (do_page_fault) from [<c000934c>] (do_PrefetchAbort+0x3c/0xa0)
r10:c0037790 r9:00000001 r8:00000001 r7:ed9a9bf8 r6:fffffffe r5:c055fbc4
r4:00000007
[<c0009310>] (do_PrefetchAbort) from [<c001354c>] (__pabt_svc+0x4c/0x80)
Exception stack(0xed9a9bf8 to 0xed9a9c40)
9be0:?????????????????????????????????????????????????????? ebaa3d18 00000001
9c00: 00000001 00000304 ee1c2c04 fffffff3 00000001 00000304 00000001 00000001
9c20: c0037790 ed9a9c74 ffffffff ed9a9c48 c004febc fffffffe 800100b3 ffffffff
r7:ed9a9c2c r6:ffffffff r5:800100b3 r4:fffffffe
[<c004fe68>] (__wake_up_common) from [<c00504ac>] (__wake_up_sync_key+0x4c/0x60)
r10:00000000 r9:00000010 r8:00000304 r7:00000001 r6:00000001 r5:a0010013
r4:ee1c2c00 r3:00000001
[<c0050460>] (__wake_up_sync_key) from [<c03cf9d0>] (unix_write_space+0x60/0x90)
r8:ed9a9df4 r7:eb9decc0 r6:ed95d5e4 r5:ed95f02c r4:ed95ef80
[<c03cf970>] (unix_write_space) from [<c0347674>] (sock_wfree+0x4c/0x84)
r4:ed95ef80 r3:c03cf970
[<c0347628>] (sock_wfree) from [<c03cf2b8>] (unix_destruct_scm+0x6c/0x74)
r5:00000000 r4:eb9decc0
[<c03cf24c>] (unix_destruct_scm) from [<c0348768>] (skb_release_head_state+0x70/0xb0)
r4:eb9decc0
[<c03486f8>] (skb_release_head_state) from [<c034b280>] (skb_release_all+0x14/0x2c)
r4:eb9decc0 r3:00000001
[<c034b26c>] (skb_release_all) from [<c034b2ac>] (__kfree_skb+0x14/0x94)
r4:eb9decc0 r3:00000001
[<c034b298>] (__kfree_skb) from [<c034b610>] (consume_skb+0x58/0x5c)
r4:ed95d400 r3:00000001
[<c034b5b8>] (consume_skb) from [<c03d050c>] (unix_stream_read_generic+0x5ec/0x750)
[<c03cff20>] (unix_stream_read_generic) from [<c03d0754>] (unix_stream_recvmsg+0x50/0x5c)
r10:ecc13800 r9:ed9a9e88 r8:bee12988 r7:00000040 r6:ecc13800 r5:ed9a9f4c
r4:00001000
[<c03d0704>] (unix_stream_recvmsg) from [<c0341250>] (sock_recvmsg+0x18/0x1c)
r7:bee1296c r6:00000040 r5:00000000 r4:ed9a9f4c
[<c0341238>] (sock_recvmsg) from [<c0342fa0>] (___sys_recvmsg+0x98/0x170)
[<c0342f08>] (___sys_recvmsg) from [<c0343d34>] (__sys_recvmsg+0x44/0x68)
r10:00000000 r9:ed9a8000 r8:c000f1e4 r7:00000129 r6:bee1296c r5:00000000
r4:ecc13800
[<c0343cf0>] (__sys_recvmsg) from [<c0343d68>] (SyS_recvmsg+0x10/0x14)
r6:b6f7df10 r5:81196c08 r4:bee12988
[<c0343d58>] (SyS_recvmsg) from [<c000f020>] (ret_fast_syscall+0x0/0x3c)
Xorg??????????? D c03e6c58???? 0?? 368??? 367 0x00000004
Backtrace:
[<c03e68a0>] (__schedule) from [<c03e6e94>] (schedule+0xb0/0xcc)
r10:c0064090 r9:00000000 r8:ed9a8000 r7:00000002 r6:ed9a99a4 r5:7fffffff
r4:ed9a8000 r3:00000001
[<c03e6de4>] (schedule) from [<c03e9804>] (schedule_timeout+0x20/0x180)
r4:7fffffff r3:00000004
[<c03e97e4>] (schedule_timeout) from [<c03e7924>] (wait_for_common+0x118/0x158)
r8:ed9a8000 r7:00000002 r6:ed9a99a4 r5:7fffffff r4:ed9a99a0
[<c03e780c>] (wait_for_common) from [<c03e797c>] (wait_for_completion+0x18/0x1c)
r9:00000000 r8:00000001 r7:ed9a9994 r6:ed9a99a0 r5:c0064050 r4:00000000
[<c03e7964>] (wait_for_completion) from [<c005f9c8>] (__wait_rcu_gp+0xe0/0x108)
[<c005f8e8>] (__wait_rcu_gp) from [<c0062510>] (synchronize_rcu+0x4c/0x5c)
r10:00000000 r9:ee9d6c08 r8:ef100000 r7:00000020 r6:eea98444 r5:ef100000
r4:eea98400
[<c00624c4>] (synchronize_rcu) from [<c02cb234>] (evdev_release+0x84/0xe0)
[<c02cb1b0>] (evdev_release) from [<c00c1218>] (__fput+0xe0/0x1b4)
r8:ef3f0910 r7:ecc68660 r6:00000008 r5:ee1ec028 r4:ee9d6c00 r3:c02cb1b0
