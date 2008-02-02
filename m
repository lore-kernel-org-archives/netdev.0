From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9873] New: BUG at net/ipv4/icmp.c:874
Date: Fri, 1 Feb 2008 19:37:42 -0800
Message-ID: <20080201193742.e4f269f5.akpm@linux-foundation.org>
References: <bug-9873-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, snakebyte@gmx.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48142 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750836AbYBBDhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 22:37:33 -0500
In-Reply-To: <bug-9873-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  1 Feb 2008 17:21:34 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9873
> 
>            Summary: BUG at net/ipv4/icmp.c:874
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24-06481-gaa62999
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: snakebyte@gmx.de
> 
> 
> Latest working kernel version: - 
> Earliest failing kernel version: 2.6.24-06481-gaa62999
> Distribution: Ubuntu
> Problem Description:
> 
> using icmpsic on a box triggers the ooops
> 
> Steps to reproduce:
> 
> start 
> icmpsic -s 192.168.0.201 -d 192.168.0.201 -p 35000 -r 22361 -k 33000
> on the machine containing those interfaces will completely lock it up
> 
> 
> [  360.552115] ------------[ cut here ]------------
> [  360.552235] kernel BUG at net/ipv4/icmp.c:874!
> [  360.552235] invalid opcode: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
> [  360.552235] Modules linked in:
> [  360.552235] 
> [  360.552235] Pid: 3899, comm: icmpsic Not tainted (2.6.24-06481-gaa62999 #20)
> [  360.552235] EIP: 0060:[<c05eb1b3>] EFLAGS: 00010282 CPU: 0
> [  360.552235] EIP is at icmp_timestamp+0x83/0xd0
> [  360.552235] EAX: fffffff2 EBX: cae7d700 ECX: 00000000 EDX: fffffffc
> [  360.552235] ESI: 003f04d0 EDI: caded000 EBP: c08efeb4 ESP: c08efe48
> [  360.552235]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> [  360.552235] Process icmpsic (pid: 3899, ti=c08ef000 task=cacf0000
> task.ti=cacbf000)
> [  360.552235] Stack: 00000004 00000001 cf449060 c0bfb720 cf0df4f0 cf0df4f0
> cf081850 d8053f00 
> [  360.552235]        d8053f00 00000004 cae7d700 c08efed4 c0899628 c08efe90
> c0603442 00000000 
> [  360.552235]        cf097090 c0603420 c08efeb4 c05b73dd 00000000 c05c5c10
> 00000001 47a3c2a2 
> [  360.552235] Call Trace:
> [  360.552235]  [<c0603442>] ? ipt_hook+0x22/0x30
> [  360.552235]  [<c0603420>] ? ipt_hook+0x0/0x30
> [  360.552235]  [<c05b73dd>] ? nf_iterate+0x5d/0x90
> [  360.552235]  [<c05c5c10>] ? ip_local_deliver_finish+0x0/0x170
> [  360.552235]  [<c05eadf6>] ? icmp_rcv+0xe6/0x200
> [  360.552235]  [<c05c5c77>] ? ip_local_deliver_finish+0x67/0x170
> [  360.552235]  [<c05c60ed>] ? ip_local_deliver+0x2d/0xa0
> [  360.552235]  [<c05c5c10>] ? ip_local_deliver_finish+0x0/0x170
> [  360.552235]  [<c05c59cf>] ? ip_rcv_finish+0xdf/0x320
> [  360.552235]  [<c05b74ca>] ? nf_hook_slow+0xba/0xe0
> [  360.552235]  [<c05c58f0>] ? ip_rcv_finish+0x0/0x320
> [  360.552235]  [<c05c5feb>] ? ip_rcv+0x16b/0x240
> [  360.552235]  [<c05c58f0>] ? ip_rcv_finish+0x0/0x320
> [  360.552235]  [<c05c5e80>] ? do_softirq+0x8a/0xd0
> [  360.552235]  [<c0128eb4>] ? local_bh_enable+0xa4/0x110
> [  360.552235]  [<c05a43d0>] ? dev_queue_xmit+0xa0/0x340
> [  360.552235]  [<c01547ad>] ? __rcu_read_unlock+0x7d/0x90
> [  360.552235]  [<c05c9d4d>] ? ip_finish_output+0x12d/0x2d0
> [  360.552235]  [<c05ca9a9>] ? ip_output+0x79/0xd0
> [  360.552235]  [<c05e4b40>] ? dst_output+0x0/0x10
> [  360.552235]  [<c05e4f71>] ? raw_send_hdrinc+0x121/0x310
> [  360.552235]  [<c05e4b40>] ? dst_output+0x0/0x10
> [  360.552235]  [<c05e60cd>] ? raw_sendmsg+0x36d/0x3a0
> [  360.552235]  [<c05ee914>] ? inet_sendmsg+0x34/0x60
> [  360.552235]  [<c0595c54>] ? sock_sendmsg+0xc4/0xf0
> [  360.552235]  [<c01373b0>] ? autoremove_wake_function+0x0/0x50
> [  360.552235]  [<c01050d3>] ? restore_nocheck+0x12/0x15
> [  360.552235]  [<c0144bf4>] ? trace_hardirqs_on+0xc4/0x150
> [  360.552235]  [<c01050d3>] ? restore_nocheck+0x12/0x15
> [  360.552235]  [<c043ff06>] ? copy_from_user+0x46/0x80
> [  360.552235]  [<c0595f45>] ? __lock_release+0x46/0x70
> [  360.552235]  [<c01070e5>] ? do_softirq+0x55/0xd0
> [  360.552235]  [<c0596e37>] ? sys_socketcall+0x187/0x260
> [  360.552235]  [<c0104fea>] ? sysenter_past_esp+0x5f/0xa5
> [  360.552235]  =======================
> [  360.552235] Code: f7 ea 69 f6 e8 03 00 00 c1 f9 1f c1 fa 06 29 ca 8d 04 16
> 31 d2 0f c8 8d 4d ac 89 45 b0 89 45 b4 89 d8 e8 c1 02 89 5d 98 c7 45 9c 00 00
> 00 
> [  360.552235] EIP: [<c05eb1b3>] icmp_timestamp+0x83/0xd0 SS:ESP 0068:c08efe48
> [  360.552276] Kernel panic - not syncing: Fatal exception in interrupt
> 
> 
> Using the icmpsic command from another box doesnt do a thing, using 127.0.0.1
> will also work.
> 


