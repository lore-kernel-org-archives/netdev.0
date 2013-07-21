From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [BUG] ipv6, rawv6_close(): BUG: unable to handle kernel paging
 request
Date: Mon, 22 Jul 2013 02:40:35 +0530
Message-ID: <51EC4E4B.6040505@linux.vnet.ibm.com>
References: <51EC283D.5010208@linux.vnet.ibm.com> <20130721205352.GB15442@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:39456 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756154Ab3GUVOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 17:14:21 -0400
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Mon, 22 Jul 2013 18:09:40 +1000
In-Reply-To: <20130721205352.GB15442@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2013 02:23 AM, Hannes Frederic Sowa wrote:
> On Sun, Jul 21, 2013 at 11:58:13PM +0530, Srivatsa S. Bhat wrote:
>> I'm seeing this on every boot.
>>
>> Version: Latest mainline (commit ea45ea70b)
> 
> Thanks for the report! Could you try the following patch?
> 

That didn't seem to help :-(

Below is the new trace (not much different than the old one).

Regards,
Srivatsa S. Bhat

-----------------------------------------------------------------------

BUG: unable to handle kernel paging request at ffff881029d8b020
IP: [<ffffffffa0366b0e>] ip6mr_sk_done+0x3e/0xc0 [ipv6]
PGD 290a067 PUD 207fbff067 PMD 207fab0067 PTE 8000001029d8b060
Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
Modules linked in: ebtable_nat ebtables nfs fscache nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter ip_tables nfsd lockd nfs_acl exportfs auth_rpcgss autofs4 sunrpc 8021q garp bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 vfat fat vhost_net macvtap macvlan vhost tun kvm_intel kvm uinput iTCO_wdt iTCO_vendor_support cdc_ether usbnet mii microcode i2c_i801 i2c_core lpc_ich mfd_core shpchp mlx4_core ioatdma dca be2net wmi acpi_cpufreq mperf ext4 jbd2 mbcache dm_mirror dm_region_hash dm_log dm_mod
CPU: 9 PID: 52 Comm: kworker/u34:0 Not tainted 3.11.0-rc1-ip6fix-a #14
Hardware name: IBM  -[8737R2A]-/00Y2738, BIOS -[B2E120RUS-1.20]- 11/30/2012
Workqueue: netns cleanup_net
task: ffff882028482180 ti: ffff882028484000 task.ti: ffff882028484000
RIP: 0010:[<ffffffffa0366b0e>]  [<ffffffffa0366b0e>] ip6mr_sk_done+0x3e/0xc0 [ipv6]
RSP: 0018:ffff882028485bd8  EFLAGS: 00010286
RAX: ffff882028482180 RBX: ffff881029d8b000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffffa03785a4
RBP: ffff882028485bf8 R08: 0000000000000002 R09: 0000000000000000
R10: 0000000000000000 R11: 2222222222222222 R12: ffff88102492c040
R13: ffff880ff65399c0 R14: ffff882028463800 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88206fc40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff881029d8b020 CR3: 0000000001c0b000 CR4: 00000000000407e0
Stack:
 ffff882028485c18 ffff880ff65399c0 ffff88102c867c00 0000000000000000
 ffff882028485c18 ffffffffa034d9d1 ffff882028463800 ffff880ff65399c0
 ffff882028485c58 ffffffff815bdecb ffffffff815bddf2 ffff880ff65399c0
Call Trace:
 [<ffffffffa034d9d1>] rawv6_close+0x21/0x40 [ipv6]
 [<ffffffff815bdecb>] inet_release+0xfb/0x220
 [<ffffffff815bddf2>] ? inet_release+0x22/0x220
 [<ffffffffa032686f>] inet6_release+0x3f/0x50 [ipv6]
 [<ffffffff8151c1d9>] sock_release+0x29/0xa0
 [<ffffffff81525520>] sk_release_kernel+0x30/0x70
 [<ffffffffa034f14b>] icmpv6_sk_exit+0x3b/0x80 [ipv6]
 [<ffffffff8152fff9>] ops_exit_list+0x39/0x60
 [<ffffffff815306fb>] cleanup_net+0xfb/0x1a0
 [<ffffffff81075e3a>] process_one_work+0x1da/0x610
 [<ffffffff81075dc9>] ? process_one_work+0x169/0x610
 [<ffffffff81076390>] worker_thread+0x120/0x3a0
 [<ffffffff81076270>] ? process_one_work+0x610/0x610
 [<ffffffff8107da2e>] kthread+0xee/0x100
 [<ffffffff8107d940>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff8162a99c>] ret_from_fork+0x7c/0xb0
 [<ffffffff8107d940>] ? __init_kthread_worker+0x70/0x70
Code: f8 66 66 66 66 90 4c 8b 67 30 49 89 fd e8 db 3c 1e e1 48 c7 c7 a0 85 37 a0 e8 ef 99 2b e1 49 8b 9c 24 90 08 00 00 48 85 db 74 06 <4c> 39 6b 20 74 2c 48 c7 c7 a0 85 37 a0 bb f3 ff ff ff e8 5b 98 
RIP  [<ffffffffa0366b0e>] ip6mr_sk_done+0x3e/0xc0 [ipv6]
 RSP <ffff882028485bd8>
