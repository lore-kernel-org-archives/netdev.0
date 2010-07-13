From: Felipe W Damasio <felipewd@gmail.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Tue, 13 Jul 2010 17:55:39 -0300
Message-ID: <AANLkTilgxvDPpBJvwbw3PHZfXDaa2_6-TbJ8lujz5y3V@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1279036193.2634.468.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mr. Dumazet,

I used the patched kernel on the production machine and squid frooze ag=
ain.

This is the dmesg message:


general protection fault: 0000 [#1] SMP
last sysfs file: /sys/devices/pci0000:00/0000:00:1f.3/i2c-0/name
CPU 1
Modules linked in:

Pid: 5533, comm: squid Not tainted 2.6.34 #6 DX58SO/
RIP: 0010:[<ffffffff81369b2a>]  [<ffffffff81369b2a>] sock_rfree+0x26/0x=
37
RSP: 0018:ffff88042287fc20  EFLAGS: 00010206
RAX: 66c86f938964c696 RBX: ffff88034e8f9a00 RCX: 0000000000000720
RDX: ffff8803f0ce05c0 RSI: ffff8803d441960c RDI: ffff88034e8f9a00
RBP: ffff8803f0ee05c0 R08: ffffea000dcb9998 R09: 0000000000000000
R10: 000000000003d830 R11: ffff8803f0ee05c0 R12: 00000000000005a8
R13: 00000000000005a8 R14: 0000000000004378 R15: 0000000000000000
=46S:  00007f4cf33ee710(0000) GS:ffff880001840000(0000) knlGS:000000000=
0000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000021d5fd0 CR3: 0000000422872000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process squid (pid: 5533, threadinfo ffff88042287e000, task ffff88042eb=
61a40)
Stack:
 ffffffff8136ecda ffff88034e8f9a00 ffffffff8136ea8c ffff88034e8f9a00
<0> ffffffff813ab142 00000000000000d0 ffffffff8136f9f9 000000000eec60e2
<0> ffff88042eb61a40 ffff88042eb61a40 ffff88042eb61a40 00000000edca7300
Call Trace:
 [<ffffffff8136ecda>] ? skb_release_head_state+0x6d/0xb7
 [<ffffffff8136ea8c>] ? __kfree_skb+0x9/0x7d
 [<ffffffff813ab142>] ? tcp_recvmsg+0x6a3/0x89a
 [<ffffffff8136f9f9>] ? __alloc_skb+0x5e/0x14e
 [<ffffffff81369dde>] ? sock_common_recvmsg+0x30/0x45
 [<ffffffff81367b0f>] ? sock_aio_read+0xdd/0xf1
 [<ffffffff813b6c97>] ? tcp_write_xmit+0x93e/0x96c
 [<ffffffff810ac500>] ? do_sync_read+0xb0/0xf2
 [<ffffffff810acf32>] ? vfs_read+0xb9/0xff
 [<ffffffff810ad034>] ? sys_read+0x45/0x6e
 [<ffffffff8100292b>] ? system_call_fastpath+0x16/0x1b
Code: ff ff ff ff c3 48 8b 57 18 8b 87 d8 00 00 00 48 8d 8a ac 00 00
00 f0 29 82 ac 00 00 00 48 8b 57 18 8b 8f d8 00 00 00 48 8b 42 38 <48>
83 b8 b0 00 00 00 00 74 06 01 8a f4 00 00 00 c3 41 57 41 89
RIP  [<ffffffff81369b2a>] sock_rfree+0x26/0x37
 RSP <ffff88042287fc20>
---[ end trace 22e6ca9ef825c0e6 ]---


Seems to be the same issue, right?

Cheers,

=46elipe Damasio





2010/7/13 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mardi 13 juillet 2010 =E0 11:49 -0300, Felipe W Damasio a =E9crit =
:
>> Hi Mr. Dumazet,
>>
>> 2010/7/13 Eric Dumazet <eric.dumazet@gmail.com>:
>> > I currently have no fresh ideas. If you want this problem to be so=
lved,
>> > its important to setup in your lab a workload to trigger again and=
 again
>> > the bug, in order to provide us more crash information.
>>
>> =A0Right. I've been running non-stop since the first bug happened, b=
ut
>> so far the problem hasn't surfaced again :-(
>>
>> =A0I've been using the kernel with the patch that you provided me
>> (nf_tproxy.c). Is there a chance that patch fixed the problem?
>
> This is a real bug, but I dont think it can fix your problem.
>
> Looking again at your crash, we see RCX=3D0x720, decimal 1824
>
> As its skb->len, we are freeing an skb that was collapsed or somethin=
g
> like that, since 1824 > 1460 (the normal MSS on ethernet)
>
> GRO is off on your machine.
>
> But coincidently 0x0720 is also a blank char for VGA screen...
> (0x20 : ASCII space, 0x07 : default attribute)
>
> So maybe you hit a corruption outside of network stack.
>
>
>
>
