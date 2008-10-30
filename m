From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: UDP/bnx2: inconsistent lock state (Re: linux-next: Tree for October 30)
Date: Thu, 30 Oct 2008 15:59:04 +0300
Message-ID: <a4423d670810300559hed082b8uf1f7ce05f5a6f4af@mail.gmail.com>
References: <a4423d670810300340i27cd7fe3wea42767431ad3574@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: mchan@broadcom.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <a4423d670810300340i27cd7fe3wea42767431ad3574@mail.gmail.com>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2008/10/30 Alexander Beregalov <a.beregalov@gmail.com>:
> bnx2 0000:03:00.0: irq 38 for MSI/MSI-X
> bnx2: eth0: using MSI
> bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive &
> transmit flow control ON
>
> [ INFO: inconsistent lock state ]
> 2.6.28-rc2-next-20081030 #4
> ---------------------------------
> inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
>  (&table->hash[i].lock){-+..}, at: [<ffffffff804ea8c5>]
> __udp4_lib_rcv+0x2a5/0x640
> {softirq-on-W} state was registered at:
>  [<ffffffff80257ea0>] __lock_acquire+0x2fd/0xc72
>  [<ffffffff8025889a>] lock_acquire+0x85/0xa9
>  [<ffffffff80525527>] _spin_lock+0x3c/0x70
>  [<ffffffff804eaca2>] udp_lib_unhash+0x2b/0x90
>  [<ffffffff804ab315>] sk_common_release+0x2f/0x83
>  [<ffffffff804e9631>] udp_lib_close+0x9/0xb
>  [<ffffffff804f1274>] inet_release+0x58/0x5f
>  [<ffffffff804a889e>] sock_release+0x20/0xc1
>  [<ffffffff804a8973>] sock_close+0x34/0x3a
>  [<ffffffff8029e8ee>] __fput+0xc5/0x164
>  [<ffffffff8029e9a2>] fput+0x15/0x17
>  [<ffffffff8029be90>] filp_close+0x67/0x72
>  [<ffffffff8023864a>] put_files_struct+0x74/0xc8
>  [<ffffffff802386e5>] exit_files+0x47/0x4f
>  [<ffffffff80239f28>] do_exit+0x27a/0x8b7
>  [<ffffffff8023a5e4>] do_group_exit+0x7f/0xaf
>  [<ffffffff8023a626>] sys_exit_group+0x12/0x14
>  [<ffffffff8020b6fb>] system_call_fastpath+0x16/0x1b
>  [<ffffffffffffffff>] 0xffffffffffffffff
> irq event stamp: 56806
> hardirqs last  enabled at (56806): [<ffffffff8023bf15>]
> _local_bh_enable_ip+0xba/0xe3
> hardirqs last disabled at (56805): [<ffffffff8023beaf>]
> _local_bh_enable_ip+0x54/0xe3
> softirqs last  enabled at (56786): [<ffffffff8023c0ec>] __do_softirq+0xf8/0x104
> softirqs last disabled at (56791): [<ffffffff8020cbac>] call_softirq+0x1c/0x28
>
> other info that might help us debug this:
> no locks held by swapper/0.
>
> stack backtrace:
> Pid: 0, comm: swapper Not tainted 2.6.28-rc2-next-20081030 #4
> Call Trace:
>  <IRQ>  [<ffffffff80256a9c>] valid_state+0x179/0x18c
>  [<ffffffff80256fda>] mark_lock+0x14d/0x37a
>  [<ffffffff80257e25>] __lock_acquire+0x282/0xc72
>  [<ffffffff804c9a91>] ? rt_intern_hash+0x442/0x45c
>  [<ffffffff8023bf47>] ? local_bh_enable_ip+0x9/0xb
>  [<ffffffff8025889a>] lock_acquire+0x85/0xa9
>  [<ffffffff804ea8c5>] ? __udp4_lib_rcv+0x2a5/0x640
>  [<ffffffff80525527>] _spin_lock+0x3c/0x70
>  [<ffffffff804ea8c5>] ? __udp4_lib_rcv+0x2a5/0x640
>  [<ffffffff804ea8c5>] __udp4_lib_rcv+0x2a5/0x640
>  [<ffffffff804eac75>] udp_rcv+0x15/0x17
>  [<ffffffff804cc1ec>] ip_local_deliver+0xad/0x13d
>  [<ffffffff804cc107>] ip_rcv+0x4b7/0x4ef
>  [<ffffffff804b3efb>] netif_receive_skb+0x213/0x23a
>  [<ffffffff8042fa7c>] bnx2_poll_work+0x92e/0xaa5
>  [<ffffffff8024f935>] ? getnstimeofday+0x3a/0x96
>  [<ffffffff8025011e>] ? do_settimeofday+0x7f/0x131
>  [<ffffffff8025001e>] ? update_wall_time+0x38e/0x40f
>  [<ffffffff80256ea9>] ? mark_lock+0x1c/0x37a
>  [<ffffffff802694f4>] ? __rcu_read_lock+0xa0/0xaf
>  [<ffffffff8042fe41>] bnx2_poll+0x128/0x20d
>  [<ffffffff804b2935>] net_rx_action+0xd2/0x1f4
>  [<ffffffff8023c064>] __do_softirq+0x70/0x104
>  [<ffffffff8020cbac>] call_softirq+0x1c/0x28
>  [<ffffffff8020e1d5>] do_softirq+0x39/0x8a
>  [<ffffffff8023bc89>] irq_exit+0x45/0xa2
>  [<ffffffff8020e4e6>] do_IRQ+0x16a/0x19c
>  [<ffffffff8020bc8b>] ret_from_intr+0x0/0xf
>  <EOI>  [<ffffffff80212d69>] ? mwait_idle+0x3e/0x48
>  [<ffffffff80212d60>] ? mwait_idle+0x35/0x48
>  [<ffffffff8020a8db>] ? cpu_idle+0x59/0xc2
>  [<ffffffff8051feb4>] ? start_secondary+0x263/0x26b
>

