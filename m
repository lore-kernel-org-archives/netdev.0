From: Kamalesh Babulal <kamalesh-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [BUG] 2.6.26-rc8-git2 - powerpc - circular locking dependency detected
 with net/ehea driver
Date: Tue, 01 Jul 2008 18:08:43 +0530
Message-ID: <486A2553.1090207@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

circular locking dependency is detected, while booting the
powerpc box with the 2.6.26-rc8-git2 kernel.

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.26-rc8-git2 #1
-------------------------------------------------------
ip/2214 is trying to acquire lock:
 (&ehea_fw_handles.lock){--..}, at: [<d0000000007b4fa8>] .ehea_up+0x6c/0x6f8 [ehea]

but task is already holding lock:
 (&port->port_lock){--..}, at: [<d0000000007b57bc>] .ehea_open+0x44/0xcc [ehea]

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #2 (&port->port_lock){--..}:
       [<c0000000000aa0e8>] .__lock_acquire+0xc84/0xee0
       [<c0000000000aa41c>] .lock_acquire+0xd8/0x124
       [<c000000000452008>] .mutex_lock_nested+0x168/0x420
       [<d0000000007b57bc>] .ehea_open+0x44/0xcc [ehea]
       [<c0000000003b62b0>] .dev_open+0xec/0x160
       [<c0000000003b46a4>] .dev_change_flags+0x10c/0x210
       [<c0000000004162b0>] .devinet_ioctl+0x2cc/0x778
       [<c0000000004173e0>] .inet_ioctl+0xdc/0x134
       [<c0000000003a4464>] .sock_ioctl+0x2dc/0x338
       [<c00000000012d12c>] .vfs_ioctl+0x64/0xfc
       [<c00000000012d614>] .do_vfs_ioctl+0x450/0x494
       [<c00000000012d6d0>] .sys_ioctl+0x78/0xc0
       [<c00000000016413c>] .dev_ifsioc+0x1e8/0x450
       [<c000000000163588>] .compat_sys_ioctl+0x3ec/0x484
       [<c0000000000086dc>] syscall_exit+0x0/0x40

-> #1 (rtnl_mutex){--..}:
       [<c0000000000aa0e8>] .__lock_acquire+0xc84/0xee0
       [<c0000000000aa41c>] .lock_acquire+0xd8/0x124
       [<c000000000452008>] .mutex_lock_nested+0x168/0x420
       [<c0000000003c1ad0>] .rtnl_lock+0x28/0x44
       [<c0000000003b5334>] .register_netdev+0x24/0x8c
       [<d0000000007b3810>] .ehea_setup_single_port+0x2d4/0x3e0 [ehea]
       [<d0000000007ba434>] .ehea_probe_adapter+0x290/0x3a0 [ehea]
       [<c0000000003a0098>] .of_platform_device_probe+0x80/0x8c4
       [<c000000000305ce4>] .driver_probe_device+0x144/0x20c
       [<c000000000305e14>] .__driver_attach+0x68/0xb0
       [<c000000000304ed4>] .bus_for_each_dev+0x88/0xe4
       [<c000000000305a24>] .driver_attach+0x34/0x50
       [<c000000000305524>] .bus_add_driver+0xe0/0x294
       [<c000000000306178>] .driver_register+0xcc/0x1a4
       [<c00000000039ff30>] .of_register_driver+0x54/0x6c
       [<c0000000000256f4>] .ibmebus_register_driver+0x40/0x60
       [<d0000000007ba728>] .ehea_module_init+0x1e4/0x22fc [ehea]
       [<c0000000000b5294>] .sys_init_module+0x19a0/0x1b80
       [<c0000000000086dc>] syscall_exit+0x0/0x40

