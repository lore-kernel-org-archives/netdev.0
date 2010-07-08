From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Squid hang up on 2.6.34
Date: Fri, 09 Jul 2010 00:06:26 +0200
Message-ID: <1278626786.2435.67.camel@edumazet-laptop>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Felipe W Damasio <felipewd@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 08 juillet 2010 =C3=A0 16:03 -0300, Felipe W Damasio a =C3=A9c=
rit :
> Hi All,
>=20

CC netdev

> I've been using squid for a few months now.
>=20
> It worked great until recently, when we upgraded to kernel 2.6.34.
>=20
> We're using squid on bridge scenario with TProxy.
>=20
> Squid simply hung up (connections with squidclient didn't work), and
> the process didn't respond to kill. I had to use "kill -9".
>=20
> The dmesg output was:
>=20
> kernel: general protection fault: 0000 [#1] SMP
> kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:1f.3/i2c-0/n=
ame
> kernel: CPU 1
> kernel: Modules linked in:
>=20
> kernel: Pid: 18351, comm: squid Not tainted 2.6.34 #1 DX58SO/
> kernel: RIP: 0010:[<ffffffff81360c2a>]  [<ffffffff81360c2a>]
> sock_rfree+0x26/0x37
> kernel: RSP: 0018:ffff88041c28fc20  EFLAGS: 00010206
> kernel: RAX: dce8dce85d415d41 RBX: ffff88038f098c00 RCX: 000000000000=
0720


dereferencing RAX, and RAX contains garbage (ascii chars :=20
"A ] A ]" ...)

At this point, RAX is supposed to contain a pointer to sk->sk_prot

static inline int sk_has_account(struct sock *sk)
{
        /* return true if protocol supports memory accounting */
        return !!sk->sk_prot->memory_allocated;
}


> kernel: RDX: ffff8804053b2e00 RSI: ffff88032564ee0c RDI: ffff88038f09=
8c00
> kernel: RBP: ffff8804051b2e00 R08: 0000000000000000 R09: 000000000000=
0000
> kernel: R10: 0000000000020860 R11: ffff8804051b2e00 R12: 000000000000=
05a8
> kernel: R13: 00000000000005a8 R14: 0000000000003d21 R15: 000000000000=
0000
> kernel: FS:  00007f214fa8c710(0000) GS:ffff880001840000(0000)
> knlGS:0000000000000000
> kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> kernel: CR2: 000000000b388000 CR3: 000000041c4c4000 CR4: 000000000000=
06e0
> kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000000=
0000
> kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000000=
0400
> kernel: Process squid (pid: 18351, threadinfo ffff88041c28e000, task
> ffff88042e0fcec0)
> kernel: Stack:
> kernel: ffffffff81365dda ffff88038f098c00 ffffffff81365b8c ffff88038f=
098c00
> kernel: <0> ffffffff813a222a 00000000000000d0 ffffffff81366af9 000000=
002e0fcec0
> kernel: <0> ffff88042e0fcec0 ffff88042e0fcec0 ffff88042e0fcec0 000000=
0014d31cc0
> kernel: Call Trace:
> kernel: [<ffffffff81365dda>] ? skb_release_head_state+0x6d/0xb7
> kernel: [<ffffffff81365b8c>] ? __kfree_skb+0x9/0x7d
> kernel: [<ffffffff813a222a>] ? tcp_recvmsg+0x6a3/0x89a
> kernel: [<ffffffff81366af9>] ? __alloc_skb+0x5e/0x14e
> kernel: [<ffffffff81360ede>] ? sock_common_recvmsg+0x30/0x45
> kernel: [<ffffffff8135ec0f>] ? sock_aio_read+0xdd/0xf1
> kernel: [<ffffffff810ac500>] ? do_sync_read+0xb0/0xf2
> kernel: [<ffffffff8142a25e>] ? _raw_spin_lock_bh+0x9/0x1f
> kernel: [<ffffffff810acf32>] ? vfs_read+0xb9/0xff
> kernel: [<ffffffff810ad034>] ? sys_read+0x45/0x6e
> kernel: [<ffffffff8100292b>] ? system_call_fastpath+0x16/0x1b
> kernel: Code: ff ff ff ff c3 48 8b 57 18 8b 87 d8 00 00 00 48 8d 8a a=
c
> 00 00 00 f0 29 82 ac 00 00 00 48 8b 57 18 8b 8f d8 00 00 00 48 8b 42
> 38 <48> 83 b8 b0 00 00 00 00 74 06 01 8a f4 00 00 00 c3 41 57 41 89
> kernel: RIP  [<ffffffff81360c2a>] sock_rfree+0x26/0x37
> kernel: RSP <ffff88041c28fc20>
> kernel: ---[ end trace bcd320fe508cc071 ]---
>=20
> Can anybody help me?
>=20
> What information can I provide you to track down this issue?
>=20
> Cheers,
>=20
> Felipe Damasio
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
