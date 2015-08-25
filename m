From: Cong Wang <cwang@twopensource.com>
Subject: WARNING at net/ipv4/netfilter/ip_tables.c:530
Date: Tue, 25 Aug 2015 11:04:14 -0700
Message-ID: <CAHA+R7NZrw-jc0r8HvhN7b6BmV32w+_ONZ9Ft8vJCgsF332AOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Florian

Your commit 98d1bd802cdbc8f56868fae51edec13e86b59515 (netfilter:
xtables: compute exact size needed for jumpstack) introduced the
following kernel warning during boot.

It looks like the if check inside mark_source_chains() isn't correct,
this causes calldepth not increased as expected, but I don't have time
to dig this.

Let me know if you need more information.

[   46.310023] ------------[ cut here ]------------
[   46.314701] WARNING: CPU: 3 PID: 719 at
net/ipv4/netfilter/ip_tables.c:530 mark_source_chains+0x16b/0x20e()
[   46.321091] CPU: 3 PID: 719 Comm: iptables Not tainted 4.2.0-rc7+ #1095
[   46.325061] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   46.328713]  0000000000000009 ffff8800d3d43c08 ffffffff81a6b5f4
0000000000000000
[   46.334895]  0000000000000000 ffff8800d3d43c48 ffffffff8107a382
ffff8800d3d43c28
[   46.342152]  ffffffff8194c17f ffff880118b98368 0000000000002580
0000000000000000
[   46.348474] Call Trace:
[   46.350123]  [<ffffffff81a6b5f4>] dump_stack+0x4c/0x65
[   46.353416]  [<ffffffff8107a382>] warn_slowpath_common+0x9c/0xb6
[   46.357157]  [<ffffffff8194c17f>] ? mark_source_chains+0x16b/0x20e
[   46.361080]  [<ffffffff8107a467>] warn_slowpath_null+0x1a/0x1c
[   46.364684]  [<ffffffff8194c17f>] mark_source_chains+0x16b/0x20e
[   46.368388]  [<ffffffff8194c3fd>] translate_table+0x1db/0x3a7
[   46.372787]  [<ffffffff81167f1b>] ? __might_fault+0x8d/0x94
[   46.376343]  [<ffffffff81167ed2>] ? __might_fault+0x44/0x94
[   46.381281]  [<ffffffff8194c6bc>] do_ipt_set_ctl+0xf3/0x18a
[   46.384871]  [<ffffffff81873db2>] nf_setsockopt+0x45/0x50
[   46.388290]  [<ffffffff818f8dae>] ? ip_setsockopt+0x61/0x94
[   46.391675]  [<ffffffff818f8dc4>] ip_setsockopt+0x77/0x94
[   46.395184]  [<ffffffff810e41cb>] ? current_kernel_time+0xe/0x32
[   46.399018]  [<ffffffff8191689f>] raw_setsockopt+0x20/0x84
[   46.467342]  [<ffffffff811b9552>] ? __fdget+0x13/0x15
[   46.536339]  [<ffffffff817f600d>] sock_common_setsockopt+0x14/0x16
[   46.607792]  [<ffffffff817efcbf>] SYSC_setsockopt+0x7a/0xa1
[   46.676808]  [<ffffffff817f17d7>] SyS_setsockopt+0xe/0x10
[   46.742973]  [<ffffffff81a77457>] entry_SYSCALL_64_fastpath+0x12/0x6f
[   46.808948] ---[ end trace 2adf1c5bb5b8e904 ]---
