From: Wang Weidong <wangweidong1@huawei.com>
Subject: Problem:  A divide error 0000 occured when rcv_mss is 0
Date: Wed, 22 Oct 2014 17:07:37 +0800
Message-ID: <544773D9.60203@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <rui.xiang@huawei.com>,
	Li Zefan <lizefan@huawei.com>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone,

my kernel is based on linux-stable-3.4.87. And when I do some testing,
I got this Bug:

<4>[18042.394823] divide error: 0000 [#1]
<4>[18042.395178] SMP 
<4>[18042.734309] CPU 2 

...

<4>[18042.734309] RIP: 0010:[<ffffffff81385e44>]  [<ffffffff81385e44>] tcp_send_dupack+0x54/0xe0
<4>[18042.734309] RSP: 0018:ffff8801c1845af0  EFLAGS: 00010246
<4>[18042.734309] RAX: 00000000000f4240 RBX: ffff8801604fad00 RCX: 0000000000000000
<4>[18042.734309] RDX: 0000000000000000 RSI: ffff880121cd5400 RDI: ffff8801604fad00
<4>[18042.734309] RBP: ffff8801c1845b00 R08: 00000000355e0308 R09: 0000000008015603
<4>[18042.734309] R10: 000000000000000f R11: ffff88016095e1cc R12: ffff880121cd5400
<4>[18042.734309] R13: 0000000000000000 R14: ffff88014f5d1c62 R15: ffff88014f5d1c62
<4>[18042.734309] FS:  00007f611dc6d700(0000) GS:ffff8801c1840000(0000) knlGS:0000000000000000
<4>[18042.734309] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
<4>[18042.734309] CR2: ffffffffff600400 CR3: 000000014c83e000 CR4: 00000000001407e0
<4>[18042.734309] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[18042.734309] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[18042.734309] Process CSD_1 (pid: 28654, threadinfo ffff88019fb92000, task ffff880162555c80)
<4>[18042.734309] Stack:
<4>[18042.734309]  0000000000002135 ffff8801604fad00 ffff8801c1845b40 ffffffff813886b5
<4>[18042.734309]  ffff8801c1845b20 ffffffff81441aa2 ffff8801604fad00 ffff880121cd5400
<4>[18042.734309]  ffff88014f5d1c62 ffff88016095e180 ffff8801c1845b90 ffffffff8138d0b7
<4>[18042.734309]  ffff88014153e0d0 0000000000000001 0000000000000002 ffff8801604fad00
<4>[18042.734309]  ffff88016095e180 0000000000000003 ffff88016095e180 ffff88014f5d1c62
<4>[18042.734309]  ffff8801c1845bc0 ffffffff81397255 ffff880121cd5400 ffff88016095e180
<4>[18042.734309]  ffff8801604fad00 ffff88014f5d1c62 ffff8801c1845c10 ffffffff81395a70
<4>[18042.734309]  ffff88010000000f ffffffff811bf0e1 ffff8801c1845c10 ffffffff81356d2f
<4>[18042.734309]  ffff880121cd5400 ffffffff81856680 ffff88016095e180 ffff88016095e1d0
<4>[18042.734309]  ffff8801c1845c80 ffffffff81396fc8 ffff88010000000f ffff880163d5e000
<4>[18042.734309]  ffff8801c1845cb0 ffffffff0000000f ffffffff81856680 0a72a8c000000801
<4>[18042.734309]  ffffffff81884600 ffff880121cd5400 ffffffff8164cc80 0000000000000006
<4>[18042.734309]  ffffffff81856680 ffffffff81883920 ffff8801c1845cb0 ffffffff813746e9
<4>[18042.734309]  ffff880121cd5400 ffff88014f5d1c4e 0000000000000008 ffff880163d5e000
<4>[18042.734309]  ffff8801c1845ce0 ffffffff81374a20 ffff880180000000 0000000000000008
<4>[18042.734309]  ffff880163d5e000 ffff880121cd5400
<4>[18042.734309] Call Trace:
<4>[18042.734309]  <IRQ> 
<4>[18042.734309]  [<ffffffff813886b5>] tcp_validate_incoming+0x135/0x2c0
<4>[18042.734309]  [<ffffffff81441aa2>] ? _raw_spin_unlock_bh+0x12/0x20
<4>[18042.734309]  [<ffffffff8138d0b7>] tcp_rcv_state_process+0x47/0xba0
<4>[18042.734309]  [<ffffffff81397255>] tcp_child_process+0x45/0xf0
<4>[18042.734309]  [<ffffffff81395a70>] tcp_v4_do_rcv+0x1b0/0x290
<4>[18042.734309]  [<ffffffff811bf0e1>] ? security_sock_rcv_skb+0x11/0x20
<4>[18042.734309]  [<ffffffff81356d2f>] ? sk_filter+0x1f/0xb0
<4>[18042.734309]  [<ffffffff81396fc8>] tcp_v4_rcv+0x738/0x810
<4>[18042.734309]  [<ffffffff813746e9>] ip_local_deliver_finish+0xb9/0x230
<4>[18042.734309]  [<ffffffff81374a20>] ip_local_deliver+0x80/0x90
<4>[18042.734309]  [<ffffffff81374389>] ip_rcv_finish+0x69/0x310
<4>[18042.734309]  [<ffffffff81374c78>] ip_rcv+0x248/0x320
<4>[18042.734309]  [<ffffffff81344dd2>] __netif_receive_skb+0x372/0x580
<4>[18042.734309]  [<ffffffff8106f0d8>] ? check_preempt_wakeup+0x158/0x250
<4>[18042.734309]  [<ffffffff81345198>] netif_receive_skb+0x28/0x90
<4>[18042.734309]  [<ffffffff81064c4e>] ? __wake_up+0x4e/0x70
<4>[18042.734309]  [<ffffffff813453dc>] napi_gro_complete+0xcc/0x100
<4>[18042.734309]  [<ffffffff8134584f>] napi_complete+0x2f/0x80
<4>[18042.734309]  [<ffffffffa1575baf>] napi_rx_handler+0x2f/0x80 [cxgb4]
<4>[18042.734309]  [<ffffffff81345957>] net_rx_action+0xb7/0x1a0
<4>[18042.734309]  [<ffffffff812259b1>] ? do_raw_spin_lock+0x61/0x110
<4>[18042.734309]  [<ffffffff8103e385>] __do_softirq+0xb5/0x1c0
<4>[18042.734309]  [<ffffffff81441b59>] ? _raw_spin_lock+0x9/0x10
<4>[18042.734309]  [<ffffffff8144a99c>] call_softirq+0x1c/0x30
<4>[18042.734309]  [<ffffffff810040fd>] do_softirq+0x6d/0xa0
<4>[18042.734309]  [<ffffffff8103e725>] irq_exit+0xa5/0xb0
<4>[18042.734309]  [<ffffffff81003cee>] do_IRQ+0x5e/0xd0
<4>[18042.734309]  [<ffffffff81441d6a>] common_interrupt+0x6a/0x6a

Is it like the problem which fixed by commit 709e8697af1c86772c1a6fccda6d4b0e2e226547
(tcp: clear xmit timers in tcp_v4_syn_recv_sock())?

I think the divide error happen at:
tcp_send_dupack
    -> tcp_enter_quickack_mode
        -> tcp_incr_quickack

There is code that: 
     unsigned quickacks = tcp_sk(sk)->rcv_wnd / (2 * icsk->icsk_ack.rcv_mss);
so the icsk_ack.rcv_mss is 0?

But I am not sure, is it a Bug in the kernel? Or maybe somewhere I do wrong.

Can anybody help me to check is it a Bug or other problems, and how can I to 
resolve it.

Regards,
Wang
