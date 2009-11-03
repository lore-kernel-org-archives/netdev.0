From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.32-rc5-mmotm1101 - kernel BUG at net/ipv4/tcp_input.c:3707!
Date: Tue, 03 Nov 2009 19:02:12 +0100
Message-ID: <4AF07024.80103@gmail.com>
References: <5765.1257270611@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Gilad Ben-Yossef <gilad@codefidence.com>,
	Ori Finkelman <ori@comsleep.com>
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753436AbZKCSDK@vger.kernel.org>
In-Reply-To: <5765.1257270611@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valdis.Kletnieks@vt.edu a =E9crit :
> Seen right after I started 'fetchmail'.  Reproducible - 3 out of 3.
> I'll bisect this tonight if nobody jumps up and yells they know what =
it is...
>=20
> Looking at the traceback, I wonder if we started sending the SYN pack=
et,
> but didn't finish the paperwork before the SYN/ACK came back?
>=20
> [   87.269743] ------------[ cut here ]------------
> [   87.270011] kernel BUG at net/ipv4/tcp_input.c:3707!
> [   87.270011] invalid opcode: 0000 [#1] PREEMPT SMP=20
> [   87.270011] last sysfs file: /sys/devices/LNXSYSTM:00/LNXSYBUS:00/=
PNP0C0A:00/power_supply/BAT0/charge_full
> [   87.270011] CPU 0=20
> [   87.270011] Modules linked in: ext4 jbd2 crc16 [last unloaded: mic=
rocode]
> [   87.270011] Pid: 2421, comm: fetchmail Not tainted 2.6.32-rc5-mmot=
m1101 #1 Latitude D820                  =20
> [   87.270011] RIP: 0010:[<ffffffff813d13c2>]  [<ffffffff813d13c2>] t=
cp_parse_options+0x62/0x273
> [   87.270011] RSP: 0018:ffff880002603af8  EFLAGS: 00010202
> [   87.270011] RAX: 0000000000000001 RBX: ffff880002603b78 RCX: 00000=
0000000000a
> [   87.270011] RDX: 0000000000000000 RSI: 0000000000000001 RDI: fffff=
fff81ad9fb0
> [   87.270011] RBP: ffff880002603b48 R08: ffff88007e2d9000 R09: 00000=
00000000001
> [   87.270011] R10: 00000000000006f6 R11: ffff880002603a78 R12: 00000=
00000000000
> [   87.270011] R13: ffff88007eb0ece8 R14: 0000000000000000 R15: ffff8=
8007e693168
> [   87.270011] FS:  00007fa02ff827c0(0000) GS:ffff880002600000(0000) =
knlGS:0000000000000000
> [   87.270011] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   87.270011] CR2: 00000032cf7411e0 CR3: 000000007e41d000 CR4: 00000=
000000006f0
> [   87.270011] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000=
00000000000
> [   87.270011] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000=
00000000400
> [   87.270011] Process fetchmail (pid: 2421, threadinfo ffff880079234=
000, task ffff88007d2bc300)
> [   87.270011] Stack:
> [   87.270011]  ffff880002603b48 ffffffff00000001 000000000000000a ff=
ffffff00000000
> [   87.270011] <0> 0000000000000000 ffff88007903bbc0 ffff88007e693168=
 ffff88007c6eb2c0
> [   87.270011] <0> 0000000000000000 0000000000000000 ffff880002603bc8=
 ffffffff81430486
