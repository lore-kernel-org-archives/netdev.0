From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: unsafe locks seen with netperf on net-2.6.29 tree
Date: Thu, 25 Dec 2008 02:25:44 -0800
Message-ID: <9929d2390812250225w19bcd2f7n11357ff26de78c52@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Emil Tantilov" <emil.s.tantilov@intel.com>,
	"Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>,
	"Alexander Duyck" <alexander.h.duyck@intel.com>
To: netdev <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:61263 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbYLYKZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 05:25:46 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1114118yxm.1
        for <netdev@vger.kernel.org>; Thu, 25 Dec 2008 02:25:44 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When testing multiple drivers (igb and ixgbe) using netperf
UDP/TCP/_RR ipv4/6 multiple threads, we are seeing unsafe locks
messages. In testing we have the locking checks enabled in the kernel
hacking option.  The unsafe condition points to the netperf process
and this only started occurring recently on Dave's net-next-2.6 tree.

Any insight would be great.

--- cut here ---

[  975.131762] calling  igb_init_module+0x0/0x72 [igb] @ 19212
[  975.131914] Intel(R) Gigabit Ethernet Network Driver - version 1.2.45-k2
[  975.131917] Copyright (c) 2008 Intel Corporation.
[  975.132004] igb 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[  975.132045] igb 0000:01:00.0: setting latency timer to 64
[  975.142963] igb 0000:01:00.0: irq 1279 for MSI/MSI-X
[  975.142972] igb 0000:01:00.0: irq 1278 for MSI/MSI-X
[  975.142978] igb 0000:01:00.0: irq 1277 for MSI/MSI-X
[  975.142984] igb 0000:01:00.0: irq 1276 for MSI/MSI-X
[  975.142989] igb 0000:01:00.0: irq 1275 for MSI/MSI-X
[  975.142995] igb 0000:01:00.0: irq 1274 for MSI/MSI-X
[  975.143001] igb 0000:01:00.0: irq 1273 for MSI/MSI-X
[  975.143006] igb 0000:01:00.0: irq 1272 for MSI/MSI-X
[  975.143012] igb 0000:01:00.0: irq 1271 for MSI/MSI-X
[  975.250556] igb 0000:01:00.0: Intel(R) Gigabit Ethernet Network Connection
[  975.250565] igb 0000:01:00.0: eth0: (PCIe:2.5Gb/s:Width x4) 00:1b:21:2a:8c:4c
[  975.250645] igb 0000:01:00.0: eth0: PBA No: e19418-006
[  975.250650] igb 0000:01:00.0: Using MSI-X interrupts. 4 rx
queue(s), 4 tx queue(s)
[  975.250716] igb 0000:01:00.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[  975.250768] igb 0000:01:00.1: setting latency timer to 64
[  975.251242] igb 0000:01:00.1: irq 1270 for MSI/MSI-X
[  975.251256] igb 0000:01:00.1: irq 1269 for MSI/MSI-X
[  975.251267] igb 0000:01:00.1: irq 1268 for MSI/MSI-X
[  975.251278] igb 0000:01:00.1: irq 1267 for MSI/MSI-X
[  975.251289] igb 0000:01:00.1: irq 1266 for MSI/MSI-X
[  975.251300] igb 0000:01:00.1: irq 1265 for MSI/MSI-X
[  975.251310] igb 0000:01:00.1: irq 1264 for MSI/MSI-X
[  975.251320] igb 0000:01:00.1: irq 1263 for MSI/MSI-X
[  975.251330] igb 0000:01:00.1: irq 1262 for MSI/MSI-X
[  975.367412] igb 0000:01:00.1: Intel(R) Gigabit Ethernet Network Connection
[  975.367418] igb 0000:01:00.1: eth1: (PCIe:2.5Gb/s:Width x4) 00:1b:21:2a:8c:4d
[  975.367493] igb 0000:01:00.1: eth1: PBA No: e19418-006
[  975.367497] igb 0000:01:00.1: Using MSI-X interrupts. 4 rx
queue(s), 4 tx queue(s)
[  975.367629] initcall igb_init_module+0x0/0x72 [igb] returned 0
after 230178 usecs
[  980.600660] igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[  980.600886] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  980.603009] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  980.793018] ADDRCONF(NETDEV_UP): eth1: link is not ready
[  990.700023] eth0: no IPv6 routers present
[ 1439.758435]
[ 1439.758437] ======================================================
[ 1439.758724] [ INFO: soft-safe -> soft-unsafe lock order detected ]
[ 1439.758868] 2.6.28-rc8-net-next-igb #13
[ 1439.759007] ------------------------------------------------------
[ 1439.759150] netperf/22302 [HC0[0]:SC0[1]:HE1:SE0] is trying to acquire:
[ 1439.759293]  (&fbc->lock){--..}, at: [<ffffffff803691a6>]
__percpu_counter_add+0x4a/0x6d
[ 1439.759581]
[ 1439.759582] and this task is already holding:
[ 1439.759853]  (slock-AF_INET){-+..}, at: [<ffffffff804fdca6>]
tcp_close+0x16c/0x2da
[ 1439.760137] which would create a new lock dependency:
[ 1439.762122]  (slock-AF_INET){-+..} -> (&fbc->lock){--..}
[ 1439.762122]
[ 1439.762122] but this new dependency connects a soft-irq-safe lock:
[ 1439.762122]  (slock-AF_INET){-+..}
[ 1439.762122] ... which became soft-irq-safe at:
[ 1439.762122]   [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122] to a soft-irq-unsafe lock:
[ 1439.762122]  (&fbc->lock){--..}
[ 1439.762122] ... which became soft-irq-unsafe at:
[ 1439.762122] ...  [<ffffffff80260480>] mark_irqflags+0xda/0xf2
[ 1439.762122]   [<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
[ 1439.762122]   [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]   [<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]   [<ffffffff803691a6>] __percpu_counter_add+0x4a/0x6d
[ 1439.762122]   [<ffffffff802a3168>] percpu_counter_add+0xe/0x10
[ 1439.762122]   [<ffffffff802a31db>] percpu_counter_inc+0xe/0x10
[ 1439.762122]   [<ffffffff802a364c>] get_empty_filp+0x75/0x117
[ 1439.762122]   [<ffffffff802acb19>] path_lookup_open+0x2b/0x9b
[ 1439.762122]   [<ffffffff802acf12>] do_filp_open+0xae/0x6b8
[ 1439.762122]   [<ffffffff802a0b2f>] do_sys_open+0x4f/0x99
[ 1439.762122]   [<ffffffff802a0ba2>] sys_open+0x1b/0x1d
[ 1439.762122]   [<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]   [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122] other info that might help us debug this:
[ 1439.762122]
[ 1439.762122] 1 lock held by netperf/22302:
[ 1439.762122]  #0:  (slock-AF_INET){-+..}, at: [<ffffffff804fdca6>]
tcp_close+0x16c/0x2da
[ 1439.762122]
[ 1439.762122] the soft-irq-safe lock's dependencies:
[ 1439.762122] -> (slock-AF_INET){-+..} ops: 0 {
[ 1439.762122]    initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564481>] _spin_lock_bh+0x31/0x3d
[ 1439.762122]
[<ffffffff804cb420>] lock_sock_nested+0x30/0x7f
[ 1439.762122]
[<ffffffff804fc544>] lock_sock+0xb/0xd
[ 1439.762122]
[<ffffffff804fdb54>] tcp_close+0x1a/0x2da
[ 1439.762122]
[<ffffffff80519082>] inet_release+0x58/0x5f
[ 1439.762122]
[<ffffffff804c9354>] sock_release+0x1a/0x76
[ 1439.762122]
[<ffffffff804c9804>] sock_close+0x22/0x26
[ 1439.762122]
[<ffffffff802a345e>] __fput+0x82/0x110
[ 1439.762122]
[<ffffffff802a381e>] fput+0x15/0x17
[ 1439.762122]
[<ffffffff802a09c9>] filp_close+0x67/0x72
[ 1439.762122]
[<ffffffff802a0a4f>] sys_close+0x7b/0xbe
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]    in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]    hardirq-on-W at:
[ 1439.762122]
[<ffffffff80260463>] mark_irqflags+0xbd/0xf2
[ 1439.762122]
[<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564481>] _spin_lock_bh+0x31/0x3d
[ 1439.762122]
[<ffffffff804cb420>] lock_sock_nested+0x30/0x7f
[ 1439.762122]
[<ffffffff804fc544>] lock_sock+0xb/0xd
[ 1439.762122]
[<ffffffff804fdb54>] tcp_close+0x1a/0x2da
[ 1439.762122]
[<ffffffff80519082>] inet_release+0x58/0x5f
[ 1439.762122]
[<ffffffff804c9354>] sock_release+0x1a/0x76
[ 1439.762122]
[<ffffffff804c9804>] sock_close+0x22/0x26
[ 1439.762122]
[<ffffffff802a345e>] __fput+0x82/0x110
[ 1439.762122]
[<ffffffff802a381e>] fput+0x15/0x17
[ 1439.762122]
[<ffffffff802a09c9>] filp_close+0x67/0x72
[ 1439.762122]
[<ffffffff802a0a4f>] sys_close+0x7b/0xbe
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]  }
[ 1439.762122]  ... key      at: [<ffffffff80eae530>]
af_family_slock_keys+0x10/0x120
[ 1439.762122]  -> (&list->lock){-+..} ops: 0 {
[ 1439.762122]     initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564502>] _spin_lock_irqsave+0x37/0x49
[ 1439.762122]
[<ffffffff804cec52>] skb_queue_tail+0x1d/0x3f
[ 1439.762122]
[<ffffffff804ea247>] netlink_broadcast_deliver+0x44/0x6b
[ 1439.762122]
[<ffffffff804eb073>] do_one_broadcast+0xcc/0xfb
[ 1439.762122]
[<ffffffff804eb1b7>] netlink_broadcast+0x94/0xec
[ 1439.762122]
[<ffffffff8035e56b>] kobject_uevent_env+0x2c3/0x369
[ 1439.762122]
[<ffffffff8035e61c>] kobject_uevent+0xb/0xd
[ 1439.762122]
[<ffffffff803d11de>] device_del+0x15d/0x175
[ 1439.762122]
[<ffffffff803d1207>] device_unregister+0x11/0x1d
[ 1439.762122]
[<ffffffff803d1249>] device_destroy+0x36/0x3a
[ 1439.762122]
[<ffffffff803b739d>] vcs_remove_sysfs+0x23/0x42
[ 1439.762122]
[<ffffffff803bd227>] con_shutdown+0x33/0x45
[ 1439.762122]
[<ffffffff803af322>] release_one_tty+0x21/0x8c
[ 1439.762122]
[<ffffffff8035e6f6>] kref_put+0x43/0x4f
[ 1439.762122]
[<ffffffff803ace6f>] tty_kref_put+0x19/0x1b
[ 1439.762122]
[<ffffffff803ad0a0>] release_tty+0x3b/0x3f
[ 1439.762122]
[<ffffffff803af28e>] tty_release_dev+0x443/0x464
[ 1439.762122]
[<ffffffff803af2c8>] tty_release+0x19/0x25
[ 1439.762122]
[<ffffffff802a345e>] __fput+0x82/0x110
[ 1439.762122]
[<ffffffff802a381e>] fput+0x15/0x17
[ 1439.762122]
[<ffffffff802a09c9>] filp_close+0x67/0x72
[ 1439.762122]
[<ffffffff802a0a4f>] sys_close+0x7b/0xbe
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     hardirq-on-W at:
[ 1439.762122]
[<ffffffff80260463>] mark_irqflags+0xbd/0xf2
[ 1439.762122]
[<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564481>] _spin_lock_bh+0x31/0x3d
[ 1439.762122]
[<ffffffff80513515>] udp_poll+0x60/0xe7
[ 1439.762122]
[<ffffffff804c7f1b>] sock_poll+0x18/0x1a
[ 1439.762122]
[<ffffffff802af335>] do_pollfd+0x4a/0x7c
[ 1439.762122]
[<ffffffff802af40d>] do_poll+0xa6/0x178
[ 1439.762122]
[<ffffffff802af7ba>] do_sys_poll+0x13b/0x1ae
[ 1439.762122]
[<ffffffff802af87f>] sys_poll+0x52/0xb3
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]   }
[ 1439.762122]   ... key      at: [<ffffffff80eae3b0>] __key.23956+0x0/0x8
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  -> (&q->lock){++..} ops: 0 {
[ 1439.762122]     initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff805644bf>] _spin_lock_irq+0x32/0x3e
[ 1439.762122]
[<ffffffff80562e1f>] wait_for_common+0x30/0x54
[ 1439.762122]
[<ffffffff80562ecd>] wait_for_completion+0x18/0x1a
[ 1439.762122]
[<ffffffff80252a90>] kthread_create+0xe3/0x154
[ 1439.762122]
[<ffffffff80560db0>] migration_call+0x44/0x343
[ 1439.762122]
[<ffffffff807fa0d4>] migration_init+0x25/0x5b
[ 1439.762122]
[<ffffffff80209191>] do_one_initcall+0x58/0x138
[ 1439.762122]
[<ffffffff807e64e6>] do_pre_smp_initcalls+0x1e/0x2b
[ 1439.762122]
[<ffffffff807e6a2b>] kernel_init+0x57/0xa7
[ 1439.762122]
[<ffffffff8020cae9>] child_rip+0xa/0x11
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-hardirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]   }
[ 1439.762122]   ... key      at: [<ffffffff808a7998>] __key.15533+0x0/0x8
[ 1439.762122]   -> (&rq->lock){++..} ops: 0 {
[ 1439.762122]      initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564502>] _spin_lock_irqsave+0x37/0x49
[ 1439.762122]
[<ffffffff802328cf>] rq_attach_root+0x16/0xb2
[ 1439.762122]
[<ffffffff807fa472>] sched_init+0x2ad/0x364
[ 1439.762122]
[<ffffffff807e6b24>] start_kernel+0x76/0x281
[ 1439.762122]
[<ffffffff807e62c8>] x86_64_start_reservations+0x7c/0x80
[ 1439.762122]
[<ffffffff807e6375>] x86_64_start_kernel+0x6a/0x72
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]      in-hardirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]      in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]    }
[ 1439.762122]    ... key      at: [<ffffffff808629f0>] __key.42413+0x0/0x8
[ 1439.762122]    -> (&vec->lock){.+..} ops: 0 {
[ 1439.762122]       initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564502>] _spin_lock_irqsave+0x37/0x49
[ 1439.762122]
[<ffffffff8027664a>] cpupri_set+0xae/0xf9
[ 1439.762122]
[<ffffffff802358e6>] rq_online_rt+0x3e/0x43
[ 1439.762122]
[<ffffffff80231aa4>] set_rq_online+0x49/0x57
[ 1439.762122]
[<ffffffff80232957>] rq_attach_root+0x9e/0xb2
[ 1439.762122]
[<ffffffff807fa472>] sched_init+0x2ad/0x364
[ 1439.762122]
[<ffffffff807e6b24>] start_kernel+0x76/0x281
[ 1439.762122]
[<ffffffff807e62c8>] x86_64_start_reservations+0x7c/0x80
[ 1439.762122]
[<ffffffff807e6375>] x86_64_start_kernel+0x6a/0x72
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]       in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     }
[ 1439.762122]     ... key      at: [<ffffffff80e96bb0>] __key.12617+0x0/0x10
[ 1439.762122]    ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564502>] _spin_lock_irqsave+0x37/0x49
[ 1439.762122]    [<ffffffff8027664a>] cpupri_set+0xae/0xf9
[ 1439.762122]    [<ffffffff802358e6>] rq_online_rt+0x3e/0x43
[ 1439.762122]    [<ffffffff80231aa4>] set_rq_online+0x49/0x57
[ 1439.762122]    [<ffffffff80232957>] rq_attach_root+0x9e/0xb2
[ 1439.762122]    [<ffffffff807fa472>] sched_init+0x2ad/0x364
[ 1439.762122]    [<ffffffff807e6b24>] start_kernel+0x76/0x281
[ 1439.762122]    [<ffffffff807e62c8>] x86_64_start_reservations+0x7c/0x80
[ 1439.762122]    [<ffffffff807e6375>] x86_64_start_kernel+0x6a/0x72
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]    -> (&rt_b->rt_runtime_lock){.+..} ops: 0 {
[ 1439.762122]       initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]
[<ffffffff80235aa8>] start_rt_bandwidth+0x2e/0x66
[ 1439.762122]
[<ffffffff80235b79>] inc_rt_tasks+0x99/0x9e
[ 1439.762122]
[<ffffffff80235bc5>] __enqueue_rt_entity+0x47/0x4b
[ 1439.762122]
[<ffffffff80235c29>] enqueue_rt_entity+0x1e/0x22
[ 1439.762122]
[<ffffffff80235c52>] enqueue_task_rt+0x25/0x3e
[ 1439.762122]
[<ffffffff80230317>] enqueue_task+0x13/0x1e
[ 1439.762122]
[<ffffffff802303a6>] activate_task+0x22/0x2a
[ 1439.762122]
[<ffffffff80236e47>] try_to_wake_up+0x11d/0x190
[ 1439.762122]
[<ffffffff80236ee6>] wake_up_process+0x10/0x12
[ 1439.762122]
[<ffffffff80560e59>] migration_call+0xed/0x343
[ 1439.762122]
[<ffffffff807fa0f6>] migration_init+0x47/0x5b
[ 1439.762122]
[<ffffffff80209191>] do_one_initcall+0x58/0x138
[ 1439.762122]
[<ffffffff807e64e6>] do_pre_smp_initcalls+0x1e/0x2b
[ 1439.762122]
[<ffffffff807e6a2b>] kernel_init+0x57/0xa7
[ 1439.762122]
[<ffffffff8020cae9>] child_rip+0xa/0x11
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]       in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     }
[ 1439.762122]     ... key      at: [<ffffffff808629f8>] __key.34299+0x0/0x8
[ 1439.762122]     -> (&cpu_base->lock){++..} ops: 0 {
[ 1439.762122]        initial-use  at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]        in-hardirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]        in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]      }
[ 1439.762122]      ... key      at: [<ffffffff808a79d0>] __key.18493+0x0/0x8
[ 1439.762122]     ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564502>] _spin_lock_irqsave+0x37/0x49
[ 1439.762122]    [<ffffffff8025600f>] lock_hrtimer_base+0x25/0x4b
[ 1439.762122]    [<ffffffff80256100>] hrtimer_start_range_ns+0x26/0xbc
[ 1439.762122]    [<ffffffff80232fd6>] hrtimer_start_expires+0x18/0x1a
[ 1439.762122]    [<ffffffff80235ad1>] start_rt_bandwidth+0x57/0x66
[ 1439.762122]    [<ffffffff80235b79>] inc_rt_tasks+0x99/0x9e
[ 1439.762122]    [<ffffffff80235bc5>] __enqueue_rt_entity+0x47/0x4b
[ 1439.762122]    [<ffffffff80235c29>] enqueue_rt_entity+0x1e/0x22
[ 1439.762122]    [<ffffffff80235c52>] enqueue_task_rt+0x25/0x3e
[ 1439.762122]    [<ffffffff80230317>] enqueue_task+0x13/0x1e
[ 1439.762122]    [<ffffffff802303a6>] activate_task+0x22/0x2a
[ 1439.762122]    [<ffffffff80236e47>] try_to_wake_up+0x11d/0x190
[ 1439.762122]    [<ffffffff80236ee6>] wake_up_process+0x10/0x12
[ 1439.762122]    [<ffffffff80560e59>] migration_call+0xed/0x343
[ 1439.762122]    [<ffffffff807fa0f6>] migration_init+0x47/0x5b
[ 1439.762122]    [<ffffffff80209191>] do_one_initcall+0x58/0x138
[ 1439.762122]    [<ffffffff807e64e6>] do_pre_smp_initcalls+0x1e/0x2b
[ 1439.762122]    [<ffffffff807e6a2b>] kernel_init+0x57/0xa7
[ 1439.762122]    [<ffffffff8020cae9>] child_rip+0xa/0x11
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]     -> (&rt_rq->rt_runtime_lock){++..} ops: 0 {
[ 1439.762122]        initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]
[<ffffffff8023558e>] update_curr_rt+0x8b/0xc1
[ 1439.762122]
[<ffffffff80235be6>] dequeue_task_rt+0x12/0x37
[ 1439.762122]
[<ffffffff80230379>] dequeue_task+0x57/0x62
[ 1439.762122]
[<ffffffff802303d0>] deactivate_task+0x22/0x2a
[ 1439.762122]
[<ffffffff80562f91>] schedule+0xc2/0x19e
[ 1439.762122]
[<ffffffff8023a568>] migration_thread+0xad/0x152
[ 1439.762122]
[<ffffffff80252c40>] kthread+0x49/0x79
[ 1439.762122]
[<ffffffff8020cae9>] child_rip+0xa/0x11
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]        in-hardirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]        in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]      }
[ 1439.762122]      ... key      at: [<ffffffff80862a00>] __key.42365+0x0/0x8
[ 1439.762122]     ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]    [<ffffffff80233fc2>] __enable_runtime+0x3a/0x7a
[ 1439.762122]    [<ffffffff802358ca>] rq_online_rt+0x22/0x43
[ 1439.762122]    [<ffffffff80231aa4>] set_rq_online+0x49/0x57
[ 1439.762122]    [<ffffffff80560e9d>] migration_call+0x131/0x343
[ 1439.762122]    [<ffffffff80566de8>] notifier_call_chain+0x33/0x5b
[ 1439.762122]    [<ffffffff802570d7>] __raw_notifier_call_chain+0x9/0xb
[ 1439.762122]    [<ffffffff802570e8>] raw_notifier_call_chain+0xf/0x11
[ 1439.762122]    [<ffffffff805612b8>] _cpu_up+0xd8/0x111
[ 1439.762122]    [<ffffffff80561373>] cpu_up+0x57/0x67
[ 1439.762122]    [<ffffffff807e6658>] smp_init+0x4f/0x95
[ 1439.762122]    [<ffffffff807e6a30>] kernel_init+0x5c/0xa7
[ 1439.762122]    [<ffffffff8020cae9>] child_rip+0xa/0x11
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]    ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]    [<ffffffff80235aa8>] start_rt_bandwidth+0x2e/0x66
[ 1439.762122]    [<ffffffff80235b79>] inc_rt_tasks+0x99/0x9e
[ 1439.762122]    [<ffffffff80235bc5>] __enqueue_rt_entity+0x47/0x4b
[ 1439.762122]    [<ffffffff80235c29>] enqueue_rt_entity+0x1e/0x22
[ 1439.762122]    [<ffffffff80235c52>] enqueue_task_rt+0x25/0x3e
[ 1439.762122]    [<ffffffff80230317>] enqueue_task+0x13/0x1e
[ 1439.762122]    [<ffffffff802303a6>] activate_task+0x22/0x2a
[ 1439.762122]    [<ffffffff80236e47>] try_to_wake_up+0x11d/0x190
[ 1439.762122]    [<ffffffff80236ee6>] wake_up_process+0x10/0x12
[ 1439.762122]    [<ffffffff80560e59>] migration_call+0xed/0x343
[ 1439.762122]    [<ffffffff807fa0f6>] migration_init+0x47/0x5b
[ 1439.762122]    [<ffffffff80209191>] do_one_initcall+0x58/0x138
[ 1439.762122]    [<ffffffff807e64e6>] do_pre_smp_initcalls+0x1e/0x2b
[ 1439.762122]    [<ffffffff807e6a2b>] kernel_init+0x57/0xa7
[ 1439.762122]    [<ffffffff8020cae9>] child_rip+0xa/0x11
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]    ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]    [<ffffffff8023558e>] update_curr_rt+0x8b/0xc1
[ 1439.762122]    [<ffffffff80235be6>] dequeue_task_rt+0x12/0x37
[ 1439.762122]    [<ffffffff80230379>] dequeue_task+0x57/0x62
[ 1439.762122]    [<ffffffff802303d0>] deactivate_task+0x22/0x2a
[ 1439.762122]    [<ffffffff80562f91>] schedule+0xc2/0x19e
[ 1439.762122]    [<ffffffff8023a568>] migration_thread+0xad/0x152
[ 1439.762122]    [<ffffffff80252c40>] kthread+0x49/0x79
[ 1439.762122]    [<ffffffff8020cae9>] child_rip+0xa/0x11
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]    -> (&rq->lock/1){.+..} ops: 0 {
[ 1439.762122]       initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff8056440c>] _spin_lock_nested+0x2a/0x36
[ 1439.762122]
[<ffffffff80235fee>] double_rq_lock+0x4d/0x62
[ 1439.762122]
[<ffffffff80236103>] __migrate_task+0x65/0xed
[ 1439.762122]
[<ffffffff8023a5ae>] migration_thread+0xf3/0x152
[ 1439.762122]
[<ffffffff80252c40>] kthread+0x49/0x79
[ 1439.762122]
[<ffffffff8020cae9>] child_rip+0xa/0x11
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]       in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     }
[ 1439.762122]     ... key      at: [<ffffffff808629f1>] __key.42413+0x1/0x8
[ 1439.762122]    ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff8056440c>] _spin_lock_nested+0x2a/0x36
[ 1439.762122]    [<ffffffff80235fee>] double_rq_lock+0x4d/0x62
[ 1439.762122]    [<ffffffff80236103>] __migrate_task+0x65/0xed
[ 1439.762122]    [<ffffffff8023a5ae>] migration_thread+0xf3/0x152
[ 1439.762122]    [<ffffffff80252c40>] kthread+0x49/0x79
[ 1439.762122]    [<ffffffff8020cae9>] child_rip+0xa/0x11
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]   ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]    [<ffffffff80232c24>] task_rq_lock+0x45/0x7a
[ 1439.762122]    [<ffffffff80236db6>] try_to_wake_up+0x8c/0x190
[ 1439.762122]    [<ffffffff80236ec7>] default_wake_function+0xd/0xf
[ 1439.762122]    [<ffffffff8023084a>] __wake_up_common+0x41/0x75
[ 1439.762122]    [<ffffffff802329ef>] complete+0x38/0x4c
[ 1439.762122]    [<ffffffff80252c1e>] kthread+0x27/0x79
[ 1439.762122]    [<ffffffff8020cae9>] child_rip+0xa/0x11
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]   -> (&ep->lock){....} ops: 0 {
[ 1439.762122]      initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564502>] _spin_lock_irqsave+0x37/0x49
[ 1439.762122]
[<ffffffff802cb47f>] ep_insert+0x132/0x231
[ 1439.762122]
[<ffffffff802cb677>] sys_epoll_ctl+0xf9/0x15f
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]    }
[ 1439.762122]    ... key      at: [<ffffffff80e99bd0>] __key.20932+0x0/0x10
[ 1439.762122]   ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564502>] _spin_lock_irqsave+0x37/0x49
[ 1439.762122]    [<ffffffff802cb9bf>] ep_poll_callback+0x1d/0xe1
[ 1439.762122]    [<ffffffff8023084a>] __wake_up_common+0x41/0x75
[ 1439.762122]    [<ffffffff80232a3d>] __wake_up_sync+0x3a/0x4e
[ 1439.762122]    [<ffffffff804cca48>] sock_def_readable+0x3e/0x5d
[ 1439.762122]    [<ffffffff8052601d>] unix_stream_sendmsg+0x1e3/0x2a4
[ 1439.762122]    [<ffffffff804c7d98>] __sock_sendmsg+0x28/0x2a
[ 1439.762122]    [<ffffffff804c7eff>] do_sock_write+0x7f/0x83
[ 1439.762122]    [<ffffffff804c830a>] sock_aio_write+0x53/0x67
[ 1439.762122]    [<ffffffff802a23b6>] do_sync_write+0xe2/0x126
[ 1439.762122]    [<ffffffff802a2ad8>] vfs_write+0xba/0xe1
[ 1439.762122]    [<ffffffff802a2bb9>] sys_write+0x47/0x6c
[ 1439.762122]    [<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  -> (&list->lock#2){-+..} ops: 0 {
[ 1439.762122]     initial-use  at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     hardirq-on-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]   }
[ 1439.762122]   ... key      at: [<ffffffff80eaf634>] __key.19759+0x0/0xc
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  -> (&hashinfo->ehash_locks[i]){-+..} ops: 0 {
[ 1439.762122]     initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]
[<ffffffff804f93a9>] __inet_hash_nolisten+0x62/0x93
[ 1439.762122]
[<ffffffff804f975b>] __inet_hash_connect+0x1a3/0x253
[ 1439.762122]
[<ffffffff804f983b>] inet_hash_connect+0x30/0x35
[ 1439.762122]
[<ffffffff8050d083>] tcp_v4_connect+0x244/0x333
[ 1439.762122]
[<ffffffff80518ade>] inet_stream_connect+0x9a/0x183
[ 1439.762122]
[<ffffffff804c89ba>] sys_connect+0x68/0x8b
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     hardirq-on-W at:
[ 1439.762122]
[<ffffffff80260463>] mark_irqflags+0xbd/0xf2
[ 1439.762122]
[<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]
[<ffffffff804f93a9>] __inet_hash_nolisten+0x62/0x93
[ 1439.762122]
[<ffffffff804f975b>] __inet_hash_connect+0x1a3/0x253
[ 1439.762122]
[<ffffffff804f983b>] inet_hash_connect+0x30/0x35
[ 1439.762122]
[<ffffffff8050d083>] tcp_v4_connect+0x244/0x333
[ 1439.762122]
[<ffffffff80518ade>] inet_stream_connect+0x9a/0x183
[ 1439.762122]
[<ffffffff804c89ba>] sys_connect+0x68/0x8b
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]   }
[ 1439.762122]   ... key      at: [<ffffffff80eb03f8>] __key.35382+0x0/0x8
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  -> (&tcp_hashinfo.bhash[i].lock){-+..} ops: 0 {
[ 1439.762122]     initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]
[<ffffffff804fb6d2>] inet_csk_get_port+0xdc/0x1f3
[ 1439.762122]
[<ffffffff80519456>] inet_bind+0x110/0x1a5
[ 1439.762122]
[<ffffffff804c8a9c>] sys_bind+0x60/0x83
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     hardirq-on-W at:
[ 1439.762122]
[<ffffffff80260463>] mark_irqflags+0xbd/0xf2
[ 1439.762122]
[<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]
[<ffffffff804fb6d2>] inet_csk_get_port+0xdc/0x1f3
[ 1439.762122]
[<ffffffff80519456>] inet_bind+0x110/0x1a5
[ 1439.762122]
[<ffffffff804c8a9c>] sys_bind+0x60/0x83
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]   }
[ 1439.762122]   ... key      at: [<ffffffff80eb03f0>] __key.42004+0x0/0x8
[ 1439.762122]   -> (&parent->list_lock){++..} ops: 0 {
[ 1439.762122]      initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]
[<ffffffff8029f21d>] cache_alloc_refill+0x6d/0x216
[ 1439.762122]
[<ffffffff8029f41a>] ____cache_alloc+0x54/0x59
[ 1439.762122]
[<ffffffff8029f591>] kmem_cache_alloc+0x33/0x8b
[ 1439.762122]
[<ffffffff8029f5f8>] kmem_cache_zalloc+0xf/0x11
[ 1439.762122]
[<ffffffff802a020c>] kmem_cache_create+0x237/0x465
[ 1439.762122]
[<ffffffff807fe580>] kmem_cache_init+0x1ae/0x403
[ 1439.762122]
[<ffffffff807e6cb5>] start_kernel+0x207/0x281
[ 1439.762122]
[<ffffffff807e62c8>] x86_64_start_reservations+0x7c/0x80
[ 1439.762122]
[<ffffffff807e6375>] x86_64_start_kernel+0x6a/0x72
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]      in-hardirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]      in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]    }
[ 1439.762122]    ... key      at: [<ffffffff80e98e40>] __key.22137+0x0/0x8
[ 1439.762122]    -> (&zone->lock){.+..} ops: 0 {
[ 1439.762122]       initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]
[<ffffffff8027bd89>] free_pages_bulk+0x2c/0x96
[ 1439.762122]
[<ffffffff8027c206>] free_hot_cold_page+0x105/0x131
[ 1439.762122]
[<ffffffff8027c286>] free_hot_page+0xb/0xd
[ 1439.762122]
[<ffffffff8027c375>] __free_pages+0x18/0x21
[ 1439.762122]
[<ffffffff80811afb>] __free_pages_bootmem+0x56/0x58
[ 1439.762122]
[<ffffffff807fc8da>] free_all_bootmem_core+0xf2/0x1c2
[ 1439.762122]
[<ffffffff807fc9ba>] free_all_bootmem+0x10/0x12
[ 1439.762122]
[<ffffffff807f8e78>] mem_init+0x37/0x161
[ 1439.762122]
[<ffffffff807e6cab>] start_kernel+0x1fd/0x281
[ 1439.762122]
[<ffffffff807e62c8>] x86_64_start_reservations+0x7c/0x80
[ 1439.762122]
[<ffffffff807e6375>] x86_64_start_kernel+0x6a/0x72
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]       in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     }
[ 1439.762122]     ... key      at: [<ffffffff80e96c0c>] __key.28439+0x0/0x8
[ 1439.762122]    ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]    -> (&on_slab_l3_key){++..} ops: 0 {
[ 1439.762122]       initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]
[<ffffffff8029f21d>] cache_alloc_refill+0x6d/0x216
[ 1439.762122]
[<ffffffff8029f41a>] ____cache_alloc+0x54/0x59
[ 1439.762122]
[<ffffffff8029f466>] __kmalloc+0x47/0xa0
[ 1439.762122]
[<ffffffff8029f686>] kmalloc+0x9/0xb
[ 1439.762122]
[<ffffffff8029f6a2>] kmalloc_node+0x9/0xb
[ 1439.762122]
[<ffffffff8029f79e>] alloc_arraycache+0x2c/0x6c
[ 1439.762122]
[<ffffffff8029f9a2>] do_tune_cpucache+0x4c/0x151
[ 1439.762122]
[<ffffffff8029fc64>] enable_cpucache+0x68/0xb2
[ 1439.762122]
[<ffffffff8055140d>] setup_cpu_cache+0x1e/0x15e
[ 1439.762122]
[<ffffffff802a03a4>] kmem_cache_create+0x3cf/0x465
[ 1439.762122]
[<ffffffff80800564>] idr_init_cache+0x23/0x2c
[ 1439.762122]
[<ffffffff807e6cba>] start_kernel+0x20c/0x281
[ 1439.762122]
[<ffffffff807e62c8>] x86_64_start_reservations+0x7c/0x80
[ 1439.762122]
[<ffffffff807e6375>] x86_64_start_kernel+0x6a/0x72
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]       in-hardirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]       in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     }
[ 1439.762122]     ... key      at: [<ffffffff80e98e64>] on_slab_l3_key+0x0/0x8
[ 1439.762122]     ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]    [<ffffffff8027bd29>] free_one_page+0x23/0x57
[ 1439.762122]    [<ffffffff8027c33b>] __free_pages_ok+0xb3/0xd5
[ 1439.762122]    [<ffffffff8027c37c>] __free_pages+0x1f/0x21
[ 1439.762122]    [<ffffffff8027c3b0>] free_pages+0x32/0x37
[ 1439.762122]    [<ffffffff8029df15>] kmem_freepages+0xcd/0xda
[ 1439.762122]    [<ffffffff8029eb26>] slab_destroy+0x4e/0x6f
[ 1439.762122]    [<ffffffff8029ec16>] free_block+0xcf/0x122
[ 1439.762122]    [<ffffffff8029e8c7>] cache_flusharray+0x83/0xec
[ 1439.762122]    [<ffffffff8029e991>] __cache_free+0x61/0x7b
[ 1439.762122]    [<ffffffff8029e9f7>] kfree+0x4c/0x70
[ 1439.762122]    [<ffffffff804cf335>] skb_release_data+0xa8/0xad
[ 1439.762122]    [<ffffffff804cfa1c>] skb_release_all+0x19/0x1d
[ 1439.762122]    [<ffffffff804cf1c9>] __kfree_skb+0x11/0x1e
[ 1439.762122]    [<ffffffff804cf1fd>] kfree_skb+0x27/0x29
[ 1439.762122]    [<ffffffff804d1b2d>] skb_free_datagram+0x14/0x20
[ 1439.762122]    [<ffffffff804ec492>] netlink_recvmsg+0x13e/0x1a4
[ 1439.762122]    [<ffffffff804c7dc6>] __sock_recvmsg+0x2c/0x2e
[ 1439.762122]    [<ffffffff804c8e2a>] sock_recvmsg+0xca/0xe3
[ 1439.762122]    [<ffffffff804c9c11>] sys_recvfrom+0xa4/0xf2
[ 1439.762122]    [<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]    ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]    [<ffffffff8029e882>] cache_flusharray+0x3e/0xec
[ 1439.762122]    [<ffffffff8029e991>] __cache_free+0x61/0x7b
[ 1439.762122]    [<ffffffff8029ea52>] kmem_cache_free+0x37/0x5b
[ 1439.762122]    [<ffffffff8029eb3f>] slab_destroy+0x67/0x6f
[ 1439.762122]    [<ffffffff8029ec16>] free_block+0xcf/0x122
[ 1439.762122]    [<ffffffff8029e8c7>] cache_flusharray+0x83/0xec
[ 1439.762122]    [<ffffffff8029e991>] __cache_free+0x61/0x7b
[ 1439.762122]    [<ffffffff8029e9f7>] kfree+0x4c/0x70
[ 1439.762122]    [<ffffffff804cf335>] skb_release_data+0xa8/0xad
[ 1439.762122]    [<ffffffff804cfa1c>] skb_release_all+0x19/0x1d
[ 1439.762122]    [<ffffffff804cf1c9>] __kfree_skb+0x11/0x1e
[ 1439.762122]    [<ffffffff804fc64e>] sk_eat_skb+0x30/0x49
[ 1439.762122]    [<ffffffff804ff339>] tcp_recvmsg+0x644/0x83b
[ 1439.762122]    [<ffffffff804ca628>] sock_common_recvmsg+0x32/0x47
[ 1439.762122]    [<ffffffff804c7dc6>] __sock_recvmsg+0x2c/0x2e
[ 1439.762122]    [<ffffffff804c7e7c>] do_sock_read+0x77/0x7b
[ 1439.762122]    [<ffffffff804c837d>] sock_aio_read+0x5f/0x73
[ 1439.762122]    [<ffffffff802a24dc>] do_sync_read+0xe2/0x126
[ 1439.762122]    [<ffffffff802a2c95>] vfs_read+0xb7/0xde
[ 1439.762122]    [<ffffffff802a2ed6>] sys_read+0x47/0x6b
[ 1439.762122]    [<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]   ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]    [<ffffffff8029f21d>] cache_alloc_refill+0x6d/0x216
[ 1439.762122]    [<ffffffff8029f41a>] ____cache_alloc+0x54/0x59
[ 1439.762122]    [<ffffffff8029f591>] kmem_cache_alloc+0x33/0x8b
[ 1439.762122]    [<ffffffff804f9586>] inet_bind_bucket_create+0x1d/0x4f
[ 1439.762122]    [<ffffffff804fb742>] inet_csk_get_port+0x14c/0x1f3
[ 1439.762122]    [<ffffffff80519456>] inet_bind+0x110/0x1a5
[ 1439.762122]    [<ffffffff804c8a9c>] sys_bind+0x60/0x83
[ 1439.762122]    [<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]   ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]    [<ffffffff804f93a9>] __inet_hash_nolisten+0x62/0x93
[ 1439.762122]    [<ffffffff804f975b>] __inet_hash_connect+0x1a3/0x253
[ 1439.762122]    [<ffffffff804f983b>] inet_hash_connect+0x30/0x35
[ 1439.762122]    [<ffffffff8050d083>] tcp_v4_connect+0x244/0x333
[ 1439.762122]    [<ffffffff80518ade>] inet_stream_connect+0x9a/0x183
[ 1439.762122]    [<ffffffff804c89ba>] sys_connect+0x68/0x8b
[ 1439.762122]    [<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  -> (&queue->syn_wait_lock){-+..} ops: 0 {
[ 1439.762122]     initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff8056457d>] _write_lock_bh+0x31/0x3d
[ 1439.762122]
[<ffffffff804cd1f7>] reqsk_queue_alloc+0xc1/0xda
[ 1439.762122]
[<ffffffff804fb446>] inet_csk_listen_start+0x1f/0xa3
[ 1439.762122]
[<ffffffff80518fb4>] inet_listen+0x5b/0x85
[ 1439.762122]
[<ffffffff804c8a21>] sys_listen+0x44/0x5f
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     hardirq-on-W at:
[ 1439.762122]
[<ffffffff80260463>] mark_irqflags+0xbd/0xf2
[ 1439.762122]
[<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff8056457d>] _write_lock_bh+0x31/0x3d
[ 1439.762122]
[<ffffffff804cd1f7>] reqsk_queue_alloc+0xc1/0xda
[ 1439.762122]
[<ffffffff804fb446>] inet_csk_listen_start+0x1f/0xa3
[ 1439.762122]
[<ffffffff80518fb4>] inet_listen+0x5b/0x85
[ 1439.762122]
[<ffffffff804c8a21>] sys_listen+0x44/0x5f
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]   }
[ 1439.762122]   ... key      at: [<ffffffff80eae768>] __key.31295+0x0/0x18
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  -> (&base->lock){++..} ops: 0 {
[ 1439.762122]     initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564502>] _spin_lock_irqsave+0x37/0x49
[ 1439.762122]
[<ffffffff8024837e>] lock_timer_base+0x26/0x4a
[ 1439.762122]
[<ffffffff80248449>] __mod_timer+0x2e/0xb8
[ 1439.762122]
[<ffffffff80248772>] mod_timer+0x25/0x27
[ 1439.762122]
[<ffffffff80804101>] con_init+0xbd/0x233
[ 1439.762122]
[<ffffffff808037b9>] console_init+0x19/0x2a
[ 1439.762122]
[<ffffffff807e6c05>] start_kernel+0x157/0x281
[ 1439.762122]
[<ffffffff807e62c8>] x86_64_start_reservations+0x7c/0x80
[ 1439.762122]
[<ffffffff807e6375>] x86_64_start_kernel+0x6a/0x72
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-hardirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]   }
[ 1439.762122]   ... key      at: [<ffffffff808a7258>] __key.21110+0x0/0x8
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  -> (&rt_hash_locks[i]){-+..} ops: 0 {
[ 1439.762122]     initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564481>] _spin_lock_bh+0x31/0x3d
[ 1439.762122]
[<ffffffff804ef842>] rt_intern_hash+0x83/0x354
[ 1439.762122]
[<ffffffff804efb5a>] ip_mkroute_output+0x47/0x50
[ 1439.762122]
[<ffffffff804efec4>] ip_route_output_slow+0x361/0x3a2
[ 1439.762122]
[<ffffffff804f008f>] __ip_route_output_key+0x18a/0x196
[ 1439.762122]
[<ffffffff804f00ad>] ip_route_output_flow+0x12/0x4b
[ 1439.762122]
[<ffffffff80512ab0>] udp_sendmsg+0x2ff/0x58e
[ 1439.762122]
[<ffffffff8051925a>] inet_sendmsg+0x46/0x53
[ 1439.762122]
[<ffffffff804c7d98>] __sock_sendmsg+0x28/0x2a
[ 1439.762122]
[<ffffffff804c8f0a>] sock_sendmsg+0xc7/0xe0
[ 1439.762122]
[<ffffffff804c9252>] sys_sendto+0xdf/0x104
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     hardirq-on-W at:
[ 1439.762122]
[<ffffffff80260463>] mark_irqflags+0xbd/0xf2
[ 1439.762122]
[<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564481>] _spin_lock_bh+0x31/0x3d
[ 1439.762122]
[<ffffffff804ef842>] rt_intern_hash+0x83/0x354
[ 1439.762122]
[<ffffffff804efb5a>] ip_mkroute_output+0x47/0x50
[ 1439.762122]
[<ffffffff804efec4>] ip_route_output_slow+0x361/0x3a2
[ 1439.762122]
[<ffffffff804f008f>] __ip_route_output_key+0x18a/0x196
[ 1439.762122]
[<ffffffff804f00ad>] ip_route_output_flow+0x12/0x4b
[ 1439.762122]
[<ffffffff80512ab0>] udp_sendmsg+0x2ff/0x58e
[ 1439.762122]
[<ffffffff8051925a>] inet_sendmsg+0x46/0x53
[ 1439.762122]
[<ffffffff804c7d98>] __sock_sendmsg+0x28/0x2a
[ 1439.762122]
[<ffffffff804c8f0a>] sock_sendmsg+0xc7/0xe0
[ 1439.762122]
[<ffffffff804c9252>] sys_sendto+0xdf/0x104
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]   }
[ 1439.762122]   ... key      at: [<ffffffff80eaf7d4>] __key.40605+0x0/0x8
[ 1439.762122]   ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]    [<ffffffff8029f21d>] cache_alloc_refill+0x6d/0x216
[ 1439.762122]    [<ffffffff8029f41a>] ____cache_alloc+0x54/0x59
[ 1439.762122]    [<ffffffff8029f591>] kmem_cache_alloc+0x33/0x8b
[ 1439.762122]    [<ffffffff804dc8c6>] kmem_cache_zalloc+0xf/0x11
[ 1439.762122]    [<ffffffff804de04a>] neigh_alloc+0x84/0x13b
[ 1439.762122]    [<ffffffff804de12c>] neigh_create+0x2b/0x1a4
[ 1439.762122]    [<ffffffff80513a8f>] __neigh_lookup_errno+0x2e/0x36
[ 1439.762122]    [<ffffffff80513b3a>] arp_bind_neighbour+0x4e/0x67
[ 1439.762122]    [<ffffffff804ef99b>] rt_intern_hash+0x1dc/0x354
[ 1439.762122]    [<ffffffff804efb5a>] ip_mkroute_output+0x47/0x50
[ 1439.762122]    [<ffffffff804efec4>] ip_route_output_slow+0x361/0x3a2
[ 1439.762122]    [<ffffffff804f008f>] __ip_route_output_key+0x18a/0x196
[ 1439.762122]    [<ffffffff804f00ad>] ip_route_output_flow+0x12/0x4b
[ 1439.762122]    [<ffffffff80512ab0>] udp_sendmsg+0x2ff/0x58e
[ 1439.762122]    [<ffffffff8051925a>] inet_sendmsg+0x46/0x53
[ 1439.762122]    [<ffffffff804c7d98>] __sock_sendmsg+0x28/0x2a
[ 1439.762122]    [<ffffffff804c8f0a>] sock_sendmsg+0xc7/0xe0
[ 1439.762122]    [<ffffffff804c9252>] sys_sendto+0xdf/0x104
[ 1439.762122]    [<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  -> (rt_peer_lock){-+..} ops: 0 {
[ 1439.762122]     initial-use  at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     hardirq-on-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]   }
[ 1439.762122]   ... key      at: [<ffffffff8078bbb8>]
rt_peer_lock.41458+0x18/0x40
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  -> (inet_peer_idlock){-+..} ops: 0 {
[ 1439.762122]     initial-use  at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     hardirq-on-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]   }
[ 1439.762122]   ... key      at: [<ffffffff8078c158>]
inet_peer_idlock+0x18/0x40
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  -> (inet_peer_unused_lock){-+..} ops: 0 {
[ 1439.762122]     initial-use  at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     hardirq-on-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]   }
[ 1439.762122]   ... key      at: [<ffffffff8078c198>]
inet_peer_unused_lock+0x18/0x30
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  -> (&pool->sp_lock){-+..} ops: 0 {
[ 1439.762122]     initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564481>] _spin_lock_bh+0x31/0x3d
[ 1439.762122]
[<ffffffffa0095f74>] svc_prepare_thread+0x59/0xf6 [sunrpc]
[ 1439.762122]
[<ffffffffa00c8f75>] lockd_up+0xa0/0x16f [lockd]
[ 1439.762122]
[<ffffffffa00de359>] nfsd_init_socks+0x3c/0x71 [nfsd]
[ 1439.762122]
[<ffffffffa00de60f>] nfsd_svc+0x7a/0xb6 [nfsd]
[ 1439.762122]
[<ffffffffa00df06c>] write_svc+0x1f/0x23 [nfsd]
[ 1439.762122]
[<ffffffffa00df541>] nfsctl_transaction_write+0x4b/0x6f [nfsd]
[ 1439.762122]
[<ffffffff802d6e85>] sys_nfsservctl+0x9d/0xec
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     in-softirq-W at:
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]     hardirq-on-W at:
[ 1439.762122]
[<ffffffff80260463>] mark_irqflags+0xbd/0xf2
[ 1439.762122]
[<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564481>] _spin_lock_bh+0x31/0x3d
[ 1439.762122]
[<ffffffffa0095f74>] svc_prepare_thread+0x59/0xf6 [sunrpc]
[ 1439.762122]
[<ffffffffa00c8f75>] lockd_up+0xa0/0x16f [lockd]
[ 1439.762122]
[<ffffffffa00de359>] nfsd_init_socks+0x3c/0x71 [nfsd]
[ 1439.762122]
[<ffffffffa00de60f>] nfsd_svc+0x7a/0xb6 [nfsd]
[ 1439.762122]
[<ffffffffa00df06c>] write_svc+0x1f/0x23 [nfsd]
[ 1439.762122]
[<ffffffffa00df541>] nfsctl_transaction_write+0x4b/0x6f [nfsd]
[ 1439.762122]
[<ffffffff802d6e85>] sys_nfsservctl+0x9d/0xec
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]   }
[ 1439.762122]   ... key      at: [<ffffffffa00b89a0>]
__key.23540+0x0/0xfffffffffffe8f33 [sunrpc]
[ 1439.762122]   ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564502>] _spin_lock_irqsave+0x37/0x49
[ 1439.762122]    [<ffffffff80253015>] add_wait_queue+0x15/0x44
[ 1439.762122]    [<ffffffffa00a0c2d>] svc_recv+0x2d8/0x584 [sunrpc]
[ 1439.762122]    [<ffffffffa00c8e0b>] lockd+0xc7/0x191 [lockd]
[ 1439.762122]    [<ffffffff80252c40>] kthread+0x49/0x79
[ 1439.762122]    [<ffffffff8020cae9>] child_rip+0xa/0x11
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]  ... acquired at:
[ 1439.762122]    [<ffffffff80260e80>] check_prev_add+0x118/0x182
[ 1439.762122]    [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]    [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]    [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]    [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]    [<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]    [<ffffffff8027bd89>] free_pages_bulk+0x2c/0x96
[ 1439.762122]    [<ffffffff8027c206>] free_hot_cold_page+0x105/0x131
[ 1439.762122]    [<ffffffff8027c286>] free_hot_page+0xb/0xd
[ 1439.762122]    [<ffffffff8027c375>] __free_pages+0x18/0x21
[ 1439.762122]    [<ffffffff8050cd55>] tcp_v4_destroy_sock+0x6a/0x85
[ 1439.762122]    [<ffffffff804fad4f>] inet_csk_destroy_sock+0x8a/0xae
[ 1439.762122]    [<ffffffff804fddf6>] tcp_close+0x2bc/0x2da
[ 1439.762122]    [<ffffffff80519082>] inet_release+0x58/0x5f
[ 1439.762122]    [<ffffffff804c9354>] sock_release+0x1a/0x76
[ 1439.762122]    [<ffffffff804c9804>] sock_close+0x22/0x26
[ 1439.762122]    [<ffffffff802a345e>] __fput+0x82/0x110
[ 1439.762122]    [<ffffffff802a381e>] fput+0x15/0x17
[ 1439.762122]    [<ffffffff802a09c9>] filp_close+0x67/0x72
[ 1439.762122]    [<ffffffff80240ae3>] close_files+0x66/0x8d
[ 1439.762122]    [<ffffffff80240b39>] put_files_struct+0x19/0x42
[ 1439.762122]    [<ffffffff80240b98>] exit_files+0x36/0x3b
[ 1439.762122]    [<ffffffff80241eec>] do_exit+0x1b7/0x2b1
[ 1439.762122]    [<ffffffff80242087>] sys_exit_group+0x0/0x14
[ 1439.762122]    [<ffffffff80242099>] sys_exit_group+0x12/0x14
[ 1439.762122]    [<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]
[ 1439.762122]
[ 1439.762122] the soft-irq-unsafe lock's dependencies:
[ 1439.762122] -> (&fbc->lock){--..} ops: 0 {
[ 1439.762122]    initial-use  at:
[ 1439.762122]
[<ffffffff80261243>] __lock_acquire+0x1d8/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]
[<ffffffff803691a6>] __percpu_counter_add+0x4a/0x6d
[ 1439.762122]
[<ffffffff802a3168>] percpu_counter_add+0xe/0x10
[ 1439.762122]
[<ffffffff802a31db>] percpu_counter_inc+0xe/0x10
[ 1439.762122]
[<ffffffff802a364c>] get_empty_filp+0x75/0x117
[ 1439.762122]
[<ffffffff802acb19>] path_lookup_open+0x2b/0x9b
[ 1439.762122]
[<ffffffff802acf12>] do_filp_open+0xae/0x6b8
[ 1439.762122]
[<ffffffff802a0b2f>] do_sys_open+0x4f/0x99
[ 1439.762122]
[<ffffffff802a0ba2>] sys_open+0x1b/0x1d
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]    softirq-on-W at:
[ 1439.762122]
[<ffffffff80260480>] mark_irqflags+0xda/0xf2
[ 1439.762122]
[<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]
[<ffffffff803691a6>] __percpu_counter_add+0x4a/0x6d
[ 1439.762122]
[<ffffffff802a3168>] percpu_counter_add+0xe/0x10
[ 1439.762122]
[<ffffffff802a31db>] percpu_counter_inc+0xe/0x10
[ 1439.762122]
[<ffffffff802a364c>] get_empty_filp+0x75/0x117
[ 1439.762122]
[<ffffffff802acb19>] path_lookup_open+0x2b/0x9b
[ 1439.762122]
[<ffffffff802acf12>] do_filp_open+0xae/0x6b8
[ 1439.762122]
[<ffffffff802a0b2f>] do_sys_open+0x4f/0x99
[ 1439.762122]
[<ffffffff802a0ba2>] sys_open+0x1b/0x1d
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]    hardirq-on-W at:
[ 1439.762122]
[<ffffffff80260463>] mark_irqflags+0xbd/0xf2
[ 1439.762122]
[<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
[ 1439.762122]
[<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]
[<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]
[<ffffffff803691a6>] __percpu_counter_add+0x4a/0x6d
[ 1439.762122]
[<ffffffff802a3168>] percpu_counter_add+0xe/0x10
[ 1439.762122]
[<ffffffff802a31db>] percpu_counter_inc+0xe/0x10
[ 1439.762122]
[<ffffffff802a364c>] get_empty_filp+0x75/0x117
[ 1439.762122]
[<ffffffff802acb19>] path_lookup_open+0x2b/0x9b
[ 1439.762122]
[<ffffffff802acf12>] do_filp_open+0xae/0x6b8
[ 1439.762122]
[<ffffffff802a0b2f>] do_sys_open+0x4f/0x99
[ 1439.762122]
[<ffffffff802a0ba2>] sys_open+0x1b/0x1d
[ 1439.762122]
[<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
[ 1439.762122]
[<ffffffffffffffff>] 0xffffffffffffffff
[ 1439.762122]  }
[ 1439.762122]  ... key      at: [<ffffffff80e9d78c>] __key.10254+0x0/0x8
[ 1439.762122]
[ 1439.762122] stack backtrace:
[ 1439.762122] Pid: 22302, comm: netperf Not tainted 2.6.28-rc8-net-next-igb #13
[ 1439.762122] Call Trace:
[ 1439.762122]  [<ffffffff802609fb>] print_bad_irq_dependency+0x250/0x261
[ 1439.762122]  [<ffffffff80260a82>] check_usage+0x76/0x83
[ 1439.762122]  [<ffffffff80260b04>] check_prev_add_irq+0x75/0xae
[ 1439.762122]  [<ffffffff80260dc1>] check_prev_add+0x59/0x182
[ 1439.762122]  [<ffffffff80260f5d>] check_prevs_add+0x73/0xe5
[ 1439.762122]  [<ffffffff80261042>] validate_chain+0x73/0x9c
[ 1439.762122]  [<ffffffff802612f0>] __lock_acquire+0x285/0x2ee
[ 1439.762122]  [<ffffffff80261d93>] lock_acquire+0x55/0x71
[ 1439.762122]  [<ffffffff803691a6>] ? __percpu_counter_add+0x4a/0x6d
[ 1439.762122]  [<ffffffff80564444>] _spin_lock+0x2c/0x38
[ 1439.762122]  [<ffffffff803691a6>] ? __percpu_counter_add+0x4a/0x6d
[ 1439.762122]  [<ffffffff803691a6>] __percpu_counter_add+0x4a/0x6d
[ 1439.762122]  [<ffffffff8050b196>] percpu_counter_add+0xe/0x10
[ 1439.762122]  [<ffffffff8050b1a5>] percpu_counter_dec+0xd/0xf
[ 1439.762122]  [<ffffffff8050cd6c>] tcp_v4_destroy_sock+0x81/0x85
[ 1439.762122]  [<ffffffff804fad4f>] inet_csk_destroy_sock+0x8a/0xae
[ 1439.762122]  [<ffffffff804fdca6>] ? tcp_close+0x16c/0x2da
[ 1439.762122]  [<ffffffff804fddf6>] tcp_close+0x2bc/0x2da
[ 1439.762122]  [<ffffffff80519082>] inet_release+0x58/0x5f
[ 1439.762122]  [<ffffffff804c9354>] sock_release+0x1a/0x76
[ 1439.762122]  [<ffffffff804c9804>] sock_close+0x22/0x26
[ 1439.762122]  [<ffffffff802a345e>] __fput+0x82/0x110
[ 1439.762122]  [<ffffffff802a381e>] fput+0x15/0x17
[ 1439.762122]  [<ffffffff802a09c9>] filp_close+0x67/0x72
[ 1439.762122]  [<ffffffff802a0a4f>] sys_close+0x7b/0xbe
[ 1439.762122]  [<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b



-- 
Cheers,
Jeff
