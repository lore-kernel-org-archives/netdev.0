From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH 0/6 v2 net-next] rhashtable fixes
Date: Fri, 6 Feb 2015 10:36:02 +0800
Message-ID: <54D42892.3030808@windriver.com>
References: <cover.1423097592.git.tgraf@suug.ch> <54D2D656.8060709@windriver.com> <20150205084737.GA15549@casper.infradead.org> <54D3346E.4040302@windriver.com> <20150205101954.GA24388@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<herbert@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34693 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949AbbBFCiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 21:38:02 -0500
In-Reply-To: <20150205101954.GA24388@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/2015 06:19 PM, Thomas Graf wrote:
> On 02/05/15 at 05:14pm, Ying Xue wrote:
>> On 02/05/2015 04:47 PM, Thomas Graf wrote:
>>> On 02/05/15 at 10:32am, Ying Xue wrote:
>>>> After I applied the sires, it sounds like panic doesn't occur any more. But soft
>>>> lockup still happens although the frequency of its reproduction is much lower
>>>> than before. Please take a look at its relevant log:
>>>
>>> Thanks for testing and the report. I had run your bind_netlink test
>>> overnight on a 4 CPU VM. Anything particular that might help trigger it?
> 
> Thanks. I will keep trying to reproduce. Can you try the following
> patch in the meantime?
>

After I applied the below change on the latest net-next tree with the series
patches, panic happens during kernel boot stage as follows:

