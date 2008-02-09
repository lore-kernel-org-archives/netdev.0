From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: [PATCH][AX25] ax25_ds_timer: use mod_timer instead of add_timer
Date: Sat, 09 Feb 2008 19:44:50 +0100
Message-ID: <47ADF4A2.6070705@free.fr>
References: <47664A0C.4060903@free.fr> <20071218135202.GA2023@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080000050508080205020701"
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:33154 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752896AbYBISoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Feb 2008 13:44:54 -0500
In-Reply-To: <20071218135202.GA2023@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080000050508080205020701
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

With AX25 patches applied I still get this possible circular locking 
message.

Regards,

Bernard P.





--------------080000050508080205020701
Content-Type: text/plain;
 name="possible_circular_locking"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="possible_circular_locking"


=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.24 #3
-------------------------------------------------------
swapper/0 is trying to acquire lock:
 (ax25_list_lock){-+..}, at: [<f91dd3b1>] ax25_destroy_socket+0x171/0x1f0 [ax25]

but task is already holding lock:
 (slock-AF_AX25){-+..}, at: [<f91dbabc>] ax25_std_heartbeat_expiry+0x1c/0xe0 [ax25]

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (slock-AF_AX25){-+..}:
       [<c014c8ca>] __lock_acquire+0xc4a/0x10d0
       [<c014cdd1>] lock_acquire+0x81/0xa0
       [<c03280e2>] _spin_lock+0x32/0x60
       [<f91dce3a>] ax25_info_show+0x24a/0x2c0 [ax25]
       [<c01a4aa1>] seq_read+0xa1/0x2a0
       [<c01c20fd>] proc_reg_read+0x5d/0x90
       [<c018a41a>] vfs_read+0xaa/0x130
       [<c018a8ed>] sys_read+0x3d/0x70
       [<c01042ae>] sysenter_past_esp+0x5f/0xa5
       [<ffffffff>] 0xffffffff

-> #0 (ax25_list_lock){-+..}:
       [<c014c6f1>] __lock_acquire+0xa71/0x10d0
       [<c014cdd1>] lock_acquire+0x81/0xa0
       [<c0328143>] _spin_lock_bh+0x33/0x60
       [<f91dd3b1>] ax25_destroy_socket+0x171/0x1f0 [ax25]
       [<f91dbaf3>] ax25_std_heartbeat_expiry+0x53/0xe0 [ax25]
       [<f91dc5ab>] ax25_heartbeat_expiry+0x1b/0x40 [ax25]
       [<c01325dd>] run_timer_softirq+0x15d/0x1c0
       [<c012e343>] __do_softirq+0x93/0x120
       [<c012e427>] do_softirq+0x57/0x60
       [<c012e868>] irq_exit+0x48/0x60
       [<c0119b3b>] smp_apic_timer_interrupt+0x5b/0x90
       [<c0104e27>] apic_timer_interrupt+0x33/0x38
       [<c0102512>] mwait_idle+0x12/0x20
       [<c0102631>] cpu_idle+0x71/0xc0
       [<c0325549>] rest_init+0x49/0x50
       [<c0427a9a>] start_kernel+0x2ea/0x370
       [<00000000>] 0x0
       [<ffffffff>] 0xffffffff

other info that might help us debug this:

1 lock held by swapper/0:
 #0:  (slock-AF_AX25){-+..}, at: [<f91dbabc>] ax25_std_heartbeat_expiry+0x1c/0xe0 [ax25]

stack backtrace:
Pid: 0, comm: swapper Not tainted 2.6.24 #3
 [<c01053da>] show_trace_log_lvl+0x1a/0x30
 [<c0105e12>] show_trace+0x12/0x20
 [<c01067cc>] dump_stack+0x6c/0x80
 [<c014a32f>] print_circular_bug_tail+0x6f/0x80
 [<c014c6f1>] __lock_acquire+0xa71/0x10d0
 [<c014cdd1>] lock_acquire+0x81/0xa0
 [<c0328143>] _spin_lock_bh+0x33/0x60
 [<f91dd3b1>] ax25_destroy_socket+0x171/0x1f0 [ax25]
 [<f91dbaf3>] ax25_std_heartbeat_expiry+0x53/0xe0 [ax25]
 [<f91dc5ab>] ax25_heartbeat_expiry+0x1b/0x40 [ax25]
 [<c01325dd>] run_timer_softirq+0x15d/0x1c0
 [<c012e343>] __do_softirq+0x93/0x120
 [<c012e427>] do_softirq+0x57/0x60
 [<c012e868>] irq_exit+0x48/0x60
 [<c0119b3b>] smp_apic_timer_interrupt+0x5b/0x90
 [<c0104e27>] apic_timer_interrupt+0x33/0x38
 [<c0102512>] mwait_idle+0x12/0x20
 [<c0102631>] cpu_idle+0x71/0xc0
 [<c0325549>] rest_init+0x49/0x50
 [<c0427a9a>] start_kernel+0x2ea/0x370
 [<00000000>] 0x0
 =======================

--------------080000050508080205020701--