> [   87.270011] Call Trace:
> [   87.270011]  <IRQ>=20
> [   87.270011]  [<ffffffff81430486>] tcp_v6_conn_request+0x171/0x3cb
> [   87.270011]  [<ffffffff813d3bf8>] tcp_rcv_state_process+0x5f/0x857
> [   87.270011]  [<ffffffff8142ff4d>] tcp_v6_do_rcv+0x313/0x445
> [   87.270011]  [<ffffffff814bd489>] ? _spin_lock_nested+0x42/0x49
> [   87.270011]  [<ffffffff8143155b>] ? tcp_v6_rcv+0x2aa/0x61c
> [   87.270011]  [<ffffffff814316f6>] tcp_v6_rcv+0x445/0x61c
> [   87.270011]  [<ffffffff81414bb9>] ip6_input_finish+0x1bf/0x31f
> [   87.270011]  [<ffffffff81414d66>] ip6_input+0x4d/0x54
> [   87.270011]  [<ffffffff81414502>] ip6_rcv_finish+0x22/0x26
> [   87.270011]  [<ffffffff81414964>] ipv6_rcv+0x45e/0x4b4
> [   87.270011]  [<ffffffff81391662>] netif_receive_skb+0x29e/0x2c8
> [   87.270011]  [<ffffffff81391717>] process_backlog+0x8b/0xc1
> [   87.270011]  [<ffffffff81391e6a>] net_rx_action+0xed/0x2b0
> [   87.270011]  [<ffffffff8108518a>] ? handle_edge_irq+0x16a/0x176
> [   87.270011]  [<ffffffff81041c2a>] __do_softirq+0x127/0x23c
> [   87.270011]  [<ffffffff813922f4>] ? rcu_read_unlock_bh+0x21/0x23
> [   87.270011]  [<ffffffff8100347c>] call_softirq+0x1c/0x34
> [   87.270011]  <EOI>=20
> [   87.270011]  [<ffffffff810049cc>] do_softirq+0x44/0xf0
> [   87.270011]  [<ffffffff813922f4>] ? rcu_read_unlock_bh+0x21/0x23
> [   87.270011]  [<ffffffff810414c7>] _local_bh_enable_ip+0x120/0x16e
> [   87.270011]  [<ffffffff8104152d>] local_bh_enable+0xd/0xf
> [   87.270011]  [<ffffffff813922f4>] rcu_read_unlock_bh+0x21/0x23
> [   87.270011]  [<ffffffff81392e10>] dev_queue_xmit+0x3e4/0x408
> [   87.270011]  [<ffffffff81392b70>] ? dev_queue_xmit+0x144/0x408
> [   87.270011]  [<ffffffff8139afa8>] neigh_resolve_output+0x1ef/0x240
> [   87.270011]  [<ffffffff81410f50>] ? ip6_output_finish+0x0/0xfc
> [   87.270011]  [<ffffffff81410fec>] ip6_output_finish+0x9c/0xfc
> [   87.270011]  [<ffffffff8141242d>] ip6_output2+0x2bf/0x2c8
> [   87.270011]  [<ffffffff81413107>] ip6_output+0xcd1/0xce6
> [   87.270011]  [<ffffffff813ab63a>] ? rcu_read_unlock+0x21/0x23
> [   87.270011]  [<ffffffff813ab89b>] ? nf_hook_slow+0xca/0xdb
> [   87.270011]  [<ffffffff81410c9c>] ? dst_output+0x0/0xd
> [   87.270011]  [<ffffffff81410ca7>] dst_output+0xb/0xd
> [   87.270011]  [<ffffffff81413517>] ip6_xmit+0x3fb/0x4d4
> [   87.270011]  [<ffffffff8143dba6>] ? __inet6_hash+0xe5/0x122
> [   87.270011]  [<ffffffff814358b2>] inet6_csk_xmit+0x265/0x274
> [   87.270011]  [<ffffffff811caa4c>] ? _raw_spin_lock+0xe9/0x1ab
> [   87.270011]  [<ffffffff813d557d>] tcp_transmit_skb+0x816/0x85f
> [   87.270011]  [<ffffffff813d6ed5>] tcp_connect+0x3ae/0x409
> [   87.270011]  [<ffffffff8142f74f>] tcp_v6_connect+0x4f0/0x55e
> [   87.270011]  [<ffffffff813e78d0>] inet_stream_connect+0xa0/0x268
> [   87.270011]  [<ffffffff81383c71>] sys_connect+0x75/0x98
> [   87.270011]  [<ffffffff810e2328>] ? path_put+0x1d/0x22
> [   87.270011]  [<ffffffff81066193>] ? trace_hardirqs_on_caller+0x16/=
0x13c
> [   87.270011]  [<ffffffff8107fdf1>] ? audit_syscall_entry+0xcb/0x19c
> [   87.270011]  [<ffffffff8100246b>] system_call_fastpath+0x16/0x1b
> [   87.270011] Code: e9 04 4d 85 f6 88 4d c0 0f 94 c2 31 c0 45 85 e4 =
0f 94 c0 21 d0 31 d2 89 c6 89 45 b8 e8 70 6a cc ff 8b 45 b8 8a 4d c0 85=
 c0 74 04 <0f> 0b eb fe 0f b6 d1 49 83 c7 38 8d 14 95 ec ff ff ff 49 8d=
 45=20
> [   87.270011] RIP  [<ffffffff813d13c2>] tcp_parse_options+0x62/0x273
> [   87.270011]  RSP <ffff880002603af8>
>=20


BUG_ON(!estab && !dst);=20

Probably comes from commit 022c3f7d82f0f1c68018696f2f027b87b9bb45c2

(Allow tcp_parse_options to consult dst entry)

CC Gilad Ben-Yossef <gilad@codefidence.com> and Ori Finkelman <ori@coms=
leep.com> for a diagnostic
