From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: mod_timer: list_add corruption: WARNING: CPU: 1 PID: 0 at lib/list_debug.c:33
 __list_add+0xbe/0xd0()
Date: Fri, 19 Jul 2013 17:17:53 +0530
Message-ID: <51E92769.7090106@linux.vnet.ibm.com>
References: <51E557C0.2060602@linux.vnet.ibm.com> <alpine.DEB.2.02.1307191323150.4089@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1307191323150.4089@ionos.tec.linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/19/2013 04:55 PM, Thomas Gleixner wrote:
> On Tue, 16 Jul 2013, Srivatsa S. Bhat wrote:
>> ------------[ cut here ]------------
>> WARNING: CPU: 1 PID: 0 at lib/list_debug.c:33 __list_add+0xbe/0xd0()
>> list_add corruption. prev->next should be next (ffff8810396b5568), but was           (null). (prev=ffff88102c1344c0).
> 
> Can you please enable debugobjects?
> 

Sure Thomas, please find the new traces below, with
debug objects enabled.
Regards,
Srivatsa S. Bhat


------------[ cut here ]------------
WARNING: CPU: 1 PID: 0 at lib/debugobjects.c:260 debug_print_object+0x8e/0xb0()
ODEBUG: init active (active state 0) object type: timer_list hint: br_multicast_group_expired+0x0/0x110 [bridge]
Modules linked in: ebtable_nat ebtables nfs fscache nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter ip_tables nfsd lockd nfs_acl exportfs auth_rpcgss autofs4 sunrpc 8021q garp bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 vfat fat vhost_net macvtap macvlan vhost tun kvm_intel kvm uinput iTCO_wdt iTCO_vendor_support cdc_ether usbnet mii microcode i2c_i801 i2c_core lpc_ich mfd_core shpchp mlx4_core ioatdma dca be2net wmi acpi_cpufreq mperf ext4 jbd2 mbcache dm_mirror dm_region_hash dm_log dm_mod
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.11.0-rc1-dbg-a #16
Hardware name: IBM  -[8737R2A]-/00Y2738, BIOS -[B2E120RUS-1.20]- 11/30/2012
 0000000000000104 ffff88103fc43908 ffffffff8161b3c9 ffffffff81a14151
 ffff88103fc43958 ffff88103fc43948 ffffffff8104e6bc 0000000000000000
 ffffffff81a2cfae ffff88101b21cfd8 ffffffff81c37ba0 ffffffff828f2ca8
