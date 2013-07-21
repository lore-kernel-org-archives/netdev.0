From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [BUG] ipv6, rawv6_close(): BUG: unable to handle kernel paging request
Date: Sun, 21 Jul 2013 23:58:13 +0530
Message-ID: <51EC283D.5010208@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm seeing this on every boot.

Version: Latest mainline (commit ea45ea70b)
 
Regards,
Srivatsa S. Bhat

---------------------------------------------------------------

BUG: unable to handle kernel paging request at ffff882018552020
IP: [<ffffffffa0366b02>] ip6mr_sk_done+0x32/0xb0 [ipv6]
PGD 290a067 PUD 207ffe0067 PMD 207ff1d067 PTE 8000002018552060
Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
Modules linked in: ebtable_nat ebtables nfs fscache nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter ip_tables nfsd lockd nfs_acl exportfs auth_rpcgss autofs4 sunrpc 8021q garp bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 vfat fat vhost_net macvtap macvlan vhost tun kvm_intel kvm uinput iTCO_wdt iTCO_vendor_support cdc_ether usbnet mii microcode i2c_i801 i2c_core lpc_ich mfd_core shpchp ioatdma dca mlx4_core be2net wmi acpi_cpufreq mperf ext4 jbd2 mbcache dm_mirror dm_region_hash dm_log dm_mod
CPU: 0 PID: 7 Comm: kworker/u33:0 Not tainted 3.11.0-rc1-ea45e-a #4
Hardware name: IBM  -[8737R2A]-/00Y2738, BIOS -[B2E120RUS-1.20]- 11/30/2012
Workqueue: netns cleanup_net
task: ffff8810393641c0 ti: ffff881039366000 task.ti: ffff881039366000
RIP: 0010:[<ffffffffa0366b02>]  [<ffffffffa0366b02>] ip6mr_sk_done+0x32/0xb0 [ipv6]
RSP: 0018:ffff881039367bd8  EFLAGS: 00010286
RAX: ffff881039367fd8 RBX: ffff882018552000 RCX: dead000000200200
RDX: 0000000000000000 RSI: ffff881039367b68 RDI: ffff881039367b68
RBP: ffff881039367bf8 R08: ffff881039367b68 R09: 2222222222222222
R10: 2222222222222222 R11: 2222222222222222 R12: ffff882015a7a040
R13: ffff882014eb89c0 R14: ffff8820289e2800 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88103fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff882018552020 CR3: 0000000001c0b000 CR4: 00000000000407f0
Stack:
 ffff881039367c18 ffff882014eb89c0 ffff882015e28c00 0000000000000000
 ffff881039367c18 ffffffffa034d9d1 ffff8820289e2800 ffff882014eb89c0
 ffff881039367c58 ffffffff815bdecb ffffffff815bddf2 ffff882014eb89c0
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
Code: 20 48 89 5d e8 4c 89 65 f0 4c 89 6d f8 66 66 66 66 90 4c 8b 67 30 49 89 fd e8 db 3c 1e e1 49 8b 9c 24 90 08 00 00 48 85 db 74 06 <4c> 39 6b 20 74 20 bb f3 ff ff ff e8 8e 3c 1e e1 89 d8 4c 8b 65 
RIP  [<ffffffffa0366b02>] ip6mr_sk_done+0x32/0xb0 [ipv6]
 RSP <ffff881039367bd8>
CR2: ffff882018552020
---[ end trace e8367f5addd58b5f ]---
BUG: sleeping function called from invalid context at kernel/rwsem.c:20
in_atomic(): 0, irqs_disabled(): 1, pid: 7, name: kworker/u33:0
INFO: lockdep is turned off.
irq event stamp: 7804
hardirqs last  enabled at (7803): [<ffffffff81620ad0>] _raw_spin_unlock_irq+0x30/0x50
hardirqs last disabled at (7804): [<ffffffff81620287>] _raw_spin_lock_irq+0x17/0x60
softirqs last  enabled at (7122): [<ffffffff81058ea6>] __do_softirq+0x1e6/0x400
softirqs last disabled at (7113): [<ffffffff8105921d>] irq_exit+0xed/0x100
CPU: 0 PID: 7 Comm: kworker/u33:0 Tainted: G      D      3.11.0-rc1-ea45e-a #4
Hardware name: IBM  -[8737R2A]-/00Y2738, BIOS -[B2E120RUS-1.20]- 11/30/2012
Workqueue: netns cleanup_net
 ffffffff819f4a61 ffff881039367828 ffffffff8161ab9c ffff881039367828
 ffff8810393641c0 ffff881039367858 ffffffff8108cbee ffff881039367898
 ffff881039357ec8 0000000000000009 0000000000000009 ffff881039367888
