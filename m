From: Scott Feldman <sfeldma@gmail.com>
Subject: /net/mpls/conf/ethX//input duplicate entry
Date: Wed, 10 Jun 2015 13:43:53 -0700
Message-ID: <CAE4R7bDhQ3speftJsggqV5Ruh-n0+n_9KR=i0DQYW-NrsUNKZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Netdev <netdev@vger.kernel.org>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>,
	rshearma@brocade.com, Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:34966 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085AbbFJUoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 16:44:14 -0400
Received: by qchs1 with SMTP id s1so957879qch.2
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 13:44:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm getting this dump_stack when reloading rocker driver.  Did some
sysctl MPLS nodes not get cleaned up on NETDEV_UNREGISTER?

Steps to repro: load rocker (on system) with rocker device, rmmod
rocker, and then modprobe rocker.  I doubt this is specific to rocker:
and re-registration of a netdev should hit it. I am using UDEV rules
to rename kernel's ethX to a different name.  Maybe that's what
tripped it up?


[   68.587713] sysctl duplicate entry: /net/mpls/conf/eth4//input
[   68.590015] CPU: 0 PID: 2944 Comm: modprobe Not tainted 4.1.0-rc7+ #35
[   68.591514] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS rel-1.8.1-0-g4adadbd-20150316_085822-nilsson.home.kraxel.org
04/01/2014
[   68.594401]  ffff88000f521f00 ffff88000f73f848 ffffffff81443991
0000000000000006
[   68.596885]  0000000000000000 ffff88000f73f8a8 ffffffff811a4d5a
ffff88000f73f8b8
[   68.599328]  ffffffff81a9e400 0000000000000000 0000000400000020
ffff88000f73f8c8
[   68.620961] Call Trace:
[   68.621770]  [<ffffffff81443991>] dump_stack+0x4c/0x65
[   68.623147]  [<ffffffff811a4d5a>] __register_sysctl_table+0x414/0x426
[   68.624659]  [<ffffffff81432c17>] register_net_sysctl+0x10/0x12
[   68.626052]  [<ffffffff81435c85>] mpls_dev_notify+0xd6/0x26f
[   68.627403]  [<ffffffff814297fa>] ? packet_notifier+0x18c/0x19a
[   68.628821]  [<ffffffff81062337>] notifier_call_chain+0x3f/0x6c
[   68.630225]  [<ffffffff8106236d>] __raw_notifier_call_chain+0x9/0xb
[   68.631675]  [<ffffffff8106237e>] raw_notifier_call_chain+0xf/0x11
[   68.633146]  [<ffffffff8135eb6c>] call_netdevice_notifiers_info+0x4f/0x58
[   68.634695]  [<ffffffff8135ebb6>] call_netdevice_notifiers+0x11/0x13
[   68.636175]  [<ffffffff8136718b>] register_netdevice+0x2f6/0x365
[   68.637604]  [<ffffffff81367214>] register_netdev+0x1a/0x27
[   68.638962]  [<ffffffffa039d3f8>] rocker_probe+0x94d/0xc20 [rocker]
[   68.640424]  [<ffffffff81300001>] ? component_bind_all+0x5b/0x190
[   68.641861]  [<ffffffff812561fa>] local_pci_probe+0x38/0x7e
[   68.643204]  [<ffffffff8125630e>] pci_device_probe+0xce/0xf4
[   68.644579]  [<ffffffff81304312>] driver_probe_device+0xcc/0x23d
[   68.646220]  [<ffffffff81304483>] ? driver_probe_device+0x23d/0x23d
[   68.647679]  [<ffffffff813044d1>] __driver_attach+0x4e/0x6f
[   68.649051]  [<ffffffff813029d0>] bus_for_each_dev+0x5a/0x8c
[   68.650402]  [<ffffffff81303dc2>] driver_attach+0x19/0x1b
[   68.651773]  [<ffffffff81303afd>] bus_add_driver+0xf1/0x1d6
[   68.653305]  [<ffffffff81304c23>] driver_register+0x87/0xbe
[   68.654652]  [<ffffffff81255a74>] __pci_register_driver+0x5d/0x62
[   68.656087]  [<ffffffffa0378000>] ? 0xffffffffa0378000
[   68.657367]  [<ffffffffa0378039>] rocker_module_init+0x39/0x1000 [rocker]
[   68.658900]  [<ffffffffa0378000>] ? 0xffffffffa0378000
[   68.660178]  [<ffffffffa0378000>] ? 0xffffffffa0378000
[   68.661461]  [<ffffffff8100030d>] do_one_initcall+0xe9/0x186
[   68.662813]  [<ffffffff8113d228>] ? kmem_cache_alloc_trace+0xee/0x100
[   68.664316]  [<ffffffff814418bf>] do_init_module+0x5b/0x1ca
[   68.665666]  [<ffffffff810b2364>] load_module+0x1cf2/0x1ee1
[   68.667002]  [<ffffffff810aefed>] ? __module_get+0x29/0x29
[   68.668336]  [<ffffffff8144a4e7>] ? retint_kernel+0x10/0x10
[   68.669694]  [<ffffffff810b2666>] SyS_init_module+0x113/0x124
[   68.671062]  [<ffffffff81449957>] system_call_fastpath+0x12/0x6f