-> #0 (&ehea_fw_handles.lock){--..}:
       [<c0000000000a9fe4>] .__lock_acquire+0xb80/0xee0
       [<c0000000000aa41c>] .lock_acquire+0xd8/0x124
       [<c000000000452008>] .mutex_lock_nested+0x168/0x420
       [<d0000000007b4fa8>] .ehea_up+0x6c/0x6f8 [ehea]
       [<d0000000007b57e4>] .ehea_open+0x6c/0xcc [ehea]
       [<c0000000003b62b0>] .dev_open+0xec/0x160
       [<c0000000003b46a4>] .dev_change_flags+0x10c/0x210
       [<c0000000004162b0>] .devinet_ioctl+0x2cc/0x778
       [<c0000000004173e0>] .inet_ioctl+0xdc/0x134
       [<c0000000003a4464>] .sock_ioctl+0x2dc/0x338
       [<c00000000012d12c>] .vfs_ioctl+0x64/0xfc
       [<c00000000012d614>] .do_vfs_ioctl+0x450/0x494
       [<c00000000012d6d0>] .sys_ioctl+0x78/0xc0
       [<c00000000016413c>] .dev_ifsioc+0x1e8/0x450
       [<c000000000163588>] .compat_sys_ioctl+0x3ec/0x484
       [<c0000000000086dc>] syscall_exit+0x0/0x40

other info that might help us debug this:

2 locks held by ip/2214:
 #0:  (rtnl_mutex){--..}, at: [<c0000000003c1ad0>] .rtnl_lock+0x28/0x44
 #1:  (&port->port_lock){--..}, at: [<d0000000007b57bc>] .ehea_open+0x44/0xcc [ehea]

