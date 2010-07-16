From: Felipe W Damasio <felipewd@gmail.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Fri, 16 Jul 2010 12:41:51 -0300
Message-ID: <AANLkTik3Lf9IbgFiagZ-oTDsqzHhhuH2B0DL6PFyZVeV@mail.gmail.com>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
	<AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>
	<1278626921.2435.73.camel@edumazet-laptop>
	<AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com>
	<1278695580.2696.55.camel@edumazet-laptop>
	<AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com>
	<1278742649.2538.17.camel@edumazet-laptop>
	<4C395459.6080407@redhat.com>
	<1278835332.2538.51.camel@edumazet-laptop>
	<AANLkTikEGuFtTlIKUfti6GDsdBz99PpKRCs5lEeEM86u@mail.gmail.com>
	<AANLkTilbEkJWPqvJE72r9HdFQSU84S02BKZB0CH-8QwB@mail.gmail.com>
	<AANLkTimn9x17g-4K7fS4MjmCgzHuBARurEoFVd_gId7m@mail.gmail.com>
	<1279032023.2634.384.camel@edumazet-laptop>
	<AANLkTilrIByt4xAHhsBsKo3nDfv0_c3sF-dCiTiYiPnu@mail.gmail.com>
	<1279036193.2634.468.camel@edumazet-laptop>
	<AANLkTilgxvDPpBJvwbw3PHZfXDaa2_6-TbJ8lujz5y3V@mail.gmail.com>
	<1279077678.2444.95.camel@edumazet-laptop>
	<AANLkTikkcaionMp3SJLgo3JmCjxQ7rPZv3-3_RbxCx_4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikkcaionMp3SJLgo3JmCjxQ7rPZv3-3_RbxCx_4@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

2010/7/14 Felipe W Damasio <felipewd@gmail.com>:
> Hi Mr. Dumazet,
>
> 2010/7/14 Eric Dumazet <eric.dumazet@gmail.com>:
>> RDX being the sk pointer (and sk+0x38 contains the corrupted "sk_pro=
t" value)
>> , we notice RBP contains same "sk" value + 0x200000 =A0(2 Mbytes).
>>
>> (same remark on your initial bug report)
>>
>> Could you enable CONFIG_FRAME_POINTER=3Dy in your config ?

I did, this is the new bug:

general protection fault: 0000 [#1] SMP
last sysfs file: /sys/devices/pci0000:00/0000:00:1f.3/i2c-0/name
CPU 2
Modules linked in: e1000e

Pid: 4209, comm: squid Not tainted 2.6.34 #4 DX58SO/
RIP: 0010:[<ffffffff8137a887>]  [<ffffffff8137a887>] sock_rfree+0x2a/0x=
3c
RSP: 0018:ffff88042d781ba8  EFLAGS: 00010282
RAX: 9a7e7f4602400d48 RBX: ffff88034c918e00 RCX: 0000000000000720
RDX: ffff880413a82e00 RSI: ffff8804161e5e2a RDI: ffff88034c918e00
RBP: ffff88042d781ba8 R08: ffff88042d781b98 R09: 0000000000000000
R10: 0000000000040570 R11: 0000000000000000 R12: ffff880413882e00
R13: 00000000000005a8 R14: 00000000000005a8 R15: 000000000000a84d
=46S:  00007f9aa0007710(0000) GS:ffff880001a80000(0000) knlGS:000000000=
0000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f11f831f020 CR3: 000000042d5f8000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process squid (pid: 4209, threadinfo ffff88042d780000, task ffff88042e3=
25620)
Stack:
 ffff88042d781bc8 ffffffff8137fda0 ffff880413882e00 ffff88034c918e00
<0> ffff88042d781be8 ffffffff8137fb3b ffff88034c918e00 ffff88034c918e00
<0> ffff88042d781cd8 ffffffff813be69b ffff88042d781c38 ffffffff813c76e4
Call Trace:
 [<ffffffff8137fda0>] skb_release_head_state+0x75/0xc0
 [<ffffffff8137fb3b>] __kfree_skb+0x11/0x86
 [<ffffffff813be69b>] tcp_recvmsg+0x6b9/0x8be
 [<ffffffff813c76e4>] ? tcp_current_mss+0x46/0x65
 [<ffffffff8137ab89>] sock_common_recvmsg+0x32/0x47
 [<ffffffff811bafb6>] ? selinux_socket_recvmsg+0x1d/0x1f
 [<ffffffff81378752>] __sock_recvmsg+0x6a/0x76
 [<ffffffff81378847>] sock_aio_read+0xe9/0x102
 [<ffffffff811b9d68>] ? avc_has_perm+0x4e/0x60
 [<ffffffff810b63f6>] do_sync_read+0xc7/0x10d
 [<ffffffff811bdb17>] ? selinux_file_permission+0xa5/0xb2
 [<ffffffff811b7917>] ? security_file_permission+0x11/0x13
 [<ffffffff810b6e7b>] vfs_read+0xbb/0x102
 [<ffffffff810b6f86>] sys_read+0x47/0x70
 [<ffffffff810029eb>] system_call_fastpath+0x16/0x1b
Code: c3 48 8b 57 18 55 8b 87 d8 00 00 00 48 89 e5 48 8d 8a ac 00 00
00 f0 29 82 ac 00 00 00 48 8b 57 18 8b 8f d8 00 00 00 48 8b 42 38 <48>
83 b8 b0 00 00 00 00 74 06 01 8a f4 00 00 00 c9 c3 55 48 89
RIP  [<ffffffff8137a887>] sock_rfree+0x2a/0x3c
 RSP <ffff88042d781ba8>
---[ end trace 8932efc1ba58ce6e ]---

Does this tell you anything?

Cheers,

=46elipe Damasio
