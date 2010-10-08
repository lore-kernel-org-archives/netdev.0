From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Fri, 8 Oct 2010 14:28:37 +0200
Message-ID: <201010081428.37639.hans.schillstrom@ericsson.com>
References: <201010071048.12817.hans.schillstrom@ericsson.com> <4CAEFE2C.3010007@free.fr> <201010081353.28056.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:57527 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360Ab0JHM2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 08:28:39 -0400
In-Reply-To: <201010081353.28056.hans.schillstrom@ericsson.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,
Any advice how to trace this down ?
This rollback_registered_many() seems to have on the lists before...
All IPv4 and IPv6 tunnels causes this crash, all you have to do is load the tunnel module(s)
enter a new ns and exit from it.

Have not tested any more devices than tunnels, 
I did an "ip link delete" on my macvlans before exiting the ns.


snip
>  # ------------[ cut here ]------------
> WARNING: at /home/hans/evip/kvm/net-next-2.6/kernel/sysctl.c:1953 unregister_sysctl_table+0xc7/0xf9()
> Hardware name: Bochs
> Modules linked in: macvlan ip6_tunnel tunnel6 pcnet32 tg3 libphy
> Pid: 5, comm: kworker/u:0 Not tainted 2.6.36-rc3 #2
> Call Trace:
>  [<ffffffff8103e281>] warn_slowpath_common+0x85/0x9d
>  [<ffffffff8103e2b3>] warn_slowpath_null+0x1a/0x1c
>  [<ffffffff81045e64>] unregister_sysctl_table+0xc7/0xf9
>  [<ffffffff812c86a5>] neigh_sysctl_unregister+0x27/0x3f
>  [<ffffffff81340c75>] addrconf_ifdown+0x415/0x45e
>  [<ffffffff81341705>] addrconf_notify+0x756/0x7fe
>  [<ffffffff812cacfb>] ? neigh_ifdown+0xc3/0xd4
>  [<ffffffff81360eb3>] ? ip6mr_device_event+0x8d/0x9e
>  [<ffffffff8105eddb>] notifier_call_chain+0x37/0x63
>  [<ffffffff8105ee8b>] raw_notifier_call_chain+0x14/0x16
>  [<ffffffff812c15c7>] call_netdevice_notifiers+0x4a/0x4f
>  [<ffffffff812c1c1b>] rollback_registered_many+0x121/0x208
>  [<ffffffff812c1d1d>] unregister_netdevice_many+0x1b/0x71
>  [<ffffffffa0047244>] ip6_tnl_exit_net+0xa4/0xb8 [ip6_tunnel]
>  [<ffffffff812bc941>] ? cleanup_net+0x0/0x198
>  [<ffffffff812bc2cf>] ops_exit_list+0x2a/0x5b
>  [<ffffffff812bca39>] cleanup_net+0xf8/0x198
>  [<ffffffff810568c7>] process_one_work+0x2a2/0x44d
>  [<ffffffff81056e35>] worker_thread+0x1db/0x34e
>  [<ffffffff81056c5a>] ? worker_thread+0x0/0x34e
>  [<ffffffff8105a030>] kthread+0x82/0x8a
>  [<ffffffff81003954>] kernel_thread_helper+0x4/0x10
>  [<ffffffff81059fae>] ? kthread+0x0/0x8a
>  [<ffffffff81003950>] ? kernel_thread_helper+0x0/0x10
> ---[ end trace eb3bc950cf9a8748 ]---
> unregister_netdevice: waiting for lo to become free. Usage count = 4
> unregister_netdevice: waiting for lo to become free. Usage count = 4
> unregister_netdevice: waiting for lo to become free. Usage count = 4


-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