[    0.720502] smpboot: Total of 8 processors activated (54278.37 BogoMIPS)
[    0.728325] devtmpfs: initialized
[    0.729961] evm: security.selinux
[    0.730308] evm: security.SMACK64
[    0.730600] evm: security.capability
[    0.732507] RTC time:  2:26:37, date: 02/06/15
[    0.733240] NET: Registered protocol family 16
[    0.733729] BUG: unable to handle kernel paging request at ffff880042724fb0
[    0.734371] IP: [<ffffffff8139dd82>] __rhashtable_insert+0x22/0xb0
[    0.734936] PGD 2c50067 PUD 0
[    0.735254] Oops: 0000 [#1] SMP
[    0.735578] Modules linked in:
[    0.735870] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.19.0-rc6+ #186
[    0.736000] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[    0.736000] task: ffff880016db8000 ti: ffff880016db4000 task.ti: ffff880016db4000
[    0.736000] RIP: 0010:[<ffffffff8139dd82>]  [<ffffffff8139dd82>]
__rhashtable_insert+0x22/0xb0
[    0.736000] RSP: 0000:ffff880016db7b78  EFLAGS: 00010286
[    0.736000] RAX: 0000000000000000 RBX: ffff880016500000 RCX: 000000000574ff73
[    0.736000] RDX: ffff880016ca5400 RSI: ffff88001651be08 RDI: ffff880016500000
[    0.736000] RBP: ffff880016db7bb8 R08: 0000000000000000 R09: 0000000000000001
[    0.736000] R10: 0000000000000000 R11: 0000000000000001 R12: ffff880016ca5400
[    0.736000] R13: ffff880016ca5400 R14: 000000000574ff73 R15: ffff880016ca5400
[    0.736000] FS:  0000000000000000(0000) GS:ffff880017c00000(0000)
knlGS:0000000000000000
[    0.736000] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    0.736000] CR2: ffff880042724fb0 CR3: 0000000001c11000 CR4: 00000000000006f0
[    0.736000] Stack:
[    0.736000]  0574ff7300000000 ffff880016ca5400 ffff880016db7bb8 ffff880016500000
[    0.736000]  ffff88001651be08 ffff880016ca5400 000000000574ff73 ffff880016ca5400
[    0.736000]  ffff880016db7c18 ffffffff8139e841 ffffffff8139e775 ffff88001651b800
[    0.736000] Call Trace:
[    0.736000]  [<ffffffff8139e841>] rhashtable_lookup_compare_insert+0x101/0x110
[    0.736000]  [<ffffffff8139e775>] ? rhashtable_lookup_compare_insert+0x35/0x110
[    0.736000]  [<ffffffff8165d800>] ? jhash+0xe0/0x160
[    0.736000]  [<ffffffff8165e1b3>] ? netlink_insert+0x43/0xf0
[    0.736000]  [<ffffffff8165e201>] netlink_insert+0x91/0xf0
[    0.736000]  [<ffffffff81660a31>] __netlink_kernel_create+0x121/0x260
[    0.736000]  [<ffffffff816288cf>] ? register_pernet_subsys+0x1f/0x50
[    0.736000]  [<ffffffff8164136d>] rtnetlink_net_init+0x4d/0x70
[    0.736000]  [<ffffffff81641fe0>] ? rtnl_unlock+0x10/0x10
[    0.736000]  [<ffffffff8162848e>] ops_init+0x4e/0x150
[    0.736000]  [<ffffffff810a6afd>] ? trace_hardirqs_on+0xd/0x10
[    0.736000]  [<ffffffff81628793>] register_pernet_operations+0xf3/0x190
[    0.736000]  [<ffffffff810a6afd>] ? trace_hardirqs_on+0xd/0x10
[    0.736000]  [<ffffffff816288de>] register_pernet_subsys+0x2e/0x50
[    0.736000]  [<ffffffff81d89e03>] rtnetlink_init+0x10/0x16b
[    0.736000]  [<ffffffff81d8b0bf>] netlink_proto_init+0x194/0x1af
[    0.736000]  [<ffffffff8165d720>] ? __tcf_em_tree_match+0x160/0x160
[    0.736000]  [<ffffffff8139d380>] ? percpu_ida_alloc+0x3c0/0x3c0
[    0.736000]  [<ffffffff8139d3b0>] ? rht_grow_above_75+0x30/0x30
[    0.736000]  [<ffffffff81d8af2b>] ? tc_action_init+0x55/0x55
[    0.736000]  [<ffffffff810002d9>] do_one_initcall+0x89/0x1c0
[    0.736000]  [<ffffffff81d361a1>] kernel_init_freeable+0x1a3/0x23d
[    0.736000]  [<ffffffff81d358f2>] ? do_early_param+0x86/0x86
[    0.736000]  [<ffffffff8174fa10>] ? rest_init+0xd0/0xd0
[    0.736000]  [<ffffffff8174fa1e>] kernel_init+0xe/0xf0
[    0.736000]  [<ffffffff81766eec>] ret_from_fork+0x7c/0xb0
[    0.736000]  [<ffffffff8174fa10>] ? rest_init+0xd0/0xd0
[    0.736000] Code: 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 48 83 ec 40 4c 89 75
f0 41 89 ce 48 89 5d d8 4c 89 65 e0 4c 89 6d e8 49 89 d4 4c 89 7d f8 <4a> 8b 54
f2 18 48 89 fb 49 89 f5 4c 89 e7 89 ce 41 89 cf 48 89
[    0.736000] RIP  [<ffffffff8139dd82>] __rhashtable_insert+0x22/0xb0
[    0.736000]  RSP <ffff880016db7b78>
[    0.736000] CR2: ffff880042724fb0
[    0.736000] ---[ end trace 0747bcdb7a563e55 ]---
[    0.736000] Kernel panic - not syncing: Fatal exception in interrupt
[    0.736000] ---[ end Kernel panic - not syncing: Fatal exception in interrupt

Regards,
Ying

> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index 5919d63..1c65be2 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -593,7 +593,7 @@ void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
>  
>  	tbl = rht_dereference_rcu(ht->future_tbl, ht);
>  	old_tbl = rht_dereference_rcu(ht->tbl, ht);
> -	hash = head_hashfn(ht, tbl, obj);
> +	hash = obj_raw_hashfn(ht, rht_obj(ht, obj));
>  
>  	lock_buckets(tbl, old_tbl, hash);
>  	__rhashtable_insert(ht, obj, tbl, hash);
> @@ -835,7 +835,7 @@ bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
>  	rcu_read_lock();
>  	old_tbl = rht_dereference_rcu(ht->tbl, ht);
>  	new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
> -	new_hash = head_hashfn(ht, new_tbl, obj);
> +	new_hash = obj_raw_hashfn(ht, rht_obj(ht, obj));
>  
>  	lock_buckets(new_tbl, old_tbl, new_hash);
>  
> 
> 
> 
