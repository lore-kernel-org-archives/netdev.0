From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: UNIX sockets kernel panic
Date: Thu, 6 Nov 2008 04:13:19 +0300
Message-ID: <20081106011319.GA22389@x200.localdomain>
References: <20081106001445.GA5595@shorty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: a.bittau@cs.ucl.ac.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:42206 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbYKFBKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 20:10:12 -0500
Received: by ug-out-1314.google.com with SMTP id 39so690674ugf.37
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2008 17:10:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081106001445.GA5595@shorty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 06, 2008 at 12:14:46AM +0000, Andrea Bittau wrote:
> The following code causes a kernel panic on Linux 2.6.26:
> http://darkircop.org/unix.c
> 
> I haven't investigated the bug so I'm not sure what is causing it, and
> don't know if it's exploitable.  The code passes unix sockets from one
> process to another using unix sockets.  The bug probably has to do with
> closing file descriptors.

Aie, nice localhost DoS (random oopses)

BUG: unable to handle kernel paging request at ffff880827feb448
IP: [<ffffffff8022191a>] cfs_rq_of+0x19/0x27
PGD 202063 PUD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/kernel/uevent_seqnum
CPU 0 
Pid: 20940, comm: unix Not tainted 2.6.28-rc3 #2
RIP: 0010:[<ffffffff8022191a>]  [<ffffffff8022191a>] cfs_rq_of+0x19/0x27
RSP: 0018:ffff88017dbd3d08  EFLAGS: 00010046
RAX: ffffffff80505940 RBX: ffff88017f94ad90 RCX: 00000000ffff8801
RDX: ffff880028027440 RSI: ffff88002802f9d8 RDI: ffff88017f94adc8
RBP: ffff88017dbd3d08 R08: ffff88002802f9d8 R09: ffff88002802f9b0
R10: 0000000000000000 R11: 0000000000000001 R12: ffff88002802f940
R13: 0000000000000001 R14: ffff88017dbd3d88 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffffffff804b2540(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff880827feb448 CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process unix (pid: 20940, threadinfo ffff88017dbd2000, task ffff88017f94ad90)
Stack:
 ffff88017dbd3d28 ffffffff80224b4b ffff88017f87d5d0 ffff88002802f940
 ffff88017dbd3d48 ffffffff80221ada 0000000000000000 ffff88002802f940
 ffff88017dbd3d68 ffffffff80221b69 ffff88017dbd3d88 ffff88017f87d5d0
Call Trace:
 [<ffffffff80224b4b>] hrtick_update+0x24/0x3f
 [<ffffffff80221ada>] enqueue_task+0x13/0x1e
 [<ffffffff80221b69>] activate_task+0x22/0x2a
 [<ffffffff80224f4b>] try_to_wake_up+0xf9/0x162
 [<ffffffff80233816>] signal_wake_up+0x2b/0x3e
 [<ffffffff80233ada>] ? send_signal+0x166/0x182
 [<ffffffff80235392>] ? do_notify_parent+0x16c/0x19b
 [<ffffffff8027baa2>] ? mntput_no_expire+0x20/0x103
 [<ffffffff80222719>] ? need_resched+0x1e/0x28
 [<ffffffff8027baa2>] ? mntput_no_expire+0x20/0x103
 [<ffffffff8022d5af>] ? do_exit+0x491/0x6cb
 [<ffffffff8022d878>] ? sys_exit_group+0x0/0xe
 [<ffffffff8020b305>] ? tracesys+0xd0/0xd5
Code: 0d 0e 29 00 48 8b 14 ca 48 03 42 08 c9 48 83 c0 70 c3 48 8b 57 d0 55 48 c7 c0 40 59 50 80 48 89 e5 8b 4a 1c 48 8b 15 e6 0d 29 00 <48> 8b 14 ca 48 03 42 08 c9 48 83 c0 70 c3 48 8b 47 50 48 8b 4f 
RIP  [<ffffffff8022191a>] cfs_rq_of+0x19/0x27
 RSP <ffff88017dbd3d08>
CR2: ffff880827feb448
Kernel panic - not syncing: Fatal exception in interrupt
