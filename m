From: Petr =?iso-8859-2?Q?=A9tetiar?= <ynezz@true.cz>
Subject: Re: [PATCH] ep93xx-eth: convert to phylib
Date: Thu, 9 Jun 2011 22:30:59 +0200
Message-ID: <20110609203059.GZ16318@ibawizard.net>
References: <201106051957.36492.florian@openwrt.org> <201106052029.24742.f.fainelli@gmail.com>
Reply-To: Petr =?iso-8859-2?Q?=A9tetiar?= <ynezz@true.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Valerio Riedel <hvr@gnu.org>,
	Mika Westerberg <mika.westerberg@iki.fi>, davem@davemloft.net,
	hsweeten@visionengravers.com, ryan@bluewatersys.com,
	Lennert Buytenhek <kernel@wantstofly.org>,
	linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ibawizard.net ([82.208.49.253]:58588 "EHLO
	mengele.ibawizard.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755887Ab1FIUbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 16:31:07 -0400
Content-Disposition: inline
In-Reply-To: <201106052029.24742.f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> [2011-06-05 20:29:24]:

> On Sunday 05 June 2011 19:57:36 Florian Fainelli wrote:
> > ep93xx-eth lacked support for monitoring link status changes, with this
> > patch, link changes are now watched and reported correctly.
> > 
> > Signed-off-by: Florian Fainelli <florian@openwrt.org>
> > ---
> 
> I just stumbled upon: http://www.mail-
> archive.com/netdev@vger.kernel.org/msg62549.html
> which does not seem to have been merged.
> 
> I will respin my patch with Herbert's changes

Hi,

just FYI, I wanted to test recent Mika's DMA/ep93xx_eth fixes, so I've added
this patch also and it oopsed. If I revert this patch, it seems to work so
far. You can find the whole patchset I've been testing on the GitHub[1]. I've
tested it on ts-7250 and ts-7300, the oops is same. Here's the oops:

	ep93xx-eth version 0.1 loading
	ep93xx_eth_mii: probed
	ep93xx_eth:ep93xx_mii_probe: no PHY found
	ep93xx-eth ep93xx-eth: failed to probe MII bus
	------------[ cut here ]------------
	WARNING: at net/core/dev.c:5133 rollback_registered_many+0x90/0x2d4()
	Modules linked in:
	Backtrace: 
	[<c0027e78>] (dump_backtrace+0x0/0x10c) from [<c0263764>] (dump_stack+0x18/0x1c)
	 r6:0000140d r5:c01cd558 r4:00000000 r3:00000000
	[<c026374c>] (dump_stack+0x0/0x1c) from [<c0037a48>] (warn_slowpath_common+0x50/0x68)
	[<c00379f8>] (warn_slowpath_common+0x0/0x68) from [<c0037a84>] (warn_slowpath_null+0x24/0x2c)
	 r8:00100100 r7:00200200 r6:cf01bda0 r5:cf01bdf8 r4:cf0b6800
	r3:00000009
	[<c0037a60>] (warn_slowpath_null+0x0/0x2c) from [<c01cd558>] (rollback_registered_many+0x90/0x2d4)
	[<c01cd4c8>] (rollback_registered_many+0x0/0x2d4) from [<c01cd834>] (rollback_registered+0x30/0x48)
	 r8:00000027 r7:cf0b6800 r6:cf0b6b40 r5:00000000 r4:cf0b6800
	r3:cf0b6858
	[<c01cd804>] (rollback_registered+0x0/0x48) from [<c01cd8a8>] (unregister_netdevice_queue+0x5c/0xa8)
	[<c01cd84c>] (unregister_netdevice_queue+0x0/0xa8) from [<c01cd914>] (unregister_netdev+0x20/0x28)
	 r5:c030f638 r4:cf0b6800
	[<c01cd8f4>] (unregister_netdev+0x0/0x28) from [<c01b03a0>] (ep93xx_eth_remove+0x34/0x90)
	 r4:cf0b6800 r3:cf039180
	[<c01b036c>] (ep93xx_eth_remove+0x0/0x90) from [<c01b1348>] (ep93xx_eth_probe+0x218/0x43c)
	 r5:c030f630 r4:ffffffed
	[<c01b1130>] (ep93xx_eth_probe+0x0/0x43c) from [<c018b7b8>] (platform_drv_probe+0x1c/0x20)
	[<c018b79c>] (platform_drv_probe+0x0/0x20) from [<c018a5d0>] (driver_probe_device+0x8c/0x198)
	[<c018a544>] (driver_probe_device+0x0/0x198) from [<c018a770>] (__driver_attach+0x94/0x98)
	 r8:c0017d40 r7:00000000 r6:c030f66c r5:c032080c r4:c030f638
	r3:00000000
	[<c018a6dc>] (__driver_attach+0x0/0x98) from [<c018974c>] (bus_for_each_dev+0x60/0x88)
	 r6:00000000 r5:c018a6dc r4:c032080c r3:c018a6dc
	[<c01896ec>] (bus_for_each_dev+0x0/0x88) from [<c018a2a8>] (driver_attach+0x20/0x28)
	 r6:cf0ae860 r5:c031d4e0 r4:c032080c
	[<c018a288>] (driver_attach+0x0/0x28) from [<c0189e94>] (bus_add_driver+0xa4/0x240)
	[<c0189df0>] (bus_add_driver+0x0/0x240) from [<c018aae0>] (driver_register+0x80/0x144)
	[<c018aa60>] (driver_register+0x0/0x144) from [<c018baf0>] (platform_driver_register+0x4c/0x60)
	 r8:c0017d40 r7:00000000 r6:cf01a000 r5:c0325960 r4:c001ee3c
	r3:00000000
	[<c018baa4>] (platform_driver_register+0x0/0x60) from [<c0017d5c>] (ep93xx_eth_init_module+0x1c/0x28)
	[<c0017d40>] (ep93xx_eth_init_module+0x0/0x28) from [<c00244f0>] (do_one_initcall+0x3c/0x17c)
	[<c00244b4>] (do_one_initcall+0x0/0x17c) from [<c0008a04>] (kernel_init+0x9c/0x140)
	[<c0008968>] (kernel_init+0x0/0x140) from [<c003b158>] (do_exit+0x0/0x710)
	 r5:c0008968 r4:00000000
	---[ end trace edc3043606fef430 ]---
	network todo 'eth%d' but state 0
	Backtrace: 
	[<c0027e78>] (dump_backtrace+0x0/0x10c) from [<c0263764>] (dump_stack+0x18/0x1c)
	 r6:cf0b6b40 r5:c0312560 r4:cf0b6800 r3:00000000
	[<c026374c>] (dump_stack+0x0/0x1c) from [<c01d10e4>] (netdev_run_todo+0x2dc/0x33c)
	[<c01d0e08>] (netdev_run_todo+0x0/0x33c) from [<c01dd824>] (rtnl_unlock+0x10/0x14)
	[<c01dd814>] (rtnl_unlock+0x0/0x14) from [<c01cd918>] (unregister_netdev+0x24/0x28)
	[<c01cd8f4>] (unregister_netdev+0x0/0x28) from [<c01b03a0>] (ep93xx_eth_remove+0x34/0x90)
	 r4:cf0b6800 r3:cf039180
	[<c01b036c>] (ep93xx_eth_remove+0x0/0x90) from [<c01b1348>] (ep93xx_eth_probe+0x218/0x43c)
	 r5:c030f630 r4:ffffffed
	[<c01b1130>] (ep93xx_eth_probe+0x0/0x43c) from [<c018b7b8>] (platform_drv_probe+0x1c/0x20)
	[<c018b79c>] (platform_drv_probe+0x0/0x20) from [<c018a5d0>] (driver_probe_device+0x8c/0x198)
	[<c018a544>] (driver_probe_device+0x0/0x198) from [<c018a770>] (__driver_attach+0x94/0x98)
	 r8:c0017d40 r7:00000000 r6:c030f66c r5:c032080c r4:c030f638
	r3:00000000
	[<c018a6dc>] (__driver_attach+0x0/0x98) from [<c018974c>] (bus_for_each_dev+0x60/0x88)
	 r6:00000000 r5:c018a6dc r4:c032080c r3:c018a6dc
	[<c01896ec>] (bus_for_each_dev+0x0/0x88) from [<c018a2a8>] (driver_attach+0x20/0x28)
	 r6:cf0ae860 r5:c031d4e0 r4:c032080c
	[<c018a288>] (driver_attach+0x0/0x28) from [<c0189e94>] (bus_add_driver+0xa4/0x240)
	[<c0189df0>] (bus_add_driver+0x0/0x240) from [<c018aae0>] (driver_register+0x80/0x144)
	[<c018aa60>] (driver_register+0x0/0x144) from [<c018baf0>] (platform_driver_register+0x4c/0x60)
	 r8:c0017d40 r7:00000000 r6:cf01a000 r5:c0325960 r4:c001ee3c
	r3:00000000
	[<c018baa4>] (platform_driver_register+0x0/0x60) from [<c0017d5c>] (ep93xx_eth_init_module+0x1c/0x28)
	[<c0017d40>] (ep93xx_eth_init_module+0x0/0x28) from [<c00244f0>] (do_one_initcall+0x3c/0x17c)
	[<c00244b4>] (do_one_initcall+0x0/0x17c) from [<c0008a04>] (kernel_init+0x9c/0x140)
	[<c0008968>] (kernel_init+0x0/0x140) from [<c003b158>] (do_exit+0x0/0x710)
	 r5:c0008968 r4:00000000
	Unable to handle kernel NULL pointer dereference at virtual address 00000000
	pgd = c0004000
	[00000000] *pgd=00000000
	Internal error: Oops: 5 [#1] PREEMPT
	Modules linked in:
	CPU: 0    Tainted: G        W    (3.0.0-rc2+ #35)
	PC is at ep93xx_free_buffers+0x24/0xd4
	LR is at ep93xx_eth_remove+0x5c/0x90
	pc : [<c01b02bc>]    lr : [<c01b03c8>]    psr: 80000013
	sp : cf01be20  ip : cf01be40  fp : cf01be3c
	r10: 00000080  r9 : c0325bc8  r8 : 00000027
	r7 : c030f638  r6 : cf0b6b40  r5 : cf0b6b54  r4 : 00000000
	r3 : 00000000  r2 : 00000014  r1 : 00000800  r0 : cf0b6b40
	Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
	Control: c000717f  Table: 00004000  DAC: 00000017
	Process swapper (pid: 1, stack limit = 0xcf01a270)
	Stack: (0xcf01be20 to 0xcf01c000)
	be20: cf0b6800 cf0b6b40 cf0b6b40 cf0b6800 cf01be54 cf01be40 c01b03c8 c01b02a8
	be40: ffffffed c030f630 cf01be94 cf01be58 c01b1348 c01b037c 00000000 c032080c
	be60: c0017d40 c030f638 cf01be84 c030f638 c0340bd0 c030f638 c032080c c0017d40
	be80: 00000000 00000000 cf01bea4 cf01be98 c018b7b8 c01b1140 cf01becc cf01bea8
	bea0: c018a5d0 c018b7ac 00000000 c030f638 c032080c c030f66c 00000000 c0017d40
	bec0: cf01beec cf01bed0 c018a770 c018a554 c018a6dc c032080c c018a6dc 00000000
	bee0: cf01bf14 cf01bef0 c018974c c018a6ec cf02ebf8 cf0391b0 c01576c4 c032080c
	bf00: c031d4e0 cf0ae860 cf01bf24 cf01bf18 c018a2a8 c01896fc cf01bf54 cf01bf28
	bf20: c0189e94 c018a298 c02ce24c cf01bf38 c032080c c0325960 cf01a000 00000000
	bf40: c0017d40 00000000 cf01bf7c cf01bf58 c018aae0cf01bfe0 c0008a04 c00244c4
	bfe0: 00000000 c0008968 00000000 cf01bff8 c003b158 c0008978 e3a0105e e3a02030
	Backtrace: 
	[<c01b0298>] (ep93xx_free_buffers+0x0/0xd4) from [<c01b03c8>] (ep93xx_eth_remove+0x5c/0x90)
	 r7:cf0b6800 r6:cf0b6b40 r5:cf0b6b40 r4:cf0b6800
	[<c01b036c>] (ep93xx_eth_remove+0x0/0x90) from [<c01b1348>] (ep93xx_eth_probe+0x218/0x43c)
	 r5:c030f630 r4:ffffffed
	[<c01b1130>] (ep93xx_eth_probe+0x0/0x43c) from [<c018b7b8>] (platform_drv_probe+0x1c/0x20)
	[<c018b79c>] (platform_drv_probe+0x0/0x20) from [<c018a5d0>] (driver_probe_device+0x8c/0x198)
	[<c018a544>] (driver_probe_device+0x0/0x198) from [<c018a770>] (__driver_attach+0x94/0x98)
	 r8:c0017d40 r7:00000000 r6:c030f66c r5:c032080c r4:c030f638
	r3:00000000
	[<c018a6dc>] (__driver_attach+0x0/0x98) from [<c018974c>] (bus_for_each_dev+0x60/0x88)
	 r6:00000000 r5:c018a6dc r4:c032080c r3:c018a6dc
	[<c01896ec>] (bus_for_each_dev+0x0/0x88) from [<c018a2a8>] (driver_attach+0x20/0x28)
	 r6:cf0ae860 r5:c031d4e0 r4:c032080c
	[<c018a288>] (driver_attach+0x0/0x28) from [<c0189e94>] (bus_add_driver+0xa4/0x240)
	[<c0189df0>] (bus_add_driver+0x0/0x240) from [<c018aae0>] (driver_register+0x80/0x144)
	[<c018aa60>] (driver_register+0x0/0x144) from [<c018baf0>] (platform_driver_register+0x4c/0x60)
	 r8:c0017d40 r7:00000000 r6:cf01a000 r5:c0325960 r4:c001ee3c
	r3:00000000
	[<c018baa4>] (platform_driver_register+0x0/0x60) from [<c0017d5c>] (ep93xx_eth_init_module+0x1c/0x28)
	[<c0017d40>] (ep93xx_eth_init_module+0x0/0x28) from [<c00244f0>] (do_one_initcall+0x3c/0x17c)
	[<c00244b4>] (do_one_initcall+0x0/0x17c) from [<c0008a04>] (kernel_init+0x9c/0x140)
	[<c0008968>] (kernel_init+0x0/0x140) from [<c003b158>] (do_exit+0x0/0x710)
	 r5:c0008968 r4:00000000
	Code: e2805014 e3a04000 e5963010 e3a01b02 (e7933184) 
	---[ end trace edc3043606fef431 ]---
	Kernel panic - not syncing: Attempted to kill init!
	Backtrace: 
	[<c0027e78>] (dump_backtrace+0x0/0x10c) from [<c0263764>] (dump_stack+0x18/0x1c)
	 r6:00000000 r5:c0312c40 r4:c0325cc0 r3:00000002
	[<c026374c>] (dump_stack+0x0/0x1c) from [<c02637d0>] (panic+0x68/0x198)
	[<c0263768>] (panic+0x0/0x198) from [<c003b7cc>] (do_exit+0x674/0x710)
	 r3:c0312c40 r2:c003b754 r1:cf01a000 r0:c02cf148
	 r7:cf019be0
	[<c003b158>] (do_exit+0x0/0x710) from [<c00284e4>] (die+  cf0b6b40 00000800
	bde0: 00000014 00000000 00000000 cf0b6b54 cf0b6b40 c030f638 00000027 c0325bc8
	be00: 00000080 cf01be3c cf01be40 cf01be20 c01b03c8 c01b02bc 80000013 ffffffff
	 r8:00000027 r7:c030f638 r6:cf0b6b40 r5:cf01be0c r4:ffffffff
	[<c01b0298>] (ep93xx_free_buffers+0x0/0xd4) from [<c01b03c8>] (ep93xx_eth_remove+0x5c/0x90)
	 r7:cf0b6800 r6:cf0b6b40 r5:cf0b6b40 r4:cf0b6800
	[<c01b036c>] (ep93xx_eth_remove+0x0/0x90) from [<c01b1348>] (ep93xx_eth_probe+0x218/0x43c)
	 r5:c030f630 r4:ffffffed
	[<c01b1130>] (ep93xx_eth_probe+0x0/0x43c) from [<c018b7b8>] (platform_drv_probe+0x1c/0x20)
	[<c018b79c>] (platform_drv_probe+0x0/0x20) from [<c018a5d0>] (driver_probe_device+0x8c/0x198)
	[<c018a544>] (driver_probe_device+0x0/0x198) from [<c018a770>] (__driver_attach+0x94/0x98)
	 r8:c0017d40 r7:00000000 r6:c030f66c r5:c032080c r4:c030f638
	r3:00000000
	[<c018a6dc>] (__driver_attach+0x0/0x98) from [<c018974c>] (bus_for_each_dev+0x60/0x88)
	 r6:00000000 r5:c018a6dc r4:c032080c r3:c018a6dc
	[<c01896ec>] (bus_for_each_dev+0x0/0x88) from [<c018a2a8>] (driver_attach+0x20/0x28)
	 r6:cf0ae860 r5:c031d4e0 r4:c032080c
	[<c018a288>] (driver_attach+0x0/0x28) from [<c0189e94>] (bus_add_driver+0xa4/0x240)
	[<c0189df0>] (bus_add_driver+0x0/0x240) from [<c018aae0>] (driver_register+0x80/0x144)
	[<c018aa60>] (driver_register+0x0/0x144) from [<c018baf0>] (platform_driver_register+0x4c/0x60)
	 r8:c0017d40 r7:00000000 r6:cf01a000 r5:c0325960 r4:c001ee3c
	r3:00000000
	[<c018baa4>] (platform_driver_register+0x0/0x60) from [<c0017d5c>] (ep93xx_eth_init_module+0x1c/0x28)
	[<c0017d40>] (ep93xx_eth_init_module+0x0/0x28) from [<c00244f0>] (do_one_initcall+0x3c/0x17c)
	[<c00244b4>] (do_one_initcall+0x0/0x17c) from [<c0008a04>] (kernel_init+0x9c/0x140)
	[<c0008968>] (kernel_init+0x0/0x140) from [<c003b158>] (do_exit+0x0/0x710)
	 r5:c0008968 r4:00000000

1. https://github.com/ynezz/linux-2.6/commits/ts72xx-wip

-- ynezz
