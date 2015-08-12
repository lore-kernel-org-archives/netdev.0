From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: Linux 4.2-rc6 regression: RIP: e030:[<ffffffff8110fb18>]
 [<ffffffff8110fb18>] =?UTF-8?Q?detach=5Fif=5Fpending+=30x=31=38/=30x=38?=
 =?UTF-8?Q?=30?=
Date: Wed, 12 Aug 2015 23:46:49 +0200
Message-ID: <b5e9ffc27531e98bc2ac1e28d6a3d0f0@eikelenboom.it>
References: <7c39e6332aae572372108d5fd68c503b@eikelenboom.it>
 <1439412094.29802.21.camel@edumazet-glaptop2.roam.corp.google.com>
 <0de9f30086ee2e662bdafee61d24b3c1@eikelenboom.it>
 <20150812.144040.1151964094247340464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150812.144040.1151964094247340464.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-08-12 23:40, David Miller wrote:
> From: linux@eikelenboom.it
> Date: Wed, 12 Aug 2015 22:50:42 +0200
> 
>> On 2015-08-12 22:41, Eric Dumazet wrote:
>>> On Wed, 2015-08-12 at 21:19 +0200, linux@eikelenboom.it wrote:
>>>> Hi,
>>>> On my box running Xen with a 4.2-rc6 kernel i still get this splat 
>>>> in
>>>> dom0,
>>>> which crashes the box.
>>>> (i reported a similar splat before (at rc4) here,
>>>> http://www.spinics.net/lists/netdev/msg337570.html)
>>>> Never seen this one on 4.1, so it seems a regression.
>>>> --
>>>> Sander
>>>> [81133.193439] general protection fault: 0000 [#1] SMP
>>>> [81133.204284] Modules linked in:
>>>> [81133.214934] CPU: 0 PID: 3 Comm: ksoftirqd/0 Not tainted
>>>> 4.2.0-rc6-20150811-linus-doflr+ #1
>>>> [81133.225632] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640) , 
>>>> BIOS
>>>> V1.8B1 09/13/2010
>>>> [81133.236237] task: ffff880059b91580 ti: ffff880059bb4000 task.ti:
>>>> ffff880059bb4000
>>>> [81133.246808] RIP: e030:[<ffffffff8110fb18>]  [<ffffffff8110fb18>]
>>>> detach_if_pending+0x18/0x80
>>>> [81133.257354] RSP: e02b:ffff880059bb7848  EFLAGS: 00010086
>>>> [81133.267749] RAX: ffff88004eddc7f0 RBX: ffff88000e20ae08 RCX:
>>>> dead000000200200
>>>> [81133.278201] RDX: 0000000000000000 RSI: ffff88005f60e600 RDI:
>>>> ffff88000e20ae08
>>>> [81133.288723] RBP: ffff880059bb7848 R08: 0000000000000001 R09:
>>>> 0000000000000001
>>>> [81133.298930] R10: 0000000000000003 R11: ffff88000e20ad68 R12:
>>>> 0000000000000000
>>>> [81133.308875] R13: 0000000101735569 R14: 0000000000015f90 R15:
>>>> ffff88005f60e600
>>>> [81133.318845] FS:  00007f28c6f7c800(0000) GS:ffff88005f600000(0000)
>>>> knlGS:0000000000000000
>>>> [81133.328864] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
>>>> [81133.338693] CR2: ffff8000007f6800 CR3: 000000003d55c000 CR4:
>>>> 0000000000000660
>>>> [81133.348462] Stack:
>>>> [81133.358005]  ffff880059bb7898 ffffffff8110fe3f ffffffff810fc261
>>>> 0000000000000200
>>>> [81133.367682]  0000000000000003 ffff88000e20ad68 0000000000000000
>>>> ffff88005854d400
>>>> [81133.377064]  0000000000015f90 0000000000000000 ffff880059bb78c8
>>>> ffffffff819b5243
>>>> [81133.386374] Call Trace:
>>>> [81133.395596]  [<ffffffff8110fe3f>] mod_timer_pending+0x3f/0xe0
>>>> [81133.404999]  [<ffffffff810fc261>] ?
>>>> __raw_callee_save___pv_queued_spin_unlock+0x11/0x20
>>>> [81133.414255]  [<ffffffff819b5243>] __nf_ct_refresh_acct+0xa3/0xb0
>>>> [81133.423137]  [<ffffffff819bbe8b>] tcp_packet+0xb3b/0x1290
>>>> [81133.431894]  [<ffffffff810cb8ca>] ? 
>>>> __local_bh_enable_ip+0x2a/0x90
>>>> [81133.440622]  [<ffffffff819b4939>] ?
>>>> __nf_conntrack_find_get+0x129/0x2a0
>>>> [81133.449339]  [<ffffffff819b682c>] nf_conntrack_in+0x29c/0x7c0
>>>> [81133.457940]  [<ffffffff81a67181>] ipv4_conntrack_in+0x21/0x30
>>>> [81133.466296]  [<ffffffff819aea1c>] nf_iterate+0x4c/0x80
>>>> [81133.474401]  [<ffffffff819aeab4>] nf_hook_slow+0x64/0xc0
>>>> [81133.482615]  [<ffffffff81a211ec>] ip_rcv+0x2ec/0x380
>>>> [81133.490781]  [<ffffffff81a209f0>] ?
>>>> ip_local_deliver_finish+0x130/0x130
>>>> [81133.498790]  [<ffffffff8197e140>]
>>>> __netif_receive_skb_core+0x2a0/0x970
>>>> [81133.506714]  [<ffffffff81a56db8>] ? inet_gro_receive+0x1c8/0x200
>>>> [81133.514609]  [<ffffffff81980705>] __netif_receive_skb+0x15/0x70
>>>> [81133.522333]  [<ffffffff8198077e>]
>>>> netif_receive_skb_internal+0x1e/0x80
>>>> [81133.529840]  [<ffffffff81980f3b>] napi_gro_receive+0x6b/0x90
>>>> [81133.537173]  [<ffffffff81740fb6>] rtl8169_poll+0x2e6/0x600
>>>> [81133.544444]  [<ffffffff810fc261>] ?
>>>> __raw_callee_save___pv_queued_spin_unlock+0x11/0x20
>>>> [81133.551566]  [<ffffffff81981ad7>] net_rx_action+0x1f7/0x300
>>>> [81133.558412]  [<ffffffff810cb6c3>] __do_softirq+0x103/0x210
>>>> [81133.565353]  [<ffffffff810cb807>] run_ksoftirqd+0x37/0x60
>>>> [81133.572359]  [<ffffffff810e4de0>] smpboot_thread_fn+0x130/0x190
>>>> [81133.579215]  [<ffffffff810e4cb0>] ? sort_range+0x20/0x20
>>>> [81133.586042]  [<ffffffff810e1fae>] kthread+0xee/0x110
>>>> [81133.592792]  [<ffffffff810e1ec0>] ?
>>>> kthread_create_on_node+0x1b0/0x1b0
>>>> [81133.599694]  [<ffffffff81af92df>] ret_from_fork+0x3f/0x70
>>>> [81133.606662]  [<ffffffff810e1ec0>] ?
>>>> kthread_create_on_node+0x1b0/0x1b0
>>>> [81133.613445] Code: 77 28 5d c3 66 66 66 66 66 66 2e 0f 1f 84 00 00
>>>> 00
>>>> 00 00 48 8b 47 08 55 48 89 e5 48 85 c0 74 6a 48 8b 0f 48 85 c9 48 89
>>>> 08
>>>> 74 04 <48> 89 41 08 84 d2 74 08 48 c7 47 08 00 00 00 00 f6 47 2a 10 
>>>> 48
>>>> [81133.627196] RIP  [<ffffffff8110fb18>] detach_if_pending+0x18/0x80
>>>> [81133.634036]  RSP <ffff880059bb7848>
>>>> [81133.640817] ---[ end trace eaf596e1fcf6a591 ]---
>>>> [81133.647521] Kernel panic - not syncing: Fatal exception in
>>>> interrupt
>>> This looks like the bug fixed in David Miller net tree :
>>> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=2235f2ac75fd2501c251b0b699a9632e80239a6d
>> 
>> Will pull the net-tree in and re-test.
> 
> You should not pull the 'net-next', but rather the 'net' one.
> 
> 'net' is not necessarily included in 'net-next'.

Thanks for the reminder, but luckily i was aware of that,
seen enough of your replies asking for patches to be resubmitted
against "the other tree" ;)
Kernel with patch is currently running so fingers crossed.

--
Sander
