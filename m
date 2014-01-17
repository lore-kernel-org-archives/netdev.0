From: Andrew Ruder <andy-GLsK2E43KyLR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH] net: sk == 0xffffffff fix - not for commit
Date: Thu, 16 Jan 2014 18:01:15 -0600
Message-ID: <20140117000115.GA4937@gmail.com>
References: <1386589672-5830-1-git-send-email-andrzej.p@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Kyungmin Park <kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Marek Szyprowski <m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1386589672-5830-1-git-send-email-andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 09, 2013 at 12:47:52PM +0100, Andrzej Pietrasiewicz wrote:
> With g_ether loaded the sk occasionally becomes 0xffffffff.
> It happens usually after transferring few hundreds of kilobytes to few
> tens of megabytes. If sk is 0xffffffff then dereferencing it causes
> kernel panic.

Don't know if this is relevant but I had this very similar stack trace
come up a few days ago (below).  I am working on a PXA 270/xscale with
gcc version 4.8.2 (Buildroot 2013.11-rc1-00028-gf388663).  Going to try
to see if I can reproduce it a little more readily before I start trying
to narrow down what is causing it.

===
Unable to handle kernel NULL pointer dereference at virtual address 00000011
pgd = d18e0000
[00000011] *pgd=a6d03831, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#1] PREEMPT ARM
Modules linked in: zeusvirt(O) zeus16550(O) 8390p ipv6
CPU: 0 PID: 2365 Comm: sshd Tainted: G           O 3.12.0+ #201
task: d7216f00 ti: d7144000 task.ti: d7144000
PC is at tcp_v4_early_demux+0xe8/0x154
LR is at __inet_lookup_established+0x1bc/0x2e0
pc : [<c0341cfc>]    lr : [<c0329bd8>]    psr: a0000013
sp : d7145b20  ip : d7145ae8  fp : d7145b44
r10: c0576c28  r9 : 00000008  r8 : d7998800
r7 : d7063800  r6 : c6cf2480  r5 : ffffffff  r4 : c6cf2480
r3 : c02ec018  r2 : d7145ad0  r1 : d7b66a28  r0 : ffffffff
Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 0000397f  Table: b18e0000  DAC: 00000015
Process sshd (pid: 2365, stack limit = 0xd71441c8)
Stack: (0xd7145b20 to 0xd7146000)
5b20: 17bf3f0a 00000016 00000003 c0026d90 d71f4634 d71f4600 d7145b6c d7145b48
5b40: c03211b4 c0341c20 000005ea d7bb0538 d7063800 00000034 d71f4600 c6cf2480
5b60: d7145b9c d7145b70 c03218dc c0321158 00001001 00000000 c0576c1c 00000000
5b80: c0577e84 c0576c14 00000000 00000000 d7145be4 d7145ba0 c02fae04 c03215d4
5ba0: c0590330 c057fc08 d7145bfc c6cf2480 c02571a0 c0576c28 000007e1 c05a3dc0
5bc0: 00000000 00000001 c05a3d60 c05a3d74 c05a3d60 c05a3d68 d7145bfc d7145be8
5be0: c02fb990 c02fa8f0 c05a3dc0 00000000 d7145c24 d7145c00 c02fc46c c02fb968
5c00: c02fc3dc c05a3dc0 c05a3d60 00000001 0000012c 00000040 d7145c64 d7145c28
5c20: c02fbcd0 c02fc3e8 00000000 d78af3c0 d7145c5c 00008d99 00000000 00000001
5c40: c05a81f0 00000003 00000100 3fa57e1c d7144028 c05a81ec d7145cb4 d7145c68
5c60: c0026a44 c02fbc10 d7145c8c d7145c78 c00538dc c0056ce4 00000000 00008d98
5c80: 00400100 0000000a c0228594 60000093 c0590330 00000000 d7145d54 00000001
5ca0: d7bb0480 000005b4 d7145ccc d7145cb8 c0026ca4 c00268f4 00000000 d7144010
5cc0: d7145ce4 d7145cd0 c0026f58 c0026c58 000000ab 0000001a d7145d04 d7145ce8
5ce0: c000f7d0 c0026ed0 00140000 d7145d20 a0000013 ffffffff d7145d1c d7145d08
5d00: c00085bc c000f768 c02f0048 c00ca7d8 d7145d7c d7145d20 c03a7dc0 c0008590
5d20: 000118ed 00000000 c05a474c c05d41cc d7bb0180 d18ed800 d7801080 000006a3
5d40: 00000001 d7bb0480 000005b4 d7145d7c d7145d80 d7145d68 c02f0048 c00ca7d8
5d60: a0000013 ffffffff c05a4738 d7bb0180 d7145dac d7145d80 c02f0048 c00ca7b0
5d80: 00000001 00c63fc0 d7b66a00 d7b66a00 00004040 000005b4 00000000 d7b66a00
5da0: d7145dcc d7145db0 c032e340 c02effd0 d7145e98 00004040 0008c414 00000000
5dc0: d7145e54 d7145dd0 c032f368 c032e310 d7145e24 c02ea81c c03a6040 c03a9c6c
5de0: 00000000 00000000 d7145ee8 00000000 000005b4 00000000 d7b66adc 00000000
5e00: 00000000 d7144000 00001854 000005b4 000027ec 00000040 d7116d80 000005b4
5e20: 00000000 00000000 d7145e6c d7b66a00 d7145ee8 d7145e98 00004040 00004040
5e40: 00004040 00020000 d7145e74 d7145e58 c03526c8 c032eb0c d7145e78 d7116d80
5e60: d7145ee0 d7116d80 d7145ed4 d7145e78 c02e63a4 c0352688 c05a3dc0 d7142000
5e80: 00000040 00004040 d76701c0 d7145ee0 00000000 d7145e98 00000000 00000000
5ea0: d7145ee0 00000001 00000000 00000000 00000040 d7145ee8 c6cf2900 00000000
5ec0: 00000000 d7145f78 d7145f44 d7145ed8 c00d1c64 c02e62e4 00000000 00000000
5ee0: 00089c28 00004040 d7116d80 00000000 00000000 d7145e78 d7216f00 00000000
5f00: 00000000 00000000 00000000 00000000 00004040 00000000 00000000 00000000
5f20: 00089c28 d7116d80 00089c28 d7145f78 00004040 00089c28 d7145f74 d7145f48
5f40: c00d23a0 c00d1bf4 00000000 00000000 00000000 00000000 d7116d80 00000000
5f60: 00089c28 00004040 d7145fa4 d7145f78 c00d2948 c00d22c0 00000000 00000000
5f80: beed167c 00000003 000614dc 00000004 c000ea28 d7144000 00000000 d7145fa8
5fa0: c000e7e0 c00d2908 beed167c 00000003 00000003 00089c28 00004040 beed167c
5fc0: beed167c 00000003 000614dc 00000004 00089c28 00060a88 0000093e beed17a0
5fe0: beed167c beed1648 00029910 b6dc821c 60000010 00000003 ffffffff ffffffff
[<c0341cfc>] (tcp_v4_early_demux+0xe8/0x154) from [<c03211b4>] (ip_rcv_finish+0x68/0x2c0)
[<c03211b4>] (ip_rcv_finish+0x68/0x2c0) from [<c03218dc>] (ip_rcv+0x314/0x398)
[<c03218dc>] (ip_rcv+0x314/0x398) from [<c02fae04>] (__netif_receive_skb_core+0x520/0x5d8)
[<c02fae04>] (__netif_receive_skb_core+0x520/0x5d8) from [<c02fb990>] (__netif_receive_skb+0x34/0x88)
[<c02fb990>] (__netif_receive_skb+0x34/0x88) from [<c02fc46c>] (process_backlog+0x90/0x148)
[<c02fc46c>] (process_backlog+0x90/0x148) from [<c02fbcd0>] (net_rx_action+0xcc/0x258)
[<c02fbcd0>] (net_rx_action+0xcc/0x258) from [<c0026a44>] (__do_softirq+0x15c/0x2e0)
[<c0026a44>] (__do_softirq+0x15c/0x2e0) from [<c0026ca4>] (do_softirq+0x58/0x64)
[<c0026ca4>] (do_softirq+0x58/0x64) from [<c0026f58>] (irq_exit+0x94/0xf0)
[<c0026f58>] (irq_exit+0x94/0xf0) from [<c000f7d0>] (handle_IRQ+0x74/0x90)
[<c000f7d0>] (handle_IRQ+0x74/0x90) from [<c00085bc>] (ichp_handle_irq+0x38/0x40)
[<c00085bc>] (ichp_handle_irq+0x38/0x40) from [<c03a7dc0>] (__irq_svc+0x40/0x6c)
Exception stack(0xd7145d20 to 0xd7145d68)
5d20: 000118ed 00000000 c05a474c c05d41cc d7bb0180 d18ed800 d7801080 000006a3
5d40: 00000001 d7bb0480 000005b4 d7145d7c d7145d80 d7145d68 c02f0048 c00ca7d8
5d60: a0000013 ffffffff
[<c03a7dc0>] (__irq_svc+0x40/0x6c) from [<c00ca7d8>] (ksize+0x34/0xc8)
[<c00ca7d8>] (ksize+0x34/0xc8) from [<c02f0048>] (__alloc_skb+0x84/0x15c)
[<c02f0048>] (__alloc_skb+0x84/0x15c) from [<c032e340>] (sk_stream_alloc_skb+0x3c/0x108)
[<c032e340>] (sk_stream_alloc_skb+0x3c/0x108) from [<c032f368>] (tcp_sendmsg+0x868/0xd34)
[<c032f368>] (tcp_sendmsg+0x868/0xd34) from [<c03526c8>] (inet_sendmsg+0x4c/0x78)
[<c03526c8>] (inet_sendmsg+0x4c/0x78) from [<c02e63a4>] (sock_aio_write+0xcc/0xdc)
[<c02e63a4>] (sock_aio_write+0xcc/0xdc) from [<c00d1c64>] (do_sync_write+0x7c/0xa0)
[<c00d1c64>] (do_sync_write+0x7c/0xa0) from [<c00d23a0>] (vfs_write+0xec/0x194)
[<c00d23a0>] (vfs_write+0xec/0x194) from [<c00d2948>] (SyS_write+0x4c/0x7c)
[<c00d2948>] (SyS_write+0x4c/0x7c) from [<c000e7e0>] (ret_fast_syscall+0x0/0x2c)
Code: 0a000019 e59f306c e5845010 e5843068 (e5d53012)
---[ end trace 5a028e59aa5bc81a ]---
Kernel panic - not syncing: Fatal exception in interrupt
===
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