Similar issue on sparc/sunhme

[ INFO: inconsistent lock state ]
2.6.28-rc2-next-20081030 #12
---------------------------------
inconsistent {softirq-on-W} -> {in-softirq-W} usage.
swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
 (&table->hash[i].lock){-+..}, at: [<000000000069fbd0>]
__udp4_lib_rcv+0x344/0x840
{softirq-on-W} state was registered at:
  [<00000000006dbe30>] _spin_lock+0x30/0x48
  [<00000000006a0128>] udp_lib_unhash+0x2c/0xa4
  [<0000000000656030>] sk_common_release+0x34/0x8c
  [<000000000069e588>] udp_lib_close+0x10/0x20
  [<00000000006a78a4>] inet_release+0x54/0x64
  [<00000000006530b0>] sock_release+0x20/0x9c
  [<0000000000653164>] sock_close+0x38/0x4c
  [<00000000004b496c>] __fput+0xcc/0x1b4
  [<00000000004b4a7c>] fput+0x28/0x38
  [<00000000004b1c40>] filp_close+0x74/0x88
  [<00000000004b1cf0>] sys_close+0x9c/0xf8
  [<0000000000406154>] linux_sparc_syscall32+0x34/0x40
irq event stamp: 91778
hardirqs last  enabled at (91778): [<0000000000455a20>]
local_bh_enable_ip+0xc4/0xf0
hardirqs last disabled at (91777): [<00000000004559b4>]
local_bh_enable_ip+0x58/0xf0
softirqs last  enabled at (91764): [<0000000000455cfc>] __do_softirq+0x108/0x118
softirqs last disabled at (91767): [<000000000042d948>] do_softirq+0x7c/0xbc

other info that might help us debug this:
no locks held by swapper/0.

stack backtrace:
Call Trace:
 [0000000000472168] print_usage_bug+0x1bc/0x1cc
 [0000000000472cac] mark_lock+0x564/0xe9c
 [0000000000474b44] __lock_acquire+0x778/0x1ac8
 [0000000000475ef0] lock_acquire+0x5c/0x74
 [00000000006dbe30] _spin_lock+0x30/0x48
 [000000000069fbd0] __udp4_lib_rcv+0x344/0x840
 [00000000006a00e8] udp_rcv+0x1c/0x30
 [000000000067d1bc] ip_local_deliver+0xe0/0x168
 [000000000067d0a0] ip_rcv+0x51c/0x558
 [000000000066048c] netif_receive_skb+0x32c/0x358
 [0000000000660548] process_backlog+0x90/0x114
 [000000000065eb20] net_rx_action+0xd0/0x1e4
 [0000000000455c68] __do_softirq+0x74/0x118
 [000000000042d948] do_softirq+0x7c/0xbc
 [0000000000455738] irq_exit+0x54/0xc0
 [000000000042da84] handler_irq+0xfc/0x114
