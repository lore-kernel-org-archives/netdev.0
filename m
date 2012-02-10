From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 42754] New: BUG: sleeping function called from invalid
 context at mm/memory.c:3924
Date: Thu, 9 Feb 2012 19:13:17 -0800
Message-ID: <20120209191317.2fbad57b.akpm@linux-foundation.org>
References: <bug-42754-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: baryluk@smp.if.uj.edu.pl, bugzilla-daemon@bugzilla.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:58010 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484Ab2BJDM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 22:12:26 -0500
In-Reply-To: <bug-42754-27@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

(It's 3.3-rc2)

On Fri, 10 Feb 2012 02:24:10 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=42754
> 
>            Summary: BUG: sleeping function called from invalid context at
>                     mm/memory.c:3924
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.3.0-rc2+
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: baryluk@smp.if.uj.edu.pl
>         Regression: Yes
> 
> 
> Created an attachment (id=72350)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=72350)
> Konfig file
> 
> [    0.000000] Linux version 3.3.0-rc2-t43-devel-smp-00172-g23783f8
> (baryluk@sredniczarny) (gcc version 4.6.2 (Debian 4.6.2-12) ) #13 SMP Sun Feb 5
> 15:37:06 CET 2012
> 
> 
> [ 1203.050623] BUG: sleeping function called from invalid context at
> mm/memory.c:3924
> [ 1203.054259] in_atomic(): 1, irqs_disabled(): 0, pid: 4446, name:
> NetworkManager
> [ 1203.057932] INFO: lockdep is turned off.
> [ 1203.061685] Pid: 4446, comm: NetworkManager Tainted: G        W  O
> 3.3.0-rc2-t43-devel-smp-00172-g23783f8 #13
> [ 1203.065606] Call Trace:
> [ 1203.069502]  [<c107e182>] __might_sleep+0x122/0x1d0
> [ 1203.073506]  [<c1140b4e>] might_fault+0x2e/0xb0
> [ 1203.077501]  [<c131c67b>] copy_to_user+0x3b/0x60
> [ 1203.081561]  [<c158a102>] put_cmsg+0x52/0xd0
> [ 1203.085624]  [<c15bc7d7>] netlink_recvmsg+0x287/0x340
> [ 1203.089740]  [<c1579b43>] sock_recvmsg+0xd3/0x110
> [ 1203.093902]  [<c1140b74>] ? might_fault+0x54/0xb0
> [ 1203.098093]  [<c158834c>] ? verify_iovec+0x4c/0xc0
> [ 1203.102336]  [<c1579a70>] ? sock_sendmsg_nosec+0x100/0x100
> [ 1203.106611]  [<c157a994>] __sys_recvmsg+0x114/0x1e0
> [ 1203.110942]  [<c1081dc7>] ? finish_task_switch+0x77/0x200
> [ 1203.115315]  [<c11784b5>] ? fget_light+0xc5/0x410
> [ 1203.119722]  [<c1081dc7>] ? finish_task_switch+0x77/0x200
> [ 1203.124167]  [<c11784c9>] ? fget_light+0xd9/0x410
> [ 1203.128618]  [<c1178435>] ? fget_light+0x45/0x410
> [ 1203.133102]  [<c157c659>] sys_recvmsg+0x39/0x60
> [ 1203.137590]  [<c157cbb3>] sys_socketcall+0x2e3/0x330
> [ 1203.142147]  [<c17cf58d>] ? sysenter_exit+0xf/0x1a
> [ 1203.146707]  [<c131be78>] ? trace_hardirqs_on_thunk+0xc/0x10
> [ 1203.151358]  [<c17cf558>] sysenter_do_call+0x12/0x38
> [ 1203.155980] BUG: scheduling while atomic: NetworkManager/4446/0x10000002
> [ 1203.160714] INFO: lockdep is turned off.
> [ 1203.165429] Modules linked in: vfat fat pci_stub vboxpci(O) vboxnetadp(O)
> vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables acpi_cpufreq mperf
> xt_CHECKSUM irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep rfcomm
> bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 radeon
> ipw2200 libipw pcmcia_rsrc pcmcia_core ttm drm_kms_helper parport_pc parport
> cfbfillrect cfbcopyarea cfbimgblt raid10 raid456 async_memcpy async_pq
> async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom floppy [last
> unloaded: scsi_wait_scan]


OK, so we have a pile of in_atomic warnings.  I assume the above was
the first to come out?  The third and following traces have a different
trace.

It might be a bug in the netlink code or thereabouts.  Or it might be that
some random unrelated piece of kernel code forgot to release a lock and
netlink was the first place where this was detected.

Peter, is there any way in which lockdep can help us find the culprit
in the second case?

Thanks.
