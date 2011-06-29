From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 38502] New: crash in skbuff.c
Date: Wed, 29 Jun 2011 13:27:14 -0700
Message-ID: <20110629132714.754a0fcf.akpm@linux-foundation.org>
References: <bug-38502-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, mysql.jorge@decimal.pt
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33938 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754242Ab1F2U1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 16:27:22 -0400
In-Reply-To: <bug-38502-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 28 Jun 2011 21:08:17 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=38502
> 
>            Summary: crash in skbuff.c
>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: mysql.jorge@decimal.pt
>         Regression: No
> 
> 
> Hi,
> 
> After I saw a rootkit on my server, that was looping or trying to waste all the
> BW on my eth0 device, i saw this information on kernel, that was caused by it
> (std binary/rootkit).
> 
> -----
> 
> skb_under_panic: text:c11d2a01 len:106 put:14 head:f262d800 data:f262d7f4
> tail:0xf262d85e end:0xf262d880 dev:eth0
> ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:146!
> invalid opcode: 0000 [#1] SMP
> last sysfs file: /sys/devices/virtual/block/md0/md/metadata_version
> Modules linked in: nfs lockd nfs_acl auth_rpcgss sunrpc xt_limit xt_tcpudp
> nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack iptable_filter ip_tables
> x_tables cls_route cls_u32 cls_fw sch_prio sch_sfq sch_tbf sch_cbq dm_mod tulip
> atl1c ipv6 button processor r8169 thermal_sys rtc_cmos rtc_core rtc_lib unix
> 
> Pid: 21077, comm: std Not tainted 2.6.38.8 #1 Gigabyte Technology Co., Ltd.
> H55M-USB3/H55M-USB3
> EIP: 0060:[<c11bd2b7>] EFLAGS: 00010246 CPU: 1
> EIP is at skb_push+0x52/0x5b
> EAX: 00000078 EBX: f2c12000 ECX: c12f5070 EDX: 00000046
> ESI: f2c12000 EDI: f2c12000 EBP: f1785c48 ESP: f1785c1c
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process std (pid: 21077, ti=f1784000 task=e3409310 task.ti=f1784000)
> Stack:
>  c12c03ba c11d2a01 0000006a 0000000e f262d800 f262d7f4 f262d85e f262d880
>  f2c12000 00000000 f1e0489c f1785c60 c11d2a01 00000800 f1e04840 c11d29e5
>  0000005a f1785c94 c11cb52e f1e0489c 00000000 0000005c ee633780 f1785cac
> Call Trace:
>  [<c11d2a01>] ? eth_header+0x1c/0x8b
>  [<c11d2a01>] eth_header+0x1c/0x8b
>  [<c11d29e5>] ? eth_header+0x0/0x8b
>  [<c11cb52e>] neigh_resolve_output+0x21f/0x281
>  [<c11e3634>] ip_finish_output+0x223/0x261
>  [<c11e3d84>] ip_output+0x97/0x9f
>  [<c11e3775>] ip_local_out+0x1b/0x1e
>  [<c11e4c87>] ip_push_pending_frames+0x290/0x31d
>  [<c11fc50f>] udp_push_pending_frames+0x285/0x2e0
>  [<c11fda11>] udp_sendmsg+0x449/0x4f9
>  [<c102830d>] ? irq_exit+0x3c/0x60
>  [<c101128c>] ? smp_apic_timer_interrupt+0x6e/0x7c
>  [<c12240ca>] ? apic_timer_interrupt+0x2a/0x30
>  [<c1202fe0>] inet_sendmsg+0x6f/0x78
>  [<c11b748e>] sock_sendmsg+0xa2/0xba
>  [<c103ff0d>] ? tick_program_event+0x17/0x1c
>  [<c1101317>] ? radix_tree_lookup+0xa/0xc
>  [<c103a0f6>] ? sched_clock_cpu+0x3f/0x11f
>  [<c10389de>] ? hrtimer_forward+0x118/0x130
>  [<c11b74f6>] ? sockfd_lookup_light+0x19/0x48
>  [<c11b852a>] sys_sendto+0xb1/0xd0
>  [<c1010ccd>] ? lapic_next_event+0x16/0x1a
>  [<c103f118>] ? clockevents_program_event+0xb7/0xc9
>  [<c101b484>] ? set_next_entity+0x2c/0x52
>  [<c101cb1c>] ? pick_next_task_fair+0x5b/0x87
>  [<c11b8561>] sys_send+0x18/0x1a
>  [<c11b8bec>] sys_socketcall+0xce/0x189
>  [<c1002610>] sysenter_do_call+0x12/0x26
> Code: c1 85 f6 0f 45 de 53 ff b1 a0 00 00 00 ff b1 9c 00 00 00 50 ff b1 a4 00
> 00 00 52 ff 71 50 ff 75 04 68 ba 03 2c c1 e8 0a 23 06 00 <0f> 0b 8d 65 f8 5b 5e
> 5d c3 55 89 c1 89 e5 56 53 8b 80 9c 00 00
> EIP: [<c11bd2b7>] skb_push+0x52/0x5b SS:ESP 0068:f1785c1c
> ---[ end trace 3ab6b39d8e0aca7f ]---
> 