Call Trace:
 [<ffffffff8161ab9c>] dump_stack+0x59/0x7d
 [<ffffffff8108cbee>] __might_sleep+0x17e/0x230
 [<ffffffff8161d7b4>] down_read+0x24/0x70
 [<ffffffff81068404>] exit_signals+0x24/0x140
 [<ffffffff81084b36>] ? blocking_notifier_call_chain+0x16/0x20
 [<ffffffff81055ee2>] do_exit+0xb2/0x4c0
 [<ffffffff81621f49>] oops_end+0xa9/0xf0
 [<ffffffff81042e0e>] no_context+0x11e/0x1f0
 [<ffffffff8104300d>] __bad_area_nosemaphore+0x12d/0x230
 [<ffffffff81043123>] bad_area_nosemaphore+0x13/0x20
 [<ffffffff81624f13>] __do_page_fault+0x133/0x4e0
 [<ffffffff8104467b>] ? __change_page_attr+0x6b/0x2b0
 [<ffffffff8104490d>] ? __change_page_attr_set_clr+0x4d/0xb0
 [<ffffffff816252f7>] do_page_fault+0x37/0x70
 [<ffffffff8162108c>] ? restore_args+0x30/0x30
 [<ffffffff81621262>] page_fault+0x22/0x30
 [<ffffffffa0366b02>] ? ip6mr_sk_done+0x32/0xb0 [ipv6]
 [<ffffffffa0366af5>] ? ip6mr_sk_done+0x25/0xb0 [ipv6]
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
BUG: unable to handle kernel paging request at ffffffffffffffa8
IP: [<ffffffff8107d020>] kthread_data+0x10/0x20
PGD 1c0c067 PUD 1c0e067 PMD 0 
Oops: 0000 [#2] SMP DEBUG_PAGEALLOC
Modules linked in: ebtable_nat ebtables nfs fscache nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter ip_tables nfsd lockd nfs_acl exportfs auth_rpcgss autofs4 sunrpc 8021q garp bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 vfat fat vhost_net macvtap macvlan vhost tun kvm_intel kvm uinput iTCO_wdt iTCO_vendor_support cdc_ether usbnet mii microcode i2c_i801 i2c_core lpc_ich mfd_core shpchp ioatdma dca mlx4_core be2net wmi acpi_cpufreq mperf ext4 jbd2 mbcache dm_mirror dm_region_hash dm_log dm_mod
CPU: 6 PID: 7 Comm: kworker/u33:0 Tainted: G      D      3.11.0-rc1-ea45e-a #4
Hardware name: IBM  -[8737R2A]-/00Y2738, BIOS -[B2E120RUS-1.20]- 11/30/2012
task: ffff8810393641c0 ti: ffff881039366000 task.ti: ffff881039366000
RIP: 0010:[<ffffffff8107d020>]  [<ffffffff8107d020>] kthread_data+0x10/0x20
RSP: 0018:ffff8810393677f8  EFLAGS: 00010092
RAX: 0000000000000000 RBX: 0000000000000006 RCX: ffffffff81ff6ea0
RDX: 0000000000000000 RSI: 0000000000000006 RDI: ffff8810393641c0
RBP: ffff8810393677f8 R08: ffff881039364230 R09: 000000000000bdde
R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000006
R13: ffff8810393647d8 R14: 0000000000000001 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88103fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000028 CR3: 0000000001c0b000 CR4: 00000000000407e0
Stack:
 ffff881039367818 ffffffff81070d85 ffff881039367818 ffff88103fd93c00
 ffff8810393678a8 ffffffff8161e40b ffff881039367858 ffff881039366000
 ffff881039367fd8 ffff881039366000 ffff881039366010 ffff881039366000
Call Trace:
 [<ffffffff81070d85>] wq_worker_sleeping+0x15/0xa0
 [<ffffffff8161e40b>] __schedule+0x6cb/0x860
 [<ffffffff8161e799>] schedule+0x29/0x70
 [<ffffffff81056105>] do_exit+0x2d5/0x4c0
 [<ffffffff81621f49>] oops_end+0xa9/0xf0
 [<ffffffff81042e0e>] no_context+0x11e/0x1f0
 [<ffffffff8104300d>] __bad_area_nosemaphore+0x12d/0x230
 [<ffffffff81043123>] bad_area_nosemaphore+0x13/0x20
 [<ffffffff81624f13>] __do_page_fault+0x133/0x4e0
 [<ffffffff8104467b>] ? __change_page_attr+0x6b/0x2b0
 [<ffffffff8104490d>] ? __change_page_attr_set_clr+0x4d/0xb0
 [<ffffffff816252f7>] do_page_fault+0x37/0x70
 [<ffffffff8162108c>] ? restore_args+0x30/0x30
 [<ffffffff81621262>] page_fault+0x22/0x30
 [<ffffffffa0366b02>] ? ip6mr_sk_done+0x32/0xb0 [ipv6]
 [<ffffffffa0366af5>] ? ip6mr_sk_done+0x25/0xb0 [ipv6]
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
Code: 70 05 00 00 48 8b 40 98 c9 48 c1 e8 02 83 e0 01 c3 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 66 66 66 66 90 48 8b 87 70 05 00 00 <48> 8b 40 a8 c9 c3 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 66 
RIP  [<ffffffff8107d020>] kthread_data+0x10/0x20
 RSP <ffff8810393677f8>
CR2: ffffffffffffffa8
---[ end trace e8367f5addd58b60 ]---
Fixing recursive fault but reboot is needed!
