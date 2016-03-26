From: wangyufen <wangyufen@huawei.com>
Subject: [ask for help and advice] fib6_del triggered BUG_ON, because
 rt->rt6i_ref counter is 2
Date: Sat, 26 Mar 2016 15:10:36 +0800
Message-ID: <56F635EC.6090009@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:19576 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbcCZHLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2016 03:11:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all

I used kernel-3.4 and applied patch 
   "6e9e16e6143b72 ipv6: replacing a rt6_info needs to purge possible propagated rt6_infos too", 

I'm not sure which opertion triggered the BUG_ON, from vmcore, I got that 
    rt6i_ref's counter is 0x2 and rt6i_dst is ff02::02

Until now ,the BUG_ON triggered 3 times, rt6i_dst always multicast address (ff02::XXX), 

So, I guess maybe there are some issues on fib6_add/fib6_del multicast address routes.


The latest BUG_ON logs:
<2>[  407.197464] kernel BUG at /usr/src/packages/BUILD/kernel-default-3.4.24.19/linux-3.4/net/ipv6/ip6_fib.c:655!
<4>[  407.220891] Pid: 0, comm: swapper/8 Tainted: P        W  O 3.4.24.19-0.11-default 
<4>[  407.220896] RIP: 0010:[<ffffffff813f3b79>]  [<ffffffff813f3b79>] fib6_purge_rt+0xe9/0xf0
<4>[  407.222627] RSP: 0018:ffff8801a1f05c30  EFLAGS: 00010202
<4>[  407.222629] RAX: 0000000000000002 RBX: ffff880172d70c80 RCX: 000000018040001c
<4>[  407.222631] RDX: ffffffff81856d00 RSI: 0000000000000000 RDI: ffff880172d70c80
<4>[  407.222633] RBP: ffff8801a1f05c50 R08: ffff880121f26d00 R09: 000000018040001c
<4>[  407.222635] R10: 0000000021f26601 R11: 0000000000000004 R12: ffff88013b9eeac0
<4>[  407.222636] R13: ffff8801a1f05cf8 R14: ffffffff81856d00 R15: ffff8801596f4200
<4>[  407.222639] FS:  0000000000000000(0000) GS:ffff8801a1f00000(0000) knlGS:0000000000000000
<4>[  407.222641] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
<4>[  407.222643] CR2: 00007f0b4c0136b0 CR3: 0000000103558000 CR4: 00000000001407e0
<4>[  407.222645] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[  407.222647] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[  407.222650] Process swapper/8 (pid: 0, threadinfo ffff88017f746000, task ffff880173389720)
<4>[  407.223060] Stack:
<4>[  407.223144]  ffff880121f26640 ffff8801a1f05cf8 ffffffff81856d00 ffff880172d70c80
<4>[  407.223474]  ffff8801a1f05ce0 ffffffff813f4b25 0000000000000092 ffff8801a1f05c78
<4>[  407.223804]  ffff8801546fdc80 ffff8801a1f05cd8 ffffffff8106a2dd ffff880159610048
<4>[  407.224133]  ffff8801a1f14788 000000000000000d 000000000000000d ffff8801a1f14700
<4>[  407.224472]  ffff88017fe17ee8 ffffffffa2effad0 ffff880172d70c80 ffff8801a1f05d90
<4>[  407.224809]  0000000000000000 ffffffff813f2dd0 ffff8801a1f05d20 ffffffff813f4c59
<4>[  407.225139]  ffffffff810585f1 0000000000000000 ffffffff81856d00 0000000000000000
<4>[  407.225484]  ffff8801a1f05d90 ffff8801596f4218 ffff8801a1f05d40 ffffffff813f2c66
<4>[  407.225822]  ffff8801a1f05d40 ffff8801a1f05d90 ffff8801a1f05d70 ffffffff813f2cf5
<4>[  407.226152]  ffff8801a1f05d70 ffffffff81451489 ffff8801a1f05d70 ffffffff81856d00
<4>[  407.226481]  ffff8801a1f05e20 ffffffff813f4e3c 00000000000007f8 00ffffff81857100
<4>[  407.226825]  ffffffff818610a0 ffffffff818610a0 ffff8801596f4230 ffff88013b026f80
<4>[  407.227154]  0000000000000000 000000003a310004 0000000000000006 ffffffff813f4bf0
<4>[  407.227484]  ffff8801a1f05e00 ffffffff81856d00 ffffffff813f2dd0 0000000000000000
<4>[  407.227828]  ffff8801a1f05e00 ffffffff81856d00 0000000000001d4c 0000000000000100
<4>[  407.228159]  ffffffff813f4f60 143dd57c7c88b3b2
<4>[  407.228243] Call Trace:
<4>[  407.228245]  <IRQ> 
<4>[  407.228249]  [<ffffffff813f4b25>] fib6_del+0x1e5/0x2b0
<4>[  407.228255]  [<ffffffff8106a2dd>] ? try_to_wake_up+0x1dd/0x2e0
<4>[  407.228265]  [<ffffffff813f2dd0>] ? fib6_dump_node+0x80/0x80
<4>[  407.228268]  [<ffffffff813f4c59>] fib6_clean_node+0x69/0xd0
<4>[  407.228272]  [<ffffffff810585f1>] ? autoremove_wake_function+0x11/0x40
<4>[  407.228276]  [<ffffffff813f2c66>] fib6_walk_continue+0x176/0x1b0
<4>[  407.228279]  [<ffffffff813f2cf5>] fib6_walk+0x55/0xb0
<4>[  407.228284]  [<ffffffff81451489>] ? _raw_write_lock_bh+0x19/0x20
<4>[  407.228287]  [<ffffffff813f4e3c>] fib6_clean_all+0x9c/0xe0
<4>[  407.228290]  [<ffffffff813f4bf0>] ? fib6_del+0x2b0/0x2b0
<4>[  407.228293]  [<ffffffff813f2dd0>] ? fib6_dump_node+0x80/0x80
<4>[  407.228297]  [<ffffffff813f4f60>] ? fib6_run_gc+0xe0/0xe0
<4>[  407.228300]  [<ffffffff813f4ecb>] fib6_run_gc+0x4b/0xe0
<4>[  407.228303]  [<ffffffff813f4f73>] fib6_gc_timer_cb+0x13/0x20
<4>[  407.228308]  [<ffffffff8104606f>] run_timer_softirq+0x14f/0x340
<4>[  407.228312]  [<ffffffff8108386f>] ? ktime_get+0x5f/0xe0
<4>[  407.228316]  [<ffffffff8103e5a1>] __do_softirq+0xd1/0x200
<4>[  407.228320]  [<ffffffff8105c7cc>] ? hrtimer_interrupt+0x12c/0x230
<4>[  407.228324]  [<ffffffff8145a5cc>] call_softirq+0x1c/0x30
<4>[  407.228330]  [<ffffffff8100414d>] do_softirq+0x6d/0xa0
<4>[  407.228333]  [<ffffffff8103e965>] irq_exit+0xa5/0xb0
<4>[  407.228337]  [<ffffffff810212f9>] smp_apic_timer_interrupt+0x69/0xa0
<4>[  407.228341]  [<ffffffff81459c0a>] apic_timer_interrupt+0x6a/0x70
<4>[  407.228342]  <EOI> 
<4>[  407.228366]  [<ffffffffa0e08972>] ? arch_local_irq_enable+0xb/0xd [processor]
<4>[  407.228379]  [<ffffffffa0e09308>] acpi_idle_enter_c1+0x90/0xba [processor]
<4>[  407.228390]  [<ffffffff81326b69>] cpuidle_enter+0x19/0x20
<4>[  407.228393]  [<ffffffff813271a3>] cpuidle_idle_call+0xb3/0x260
<4>[  407.228397]  [<ffffffff8100b255>] cpu_idle+0x65/0xd0
<4>[  407.228401]  [<ffffffff814414a2>] start_secondary+0x200/0x202
<4>[  407.228403] Code: 48 89 55 e0 48 89 75 e8 e8 75 58 f6 ff 48 8b 75 e8 48 8b 55 e0 e9 56 ff ff ff 0f 1f 84 00 00 00 00 00 48 8b 82 90 03 00 00 eb 87 <0f> 0b 0f 1f 44 00 00 55 41 89 d2 48 89 e5 41 57 41 56 41 55 49 
<1>[  407.228432] RIP  [<ffffffff813f3b79>] fib6_purge_rt+0xe9/0xf0
<4>[  407.228435]  RSP <ffff8801a1f05c30>
