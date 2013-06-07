From: Tommi Rantala <tt.rantala@gmail.com>
Subject: ipv6 && kernel BUG at net/core/skbuff.c:126!
Date: Fri, 7 Jun 2013 21:33:49 +0300
Message-ID: <CA+ydwtpiZ7Z3bEWZxnM4BVxo_fvX5JXO=0zqqpobsCgm4jdwRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Hit this while fuzzing v3.10-rc4-214-g1612e11 (plus a one-liner
af_netlink patch from Patrick McHardy, that I hope is not related to
this bug).

Tommi

[19081.311430] vhci_hcd: changed 0
[19085.248780] type=1401 audit(1370620096.643:275): SELinux:
unrecognized netlink message type=26994 for sclass=34
[19085.248780]
[19212.879972] RDS: rds_bind() could not find a transport, load
rds_tcp or rds_rdma?
[19261.840596] type=1401 audit(1370620273.235:276): SELinux:
unrecognized netlink message type=0 for sclass=34
[19261.840596]
[19275.403689] RDS: rds_bind() could not find a transport, load
rds_tcp or rds_rdma?
[19276.607552] trinity-watchdo[26887]: segfault at b4aae80 ip
00000000004050df sp 00007fffbef9e348 error 4 in trinity[400000+22000]
[19344.507844] RDS: rds_bind() could not find a transport, load
rds_tcp or rds_rdma?
[19491.565638] skbuff: skb_under_panic: text:ffffffff81fc402c len:48
put:40 head:ffff88008c6a5a40 data:ffff88008c6a5a3c tail:0x2c end:0xc0
dev:<NULL>
[19491.570959] ------------[ cut here ]------------
[19491.572556] kernel BUG at /build/linux-one/net/core/skbuff.c:126!
[19491.574432] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[19491.576143] CPU: 0 PID: 27749 Comm: trinity-child16 Not tainted
3.10.0-rc4+ #1
[19491.578330] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[19491.580017] task: ffff8800b51aa3e0 ti: ffff8800ad4b0000 task.ti:
ffff8800ad4b0000
[19491.582268] RIP: 0010:[<ffffffff8229b949>]  [<ffffffff8229b949>]
skb_panic+0x5e/0x60
[19491.584558] RSP: 0018:ffff8800ad4b1e00  EFLAGS: 00010282
[19491.586165] RAX: 0000000000000086 RBX: ffff8800b7dd6900 RCX: 0000000000000006
[19491.588290] RDX: 0000000000003420 RSI: ffff8800b51aaab8 RDI: 0000000000000246
[19491.590426] RBP: ffff8800ad4b1e20 R08: 0000000000000002 R09: 0000000000000000
[19491.592632] R10: 0000000000000001 R11: 0000000000000001 R12: ffffffff82dc29c0
[19491.594897] R13: ffff8800b6a37000 R14: ffff8800b6a375f8 R15: ffff8800b5075680
[19491.597103] FS:  00007feced22c700(0000) GS:ffff8800bf600000(0000)
knlGS:0000000000000000
[19491.599585] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[19491.601313] CR2: 00007f603b3cdb90 CR3: 00000000b03a2000 CR4: 00000000000006f0
[19491.603450] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[19491.605580] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[19491.607710] Stack:
[19491.608362]  ffff88008c6a5a3c 000000000000002c 00000000000000c0
ffffffff82b59d69
[19491.610681]  ffff8800ad4b1e30 ffffffff81eb6243 ffff8800ad4b1e90
ffffffff81fc402c
[19491.613074]  ffffffff81119c55 11ff8800b51aa3e0 ffff8800ad4b1e58
0100007f0100007f
[19491.615447] Call Trace:
[19491.616273]  [<ffffffff81eb6243>] skb_push+0x33/0x40
[19491.617840]  [<ffffffff81fc402c>] ip6_push_pending_frames+0x20c/0x4b0
[19491.619768]  [<ffffffff81119c55>] ? local_bh_enable+0xc5/0xf0
[19491.621476]  [<ffffffff81fdf650>] udp_v6_push_pending_frames+0x390/0x3a0
[19491.623475]  [<ffffffff81119c55>] ? local_bh_enable+0xc5/0xf0
[19491.625236]  [<ffffffff81fdf2c0>] ? compat_udpv6_setsockopt+0x30/0x30
[19491.627153]  [<ffffffff81f60812>] udp_lib_setsockopt+0xc2/0x1d0
[19491.628965]  [<ffffffff81fdf67d>] udpv6_setsockopt+0x1d/0x30
[19491.630674]  [<ffffffff81eb33bf>] sock_common_setsockopt+0xf/0x20
[19491.632577]  [<ffffffff81ead7e6>] SyS_setsockopt+0x96/0xe0
[19491.634376]  [<ffffffff822a47a9>] system_call_fastpath+0x16/0x1b
[19491.636189] Code: 00 00 48 89 44 24 10 8b 87 d0 00 00 00 48 89 44
24 08 48 8b 87 e0 00 00 00 48 c7 c7 d0 82 b6 82 48 89 04 24 31 c0 e8
b9 c3 fe ff <0f> 0b 55 48 89 e5 41 56 41 55 41 54 53 48 89 fb 48 83 ec
28 4c
[19491.643452] RIP  [<ffffffff8229b949>] skb_panic+0x5e/0x60
[19491.645166]  RSP <ffff8800ad4b1e00>
[19491.696563] ---[ end trace 65e4f208315d47ce ]---
[19592.612621] irda_setsockopt: not allowed to set MAXSDUSIZE for this
socket type!