Call Trace:
 <IRQ>  [<ffffffff8161b3c9>] dump_stack+0x59/0x80
 [<ffffffff8104e6bc>] warn_slowpath_common+0x8c/0xc0
 [<ffffffff8104e7a6>] warn_slowpath_fmt+0x46/0x50
 [<ffffffff812b5aee>] debug_print_object+0x8e/0xb0
 [<ffffffffa04247f0>] ? br_multicast_free_pg+0x20/0x20 [bridge]
 [<ffffffff812b65e2>] ? __debug_object_init+0x42/0x3f0
 [<ffffffff812b67bf>] __debug_object_init+0x21f/0x3f0
 [<ffffffff812b69df>] debug_object_init+0x1f/0x30
 [<ffffffff81060ea9>] init_timer_key+0x39/0x100
 [<ffffffffa0425ec5>] br_ip4_multicast_query+0x155/0x380 [bridge]
 [<ffffffffa0427eef>] br_multicast_ipv4_rcv+0x2cf/0x3d0 [bridge]
 [<ffffffff8162140b>] ? _raw_spin_unlock+0x2b/0x50
 [<ffffffffa0419a9b>] ? br_fdb_update+0x1db/0x2b0 [bridge]
 [<ffffffffa04284b5>] br_multicast_rcv+0x45/0x60 [bridge]
 [<ffffffffa041bdfe>] br_handle_frame_finish+0x16e/0x3c0 [bridge]
 [<ffffffffa041bac8>] br_handle_frame+0x238/0x400 [bridge]
 [<ffffffffa041b890>] ? br_del_bridge+0x80/0x80 [bridge]
 [<ffffffff81539ca7>] __netif_receive_skb_core+0x237/0x960
 [<ffffffff81539ade>] ? __netif_receive_skb_core+0x6e/0x960
 [<ffffffff8153a3f7>] __netif_receive_skb+0x27/0x70
 [<ffffffff8153c6fd>] netif_receive_skb+0x2d/0x210
 [<ffffffff81527e65>] ? __netdev_alloc_skb+0xa5/0x110
 [<ffffffffa0129a0f>] be_rx_compl_process+0xef/0x140 [be2net]
 [<ffffffffa0129dc2>] be_process_rx+0xe2/0x1a0 [be2net]
 [<ffffffffa0129fbd>] be_poll+0x13d/0x1d0 [be2net]
 [<ffffffff8153dab8>] net_rx_action+0xd8/0x2a0
 [<ffffffff81058e19>] __do_softirq+0x149/0x400
 [<ffffffff8105922d>] irq_exit+0xed/0x100
 [<ffffffff8162d206>] do_IRQ+0x66/0xe0
 [<ffffffff8162182f>] common_interrupt+0x6f/0x6f
 <EOI>  [<ffffffff814f148b>] ? cpuidle_enter_state+0x5b/0xe0
 [<ffffffff814f1487>] ? cpuidle_enter_state+0x57/0xe0
 [<ffffffff81625cd0>] ? notifier_call_chain+0x120/0x120
 [<ffffffff814f197f>] cpuidle_idle_call+0xcf/0x160
 [<ffffffff8100cf0e>] arch_cpu_idle+0xe/0x30
 [<ffffffff810b1291>] cpu_idle_loop+0x81/0x3a0
 [<ffffffff810b1620>] cpu_startup_entry+0x70/0x80
 [<ffffffff810334fc>] start_secondary+0xdc/0xe0
