From: Kamalesh Babulal <kamalesh-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [BUG] 2.6.26-rc8-git2 - powerpc - circular locking dependency
 detected with net/ehea driver
Date: Tue, 08 Jul 2008 00:13:14 +0530
Message-ID: <487263C2.60404@linux.vnet.ibm.com>
References: <486A2553.1090207@linux.vnet.ibm.com> <200807071108.09616.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: Jan-Bernd Themann <ossthema-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200807071108.09616.ossthema-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> Hi Kamalesh,
> 
> where you able to reproduce this problem with the patches applied
> we posted on friday?
> 
> Regards,
> Jan-Bernd
> 
> On Tuesday 01 July 2008 14:38, Kamalesh Babulal wrote:
>> Hi,
>>
>> circular locking dependency is detected, while booting the
>> powerpc box with the 2.6.26-rc8-git2 kernel.
>>
>> =======================================================
>> [ INFO: possible circular locking dependency detected ]
>> 2.6.26-rc8-git2 #1
>> -------------------------------------------------------
Hi Jan-Bernd,

Thanks for the patch. I tried your patch set over the 2.6.26-rc8-git2 kernel, 
the circular dependency is still begin detected :(.

Jul  7 09:12:42 : =======================================================
Jul  7 09:12:42 : [ INFO: possible circular locking dependency detected ]
Jul  7 09:12:42 : 2.6.26-rc8-git2 #2
Jul  7 09:12:42 : -------------------------------------------------------
Jul  7 09:12:42 : ip/2218 is trying to acquire lock:
Jul  7 09:12:42 :  (&ehea_fw_handles.lock){--..}, at: [<d0000000002740c4>] .ehea_up+0x6c/0x6f4 [ehea]
Jul  7 09:12:42 : 
Jul  7 09:12:42 : but task is already holding lock:
Jul  7 09:12:42 :  (&port->port_lock){--..}, at: [<d0000000002757dc>] .ehea_open+0x44/0xcc [ehea]
Jul  7 09:12:42 : 
Jul  7 09:12:42 : which lock already depends on the new lock.
Jul  7 09:12:42 : 
Jul  7 09:12:42 : 
Jul  7 09:12:42 : the existing dependency chain (in reverse order) is:
Jul  7 09:12:42 : 
Jul  7 09:12:42 : -> #2 (&port->port_lock){--..}:
Jul  7 09:12:42 :        [<c0000000000aa0e8>] .__lock_acquire+0xc84/0xee0
Jul  7 09:12:42 :        [<c0000000000aa41c>] .lock_acquire+0xd8/0x124
Jul  7 09:12:42 :        [<c000000000452008>] .mutex_lock_nested+0x168/0x420
Jul  7 09:12:42 :        [<d0000000002757dc>] .ehea_open+0x44/0xcc [ehea]
Jul  7 09:12:42 :        [<c0000000003b62b0>] .dev_open+0xec/0x160
Jul  7 09:12:42 :        [<c0000000003b46a4>] .dev_change_flags+0x10c/0x210
Jul  7 09:12:42 :        [<c0000000004162b0>] .devinet_ioctl+0x2cc/0x778
Jul  7 09:12:42 :        [<c0000000004173e0>] .inet_ioctl+0xdc/0x134
Jul  7 09:12:42 :        [<c0000000003a4464>] .sock_ioctl+0x2dc/0x338
Jul  7 09:12:42 :        [<c00000000012d12c>] .vfs_ioctl+0x64/0xfc
Jul  7 09:12:42 :        [<c00000000012d614>] .do_vfs_ioctl+0x450/0x494
Jul  7 09:12:42 :        [<c00000000012d6d0>] .sys_ioctl+0x78/0xc0
Jul  7 09:12:42 :        [<c00000000016413c>] .dev_ifsioc+0x1e8/0x450
Jul  7 09:12:42 :        [<c000000000163588>] .compat_sys_ioctl+0x3ec/0x484
Jul  7 09:12:42 :        [<c0000000000086dc>] syscall_exit+0x0/0x40
Jul  7 09:12:42 : 
Jul  7 09:12:42 : -> #1 (rtnl_mutex){--..}:
Jul  7 09:12:42 :        [<c0000000000aa0e8>] .__lock_acquire+0xc84/0xee0
Jul  7 09:12:42 :        [<c0000000000aa41c>] .lock_acquire+0xd8/0x124
Jul  7 09:12:42 :        [<c000000000452008>] .mutex_lock_nested+0x168/0x420
Jul  7 09:12:42 :        [<c0000000003c1ad0>] .rtnl_lock+0x28/0x44
Jul  7 09:12:42 :        [<c0000000003b5334>] .register_netdev+0x24/0x8c
Jul  7 09:12:42 :        [<d00000000027292c>] .ehea_setup_single_port+0x2d4/0x3e0 [ehea]
Jul  7 09:12:42 :        [<d00000000027a494>] .ehea_probe_adapter+0x290/0x3a0 [ehea]
Jul  7 09:12:42 :        [<c0000000003a0098>] .of_platform_device_probe+0x80/0x8c4
Jul  7 09:12:42 :        [<c000000000305ce4>] .driver_probe_device+0x144/0x20c
Jul  7 09:12:42 :        [<c000000000305e14>] .__driver_attach+0x68/0xb0
Jul  7 09:12:42 :        [<c000000000304ed4>] .bus_for_each_dev+0x88/0xe4
Jul  7 09:12:42 :        [<c000000000305a24>] .driver_attach+0x34/0x50
Jul  7 09:12:42 :        [<c000000000305524>] .bus_add_driver+0xe0/0x294
Jul  7 09:12:42 :        [<c000000000306178>] .driver_register+0xcc/0x1a4
Jul  7 09:12:42 :        [<c00000000039ff30>] .of_register_driver+0x54/0x6c
Jul  7 09:12:42 :        [<c0000000000256f4>] .ibmebus_register_driver+0x40/0x60
Jul  7 09:12:42 :        [<d00000000027a788>] .ehea_module_init+0x1e4/0x238c [ehea]
Jul  7 09:12:42 :        [<c0000000000b5294>] .sys_init_module+0x19a0/0x1b80
Jul  7 09:12:42 :        [<c0000000000086dc>] syscall_exit+0x0/0x40
Jul  7 09:12:42 : 
Jul  7 09:12:42 : -> #0 (&ehea_fw_handles.lock){--..}:
Jul  7 09:12:42 :        [<c0000000000a9fe4>] .__lock_acquire+0xb80/0xee0
Jul  7 09:12:42 :        [<c0000000000aa41c>] .lock_acquire+0xd8/0x124
Jul  7 09:12:42 :        [<c000000000452008>] .mutex_lock_nested+0x168/0x420
Jul  7 09:12:42 :        [<d0000000002740c4>] .ehea_up+0x6c/0x6f4 [ehea]
Jul  7 09:12:42 :        [<d000000000275804>] .ehea_open+0x6c/0xcc [ehea]
Jul  7 09:12:42 :        [<c0000000003b62b0>] .dev_open+0xec/0x160
Jul  7 09:12:42 :        [<c0000000003b46a4>] .dev_change_flags+0x10c/0x210
Jul  7 09:12:42 :        [<c0000000004162b0>] .devinet_ioctl+0x2cc/0x778
Jul  7 09:12:42 :        [<c0000000004173e0>] .inet_ioctl+0xdc/0x134
Jul  7 09:12:42 :        [<c0000000003a4464>] .sock_ioctl+0x2dc/0x338
Jul  7 09:12:42 :        [<c00000000012d12c>] .vfs_ioctl+0x64/0xfc
Jul  7 09:12:42 :        [<c00000000012d614>] .do_vfs_ioctl+0x450/0x494
Jul  7 09:12:42 :        [<c00000000012d6d0>] .sys_ioctl+0x78/0xc0
Jul  7 09:12:42 :        [<c00000000016413c>] .dev_ifsioc+0x1e8/0x450
Jul  7 09:12:42 :        [<c000000000163588>] .compat_sys_ioctl+0x3ec/0x484
Jul  7 09:12:42 :        [<c0000000000086dc>] syscall_exit+0x0/0x40
Jul  7 09:12:42 : 
Jul  7 09:12:42 : other info that might help us debug this:
Jul  7 09:12:42 : 
Jul  7 09:12:42 : 2 locks held by ip/2218:
Jul  7 09:12:42 :  #0:  (rtnl_mutex){--..}, at: [<c0000000003c1ad0>] .rtnl_lock+0x28/0x44
Jul  7 09:12:42 :  #1:  (&port->port_lock){--..}, at: [<d0000000002757dc>] .ehea_open+0x44/0xcc [ehea]
Jul  7 09:12:42 : 
Jul  7 09:12:42 : stack backtrace:
Jul  7 09:12:42 : Call Trace:
Jul  7 09:12:42 : [c0000000f7b6f030] [c000000000010b9c] .show_stack+0x78/0x1c8 (unreliable)
Jul  7 09:12:42 : [c0000000f7b6f0e0] [c000000000010d0c] .dump_stack+0x20/0x34
Jul  7 09:12:42 : [c0000000f7b6f160] [c0000000000a7644] .print_circular_bug_tail+0x84/0xa8
Jul  7 09:12:42 : [c0000000f7b6f230] [c0000000000a9fe4] .__lock_acquire+0xb80/0xee0
Jul  7 09:12:42 keechi-lp2 rmcctrl: 0513-059 The ctrmc Subsystem has been started. Subsystem PID is 2316.
Jul  7 09:12:42 : [c0000000f7b6f320] [c0000000000aa41c] .lock_acquire+0xd8/0x124
Jul  7 09:12:42 : [c0000000f7b6f3e0] [c000000000452008] .mutex_lock_nested+0x168/0x420
Jul  7 09:12:42 : [c0000000f7b6f4d0] [d0000000002740c4] .ehea_up+0x6c/0x6f4 [ehea]
Jul  7 09:12:42 : [c0000000f7b6f5e0] [d000000000275804] .ehea_open+0x6c/0xcc [ehea]
Jul  7 09:12:42 : [c0000000f7b6f680] [c0000000003b62b0] .dev_open+0xec/0x160
Jul  7 09:12:42 : [c0000000f7b6f710] [c0000000003b46a4] .dev_change_flags+0x10c/0x210
Jul  7 09:12:42 : [c0000000f7b6f7c0] [c0000000004162b0] .devinet_ioctl+0x2cc/0x778
Jul  7 09:12:42 : [c0000000f7b6f8d0] [c0000000004173e0] .inet_ioctl+0xdc/0x134
Jul  7 09:12:42 : [c0000000f7b6f950] [c0000000003a4464] .sock_ioctl+0x2dc/0x338
Jul  7 09:12:42 : [c0000000f7b6f9f0] [c00000000012d12c] .vfs_ioctl+0x64/0xfc
Jul  7 09:12:42 : [c0000000f7b6fa90] [c00000000012d614] .do_vfs_ioctl+0x450/0x494
Jul  7 09:12:42 : [c0000000f7b6fb50] [c00000000012d6d0] .sys_ioctl+0x78/0xc0
Jul  7 09:12:42 : [c0000000f7b6fc10] [c00000000016413c] .dev_ifsioc+0x1e8/0x450
Jul  7 09:12:42 : [c0000000f7b6fd30] [c000000000163588] .compat_sys_ioctl+0x3ec/0x484
Jul  7 09:12:42 : [c0000000f7b6fe30] [c0000000000086dc] syscall_exit+0x0/0x40
Jul  7 09:12:42 : ehea: eth0: Physical port up
Jul  7 09:12:42 : ehea: External switch port is backup port

0x40c4 is in ehea_up (drivers/net/ehea/ehea_main.c:2469).
2464            struct ehea_port *port = netdev_priv(dev);
2465
2466            if (port->state == EHEA_PORT_UP)
2467                    return 0;
2468
2469            mutex_lock(&ehea_fw_handles.lock);
2470
2471            ret = ehea_port_res_setup(port, port->num_def_qps,
2472                                      port->num_add_tx_qps);
2473            if (ret) {

0x57dc is in ehea_open (drivers/net/ehea/ehea_main.c:2559).
2554    static int ehea_open(struct net_device *dev)
2555    {
2556            int ret;
2557            struct ehea_port *port = netdev_priv(dev);
2558
2559            mutex_lock(&port->port_lock);
2560
2561            if (netif_msg_ifup(port))
2562                    ehea_info("enabling port %s", dev->name);
2563


-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
