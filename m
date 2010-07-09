From: Felipe W Damasio <felipewd@gmail.com>
Subject: Re: Squid hang up on 2.6.34
Date: Fri, 9 Jul 2010 12:03:56 -0300
Message-ID: <AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
	<AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>
	<1278626921.2435.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278626921.2435.73.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

2010/7/8 Eric Dumazet <eric.dumazet@gmail.com>:
> Please try to reproduce a new report.
>
> It looks like a memory corruption, and it would be good to see if a
> common pattern is occurring.

I'm trying..the thing is the freeze occured on the machine that sits
on a 200Mbps ISP in bridge-mode. Since the machine frooze, and the
whole ISP went down for a few minutes, I'm not allowed to run any
tests on it.

I've setup the same scenario on a lab, but since last night been
unable to reproduce the bug. Maybe there's a clue on the this crash
below that can help me write some program to trigger the problem?

Cheers,

Felipe Damasio

kernel: general protection fault: 0000 [#1] SMP
kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:1f.3/i2c-0/name
kernel: CPU 1
kernel: Modules linked in:

kernel: Pid: 18351, comm: squid Not tainted 2.6.34 #1 DX58SO/
kernel: RIP: 0010:[<ffffffff81360c2a>]  [<ffffffff81360c2a>]
sock_rfree+0x26/0x37
kernel: RSP: 0018:ffff88041c28fc20  EFLAGS: 00010206
kernel: RAX: dce8dce85d415d41 RBX: ffff88038f098c00 RCX: 0000000000000720
kernel: RDX: ffff8804053b2e00 RSI: ffff88032564ee0c RDI: ffff88038f098c00
kernel: RBP: ffff8804051b2e00 R08: 0000000000000000 R09: 0000000000000000
kernel: R10: 0000000000020860 R11: ffff8804051b2e00 R12: 00000000000005a8
kernel: R13: 00000000000005a8 R14: 0000000000003d21 R15: 0000000000000000
kernel: FS:  00007f214fa8c710(0000) GS:ffff880001840000(0000)
knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kernel: CR2: 000000000b388000 CR3: 000000041c4c4000 CR4: 00000000000006e0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
kernel: Process squid (pid: 18351, threadinfo ffff88041c28e000, task
ffff88042e0fcec0)
kernel: Stack:
kernel: ffffffff81365dda ffff88038f098c00 ffffffff81365b8c ffff88038f098c00
kernel: <0> ffffffff813a222a 00000000000000d0 ffffffff81366af9 000000002e0fcec0
kernel: <0> ffff88042e0fcec0 ffff88042e0fcec0 ffff88042e0fcec0 0000000014d31cc0
kernel: Call Trace:
kernel: [<ffffffff81365dda>] ? skb_release_head_state+0x6d/0xb7
kernel: [<ffffffff81365b8c>] ? __kfree_skb+0x9/0x7d
kernel: [<ffffffff813a222a>] ? tcp_recvmsg+0x6a3/0x89a
kernel: [<ffffffff81366af9>] ? __alloc_skb+0x5e/0x14e
kernel: [<ffffffff81360ede>] ? sock_common_recvmsg+0x30/0x45
kernel: [<ffffffff8135ec0f>] ? sock_aio_read+0xdd/0xf1
kernel: [<ffffffff810ac500>] ? do_sync_read+0xb0/0xf2
kernel: [<ffffffff8142a25e>] ? _raw_spin_lock_bh+0x9/0x1f
kernel: [<ffffffff810acf32>] ? vfs_read+0xb9/0xff
kernel: [<ffffffff810ad034>] ? sys_read+0x45/0x6e
kernel: [<ffffffff8100292b>] ? system_call_fastpath+0x16/0x1b
kernel: Code: ff ff ff ff c3 48 8b 57 18 8b 87 d8 00 00 00 48 8d 8a ac
00 00 00 f0 29 82 ac 00 00 00 48 8b 57 18 8b 8f d8 00 00 00 48 8b 42
38 <48> 83 b8 b0 00 00 00 00 74 06 01 8a f4 00 00 00 c3 41 57 41 89
kernel: RIP  [<ffffffff81360c2a>] sock_rfree+0x26/0x37
kernel: RSP <ffff88041c28fc20>
kernel: ---[ end trace bcd320fe508cc071 ]---
