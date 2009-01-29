From: arrow.ebd@gmail.com
Subject: ipv6: INFO: possible circular locking dependency detected --
	2.6.29-rc3
Date: Thu, 29 Jan 2009 20:43:28 +0800
Message-ID: <20090129124328.GA21638@think>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: linux_kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:58004 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbZA2MqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 07:46:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

	Here is some error message when I starting gw6c, but work fine
after try again.

[28132.185654] tun: Disabled Privacy Extensions
[28205.459897] ip6_tables: (C) 2000-2006 Netfilter Core Team
[28696.166729] warning: `dumpcap' uses 32-bit capabilities (legacy support in use)
[28715.857186] device tun entered promiscuous mode
[28716.414947] 
[28716.414950] =======================================================
[28716.414954] [ INFO: possible circular locking dependency detected ]
[28716.414956] 2.6.29-rc3 #38
[28716.414958] -------------------------------------------------------
[28716.414960] dumpcap/20695 is trying to acquire lock:
[28716.414962]  (&mm->mmap_sem){----}, at: [<c0276239>] might_fault+0x31/0x6d
[28716.414969] 
[28716.414970] but task is already holding lock:
[28716.414972]  (sk_lock-AF_PACKET){--..}, at: [<c043f5c7>] sock_setsockopt+0x12c/0x4a9
[28716.414977] 
[28716.414978] which lock already depends on the new lock.
[28716.414979] 
[28716.414980] 
[28716.414981] the existing dependency chain (in reverse order) is:
[28716.414983] 
[28716.414983] -> #1 (sk_lock-AF_PACKET){--..}:
[28716.414987]        [<c0243cbb>] check_usage+0x6d/0x338
[28716.414991]        [<c02422c5>] add_lock_to_list+0x66/0x94
[28716.414994]        [<c0244f8a>] __lock_acquire+0x1004/0x132b
[28716.414997]        [<c04cb621>] packet_mmap+0x2e/0xf4
[28716.415001]        [<c04cb621>] packet_mmap+0x2e/0xf4
[28716.415004]        [<c024530d>] lock_acquire+0x5c/0x7e
[28716.415007]        [<c04cb621>] packet_mmap+0x2e/0xf4
[28716.415010]        [<c043e217>] lock_sock_nested+0xac/0xb9
[28716.415014]        [<c04cb621>] packet_mmap+0x2e/0xf4
[28716.415017]        [<c04cb621>] packet_mmap+0x2e/0xf4
[28716.415020]        [<c043b5d6>] sock_mmap+0xf/0x11
[28716.415022]        [<c027c2b5>] mmap_region+0x283/0x4c0
[28716.415026]        [<c027c70a>] do_mmap_pgoff+0x218/0x261
[28716.415029]        [<c0205e8e>] sys_mmap2+0x59/0x77
[28716.415033]        [<c02033cb>] sysenter_do_call+0x12/0x3f
[28716.415036]        [<ffffffff>] 0xffffffff
[28716.415050] 
[28716.415050] -> #0 (&mm->mmap_sem){----}:
[28716.415053]        [<c0243c17>] print_circular_bug_tail+0x77/0xae
[28716.415057]        [<c0244cba>] __lock_acquire+0xd34/0x132b
[28716.415060]        [<c02435d8>] mark_held_locks+0x4e/0x64
[28716.415063]        [<c022afba>] local_bh_enable+0xb8/0xc6
[28716.415066]        [<c024530d>] lock_acquire+0x5c/0x7e
[28716.415069]        [<c0276239>] might_fault+0x31/0x6d
[28716.415072]        [<c0276256>] might_fault+0x4e/0x6d
[28716.415074]        [<c0276239>] might_fault+0x31/0x6d
[28716.415077]        [<c033b85f>] copy_from_user+0x27/0x10e
[28716.415081]        [<c043f8cc>] sock_setsockopt+0x431/0x4a9
[28716.415084]        [<c024378c>] trace_hardirqs_on_caller+0x10e/0x12e
[28716.415087]        [<c0276239>] might_fault+0x31/0x6d
[28716.415090]        [<c043bf45>] sys_setsockopt+0x4c/0x7d
[28716.415093]        [<c043d5ff>] sys_socketcall+0x146/0x19f
[28716.415096]        [<c033b3d8>] trace_hardirqs_on_thunk+0xc/0x10
[28716.415099]        [<c02033cb>] sysenter_do_call+0x12/0x3f
[28716.415102]        [<ffffffff>] 0xffffffff
[28716.415107] 
[28716.415108] other info that might help us debug this:
[28716.415109] 
[28716.415111] 1 lock held by dumpcap/20695:
[28716.415112]  #0:  (sk_lock-AF_PACKET){--..}, at: [<c043f5c7>] sock_setsockopt+0x12c/0x4a9
[28716.415117] 
[28716.415117] stack backtrace:
[28716.415121] Pid: 20695, comm: dumpcap Not tainted 2.6.29-rc3 #38
[28716.415122] Call Trace:
[28716.415126]  [<c0243c44>] print_circular_bug_tail+0xa4/0xae
[28716.415129]  [<c0244cba>] __lock_acquire+0xd34/0x132b
[28716.415132]  [<c02435d8>] mark_held_locks+0x4e/0x64
[28716.415135]  [<c022afba>] local_bh_enable+0xb8/0xc6
[28716.415138]  [<c024530d>] lock_acquire+0x5c/0x7e
[28716.415140]  [<c0276239>] might_fault+0x31/0x6d
[28716.415143]  [<c0276256>] might_fault+0x4e/0x6d
[28716.415145]  [<c0276239>] might_fault+0x31/0x6d
[28716.415148]  [<c033b85f>] copy_from_user+0x27/0x10e
[28716.415151]  [<c043f8cc>] sock_setsockopt+0x431/0x4a9
[28716.415154]  [<c024378c>] trace_hardirqs_on_caller+0x10e/0x12e
[28716.415156]  [<c0276239>] might_fault+0x31/0x6d
[28716.415159]  [<c043bf45>] sys_setsockopt+0x4c/0x7d
[28716.415162]  [<c043d5ff>] sys_socketcall+0x146/0x19f
[28716.415165]  [<c033b3d8>] trace_hardirqs_on_thunk+0xc/0x10
[28716.415168]  [<c02033cb>] sysenter_do_call+0x12/0x3f
[28727.318127] device tun left promiscuous mode
[28734.529148] device wlan0 entered promiscuous mode
[28745.448232] device wlan0 left promiscuous mode
[28789.287047] device tun entered promiscuous mode
[28960.255184] device tun left promiscuous mode
[29228.332332] tun: Disabled Privacy Extensions
[29243.004359] tun: Disabled Privacy Extensions
[29258.855659] tun: Disabled Privacy Extensions
[29390.773165] tun: Disabled Privacy Extensions
[29439.781285] tun: Disabled Privacy Extensions
[29766.436131] tun: Disabled Privacy Extensions
