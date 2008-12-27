From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12306] New: unable to handle kernel paging
 request at ffff8900c6685e00
Date: Sat, 27 Dec 2008 00:29:17 -0800
Message-ID: <20081227002917.df13f930.akpm@linux-foundation.org>
References: <bug-12306-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, antonprk@mail.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35555 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751455AbYL0I3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2008 03:29:54 -0500
In-Reply-To: <bug-12306-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 26 Dec 2008 22:17:29 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12306
> 
>            Summary: unable to handle kernel paging request at
>                     ffff8900c6685e00
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: Linux host.name.hiden 2.6.28 #1 SMP Thu Dec 25 07:28:00
>                     MSK 2008
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: drivers_other@kernel-bugs.osdl.org
>         ReportedBy: antonprk@mail.ru

2.6.28 crashed in tcp_recvmsg.

> 
> Latest working kernel version: none
> Earliest failing kernel version: 2.6.26.5

And apparently 2.6.26.5 does the same thing?

I would be suspecting a hardware failure here.  Can we have more
details please?  Some additional oops traces from this or earlier
kenrels might help.

Is the failure seen on other machines, or just this one?


> Distribution:
> Hardware Environment: Intel(R) Core(TM)2 CPU 6320  @ 1.86GHz
> Software Environment: Web Server
> Problem Description: Server crash
> 
> Kernel report in syslog:
> kernel: dcpumon[26379]: segfault at 7fff225fd1c8 ip 00000000004c142f sp
> 00007fff225e01f0 error 6 in dcpumon[400000+d3000]
> kernel: 3w-9xxx: scsi0: ERROR: (0x03:0x010D): Invalid field in CDB:.
> kernel: mkbb.sh[5721]: segfault at 10000000000 ip 0000000000425080 sp
> 00007fffb30e2560 error 4 in bash[400000+ab000]
> kernel: BUG: unable to handle kernel paging request at ffff8900c6685e00
> kernel: IP: [<ffffffff804f57e5>] tcp_recvmsg+0x265/0xca0
> kernel: PGD 0 
> kernel: Oops: 0002 [#1] SMP 
> kernel: last sysfs file:
> /sys/devices/pci0000:00/0000:00:1c.0/0000:09:00.0/0000:0a:01.0/host0/target0:0:0/0:0:0:0/vendor
> kernel: CPU 0 
> kernel: Modules linked in: piix ide_core
> kernel: Pid: 31968, comm: httpd Not tainted 2.6.28 #1
> kernel: RIP: 0010:[<ffffffff804f57e5>]  [<ffffffff804f57e5>]
> tcp_recvmsg+0x265/0xca0
> kernel: RSP: 0018:ffff8800d1a63c98  EFLAGS: 00010296
> kernel: RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00000000c0000100
> kernel: RDX: 0000000000000000 RSI: ffff8800d1a63c38 RDI: ffff8800ca15caf0
> kernel: RBP: 0000000000000000 R08: 00000000ffffffff R09: 0000000000000000
> kernel: R10: ffff880219dd5da8 R11: 0000000000000000 R12: ffff8900c66859c0
> kernel: R13: ffff8800c6685a68 R14: ffff8800c6685dac R15: 00000000ffffff95
> kernel: FS:  00007f7c10d286e0(0000) GS:ffffffff80757500(0000)
> knlGS:0000000000000000
> kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> kernel: CR2: ffff8900c6685e00 CR3: 0000000019bb3000 CR4: 00000000000006e0
> kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> kernel: Process httpd (pid: 31968, threadinfo ffff8800d1a62000, task
> ffff880148778050)
> kernel: Stack:
> kernel:  00000001000000be 0000000000000001 ffff880148778050 ffff8800d1a63e68
> kernel:  0000000000000000 0000000000001000 ffff8800d1a63d80 00000000000000be
> kernel:  0000000000bb4b84 7fffffffffffffff 000005b400002238 ffff8800d1a63d80
> kernel: Call Trace:
> kernel:  [<ffffffff804b40b0>] sock_common_recvmsg+0x30/0x50
> kernel:  [<ffffffff804af9df>] sock_aio_read+0x10f/0x120
> kernel:  [<ffffffff8029e73b>] do_sync_read+0xdb/0x140
> kernel:  [<ffffffff802521e0>] autoremove_wake_function+0x0/0x30
> kernel:  [<ffffffff8034468e>] _atomic_dec_and_lock+0x4e/0x80
> kernel:  [<ffffffff802b4981>] mntput_no_expire+0x21/0x120
> kernel:  [<ffffffff8024aa8f>] do_sigaction+0xff/0x1c0
> kernel:  [<ffffffff8029e901>] vfs_read+0x161/0x170
> kernel:  [<ffffffff8029ec13>] sys_read+0x53/0x90
> kernel:  [<ffffffff8020b61b>] system_call_fastpath+0x16/0x1b
> kernel: Code: 24 20 04 00 00 0f 84 c6 06 00 00 8b 54 24 08 39 54 24 20 0f 8c 80
> 03 00 00 4c 89 e7 e8 85 d9 fb ff 31 f6 4c 89 e7 e8 9b d8 fb ff <41> c7 84 24 40
> 04 00 00 00 00 00 00 48 83 7c 24 10 00 74 4f 8b 
> kernel: RIP  [<ffffffff804f57e5>] tcp_recvmsg+0x265/0xca0
> kernel:  RSP <ffff8800d1a63c98>
> kernel: CR2: ffff8900c6685e00
> kernel: ---[ end trace 7b4209a86045831c ]---
> 
> 
> 
> Other:
> #cat
> /sys/devices/pci0000:00/0000:00:1c.0/0000:09:00.0/0000:0a:01.0/host0/target0:0:0/0:0:0:0/vendor
> 
> AMCC    
> 
> 
> # free -m
>              total       used       free     shared    buffers     cached
> Mem:          8005       7960         44          0        560       6622
> -/+ buffers/cache:        777       7227
> Swap:        16386         34      16352
> 
> #cat /etc/redhat-release
> 
> CentOS release 4.7 (Final)
> 

