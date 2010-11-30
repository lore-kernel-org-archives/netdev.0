From: Yinghai Lu <yinghai@kernel.org>
Subject: qlge warning
Date: Tue, 30 Nov 2010 15:28:05 -0800
Message-ID: <AANLkTi=oGgajs5KX9haKUALprJTatctpGs5UNU7LrRGO@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ingo Molnar <mingo@elte.hu>
To: David Miller <davem@davemloft.net>, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:49917 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955Ab0K3X2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 18:28:06 -0500
Received: by qyk11 with SMTP id 11so1844147qyk.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 15:28:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[  290.233264] =======================================================
[  290.251780] [ INFO: possible circular locking dependency detected ]
[  290.271534] 2.6.37-rc4-tip-yh-05919-geb30094-dirty #308
[  290.271775] -------------------------------------------------------
[  290.291512] swapper/1 is trying to acquire lock:
[  290.291725]  ((&(&qdev->mpi_port_cfg_work)->work)){+.+...}, at:
[<ffffffff81096419>] wait_on_work+0x0/0xff
[  290.311643]
[  290.311644] but task is already holding lock:
[  290.311915]  (rtnl_mutex){+.+.+.}, at: [<ffffffff81bb094d>]
rtnl_lock+0x17/0x19
[  290.331681]
[  290.331682] which lock already depends on the new lock.
[  290.331684]
[  290.351491]
[  290.351492] the existing dependency chain (in reverse order) is:
[  290.351830]
[  290.351831] -> #1 (rtnl_mutex){+.+.+.}:
[  290.371562]        [<ffffffff810ae6b6>] lock_acquire+0xca/0xf0
[  290.371824]        [<ffffffff81cdbf5d>] mutex_lock_nested+0x60/0x2b8
[  290.391539]        [<ffffffff81bb094d>] rtnl_lock+0x17/0x19
[  290.411250]        [<ffffffff818501ad>] ql_mpi_port_cfg_work+0x1f/0x1ad
[  290.411606]        [<ffffffff81095189>] process_one_work+0x234/0x3e8
[  290.431282]        [<ffffffff81095663>] worker_thread+0x17f/0x261
[  290.431583]        [<ffffffff8109a633>] kthread+0xa0/0xa8
[  290.451279]        [<ffffffff8103a914>] kernel_thread_helper+0x4/0x10
[  290.451581]
[  290.451582] -> #0 ((&(&qdev->mpi_port_cfg_work)->work)){+.+...}:
[  290.471483]        [<ffffffff810ada85>] __lock_acquire+0x113c/0x1813
[  290.491177]        [<ffffffff810ae6b6>] lock_acquire+0xca/0xf0
[  290.491451]        [<ffffffff8109646c>] wait_on_work+0x53/0xff
[  290.511128]        [<ffffffff810965da>] __cancel_work_timer+0xc2/0x102
[  290.511434]        [<ffffffff8109662c>] cancel_delayed_work_sync+0x12/0x14
[  290.531233]        [<ffffffff81847646>] ql_cancel_all_work_sync+0x64/0x68
[  290.531563]        [<ffffffff818499d5>] ql_adapter_down+0x23/0xf6
[  290.551298]        [<ffffffff81849ca7>] qlge_close+0x67/0x76
[  290.571015]        [<ffffffff81ba3853>] __dev_close+0x7b/0x89
[  290.571297]        [<ffffffff81ba5535>] __dev_change_flags+0xad/0x131
[  290.590974]        [<ffffffff81ba563a>] dev_change_flags+0x21/0x57
[  290.591280]        [<ffffffff827de30e>] ic_close_devs+0x2e/0x48
[  290.610978]        [<ffffffff827df332>] ip_auto_config+0xbc9/0xe84
[  290.611280]        [<ffffffff810002da>] do_one_initcall+0x57/0x135
[  290.630977]        [<ffffffff8278ef8a>] kernel_init+0x16c/0x1f6
[  290.631263]        [<ffffffff8103a914>] kernel_thread_helper+0x4/0x10
[  290.651000]
[  290.651001] other info that might help us debug this:
[  290.651003]
[  290.670829] 1 lock held by swapper/1:
[  290.671013]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81bb094d>]
rtnl_lock+0x17/0x19
[  290.690819]
[  290.690820] stack backtrace:
[  290.691054] Pid: 1, comm: swapper Not tainted
2.6.37-rc4-tip-yh-05919-geb30094-dirty #308
[  290.710805] Call Trace:
[  290.710938]  [<ffffffff810aa296>] ? print_circular_bug+0xaf/0xbe
[  290.730683]  [<ffffffff810ada85>] ? __lock_acquire+0x113c/0x1813
[  290.730955]  [<ffffffff81095d70>] ? wait_on_cpu_work+0xdb/0x114
[  290.750672]  [<ffffffff81096419>] ? wait_on_work+0x0/0xff
[  290.750939]  [<ffffffff810ae6b6>] ? lock_acquire+0xca/0xf0
[  290.770664]  [<ffffffff81096419>] ? wait_on_work+0x0/0xff
[  290.770920]  [<ffffffff8109646c>] ? wait_on_work+0x53/0xff
[  290.790575]  [<ffffffff81096419>] ? wait_on_work+0x0/0xff
[  290.790821]  [<ffffffff810965da>] ? __cancel_work_timer+0xc2/0x102
[  290.810559]  [<ffffffff8109662c>] ? cancel_delayed_work_sync+0x12/0x14
[  290.810855]  [<ffffffff81847646>] ? ql_cancel_all_work_sync+0x64/0x68
[  290.830594]  [<ffffffff818499d5>] ? ql_adapter_down+0x23/0xf6
[  290.830867]  [<ffffffff81849ca7>] ? qlge_close+0x67/0x76
[  290.850568]  [<ffffffff81ba3853>] ? __dev_close+0x7b/0x89
[  290.850829]  [<ffffffff81ba5535>] ? __dev_change_flags+0xad/0x131
[  290.870540]  [<ffffffff81ba563a>] ? dev_change_flags+0x21/0x57
[  290.870815]  [<ffffffff827de30e>] ? ic_close_devs+0x2e/0x48
[  290.890595]  [<ffffffff827df332>] ? ip_auto_config+0xbc9/0xe84
[  290.910247]  [<ffffffff81cda1e3>] ? printk+0x41/0x43
[  290.910488]  [<ffffffff827de769>] ? ip_auto_config+0x0/0xe84
[  290.910747]  [<ffffffff810002da>] ? do_one_initcall+0x57/0x135
[  290.930455]  [<ffffffff8278ef8a>] ? kernel_init+0x16c/0x1f6
[  290.930743]  [<ffffffff8103a914>] ? kernel_thread_helper+0x4/0x10
[  290.950419]  [<ffffffff81cde23c>] ? restore_args+0x0/0x30
[  290.970152]  [<ffffffff8278ee1e>] ? kernel_init+0x0/0x1f6
[  290.970398]  [<ffffffff8103a910>] ? kernel_thread_helper+0x0/0x10