CR2: ffff881029d8b020
---[ end trace fef188ae87dec56e ]---
Kernel panic - not syncing: Fatal exception in interrupt
------------[ cut here ]------------
WARNING: CPU: 9 PID: 52 at arch/x86/kernel/smp.c:124 native_smp_send_reschedule+0x5c/0x60()
Modules linked in: ebtable_nat ebtables nfs fscache nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter ip_tables nfsd lockd nfs_acl exportfs auth_rpcgss autofs4 sunrpc 8021q garp bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 vfat fat vhost_net macvtap macvlan vhost tun kvm_intel kvm uinput iTCO_wdt iTCO_vendor_support cdc_ether usbnet mii microcode i2c_i801 i2c_core lpc_ich mfd_core shpchp mlx4_core ioatdma dca be2net wmi acpi_cpufreq mperf ext4 jbd2 mbcache dm_mirror dm_region_hash dm_log dm_mod
CPU: 9 PID: 52 Comm: kworker/u34:0 Tainted: G      D      3.11.0-rc1-ip6fix-a #14
Hardware name: IBM  -[8737R2A]-/00Y2738, BIOS -[B2E120RUS-1.20]- 11/30/2012
Workqueue: netns cleanup_net
 000000000000007c ffff88206fc43d08 ffffffff8161ab9c ffffffff819dd1d6
 0000000000000000 ffff88206fc43d48 ffffffff8104e6ac ffffffff8109e7df
 0000000000000008 0000000000000008 00000000fffcef4c 0000000000000009
Call Trace:
 <IRQ>  [<ffffffff8161ab9c>] dump_stack+0x59/0x7d
 [<ffffffff8104e6ac>] warn_slowpath_common+0x8c/0xc0
 [<ffffffff8109e7df>] ? trigger_load_balance+0x11f/0x520
 [<ffffffff8104e6fa>] warn_slowpath_null+0x1a/0x20
 [<ffffffff81030f6c>] native_smp_send_reschedule+0x5c/0x60
 [<ffffffff8109ea65>] trigger_load_balance+0x3a5/0x520
 [<ffffffff8109e73f>] ? trigger_load_balance+0x7f/0x520
 [<ffffffff8108b39f>] scheduler_tick+0xaf/0xf0
 [<ffffffff81060a79>] update_process_times+0x69/0x80
 [<ffffffff81081ecf>] ? __run_hrtimer+0x6f/0x2e0
 [<ffffffff810bb859>] tick_sched_handle+0x39/0x80
 [<ffffffff810bba84>] tick_sched_timer+0x54/0x90
 [<ffffffff81081ee3>] __run_hrtimer+0x83/0x2e0
 [<ffffffff810bba30>] ? tick_nohz_handler+0xc0/0xc0
 [<ffffffff81082426>] hrtimer_interrupt+0x116/0x2a0
 [<ffffffff8103467b>] local_apic_timer_interrupt+0x3b/0x60
 [<ffffffff8162ca45>] smp_apic_timer_interrupt+0x45/0x60
 [<ffffffff8162b6af>] apic_timer_interrupt+0x6f/0x80
 <EOI>  [<ffffffff8161a9d2>] ? panic+0x19c/0x1e2
 [<ffffffff8161a9d5>] ? panic+0x19f/0x1e2
 [<ffffffff8161a9d2>] ? panic+0x19c/0x1e2
 [<ffffffff81052628>] ? kmsg_dump+0x1d8/0x2a0
 [<ffffffff81052476>] ? kmsg_dump+0x26/0x2a0
 [<ffffffff81052610>] ? kmsg_dump+0x1c0/0x2a0
 [<ffffffff81621f8a>] oops_end+0xea/0xf0
 [<ffffffff81042e0e>] no_context+0x11e/0x1f0
 [<ffffffff8104300d>] __bad_area_nosemaphore+0x12d/0x230
 [<ffffffff81043123>] bad_area_nosemaphore+0x13/0x20
 [<ffffffff81624f13>] __do_page_fault+0x133/0x4e0
 [<ffffffff8104467b>] ? __change_page_attr+0x6b/0x2b0
 [<ffffffff8104490d>] ? __change_page_attr_set_clr+0x4d/0xb0
 [<ffffffff816252f7>] do_page_fault+0x37/0x70
 [<ffffffff8162108c>] ? restore_args+0x30/0x30
 [<ffffffff81621262>] page_fault+0x22/0x30
 [<ffffffffa0366b0e>] ? ip6mr_sk_done+0x3e/0xc0 [ipv6]
 [<ffffffffa0366b01>] ? ip6mr_sk_done+0x31/0xc0 [ipv6]
 [<ffffffffa034d9d1>] rawv6_close+0x21/0x40 [ipv6]
 [<ffffffff815bdecb>] inet_release+0xfb/0x220
 [<ffffffff815bddf2>] ? inet_release+0x22/0x220
 [<ffffffffa032686f>] inet6_release+0x3f/0x50 [ipv6]
 [<ffffffff8151c1d9>] sock_release+0x29/0xa0
 [<ffffffff81525520>] sk_release_kernel+0x30/0x70
 [<ffffffffa034f14b>] icmpv6_sk_exit+0x3b/0x80 [ipv6]
 [<ffffffff8152fff9>] ops_exit_list+0x39/0x60
 [<ffffffff815306fb>] cleanup_net+0xfb/0x1a0
 [<ffffffff81075e3a>] process_one_work+0x1da/0x610
 [<ffffffff81075dc9>] ? process_one_work+0x169/0x610
 [<ffffffff81076390>] worker_thread+0x120/0x3a0
 [<ffffffff81076270>] ? process_one_work+0x610/0x610
 [<ffffffff8107da2e>] kthread+0xee/0x100
 [<ffffffff8107d940>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff8162a99c>] ret_from_fork+0x7c/0xb0
 [<ffffffff8107d940>] ? __init_kthread_worker+0x70/0x70
---[ end trace fef188ae87dec56f ]---