---[ end trace 68b46b9f74e14585 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 0 at lib/debugobjects.c:260 debug_print_object+0x8e/0xb0()
ODEBUG: init active (active state 0) object type: timer_list hint: br_multicast_group_expired+0x0/0x110 [bridge]
Modules linked in: ebtable_nat ebtables nfs fscache nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter ip_tables nfsd lockd nfs_acl exportfs auth_rpcgss autofs4 sunrpc 8021q garp bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 vfat fat vhost_net macvtap macvlan vhost tun kvm_intel kvm uinput iTCO_wdt iTCO_vendor_support cdc_ether usbnet mii microcode i2c_i801 i2c_core lpc_ich mfd_core shpchp mlx4_core ioatdma dca be2net wmi acpi_cpufreq mperf ext4 jbd2 mbcache dm_mirror dm_region_hash dm_log dm_mod
CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W    3.11.0-rc1-dbg-a #16
Hardware name: IBM  -[8737R2A]-/00Y2738, BIOS -[B2E120RUS-1.20]- 11/30/2012
 0000000000000104 ffff88103fc43908 ffffffff8161b3c9 ffffffff81a14151
 ffff88103fc43958 ffff88103fc43948 ffffffff8104e6bc 0000000000000000
 ffffffff81a2cfae ffff88101b21cfd8 ffffffff81c37ba0 ffffffff828f2ca8
Call Trace:
 <IRQ>  [<ffffffff8161b3c9>] dump_stack+0x59/0x80
 [<ffffffff8104e6bc>] warn_slowpath_common+0x8c/0xc0
 [<ffffffff8104e7a6>] warn_slowpath_fmt+0x46/0x50
 [<ffffffff812b5aee>] debug_print_object+0x8e/0xb0
 [<ffffffffa04247f0>] ? br_multicast_free_pg+0x20/0x20 [bridge]
 [<ffffffff812b65e2>] ? __debug_object_init+0x42/0x3f0
 [<ffffffff812b67bf>] __debug_object_init+0x21f/0x3f0
 [<ffffffff812b69df>] debug_object_init+0x1f/0x30
 [<ffffffff81060ea9>] init_timer_key+0x39/0x100
 [<ffffffffa0425ec5>] br_ip4_multicast_query+0x155/0x380 [bridge]
 [<ffffffffa0427eef>] br_multicast_ipv4_rcv+0x2cf/0x3d0 [bridge]
 [<ffffffff8156d93e>] ? nf_hook_slow+0x16e/0x2a0
 [<ffffffffa0419a07>] ? br_fdb_update+0x147/0x2b0 [bridge]
 [<ffffffffa04284b5>] br_multicast_rcv+0x45/0x60 [bridge]
 [<ffffffffa041bdfe>] br_handle_frame_finish+0x16e/0x3c0 [bridge]
 [<ffffffffa041bac8>] br_handle_frame+0x238/0x400 [bridge]
 [<ffffffffa041b890>] ? br_del_bridge+0x80/0x80 [bridge]
 [<ffffffff81539ca7>] __netif_receive_skb_core+0x237/0x960
 [<ffffffff81539ade>] ? __netif_receive_skb_core+0x6e/0x960
 [<ffffffff810c2d1d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8153a3f7>] __netif_receive_skb+0x27/0x70
 [<ffffffff8153c6fd>] netif_receive_skb+0x2d/0x210
 [<ffffffff81527e65>] ? __netdev_alloc_skb+0xa5/0x110
 [<ffffffffa0129a0f>] be_rx_compl_process+0xef/0x140 [be2net]
 [<ffffffffa0129dc2>] be_process_rx+0xe2/0x1a0 [be2net]
 [<ffffffffa0129fbd>] be_poll+0x13d/0x1d0 [be2net]
 [<ffffffff8153dab8>] net_rx_action+0xd8/0x2a0
 [<ffffffff81058e19>] __do_softirq+0x149/0x400
 [<ffffffff8105922d>] irq_exit+0xed/0x100
 [<ffffffff8162d206>] do_IRQ+0x66/0xe0
 [<ffffffff8162182f>] common_interrupt+0x6f/0x6f
 <EOI>  [<ffffffff814f148b>] ? cpuidle_enter_state+0x5b/0xe0
 [<ffffffff814f1487>] ? cpuidle_enter_state+0x57/0xe0
 [<ffffffff81625cd0>] ? notifier_call_chain+0x120/0x120
 [<ffffffff814f197f>] cpuidle_idle_call+0xcf/0x160
 [<ffffffff8100cf0e>] arch_cpu_idle+0xe/0x30
 [<ffffffff810b1291>] cpu_idle_loop+0x81/0x3a0
 [<ffffffff810b1620>] cpu_startup_entry+0x70/0x80
 [<ffffffff810334fc>] start_secondary+0xdc/0xe0
---[ end trace 68b46b9f74e14586 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 0 at lib/debugobjects.c:260 debug_print_object+0x8e/0xb0()
ODEBUG: init active (active state 0) object type: timer_list hint: br_multicast_group_expired+0x0/0x110 [bridge]
Modules linked in: ebtable_nat ebtables nfs fscache nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter ip_tables nfsd lockd nfs_acl exportfs auth_rpcgss autofs4 sunrpc 8021q garp bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 vfat fat vhost_net macvtap macvlan vhost tun kvm_intel kvm uinput iTCO_wdt iTCO_vendor_support cdc_ether usbnet mii microcode i2c_i801 i2c_core lpc_ich mfd_core shpchp mlx4_core ioatdma dca be2net wmi acpi_cpufreq mperf ext4 jbd2 mbcache dm_mirror dm_region_hash dm_log dm_mod
CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W    3.11.0-rc1-dbg-a #16
Hardware name: IBM  -[8737R2A]-/00Y2738, BIOS -[B2E120RUS-1.20]- 11/30/2012
 0000000000000104 ffff88103fc43908 ffffffff8161b3c9 ffffffff81a14151
 ffff88103fc43958 ffff88103fc43948 ffffffff8104e6bc 0000000000000000
 ffffffff81a2cfae ffff88101b21cfd8 ffffffff81c37ba0 ffffffff828f2ca8
Call Trace:
 <IRQ>  [<ffffffff8161b3c9>] dump_stack+0x59/0x80
 [<ffffffff8104e6bc>] warn_slowpath_common+0x8c/0xc0
 [<ffffffff8104e7a6>] warn_slowpath_fmt+0x46/0x50
 [<ffffffff812b5aee>] debug_print_object+0x8e/0xb0
 [<ffffffffa04247f0>] ? br_multicast_free_pg+0x20/0x20 [bridge]
 [<ffffffff812b65e2>] ? __debug_object_init+0x42/0x3f0
 [<ffffffff812b67bf>] __debug_object_init+0x21f/0x3f0
 [<ffffffff810c2d1d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff812b69df>] debug_object_init+0x1f/0x30
 [<ffffffff81060ea9>] init_timer_key+0x39/0x100
 [<ffffffffa0425ec5>] br_ip4_multicast_query+0x155/0x380 [bridge]
 [<ffffffffa0427eef>] br_multicast_ipv4_rcv+0x2cf/0x3d0 [bridge]
 [<ffffffff8156d93e>] ? nf_hook_slow+0x16e/0x2a0
 [<ffffffffa04199a4>] ? br_fdb_update+0xe4/0x2b0 [bridge]
 [<ffffffffa04284b5>] br_multicast_rcv+0x45/0x60 [bridge]
 [<ffffffffa041bdfe>] br_handle_frame_finish+0x16e/0x3c0 [bridge]
 [<ffffffffa041bac8>] br_handle_frame+0x238/0x400 [bridge]
 [<ffffffffa041b890>] ? br_del_bridge+0x80/0x80 [bridge]
 [<ffffffff81539ca7>] __netif_receive_skb_core+0x237/0x960
 [<ffffffff81539ade>] ? __netif_receive_skb_core+0x6e/0x960
 [<ffffffff810c2d1d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8153a3f7>] __netif_receive_skb+0x27/0x70
 [<ffffffff8153c6fd>] netif_receive_skb+0x2d/0x210
 [<ffffffff81527e65>] ? __netdev_alloc_skb+0xa5/0x110
 [<ffffffffa0129a0f>] be_rx_compl_process+0xef/0x140 [be2net]
 [<ffffffffa0129dc2>] be_process_rx+0xe2/0x1a0 [be2net]
 [<ffffffffa0129fbd>] be_poll+0x13d/0x1d0 [be2net]
 [<ffffffff8153dab8>] net_rx_action+0xd8/0x2a0
 [<ffffffff81058e19>] __do_softirq+0x149/0x400
 [<ffffffff8105922d>] irq_exit+0xed/0x100
 [<ffffffff8162d206>] do_IRQ+0x66/0xe0
 [<ffffffff8162182f>] common_interrupt+0x6f/0x6f
 <EOI>  [<ffffffff814f148b>] ? cpuidle_enter_state+0x5b/0xe0
 [<ffffffff814f1487>] ? cpuidle_enter_state+0x57/0xe0
 [<ffffffff81625cd0>] ? notifier_call_chain+0x120/0x120
 [<ffffffff814f197f>] cpuidle_idle_call+0xcf/0x160
 [<ffffffff8100cf0e>] arch_cpu_idle+0xe/0x30
 [<ffffffff810b1291>] cpu_idle_loop+0x81/0x3a0
 [<ffffffff810b1620>] cpu_startup_entry+0x70/0x80
 [<ffffffff810334fc>] start_secondary+0xdc/0xe0
---[ end trace 68b46b9f74e14587 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 0 at lib/debugobjects.c:260 debug_print_object+0x8e/0xb0()
ODEBUG: init active (active state 0) object type: timer_list hint: br_multicast_group_expired+0x0/0x110 [bridge]
Modules linked in: ebtable_nat ebtables nfs fscache nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter ip_tables nfsd lockd nfs_acl exportfs auth_rpcgss autofs4 sunrpc 8021q garp bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 vfat fat vhost_net macvtap macvlan vhost tun kvm_intel kvm uinput iTCO_wdt iTCO_vendor_support cdc_ether usbnet mii microcode i2c_i801 i2c_core lpc_ich mfd_core shpchp mlx4_core ioatdma dca be2net wmi acpi_cpufreq mperf ext4 jbd2 mbcache dm_mirror dm_region_hash dm_log dm_mod
CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W    3.11.0-rc1-dbg-a #16
Hardware name: IBM  -[8737R2A]-/00Y2738, BIOS -[B2E120RUS-1.20]- 11/30/2012
 0000000000000104 ffff88103fc43908 ffffffff8161b3c9 ffffffff81a14151
 ffff88103fc43958 ffff88103fc43948 ffffffff8104e6bc 0000000000000000
 ffffffff81a2cfae ffff88101b21cfd8 ffffffff81c37ba0 ffffffff828f2ca8
Call Trace:
 <IRQ>  [<ffffffff8161b3c9>] dump_stack+0x59/0x80
 [<ffffffff8104e6bc>] warn_slowpath_common+0x8c/0xc0
 [<ffffffff8104e7a6>] warn_slowpath_fmt+0x46/0x50
 [<ffffffff812b5aee>] debug_print_object+0x8e/0xb0
 [<ffffffffa04247f0>] ? br_multicast_free_pg+0x20/0x20 [bridge]
 [<ffffffff812b65e2>] ? __debug_object_init+0x42/0x3f0
 [<ffffffff812b67bf>] __debug_object_init+0x21f/0x3f0
 [<ffffffff810c2d1d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff812b69df>] debug_object_init+0x1f/0x30
 [<ffffffff81060ea9>] init_timer_key+0x39/0x100
 [<ffffffffa0425ec5>] br_ip4_multicast_query+0x155/0x380 [bridge]
 [<ffffffffa0427eef>] br_multicast_ipv4_rcv+0x2cf/0x3d0 [bridge]
 [<ffffffff8156d93e>] ? nf_hook_slow+0x16e/0x2a0
 [<ffffffffa04199a4>] ? br_fdb_update+0xe4/0x2b0 [bridge]
 [<ffffffffa04284b5>] br_multicast_rcv+0x45/0x60 [bridge]
 [<ffffffffa041bdfe>] br_handle_frame_finish+0x16e/0x3c0 [bridge]
 [<ffffffffa041bac8>] br_handle_frame+0x238/0x400 [bridge]
 [<ffffffffa041b890>] ? br_del_bridge+0x80/0x80 [bridge]
 [<ffffffff81539ca7>] __netif_receive_skb_core+0x237/0x960
 [<ffffffff81539ade>] ? __netif_receive_skb_core+0x6e/0x960
 [<ffffffff8153a3f7>] __netif_receive_skb+0x27/0x70
 [<ffffffff8153c6fd>] netif_receive_skb+0x2d/0x210
 [<ffffffff81527e65>] ? __netdev_alloc_skb+0xa5/0x110
 [<ffffffffa0129a0f>] be_rx_compl_process+0xef/0x140 [be2net]
 [<ffffffffa0129dc2>] be_process_rx+0xe2/0x1a0 [be2net]
 [<ffffffffa0129fbd>] be_poll+0x13d/0x1d0 [be2net]
 [<ffffffff8153dab8>] net_rx_action+0xd8/0x2a0
 [<ffffffff81058e19>] __do_softirq+0x149/0x400
 [<ffffffff8105922d>] irq_exit+0xed/0x100
 [<ffffffff8162d206>] do_IRQ+0x66/0xe0
 [<ffffffff8162182f>] common_interrupt+0x6f/0x6f
 <EOI>  [<ffffffff814f148b>] ? cpuidle_enter_state+0x5b/0xe0
 [<ffffffff814f1487>] ? cpuidle_enter_state+0x57/0xe0
 [<ffffffff81625cd0>] ? notifier_call_chain+0x120/0x120
 [<ffffffff814f197f>] cpuidle_idle_call+0xcf/0x160
 [<ffffffff8100cf0e>] arch_cpu_idle+0xe/0x30
 [<ffffffff810b1291>] cpu_idle_loop+0x81/0x3a0
 [<ffffffff810b1620>] cpu_startup_entry+0x70/0x80
 [<ffffffff810334fc>] start_secondary+0xdc/0xe0
---[ end trace 68b46b9f74e14588 ]---
