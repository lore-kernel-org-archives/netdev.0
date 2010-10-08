From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Fri, 8 Oct 2010 13:53:27 +0200
Message-ID: <201010081353.28056.hans.schillstrom@ericsson.com>
References: <201010071048.12817.hans.schillstrom@ericsson.com> <4CAEFE2C.3010007@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:48465 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932148Ab0JHLxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 07:53:30 -0400
In-Reply-To: <4CAEFE2C.3010007@free.fr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 08 October 2010 13:19:08 Daniel Lezcano wrote:
Hello
> On 10/07/2010 10:48 AM, Hans Schillstrom wrote:
> > Hello
> > I'm trying to exit a network name space and it doesn't work (or am I doing something wrong?)
> > The only netdevices left are lo and the tunnels ip6tnl0, sit0 and tunl0 when exiting netns.
> >
> > A netns is created by lxc-execute with two interfaces eth0 eth1 (macvlan)
> > (see conf file at the end)
> >
> > Kernel: net-next-2.6 top from 4 october 2010
> >
> 
> Hi Hans,
> 
> I tried to reproduce your problem but I just get a big kernel crash when
> exiting the container :/
> 
> The stack is different but it may be related to the same problem.
> 
> BUG: unable to handle kernel paging request at ffff88003ba453a0
> IP: [<ffffffff813020b6>] macvlan_stop+0x57/0x7d
> PGD 180b063 PUD 180f063 PMD 1ffdb067 PTE 3ba45160
> Oops: 0002 [#1] DEBUG_PAGEALLOC
> last sysfs file: /sys/devices/virtual/net/mc0PyXBA/type
> CPU 0
> Pid: 5, comm: kworker/u:0 Not tainted 2.6.36-rc7-next-20101007+ #11 /Bochs
> RIP: 0010:[<ffffffff813020b6>]  [<ffffffff813020b6>] macvlan_stop+0x57/0x7d
> RSP: 0018:ffff88003f111c30  EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffff88003bdd1e60 RCX: 000000000000c100
> RDX: ffff88003ba453a0 RSI: ffff88003f111d70 RDI: ffffffff810300e5
> RBP: ffff88003f111c50 R08: ffff88003f111d70 R09: 00000000000000cc
> R10: 0000000000000001 R11: ffff88003f111ba0 R12: ffff88003bdd1800
> R13: ffff880039fec800 R14: ffff88003f111d70 R15: ffff88003ba06830
> FS:  0000000000000000(0000) GS:ffffffff8181b000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: ffff88003ba453a0 CR3: 000000003c284000 CR4: 00000000000006f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process kworker/u:0 (pid: 5, threadinfo ffff88003f110000, task
> ffff88003f0f20a0)
> Stack:
>   ffffffff81657a10 ffff88003bdd1800 ffffffff81657a10 ffff88003bb23800
> <0> ffff88003f111c70 ffffffff81362d09 ffff88003bdd1800 ffff88003f111cf0
> <0> ffff88003f111c90 ffffffff81362d31 ffff88003ba067c0 ffff88003bdd1800
> Call Trace:
>   [<ffffffff81362d09>] __dev_close+0x75/0x83
>   [<ffffffff81362d31>] dev_close+0x1a/0x3f
>   [<ffffffff81362e38>] rollback_registered_many+0xe2/0x21c
>   [<ffffffff81362f88>] unregister_netdevice_many+0x16/0x6d
>   [<ffffffff8136314d>] default_device_exit_batch+0xa7/0xbb
>   [<ffffffff8135db06>] ops_exit_list+0x4e/0x56
>   [<ffffffff8135e285>] cleanup_net+0xf5/0x195
>   [<ffffffff8103e084>] process_one_work+0x25d/0x3e7
>   [<ffffffff8103e027>] ? process_one_work+0x200/0x3e7
>   [<ffffffff8135e190>] ? cleanup_net+0x0/0x195
>   [<ffffffff8103e54a>] worker_thread+0x1b5/0x342
>   [<ffffffff8103e395>] ? worker_thread+0x0/0x342
>   [<ffffffff81041495>] kthread+0x7c/0x84
>   [<ffffffff810034f4>] kernel_thread_helper+0x4/0x10
>   [<ffffffff814389ba>] ? restore_args+0x0/0x30
>   [<ffffffff81041419>] ? kthread+0x0/0x84
>   [<ffffffff810034f0>] ? kernel_thread_helper+0x0/0x10
> Code: 00 00 02 74 0b 83 ce ff 4c 89 ef e8 ab eb 05 00 49 8b b4 24 a0 02
> 00 00 4c 89 ef e8 b9 52 06 00 48 8b 43 18 48 8b 53 20 48 85 c0 <48> 89
> 02 74 04 48 89 50 08 48 be 00 02 20 00 00 00 ad de 48 89
> RIP  [<ffffffff813020b6>] macvlan_stop+0x57/0x7d
>   RSP <ffff88003f111c30>
> CR2: ffff88003ba453a0
> ---[ end trace 05c41c2103816005 ]---
> BUG: unable to handle kernel paging request at fffffffffffffff8
> IP: [<ffffffff810410bf>] kthread_data+0xb/0x11
> PGD 180c067 PUD 180d067 PMD 0
> Oops: 0000 [#2] DEBUG_PAGEALLOC
> last sysfs file: /sys/devices/virtual/net/mc0PyXBA/type
> CPU 0
> Pid: 5, comm: kworker/u:0 Tainted: G      D
> 2.6.36-rc7-next-20101007+ #11 /Bochs
> RIP: 0010:[<ffffffff810410bf>]  [<ffffffff810410bf>] kthread_data+0xb/0x11
> RSP: 0018:ffff88003f111868  EFLAGS: 00010096
> RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff88003f111fd8
> RDX: ffff88003f0f20a0 RSI: 0000000000000000 RDI: ffff88003f0f20a0
> RBP: ffff88003f111868 R08: 0000000000000002 R09: 0000000000000001
> R10: 0000000000000246 R11: 09f911029d74e35b R12: 0000000000000000
> R13: ffff88003f111948 R14: ffff88003f0c60a0 R15: ffff88003f0f2218
> FS:  0000000000000000(0000) GS:ffffffff8181b000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: fffffffffffffff8 CR3: 000000003cb19000 CR4: 00000000000006f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process kworker/u:0 (pid: 5, threadinfo ffff88003f110000, task
> ffff88003f0f20a0)
> Stack:
>   ffff88003f111888 ffffffff8103d4e4 ffff88003f111888 ffff88003f0f2310
> <0> ffff88003f110010 ffff88003f0f20a0 ffff88003f111fd8 ffff88003f111fd8
> Call Trace:
>   [<ffffffff8103d4e4>] wq_worker_sleeping+0x10/0x76
>   [<ffffffff81435ffe>] schedule+0xf4/0x405
>   [<ffffffff8102ebc4>] do_exit+0x647/0x660
>   [<ffffffff81005ba0>] oops_end+0xb3/0xbb
>   [<ffffffff8101c6b8>] no_context+0x1f5/0x204
>   [<ffffffff8101c854>] __bad_area_nosemaphore+0x18d/0x1b0
>   [<ffffffff8101c885>] bad_area_nosemaphore+0xe/0x10
>   [<ffffffff8101cb52>] do_page_fault+0x16b/0x34d
>   [<ffffffff81300a85>] ? ei_set_multicast_list+0x1f/0x3d
>   [<ffffffff81437f46>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>   [<ffffffff81438b9f>] page_fault+0x1f/0x30
>   [<ffffffff810300e5>] ? local_bh_enable_ip+0xb7/0xbd
>   [<ffffffff813020b6>] ? macvlan_stop+0x57/0x7d
>   [<ffffffff81362d09>] __dev_close+0x75/0x83
>   [<ffffffff81362d31>] dev_close+0x1a/0x3f
>   [<ffffffff81362e38>] rollback_registered_many+0xe2/0x21c
>   [<ffffffff81362f88>] unregister_netdevice_many+0x16/0x6d
>   [<ffffffff8136314d>] default_device_exit_batch+0xa7/0xbb
>   [<ffffffff8135db06>] ops_exit_list+0x4e/0x56
>   [<ffffffff8135e285>] cleanup_net+0xf5/0x195
>   [<ffffffff8103e084>] process_one_work+0x25d/0x3e7
>   [<ffffffff8103e027>] ? process_one_work+0x200/0x3e7
>   [<ffffffff8135e190>] ? cleanup_net+0x0/0x195
>   [<ffffffff8103e54a>] worker_thread+0x1b5/0x342
>   [<ffffffff8103e395>] ? worker_thread+0x0/0x342
>   [<ffffffff81041495>] kthread+0x7c/0x84
>   [<ffffffff810034f4>] kernel_thread_helper+0x4/0x10
>   [<ffffffff814389ba>] ? restore_args+0x0/0x30
>   [<ffffffff81041419>] ? kthread+0x0/0x84
>   [<ffffffff810034f0>] ? kernel_thread_helper+0x0/0x10
> Code: 5c 41 5d 41 5e c9 c3 90 55 48 8b 04 25 40 a0 81 81 48 8b 80 18 02
> 00 00 48 89 e5 8b 40 f0 c9 c3 48 8b 87 18 02 00 00 55 48 89 e5 <48> 8b
> 40 f8 c9 c3 48 89 f0 c1 ee 06 55 89 f6 83 e0 3f 48 c1 e6
> RIP  [<ffffffff810410bf>] kthread_data+0xb/0x11
>   RSP <ffff88003f111868>
> CR2: fffffffffffffff8
> ---[ end trace 05c41c2103816006 ]---
> 
> 
> 
> Thanks
>    -- Daniel

I did the same setup without any tunnel modules loaded and then it almost worked 
except free-ing of the loopback interface :-(
"unregister_netdevice: waiting for lo to become free. Usage count = 4"

When adding a tunnel module (here ip6_tunnel) you'll have the crash

ex: 
/var/lib/lxc # ifconfig -a
ip6tnl0   Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  
          NOARP  MTU:1460  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback  
          LOOPBACK  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

 # ifconfig
 # ps
  PID USER       VSZ STAT COMMAND
    1 root     12412 S    /usr/lib64/lxc/lxc-init -- /var/bin/init
    2 root      4540 S    /bin/ash /var/bin/init
    6 root      4544 S    /bin/ash
   16 root      4544 R    ps
 # kill 2
 # ^D (exit of ns)
 # ------------[ cut here ]------------
WARNING: at /home/hans/evip/kvm/net-next-2.6/kernel/sysctl.c:1953 unregister_sysctl_table+0xc7/0xf9()
Hardware name: Bochs
Modules linked in: macvlan ip6_tunnel tunnel6 pcnet32 tg3 libphy
Pid: 5, comm: kworker/u:0 Not tainted 2.6.36-rc3 #2
Call Trace:
 [<ffffffff8103e281>] warn_slowpath_common+0x85/0x9d
 [<ffffffff8103e2b3>] warn_slowpath_null+0x1a/0x1c
 [<ffffffff81045e64>] unregister_sysctl_table+0xc7/0xf9
 [<ffffffff812c86a5>] neigh_sysctl_unregister+0x27/0x3f
 [<ffffffff81340c75>] addrconf_ifdown+0x415/0x45e
 [<ffffffff81341705>] addrconf_notify+0x756/0x7fe
 [<ffffffff812cacfb>] ? neigh_ifdown+0xc3/0xd4
 [<ffffffff81360eb3>] ? ip6mr_device_event+0x8d/0x9e
 [<ffffffff8105eddb>] notifier_call_chain+0x37/0x63
 [<ffffffff8105ee8b>] raw_notifier_call_chain+0x14/0x16
 [<ffffffff812c15c7>] call_netdevice_notifiers+0x4a/0x4f
 [<ffffffff812c1c1b>] rollback_registered_many+0x121/0x208
 [<ffffffff812c1d1d>] unregister_netdevice_many+0x1b/0x71
 [<ffffffffa0047244>] ip6_tnl_exit_net+0xa4/0xb8 [ip6_tunnel]
 [<ffffffff812bc941>] ? cleanup_net+0x0/0x198
 [<ffffffff812bc2cf>] ops_exit_list+0x2a/0x5b
 [<ffffffff812bca39>] cleanup_net+0xf8/0x198
 [<ffffffff810568c7>] process_one_work+0x2a2/0x44d
 [<ffffffff81056e35>] worker_thread+0x1db/0x34e
 [<ffffffff81056c5a>] ? worker_thread+0x0/0x34e
 [<ffffffff8105a030>] kthread+0x82/0x8a
 [<ffffffff81003954>] kernel_thread_helper+0x4/0x10
 [<ffffffff81059fae>] ? kthread+0x0/0x8a
 [<ffffffff81003950>] ? kernel_thread_helper+0x0/0x10
---[ end trace eb3bc950cf9a8748 ]---
unregister_netdevice: waiting for lo to become free. Usage count = 4
unregister_netdevice: waiting for lo to become free. Usage count = 4
unregister_netdevice: waiting for lo to become free. Usage count = 4

Regards 
Hans

> 
> > I added some printk's inn ipip.c  ipip_exit_net()
> > ...
> >          rtnl_lock();
> >          printk(KERN_ERR "ipip_exit_net(enter)\n");
> >          ipip_destroy_tunnels(ipn,&list);
> >          printk(KERN_ERR "ipip_exit_net(1)\n");
> >          unregister_netdevice_queue(ipn->fb_tunnel_dev,&list);
> >          printk(KERN_ERR "ipip_exit_net(2)\n");
> >          unregister_netdevice_many(&list);
> >          printk(KERN_ERR "ipip_exit_net(3)\n");
> >          rtnl_unlock();
> >          printk(KERN_ERR "ipip_exit_net(exit)\n");
> >
> >
> > Exit steps:
> > ===== Screen dump =====
> >
> >   # ifconfig eth0  0.0.0.0  down
> >   # ifconfig eth1  0.0.0.0  down
> >   # ifconfig lo  0.0.0.0  down
> >   # ip li de eth0
> >   # ip li de eth1
> >   # ifconfig -a
> > ip6tnl0   Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
> >            NOARP  MTU:1460  Metric:1
> >            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
> >            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
> >            collisions:0 txqueuelen:0
> >            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
> >
> > lo        Link encap:Local Loopback
> >            inet addr:127.0.0.1  Mask:255.0.0.0
> >            LOOPBACK  MTU:16436  Metric:1
> >            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
> >            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
> >            collisions:0 txqueuelen:0
> >            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
> >
> > sit0      Link encap:IPv6-in-IPv4
> >            NOARP  MTU:1480  Metric:1
> >            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
> >            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
> >            collisions:0 txqueuelen:0
> >            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
> >
> > tunl0     Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
> >            NOARP  MTU:1480  Metric:1
> >            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
> >            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
> >            collisions:0 txqueuelen:0
> >            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
> >
> >   # ps
> >    PID USER       VSZ STAT COMMAND
> >      1 root     12412 S    /usr/lib64/lxc/lxc-init -- /var/bin/init
> >      2 root      4540 S    /bin/ash /var/bin/init
> >      7 root      6640 S    inetd
> >      8 root      4544 S    /bin/ash
> >     26 root      4544 R    ps
> >   # lsmod
> > Module                  Size  Used by    Not tainted
> > macvlan                 8709  0
> > pcnet32                29549  0
> > tg3                   112093  0
> > libphy                 21043  1 tg3
> >   # kill 7 2
> >   # ps
> >    PID USER       VSZ STAT COMMAND
> >      1 root     12412 S    /usr/lib64/lxc/lxc-init -- /var/bin/init
> >      8 root      4544 S    /bin/ash
> >     28 root      4544 R    ps
> >   # exit  ( here is the exit from netns  )
> >   # ipip_exit_net(enter)
> > ipip_exit_net(1)
> > ipip_exit_net(2)
> > ------------[ cut here ]------------
> > WARNING: at /home/hans/evip/kvm/net-next-2.6/kernel/sysctl.c:1953 unregister_sysctl_table+0xc7/0xf9()
> > Hardware name: Bochs
> > Modules linked in: macvlan pcnet32 tg3 libphy
> > Pid: 5, comm: kworker/u:0 Not tainted 2.6.36-rc3+ #7
> > Call Trace:
> >   [<ffffffff8103e281>] warn_slowpath_common+0x85/0x9d
> >   [<ffffffff8103e2b3>] warn_slowpath_null+0x1a/0x1c
> >   [<ffffffff81045e64>] unregister_sysctl_table+0xc7/0xf9
> >   [<ffffffff812c86a5>] neigh_sysctl_unregister+0x27/0x3f
> >   [<ffffffff81342108>] addrconf_ifdown+0x415/0x45e
> >   [<ffffffff81342b98>] addrconf_notify+0x756/0x7fe
> >   [<ffffffff812cacfb>] ? neigh_ifdown+0xc3/0xd4
> >   [<ffffffff813622b3>] ? ip6mr_device_event+0x8d/0x9e
> >   [<ffffffff8105eddb>] notifier_call_chain+0x37/0x63
> >   [<ffffffff8105ee8b>] raw_notifier_call_chain+0x14/0x16
> >   [<ffffffff812c15c7>] call_netdevice_notifiers+0x4a/0x4f
> >   [<ffffffff812c1c1b>] rollback_registered_many+0x121/0x208
> >   [<ffffffff812c1d1d>] unregister_netdevice_many+0x1b/0x71
> >   [<ffffffff81324209>] ipip_exit_net+0xea/0x11a
> >   [<ffffffff812bc941>] ? cleanup_net+0x0/0x198
> >   [<ffffffff812bc2cf>] ops_exit_list+0x2a/0x5b
> >   [<ffffffff812bca39>] cleanup_net+0xf8/0x198
> >   [<ffffffff810568c7>] process_one_work+0x2a2/0x44d
> >   [<ffffffff81056e35>] worker_thread+0x1db/0x34e
> >   [<ffffffff81056c5a>] ? worker_thread+0x0/0x34e
> >   [<ffffffff8105a030>] kthread+0x82/0x8a
> >   [<ffffffff81003954>] kernel_thread_helper+0x4/0x10
> >   [<ffffffff81059fae>] ? kthread+0x0/0x8a
> >   [<ffffffff81003950>] ? kernel_thread_helper+0x0/0x10
> > ---[ end trace 939b5185219f32e7 ]---
> > ipip_exit_net(3)
> > ipip_exit_net(exit)
> > unregister_netdevice: waiting for lo to become free. Usage count = 4
> > unregister_netdevice: waiting for lo to become free. Usage count = 4
> > unregister_netdevice: waiting for lo to become free. Usage count = 4
> > ....
> > ...
> > ===== End of screen dump =====
> >
> > lxc conf file:
> > # Container with network virtualized using the vlan device driver
> > # Local eth0 uplink
> > lxc.utsname = fee_0
> > lxc.network.type = macvlan
> > lxc.network.flags = up
> > lxc.network.link = eth1
> > lxc.network.hwaddr = 00:00:04:01:01:01
> > lxc.network.ipv4 = 192.168.1.21/24
> > lxc.network.ipv6 = 2003::2:1:1/96
> > # local eth1 downlink - to the RS farm
> > lxc.network.type = macvlan
> > lxc.network.flags = up
> > lxc.network.link = eth0
> > lxc.network.hwaddr = 00:00:03:01:01:01
> > lxc.network.ipv4 = 192.168.0.21/24
> > lxc.network.ipv6 = 2003::1:1:1/96
> > lxc.mount.entry = /var/lib/lxc/fee_0/var /var none rw,bind 0 0
> >
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
