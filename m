From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8054] New: tipc_ref_discard tipc_deleteport
 locking dependency
Date: Thu, 22 Feb 2007 13:16:38 -0800
Message-ID: <20070222131638.f0d6ed03.akpm@linux-foundation.org>
References: <200702221220.l1MCKALR031323@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, snakebyte@gmx.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:39215 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751904AbXBVVQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 16:16:50 -0500
In-Reply-To: <200702221220.l1MCKALR031323@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Thu, 22 Feb 2007 04:20:10 -0800 bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=8054
> 
>            Summary: tipc_ref_discard tipc_deleteport locking dependency
>     Kernel Version: 2.6.21-rc1
>             Status: NEW
>           Severity: normal
>              Owner: acme@conectiva.com.br
>          Submitter: snakebyte@gmx.de
> 
> 
> Most recent kernel where this bug did *NOT* occur: - also seen this on 2.6.20
> Distribution: Gentoo
> Hardware Environment: AMD-K6
> Software Environment: 
> Problem Description:
> 
> [  273.837978] =======================================================
> [  273.838209] [ INFO: possible circular locking dependency detected ]
> [  273.838324] 2.6.21-rc1 #5
> [  273.838427] -------------------------------------------------------
> [  273.838535] sfuzz/3950 is trying to acquire lock:
> [  273.838642]  (ref_table_lock){-+..}, at: [<c0531389>] tipc_ref_discard+0x29/0xe0
> [  273.839116] 
> [  273.839121] but task is already holding lock:
> [  273.839297]  (&table[i].lock){-+..}, at: [<c052fae0>] tipc_deleteport+0x40/0x180
> [  273.839728] 
> [  273.839733] which lock already depends on the new lock.
> [  273.839741] 
> [  273.839998] 
> [  273.840003] the existing dependency chain (in reverse order) is:
> [  273.840182] 
> [  273.840187] -> #1 (&table[i].lock){-+..}:
> [  273.840581]        [<c0138994>] __lock_acquire+0xeb4/0x1020
> [  273.841352]        [<c0138b69>] lock_acquire+0x69/0xa0
> [  273.842041]        [<c0537f80>] _spin_lock_bh+0x40/0x60
> [  273.842801]        [<c05314ab>] tipc_ref_acquire+0x6b/0xe0
> [  273.844131]        [<c052ef93>] tipc_createport_raw+0x33/0x260
> [  273.844823]        [<c0530121>] tipc_createport+0x41/0x120
> [  273.845528]        [<c0529b4c>] tipc_subscr_start+0xcc/0x120
> [  273.846217]        [<c0521d04>] process_signal_queue+0x44/0x80
> [  273.846926]        [<c011df38>] tasklet_action+0x38/0x80
> [  273.847626]        [<c011e1db>] __do_softirq+0x5b/0xc0
> [  273.848374]        [<c0105e48>] do_softirq+0x88/0xe0
> [  273.849630]        [<ffffffff>] 0xffffffff
> [  273.850315] 
> [  273.850319] -> #0 (ref_table_lock){-+..}:
> [  273.850713]        [<c013878d>] __lock_acquire+0xcad/0x1020
> [  273.851416]        [<c0138b69>] lock_acquire+0x69/0xa0
> [  273.852127]        [<c0538040>] _write_lock_bh+0x40/0x60
> [  273.852835]        [<c0531389>] tipc_ref_discard+0x29/0xe0
> [  273.853552]        [<c052fafa>] tipc_deleteport+0x5a/0x180
> [  273.854832]        [<c05317d8>] tipc_create+0x58/0x160
> [  273.855530]        [<c04603d2>] __sock_create+0x112/0x280
> [  273.856237]        [<c046057a>] sock_create+0x1a/0x20
> [  273.856931]        [<c04605a3>] sys_socketpair+0x23/0x1a0
> [  273.857642]        [<c0461257>] sys_socketcall+0x137/0x260
> [  273.858343]        [<c0102cb0>] syscall_call+0x7/0xb
> [  273.859052]        [<ffffffff>] 0xffffffff
> [  273.860333] 
> [  273.860338] other info that might help us debug this:
> [  273.860345] 
> [  273.860596] 1 lock held by sfuzz/3950:
> [  273.860697]  #0:  (&table[i].lock){-+..}, at: [<c052fae0>]
> tipc_deleteport+0x40/0x180
> [  273.861208] 
> [  273.861213] stack backtrace:
> [  273.861391]  [<c01042ba>] show_trace_log_lvl+0x1a/0x40
> [  273.861591]  [<c0104a92>] show_trace+0x12/0x20
> [  273.861779]  [<c0104b99>] dump_stack+0x19/0x20
> [  273.861968]  [<c013686e>] print_circular_bug_tail+0x6e/0x80
> [  273.862162]  [<c013878d>] __lock_acquire+0xcad/0x1020
> [  273.862354]  [<c0138b69>] lock_acquire+0x69/0xa0
> [  273.862544]  [<c0538040>] _write_lock_bh+0x40/0x60
> [  273.862740]  [<c0531389>] tipc_ref_discard+0x29/0xe0
> [  273.862958]  [<c052fafa>] tipc_deleteport+0x5a/0x180
> [  273.863153]  [<c05317d8>] tipc_create+0x58/0x160
> [  273.863347]  [<c04603d2>] __sock_create+0x112/0x280
> [  273.863541]  [<c046057a>] sock_create+0x1a/0x20
> [  273.863731]  [<c04605a3>] sys_socketpair+0x23/0x1a0
> [  273.863922]  [<c0461257>] sys_socketcall+0x137/0x260
> [  273.864113]  [<c0102cb0>] syscall_call+0x7/0xb
> [  273.864299]  =======================
> 
> Steps to reproduce:
> 
> enable tipc, recompile, reboot, run sfuzz
> (http://www.digitaldwarf.be/products/sfuzz.c) for some time
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
