From: Rick Jones <rick.jones2@hp.com>
Subject: Re: large degradation in ip netns add/exec performance in 3.13?
Date: Tue, 11 Feb 2014 16:56:49 -0800
Message-ID: <52FAC6D1.50702@hp.com>
References: <52F1461D.8050703@hp.com> <52FAA3A6.9050608@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030605010800050300060809"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:29944 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbaBLA4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 19:56:51 -0500
Received: from g9t2301.houston.hp.com (g9t2301.houston.hp.com [16.216.185.78])
	by g4t0015.houston.hp.com (Postfix) with ESMTP id 674208009
	for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 00:56:50 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g9t2301.houston.hp.com (Postfix) with ESMTP id 1659C78
	for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 00:56:50 +0000 (UTC)
In-Reply-To: <52FAA3A6.9050608@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030605010800050300060809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 02/11/2014 02:26 PM, Rick Jones wrote:
> I did have the system lockup once at 16 concurrent streams on the 3.13.0
> kernel.  Didn't happen the next two times I tried.

I've had it happen again with a slightly tweaked ("heavier") fake router 
creation.  I'm guessing the attached soft lockup messages are related 
and may help point somewhere.

happy benchmarking,

rick jones


--------------030605010800050300060809
Content-Type: text/plain; charset=UTF-8;
 name="16_stream_lockup_dmesg.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="16_stream_lockup_dmesg.txt"

