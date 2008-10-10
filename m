From: Chris Snook <csnook@redhat.com>
Subject: Re: [atl1-devel] [Bugme-new] [Bug 11736] New: atl1e: INFO: inconsistent
 lock state
Date: Fri, 10 Oct 2008 17:31:43 -0400
Message-ID: <48EFC9BF.3020806@redhat.com>
References: <bug-11736-10286@http.bugzilla.kernel.org/> <20081010142342.afe1cbb1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	nm127@freemail.hu, bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60624 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761063AbYJJVhu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 17:37:50 -0400
In-Reply-To: <20081010142342.afe1cbb1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Copying Jie Yang, the atl1e author, as I'm not certain he's on atl1-devel.

Jie --

What do you make of this?

-- Chris

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Fri, 10 Oct 2008 14:14:12 -0700 (PDT)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=11736
>>
>>            Summary: atl1e: INFO: inconsistent lock state
>>            Product: Drivers
>>            Version: 2.5
>>      KernelVersion: 2.6.27
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Network
>>         AssignedTo: jgarzik@pobox.com
>>         ReportedBy: nm127@freemail.hu
>>
>>
>> Latest working kernel version:
>> Earliest failing kernel version:
>> Distribution: Debian
>> Hardware Environment: eeePC 901
>> Software Environment:
>> Problem Description:
>> At boot the following message appears in the dmesg:
>>
>> [   10.926640] ATL1E 0000:04:00.0: PCI INT A -> Link[LNKB] -> GSI 5 (level,
>> low) -> IRQ 5
>> [   10.941823] ATL1E 0000:04:00.0: setting latency timer to 64
>> [   42.441150] 
>> [   42.441156] =================================
>> [   42.450029] [ INFO: inconsistent lock state ]
>> [   42.450029] 2.6.27 #1
>> [   42.450029] ---------------------------------
>> [   42.450029] inconsistent {hardirq-on-W} -> {in-hardirq-W} usage.
>> [   42.450029] ifconfig/1315 [HC1[1]:SC0[0]:HE0:SE1] takes:
>> [   42.450029]  (&adapter->mdio_lock){+-..}, at: [<f89e4499>]
>> atl1e_intr+0x2a9/0x440 [atl1e]
>> [   42.450029] {hardirq-on-W} state was registered at:
>> [   42.450029]   [<c0139364>] mark_lock+0xf4/0x830
>> [   42.450029]   [<c013a459>] __lock_acquire+0x2e9/0x1380
>> [   42.450029]   [<c02a2bbf>] pci_conf1_read+0xaf/0xf0
>> [   42.450029]   [<c0139cc9>] debug_check_no_locks_freed+0x79/0x130
>> [   42.450029]   [<c0139c24>] trace_hardirqs_on_caller+0xa4/0xc0
>> [   42.450029]   [<c013b54d>] lock_acquire+0x5d/0x80
>> [   42.450029]   [<f89e831b>] atl1e_probe+0x48b/0x6d0 [atl1e]
>> [   42.450029]   [<c0305e60>] _spin_lock+0x30/0x40
>> [   42.450029]   [<f89e831b>] atl1e_probe+0x48b/0x6d0 [atl1e]
>> [   42.450029]   [<f89e831b>] atl1e_probe+0x48b/0x6d0 [atl1e]
>> [   42.450029]   [<c01ef988>] pci_match_device+0xa8/0xc0
>> [   42.450029]   [<c01efd26>] pci_device_probe+0x56/0x80
>> [   42.450029]   [<c025a375>] driver_probe_device+0x75/0x150
>> [   42.450029]   [<c0139c24>] trace_hardirqs_on_caller+0xa4/0xc0
>> [   42.450029]   [<c025a4c2>] __driver_attach+0x72/0x80
>> [   42.450029]   [<c0259a3c>] bus_for_each_dev+0x3c/0x60
>> [   42.450029]   [<c025a1e6>] driver_attach+0x16/0x20
>> [   42.450029]   [<c025a450>] __driver_attach+0x0/0x80
>> [   42.450029]   [<c0259e92>] bus_add_driver+0xb2/0x230
>> [   42.450029]   [<c01ef820>] pci_device_shutdown+0x0/0x20
>> [   42.450029]   [<c01efc70>] pci_device_remove+0x0/0x40
>> [   42.450029]   [<c025a64d>] driver_register+0x4d/0x120
>> [   42.450029]   [<c01ea6a2>] __spin_lock_init+0x32/0x70
>> [   42.450029]   [<f8860000>] snd_mixer_oss_conv+0x0/0x50 [snd_mixer_oss]
>> [   42.450029]   [<c01eff88>] __pci_register_driver+0x58/0xa0
>> [   42.450029]   [<f8860000>] snd_mixer_oss_conv+0x0/0x50 [snd_mixer_oss]
>> [   42.450029]   [<c0101122>] do_one_initcall+0x32/0x160
>> [   42.450029]   [<c0145530>] disable_irq+0x0/0x30
>> [   42.450029]   [<c0304ac5>] __mutex_unlock_slowpath+0x95/0xe0
>> [   42.450029]   [<c0143429>] sys_init_module+0x89/0x1b0
>> [   42.450029]   [<c0139c24>] trace_hardirqs_on_caller+0xa4/0xc0
>> [   42.450029]   [<c01de344>] trace_hardirqs_on_thunk+0xc/0x10
>> [   42.450029]   [<c01030d6>] syscall_call+0x7/0xb
>> [   42.450029]   [<ffffffff>] 0xffffffff
>> [   42.450029] irq event stamp: 4564
>> [   42.450029] hardirqs last  enabled at (4563): [<c01652b5>]
>> kmem_cache_free+0x65/0x90
>> [   42.450029] hardirqs last disabled at (4564): [<c01de354>]
>> trace_hardirqs_off_thunk+0xc/0x18
>> [   42.450029] softirqs last  enabled at (4532): [<c02b1d1c>]
>> dev_change_flags+0x5c/0x1a0
>> [   42.450029] softirqs last disabled at (4530): [<c0305e7b>]
>> _spin_lock_bh+0xb/0x40
>> [   42.450029] 
>> [   42.450029] other info that might help us debug this:
>> [   42.450029] 1 lock held by ifconfig/1315:
>> [   42.450029]  #0:  (rtnl_mutex){--..}, at: [<c02ed5c1>]
>> devinet_ioctl+0xf1/0x670
>> [   42.450029] 
>> [   42.450029] stack backtrace:
>> [   42.450029] Pid: 1315, comm: ifconfig Not tainted 2.6.27 #1
>> [   42.450029]  [<c0138944>] print_usage_bug+0x174/0x190
>> [   42.450029]  [<c01399c5>] mark_lock+0x755/0x830
>> [   42.450029]  [<c013ac85>] __lock_acquire+0xb15/0x1380
>> [   42.450029]  [<c013a5be>] __lock_acquire+0x44e/0x1380
>> [   42.450029]  [<c013a5be>] __lock_acquire+0x44e/0x1380
>> [   42.450029]  [<c013b54d>] lock_acquire+0x5d/0x80
>> [   42.450029]  [<f89e4499>] atl1e_intr+0x2a9/0x440 [atl1e]
>> [   42.450029]  [<c0305e60>] _spin_lock+0x30/0x40
>> [   42.450029]  [<f89e4499>] atl1e_intr+0x2a9/0x440 [atl1e]
>> [   42.450029]  [<f89e4499>] atl1e_intr+0x2a9/0x440 [atl1e]
>> [   42.450029]  [<c0306246>] _spin_lock_irqsave+0x46/0x60
>> [   42.450029]  [<c0144fa0>] handle_IRQ_event+0x20/0x60
>> [   42.450029]  [<c01467fd>] handle_level_irq+0x6d/0xe0
>> [   42.450029]  [<c0104f63>] do_IRQ+0x53/0xa0
>> [   42.450029]  [<c0103280>] common_interrupt+0x28/0x30
>> [   42.450029]  [<f89e53c4>] atl1e_up+0x424/0x4a0 [atl1e]
>> [   42.450029]  [<f89e41f0>] atl1e_intr+0x0/0x440 [atl1e]
>> [   42.450029]  [<c0145985>] request_irq+0xa5/0xc0
>> [   42.450029]  [<f89e5c5d>] atl1e_open+0xdd/0x390 [atl1e]
>> [   42.450029]  [<c02b3b44>] dev_open+0x54/0xb0
>> [   42.450029]  [<c02b1d1c>] dev_change_flags+0x5c/0x1a0
>> [   42.450029]  [<c011f82b>] local_bh_enable_ip+0x6b/0xb0
>> [   42.450029]  [<c02b1d3e>] dev_change_flags+0x7e/0x1a0
>> [   42.450029]  [<c02ed9de>] devinet_ioctl+0x50e/0x670
>> [   42.450029]  [<c02a4f5f>] sock_ioctl+0xcf/0x250
>> [   42.450029]  [<c02a4e90>] sock_ioctl+0x0/0x250
>> [   42.450029]  [<c017448f>] vfs_ioctl+0x1f/0x70
>> [   42.450029]  [<c0110eb3>] do_page_fault+0xf3/0x680
>> [   42.450029]  [<c017453c>] do_vfs_ioctl+0x5c/0x260
>> [   42.450029]  [<c017477d>] sys_ioctl+0x3d/0x70
>> [   42.450029]  [<c01030d6>] syscall_call+0x7/0xb
>> [   42.450029]  =======================
>> [   42.916493] ATL1E 0000:04:00.0: ATL1E: eth0 NIC Link is Up<100 Mbps Full
>> Duplex>
>>
>> Steps to reproduce: boot the system
>>
> 
> 
> -------------------------------------------------------------------------
> This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
> Build the coolest Linux based applications with Moblin SDK & win great prizes
> Grand prize is a trip for two to an Open Source event anywhere in the world
> http://moblin-contest.org/redirect.php?banner_id=100&url=/
> _______________________________________________
> atl1-devel mailing list
> atl1-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/atl1-devel

