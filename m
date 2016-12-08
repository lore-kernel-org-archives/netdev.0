From: Dave Jones <davej@codemonkey.org.uk>
Subject: netconsole: sleeping function called from invalid context
Date: Thu, 8 Dec 2016 12:36:08 -0500
Message-ID: <20161208173608.fkuwobvph64ilmpd@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:57466 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932164AbcLHRgL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 12:36:11 -0500
Received: from c-65-96-119-39.hsd1.ma.comcast.net ([65.96.119.39] helo=wopr.kernelslacker.org)
        by arcturus.aphlor.org with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
        (Exim 4.87)
        (envelope-from <davej@codemonkey.org.uk>)
        id 1cF2c5-0007cb-QW
        for netdev@vger.kernel.org; Thu, 08 Dec 2016 17:36:09 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think this has been around for a while, but for some reason I'm running into
it a lot today.


BUG: sleeping function called from invalid context at kernel/irq/manage.c:110
in_atomic(): 1, irqs_disabled(): 1, pid: 1839, name: modprobe
no locks held by modprobe/1839.
Preemption disabled at:
[<ffffffff81b17163>] write_ext_msg+0x73/0x2d0
CPU: 0 PID: 1839 Comm: modprobe Not tainted 4.9.0-rc8-think+ #5 
 ffff880442287300
 ffffffff81651e19
 0000000080000001
 0000000000000000
 ffff88044221d380
 000000000000006e
 ffff880442287338
 ffffffff811117c3
 ffff88044221d388
 ffffffff8207b940
 000000000000006e
 0000000000000000
Call Trace:
 [<ffffffff81651e19>] dump_stack+0x6c/0x93
 [<ffffffff811117c3>] ___might_sleep+0x193/0x210
 [<ffffffff811118b1>] __might_sleep+0x71/0xe0
 [<ffffffff811673d4>] ? __synchronize_hardirq+0x94/0xa0
 [<ffffffff81167598>] synchronize_irq+0xa8/0x170
 [<ffffffff811674f0>] ? set_irq_wake_real+0x90/0x90
 [<ffffffff811674f5>] ? synchronize_irq+0x5/0x170
 [<ffffffff81167b95>] ? disable_irq+0x5/0x30
 [<ffffffff81167bb8>] disable_irq+0x28/0x30
 [<ffffffff81b78654>] e1000_netpoll+0x1c4/0x200
 [<ffffffff81b78490>] ? e1000_intr_msix_tx+0x190/0x190
 [<ffffffff81d4fd40>] netpoll_poll_dev+0xa0/0x3b0
 [<ffffffff811113c8>] ? preempt_count_sub+0x18/0xd0
 [<ffffffff81d5025d>] netpoll_send_skb_on_dev+0x20d/0x3d0
 [<ffffffff81d50955>] netpoll_send_udp+0x535/0x8c0
 [<ffffffff81b17376>] write_ext_msg+0x286/0x2d0
 [<ffffffff8168c71b>] ? check_preemption_disabled+0x3b/0x160
 [<ffffffff81161d85>] call_console_drivers.isra.20.constprop.26+0x165/0x310
 [<ffffffff811631b6>] console_unlock+0x3b6/0x840
 [<ffffffff81163af5>] vprintk_emit+0x4b5/0x6e0
 [<ffffffff81164058>] vprintk_default+0x48/0x80
 [<ffffffff812b6e11>] printk+0xbc/0xe7
 [<ffffffff812b6d55>] ? printk_lock.constprop.1+0x102/0x102
 [<ffffffff812b6d5a>] ? printk+0x5/0xe7
 [<ffffffffa0990001>] ? bt_init+0x1/0xfa [bluetooth]
 [<ffffffffa090fddd>] bt_info+0xdd/0x110 [bluetooth]
 [<ffffffffa090fd00>] ? bt_to_errno+0x50/0x50 [bluetooth]
 [<ffffffffa090fd05>] ? bt_info+0x5/0x110 [bluetooth]
 [<ffffffffa0990470>] sco_init+0xb0/0xc40 [bluetooth]
 [<ffffffffa0990000>] ? 0xffffffffa0990000
 [<ffffffffa099009d>] bt_init+0x9d/0xfa [bluetooth]
 [<ffffffff81000639>] do_one_initcall+0x199/0x220
 [<ffffffff810004a0>] ? initcall_blacklisted+0x170/0x170
 [<ffffffff812b759f>] ? do_init_module+0xe3/0x2fd
 [<ffffffffa0990000>] ? 0xffffffffa0990000
 [<ffffffff810004a5>] ? do_one_initcall+0x5/0x220
 [<ffffffff8137063c>] ? __asan_register_globals+0x7c/0xa0
 [<ffffffff812b75b0>] do_init_module+0xf4/0x2fd
 [<ffffffff811cae09>] load_module+0x3a79/0x4670
 [<ffffffff811c4f00>] ? disable_ro_nx+0x80/0x80
 [<ffffffff811c7390>] ? module_frob_arch_sections+0x20/0x20
 [<ffffffff8123874a>] ? __buffer_unlock_commit+0x4a/0x90
 [<ffffffff81239a9c>] ? trace_function+0x9c/0xc0
 [<ffffffff81246dda>] ? function_trace_call+0xea/0x290
 [<ffffffff811cbda1>] ? SYSC_finit_module+0x181/0x1c0
 [<ffffffff811c7390>] ? module_frob_arch_sections+0x20/0x20
 [<ffffffff813b4400>] ? get_user_arg_ptr.isra.26+0xa0/0xa0
 [<ffffffff811c7395>] ? load_module+0x5/0x4670
 [<ffffffff811cbda1>] SYSC_finit_module+0x181/0x1c0
 [<ffffffff811cbc20>] ? SYSC_init_module+0x220/0x220
 [<ffffffff81246dda>] ? function_trace_call+0xea/0x290
 [<ffffffff811cbdf0>] ? SyS_init_module+0x10/0x10
 [<ffffffff811cbdf0>] ? SyS_init_module+0x10/0x10
 [<ffffffff811cbdf5>] ? SyS_finit_module+0x5/0x10
 [<ffffffff8168c87c>] ? __this_cpu_preempt_check+0x1c/0x20
 [<ffffffff811cbdf0>] ? SyS_init_module+0x10/0x10
 [<ffffffff811cbdfe>] SyS_finit_module+0xe/0x10
 [<ffffffff81003bc0>] do_syscall_64+0x100/0x2b0
 [<ffffffff81f317cb>] entry_SYSCALL64_slow_path+0x25/0x25