stack backtrace:
Call Trace:
[c0000000f4d0f030] [c000000000010b9c] .show_stack+0x78/0x1c8 (unreliable)
[c0000000f4d0f0e0] [c000000000010d0c] .dump_stack+0x20/0x34
[c0000000f4d0f160] [c0000000000a7644] .print_circular_bug_tail+0x84/0xa8
[c0000000f4d0f230] [c0000000000a9fe4] .__lock_acquire+0xb80/0xee0
[c0000000f4d0f320] [c0000000000aa41c] .lock_acquire+0xd8/0x124
[c0000000f4d0f3e0] [c000000000452008] .mutex_lock_nested+0x168/0x420
[c0000000f4d0f4d0] [d0000000007b4fa8] .ehea_up+0x6c/0x6f8 [ehea]
[c0000000f4d0f5e0] [d0000000007b57e4] .ehea_open+0x6c/0xcc [ehea]
[c0000000f4d0f680] [c0000000003b62b0] .dev_open+0xec/0x160
[c0000000f4d0f710] [c0000000003b46a4] .dev_change_flags+0x10c/0x210
[c0000000f4d0f7c0] [c0000000004162b0] .devinet_ioctl+0x2cc/0x778
[c0000000f4d0f8d0] [c0000000004173e0] .inet_ioctl+0xdc/0x134
[c0000000f4d0f950] [c0000000003a4464] .sock_ioctl+0x2dc/0x338
[c0000000f4d0f9f0] [c00000000012d12c] .vfs_ioctl+0x64/0xfc
[c0000000f4d0fa90] [c00000000012d614] .do_vfs_ioctl+0x450/0x494
[c0000000f4d0fb50] [c00000000012d6d0] .sys_ioctl+0x78/0xc0
[c0000000f4d0fc10] [c00000000016413c] .dev_ifsioc+0x1e8/0x450
[c0000000f4d0fd30] [c000000000163588] .compat_sys_ioctl+0x3ec/0x484
[c0000000f4d0fe30] [c0000000000086dc] syscall_exit+0x0/0x40
ehea: eth0: Physical port up
ehea: External switch port is backup port
BUG: sleeping function called from invalid context at kernel/mutex.c:209
in_atomic():1, irqs_disabled():0
INFO: lockdep is turned off.
Call Trace:
[c0000000f4d0f200] [c000000000010b9c] .show_stack+0x78/0x1c8 (unreliable)
[c0000000f4d0f2b0] [c000000000010d0c] .dump_stack+0x20/0x34
[c0000000f4d0f330] [c00000000006dfc0] .__might_sleep+0x104/0x124
[c0000000f4d0f3c0] [c000000000451ef0] .mutex_lock_nested+0x50/0x420
[c0000000f4d0f4b0] [d0000000007b2f80] .ehea_set_multicast_list+0x64/0x1d8 [ehea]
[c0000000f4d0f560] [c0000000003b2de4] .__dev_set_rx_mode+0xd0/0xf0
[c0000000f4d0f5f0] [c0000000003b2e44] .dev_set_rx_mode+0x40/0x70
[c0000000f4d0f680] [c0000000003b62ec] .dev_open+0x128/0x160
[c0000000f4d0f710] [c0000000003b46a4] .dev_change_flags+0x10c/0x210
[c0000000f4d0f7c0] [c0000000004162b0] .devinet_ioctl+0x2cc/0x778
[c0000000f4d0f8d0] [c0000000004173e0] .inet_ioctl+0xdc/0x134
[c0000000f4d0f950] [c0000000003a4464] .sock_ioctl+0x2dc/0x338
[c0000000f4d0f9f0] [c00000000012d12c] .vfs_ioctl+0x64/0xfc
[c0000000f4d0fa90] [c00000000012d614] .do_vfs_ioctl+0x450/0x494
[c0000000f4d0fb50] [c00000000012d6d0] .sys_ioctl+0x78/0xc0
[c0000000f4d0fc10] [c00000000016413c] .dev_ifsioc+0x1e8/0x450
[c0000000f4d0fd30] [c000000000163588] .compat_sys_ioctl+0x3ec/0x484
[c0000000f4d0fe30] [c0000000000086dc] syscall_exit+0x0/0x40
[  OK  ]
Starting auditd: [  OK  ]
Starting system logger: [  OK  ]
Starting kernel logger: [  OK  ]
Starting ctrmc:  WARNING: initlog is deprecated and will be removed in a future release
WARNING: initlog is deprecated and will be removed in a future release
[  OK  ]
Starting irqbalance: [  OK  ]
Starting portmap: [  OK  ]
Starting NFS statd: [  OK  ]
Starting RPC idmapd: [  OK  ]
Starting system message bus: [  OK  ]
[  OK  ] Bluetooth services:[  OK  ]
Mounting other filesystems:  [  OK  ]
Starting PC/SC smart card daemon (pcscd): [  OK  ]
Starting hidd: [  OK  ]
Starting autofs:  Loading autofs4: [  OK  ]
Starting automount: [  OK  ]
[  OK  ]
Starting hpiod: [  OK  ]
Starting hpssd: [  OK  ]
Starting iprinit:  Starting ipr initialization daemon[  OK  ]
[  OK  ]
Starting iprupdate:  Checking ipr microcode levels
Completed ipr microcode updates[  OK  ]
[  OK  ]
Starting rtas_errd (platform error handling) daemon: [  OK  ]
Starting iprdump:  Starting ipr dump daemon[  OK  ]
[  OK  ]
Starting sshd: BUG: sleeping function called from invalid context at kernel/mutex.c:209
in_atomic():1, irqs_disabled():0
INFO: lockdep is turned off.
Call Trace:
[c00000010ac5f1e0] [c000000000010b9c] .show_stack+0x78/0x1c8 (unreliable)
[c00000010ac5f290] [c000000000010d0c] .dump_stack+0x20/0x34
[c00000010ac5f310] [c00000000006dfc0] .__might_sleep+0x104/0x124
[c00000010ac5f3a0] [c000000000451ef0] .mutex_lock_nested+0x50/0x420
[c00000010ac5f490] [d0000000007b2f80] .ehea_set_multicast_list+0x64/0x1d8 [ehea]
[c00000010ac5f540] [c0000000003b2de4] .__dev_set_rx_mode+0xd0/0xf0
[c00000010ac5f5d0] [c0000000003b98a4] .dev_mc_add+0x7c/0xc0
[c00000010ac5f680] [d000000000827efc] .igmp6_group_added+0x94/0x208 [ipv6]
[c00000010ac5f740] [d0000000008284e4] .ipv6_dev_mc_inc+0x400/0x44c [ipv6]
[c00000010ac5f7e0] [d00000000080c59c] .ipv6_add_dev+0x2ec/0x358 [ipv6]
[c00000010ac5f8a0] [d00000000080d2b8] .addrconf_notify+0xbc/0x928 [ipv6]
[c00000010ac5fa50] [c0000000003b717c] .register_netdevice_notifier+0x94/0x29c
[c00000010ac5fb00] [d000000000839358] .addrconf_init+0xa4/0x1ac [ipv6]
[c00000010ac5fb90] [d0000000008390e0] .inet6_init+0x248/0x3dc [ipv6]
[c00000010ac5fc30] [c0000000000b5294] .sys_init_module+0x19a0/0x1b80
[c00000010ac5fe30] [c0000000000086dc] syscall_exit+0x0/0x40
[  OK  ]
Starting cups: [  OK  ]
Starting xinetd: [  OK  ]
Starting NFS services:  [  OK  ]
Starting NFS quotas: [  OK  ]
Starting NFS daemon: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[  OK  ]
Starting NFS mountd: [  OK  ]
Starting vsftpd for vsftpd: [  OK  ]
Starting sendmail: [  OK  ]
Starting sm-client: [  OK  ]
Starting console mouse services: [  OK  ]
Starting crond: [  OK  ]
Starting xfs: [  OK  ]
Starting anacron: [  OK  ]
Starting atd: [  OK  ]
Starting yum-updatesd: [  OK  ]
Starting Avahi daemon... BUG: sleeping function called from invalid context at kernel/mutex.c:209
in_atomic():1, irqs_disabled():0
INFO: lockdep is turned off.
Call Trace:
[c00000010608f200] [c000000000010b9c] .show_stack+0x78/0x1c8 (unreliable)
[c00000010608f2b0] [c000000000010d0c] .dump_stack+0x20/0x34
[c00000010608f330] [c00000000006dfc0] .__might_sleep+0x104/0x124
[c00000010608f3c0] [c000000000451ef0] .mutex_lock_nested+0x50/0x420
[c00000010608f4b0] [d0000000007b2f80] .ehea_set_multicast_list+0x64/0x1d8 [ehea]
[c00000010608f560] [c0000000003b2de4] .__dev_set_rx_mode+0xd0/0xf0
[c00000010608f5f0] [c0000000003b98a4] .dev_mc_add+0x7c/0xc0
[c00000010608f6a0] [d000000000827efc] .igmp6_group_added+0x94/0x208 [ipv6]
[c00000010608f760] [d0000000008284e4] .ipv6_dev_mc_inc+0x400/0x44c [ipv6]
[c00000010608f800] [d000000000828e9c] .ipv6_sock_mc_join+0x1e0/0x288 [ipv6]
[c00000010608f8c0] [d000000000818338] .do_ipv6_setsockopt+0x91c/0xcfc [ipv6]
[c00000010608faf0] [d0000000008189a0] .ipv6_setsockopt+0x90/0x120 [ipv6]
[c00000010608fba0] [d00000000081d408] .udpv6_setsockopt+0x40/0x5c [ipv6]
[c00000010608fc20] [c0000000003a4bf4] .sock_common_setsockopt+0x40/0x58
[c00000010608fca0] [c0000000003a1ae8] .sys_setsockopt+0xc0/0x110
[c00000010608fd60] [c0000000003a4054] .sys_socketcall+0x1bc/0x21c
[c00000010608fe30] [c0000000000086dc] syscall_exit+0x0/0x40
[  OK  ]

0xc0000000003c1ad0 is in rtnl_lock (net/core/rtnetlink.c:66).
61
62      static DEFINE_MUTEX(rtnl_mutex);
63
64      void rtnl_lock(void)
65      {
66              mutex_lock(&rtnl_mutex);
67      }
68
69      void __rtnl_unlock(void)
70      {

0x4fa8 is in ehea_up (drivers/net/ehea/ehea_main.c:2462).
2457            struct ehea_port *port = netdev_priv(dev);
2458
2459            if (port->state == EHEA_PORT_UP)
2460                    return 0;
2461
2462            mutex_lock(&ehea_fw_handles.lock);
2463
2464            ret = ehea_port_res_setup(port, port->num_def_qps,
2465                                      port->num_add_tx_qps);
2466            if (ret) {

0x57bc is in ehea_open (drivers/net/ehea/ehea_main.c:2552).
2547    static int ehea_open(struct net_device *dev)
2548    {
2549            int ret;
2550            struct ehea_port *port = netdev_priv(dev);
2551
2552            mutex_lock(&port->port_lock);
2553
2554            if (netif_msg_ifup(port))
2555                    ehea_info("enabling port %s", dev->name);
2556


-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
