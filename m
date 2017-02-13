From: Eric Dumazet <edumazet@google.com>
Subject: Re: net: BUG in __skb_gso_segment
Date: Mon, 13 Feb 2017 13:56:04 -0800
Message-ID: <CANn89i+rqdKnRN9XH4ARqGouJaM0P2WtH9XrGQF+MJ_+mgrsaQ@mail.gmail.com>
References: <CAAeHK+x0LGHoBF-iL5Az-nrXTBkMUfeqi0Pb-7Fne7L8ZYA6Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+x0LGHoBF-iL5Az-nrXTBkMUfeqi0Pb-7Fne7L8ZYA6Sg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 13, 2017 at 11:54 AM, Andrey Konovalov
<andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> A reproducer and .config are attached.
>
> On commit 926af6273fc683cd98cd0ce7bf0d04a02eed6742.
>
> kernel BUG at ./include/linux/skbuff.h:1942!
> invalid opcode: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 1 PID: 5922 Comm: syz-executor5 Not tainted 4.10.0-rc7+ #127
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88003ba72dc0 task.stack: ffff880033ed0000
> RIP: 0010:__skb_pull include/linux/skbuff.h:1942 [inline]
> RIP: 0010:skb_mac_gso_segment+0x5ae/0x690 net/core/dev.c:2634
> RSP: 0018:ffff880033ed6c48 EFLAGS: 00010216
> RAX: 0000000000010000 RBX: 000000000000113e RCX: ffffc90003f74000
> RDX: 0000000000000223 RSI: ffffffff833cfbfe RDI: ffff88003e305244
> RBP: ffff880033ed6d98 R08: 0000000000000000 R09: 0000000000000000
> R10: c66e14bf8d4328e9 R11: 0000000000000000 R12: 000000000000000e
> R13: ffff88003e3051c0 R14: ffff880033ed6d70 R15: 0000000000000000
> FS:  00007faa035db700(0000) GS:ffff88003ed00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000203dd000 CR3: 000000003c165000 CR4: 00000000000006e0
> Call Trace:
>  __skb_gso_segment+0x3d2/0x780 net/core/dev.c:2710
>  skb_gso_segment include/linux/netdevice.h:3914 [inline]
>  validate_xmit_skb+0x5c9/0xc20 net/core/dev.c:2944
>  __dev_queue_xmit+0x102e/0x2860 net/core/dev.c:3364
>  dev_queue_xmit+0x17/0x20 net/core/dev.c:3405
>  packet_snd net/packet/af_packet.c:2872 [inline]
>  packet_sendmsg+0x40bc/0x58b0 net/packet/af_packet.c:2897
>  sock_sendmsg_nosec net/socket.c:635 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:645
>  ___sys_sendmsg+0x4a3/0xae0 net/socket.c:1985
>  __sys_sendmmsg+0x25c/0x750 net/socket.c:2075
>  SYSC_sendmmsg net/socket.c:2106 [inline]
>  SyS_sendmmsg+0x35/0x60 net/socket.c:2101
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x4458b9
> RSP: 002b:00007faa035dab58 EFLAGS: 00000292 ORIG_RAX: 0000000000000133
> RAX: ffffffffffffffda RBX: 0000000000000016 RCX: 00000000004458b9
> RDX: 0000000000000001 RSI: 0000000020bc7fc8 RDI: 0000000000000016
> RBP: 00000000006e1ad0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000708000
> R13: 0000000020fcc000 R14: 0000000000001000 R15: 0000000000000003
> Code: 00 00 48 c7 c7 00 4b 23 85 c6 05 b6 6f b2 02 01 e8 58 7a 04 fe
> e9 ae fc ff ff 48 c7 c3 ea ff ff ff e9 dc fe ff ff e8 82 f0 1d fe <0f>
> 0b 48 8b bd e0 fe ff ff e8 a4 30 48 fe e9 ef fd ff ff e8 9a
> RIP: __skb_pull include/linux/skbuff.h:1942 [inline] RSP: ffff880033ed6c48
> RIP: skb_mac_gso_segment+0x5ae/0x690 net/core/dev.c:2634 RSP: ffff880033ed6c48
> ---[ end trace 2214c8475331c97c ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..

Hi Andrey.

926af6273fc683cd98cd0ce7bf0d04a02eed6 is quite old ;)

Probably already fixed ?

commit 57031eb794906eea4e1c7b31dc1e2429c0af0c66
Author: Willem de Bruijn <willemb@google.com>
Date:   Tue Feb 7 15:57:21 2017 -0500

    packet: round up linear to header len

    Link layer protocols may unconditionally pull headers, as Ethernet
    does in eth_type_trans. Ensure that the entire link layer header
    always lies in the skb linear segment. tpacket_snd has such a check.
    Extend this to packet_snd.

    Variable length link layer headers complicate the computation
    somewhat. Here skb->len may be smaller than dev->hard_header_len.

    Round up the linear length to be at least as long as the smallest of
    the two.

    Reported-by: Dmitry Vyukov <dvyukov@google.com>
    Signed-off-by: Willem de Bruijn <willemb@google.com>
    Acked-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 217e6fa24ce28ec87fca8da93c9016cb78028612
Author: Willem de Bruijn <willemb@google.com>
Date:   Tue Feb 7 15:57:20 2017 -0500

    net: introduce device min_header_len

    The stack must not pass packets to device drivers that are shorter
    than the minimum link layer header length.

    Previously, packet sockets would drop packets smaller than or equal
    to dev->hard_header_len, but this has false positives. Zero length
    payload is used over Ethernet. Other link layer protocols support
    variable length headers. Support for validation of these protocols
    removed the min length check for all protocols.

    Introduce an explicit dev->min_header_len parameter and drop all
    packets below this value. Initially, set it to non-zero only for
    Ethernet and loopback. Other protocols can follow in a patch to
    net-next.

    Fixes: 9ed988cd5915 ("packet: validate variable length ll headers")
    Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
    Signed-off-by: Willem de Bruijn <willemb@google.com>
    Acked-by: Eric Dumazet <edumazet@google.com>
    Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
