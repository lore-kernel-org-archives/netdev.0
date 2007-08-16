From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8895] New: An ioctl to delete an ipv6 tunnel
 leads to a kernel panic
Date: Thu, 16 Aug 2007 13:09:21 -0700
Message-ID: <20070816130921.a0f60e31.akpm@linux-foundation.org>
References: <bug-8895-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, clowncoder@clownix.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55256 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752571AbXHPUJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 16:09:31 -0400
In-Reply-To: <bug-8895-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Aug 2007 12:24:05 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8895
> 
>            Summary: An ioctl to delete an ipv6 tunnel leads to a kernel
>                     panic
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22.3 and also 2.6.21.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: clowncoder@clownix.net
> 
> 
> Most recent kernel where this bug did not occur: ?
> Distribution: lfs and fedora
> Hardware Environment:user mode linux and vmware
> Software Environment:an evolution of mip6d (ip mobility daemon) 
> Problem Description: The mip6d HA was modified to make a redondancy evolution,
> when an HA is interrupted, the other takes over, this leads to some
> creation/deletion of routes and tunnels.
> Note: The HA ip address known by the mobile (MR) stays the same, the slave HA
> takes it with an override neighbor advertisement message. So the tunnel between
> the mobile router and the HA(s) keep the same end adresses. 
> The problem occurs when a Ctrl C is done on the master HA, the slave takes over
> but sometimes, the master gets a kernel panic. 
> 
> Here is the dump of the master:
> 
> ICMPv6 NA: someone advertises our address on eth1!
> Slab corruption: ip6_dst_cache start=0867ed00, len=224
> Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
> Last user: [<08157c46>](dst_destroy+0x79/0xad)
> 0a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b 6b
> Prev obj: start=0867ec08, len=224
> Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
> Last user: [<08157b05>](dst_alloc+0x26/0x62)
> 000: 00 00 00 00 00 00 00 00 00 00 00 00 40 41 6f 08
> 010: 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00
> Next obj: start=0867edf8, len=224
> Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
> Last user: [<08157b05>](dst_alloc+0x26/0x62)
> 000: 00 00 00 00 00 00 00 00 00 00 00 00 60 41 99 0b
> 010: 00 00 ff ff 00 00 00 00 7d df ff ff 00 00 00 00
> BUG: failure at net/ipv6/ip6_fib.c:1151/fib6_del_route()!
> Kernel panic - not syncing: BUG!
> 
> EIP: 0073:[<080e10b4>] CPU: 0 Not tainted ESP: 007b:bf6d0398 EFLAGS: 00000246
>     Not tainted
> EAX: ffffffda EBX: 00000006 ECX: 000089f2 EDX: bf6d0428
> ESI: 00000000 EDI: 0815c150 EBP: bf6d0458 DS: 007b ES: 007b
> 08a37ae4:  [<0806ba80>] show_regs+0xb4/0xb9
> 08a37b10:  [<0805a044>] panic_exit+0x25/0x3f
> 08a37b24:  [<0807b088>] notifier_call_chain+0x21/0x46
> 08a37b44:  [<0807b123>] __atomic_notifier_call_chain+0x17/0x19
> 08a37b60:  [<0807b13a>] atomic_notifier_call_chain+0x15/0x17
> 08a37b7c:  [<0806fff6>] panic+0x52/0xdd
> 08a37b9c:  [<081bb8d2>] fib6_del_route+0x112/0x175
> 08a37bc0:  [<081bb9c6>] fib6_del+0x91/0xcc
> 08a37bdc:  [<081bbba8>] fib6_clean_node+0x26/0x73
> 08a37bf4:  [<081bba8a>] fib6_walk_continue+0x89/0x11f
> 08a37c04:  [<081bbb57>] fib6_walk+0x37/0x62
> 08a37c18:  [<081bbc23>] fib6_clean_tree+0x2e/0x31
> 08a37c4c:  [<081bbc83>] fib6_prune_clones+0x15/0x1a
> 08a37c64:  [<081bb9de>] fib6_del+0xa9/0xcc
> 08a37c7c:  [<081bbba8>] fib6_clean_node+0x26/0x73
> 08a37c94:  [<081bba8a>] fib6_walk_continue+0x89/0x11f
> 08a37ca4:  [<081bbb57>] fib6_walk+0x37/0x62
> 08a37cb8:  [<081bbc23>] fib6_clean_tree+0x2e/0x31
> 08a37cec:  [<081bbc51>] fib6_clean_all+0x2b/0x48
> 08a37d10:  [<081b9d15>] rt6_ifdown+0x12/0x17
> 08a37d24:  [<081b56e3>] addrconf_ifdown+0x54/0x275
> 08a37d40:  [<081b562d>] addrconf_notify+0x18a/0x1ec
> 08a37d5c:  [<0807b088>] notifier_call_chain+0x21/0x46
> 08a37d7c:  [<0807b257>] __raw_notifier_call_chain+0x17/0x19
> 08a37d98:  [<0807b26e>] raw_notifier_call_chain+0x15/0x17
> 08a37db4:  [<08153c18>] dev_close+0x5e/0x68
> 08a37dcc:  [<0815619e>] unregister_netdevice+0xb7/0x1bc
> 08a37ddc:  [<081d75d7>] ip6_tnl_ioctl+0x1a9/0x1d2
> 08a37e34:  [<0815578c>] dev_ifsioc+0x3b9/0x3d9
> 08a37e54:  [<08155a71>] dev_ioctl+0x2c5/0x300
> 08a37e9c:  [<0814b435>] sock_ioctl+0x230/0x243
> 08a37ebc:  [<080b0801>] do_ioctl+0x21/0x5a
> 08a37ed8:  [<080b0ba8>] vfs_ioctl+0x1ec/0x209
> 08a37f00:  [<080b0bf3>] sys_ioctl+0x2e/0x4b
> 08a37f28:  [<0805a7ae>] handle_syscall+0x86/0xa0
> 08a37f74:  [<08068d00>] handle_trap+0xd8/0xe1
> 08a37f90:  [<080690f3>] userspace+0x138/0x180
> 08a37fdc:  [<0805a4d1>] fork_handler+0x74/0x7c
> 08a37ffc:  [<a55a5a5a>] 0xa55a5a5a
> 
> 
> Program received signal SIGSEGV, Segmentation fault.
> 0xb7e58761 in abort () from /lib/tls/i686/cmov/libc.so.6
> (gdb)
> 
> 
> 
> Program received signal SIGSEGV, Segmentation fault.
> 0xb7e58761 in abort () from /lib/tls/i686/cmov/libc.so.6
> (gdb) bt
> #0  0xb7e58761 in abort () from /lib/tls/i686/cmov/libc.so.6
> #1  0x080676df in os_dump_core () at arch/um/os-Linux/util.c:109
> #2  0x0805a05a in panic_exit (self=0x825d674, unused1=0, unused2=0x8277ee0)
>     at arch/um/kernel/um_arch.c:477
> #3  0x0807b088 in notifier_call_chain (nl=0x8277ec0, val=0, v=0x8277ee0,
>     nr_to_call=-2, nr_calls=0x0) at kernel/sys.c:163
> #4  0x0807b123 in __atomic_notifier_call_chain (nh=0x8277ec0, val=0,
>     v=0x8277ee0, nr_to_call=-1, nr_calls=0x0) at kernel/sys.c:256
> #5  0x0807b13a in atomic_notifier_call_chain (nh=0x8277ec0, val=0, v=0x8277ee0)
>     at kernel/sys.c:266
> #6  0x0806fff6 in panic (fmt=0x8217b25 "BUG!") at kernel/panic.c:99
> #7  0x081bb8d2 in fib6_del_route (fn=0x0, rtp=0x8abd568, info=0x0)
>     at net/ipv6/ip6_fib.c:1151
> #8  0x081bb9c6 in fib6_del (rt=0x867ed00, info=0x0) at net/ipv6/ip6_fib.c:1193
> #9  0x081bbba8 in fib6_clean_node (w=0x8a37c20) at net/ipv6/ip6_fib.c:1322
> #10 0x081bba8a in fib6_walk_continue (w=0x8a37c20) at net/ipv6/ip6_fib.c:1264
> #11 0x081bbb57 in fib6_walk (w=0x8a37c20) at net/ipv6/ip6_fib.c:1306
> #12 0x081bbc23 in fib6_clean_tree (root=0x8abd440,
>     func=0x81bbc88 <fib6_prune_clone>, prune=1, arg=0x867edf8)
>     at net/ipv6/ip6_fib.c:1360
> #13 0x081bbc83 in fib6_prune_clones (fn=0x8abd440, rt=0x867edf8)
>     at net/ipv6/ip6_fib.c:1394
> #14 0x081bb9de in fib6_del (rt=0x867edf8, info=0x0) at net/ipv6/ip6_fib.c:1184
> #15 0x081bbba8 in fib6_clean_node (w=0x8a37cc0) at net/ipv6/ip6_fib.c:1322
> #16 0x081bba8a in fib6_walk_continue (w=0x8a37cc0) at net/ipv6/ip6_fib.c:1264
> #17 0x081bbb57 in fib6_walk (w=0x8a37cc0) at net/ipv6/ip6_fib.c:1306
> #18 0x081bbc23 in fib6_clean_tree (root=0x8272dac,
>     func=0x81b9ce2 <fib6_ifdown>, prune=0, arg=0xb994160)
>     at net/ipv6/ip6_fib.c:1360
> #19 0x081bbc51 in fib6_clean_all (func=0x81b9ce2 <fib6_ifdown>, prune=0,
>     arg=0xb994160) at net/ipv6/ip6_fib.c:1372
> #20 0x081b9d15 in rt6_ifdown (dev=0xb994160) at net/ipv6/route.c:1944
> #21 0x081b56e3 in addrconf_ifdown (dev=0xb994160, how=0)
>     at net/ipv6/addrconf.c:2400
> #22 0x081b562d in addrconf_notify (this=0x82721c4, event=2, data=0xb994160)
>     at net/ipv6/addrconf.c:2358
> #23 0x0807b088 in notifier_call_chain (nl=0x8283e94, val=2, v=0xb994160,
>     nr_to_call=-10, nr_calls=0x0) at kernel/sys.c:163
> #24 0x0807b257 in __raw_notifier_call_chain (nh=0x8283e94, val=2, v=0xb994160,
>     nr_to_call=-1, nr_calls=0x0) at kernel/sys.c:451
> #25 0x0807b26e in raw_notifier_call_chain (nh=0x8283e94, val=2, v=0xb994160)
>     at kernel/sys.c:459
> #26 0x08153c18 in dev_close (dev=0xb994160) at net/core/dev.c:1015
> #27 0x0815619e in unregister_netdevice (dev=0xb994160) at net/core/dev.c:3451
> #28 0x081d75d7 in ip6_tnl_ioctl (dev=0xb994160, ifr=0x8a37e6c, cmd=35314)
>     at net/ipv6/ip6_tunnel.c:1266
> #29 0x0815578c in dev_ifsioc (ifr=0x8a37e6c, cmd=35314) at net/core/dev.c:2816
> #30 0x08155a71 in dev_ioctl (cmd=35314, arg=0xbf6d0428) at net/core/dev.c:2995
> #31 0x0814b435 in sock_ioctl (file=0x832a348, cmd=35314, arg=3211592744)
>     at net/socket.c:909
> #32 0x080b0801 in do_ioctl (filp=0x16, cmd=35314, arg=3211592744)
> ---Type <return> to continue, or q <return> to quit---
> 
>     at fs/ioctl.c:30
> #33 0x080b0ba8 in vfs_ioctl (filp=0x832a348, fd=6, cmd=6, arg=3211592744)
>     at fs/ioctl.c:159
> #34 0x080b0bf3 in sys_ioctl (fd=6, cmd=35314, arg=3211592744) at fs/ioctl.c:179
> #35 0x0805a7ae in handle_syscall (r=0x867a894)
>     at arch/um/kernel/skas/syscall.c:38
> #36 0x08068d00 in handle_trap (pid=10640, regs=0x867a894, local_using_sysemu=2)
>     at arch/um/os-Linux/skas/process.c:173
> #37 0x080690f3 in userspace (regs=0x867a894)
>     at arch/um/os-Linux/skas/process.c:330
> #38 0x0805a4d1 in fork_handler () at arch/um/kernel/skas/process.c:96
> #39 0xa55a5a5a in ?? ()
> (gdb)
> 
> 
> 
> Steps to reproduce:
> 
> 
