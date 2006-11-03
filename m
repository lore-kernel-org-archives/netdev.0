From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [BUG ??] nfs: kernel server lock problems
Date: Fri, 3 Nov 2006 07:45:48 +0000
Message-ID: <200611030745.48401@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:16290 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1753179AbWKCHqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 02:46:04 -0500
Received: from gerrit (gerrit.erg.abdn.ac.uk [139.133.204.176])
	by erg.abdn.ac.uk (8.13.4/8.13.4) with ESMTP id kA37jpwh022834
	for <netdev@vger.kernel.org>; Fri, 3 Nov 2006 07:45:52 GMT
Content-Disposition: inline
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Someone any ideas regarding the following bug report,
which happened on 

 * a dual-Pentium-3 server with SMP enabled
 * latest davem-2.6 (pulled yesterday)
 * nfs-utils 1.0.10
 * lock validation turned on

If this is not enough information please point out what 
is missing.

--------------<snip>------------------------------
Nov  2 22:55:15 kernel: =====================================
Nov  2 22:55:15 kernel: [ BUG: lock held at task exit time! ]
Nov  2 22:55:15 kernel: -------------------------------------
Nov  2 22:55:15 kernel: S20nfs-kernel-s/5294 is exiting with locks still held!
Nov  2 22:55:15 kernel: 1 lock held by S20nfs-kernel-s/5294:
Nov  2 22:55:15 kernel:  #0:  (old_style_spin_init#2){--..}, at: [_atomic_dec_and_lock+62/112] _atomic_dec_and_lock+0x3e/0x70
Nov  2 22:55:15 kernel: 
Nov  2 22:55:15 kernel: stack backtrace:
Nov  2 22:55:15 kernel:  [show_trace_log_lvl+26/48] show_trace_log_lvl+0x1a/0x30
Nov  2 22:55:15 kernel:  [show_trace+18/32] show_trace+0x12/0x20
Nov  2 22:55:15 kernel:  [dump_stack+25/32] dump_stack+0x19/0x20
Nov  2 22:55:15 kernel:  [debug_check_no_locks_held+135/144] debug_check_no_locks_held+0x87/0x90
Nov  2 22:55:15 kernel:  [do_exit+1165/2176] do_exit+0x48d/0x880
Nov  2 22:55:15 kernel:  [do_group_exit+54/144] do_group_exit+0x36/0x90
Nov  2 22:55:15 kernel:  [sys_exit_group+15/32] sys_exit_group+0xf/0x20
Nov  2 22:55:15 kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
Nov  2 22:55:15 kernel:  =======================
Nov  2 23:03:59 kernel: nfsd: last server has exited
Nov  2 23:03:59 kernel: nfsd: unexporting all filesystems
Nov  2 23:04:10 kernel: BUG: soft lockup detected on CPU#1!
Nov  2 23:04:10 kernel:  [show_trace_log_lvl+26/48] show_trace_log_lvl+0x1a/0x30
Nov  2 23:04:10 kernel:  [show_trace+18/32] show_trace+0x12/0x20
Nov  2 23:04:10 kernel:  [dump_stack+25/32] dump_stack+0x19/0x20
Nov  2 23:04:10 kernel:  [softlockup_tick+170/208] softlockup_tick+0xaa/0xd0
Nov  2 23:04:10 kernel:  [run_local_timers+18/32] run_local_timers+0x12/0x20
Nov  2 23:04:10 kernel:  [update_process_times+52/128] update_process_times+0x34/0x80
Nov  2 23:04:10 kernel:  [smp_apic_timer_interrupt+132/176] smp_apic_timer_interrupt+0x84/0xb0
Nov  2 23:04:10 kernel:  [apic_timer_interrupt+42/48] apic_timer_interrupt+0x2a/0x30
Nov  2 23:04:10 kernel:  [_spin_lock+51/64] _spin_lock+0x33/0x40
Nov  2 23:04:10 kernel:  [auth_domain_lookup+100/256] auth_domain_lookup+0x64/0x100
Nov  2 23:04:10 kernel:  [unix_domain_find+26/192] unix_domain_find+0x1a/0xc0
Nov  2 23:04:10 kernel:  [ip_map_parse+341/352] ip_map_parse+0x155/0x160
Nov  2 23:04:10 kernel:  [cache_write+127/176] cache_write+0x7f/0xb0
Nov  2 23:04:10 kernel:  [vfs_write+149/272] vfs_write+0x95/0x110
Nov  2 23:04:10 kernel:  [sys_write+61/112] sys_write+0x3d/0x70
Nov  2 23:04:10 kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
Nov  2 23:04:10 kernel:  =======================
			
		
