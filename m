From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9825] New: GPF in kernel when /sbin/ss used
 for display DCCP sockets.
Date: Sat, 26 Jan 2008 22:33:30 -0800
Message-ID: <20080126223330.204e1bd1.akpm@linux-foundation.org>
References: <bug-9825-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, spike@ml.yaroslavl.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57582 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751006AbYA0Gdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2008 01:33:35 -0500
In-Reply-To: <bug-9825-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Sat, 26 Jan 2008 13:18:40 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=9825
> 
>            Summary: GPF in kernel when /sbin/ss used for display DCCP
>                     sockets.
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: spike@ml.yaroslavl.ru
> 
> 
> Latest working kernel version: 2.6.23.14
> Earliest failing kernel version:2.6.24

A regression in 2.6.24.

> Distribution:gentoo 
> Hardware Environment: i386
> Software Environment: ss utility, iproute2-ss070710
> Problem Description:
> GPF in kernel when ss used for display DCCP sockets.
> 
> Jan 26 23:38:03 host general protection fault: 0000 [#1] PREEMPT
> Jan 26 23:38:03 host Modules linked in: iptable_mangle iptable_nat nf_nat
> ipt_REJECT xt_tcpudp nf_conntrack_ipv4 xt_state ipt_ULOG iptable_filter
> ip_tables x_
> Jan 26 23:38:03 host
> Jan 26 23:38:03 host Pid: 5573, comm: ss Not tainted (2.6.24 #1)
> Jan 26 23:38:03 host EIP: 0060:[<c031a14f>] EFLAGS: 00010282 CPU: 0
> Jan 26 23:38:03 host EIP is at inet_diag_dump+0x2a/0x88b
> Jan 26 23:38:03 host EAX: fffffffe EBX: e7095810 ECX: 00000001 EDX: fffffffe
> Jan 26 23:38:03 host ESI: ee264a00 EDI: e7035840 EBP: 000015c5 ESP: e70fdbd0
> Jan 26 23:38:03 host DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> Jan 26 23:38:03 host Process ss (pid: 5573, ti=e70fc000 task=e70f3680
> task.ti=e70fc000)
> Jan 26 23:38:03 host Stack: 00000001 c040c164 e70f3680 000040d0 00000000
> e7035840 ee264a00 c01690a7
> Jan 26 23:38:03 host effc6009 e70fdc20 e7095810 000240d0 c040c6c0 00000010
> c14e02c0 00000282
> Jan 26 23:38:03 host 8cab2e5a 000040d0 00000f00 000000d0 c0426e80 c0147e38
> ee264a00 c02c6dff
> Jan 26 23:38:03 host Call Trace:
> Jan 26 23:38:03 host [<c01690a7>] permission+0x51/0xe7
> Jan 26 23:38:03 host [<c0147e38>] __get_free_pages+0x4d/0x55
> Jan 26 23:38:03 host [<c02c6dff>] __alloc_skb+0x4b/0xfa
> Jan 26 23:38:03 host [<c02de333>] netlink_dump+0x47/0x178
> Jan 26 23:38:03 host [<c01426df>] file_read_actor+0xe1/0x10c
> Jan 26 23:38:03 host [<c02e062e>] netlink_dump_start+0xb8/0x15e
> Jan 26 23:38:03 host [<c0319bf0>] inet_diag_rcv_msg+0x5c/0x591
> Jan 26 23:38:03 host [<c031a125>] inet_diag_dump+0x0/0x88b
> Jan 26 23:38:03 host [<c0319b94>] inet_diag_rcv_msg+0x0/0x591
> Jan 26 23:38:03 host [<c0319152>] inet_diag_rcv+0x0/0x24
> Jan 26 23:38:03 host [<c02df335>] netlink_rcv_skb+0x6d/0x8e
> Jan 26 23:38:03 host [<c031916b>] inet_diag_rcv+0x19/0x24
> Jan 26 23:38:03 host [<c02df0e0>] netlink_unicast+0x1fa/0x224
> Jan 26 23:38:03 host [<c02df86e>] netlink_sendmsg+0x1d0/0x2b2
> Jan 26 23:38:03 host [<c01690a7>] permission+0x51/0xe7
> Jan 26 23:38:03 host [<c02c1423>] sock_sendmsg+0xbb/0xdd
> Jan 26 23:38:03 host [<c012c951>] autoremove_wake_function+0x0/0x37
> Jan 26 23:38:03 host [<c013090c>] __atomic_notifier_call_chain+0x24/0x4a
> Jan 26 23:38:03 host [<c0130949>] atomic_notifier_call_chain+0x17/0x1b
> Jan 26 23:38:03 host [<c0251ad0>] notify_update+0x1f/0x23
> Jan 26 23:38:03 host [<c0253f0f>] do_con_write+0x33d/0x1aac
> Jan 26 23:38:03 host [<c0253f0f>] do_con_write+0x33d/0x1aac
> Jan 26 23:38:03 host [<c02c8369>] verify_iovec+0x2a/0x91
> Jan 26 23:38:03 host [<c02c1572>] sys_sendmsg+0x12d/0x243
> Jan 26 23:38:03 host [<c024b40f>] n_tty_ioctl+0x0/0x1e1
> Jan 26 23:38:03 host [<c0247475>] tty_ioctl+0x114/0xeb5
> Jan 26 23:38:03 host [<c0142987>] find_lock_page+0x20/0xab
> Jan 26 23:38:03 host [<c0144d19>] filemap_fault+0x1d4/0x43e
> Jan 26 23:38:03 host [<c02c3618>] sk_prot_alloc+0x70/0x8a
> Jan 26 23:38:03 host [<c02c4d19>] sk_alloc+0x3d/0x47
> Jan 26 23:38:03 host [<c0172eee>] d_alloc+0x1b/0x192
> Jan 26 23:38:03 host [<c0172eb3>] d_instantiate+0x3b/0x5b
> Jan 26 23:38:03 host [<c02c1161>] sock_attach_fd+0x77/0xa2
> Jan 26 23:38:03 host [<c02c27d8>] sys_socketcall+0x24f/0x271
> Jan 26 23:38:03 host [<c0115952>] do_page_fault+0x0/0x5ce
> Jan 26 23:38:03 host [<c0103e72>] sysenter_past_esp+0x5f/0x85
> Jan 26 23:38:03 host [<c0350000>] __xfrm6_tunnel_spi_lookup+0x26/0x72
> Jan 26 23:38:03 host =======================
> Jan 26 23:38:03 host Code: ff 55 57 56 53 83 ec 74 89 44 24 18 89 54 24 14 8b
> 5a 04 0f b7 43 04 e8 36 f0 ff ff 85 c0 0f 84 a4 02 00 00 83 c3 10 89 5c 24 28
> <8
> Jan 26 23:38:03 host EIP: [<c031a14f>] inet_diag_dump+0x2a/0x88b SS:ESP
> 0068:e70fdbd0
> Jan 26 23:38:03 host ---[ end trace 57d7a9039abd2ede ]---
> 
> All ss runned later sleep forewer in D state. Kill -9 don't work.
> 
> Steps to reproduce:
> run /sbin/ss -d
> 
> 