[  200.884083] BUG: soft lockup - CPU#12 stuck for 23s! [ip:34798]
[  200.911571] Modules linked in: veth ipmi_devintf 8021q garp xt_CHECKSUM iptable_mangle bridge stp llc kvm_intel kvm bonding ipt_REJECT xt_LOG xt_limit xt_tcpudp xt_addrtype nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter psmouse ip6_tables iptable_filter ip_tables x_tables gpio_ich igb mpt2sas i2c_algo_bit sb_edac scsi_transport_sas ptp ioatdma ipmi_si serio_raw hpwdt edac_core lpc_ich pps_core hpilo be2net dca ipmi_msghandler raid_class mac_hid acpi_power_meter lp parport shpchp hpsa
[  200.911599] CPU: 12 PID: 34798 Comm: ip Not tainted 3.13.0 #1
[  200.911600] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  200.911602] task: ffff880fe4d3ae60 ti: ffff880fe4c9e000 task.ti: ffff880fe4c9e000
[  200.911603] RIP: 0010:[<ffffffff811ad1e8>]  [<ffffffff811ad1e8>] __lookup_mnt+0x68/0x80
[  200.911609] RSP: 0018:ffff880fe4c9fcd8  EFLAGS: 00000282
[  200.911610] RAX: ffff880fe7151400 RBX: ffffffff8119859b RCX: ffff881ff9464370
[  200.911612] RDX: ffff880fe7151420 RSI: ffff8800b985e9c0 RDI: ffff880fe94cd1a0
[  200.911613] RBP: ffff880fe4c9fce8 R08: 326f6d7500737973 R09: ffff8800b985e9c0
[  200.911614] R10: 003f010100030103 R11: ffffc90000002000 R12: ffff880fe4c9fe00
[  200.911615] R13: ffff880fe244bc08 R14: 0000000000000000 R15: ffff881fe9ce21f0
[  200.911616] FS:  00007fe7048e0700(0000) GS:ffff88203f880000(0000) knlGS:0000000000000000
[  200.911617] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  200.911618] CR2: 000000000043e408 CR3: 0000001fe94bf000 CR4: 00000000000407e0
[  200.911620] Stack:
[  200.911621]  ffff881fe87c62fc ffff880fe7151400 ffff880fe4c9fd18 ffffffff811ad2b0
[  200.911624]  ffff880fe4c9fdb8 ffff880fe4c9ff28 ffff881ff65949c0 ffff880fe4c9ff28
[  200.911626]  ffff880fe4c9fd38 ffffffff8119855e ffff880fe4c9fda8 ffff881ff65949c0
[  200.911629] Call Trace:
[  200.911632]  [<ffffffff811ad2b0>] lookup_mnt+0x30/0x70
[  200.911636]  [<ffffffff8119855e>] follow_mount+0x5e/0x70
[  200.911639]  [<ffffffff81199070>] mountpoint_last+0xc0/0x1d0
[  200.911641]  [<ffffffff8119ad47>] path_mountpoint+0xd7/0x440
[  200.911646]  [<ffffffff810953c9>] ? __rwsem_do_wake+0x119/0x170
[  200.911651]  [<ffffffff81352e17>] ? call_rwsem_wake+0x17/0x30
[  200.911655]  [<ffffffff8117f551>] ? kmem_cache_alloc+0x31/0x160
[  200.911657]  [<ffffffff8119922c>] ? getname_flags+0x5c/0x190
[  200.911659]  [<ffffffff8119b0e4>] filename_mountpoint+0x34/0xc0
[  200.911661]  [<ffffffff8119e65a>] user_path_mountpoint_at+0x4a/0x70
[  200.911664]  [<ffffffff811adcef>] SyS_umount+0x7f/0x3b0
[  200.911665]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  200.911669]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  200.911670] Code: 48 8b 55 f8 31 c0 48 39 ca 74 2b 48 89 d0 eb 13 0f 1f 00 48 8b 00 48 89 45 f8 48 8b 45 f8 48 39 c8 74 18 48 8b 50 10 48 83 c2 20 <48> 39 d7 75 e3 48 39 70 18 75 dd c9 c3 0f 1f 00 31 c0 c9 c3 0f 
[  228.897796] BUG: soft lockup - CPU#12 stuck for 23s! [ip:34798]
[  228.925134] Modules linked in: veth ipmi_devintf 8021q garp xt_CHECKSUM iptable_mangle bridge stp llc kvm_intel kvm bonding ipt_REJECT xt_LOG xt_limit xt_tcpudp xt_addrtype nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter psmouse ip6_tables iptable_filter ip_tables x_tables gpio_ich igb mpt2sas i2c_algo_bit sb_edac scsi_transport_sas ptp ioatdma ipmi_si serio_raw hpwdt edac_core lpc_ich pps_core hpilo be2net dca ipmi_msghandler raid_class mac_hid acpi_power_meter lp parport shpchp hpsa
[  228.925152] CPU: 12 PID: 34798 Comm: ip Not tainted 3.13.0 #1
[  228.925153] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  228.925154] task: ffff880fe4d3ae60 ti: ffff880fe4c9e000 task.ti: ffff880fe4c9e000
[  228.925155] RIP: 0010:[<ffffffff811ad1e0>]  [<ffffffff811ad1e0>] __lookup_mnt+0x60/0x80
[  228.925157] RSP: 0018:ffff880fe4c9fcd8  EFLAGS: 00000287
[  228.925158] RAX: ffff880fe7150000 RBX: ffffffff8119859b RCX: ffff881ff9464370
[  228.925159] RDX: 0000000000000022 RSI: ffff8800b985e9c0 RDI: ffff880fe94cd1a0
[  228.925160] RBP: ffff880fe4c9fce8 R08: 326f6d7500737973 R09: ffff8800b985e9c0
[  228.925161] R10: 003f010100030103 R11: ffffc90000002000 R12: ffff880fe4c9fe00
[  228.925162] R13: ffff880fe244bc08 R14: 0000000000000000 R15: ffff881fe9ce21f0
[  228.925163] FS:  00007fe7048e0700(0000) GS:ffff88203f880000(0000) knlGS:0000000000000000
[  228.925165] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  228.925165] CR2: 000000000043e408 CR3: 0000001fe94bf000 CR4: 00000000000407e0
[  228.925166] Stack:
[  228.925167]  ffff881fe87c62fc ffff880fe7150000 ffff880fe4c9fd18 ffffffff811ad2b0
[  228.925170]  ffff880fe4c9fdb8 ffff880fe4c9ff28 ffff881ff65949c0 ffff880fe4c9ff28
[  228.925173]  ffff880fe4c9fd38 ffffffff8119855e ffff880fe4c9fda8 ffff881ff65949c0
[  228.925175] Call Trace:
[  228.925177]  [<ffffffff811ad2b0>] lookup_mnt+0x30/0x70
[  228.925179]  [<ffffffff8119855e>] follow_mount+0x5e/0x70
[  228.925181]  [<ffffffff81199070>] mountpoint_last+0xc0/0x1d0
[  228.925183]  [<ffffffff8119ad47>] path_mountpoint+0xd7/0x440
[  228.925185]  [<ffffffff810953c9>] ? __rwsem_do_wake+0x119/0x170
[  228.925188]  [<ffffffff81352e17>] ? call_rwsem_wake+0x17/0x30
[  228.925190]  [<ffffffff8117f551>] ? kmem_cache_alloc+0x31/0x160
[  228.925192]  [<ffffffff8119922c>] ? getname_flags+0x5c/0x190
[  228.925194]  [<ffffffff8119b0e4>] filename_mountpoint+0x34/0xc0
[  228.925196]  [<ffffffff8119e65a>] user_path_mountpoint_at+0x4a/0x70
[  228.925198]  [<ffffffff811adcef>] SyS_umount+0x7f/0x3b0
[  228.925200]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  228.925201]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  228.925202] Code: 00 48 8b 01 48 89 45 f8 48 8b 55 f8 31 c0 48 39 ca 74 2b 48 89 d0 eb 13 0f 1f 00 48 8b 00 48 89 45 f8 48 8b 45 f8 48 39 c8 74 18 <48> 8b 50 10 48 83 c2 20 48 39 d7 75 e3 48 39 70 18 75 dd c9 c3 
[  235.981280] INFO: rcu_sched self-detected stall on CPU
[  235.993270] INFO: rcu_sched detected stalls on CPUs/tasks: { 12} (detected by 28, t=15003 jiffies, g=5308, c=5307, q=11411)
[  235.993279] sending NMI to all CPUs:
[  235.993295] NMI backtrace for cpu 0
[  235.993302] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0 #1
[  235.993304] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.993307] task: ffffffff81c104a0 ti: ffffffff81c00000 task.ti: ffffffff81c00000
[  235.993310] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.993328] RSP: 0018:ffffffff81c01de8  EFLAGS: 00000046
[  235.993330] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.993331] RDX: 0000000000000000 RSI: ffffffff81c01fd8 RDI: 0000000000000000
[  235.993354] RBP: ffffffff81c01e18 R08: 0000000000000a75 R09: 0000000000000f79
[  235.993354] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.993355] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.993356] FS:  0000000000000000(0000) GS:ffff880fffa00000(0000) knlGS:0000000000000000
[  235.993357] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.993357] CR2: 00007f0f59fa6000 CR3: 0000000001c0b000 CR4: 00000000000407f0
[  235.993358] Stack:
[  235.993359]  ffffffff81c01e18 00000000810af234 ffffe8efbfc01100 00000036d7ae4eff
[  235.993361]  ffffffff81c88a30 ffffffff81c88860 ffffffff81c01e78 ffffffff81568a4f
[  235.993364]  0000000000000000 00000000014434f8 0000000000000000 00000000014434f8
[  235.993366] Call Trace:
[  235.993367]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.993371]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.993373]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.993377]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.993379]  [<ffffffff816a2337>] rest_init+0x77/0x80
[  235.993383]  [<ffffffff81d09e8c>] start_kernel+0x3f7/0x404
[  235.993386]  [<ffffffff81d09895>] ? repair_env_string+0x5a/0x5a
[  235.993388]  [<ffffffff81d095a8>] x86_64_start_reservations+0x2a/0x2c
[  235.993390]  [<ffffffff81d0969a>] x86_64_start_kernel+0xf0/0xf7
[  235.993391] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.993427] NMI backtrace for cpu 1
[  235.993428] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.13.0 #1
[  235.993429] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.993430] task: ffff880ff9161730 ti: ffff880ff915c000 task.ti: ffff880ff915c000
[  235.993430] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.993433] RSP: 0018:ffff880ff915ddb8  EFLAGS: 00000046
[  235.993433] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.993434] RDX: 0000000000000000 RSI: ffff880ff915dfd8 RDI: 0000000000000001
[  235.993434] RBP: ffff880ff915dde8 R08: 000000000000000d R09: 0000000000000040
[  235.993435] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.993435] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.993436] FS:  0000000000000000(0000) GS:ffff880fffa20000(0000) knlGS:0000000000000000
[  235.993437] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.993437] CR2: 00007fc7c8d25010 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.993438] Stack:
[  235.993438]  ffff880ff915dde8 00000001810af234 ffffe8efbfc21100 00000036d7ff16af
[  235.993440]  ffffffff81c88a30 ffffffff81c88860 ffff880ff915de48 ffffffff81568a4f
[  235.993442]  0000000000000000 0000000000f36688 0000000000000000 0000000000f36688
[  235.993444] Call Trace:
[  235.993445]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.993447]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.993449]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.993451]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.993452]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.993455] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.993499] NMI backtrace for cpu 2
[  235.993500] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 3.13.0 #1
[  235.993501] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.993502] task: ffff880ff9162e60 ti: ffff880ff915e000 task.ti: ffff880ff915e000
[  235.993502] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.993505] RSP: 0018:ffff880ff915fdb8  EFLAGS: 00000046
[  235.993505] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.993506] RDX: 0000000000000000 RSI: ffff880ff915ffd8 RDI: 0000000000000002
[  235.993506] RBP: ffff880ff915fde8 R08: 0000000000000009 R09: 0000000000000040
[  235.993507] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.993507] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.993508] FS:  0000000000000000(0000) GS:ffff880fffa40000(0000) knlGS:0000000000000000
[  235.993509] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.993509] CR2: 00007f0f59fa6000 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.993510] Stack:
[  235.993510]  ffff880ff915fde8 00000002810af234 ffffe8efbfc41100 00000036d7ff15cf
[  235.993512]  ffffffff81c88a30 ffffffff81c88860 ffff880ff915fe48 ffffffff81568a4f
[  235.993514]  0000000000000000 0000000000f36863 0000000000000000 0000000000f36863
[  235.993516] Call Trace:
[  235.993517]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.993519]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.993521]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.993523]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.993524]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.993526] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.993611] NMI backtrace for cpu 3
[  235.993615] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 3.13.0 #1
[  235.993616] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.993618] task: ffff880ff9164590 ti: ffff880ff9168000 task.ti: ffff880ff9168000
[  235.993620] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.993626] RSP: 0018:ffff880ff9169db8  EFLAGS: 00000046
[  235.993628] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.993629] RDX: 0000000000000000 RSI: ffff880ff9169fd8 RDI: 0000000000000003
[  235.993631] RBP: ffff880ff9169de8 R08: 000000000000000d R09: 0000000000000031
[  235.993632] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.993633] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.993635] FS:  0000000000000000(0000) GS:ffff880fffa60000(0000) knlGS:0000000000000000
[  235.993637] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.993639] CR2: 00007f1ae4ad9000 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.993640] Stack:
[  235.993641]  ffff880ff9169de8 00000003810af234 ffffe8efbfc61100 00000036d7ffdec3
[  235.993656]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9169e48 ffffffff81568a4f
[  235.993658]  0000000000000000 0000000000f292a1 0000000000000000 0000000000f292a1
[  235.993660] Call Trace:
[  235.993660]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.993663]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.993664]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.993666]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.993668]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.993670] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.993698] NMI backtrace for cpu 4
[  235.993700] CPU: 4 PID: 0 Comm: swapper/4 Not tainted 3.13.0 #1
[  235.993700] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.993701] task: ffff880ff9165cc0 ti: ffff880ff916a000 task.ti: ffff880ff916a000
[  235.993702] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.993704] RSP: 0018:ffff880ff916bdb8  EFLAGS: 00000046
[  235.993704] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.993705] RDX: 0000000000000000 RSI: ffff880ff916bfd8 RDI: 0000000000000004
[  235.993705] RBP: ffff880ff916bde8 R08: 000000000000000d R09: 0000000000000009
[  235.993706] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.993706] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.993707] FS:  0000000000000000(0000) GS:ffff880fffa80000(0000) knlGS:0000000000000000
[  235.993708] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.993708] CR2: 0000000001149088 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.993709] Stack:
[  235.993709]  ffff880ff916bde8 00000004810af234 ffffe8efbfc81100 00000036d7ff41be
[  235.993712]  ffffffff81c88a30 ffffffff81c88860 ffff880ff916be48 ffffffff81568a4f
[  235.993714]  0000000000000000 0000000000f33976 0000000000000000 0000000000f33976
[  235.993716] Call Trace:
[  235.993717]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.993719]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.993720]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.993722]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.993724]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.993726] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.993810] NMI backtrace for cpu 5
[  235.993814] CPU: 5 PID: 0 Comm: swapper/5 Not tainted 3.13.0 #1
[  235.993815] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.993817] task: ffff880ff9170000 ti: ffff880ff916c000 task.ti: ffff880ff916c000
[  235.993819] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.993825] RSP: 0018:ffff880ff916ddb8  EFLAGS: 00000046
[  235.993827] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.993828] RDX: 0000000000000000 RSI: ffff880ff916dfd8 RDI: 0000000000000005
[  235.993830] RBP: ffff880ff916dde8 R08: 000000000000000d R09: 0000000000000031
[  235.993831] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.993832] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.993834] FS:  0000000000000000(0000) GS:ffff880fffaa0000(0000) knlGS:0000000000000000
[  235.993836] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.993837] CR2: 00007ffe8c81d9b8 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.993850] Stack:
[  235.993851]  ffff880ff916dde8 00000005810af234 ffffe8efbfca1100 00000036d7ff3023
[  235.993853]  ffffffff81c88a30 ffffffff81c88860 ffff880ff916de48 ffffffff81568a4f
[  235.993855]  0000000000000000 0000000000f3588a 0000000000000000 0000000000f3588a
[  235.993857] Call Trace:
[  235.993858]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.993860]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.993861]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.993863]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.993865]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.993867] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.993899] NMI backtrace for cpu 6
[  235.993901] CPU: 6 PID: 0 Comm: swapper/6 Not tainted 3.13.0 #1
[  235.993901] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.993902] task: ffff880ff9171730 ti: ffff880ff916e000 task.ti: ffff880ff916e000
[  235.993903] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.993905] RSP: 0018:ffff880ff916fdb8  EFLAGS: 00000046
[  235.993905] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.993906] RDX: 0000000000000000 RSI: ffff880ff916ffd8 RDI: 0000000000000006
[  235.993906] RBP: ffff880ff916fde8 R08: 000000000000002d R09: 0000000000000019
[  235.993907] R10: 0000000000000002 R11: 0000000000000001 R12: 0000000000000005
[  235.993907] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.993908] FS:  0000000000000000(0000) GS:ffff880fffac0000(0000) knlGS:0000000000000000
[  235.993909] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.993909] CR2: 00007f0081b3e078 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.993910] Stack:
[  235.993910]  ffff880ff916fde8 00000006810af234 ffffe8efbfcc1100 00000036d7ffdcd9
[  235.993912]  ffffffff81c88a30 ffffffff81c88860 ffff880ff916fe48 ffffffff81568a4f
[  235.993914]  0000000000000000 00000000003b7b09 0000000000000000 00000000003b7b09
[  235.993916] Call Trace:
[  235.993917]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.993919]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.993921]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.993923]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.993924]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.993926] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.994009] NMI backtrace for cpu 7
[  235.994013] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 3.13.0 #1
[  235.994015] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.994017] task: ffff880ff9172e60 ti: ffff880ff9180000 task.ti: ffff880ff9180000
[  235.994019] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.994025] RSP: 0018:ffff880ff9181db8  EFLAGS: 00000046
[  235.994026] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.994028] RDX: 0000000000000000 RSI: ffff880ff9181fd8 RDI: 0000000000000007
[  235.994029] RBP: ffff880ff9181de8 R08: 000000000000000d R09: 0000000000000009
[  235.994030] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.994031] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.994033] FS:  0000000000000000(0000) GS:ffff880fffae0000(0000) knlGS:0000000000000000
[  235.994035] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.994048] CR2: 00007f5e36afa078 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.994048] Stack:
[  235.994049]  ffff880ff9181de8 00000007810af234 ffffe8efbfce1100 00000036d7ff4f94
[  235.994051]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9181e48 ffffffff81568a4f
[  235.994053]  0000000000000000 0000000000f339eb 0000000000000000 0000000000f339eb
[  235.994055] Call Trace:
[  235.994056]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.994058]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.994060]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.994062]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.994063]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.994065] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.994098] NMI backtrace for cpu 8
[  235.994100] CPU: 8 PID: 0 Comm: swapper/8 Not tainted 3.13.0 #1
[  235.994100] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.994101] task: ffff880ff9174590 ti: ffff880ff9182000 task.ti: ffff880ff9182000
[  235.994102] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.994112] RSP: 0018:ffff880ff9183db8  EFLAGS: 00000046
[  235.994113] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.994114] RDX: 0000000000000000 RSI: ffff880ff9183fd8 RDI: 0000000000000008
[  235.994114] RBP: ffff880ff9183de8 R08: 0000000000000001 R09: 0000000000000001
[  235.994115] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.994115] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.994116] FS:  0000000000000000(0000) GS:ffff88203f800000(0000) knlGS:0000000000000000
[  235.994117] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.994117] CR2: 00007fff61860128 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.994118] Stack:
[  235.994118]  ffff880ff9183de8 00000008810af234 ffffe8ffffa01100 00000036d7feb403
[  235.994121]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9183e48 ffffffff81568a4f
[  235.994123]  0000000000000000 0000000000f3c0d9 0000000000000000 0000000000f3c0d9
[  235.994125] Call Trace:
[  235.994126]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.994130]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.994131]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.994135]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.994138]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.994141] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.994200] NMI backtrace for cpu 9
[  235.994201] CPU: 9 PID: 0 Comm: swapper/9 Not tainted 3.13.0 #1
[  235.994202] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.994203] task: ffff880ff9175cc0 ti: ffff880ff9184000 task.ti: ffff880ff9184000
[  235.994203] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.994206] RSP: 0018:ffff880ff9185db8  EFLAGS: 00000046
[  235.994206] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.994207] RDX: 0000000000000000 RSI: ffff880ff9185fd8 RDI: 0000000000000009
[  235.994207] RBP: ffff880ff9185de8 R08: 0000000000000f9d R09: 0000000000000001
[  235.994208] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.994209] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.994209] FS:  0000000000000000(0000) GS:ffff88203f820000(0000) knlGS:0000000000000000
[  235.994210] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.994211] CR2: 00007faa9e134fbd CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.994211] Stack:
[  235.994212]  ffff880ff9185de8 00000009810af234 ffffe8ffffa21100 00000036d7feba3d
[  235.994214]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9185e48 ffffffff81568a4f
[  235.994216]  0000000000000000 0000000000f3b7eb 0000000000000000 0000000000f3b7eb
[  235.994218] Call Trace:
[  235.994219]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.994221]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.994223]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.994225]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.994227]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.994229] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.994294] NMI backtrace for cpu 10
[  235.994296] CPU: 10 PID: 0 Comm: swapper/10 Not tainted 3.13.0 #1
[  235.994296] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.994297] task: ffff880ff9188000 ti: ffff880ff9186000 task.ti: ffff880ff9186000
[  235.994298] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.994300] RSP: 0018:ffff880ff9187db8  EFLAGS: 00000046
[  235.994301] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.994301] RDX: 0000000000000000 RSI: ffff880ff9187fd8 RDI: 000000000000000a
[  235.994302] RBP: ffff880ff9187de8 R08: 0000000000000001 R09: 0000000000000001
[  235.994302] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.994303] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.994303] FS:  0000000000000000(0000) GS:ffff88203f840000(0000) knlGS:0000000000000000
[  235.994304] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.994305] CR2: 00007fff865a616c CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.994305] Stack:
[  235.994305]  ffff880ff9187de8 0000000a810af234 ffffe8ffffa41100 00000036d7feb40a
[  235.994308]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9187e48 ffffffff81568a4f
[  235.994310]  0000000000000000 0000000000f3be6a 0000000000000000 0000000000f3be6a
[  235.994312] Call Trace:
[  235.994313]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.994315]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.994317]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.994319]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.994320]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.994322] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.994396] NMI backtrace for cpu 11
[  235.994397] CPU: 11 PID: 0 Comm: swapper/11 Not tainted 3.13.0 #1
[  235.994398] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.994399] task: ffff880ff9189730 ti: ffff880ff9190000 task.ti: ffff880ff9190000
[  235.994399] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.994402] RSP: 0018:ffff880ff9191db8  EFLAGS: 00000046
[  235.994402] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.994403] RDX: 0000000000000000 RSI: ffff880ff9191fd8 RDI: 000000000000000b
[  235.994403] RBP: ffff880ff9191de8 R08: 0000000000000020 R09: 0000000000000000
[  235.994404] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.994404] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.994405] FS:  0000000000000000(0000) GS:ffff88203f860000(0000) knlGS:0000000000000000
[  235.994405] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.994406] CR2: 00007fb34e58e120 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.994406] Stack:
[  235.994407]  ffff880ff9191de8 0000000b810af234 ffffe8ffffa61100 00000036d7feb7a2
[  235.994409]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9191e48 ffffffff81568a4f
[  235.994411]  0000000000000000 0000000000f3ba28 0000000000000000 0000000000f3ba28
[  235.994413] Call Trace:
[  235.994414]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.994416]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.994418]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.994420]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.994421]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.994423] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.994474] NMI backtrace for cpu 12
[  235.994476] CPU: 12 PID: 34798 Comm: ip Not tainted 3.13.0 #1
[  235.994476] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.994477] task: ffff880fe4d3ae60 ti: ffff880fe4c9e000 task.ti: ffff880fe4c9e000
[  235.994478] RIP: 0010:[<ffffffff81428c35>]  [<ffffffff81428c35>] io_serial_in+0x15/0x20
[  235.994484] RSP: 0018:ffff88203f883b68  EFLAGS: 00000002
[  235.994485] RAX: 0000000054cf6200 RBX: ffffffff81f623e8 RCX: 0000000000000000
[  235.994485] RDX: 00000000000002fd RSI: 00000000000002fd RDI: ffffffff81f623e8
[  235.994486] RBP: ffff88203f883b68 R08: 000000000000000c R09: 0000000000000100
[  235.994487] R10: 0000000000000000 R11: ffffc90000002000 R12: 00000000000026b3
[  235.994488] R13: 0000000000000020 R14: ffffffff8142b0b0 R15: ffffffff81ea57d9
[  235.994489] FS:  00007fe7048e0700(0000) GS:ffff88203f880000(0000) knlGS:0000000000000000
[  235.994490] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.994490] CR2: 000000000043e408 CR3: 0000001fe94bf000 CR4: 00000000000407e0
[  235.994491] Stack:
[  235.994491]  ffff88203f883b98 ffffffff8142b04b ffffffff81a35a9e ffffffff81f623e8
[  235.994494]  0000000000000066 ffffffff81ea57c3 ffff88203f883bb8 ffffffff8142b0d5
[  235.994498]  ffffffff81ea57c3 ffffffff81f623e8 ffff88203f883bf8 ffffffff8142468d
[  235.994501] Call Trace:
[  235.994501]  <IRQ>  [<ffffffff8142b04b>] wait_for_xmitr+0x3b/0xa0
[  235.994506]  [<ffffffff8142b0d5>] serial8250_console_putchar+0x25/0x40
[  235.994508]  [<ffffffff8142468d>] uart_console_write+0x3d/0x70
[  235.994510]  [<ffffffff8142b25f>] serial8250_console_write+0xaf/0x140
[  235.994513]  [<ffffffff810a00d5>] call_console_drivers.constprop.17+0xa5/0x110
[  235.994515]  [<ffffffff810a0745>] console_unlock+0x2f5/0x3a0
[  235.994517]  [<ffffffff810a0c75>] vprintk_emit+0x2b5/0x510
[  235.994519]  [<ffffffff816ac2c1>] printk+0x61/0x63
[  235.994524]  [<ffffffff810ad226>] rcu_check_callbacks+0x386/0x6a0
[  235.994528]  [<ffffffff8105d248>] update_process_times+0x48/0x80
[  235.994534]  [<ffffffff810b7fc3>] tick_sched_handle.isra.11+0x33/0x70
[  235.994538]  [<ffffffff810b80ec>] tick_sched_timer+0x4c/0x80
[  235.994540]  [<ffffffff8107426c>] __run_hrtimer+0x6c/0x220
[  235.994545]  [<ffffffff810b80a0>] ? tick_nohz_handler+0xa0/0xa0
[  235.994547]  [<ffffffff81074b7f>] hrtimer_interrupt+0xff/0x240
[  235.994549]  [<ffffffff810303fb>] local_apic_timer_interrupt+0x3b/0x60
[  235.994552]  [<ffffffff816c5325>] smp_apic_timer_interrupt+0x45/0x60
[  235.994555]  [<ffffffff816c410a>] apic_timer_interrupt+0x6a/0x70
[  235.994558]  <EOI>  [<ffffffff8119859b>] ? path_get+0x2b/0x40
[  235.994561]  [<ffffffff811ad1e8>] ? __lookup_mnt+0x68/0x80
[  235.994563]  [<ffffffff811ad2b0>] lookup_mnt+0x30/0x70
[  235.994564]  [<ffffffff8119855e>] follow_mount+0x5e/0x70
[  235.994567]  [<ffffffff81199070>] mountpoint_last+0xc0/0x1d0
[  235.994569]  [<ffffffff8119ad47>] path_mountpoint+0xd7/0x440
[  235.994571]  [<ffffffff810953c9>] ? __rwsem_do_wake+0x119/0x170
[  235.994573]  [<ffffffff81352e17>] ? call_rwsem_wake+0x17/0x30
[  235.994575]  [<ffffffff8117f551>] ? kmem_cache_alloc+0x31/0x160
[  235.994578]  [<ffffffff8119922c>] ? getname_flags+0x5c/0x190
[  235.994580]  [<ffffffff8119b0e4>] filename_mountpoint+0x34/0xc0
[  235.994582]  [<ffffffff8119e65a>] user_path_mountpoint_at+0x4a/0x70
[  235.994584]  [<ffffffff811adcef>] SyS_umount+0x7f/0x3b0
[  235.994586]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  235.994588]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  235.994590] Code: 48 89 e5 d3 e6 48 63 f6 48 03 77 10 8b 06 5d c3 66 0f 1f 44 00 00 66 66 66 66 90 0f b6 4f 61 55 48 89 e5 d3 e6 03 77 08 89 f2 ec <0f> b6 c0 5d c3 66 0f 1f 44 00 00 66 66 66 66 90 0f b6 4f 61 55 
[  235.994611] NMI backtrace for cpu 13
[  235.994613] CPU: 13 PID: 0 Comm: swapper/13 Not tainted 3.13.0 #1
[  235.994613] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.994614] task: ffff880ff918c590 ti: ffff880ff9194000 task.ti: ffff880ff9194000
[  235.994615] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.994617] RSP: 0018:ffff880ff9195db8  EFLAGS: 00000046
[  235.994618] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.994618] RDX: 0000000000000000 RSI: ffff880ff9195fd8 RDI: 000000000000000d
[  235.994619] RBP: ffff880ff9195de8 R08: 0000000000000020 R09: 0000000000000001
[  235.994619] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.994620] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.994620] FS:  0000000000000000(0000) GS:ffff88203f8a0000(0000) knlGS:0000000000000000
[  235.994621] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.994622] CR2: 00007fb34e58e120 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.994622] Stack:
[  235.994623]  ffff880ff9195de8 0000000d810af234 ffffe8ffffaa1100 00000036d7feba17
[  235.994625]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9195e48 ffffffff81568a4f
[  235.994627]  0000000000000000 0000000000f3b7fa 0000000000000000 0000000000f3b7fa
[  235.994629] Call Trace:
[  235.994630]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.994632]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.994634]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.994636]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.994638]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.994640] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.994692] NMI backtrace for cpu 14
[  235.994694] CPU: 14 PID: 0 Comm: swapper/14 Not tainted 3.13.0 #1
[  235.994694] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.994695] task: ffff880ff918dcc0 ti: ffff880ff9196000 task.ti: ffff880ff9196000
[  235.994696] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.994698] RSP: 0018:ffff880ff9197db8  EFLAGS: 00000046
[  235.994699] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.994699] RDX: 0000000000000000 RSI: ffff880ff9197fd8 RDI: 000000000000000e
[  235.994700] RBP: ffff880ff9197de8 R08: 0000000000000020 R09: 0000000000000000
[  235.994700] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.994701] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.994701] FS:  0000000000000000(0000) GS:ffff88203f8c0000(0000) knlGS:0000000000000000
[  235.994702] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.994703] CR2: 00007fb34e58e120 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.994703] Stack:
[  235.994703]  ffff880ff9197de8 0000000e810af234 ffffe8ffffac1100 00000036d7feb607
[  235.994706]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9197e48 ffffffff81568a4f
[  235.994708]  0000000000000000 0000000000f3bbfa 0000000000000000 0000000000f3bbfa
[  235.994710] Call Trace:
[  235.994711]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.994713]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.994715]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.994716]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.994718]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.994720] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.994793] NMI backtrace for cpu 15
[  235.994795] CPU: 15 PID: 0 Comm: swapper/15 Not tainted 3.13.0 #1
[  235.994795] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.994796] task: ffff880ff9198000 ti: ffff880ff91a0000 task.ti: ffff880ff91a0000
[  235.994797] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.994799] RSP: 0018:ffff880ff91a1db8  EFLAGS: 00000046
[  235.994800] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.994800] RDX: 0000000000000000 RSI: ffff880ff91a1fd8 RDI: 000000000000000f
[  235.994801] RBP: ffff880ff91a1de8 R08: 0000000000000020 R09: 0000000000000001
[  235.994801] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.994801] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.994802] FS:  0000000000000000(0000) GS:ffff88203f8e0000(0000) knlGS:0000000000000000
[  235.994803] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.994803] CR2: 00007fb34e58e120 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.994804] Stack:
[  235.994804]  ffff880ff91a1de8 0000000f810af234 ffffe8ffffae1100 00000036d7feb39c
[  235.994807]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91a1e48 ffffffff81568a4f
[  235.994809]  0000000000000000 0000000000f3c5e1 0000000000000000 0000000000f3c5e1
[  235.994811] Call Trace:
[  235.994811]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.994814]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.994815]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.994817]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.994819]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.994821] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.994838] NMI backtrace for cpu 16
[  235.994843] CPU: 16 PID: 0 Comm: swapper/16 Not tainted 3.13.0 #1
[  235.994844] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.994846] task: ffff880ff9199730 ti: ffff880ff91a2000 task.ti: ffff880ff91a2000
[  235.994848] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.994854] RSP: 0018:ffff880ff91a3db8  EFLAGS: 00000046
[  235.994855] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.994857] RDX: 0000000000000000 RSI: ffff880ff91a3fd8 RDI: 0000000000000010
[  235.994870] RBP: ffff880ff91a3de8 R08: 000000000000000d R09: 0000000000000024
[  235.994870] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.994871] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.994872] FS:  0000000000000000(0000) GS:ffff880fffb00000(0000) knlGS:0000000000000000
[  235.994872] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.994873] CR2: 00007facb638d9b8 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.994873] Stack:
[  235.994874]  ffff880ff91a3de8 00000010810af234 ffffe8efbfd01100 00000036d7ff11ef
[  235.994877]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91a3e48 ffffffff81568a4f
[  235.994879]  0000000000000000 0000000000f37baa 0000000000000000 0000000000f37baa
[  235.994881] Call Trace:
[  235.994882]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.994884]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.994885]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.994887]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.994889]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.994891] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.994905] NMI backtrace for cpu 17
[  235.994907] CPU: 17 PID: 0 Comm: swapper/17 Not tainted 3.13.0 #1
[  235.994908] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.994908] task: ffff880ff919ae60 ti: ffff880ff91a4000 task.ti: ffff880ff91a4000
[  235.994909] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.994911] RSP: 0018:ffff880ff91a5db8  EFLAGS: 00000046
[  235.994912] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.994912] RDX: 0000000000000000 RSI: ffff880ff91a5fd8 RDI: 0000000000000011
[  235.994913] RBP: ffff880ff91a5de8 R08: 000000000000000d R09: 0000000000000024
[  235.994913] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.994914] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.994915] FS:  0000000000000000(0000) GS:ffff880fffb20000(0000) knlGS:0000000000000000
[  235.994915] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.994916] CR2: 00007fabfe2faf50 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.994916] Stack:
[  235.994917]  ffff880ff91a5de8 00000011810af234 ffffe8efbfd21100 00000036d7ff0c4e
[  235.994919]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91a5e48 ffffffff81568a4f
[  235.994921]  0000000000000000 0000000000f37f19 0000000000000000 0000000000f37f19
[  235.994923] Call Trace:
[  235.994924]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.994926]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.994928]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.994930]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.994931]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.994933] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.995006] NMI backtrace for cpu 18
[  235.995011] CPU: 18 PID: 0 Comm: swapper/18 Not tainted 3.13.0 #1
[  235.995012] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.995014] task: ffff880ff919c590 ti: ffff880ff91a8000 task.ti: ffff880ff91a8000
[  235.995016] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.995023] RSP: 0018:ffff880ff91a9db8  EFLAGS: 00000046
[  235.995024] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.995025] RDX: 0000000000000000 RSI: ffff880ff91a9fd8 RDI: 0000000000000012
[  235.995027] RBP: ffff880ff91a9de8 R08: 000000000000000d R09: 0000000000000010
[  235.995028] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.995029] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.995031] FS:  0000000000000000(0000) GS:ffff880fffb40000(0000) knlGS:0000000000000000
[  235.995033] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.995034] CR2: 00007fabfe295c62 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.995047] Stack:
[  235.995048]  ffff880ff91a9de8 00000012810af234 ffffe8efbfd41100 00000036d7ff1379
[  235.995050]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91a9e48 ffffffff81568a4f
[  235.995052]  0000000000000000 0000000000f37929 0000000000000000 0000000000f37929
[  235.995054] Call Trace:
[  235.995055]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.995057]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.995059]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.995060]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.995062]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.995064] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.995078] NMI backtrace for cpu 19
[  235.995080] CPU: 19 PID: 0 Comm: swapper/19 Not tainted 3.13.0 #1
[  235.995081] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.995081] task: ffff880ff919dcc0 ti: ffff880ff91aa000 task.ti: ffff880ff91aa000
[  235.995082] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.995084] RSP: 0018:ffff880ff91abdb8  EFLAGS: 00000046
[  235.995085] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.995085] RDX: 0000000000000000 RSI: ffff880ff91abfd8 RDI: 0000000000000013
[  235.995086] RBP: ffff880ff91abde8 R08: 000000000000000d R09: 0000000000000004
[  235.995086] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.995087] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.995087] FS:  0000000000000000(0000) GS:ffff880fffb60000(0000) knlGS:0000000000000000
[  235.995088] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.995089] CR2: 00007f7339703bd0 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.995089] Stack:
[  235.995089]  ffff880ff91abde8 00000013810af234 ffffe8efbfd61100 00000036d7ff4c29
[  235.995092]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91abe48 ffffffff81568a4f
[  235.995094]  0000000000000000 0000000000f35cc8 0000000000000000 0000000000f35cc8
[  235.995096] Call Trace:
[  235.995097]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.995099]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.995101]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.995102]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.995104]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.995106] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.995120] NMI backtrace for cpu 20
[  235.995122] CPU: 20 PID: 0 Comm: swapper/20 Not tainted 3.13.0 #1
[  235.995122] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.995123] task: ffff880ff91b0000 ti: ffff880ff91ac000 task.ti: ffff880ff91ac000
[  235.995124] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.995126] RSP: 0018:ffff880ff91addb8  EFLAGS: 00000046
[  235.995127] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.995127] RDX: 0000000000000000 RSI: ffff880ff91adfd8 RDI: 0000000000000014
[  235.995128] RBP: ffff880ff91adde8 R08: 000000000000000d R09: 0000000000000001
[  235.995128] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.995129] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.995129] FS:  0000000000000000(0000) GS:ffff880fffb80000(0000) knlGS:0000000000000000
[  235.995130] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.995131] CR2: 00007fabfe295c62 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.995131] Stack:
[  235.995131]  ffff880ff91adde8 00000014810af234 ffffe8efbfd81100 00000036d7ff1a17
[  235.995134]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91ade48 ffffffff81568a4f
[  235.995136]  0000000000000000 0000000000f370ed 0000000000000000 0000000000f370ed
[  235.995138] Call Trace:
[  235.995139]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.995141]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.995142]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.995144]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.995146]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.995148] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.995199] NMI backtrace for cpu 21
[  235.995201] CPU: 21 PID: 0 Comm: swapper/21 Not tainted 3.13.0 #1
[  235.995214] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.995216] task: ffff880ff91b1730 ti: ffff880ff91ae000 task.ti: ffff880ff91ae000
[  235.995218] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.995224] RSP: 0018:ffff880ff91afdb8  EFLAGS: 00000046
[  235.995226] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.995227] RDX: 0000000000000000 RSI: ffff880ff91affd8 RDI: 0000000000000015
[  235.995228] RBP: ffff880ff91afde8 R08: 000000000000000d R09: 0000000000000004
[  235.995229] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.995231] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.995233] FS:  0000000000000000(0000) GS:ffff880fffba0000(0000) knlGS:0000000000000000
[  235.995234] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.995236] CR2: 00007fabfe295c62 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.995237] Stack:
[  235.995238]  ffff880ff91afde8 00000015810af234 ffffe8efbfda1100 00000036d7ff1d29
[  235.995244]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91afe48 ffffffff81568a4f
[  235.995250]  0000000000000000 0000000000f36e28 0000000000000000 0000000000f36e28
[  235.995256] Call Trace:
[  235.995258]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.995275]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.995276]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.995278]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.995280]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.995282] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.995300] NMI backtrace for cpu 22
[  235.995301] CPU: 22 PID: 0 Comm: swapper/22 Not tainted 3.13.0 #1
[  235.995302] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.995302] task: ffff880ff91b2e60 ti: ffff880ff91c8000 task.ti: ffff880ff91c8000
[  235.995303] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.995305] RSP: 0018:ffff880ff91c9db8  EFLAGS: 00000046
[  235.995306] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.995306] RDX: 0000000000000000 RSI: ffff880ff91c9fd8 RDI: 0000000000000016
[  235.995307] RBP: ffff880ff91c9de8 R08: 000000000000000d R09: 0000000000000079
[  235.995307] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.995308] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.995309] FS:  0000000000000000(0000) GS:ffff880fffbc0000(0000) knlGS:0000000000000000
[  235.995309] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.995310] CR2: 00007fddf83e5810 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.995310] Stack:
[  235.995311]  ffff880ff91c9de8 00000016810af234 ffffe8efbfdc1100 00000036d7ffdd1b
[  235.995313]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91c9e48 ffffffff81568a4f
[  235.995315]  0000000000000000 0000000000f29605 0000000000000000 0000000000f29605
[  235.995317] Call Trace:
[  235.995318]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.995320]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.995322]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.995323]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.995325]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.995327] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.995407] NMI backtrace for cpu 23
[  235.995412] CPU: 23 PID: 0 Comm: swapper/23 Not tainted 3.13.0 #1
[  235.995413] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.995415] task: ffff880ff91b4590 ti: ffff880ff91ca000 task.ti: ffff880ff91ca000
[  235.995417] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.995423] RSP: 0018:ffff880ff91cbdb8  EFLAGS: 00000046
[  235.995424] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.995426] RDX: 0000000000000000 RSI: ffff880ff91cbfd8 RDI: 0000000000000017
[  235.995427] RBP: ffff880ff91cbde8 R08: 000000000000000d R09: 0000000000000031
[  235.995428] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.995429] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.995431] FS:  0000000000000000(0000) GS:ffff880fffbe0000(0000) knlGS:0000000000000000
[  235.995446] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.995446] CR2: 000000000042f3c0 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.995447] Stack:
[  235.995447]  ffff880ff91cbde8 00000017810af234 ffffe8efbfde1100 00000036d7ffd92e
[  235.995449]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91cbe48 ffffffff81568a4f
[  235.995451]  0000000000000000 0000000000f29813 0000000000000000 0000000000f29813
[  235.995454] Call Trace:
[  235.995454]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.995456]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.995458]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.995460]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.995461]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.995463] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.995497] NMI backtrace for cpu 24
[  235.995499] CPU: 24 PID: 0 Comm: swapper/24 Not tainted 3.13.0 #1
[  235.995499] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.995500] task: ffff880ff91b5cc0 ti: ffff880ff91cc000 task.ti: ffff880ff91cc000
[  235.995501] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.995510] RSP: 0018:ffff880ff91cddb8  EFLAGS: 00000046
[  235.995511] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.995511] RDX: 0000000000000000 RSI: ffff880ff91cdfd8 RDI: 0000000000000018
[  235.995512] RBP: ffff880ff91cdde8 R08: 0000000000000009 R09: 0000000000000001
[  235.995512] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.995513] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.995514] FS:  0000000000000000(0000) GS:ffff88203f900000(0000) knlGS:0000000000000000
[  235.995515] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.995515] CR2: 00007fb45337dbd0 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.995516] Stack:
[  235.995516]  ffff880ff91cdde8 00000018810af234 ffffe8ffffb01100 00000036d7fea5e7
[  235.995519]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91cde48 ffffffff81568a4f
[  235.995521]  0000000000000000 0000000000f3d2ba 0000000000000000 0000000000f3d2ba
[  235.995523] Call Trace:
[  235.995524]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.995526]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.995528]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.995530]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.995531]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.995533] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.995596] NMI backtrace for cpu 25
[  235.995598] CPU: 25 PID: 0 Comm: swapper/25 Not tainted 3.13.0 #1
[  235.995598] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.995599] task: ffff880ff91d0000 ti: ffff880ff91ce000 task.ti: ffff880ff91ce000
[  235.995600] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.995602] RSP: 0018:ffff880ff91cfdb8  EFLAGS: 00000046
[  235.995603] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.995603] RDX: 0000000000000000 RSI: ffff880ff91cffd8 RDI: 0000000000000019
[  235.995604] RBP: ffff880ff91cfde8 R08: 0000000000000009 R09: 0000000000000004
[  235.995604] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.995605] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.995605] FS:  0000000000000000(0000) GS:ffff88203f920000(0000) knlGS:0000000000000000
[  235.995606] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.995606] CR2: 00007f2481c7af70 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.995607] Stack:
[  235.995607]  ffff880ff91cfde8 00000019810af234 ffffe8ffffb21100 00000036d7fea488
[  235.995610]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91cfe48 ffffffff81568a4f
[  235.995612]  0000000000000000 0000000000f3d3ad 0000000000000000 0000000000f3d3ad
[  235.995614] Call Trace:
[  235.995615]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.995617]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.995618]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.995620]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.995622]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.995624] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.995693] NMI backtrace for cpu 26
[  235.995695] CPU: 26 PID: 0 Comm: swapper/26 Not tainted 3.13.0 #1
[  235.995695] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.995696] task: ffff880ff91d1730 ti: ffff880ff91d8000 task.ti: ffff880ff91d8000
[  235.995697] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.995699] RSP: 0018:ffff880ff91d9db8  EFLAGS: 00000046
[  235.995699] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.995700] RDX: 0000000000000000 RSI: ffff880ff91d9fd8 RDI: 000000000000001a
[  235.995700] RBP: ffff880ff91d9de8 R08: 0000000000000009 R09: 0000000000000009
[  235.995701] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.995701] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.995702] FS:  0000000000000000(0000) GS:ffff88203f940000(0000) knlGS:0000000000000000
[  235.995703] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.995703] CR2: 00007fe8b418cbd0 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.995704] Stack:
[  235.995704]  ffff880ff91d9de8 0000001a810af234 ffffe8ffffb41100 00000036d7fea539
[  235.995706]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91d9e48 ffffffff81568a4f
[  235.995708]  0000000000000000 0000000000f3d312 0000000000000000 0000000000f3d312
[  235.995710] Call Trace:
[  235.995711]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.995713]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.995715]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.995717]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.995719]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.995721] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.995793] NMI backtrace for cpu 27
[  235.995795] CPU: 27 PID: 0 Comm: swapper/27 Not tainted 3.13.0 #1
[  235.995795] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.995796] task: ffff880ff91d2e60 ti: ffff880ff91da000 task.ti: ffff880ff91da000
[  235.995797] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.995799] RSP: 0018:ffff880ff91dbdb8  EFLAGS: 00000046
[  235.995800] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.995800] RDX: 0000000000000000 RSI: ffff880ff91dbfd8 RDI: 000000000000001b
[  235.995801] RBP: ffff880ff91dbde8 R08: 0000000000000009 R09: 0000000000000090
[  235.995801] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.995802] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.995802] FS:  0000000000000000(0000) GS:ffff88203f960000(0000) knlGS:0000000000000000
[  235.995803] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.995804] CR2: 000000000043e408 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.995804] Stack:
[  235.995804]  ffff880ff91dbde8 0000001b810af234 ffffe8ffffb61100 00000036d7fea6b2
[  235.995807]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91dbe48 ffffffff81568a4f
[  235.995809]  0000000000000000 0000000000f3d1e6 0000000000000000 0000000000f3d1e6
[  235.995811] Call Trace:
[  235.995812]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.995814]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.995816]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.995818]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.995819]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.995821] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.995872] NMI backtrace for cpu 28
[  235.995875] CPU: 28 PID: 0 Comm: swapper/28 Not tainted 3.13.0 #1
[  235.995876] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.995877] task: ffff880ff91d4590 ti: ffff880ff91dc000 task.ti: ffff880ff91dc000
[  235.995877] RIP: 0010:[<ffffffff81351a07>]  [<ffffffff81351a07>] delay_tsc+0x37/0x60
[  235.995880] RSP: 0018:ffff88203f983cf8  EFLAGS: 00000046
[  235.995880] RAX: 000000005506b845 RBX: 00000000000003e9 RCX: 000000000000001c
[  235.995881] RDX: 000000000004db36 RSI: 000000005506b806 RDI: 000000000003ed47
[  235.995882] RBP: ffff88203f983cf8 R08: 000000000000001c R09: 0000000000000000
[  235.995882] R10: 0000000000000038 R11: 0000000000018840 R12: 0000000000001000
[  235.995883] R13: ffffffff81ce9920 R14: 0000000000000400 R15: 0000000000000092
[  235.995884] FS:  0000000000000000(0000) GS:ffff88203f980000(0000) knlGS:0000000000000000
[  235.995885] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.995885] CR2: 00007f7938713c62 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.995886] Stack:
[  235.995886]  ffff88203f983d08 ffffffff8135194c ffff88203f983d28 ffffffff8103047a
[  235.995889]  0000000000000002 000000000000b06a ffff88203f983d78 ffffffff81031f10
[  235.995892]  ffffffff0000002b 000000000000001d ffff88203f983d98 0000000000002710
[  235.995895] Call Trace:
[  235.995895]  <IRQ>  [<ffffffff8135194c>] __const_udelay+0x2c/0x30
[  235.995898]  [<ffffffff8103047a>] native_safe_apic_wait_icr_idle+0x2a/0x60
[  235.995900]  [<ffffffff81031f10>] default_send_IPI_mask_sequence_phys+0xc0/0xd0
[  235.995902]  [<ffffffff810364b7>] physflat_send_IPI_all+0x17/0x20
[  235.995906]  [<ffffffff81032094>] arch_trigger_all_cpu_backtrace+0x74/0xb0
[  235.995908]  [<ffffffff810ad51a>] rcu_check_callbacks+0x67a/0x6a0
[  235.995910]  [<ffffffff8105d248>] update_process_times+0x48/0x80
[  235.995912]  [<ffffffff810b7fc3>] tick_sched_handle.isra.11+0x33/0x70
[  235.995914]  [<ffffffff810b80ec>] tick_sched_timer+0x4c/0x80
[  235.995916]  [<ffffffff8107426c>] __run_hrtimer+0x6c/0x220
[  235.995918]  [<ffffffff810b80a0>] ? tick_nohz_handler+0xa0/0xa0
[  235.995919]  [<ffffffff81074b7f>] hrtimer_interrupt+0xff/0x240
[  235.995922]  [<ffffffff810303fb>] local_apic_timer_interrupt+0x3b/0x60
[  235.995924]  [<ffffffff816c5325>] smp_apic_timer_interrupt+0x45/0x60
[  235.995926]  [<ffffffff816c410a>] apic_timer_interrupt+0x6a/0x70
[  235.995927]  <EOI>  [<ffffffff8107466f>] ? __hrtimer_start_range_ns+0x18f/0x490
[  235.995930]  [<ffffffff81568a5b>] ? cpuidle_enter_state+0x5b/0xe0
[  235.995933]  [<ffffffff81568a57>] ? cpuidle_enter_state+0x57/0xe0
[  235.995935]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.995937]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.995939]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.995941]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.995943] Code: 04 25 64 b0 00 00 66 66 90 0f ae e8 0f 31 89 c6 eb 11 66 90 f3 90 65 8b 0c 25 64 b0 00 00 41 39 c8 75 12 66 66 90 0f ae e8 0f 31 <89> c2 29 f2 39 fa 72 e1 5d c3 29 c6 01 f7 66 66 90 0f ae e8 0f 
[  235.995991] NMI backtrace for cpu 29
[  235.995993] CPU: 29 PID: 0 Comm: swapper/29 Not tainted 3.13.0 #1
[  235.995994] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.995994] task: ffff880ff91d5cc0 ti: ffff880ff91de000 task.ti: ffff880ff91de000
[  235.995995] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.995997] RSP: 0018:ffff880ff91dfdb8  EFLAGS: 00000046
[  235.995998] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.995998] RDX: 0000000000000000 RSI: ffff880ff91dffd8 RDI: 000000000000001d
[  235.995999] RBP: ffff880ff91dfde8 R08: 0000000000000009 R09: 0000000000000009
[  235.995999] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.996000] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.996001] FS:  0000000000000000(0000) GS:ffff88203f9a0000(0000) knlGS:0000000000000000
[  235.996001] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.996002] CR2: 00007f8e932cd6d0 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.996002] Stack:
[  235.996003]  ffff880ff91dfde8 0000001d810af234 ffffe8ffffba1100 00000036d7fea5c5
[  235.996005]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91dfe48 ffffffff81568a4f
[  235.996007]  0000000000000000 0000000000f3d255 0000000000000000 0000000000f3d255
[  235.996009] Call Trace:
[  235.996010]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.996012]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.996013]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.996015]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.996017]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.996019] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.996093] NMI backtrace for cpu 30
[  235.996095] CPU: 30 PID: 0 Comm: swapper/30 Not tainted 3.13.0 #1
[  235.996095] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.996096] task: ffff880ff91e8000 ti: ffff880ff91f0000 task.ti: ffff880ff91f0000
[  235.996097] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.996099] RSP: 0018:ffff880ff91f1db8  EFLAGS: 00000046
[  235.996100] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.996100] RDX: 0000000000000000 RSI: ffff880ff91f1fd8 RDI: 000000000000001e
[  235.996101] RBP: ffff880ff91f1de8 R08: 0000000000000009 R09: 0000000000000090
[  235.996101] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.996102] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.996102] FS:  0000000000000000(0000) GS:ffff88203f9c0000(0000) knlGS:0000000000000000
[  235.996103] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.996104] CR2: 00007f6afe1dfc20 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.996104] Stack:
[  235.996104]  ffff880ff91f1de8 0000001e810af234 ffffe8ffffbc1100 00000036d7fea69c
[  235.996107]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91f1e48 ffffffff81568a4f
[  235.996109]  0000000000000000 0000000000f3d1da 0000000000000000 0000000000f3d1da
[  235.996111] Call Trace:
[  235.996112]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.996114]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.996115]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.996117]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.996119]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.996121] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  235.996192] NMI backtrace for cpu 31
[  235.996194] CPU: 31 PID: 0 Comm: swapper/31 Not tainted 3.13.0 #1
[  235.996194] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  235.996195] task: ffff880ff91e9730 ti: ffff880ff91f2000 task.ti: ffff880ff91f2000
[  235.996196] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  235.996198] RSP: 0018:ffff880ff91f3db8  EFLAGS: 00000046
[  235.996199] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  235.996199] RDX: 0000000000000000 RSI: ffff880ff91f3fd8 RDI: 000000000000001f
[  235.996200] RBP: ffff880ff91f3de8 R08: 0000000000000009 R09: 0000000000000010
[  235.996200] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  235.996201] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  235.996202] FS:  0000000000000000(0000) GS:ffff88203f9e0000(0000) knlGS:0000000000000000
[  235.996202] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.996203] CR2: 00007f6afe0acc62 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  235.996203] Stack:
[  235.996204]  ffff880ff91f3de8 0000001f810af234 ffffe8ffffbe1100 00000036d7fea771
[  235.996206]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91f3e48 ffffffff81568a4f
[  235.996208]  0000000000000000 0000000000f3d142 0000000000000000 0000000000f3d142
[  235.996211] Call Trace:
[  235.996211]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  235.996214]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  235.996215]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  235.996217]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  235.996219]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  235.996221] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.028222]  { 12}  (t=15011 jiffies g=5308 c=5307 q=11412)
[  236.029075] sending NMI to all CPUs:
[  236.029127] NMI backtrace for cpu 0
[  236.029137] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0 #1
[  236.029139] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.029143] task: ffffffff81c104a0 ti: ffffffff81c00000 task.ti: ffffffff81c00000
[  236.029145] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.029154] RSP: 0018:ffffffff81c01de8  EFLAGS: 00000046
[  236.029156] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.029170] RDX: 0000000000000000 RSI: ffffffff81c01fd8 RDI: 0000000000000000
[  236.029171] RBP: ffffffff81c01e18 R08: 0000000000001185 R09: 0000000000001ae9
[  236.029172] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.029173] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.029175] FS:  0000000000000000(0000) GS:ffff880fffa00000(0000) knlGS:0000000000000000
[  236.029176] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.029177] CR2: 00007f0f59fa6000 CR3: 0000000001c0b000 CR4: 00000000000407f0
[  236.029178] Stack:
[  236.029178]  ffffffff81c01e18 00000000810af234 ffffe8efbfc01100 00000036d966d7c1
[  236.029182]  ffffffff81c88a30 ffffffff81c88860 ffffffff81c01e78 ffffffff81568a4f
[  236.029184]  0000000000000000 0000000000f9d714 0000000000000000 0000000000f9d714
[  236.029187] Call Trace:
[  236.029190]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.029192]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.029194]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.029196]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.029199]  [<ffffffff816a2337>] rest_init+0x77/0x80
[  236.029201]  [<ffffffff81d09e8c>] start_kernel+0x3f7/0x404
[  236.029203]  [<ffffffff81d09895>] ? repair_env_string+0x5a/0x5a
[  236.029205]  [<ffffffff81d095a8>] x86_64_start_reservations+0x2a/0x2c
[  236.029207]  [<ffffffff81d0969a>] x86_64_start_kernel+0xf0/0xf7
[  236.029208] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.029225] NMI backtrace for cpu 1
[  236.029228] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.13.0 #1
[  236.029229] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.029230] task: ffff880ff9161730 ti: ffff880ff915c000 task.ti: ffff880ff915c000
[  236.029231] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.029237] RSP: 0018:ffff880ff915ddb8  EFLAGS: 00000046
[  236.029241] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.029244] RDX: 0000000000000000 RSI: ffff880ff915dfd8 RDI: 0000000000000001
[  236.029248] RBP: ffff880ff915dde8 R08: 0000000000002df5 R09: 00000000006b8f41
[  236.029251] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.029254] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.029257] FS:  0000000000000000(0000) GS:ffff880fffa20000(0000) knlGS:0000000000000000
[  236.029260] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.029263] CR2: 00007fc7c8d25010 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.029266] Stack:
[  236.029268]  ffff880ff915dde8 00000001810af234 ffffe8efbfc21100 00000036d9e760dc
[  236.029277]  ffffffff81c88a30 ffffffff81c88860 ffff880ff915de48 ffffffff81568a4f
[  236.029280]  0000000000000000 0000000000f36962 0000000000000000 0000000000f36962
[  236.029296] Call Trace:
[  236.029302]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.029306]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.029313]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.029319]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.029325]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.029328] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.029349] NMI backtrace for cpu 2
[  236.029352] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 3.13.0 #1
[  236.029353] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.029354] task: ffff880ff9162e60 ti: ffff880ff915e000 task.ti: ffff880ff915e000
[  236.029355] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.029358] RSP: 0018:ffff880ff915fdb8  EFLAGS: 00000046
[  236.029359] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.029360] RDX: 0000000000000000 RSI: ffff880ff915ffd8 RDI: 0000000000000002
[  236.029361] RBP: ffff880ff915fde8 R08: 0000000000003105 R09: 00000000009bdc10
[  236.029362] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.029363] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.029364] FS:  0000000000000000(0000) GS:ffff880fffa40000(0000) knlGS:0000000000000000
[  236.029365] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.029366] CR2: 00007f0f59fa6000 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.029367] Stack:
[  236.029368]  ffff880ff915fde8 00000002810af234 ffffe8efbfc41100 00000036d9e76104
[  236.029371]  ffffffff81c88a30 ffffffff81c88860 ffff880ff915fe48 ffffffff81568a4f
[  236.029373]  0000000000000000 0000000000f36934 0000000000000000 0000000000f36934
[  236.029376] Call Trace:
[  236.029379]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.029381]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.029384]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.029386]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.029388]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.029389] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.029419] NMI backtrace for cpu 3
[  236.029423] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 3.13.0 #1
[  236.029426] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.029428] task: ffff880ff9164590 ti: ffff880ff9168000 task.ti: ffff880ff9168000
[  236.029431] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.029436] RSP: 0018:ffff880ff9169db8  EFLAGS: 00000046
[  236.029440] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.029443] RDX: 0000000000000000 RSI: ffff880ff9169fd8 RDI: 0000000000000003
[  236.029447] RBP: ffff880ff9169de8 R08: 0000000000002d5d R09: 000000000a0b33f9
[  236.029451] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.029454] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.029456] FS:  0000000000000000(0000) GS:ffff880fffa60000(0000) knlGS:0000000000000000
[  236.029460] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.029463] CR2: 00007f1ae4ad9000 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.029466] Stack:
[  236.029468]  ffff880ff9169de8 00000003810af234 ffffe8efbfc61100 00000036d9e764bc
[  236.029476]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9169e48 ffffffff81568a4f
[  236.029484]  0000000000000000 0000000000f368bb 0000000000000000 0000000000f368bb
[  236.029496] Call Trace:
[  236.029503]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.029509]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.029514]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.029516]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.029519]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.029520] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.029537] NMI backtrace for cpu 4
[  236.029540] CPU: 4 PID: 0 Comm: swapper/4 Not tainted 3.13.0 #1
[  236.029541] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.029542] task: ffff880ff9165cc0 ti: ffff880ff916a000 task.ti: ffff880ff916a000
[  236.029543] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.029546] RSP: 0018:ffff880ff916bdb8  EFLAGS: 00000046
[  236.029547] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.029548] RDX: 0000000000000000 RSI: ffff880ff916bfd8 RDI: 0000000000000004
[  236.029549] RBP: ffff880ff916bde8 R08: 0000000000002d0d R09: 00000000006c20a4
[  236.029550] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.029551] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.029552] FS:  0000000000000000(0000) GS:ffff880fffa80000(0000) knlGS:0000000000000000
[  236.029554] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.029554] CR2: 0000000001149088 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.029555] Stack:
[  236.029556]  ffff880ff916bde8 00000004810af234 ffffe8efbfc81100 00000036d9e778b1
[  236.029559]  ffffffff81c88a30 ffffffff81c88860 ffff880ff916be48 ffffffff81568a4f
[  236.029565]  0000000000000000 0000000000f35c9e 0000000000000000 0000000000f35c9e
[  236.029573] Call Trace:
[  236.029578]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.029582]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.029588]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.029595]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.029601]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.029604] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.029674] NMI backtrace for cpu 5
[  236.029677] CPU: 5 PID: 0 Comm: swapper/5 Not tainted 3.13.0 #1
[  236.029693] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.029694] task: ffff880ff9170000 ti: ffff880ff916c000 task.ti: ffff880ff916c000
[  236.029695] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.029698] RSP: 0018:ffff880ff916ddb8  EFLAGS: 00000046
[  236.029699] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.029700] RDX: 0000000000000000 RSI: ffff880ff916dfd8 RDI: 0000000000000005
[  236.029701] RBP: ffff880ff916dde8 R08: 0000000000002c91 R09: 0000000009aef364
[  236.029702] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.029703] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.029704] FS:  0000000000000000(0000) GS:ffff880fffaa0000(0000) knlGS:0000000000000000
[  236.029706] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.029707] CR2: 00007ffe8c81d9b8 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.029707] Stack:
[  236.029708]  ffff880ff916dde8 00000005810af234 ffffe8efbfca1100 00000036d9e76c5f
[  236.029711]  ffffffff81c88a30 ffffffff81c88860 ffff880ff916de48 ffffffff81568a4f
[  236.029714]  0000000000000000 0000000000f35eb1 0000000000000000 0000000000f35eb1
[  236.029717] Call Trace:
[  236.029720]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.029722]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.029725]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.029727]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.029729]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.029730] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.029766] NMI backtrace for cpu 6
[  236.029772] CPU: 6 PID: 0 Comm: swapper/6 Not tainted 3.13.0 #1
[  236.029776] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.029780] task: ffff880ff9171730 ti: ffff880ff916e000 task.ti: ffff880ff916e000
[  236.029783] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.029788] RSP: 0018:ffff880ff916fdb8  EFLAGS: 00000046
[  236.029792] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.029795] RDX: 0000000000000000 RSI: ffff880ff916ffd8 RDI: 0000000000000006
[  236.029798] RBP: ffff880ff916fde8 R08: 00000000000009a1 R09: 0000000000002ef3
[  236.029800] R10: 0000000000000002 R11: 0000000000000001 R12: 0000000000000005
[  236.029802] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.029805] FS:  0000000000000000(0000) GS:ffff880fffac0000(0000) knlGS:0000000000000000
[  236.029807] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.029810] CR2: 00007f0081b3e078 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.029812] Stack:
[  236.029814]  ffff880ff916fde8 00000006810af234 ffffe8efbfcc1100 00000036d9e77224
[  236.029822]  ffffffff81c88a30 ffffffff81c88860 ffff880ff916fe48 ffffffff81568a4f
[  236.029834]  0000000000000000 0000000000f357ac 0000000000000000 0000000000f357ac
[  236.029844] Call Trace:
[  236.029850]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.029854]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.029859]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.029864]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.029868]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.029871] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.029890] NMI backtrace for cpu 7
[  236.029893] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 3.13.0 #1
[  236.029894] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.029895] task: ffff880ff9172e60 ti: ffff880ff9180000 task.ti: ffff880ff9180000
[  236.029896] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.029899] RSP: 0018:ffff880ff9181db8  EFLAGS: 00000046
[  236.029900] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.029901] RDX: 0000000000000000 RSI: ffff880ff9181fd8 RDI: 0000000000000007
[  236.029902] RBP: ffff880ff9181de8 R08: 0000000000002be9 R09: 00000000006c20a4
[  236.029903] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.029904] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.029905] FS:  0000000000000000(0000) GS:ffff880fffae0000(0000) knlGS:0000000000000000
[  236.029906] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.029907] CR2: 00007f5e36afa078 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.029908] Stack:
[  236.029909]  ffff880ff9181de8 00000007810af234 ffffe8efbfce1100 00000036d9e77702
[  236.029912]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9181e48 ffffffff81568a4f
[  236.029914]  0000000000000000 0000000000f352a2 0000000000000000 0000000000f352a2
[  236.029917] Call Trace:
[  236.029923]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.029930]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.029935]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.029941]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.029947]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.029949] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.030025] NMI backtrace for cpu 8
[  236.030028] CPU: 8 PID: 0 Comm: swapper/8 Not tainted 3.13.0 #1
[  236.030030] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.030031] task: ffff880ff9174590 ti: ffff880ff9182000 task.ti: ffff880ff9182000
[  236.030032] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.030035] RSP: 0018:ffff880ff9183db8  EFLAGS: 00000046
[  236.030036] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.030037] RDX: 0000000000000000 RSI: ffff880ff9183fd8 RDI: 0000000000000008
[  236.030038] RBP: ffff880ff9183de8 R08: 0000000000002e9d R09: 000000000875e264
[  236.030039] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.030040] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.030041] FS:  0000000000000000(0000) GS:ffff88203f800000(0000) knlGS:0000000000000000
[  236.030042] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.030043] CR2: 00007fff61860128 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.030044] Stack:
[  236.030045]  ffff880ff9183de8 00000008810af234 ffffe8ffffa01100 00000036d9e727e2
[  236.030055]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9183e48 ffffffff81568a4f
[  236.030057]  0000000000000000 0000000000f39422 0000000000000000 0000000000f39422
[  236.030060] Call Trace:
[  236.030063]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.030065]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.030068]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.030070]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.030073]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.030079] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.030324] NMI backtrace for cpu 9
[  236.030327] CPU: 9 PID: 0 Comm: swapper/9 Not tainted 3.13.0 #1
[  236.030328] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.030329] task: ffff880ff9175cc0 ti: ffff880ff9184000 task.ti: ffff880ff9184000
[  236.030330] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.030333] RSP: 0018:ffff880ff9185db8  EFLAGS: 00000046
[  236.030334] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.030335] RDX: 0000000000000000 RSI: ffff880ff9185fd8 RDI: 0000000000000009
[  236.030336] RBP: ffff880ff9185de8 R08: 0000000000002a55 R09: 000000000055da10
[  236.030337] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.030338] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.030340] FS:  0000000000000000(0000) GS:ffff88203f820000(0000) knlGS:0000000000000000
[  236.030341] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.030342] CR2: 00007faa9e134fbd CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.030343] Stack:
[  236.030343]  ffff880ff9185de8 00000009810af234 ffffe8ffffa21100 00000036d9e7297a
[  236.030357]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9185e48 ffffffff81568a4f
[  236.030360]  0000000000000000 0000000000f391fb 0000000000000000 0000000000f391fb
[  236.030363] Call Trace:
[  236.030365]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.030368]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.030370]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.030372]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.030374]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.030379] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.030460] NMI backtrace for cpu 10
[  236.030468] CPU: 10 PID: 0 Comm: swapper/10 Not tainted 3.13.0 #1
[  236.030472] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.030474] task: ffff880ff9188000 ti: ffff880ff9186000 task.ti: ffff880ff9186000
[  236.030475] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.030478] RSP: 0018:ffff880ff9187db8  EFLAGS: 00000046
[  236.030479] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.030480] RDX: 0000000000000000 RSI: ffff880ff9187fd8 RDI: 000000000000000a
[  236.030481] RBP: ffff880ff9187de8 R08: 0000000000002df1 R09: 0000000000462400
[  236.030482] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.030483] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.030484] FS:  0000000000000000(0000) GS:ffff88203f840000(0000) knlGS:0000000000000000
[  236.030485] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.030486] CR2: 00007fff865a616c CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.030487] Stack:
[  236.030488]  ffff880ff9187de8 0000000a810af234 ffffe8ffffa41100 00000036d9e71b5e
[  236.030512]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9187e48 ffffffff81568a4f
[  236.030535]  0000000000000000 0000000000f3a0b1 0000000000000000 0000000000f3a0b1
[  236.030558] Call Trace:
[  236.030569]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.030580]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.030591]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.030602]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.030614]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.030621] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.030742] NMI backtrace for cpu 11
[  236.030745] CPU: 11 PID: 0 Comm: swapper/11 Not tainted 3.13.0 #1
[  236.030746] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.030748] task: ffff880ff9189730 ti: ffff880ff9190000 task.ti: ffff880ff9190000
[  236.030749] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.030752] RSP: 0018:ffff880ff9191db8  EFLAGS: 00000046
[  236.030753] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.030754] RDX: 0000000000000000 RSI: ffff880ff9191fd8 RDI: 000000000000000b
[  236.030755] RBP: ffff880ff9191de8 R08: 0000000000003105 R09: 0000000000f3e584
[  236.030756] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.030756] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.030758] FS:  0000000000000000(0000) GS:ffff88203f860000(0000) knlGS:0000000000000000
[  236.030759] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.030760] CR2: 00007fb34e58e120 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.030761] Stack:
[  236.030761]  ffff880ff9191de8 0000000b810af234 ffffe8ffffa61100 00000036d9e72304
[  236.030775]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9191e48 ffffffff81568a4f
[  236.030778]  0000000000000000 0000000000f39ae0 0000000000000000 0000000000f39ae0
[  236.030780] Call Trace:
[  236.030783]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.030785]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.030788]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.030790]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.030792]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.030793] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.031027] NMI backtrace for cpu 12
[  236.031029] CPU: 12 PID: 34798 Comm: ip Not tainted 3.13.0 #1
[  236.031029] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.031031] task: ffff880fe4d3ae60 ti: ffff880fe4c9e000 task.ti: ffff880fe4c9e000
[  236.031031] RIP: 0010:[<ffffffff81351a07>]  [<ffffffff81351a07>] delay_tsc+0x37/0x60
[  236.031034] RSP: 0018:ffff88203f883cf8  EFLAGS: 00000046
[  236.031035] RAX: 000000005a575fbb RBX: 00000000000003e9 RCX: 000000000000000c
[  236.031036] RDX: 000000000004db36 RSI: 000000005a575f79 RDI: 000000000003ed47
[  236.031036] RBP: ffff88203f883cf8 R08: 000000000000000c R09: 0000000000000000
[  236.031037] R10: 0000000000001537 R11: 0000000000001536 R12: 0000000000001000
[  236.031038] R13: ffffffff81ce9920 R14: 0000000000000400 R15: 0000000000000092
[  236.031039] FS:  00007fe7048e0700(0000) GS:ffff88203f880000(0000) knlGS:0000000000000000
[  236.031040] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.031041] CR2: 000000000043e408 CR3: 0000001fe94bf000 CR4: 00000000000407e0
[  236.031042] Stack:
[  236.031042]  ffff88203f883d08 ffffffff8135194c ffff88203f883d28 ffffffff8103047a
[  236.031045]  0000000000000002 000000000000b06a ffff88203f883d78 ffffffff81031f10
[  236.031048]  ffffffff0000002a 000000000000000d ffff88203f883d98 0000000000002710
[  236.031050] Call Trace:
[  236.031051]  <IRQ> 
[  236.031052]  [<ffffffff8135194c>] __const_udelay+0x2c/0x30
[  236.031056]  [<ffffffff8103047a>] native_safe_apic_wait_icr_idle+0x2a/0x60
[  236.031057]  [<ffffffff81031f10>] default_send_IPI_mask_sequence_phys+0xc0/0xd0
[  236.031060]  [<ffffffff810364b7>] physflat_send_IPI_all+0x17/0x20
[  236.031062]  [<ffffffff81032094>] arch_trigger_all_cpu_backtrace+0x74/0xb0
[  236.031064]  [<ffffffff810ad2d5>] rcu_check_callbacks+0x435/0x6a0
[  236.031066]  [<ffffffff8105d248>] update_process_times+0x48/0x80
[  236.031068]  [<ffffffff810b7fc3>] tick_sched_handle.isra.11+0x33/0x70
[  236.031070]  [<ffffffff810b80ec>] tick_sched_timer+0x4c/0x80
[  236.031072]  [<ffffffff8107426c>] __run_hrtimer+0x6c/0x220
[  236.031074]  [<ffffffff810b80a0>] ? tick_nohz_handler+0xa0/0xa0
[  236.031076]  [<ffffffff81074b7f>] hrtimer_interrupt+0xff/0x240
[  236.031083]  [<ffffffff810303fb>] local_apic_timer_interrupt+0x3b/0x60
[  236.031094]  [<ffffffff816c5325>] smp_apic_timer_interrupt+0x45/0x60
[  236.031105]  [<ffffffff816c410a>] apic_timer_interrupt+0x6a/0x70
[  236.031111]  <EOI> 
[  236.031116]  [<ffffffff8119859b>] ? path_get+0x2b/0x40
[  236.031131]  [<ffffffff811ad1e8>] ? __lookup_mnt+0x68/0x80
[  236.031141]  [<ffffffff811ad2b0>] lookup_mnt+0x30/0x70
[  236.031151]  [<ffffffff8119855e>] follow_mount+0x5e/0x70
[  236.031161]  [<ffffffff81199070>] mountpoint_last+0xc0/0x1d0
[  236.031171]  [<ffffffff8119ad47>] path_mountpoint+0xd7/0x440
[  236.031181]  [<ffffffff810953c9>] ? __rwsem_do_wake+0x119/0x170
[  236.031193]  [<ffffffff81352e17>] ? call_rwsem_wake+0x17/0x30
[  236.031205]  [<ffffffff8117f551>] ? kmem_cache_alloc+0x31/0x160
[  236.031216]  [<ffffffff8119922c>] ? getname_flags+0x5c/0x190
[  236.031226]  [<ffffffff8119b0e4>] filename_mountpoint+0x34/0xc0
[  236.031238]  [<ffffffff8119e65a>] user_path_mountpoint_at+0x4a/0x70
[  236.031248]  [<ffffffff811adcef>] SyS_umount+0x7f/0x3b0
[  236.031257]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  236.031267]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  236.031273] Code: 04 25 64 b0 00 00 66 66 90 0f ae e8 0f 31 89 c6 eb 11 66 90 f3 90 65 8b 0c 25 64 b0 00 00 41 39 c8 75 12 66 66 90 0f ae e8 0f 31 <89> c2 29 f2 39 fa 72 e1 5d c3 29 c6 01 f7 66 66 90 0f ae e8 0f 
[  236.031344] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 1.072 msecs
[  236.031369] NMI backtrace for cpu 13
[  236.031376] CPU: 13 PID: 0 Comm: swapper/13 Not tainted 3.13.0 #1
[  236.031382] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.031389] task: ffff880ff918c590 ti: ffff880ff9194000 task.ti: ffff880ff9194000
[  236.031395] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.031407] RSP: 0018:ffff880ff9195db8  EFLAGS: 00000046
[  236.031413] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.031419] RDX: 0000000000000000 RSI: ffff880ff9195fd8 RDI: 000000000000000d
[  236.031425] RBP: ffff880ff9195de8 R08: 00000000000029f1 R09: 0000000000003e71
[  236.031431] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.031436] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.031442] FS:  0000000000000000(0000) GS:ffff88203f8a0000(0000) knlGS:0000000000000000
[  236.031448] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.031465] CR2: 00007fb34e58e120 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.031471] Stack:
[  236.031476]  ffff880ff9195de8 0000000d810af234 ffffe8ffffaa1100 00000036d9e72362
[  236.031499]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9195e48 ffffffff81568a4f
[  236.031525]  0000000000000000 0000000000f3989f 0000000000000000 0000000000f3989f
[  236.031549] Call Trace:
[  236.031560]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.031571]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.031581]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.031591]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.031601]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.031606] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.031658] NMI backtrace for cpu 14
[  236.031661] CPU: 14 PID: 0 Comm: swapper/14 Not tainted 3.13.0 #1
[  236.031662] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.031663] task: ffff880ff918dcc0 ti: ffff880ff9196000 task.ti: ffff880ff9196000
[  236.031664] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.031667] RSP: 0018:ffff880ff9197db8  EFLAGS: 00000046
[  236.031668] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.031669] RDX: 0000000000000000 RSI: ffff880ff9197fd8 RDI: 000000000000000e
[  236.031670] RBP: ffff880ff9197de8 R08: 0000000000002c85 R09: 00000000009baa24
[  236.031671] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.031672] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.031673] FS:  0000000000000000(0000) GS:ffff88203f8c0000(0000) knlGS:0000000000000000
[  236.031674] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.031675] CR2: 00007fb34e58e120 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.031676] Stack:
[  236.031677]  ffff880ff9197de8 0000000e810af234 ffffe8ffffac1100 00000036d9e7248e
[  236.031680]  ffffffff81c88a30 ffffffff81c88860 ffff880ff9197e48 ffffffff81568a4f
[  236.031683]  0000000000000000 0000000000f3976c 0000000000000000 0000000000f3976c
[  236.031685] Call Trace:
[  236.031688]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.031690]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.031693]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.031695]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.031697]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.031698] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.031822] NMI backtrace for cpu 15
[  236.031833] CPU: 15 PID: 0 Comm: swapper/15 Not tainted 3.13.0 #1
[  236.031842] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.031863] task: ffff880ff9198000 ti: ffff880ff91a0000 task.ti: ffff880ff91a0000
[  236.031870] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.031882] RSP: 0018:ffff880ff91a1db8  EFLAGS: 00000046
[  236.031890] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.031898] RDX: 0000000000000000 RSI: ffff880ff91a1fd8 RDI: 000000000000000f
[  236.031904] RBP: ffff880ff91a1de8 R08: 000000000000295d R09: 0000000000003e72
[  236.031910] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.031917] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.031923] FS:  0000000000000000(0000) GS:ffff88203f8e0000(0000) knlGS:0000000000000000
[  236.031930] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.031936] CR2: 00007fb34e58e120 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.031942] Stack:
[  236.031947]  ffff880ff91a1de8 0000000f810af234 ffffe8ffffae1100 00000036d9e72a0b
[  236.031971]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91a1e48 ffffffff81568a4f
[  236.032002]  0000000000000000 0000000000f39171 0000000000000000 0000000000f39171
[  236.032017] Call Trace:
[  236.032020]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.032022]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.032025]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.032027]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.032029]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.032030] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.032058] NMI backtrace for cpu 16
[  236.032061] CPU: 16 PID: 0 Comm: swapper/16 Not tainted 3.13.0 #1
[  236.032063] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.032065] task: ffff880ff9199730 ti: ffff880ff91a2000 task.ti: ffff880ff91a2000
[  236.032067] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.032071] RSP: 0018:ffff880ff91a3db8  EFLAGS: 00000046
[  236.032073] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.032074] RDX: 0000000000000000 RSI: ffff880ff91a3fd8 RDI: 0000000000000010
[  236.032076] RBP: ffff880ff91a3de8 R08: 0000000000002931 R09: 0000000000003e6e
[  236.032077] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.032079] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.032081] FS:  0000000000000000(0000) GS:ffff880fffb00000(0000) knlGS:0000000000000000
[  236.032083] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.032085] CR2: 00007facb638d9b8 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.032086] Stack:
[  236.032087]  ffff880ff91a3de8 00000010810af234 ffffe8efbfd01100 00000036d9e74c93
[  236.032092]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91a3e48 ffffffff81568a4f
[  236.032097]  0000000000000000 0000000000f385ab 0000000000000000 0000000000f385ab
[  236.032101] Call Trace:
[  236.032105]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.032110]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.032117]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.032122]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.032128]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.032130] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.032219] NMI backtrace for cpu 17
[  236.032223] CPU: 17 PID: 0 Comm: swapper/17 Not tainted 3.13.0 #1
[  236.032224] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.032226] task: ffff880ff919ae60 ti: ffff880ff91a4000 task.ti: ffff880ff91a4000
[  236.032228] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.032232] RSP: 0018:ffff880ff91a5db8  EFLAGS: 00000046
[  236.032234] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.032236] RDX: 0000000000000000 RSI: ffff880ff91a5fd8 RDI: 0000000000000011
[  236.032238] RBP: ffff880ff91a5de8 R08: 0000000000002bcd R09: 0000000000003e6d
[  236.032239] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.032241] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.032243] FS:  0000000000000000(0000) GS:ffff880fffb20000(0000) knlGS:0000000000000000
[  236.032257] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.032259] CR2: 00007fabfe2faf50 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.032260] Stack:
[  236.032261]  ffff880ff91a5de8 00000011810af234 ffffe8efbfd21100 00000036d9e7584f
[  236.032267]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91a5e48 ffffffff81568a4f
[  236.032271]  0000000000000000 0000000000f37fc8 0000000000000000 0000000000f37fc8
[  236.032276] Call Trace:
[  236.032281]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.032287]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.032295]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.032301]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.032308]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.032311] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.032409] NMI backtrace for cpu 18
[  236.032412] CPU: 18 PID: 0 Comm: swapper/18 Not tainted 3.13.0 #1
[  236.032413] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.032414] task: ffff880ff919c590 ti: ffff880ff91a8000 task.ti: ffff880ff91a8000
[  236.032415] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.032419] RSP: 0018:ffff880ff91a9db8  EFLAGS: 00000046
[  236.032420] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.032421] RDX: 0000000000000000 RSI: ffff880ff91a9fd8 RDI: 0000000000000012
[  236.032422] RBP: ffff880ff91a9de8 R08: 00000000000028a5 R09: 00000000006bf710
[  236.032423] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.032424] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.032425] FS:  0000000000000000(0000) GS:ffff880fffb40000(0000) knlGS:0000000000000000
[  236.032426] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.032427] CR2: 00007fabfe295c62 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.032428] Stack:
[  236.032429]  ffff880ff91a9de8 00000012810af234 ffffe8efbfd41100 00000036d9e75e54
[  236.032432]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91a9e48 ffffffff81568a4f
[  236.032435]  0000000000000000 0000000000f37a49 0000000000000000 0000000000f37a49
[  236.032438] Call Trace:
[  236.032441]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.032443]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.032446]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.032448]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.032451]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.032454] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.032555] NMI backtrace for cpu 19
[  236.032558] CPU: 19 PID: 0 Comm: swapper/19 Not tainted 3.13.0 #1
[  236.032559] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.032561] task: ffff880ff919dcc0 ti: ffff880ff91aa000 task.ti: ffff880ff91aa000
[  236.032562] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.032565] RSP: 0018:ffff880ff91abdb8  EFLAGS: 00000046
[  236.032566] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.032567] RDX: 0000000000000000 RSI: ffff880ff91abfd8 RDI: 0000000000000013
[  236.032568] RBP: ffff880ff91abde8 R08: 0000000000002b3d R09: 0000000000003e67
[  236.032569] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.032570] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.032571] FS:  0000000000000000(0000) GS:ffff880fffb60000(0000) knlGS:0000000000000000
[  236.032572] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.032574] CR2: 00007f7339703bd0 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.032574] Stack:
[  236.032575]  ffff880ff91abde8 00000013810af234 ffffe8efbfd61100 00000036d9e764ca
[  236.032578]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91abe48 ffffffff81568a4f
[  236.032581]  0000000000000000 0000000000f37386 0000000000000000 0000000000f37386
[  236.032584] Call Trace:
[  236.032587]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.032589]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.032592]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.032594]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.032597]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.032600] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.032632] NMI backtrace for cpu 20
[  236.032636] CPU: 20 PID: 0 Comm: swapper/20 Not tainted 3.13.0 #1
[  236.032640] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.032643] task: ffff880ff91b0000 ti: ffff880ff91ac000 task.ti: ffff880ff91ac000
[  236.032646] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.032652] RSP: 0018:ffff880ff91addb8  EFLAGS: 00000046
[  236.032666] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.032668] RDX: 0000000000000000 RSI: ffff880ff91adfd8 RDI: 0000000000000014
[  236.032671] RBP: ffff880ff91adde8 R08: 0000000000002865 R09: 00000000006c5f11
[  236.032673] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.032676] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.032678] FS:  0000000000000000(0000) GS:ffff880fffb80000(0000) knlGS:0000000000000000
[  236.032681] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.032683] CR2: 00007fabfe295c62 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.032685] Stack:
[  236.032687]  ffff880ff91adde8 00000014810af234 ffffe8efbfd81100 00000036d9e80e36
[  236.032701]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91ade48 ffffffff81568a4f
[  236.032711]  0000000000000000 0000000000f2acc2 0000000000000000 0000000000f2acc2
[  236.032720] Call Trace:
[  236.032725]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.032730]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.032735]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.032740]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.032748]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.032752] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.032777] NMI backtrace for cpu 21
[  236.032780] CPU: 21 PID: 0 Comm: swapper/21 Not tainted 3.13.0 #1
[  236.032781] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.032782] task: ffff880ff91b1730 ti: ffff880ff91ae000 task.ti: ffff880ff91ae000
[  236.032783] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.032786] RSP: 0018:ffff880ff91afdb8  EFLAGS: 00000046
[  236.032788] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.032789] RDX: 0000000000000000 RSI: ffff880ff91affd8 RDI: 0000000000000015
[  236.032790] RBP: ffff880ff91afde8 R08: 0000000000002a91 R09: 0000000000003e67
[  236.032790] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.032791] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.032793] FS:  0000000000000000(0000) GS:ffff880fffba0000(0000) knlGS:0000000000000000
[  236.032794] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.032795] CR2: 00007fabfe295c62 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.032796] Stack:
[  236.032796]  ffff880ff91afde8 00000015810af234 ffffe8efbfda1100 00000036d9e76b9d
[  236.032800]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91afe48 ffffffff81568a4f
[  236.032802]  0000000000000000 0000000000f36e0b 0000000000000000 0000000000f36e0b
[  236.032805] Call Trace:
[  236.032808]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.032813]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.032819]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.032823]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.032828]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.032830] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.032910] NMI backtrace for cpu 22
[  236.032913] CPU: 22 PID: 0 Comm: swapper/22 Not tainted 3.13.0 #1
[  236.032914] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.032915] task: ffff880ff91b2e60 ti: ffff880ff91c8000 task.ti: ffff880ff91c8000
[  236.032916] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.032919] RSP: 0018:ffff880ff91c9db8  EFLAGS: 00000046
[  236.032920] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.032921] RDX: 0000000000000000 RSI: ffff880ff91c9fd8 RDI: 0000000000000016
[  236.032922] RBP: ffff880ff91c9de8 R08: 00000000000027f9 R09: 0000000000003e65
[  236.032923] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.032924] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.032926] FS:  0000000000000000(0000) GS:ffff880fffbc0000(0000) knlGS:0000000000000000
[  236.032927] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.032928] CR2: 00007fddf83e5810 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.032928] Stack:
[  236.032929]  ffff880ff91c9de8 00000016810af234 ffffe8efbfdc1100 00000036d9e76c44
[  236.032932]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91c9e48 ffffffff81568a4f
[  236.032946]  0000000000000000 0000000000f36c77 0000000000000000 0000000000f36c77
[  236.032949] Call Trace:
[  236.032952]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.032954]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.032957]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.032959]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.032961]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.032962] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.033010] NMI backtrace for cpu 23
[  236.033013] CPU: 23 PID: 0 Comm: swapper/23 Not tainted 3.13.0 #1
[  236.033014] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.033015] task: ffff880ff91b4590 ti: ffff880ff91ca000 task.ti: ffff880ff91ca000
[  236.033016] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.033019] RSP: 0018:ffff880ff91cbdb8  EFLAGS: 00000046
[  236.033020] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.033021] RDX: 0000000000000000 RSI: ffff880ff91cbfd8 RDI: 0000000000000017
[  236.033022] RBP: ffff880ff91cbde8 R08: 0000000000002a21 R09: 00000000009c2701
[  236.033023] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.033024] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.033025] FS:  0000000000000000(0000) GS:ffff880fffbe0000(0000) knlGS:0000000000000000
[  236.033026] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.033027] CR2: 000000000042f3c0 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.033028] Stack:
[  236.033029]  ffff880ff91cbde8 00000017810af234 ffffe8efbfde1100 00000036d9e771a8
[  236.033032]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91cbe48 ffffffff81568a4f
[  236.033034]  0000000000000000 0000000000f3678b 0000000000000000 0000000000f3678b
[  236.033037] Call Trace:
[  236.033040]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.033042]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.033045]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.033046]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.033049]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.033050] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.033098] NMI backtrace for cpu 24
[  236.033102] CPU: 24 PID: 0 Comm: swapper/24 Not tainted 3.13.0 #1
[  236.033103] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.033104] task: ffff880ff91b5cc0 ti: ffff880ff91cc000 task.ti: ffff880ff91cc000
[  236.033105] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.033109] RSP: 0018:ffff880ff91cddb8  EFLAGS: 00000046
[  236.033110] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.033111] RDX: 0000000000000000 RSI: ffff880ff91cdfd8 RDI: 0000000000000018
[  236.033112] RBP: ffff880ff91cdde8 R08: 0000000000002729 R09: 0000000007487c44
[  236.033113] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.033114] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.033115] FS:  0000000000000000(0000) GS:ffff88203f900000(0000) knlGS:0000000000000000
[  236.033116] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.033125] CR2: 00007fb45337dbd0 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.033126] Stack:
[  236.033127]  ffff880ff91cdde8 00000018810af234 ffffe8ffffb01100 00000036d9e716e7
[  236.033131]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91cde48 ffffffff81568a4f
[  236.033133]  0000000000000000 0000000000f3abbe 0000000000000000 0000000000f3abbe
[  236.033136] Call Trace:
[  236.033139]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.033141]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.033144]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.033146]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.033160]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.033167] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.033235] NMI backtrace for cpu 25
[  236.033238] CPU: 25 PID: 0 Comm: swapper/25 Not tainted 3.13.0 #1
[  236.033239] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.033241] task: ffff880ff91d0000 ti: ffff880ff91ce000 task.ti: ffff880ff91ce000
[  236.033242] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.033245] RSP: 0018:ffff880ff91cfdb8  EFLAGS: 00000046
[  236.033246] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.033247] RDX: 0000000000000000 RSI: ffff880ff91cffd8 RDI: 0000000000000019
[  236.033248] RBP: ffff880ff91cfde8 R08: 0000000000002c11 R09: 0000000000003e74
[  236.033249] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.033250] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.033251] FS:  0000000000000000(0000) GS:ffff88203f920000(0000) knlGS:0000000000000000
[  236.033253] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.033254] CR2: 00007f2481c7af70 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.033254] Stack:
[  236.033255]  ffff880ff91cfde8 00000019810af234 ffffe8ffffb21100 00000036d9e716eb
[  236.033258]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91cfe48 ffffffff81568a4f
[  236.033261]  0000000000000000 0000000000f3abee 0000000000000000 0000000000f3abee
[  236.033279] Call Trace:
[  236.033284]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.033299]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.033313]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.033325]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.033338]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.033345] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.033371] NMI backtrace for cpu 26
[  236.033375] CPU: 26 PID: 0 Comm: swapper/26 Not tainted 3.13.0 #1
[  236.033376] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.033385] task: ffff880ff91d1730 ti: ffff880ff91d8000 task.ti: ffff880ff91d8000
[  236.033386] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.033389] RSP: 0018:ffff880ff91d9db8  EFLAGS: 00000046
[  236.033390] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.033392] RDX: 0000000000000000 RSI: ffff880ff91d9fd8 RDI: 000000000000001a
[  236.033393] RBP: ffff880ff91d9de8 R08: 0000000000002699 R09: 0000000000003e74
[  236.033405] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.033406] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.033408] FS:  0000000000000000(0000) GS:ffff88203f940000(0000) knlGS:0000000000000000
[  236.033409] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.033410] CR2: 00007fe8b418cbd0 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.033411] Stack:
[  236.033411]  ffff880ff91d9de8 0000001a810af234 ffffe8ffffb41100 00000036d9e715fe
[  236.033415]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91d9e48 ffffffff81568a4f
[  236.033417]  0000000000000000 0000000000f3acc6 0000000000000000 0000000000f3acc6
[  236.033420] Call Trace:
[  236.033423]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.033425]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.033428]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.033430]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.033444]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.033451] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.033517] NMI backtrace for cpu 27
[  236.033521] CPU: 27 PID: 0 Comm: swapper/27 Not tainted 3.13.0 #1
[  236.033522] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.033523] task: ffff880ff91d2e60 ti: ffff880ff91da000 task.ti: ffff880ff91da000
[  236.033524] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.033527] RSP: 0018:ffff880ff91dbdb8  EFLAGS: 00000046
[  236.033528] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.033529] RDX: 0000000000000000 RSI: ffff880ff91dbfd8 RDI: 000000000000001b
[  236.033530] RBP: ffff880ff91dbde8 R08: 0000000000002651 R09: 00000000006ba400
[  236.033531] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.033532] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.033534] FS:  0000000000000000(0000) GS:ffff88203f960000(0000) knlGS:0000000000000000
[  236.033535] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.033536] CR2: 000000000043e408 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.033537] Stack:
[  236.033537]  ffff880ff91dbde8 0000001b810af234 ffffe8ffffb61100 00000036d9e715fd
[  236.033541]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91dbe48 ffffffff81568a4f
[  236.033543]  0000000000000000 0000000000f3ac2c 0000000000000000 0000000000f3ac2c
[  236.033552] Call Trace:
[  236.033566]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.033579]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.033592]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.033605]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.033618]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.033623] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.033641] NMI backtrace for cpu 28
[  236.033643] CPU: 28 PID: 0 Comm: swapper/28 Not tainted 3.13.0 #1
[  236.033645] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.033646] task: ffff880ff91d4590 ti: ffff880ff91dc000 task.ti: ffff880ff91dc000
[  236.033647] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.033650] RSP: 0018:ffff880ff91dddb8  EFLAGS: 00000046
[  236.033652] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.033653] RDX: 0000000000000000 RSI: ffff880ff91ddfd8 RDI: 000000000000001c
[  236.033654] RBP: ffff880ff91ddde8 R08: 0000000000000015 R09: 0000000000000004
[  236.033656] R10: 0000000000000002 R11: 0000000000000001 R12: 0000000000000005
[  236.033657] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.033659] FS:  0000000000000000(0000) GS:ffff88203f980000(0000) knlGS:0000000000000000
[  236.033660] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.033662] CR2: 00007f7938713c62 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.033663] Stack:
[  236.033675]  ffff880ff91ddde8 0000001c810af234 ffffe8ffffb81100 00000036da23ed3f
[  236.033679]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91dde48 ffffffff81568a4f
[  236.033683]  0000000000000000 00000000003cb772 0000000000000000 00000000003cb772
[  236.033687] Call Trace:
[  236.033690]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.033693]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.033696]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.033698]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.033702]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.033703] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.033797] NMI backtrace for cpu 29
[  236.033800] CPU: 29 PID: 0 Comm: swapper/29 Not tainted 3.13.0 #1
[  236.033801] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.033802] task: ffff880ff91d5cc0 ti: ffff880ff91de000 task.ti: ffff880ff91de000
[  236.033803] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.033806] RSP: 0018:ffff880ff91dfdb8  EFLAGS: 00000046
[  236.033807] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.033808] RDX: 0000000000000000 RSI: ffff880ff91dffd8 RDI: 000000000000001d
[  236.033809] RBP: ffff880ff91dfde8 R08: 00000000000025c1 R09: 00000000000019a1
[  236.033810] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.033811] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.033812] FS:  0000000000000000(0000) GS:ffff88203f9a0000(0000) knlGS:0000000000000000
[  236.033813] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.033814] CR2: 00007f8e932cd6d0 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.033815] Stack:
[  236.033816]  ffff880ff91dfde8 0000001d810af234 ffffe8ffffba1100 00000036d9e715e2
[  236.033819]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91dfe48 ffffffff81568a4f
[  236.033822]  0000000000000000 0000000000f3abe8 0000000000000000 0000000000f3abe8
[  236.033824] Call Trace:
[  236.033827]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.033837]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.033850]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.033862]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.033875]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.033882] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.033917] NMI backtrace for cpu 30
[  236.033920] CPU: 30 PID: 0 Comm: swapper/30 Not tainted 3.13.0 #1
[  236.033921] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.033923] task: ffff880ff91e8000 ti: ffff880ff91f0000 task.ti: ffff880ff91f0000
[  236.033924] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.033927] RSP: 0018:ffff880ff91f1db8  EFLAGS: 00000046
[  236.033928] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.033929] RDX: 0000000000000000 RSI: ffff880ff91f1fd8 RDI: 000000000000001e
[  236.033930] RBP: ffff880ff91f1de8 R08: 0000000000002579 R09: 00000000006c3571
[  236.033931] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.033932] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.033933] FS:  0000000000000000(0000) GS:ffff88203f9c0000(0000) knlGS:0000000000000000
[  236.033934] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.033935] CR2: 00007f6afe1dfc20 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.033936] Stack:
[  236.033936]  ffff880ff91f1de8 0000001e810af234 ffffe8ffffbc1100 00000036d9e7169e
[  236.033940]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91f1e48 ffffffff81568a4f
[  236.033942]  0000000000000000 0000000000f3ac4b 0000000000000000 0000000000f3ac4b
[  236.033945] Call Trace:
[  236.033955]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.033967]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.033980]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.033992]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.034005]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.034012] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  236.034037] NMI backtrace for cpu 31
[  236.034040] CPU: 31 PID: 0 Comm: swapper/31 Not tainted 3.13.0 #1
[  236.034041] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  236.034042] task: ffff880ff91e9730 ti: ffff880ff91f2000 task.ti: ffff880ff91f2000
[  236.034043] RIP: 0010:[<ffffffff813be6dc>]  [<ffffffff813be6dc>] intel_idle+0xcc/0x140
[  236.034046] RSP: 0018:ffff880ff91f3db8  EFLAGS: 00000046
[  236.034047] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  236.034048] RDX: 0000000000000000 RSI: ffff880ff91f3fd8 RDI: 000000000000001f
[  236.034049] RBP: ffff880ff91f3de8 R08: 0000000000002535 R09: 0000000000003e76
[  236.034050] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000005
[  236.034051] R13: 0000000000000030 R14: 0000000000000004 R15: 0000000000000005
[  236.034052] FS:  0000000000000000(0000) GS:ffff88203f9e0000(0000) knlGS:0000000000000000
[  236.034053] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  236.034054] CR2: 00007f6afe0acc62 CR3: 0000000001c0b000 CR4: 00000000000407e0
[  236.034055] Stack:
[  236.034056]  ffff880ff91f3de8 0000001f810af234 ffffe8ffffbe1100 00000036d9e71788
[  236.034070]  ffffffff81c88a30 ffffffff81c88860 ffff880ff91f3e48 ffffffff81568a4f
[  236.034073]  0000000000000000 0000000000f3aae1 0000000000000000 0000000000f3aae1
[  236.034075] Call Trace:
[  236.034078]  [<ffffffff81568a4f>] cpuidle_enter_state+0x4f/0xe0
[  236.034091]  [<ffffffff81568ba0>] cpuidle_idle_call+0xc0/0x210
[  236.034104]  [<ffffffff8100b78e>] arch_cpu_idle+0xe/0x30
[  236.034117]  [<ffffffff810a2118>] cpu_startup_entry+0xc8/0x2b0
[  236.034130]  [<ffffffff8102e9ef>] start_secondary+0x1cf/0x230
[  236.034136] Code: 48 8b 34 25 f0 b8 00 00 48 89 d1 48 8d 86 38 e0 ff ff 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 16 a5 8c 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 9e 73 cf 
[  260.913466] BUG: soft lockup - CPU#12 stuck for 22s! [ip:34798]
[  260.940238] Modules linked in: veth ipmi_devintf 8021q garp xt_CHECKSUM iptable_mangle bridge stp llc kvm_intel kvm bonding ipt_REJECT xt_LOG xt_limit xt_tcpudp xt_addrtype nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter psmouse ip6_tables iptable_filter ip_tables x_tables gpio_ich igb mpt2sas i2c_algo_bit sb_edac scsi_transport_sas ptp ioatdma ipmi_si serio_raw hpwdt edac_core lpc_ich pps_core hpilo be2net dca ipmi_msghandler raid_class mac_hid acpi_power_meter lp parport shpchp hpsa
[  260.940271] CPU: 12 PID: 34798 Comm: ip Not tainted 3.13.0 #1
[  260.940278] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  260.940279] task: ffff880fe4d3ae60 ti: ffff880fe4c9e000 task.ti: ffff880fe4c9e000
[  260.940280] RIP: 0010:[<ffffffff811ad1e4>]  [<ffffffff811ad1e4>] __lookup_mnt+0x64/0x80
[  260.940282] RSP: 0018:ffff880fe4c9fcd8  EFLAGS: 00000283
[  260.940283] RAX: ffff880fe4cb7ed8 RBX: ffffffff8119859b RCX: ffff881ff9464370
[  260.940285] RDX: 0000000000000002 RSI: ffff8800b985e9c0 RDI: ffff880fe94cd1a0
[  260.940285] RBP: ffff880fe4c9fce8 R08: 326f6d7500737973 R09: ffff8800b985e9c0
[  260.940286] R10: 003f010100030103 R11: ffffc90000002000 R12: ffff880fe4c9fe00
[  260.940287] R13: ffff880fe244bc08 R14: 0000000000000000 R15: ffff881fe9ce21f0
[  260.940289] FS:  00007fe7048e0700(0000) GS:ffff88203f880000(0000) knlGS:0000000000000000
[  260.940290] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  260.940291] CR2: 000000000043e408 CR3: 0000001fe94bf000 CR4: 00000000000407e0
[  260.940292] Stack:
[  260.940292]  ffff881fe87c62fc ffff880fe4cb7ed8 ffff880fe4c9fd18 ffffffff811ad2b0
[  260.940295]  ffff880fe4c9fdb8 ffff880fe4c9ff28 ffff881ff65949c0 ffff880fe4c9ff28
[  260.940298]  ffff880fe4c9fd38 ffffffff8119855e ffff880fe4c9fda8 ffff881ff65949c0
[  260.940300] Call Trace:
[  260.940302]  [<ffffffff811ad2b0>] lookup_mnt+0x30/0x70
[  260.940304]  [<ffffffff8119855e>] follow_mount+0x5e/0x70
[  260.940306]  [<ffffffff81199070>] mountpoint_last+0xc0/0x1d0
[  260.940308]  [<ffffffff8119ad47>] path_mountpoint+0xd7/0x440
[  260.940311]  [<ffffffff810953c9>] ? __rwsem_do_wake+0x119/0x170
[  260.940313]  [<ffffffff81352e17>] ? call_rwsem_wake+0x17/0x30
[  260.940315]  [<ffffffff8117f551>] ? kmem_cache_alloc+0x31/0x160
[  260.940317]  [<ffffffff8119922c>] ? getname_flags+0x5c/0x190
[  260.940319]  [<ffffffff8119b0e4>] filename_mountpoint+0x34/0xc0
[  260.940321]  [<ffffffff8119e65a>] user_path_mountpoint_at+0x4a/0x70
[  260.940323]  [<ffffffff811adcef>] SyS_umount+0x7f/0x3b0
[  260.940325]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  260.940327]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  260.940328] Code: 48 89 45 f8 48 8b 55 f8 31 c0 48 39 ca 74 2b 48 89 d0 eb 13 0f 1f 00 48 8b 00 48 89 45 f8 48 8b 45 f8 48 39 c8 74 18 48 8b 50 10 <48> 83 c2 20 48 39 d7 75 e3 48 39 70 18 75 dd c9 c3 0f 1f 00 31 
[  288.927177] BUG: soft lockup - CPU#12 stuck for 23s! [ip:34798]
[  288.954015] Modules linked in: veth ipmi_devintf 8021q garp xt_CHECKSUM iptable_mangle bridge stp llc kvm_intel kvm bonding ipt_REJECT xt_LOG xt_limit xt_tcpudp xt_addrtype nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter psmouse ip6_tables iptable_filter ip_tables x_tables gpio_ich igb mpt2sas i2c_algo_bit sb_edac scsi_transport_sas ptp ioatdma ipmi_si serio_raw hpwdt edac_core lpc_ich pps_core hpilo be2net dca ipmi_msghandler raid_class mac_hid acpi_power_meter lp parport shpchp hpsa
[  288.954050] CPU: 12 PID: 34798 Comm: ip Not tainted 3.13.0 #1
[  288.954051] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  288.954052] task: ffff880fe4d3ae60 ti: ffff880fe4c9e000 task.ti: ffff880fe4c9e000
[  288.954053] RIP: 0010:[<ffffffff811ad1e4>]  [<ffffffff811ad1e4>] __lookup_mnt+0x64/0x80
[  288.954055] RSP: 0018:ffff880fe4c9fcd8  EFLAGS: 00000283
[  288.954056] RAX: ffff880fe7151180 RBX: ffffffff8119859b RCX: ffff881ff9464370
[  288.954058] RDX: ffff880fe7151180 RSI: ffff8800b985e9c0 RDI: ffff880fe94cd1a0
[  288.954058] RBP: ffff880fe4c9fce8 R08: 326f6d7500737973 R09: ffff8800b985e9c0
[  288.954059] R10: 003f010100030103 R11: ffffc90000002000 R12: ffff880fe4c9fe00
[  288.954060] R13: ffff880fe244bc08 R14: 0000000000000000 R15: ffff881fe9ce21f0
[  288.954062] FS:  00007fe7048e0700(0000) GS:ffff88203f880000(0000) knlGS:0000000000000000
[  288.954063] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  288.954064] CR2: 000000000043e408 CR3: 0000001fe94bf000 CR4: 00000000000407e0
[  288.954064] Stack:
[  288.954065]  ffff881fe87c62fc ffff880fe7151180 ffff880fe4c9fd18 ffffffff811ad2b0
[  288.954068]  ffff880fe4c9fdb8 ffff880fe4c9ff28 ffff881ff65949c0 ffff880fe4c9ff28
[  288.954070]  ffff880fe4c9fd38 ffffffff8119855e ffff880fe4c9fda8 ffff881ff65949c0
[  288.954073] Call Trace:
[  288.954075]  [<ffffffff811ad2b0>] lookup_mnt+0x30/0x70
[  288.954077]  [<ffffffff8119855e>] follow_mount+0x5e/0x70
[  288.954079]  [<ffffffff81199070>] mountpoint_last+0xc0/0x1d0
[  288.954081]  [<ffffffff8119ad47>] path_mountpoint+0xd7/0x440
[  288.954083]  [<ffffffff810953c9>] ? __rwsem_do_wake+0x119/0x170
[  288.954085]  [<ffffffff81352e17>] ? call_rwsem_wake+0x17/0x30
[  288.954087]  [<ffffffff8117f551>] ? kmem_cache_alloc+0x31/0x160
[  288.954089]  [<ffffffff8119922c>] ? getname_flags+0x5c/0x190
[  288.954091]  [<ffffffff8119b0e4>] filename_mountpoint+0x34/0xc0
[  288.954093]  [<ffffffff8119e65a>] user_path_mountpoint_at+0x4a/0x70
[  288.954095]  [<ffffffff811adcef>] SyS_umount+0x7f/0x3b0
[  288.954097]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  288.954099]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  288.954100] Code: 48 89 45 f8 48 8b 55 f8 31 c0 48 39 ca 74 2b 48 89 d0 eb 13 0f 1f 00 48 8b 00 48 89 45 f8 48 8b 45 f8 48 39 c8 74 18 48 8b 50 10 <48> 83 c2 20 48 39 d7 75 e3 48 39 70 18 75 dd c9 c3 0f 1f 00 31 
[  316.940889] BUG: soft lockup - CPU#12 stuck for 23s! [ip:34798]
[  316.967730] Modules linked in: veth ipmi_devintf 8021q garp xt_CHECKSUM iptable_mangle bridge stp llc kvm_intel kvm bonding ipt_REJECT xt_LOG xt_limit xt_tcpudp xt_addrtype nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter psmouse ip6_tables iptable_filter ip_tables x_tables gpio_ich igb mpt2sas i2c_algo_bit sb_edac scsi_transport_sas ptp ioatdma ipmi_si serio_raw hpwdt edac_core lpc_ich pps_core hpilo be2net dca ipmi_msghandler raid_class mac_hid acpi_power_meter lp parport shpchp hpsa
[  316.967773] CPU: 12 PID: 34798 Comm: ip Not tainted 3.13.0 #1
[  316.967774] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  316.967776] task: ffff880fe4d3ae60 ti: ffff880fe4c9e000 task.ti: ffff880fe4c9e000
[  316.967777] RIP: 0010:[<ffffffff811ad1e8>]  [<ffffffff811ad1e8>] __lookup_mnt+0x68/0x80
[  316.967779] RSP: 0018:ffff880fe4c9fcd8  EFLAGS: 00000286
[  316.967780] RAX: ffff880fe7153480 RBX: ffffffff8119859b RCX: ffff881ff9464370
[  316.967781] RDX: ffff880fe71534a0 RSI: ffff8800b985e9c0 RDI: ffff880fe94cd1a0
[  316.967782] RBP: ffff880fe4c9fce8 R08: 326f6d7500737973 R09: ffff8800b985e9c0
[  316.967783] R10: 003f010100030103 R11: ffffc90000002000 R12: ffff880fe4c9fe00
[  316.967784] R13: ffff880fe244bc08 R14: 0000000000000000 R15: ffff881fe9ce21f0
[  316.967785] FS:  00007fe7048e0700(0000) GS:ffff88203f880000(0000) knlGS:0000000000000000
[  316.967786] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  316.967787] CR2: 000000000043e408 CR3: 0000001fe94bf000 CR4: 00000000000407e0
[  316.967788] Stack:
[  316.967789]  ffff881fe87c62fc ffff880fe7153480 ffff880fe4c9fd18 ffffffff811ad2b0
[  316.967792]  ffff880fe4c9fdb8 ffff880fe4c9ff28 ffff881ff65949c0 ffff880fe4c9ff28
[  316.967794]  ffff880fe4c9fd38 ffffffff8119855e ffff880fe4c9fda8 ffff881ff65949c0
[  316.967797] Call Trace:
[  316.967799]  [<ffffffff811ad2b0>] lookup_mnt+0x30/0x70
[  316.967801]  [<ffffffff8119855e>] follow_mount+0x5e/0x70
[  316.967803]  [<ffffffff81199070>] mountpoint_last+0xc0/0x1d0
[  316.967805]  [<ffffffff8119ad47>] path_mountpoint+0xd7/0x440
[  316.967807]  [<ffffffff810953c9>] ? __rwsem_do_wake+0x119/0x170
[  316.967809]  [<ffffffff81352e17>] ? call_rwsem_wake+0x17/0x30
[  316.967811]  [<ffffffff8117f551>] ? kmem_cache_alloc+0x31/0x160
[  316.967813]  [<ffffffff8119922c>] ? getname_flags+0x5c/0x190
[  316.967816]  [<ffffffff8119b0e4>] filename_mountpoint+0x34/0xc0
[  316.967818]  [<ffffffff8119e65a>] user_path_mountpoint_at+0x4a/0x70
[  316.967820]  [<ffffffff811adcef>] SyS_umount+0x7f/0x3b0
[  316.967821]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  316.967823]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  316.967824] Code: 48 8b 55 f8 31 c0 48 39 ca 74 2b 48 89 d0 eb 13 0f 1f 00 48 8b 00 48 89 45 f8 48 8b 45 f8 48 39 c8 74 18 48 8b 50 10 48 83 c2 20 <48> 39 d7 75 e3 48 39 70 18 75 dd c9 c3 0f 1f 00 31 c0 c9 c3 0f 
[  344.954600] BUG: soft lockup - CPU#12 stuck for 23s! [ip:34798]
[  344.981497] Modules linked in: veth ipmi_devintf 8021q garp xt_CHECKSUM iptable_mangle bridge stp llc kvm_intel kvm bonding ipt_REJECT xt_LOG xt_limit xt_tcpudp xt_addrtype nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter psmouse ip6_tables iptable_filter ip_tables x_tables gpio_ich igb mpt2sas i2c_algo_bit sb_edac scsi_transport_sas ptp ioatdma ipmi_si serio_raw hpwdt edac_core lpc_ich pps_core hpilo be2net dca ipmi_msghandler raid_class mac_hid acpi_power_meter lp parport shpchp hpsa
[  344.981523] CPU: 12 PID: 34798 Comm: ip Not tainted 3.13.0 #1
[  344.981524] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  344.981525] task: ffff880fe4d3ae60 ti: ffff880fe4c9e000 task.ti: ffff880fe4c9e000
[  344.981526] RIP: 0010:[<ffffffff811ad1e4>]  [<ffffffff811ad1e4>] __lookup_mnt+0x64/0x80
[  344.981528] RSP: 0018:ffff880fe4c9fcd8  EFLAGS: 00000283
[  344.981530] RAX: ffff880fe7153e80 RBX: ffffffff8119859b RCX: ffff881ff9464370
[  344.981531] RDX: ffff880fe7153e80 RSI: ffff8800b985e9c0 RDI: ffff880fe94cd1a0
[  344.981532] RBP: ffff880fe4c9fce8 R08: 326f6d7500737973 R09: ffff8800b985e9c0
[  344.981533] R10: 003f010100030103 R11: ffffc90000002000 R12: ffff880fe4c9fe00
[  344.981534] R13: ffff880fe244bc08 R14: 0000000000000000 R15: ffff881fe9ce21f0
[  344.981535] FS:  00007fe7048e0700(0000) GS:ffff88203f880000(0000) knlGS:0000000000000000
[  344.981536] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  344.981537] CR2: 000000000043e408 CR3: 0000001fe94bf000 CR4: 00000000000407e0
[  344.981538] Stack:
[  344.981539]  ffff881fe87c62fc ffff880fe7153e80 ffff880fe4c9fd18 ffffffff811ad2b0
[  344.981542]  ffff880fe4c9fdb8 ffff880fe4c9ff28 ffff881ff65949c0 ffff880fe4c9ff28
[  344.981544]  ffff880fe4c9fd38 ffffffff8119855e ffff880fe4c9fda8 ffff881ff65949c0
[  344.981547] Call Trace:
[  344.981549]  [<ffffffff811ad2b0>] lookup_mnt+0x30/0x70
[  344.981551]  [<ffffffff8119855e>] follow_mount+0x5e/0x70
[  344.981553]  [<ffffffff81199070>] mountpoint_last+0xc0/0x1d0
[  344.981555]  [<ffffffff8119ad47>] path_mountpoint+0xd7/0x440
[  344.981557]  [<ffffffff810953c9>] ? __rwsem_do_wake+0x119/0x170
[  344.981559]  [<ffffffff81352e17>] ? call_rwsem_wake+0x17/0x30
[  344.981561]  [<ffffffff8117f551>] ? kmem_cache_alloc+0x31/0x160
[  344.981563]  [<ffffffff8119922c>] ? getname_flags+0x5c/0x190
[  344.981565]  [<ffffffff8119b0e4>] filename_mountpoint+0x34/0xc0
[  344.981567]  [<ffffffff8119e65a>] user_path_mountpoint_at+0x4a/0x70
[  344.981569]  [<ffffffff811adcef>] SyS_umount+0x7f/0x3b0
[  344.981571]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  344.981573]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  344.981573] Code: 48 89 45 f8 48 8b 55 f8 31 c0 48 39 ca 74 2b 48 89 d0 eb 13 0f 1f 00 48 8b 00 48 89 45 f8 48 8b 45 f8 48 39 c8 74 18 48 8b 50 10 <48> 83 c2 20 48 39 d7 75 e3 48 39 70 18 75 dd c9 c3 0f 1f 00 31 
[  362.639304] INFO: task ip:34742 blocked for more than 120 seconds.
[  362.667295]       Not tainted 3.13.0 #1
[  362.684600] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  362.719972] ip              D ffffffff8180f480     0 34742  34736 0x00000002
[  362.719976]  ffff880fe36e1c58 0000000000000046 ffff88203f933080 ffff881ff8dfec00
[  362.719979]  ffff880fe247ae60 0000000000013080 ffff880fe36e1fd8 0000000000013080
[  362.719982]  ffff880ff9164590 ffff880fe247ae60 ffff880fe36e1c58 ffff880fe36e1da0
[  362.719984] Call Trace:
[  362.719992]  [<ffffffff816b7e09>] schedule+0x29/0x70
[  362.719995]  [<ffffffff816b7005>] schedule_timeout+0x1e5/0x250
[  362.719999]  [<ffffffff81137aee>] ? free_hot_cold_page_list+0x4e/0xc0
[  362.720002]  [<ffffffff816b8ec6>] wait_for_completion+0xa6/0x110
[  362.720004]  [<ffffffff810805c0>] ? try_to_wake_up+0x2b0/0x2b0
[  362.720006]  [<ffffffff810ab950>] ? __call_rcu.constprop.61+0x240/0x240
[  362.720010]  [<ffffffff810a960d>] wait_rcu_gp+0x4d/0x60
[  362.720012]  [<ffffffff810a9620>] ? wait_rcu_gp+0x60/0x60
[  362.720014]  [<ffffffff810abd2c>] synchronize_sched+0x3c/0x50
[  362.720017]  [<ffffffff811acca3>] namespace_unlock+0x83/0xe0
[  362.720019]  [<ffffffff811ae3ff>] drop_collected_mounts+0x4f/0x60
[  362.720021]  [<ffffffff811af96d>] put_mnt_ns+0x2d/0x50
[  362.720024]  [<ffffffff8107562f>] free_nsproxy+0x1f/0x90
[  362.720027]  [<ffffffff810757bd>] switch_task_namespaces+0x5d/0x70
[  362.720029]  [<ffffffff810757e0>] exit_task_namespaces+0x10/0x20
[  362.720049]  [<ffffffff81050f16>] do_exit+0x2a6/0xa70
[  362.720075]  [<ffffffff8118e4d4>] ? vfs_write+0x174/0x1f0
[  362.720087]  [<ffffffff81051814>] do_group_exit+0x44/0xb0
[  362.720089]  [<ffffffff81051897>] SyS_exit_group+0x17/0x20
[  362.720091]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  362.720093] INFO: task ip:34743 blocked for more than 120 seconds.
[  362.748027]       Not tainted 3.13.0 #1
[  362.765613] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  362.802217] ip              D ffffffff8180f480     0 34743  34737 0x00000002
[  362.802220]  ffff880fe37afce8 0000000000000046 ffff880fe37afcc8 ffffffff81137aee
[  362.802223]  ffff880fe8610000 0000000000013080 ffff880fe37affd8 0000000000013080
[  362.802226]  ffff880ff91d0000 ffff880fe8610000 ffff881fe9fee5c0 ffff880fe37afe30
[  362.802228] Call Trace:
[  362.802230]  [<ffffffff81137aee>] ? free_hot_cold_page_list+0x4e/0xc0
[  362.802233]  [<ffffffff816b7e09>] schedule+0x29/0x70
[  362.802235]  [<ffffffff816b7005>] schedule_timeout+0x1e5/0x250
[  362.802238]  [<ffffffff816b8ec6>] wait_for_completion+0xa6/0x110
[  362.802239]  [<ffffffff810805c0>] ? try_to_wake_up+0x2b0/0x2b0
[  362.802241]  [<ffffffff810ab950>] ? __call_rcu.constprop.61+0x240/0x240
[  362.802243]  [<ffffffff810a960d>] wait_rcu_gp+0x4d/0x60
[  362.802246]  [<ffffffff810a9620>] ? wait_rcu_gp+0x60/0x60
[  362.802247]  [<ffffffff810abd2c>] synchronize_sched+0x3c/0x50
[  362.802250]  [<ffffffff810757b5>] switch_task_namespaces+0x55/0x70
[  362.802252]  [<ffffffff810757e0>] exit_task_namespaces+0x10/0x20
[  362.802254]  [<ffffffff81050f16>] do_exit+0x2a6/0xa70
[  362.802258]  [<ffffffff815a3c59>] ? __sys_recvmsg+0x49/0x90
[  362.802261]  [<ffffffff81051814>] do_group_exit+0x44/0xb0
[  362.802263]  [<ffffffff81051897>] SyS_exit_group+0x17/0x20
[  362.802265]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  362.802266] INFO: task ip:34752 blocked for more than 120 seconds.
[  362.831291]       Not tainted 3.13.0 #1
[  362.855262] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  362.890787] ip              D 0000000000000000     0 34752  34746 0x00000000
[  362.890788]  ffff880fe4cb7d48 0000000000000086 ffff880fe44b6fd0 ffff881ff65949c0
[  362.890792]  ffff880ff277ae60 0000000000013080 ffff880fe4cb7fd8 0000000000013080
[  362.890794]  ffff881fec495cc0 ffff880ff277ae60 ffff880fe4cb7d38 ffff880fe4cb7e90
[  362.890797] Call Trace:
[  362.890800]  [<ffffffff816b7e09>] schedule+0x29/0x70
[  362.890802]  [<ffffffff816b7005>] schedule_timeout+0x1e5/0x250
[  362.890804]  [<ffffffff81080542>] ? try_to_wake_up+0x232/0x2b0
[  362.890806]  [<ffffffff8119a9d2>] ? do_path_lookup+0x32/0x40
[  362.890808]  [<ffffffff816b8ec6>] wait_for_completion+0xa6/0x110
[  362.890810]  [<ffffffff810805c0>] ? try_to_wake_up+0x2b0/0x2b0
[  362.890812]  [<ffffffff810ab950>] ? __call_rcu.constprop.61+0x240/0x240
[  362.890814]  [<ffffffff810a960d>] wait_rcu_gp+0x4d/0x60
[  362.890816]  [<ffffffff810a9620>] ? wait_rcu_gp+0x60/0x60
[  362.890818]  [<ffffffff810abd2c>] synchronize_sched+0x3c/0x50
[  362.890820]  [<ffffffff811acca3>] namespace_unlock+0x83/0xe0
[  362.890822]  [<ffffffff811ade70>] SyS_umount+0x200/0x3b0
[  362.890823]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  362.890825]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  362.890827] INFO: task route:34761 blocked for more than 120 seconds.
[  362.920002]       Not tainted 3.13.0 #1
[  362.937663] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  362.973635] route           D ffffffff8180f480     0 34761  34749 0x00000002
[  362.973637]  ffff881fe9579ce8 0000000000000046 ffff881fe9579cc8 ffffffff81137aee
[  362.973640]  ffff881fe9572e60 0000000000013080 ffff881fe9579fd8 0000000000013080
[  362.973643]  ffff880ff919c590 ffff881fe9572e60 ffff880fe931b5c0 ffff881fe9579e30
[  362.973645] Call Trace:
[  362.973647]  [<ffffffff81137aee>] ? free_hot_cold_page_list+0x4e/0xc0
[  362.973650]  [<ffffffff816b7e09>] schedule+0x29/0x70
[  362.973652]  [<ffffffff816b7005>] schedule_timeout+0x1e5/0x250
[  362.973654]  [<ffffffff816b8ec6>] wait_for_completion+0xa6/0x110
[  362.973656]  [<ffffffff810805c0>] ? try_to_wake_up+0x2b0/0x2b0
[  362.973658]  [<ffffffff810ab950>] ? __call_rcu.constprop.61+0x240/0x240
[  362.973660]  [<ffffffff810a960d>] wait_rcu_gp+0x4d/0x60
[  362.973662]  [<ffffffff810a9620>] ? wait_rcu_gp+0x60/0x60
[  362.973664]  [<ffffffff810abd2c>] synchronize_sched+0x3c/0x50
[  362.973667]  [<ffffffff810757b5>] switch_task_namespaces+0x55/0x70
[  362.973669]  [<ffffffff810757e0>] exit_task_namespaces+0x10/0x20
[  362.973671]  [<ffffffff81050f16>] do_exit+0x2a6/0xa70
[  362.973673]  [<ffffffff8118faee>] ? ____fput+0xe/0x10
[  362.973676]  [<ffffffff8106e1dc>] ? task_work_run+0xac/0xe0
[  362.973678]  [<ffffffff81051814>] do_group_exit+0x44/0xb0
[  362.973680]  [<ffffffff81051897>] SyS_exit_group+0x17/0x20
[  362.973682]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  362.973684] INFO: task ip:34762 blocked for more than 120 seconds.
[  363.002063]       Not tainted 3.13.0 #1
[  363.019580] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  363.055607] ip              D ffffffff8180f480     0 34762  34751 0x00000000
[  363.055609]  ffff880fe24c5d48 0000000000000082 ffff880fe24c5d08 ffff881ff65949c0
[  363.055612]  ffff880fe3c90000 0000000000013080 ffff880fe24c5fd8 0000000000013080
[  363.055615]  ffff880ff9171730 ffff880fe3c90000 ffff880fe24c5d38 ffff880fe24c5e90
[  363.055617] Call Trace:
[  363.055620]  [<ffffffff816b7e09>] schedule+0x29/0x70
[  363.055622]  [<ffffffff816b7005>] schedule_timeout+0x1e5/0x250
[  363.055624]  [<ffffffff8119ad1a>] ? path_mountpoint+0xaa/0x440
[  363.055627]  [<ffffffff816b7e09>] ? schedule+0x29/0x70
[  363.055629]  [<ffffffff816b8ec6>] wait_for_completion+0xa6/0x110
[  363.055631]  [<ffffffff810805c0>] ? try_to_wake_up+0x2b0/0x2b0
[  363.055633]  [<ffffffff810ab950>] ? __call_rcu.constprop.61+0x240/0x240
[  363.055635]  [<ffffffff810a960d>] wait_rcu_gp+0x4d/0x60
[  363.055650]  [<ffffffff810a9620>] ? wait_rcu_gp+0x60/0x60
[  363.055658]  [<ffffffff810abd2c>] synchronize_sched+0x3c/0x50
[  363.055660]  [<ffffffff811acca3>] namespace_unlock+0x83/0xe0
[  363.055661]  [<ffffffff811ade70>] SyS_umount+0x200/0x3b0
[  363.055663]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  363.055665]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  363.055667] INFO: task ip:34779 blocked for more than 120 seconds.
[  363.084012]       Not tainted 3.13.0 #1
[  363.101629] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  363.137309] ip              D ffffffff8180f480     0 34779  34771 0x00000000
[  363.137311]  ffff880fe2561d48 0000000000000086 ffff880fe3c9063c ffff881ff65949c0
[  363.137314]  ffff880ff4ad1730 0000000000013080 ffff880fe2561fd8 0000000000013080
[  363.137317]  ffff880ff91d2e60 ffff880ff4ad1730 ffff880fe2561d38 ffff880fe2561e90
[  363.137320] Call Trace:
[  363.137322]  [<ffffffff816b7e09>] schedule+0x29/0x70
[  363.137324]  [<ffffffff816b7005>] schedule_timeout+0x1e5/0x250
[  363.137326]  [<ffffffff8119ad1a>] ? path_mountpoint+0xaa/0x440
[  363.137329]  [<ffffffff810953c9>] ? __rwsem_do_wake+0x119/0x170
[  363.137331]  [<ffffffff816b8ec6>] wait_for_completion+0xa6/0x110
[  363.137333]  [<ffffffff810805c0>] ? try_to_wake_up+0x2b0/0x2b0
[  363.137334]  [<ffffffff810ab950>] ? __call_rcu.constprop.61+0x240/0x240
[  363.137337]  [<ffffffff810a960d>] wait_rcu_gp+0x4d/0x60
[  363.137339]  [<ffffffff810a9620>] ? wait_rcu_gp+0x60/0x60
[  363.137340]  [<ffffffff810abd2c>] synchronize_sched+0x3c/0x50
[  363.137342]  [<ffffffff811acca3>] namespace_unlock+0x83/0xe0
[  363.137344]  [<ffffffff811ade70>] SyS_umount+0x200/0x3b0
[  363.137346]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  363.137348]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  363.137350] INFO: task ip:34791 blocked for more than 120 seconds.
[  363.166070]       Not tainted 3.13.0 #1
[  363.183753] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  363.219583] ip              D ffffffff8180f480     0 34791  34776 0x00000000
[  363.219585]  ffff880fe5295d78 0000000000000082 ffff881ff7cd5be0 ffff881fe9572e60
[  363.219600]  ffff880fe5274590 0000000000013080 ffff880fe5295fd8 0000000000013080
[  363.219602]  ffff880ff919dcc0 ffff880fe5274590 ffff880fe5295d58 ffff880fe5295ec0
[  363.219605] Call Trace:
[  363.219608]  [<ffffffff816b7e09>] schedule+0x29/0x70
[  363.219610]  [<ffffffff816b7005>] schedule_timeout+0x1e5/0x250
[  363.219612]  [<ffffffff810954e1>] ? rwsem_wake+0x51/0x70
[  363.219615]  [<ffffffff81352e17>] ? call_rwsem_wake+0x17/0x30
[  363.219618]  [<ffffffff816b8ec6>] wait_for_completion+0xa6/0x110
[  363.219648]  [<ffffffff810805c0>] ? try_to_wake_up+0x2b0/0x2b0
[  363.219653]  [<ffffffff810ab950>] ? __call_rcu.constprop.61+0x240/0x240
[  363.219655]  [<ffffffff810a960d>] wait_rcu_gp+0x4d/0x60
[  363.219657]  [<ffffffff810a9620>] ? wait_rcu_gp+0x60/0x60
[  363.219659]  [<ffffffff810abd2c>] synchronize_sched+0x3c/0x50
[  363.219661]  [<ffffffff810757b5>] switch_task_namespaces+0x55/0x70
[  363.219664]  [<ffffffff8104e493>] SyS_unshare+0x193/0x270
[  363.219665]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  363.219667] INFO: task ip:34793 blocked for more than 120 seconds.
[  363.248607]       Not tainted 3.13.0 #1
[  363.265946] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  363.304072] ip              D ffffffff8180f480     0 34793  34778 0x00000000
[  363.304074]  ffff881fe8049d48 0000000000000086 ffff880ff4ad1d6c ffff881ff65949c0
[  363.304077]  ffff881fe87c5cc0 0000000000013080 ffff881fe8049fd8 0000000000013080
[  363.304080]  ffff880ff9172e60 ffff881fe87c5cc0 ffff881fe8049d38 ffff881fe8049e90
[  363.304082] Call Trace:
[  363.304085]  [<ffffffff816b7e09>] schedule+0x29/0x70
[  363.304087]  [<ffffffff816b7005>] schedule_timeout+0x1e5/0x250
[  363.304088]  [<ffffffff81080542>] ? try_to_wake_up+0x232/0x2b0
[  363.304090]  [<ffffffff810953c9>] ? __rwsem_do_wake+0x119/0x170
[  363.304093]  [<ffffffff816b8ec6>] wait_for_completion+0xa6/0x110
[  363.304094]  [<ffffffff810805c0>] ? try_to_wake_up+0x2b0/0x2b0
[  363.304096]  [<ffffffff810ab950>] ? __call_rcu.constprop.61+0x240/0x240
[  363.304098]  [<ffffffff810a960d>] wait_rcu_gp+0x4d/0x60
[  363.304100]  [<ffffffff810a9620>] ? wait_rcu_gp+0x60/0x60
[  363.304102]  [<ffffffff810abd2c>] synchronize_sched+0x3c/0x50
[  363.304104]  [<ffffffff811acca3>] namespace_unlock+0x83/0xe0
[  363.304106]  [<ffffffff811ade70>] SyS_umount+0x200/0x3b0
[  363.304107]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  363.304109]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  363.304111] INFO: task ip:34797 blocked for more than 120 seconds.
[  363.332079]       Not tainted 3.13.0 #1
[  363.349745] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  363.385570] ip              D ffffffff8180f480     0 34797  34781 0x00000000
[  363.385572]  ffff881fe8041d78 0000000000000082 ffff881ff7cd5be0 ffff880fe5274590
[  363.385575]  ffff881fe87cae60 0000000000013080 ffff881fe8041fd8 0000000000013080
[  363.385577]  ffff880ff9165cc0 ffff881fe87cae60 ffff881fe8041d58 ffff881fe8041ec0
[  363.385580] Call Trace:
[  363.385582]  [<ffffffff816b7e09>] schedule+0x29/0x70
[  363.385584]  [<ffffffff816b7005>] schedule_timeout+0x1e5/0x250
[  363.385586]  [<ffffffff810954e1>] ? rwsem_wake+0x51/0x70
[  363.385588]  [<ffffffff81352e17>] ? call_rwsem_wake+0x17/0x30
[  363.385591]  [<ffffffff816b8ec6>] wait_for_completion+0xa6/0x110
[  363.385593]  [<ffffffff810805c0>] ? try_to_wake_up+0x2b0/0x2b0
[  363.385594]  [<ffffffff810ab950>] ? __call_rcu.constprop.61+0x240/0x240
[  363.385597]  [<ffffffff810a960d>] wait_rcu_gp+0x4d/0x60
[  363.385599]  [<ffffffff810a9620>] ? wait_rcu_gp+0x60/0x60
[  363.385601]  [<ffffffff810abd2c>] synchronize_sched+0x3c/0x50
[  363.385603]  [<ffffffff810757b5>] switch_task_namespaces+0x55/0x70
[  363.385605]  [<ffffffff8104e493>] SyS_unshare+0x193/0x270
[  363.385607]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  363.385609] INFO: task ip:34811 blocked for more than 120 seconds.
[  363.413905]       Not tainted 3.13.0 #1
[  363.431442] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  363.467456] ip              D ffffffff8180f480     0 34811  34807 0x00000000
[  363.467458]  ffff880fe4ee7d78 0000000000000086 ffff881ff7cd5be0 0000001200000011
[  363.467461]  ffff880fe8615cc0 0000000000013080 ffff880fe4ee7fd8 0000000000013080
[  363.467463]  ffff880ff91d1730 ffff880fe8615cc0 ffff880fe4ee7d58 ffff880fe4ee7ec0
[  363.467466] Call Trace:
[  363.467468]  [<ffffffff816b7e09>] schedule+0x29/0x70
[  363.467470]  [<ffffffff816b7005>] schedule_timeout+0x1e5/0x250
[  363.467472]  [<ffffffff811ad560>] ? attach_mnt+0x30/0xa0
[  363.467474]  [<ffffffff811ae220>] ? copy_tree+0x1e0/0x310
[  363.467476]  [<ffffffff816b8ec6>] wait_for_completion+0xa6/0x110
[  363.467478]  [<ffffffff810805c0>] ? try_to_wake_up+0x2b0/0x2b0
[  363.467479]  [<ffffffff810ab950>] ? __call_rcu.constprop.61+0x240/0x240
[  363.467481]  [<ffffffff810a960d>] wait_rcu_gp+0x4d/0x60
[  363.467483]  [<ffffffff810a9620>] ? wait_rcu_gp+0x60/0x60
[  363.467485]  [<ffffffff810abd2c>] synchronize_sched+0x3c/0x50
[  363.467487]  [<ffffffff810757b5>] switch_task_namespaces+0x55/0x70
[  363.467489]  [<ffffffff8104e493>] SyS_unshare+0x193/0x270
[  363.467491]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  372.968310] BUG: soft lockup - CPU#12 stuck for 23s! [ip:34798]
[  372.995272] Modules linked in: veth ipmi_devintf 8021q garp xt_CHECKSUM iptable_mangle bridge stp llc kvm_intel kvm bonding ipt_REJECT xt_LOG xt_limit xt_tcpudp xt_addrtype nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter psmouse ip6_tables iptable_filter ip_tables x_tables gpio_ich igb mpt2sas i2c_algo_bit sb_edac scsi_transport_sas ptp ioatdma ipmi_si serio_raw hpwdt edac_core lpc_ich pps_core hpilo be2net dca ipmi_msghandler raid_class mac_hid acpi_power_meter lp parport shpchp hpsa
[  372.995298] CPU: 12 PID: 34798 Comm: ip Not tainted 3.13.0 #1
[  372.995306] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  372.995307] task: ffff880fe4d3ae60 ti: ffff880fe4c9e000 task.ti: ffff880fe4c9e000
[  372.995308] RIP: 0010:[<ffffffff811ad1e4>]  [<ffffffff811ad1e4>] __lookup_mnt+0x64/0x80
[  372.995311] RSP: 0018:ffff880fe4c9fcd8  EFLAGS: 00000283
[  372.995312] RAX: ffff880fe7153480 RBX: ffffffff8119859b RCX: ffff881ff9464370
[  372.995313] RDX: ffff880fe7153480 RSI: ffff8800b985e9c0 RDI: ffff880fe94cd1a0
[  372.995314] RBP: ffff880fe4c9fce8 R08: 326f6d7500737973 R09: ffff8800b985e9c0
[  372.995315] R10: 003f010100030103 R11: ffffc90000002000 R12: ffff880fe4c9fe00
[  372.995316] R13: ffff880fe244bc08 R14: 0000000000000000 R15: ffff881fe9ce21f0
[  372.995317] FS:  00007fe7048e0700(0000) GS:ffff88203f880000(0000) knlGS:0000000000000000
[  372.995318] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  372.995319] CR2: 000000000043e408 CR3: 0000001fe94bf000 CR4: 00000000000407e0
[  372.995320] Stack:
[  372.995321]  ffff881fe87c62fc ffff880fe7153480 ffff880fe4c9fd18 ffffffff811ad2b0
[  372.995324]  ffff880fe4c9fdb8 ffff880fe4c9ff28 ffff881ff65949c0 ffff880fe4c9ff28
[  372.995326]  ffff880fe4c9fd38 ffffffff8119855e ffff880fe4c9fda8 ffff881ff65949c0
[  372.995329] Call Trace:
[  372.995330]  [<ffffffff811ad2b0>] lookup_mnt+0x30/0x70
[  372.995333]  [<ffffffff8119855e>] follow_mount+0x5e/0x70
[  372.995334]  [<ffffffff81199070>] mountpoint_last+0xc0/0x1d0
[  372.995336]  [<ffffffff8119ad47>] path_mountpoint+0xd7/0x440
[  372.995338]  [<ffffffff810953c9>] ? __rwsem_do_wake+0x119/0x170
[  372.995341]  [<ffffffff81352e17>] ? call_rwsem_wake+0x17/0x30
[  372.995343]  [<ffffffff8117f551>] ? kmem_cache_alloc+0x31/0x160
[  372.995345]  [<ffffffff8119922c>] ? getname_flags+0x5c/0x190
[  372.995347]  [<ffffffff8119b0e4>] filename_mountpoint+0x34/0xc0
[  372.995349]  [<ffffffff8119e65a>] user_path_mountpoint_at+0x4a/0x70
[  372.995351]  [<ffffffff811adcef>] SyS_umount+0x7f/0x3b0
[  372.995352]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  372.995354]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  372.995355] Code: 48 89 45 f8 48 8b 55 f8 31 c0 48 39 ca 74 2b 48 89 d0 eb 13 0f 1f 00 48 8b 00 48 89 45 f8 48 8b 45 f8 48 39 c8 74 18 48 8b 50 10 <48> 83 c2 20 48 39 d7 75 e3 48 39 70 18 75 dd c9 c3 0f 1f 00 31 

--------------030605010800050300060809--
