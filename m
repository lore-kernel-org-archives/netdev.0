From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9208] New: Oops on sky2, delete_module causes
 SIGKILL
Date: Mon, 22 Oct 2007 11:12:35 -0700
Message-ID: <20071022111235.266a10df.akpm@linux-foundation.org>
References: <bug-9208-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, jkarlson@cc.hut.fi,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39382 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754024AbXJVSMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 14:12:41 -0400
In-Reply-To: <bug-9208-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Oct 2007 06:58:37 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9208
> 
>            Summary: Oops on sky2, delete_module causes SIGKILL
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: linux-2.6.23-git17
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: jkarlson@cc.hut.fi
> 
> 
> Most recent kernel where this bug did not occur:
> linux-2.6.23-git-13
> 
> Distribution:
> gentoo
> 
> Hardware Environment:
> macbook revision2
> 
> Software Environment:
> gcc-4.2.2, glibc-2.6.1-r0, 2.6.23-git14...17 x86_64
> sys-devel/binutils:  2.18-r1
> sys-apps/module-init-tools-3.2.2-r3
> 
> Problem Description:
> on dmesg
> 
> sky2 eth0: enabling interface
> sky2 eth0: Link is up at 100 Mbps, full duplex, flow control both
> hda: selected mode 0x44
> appletouch: incomplete data package (first byte: 2, length: 4).
> Unable to handle kernel NULL pointer dereference at 00000000000003b0 RIP: 
>  [<ffffffff804ae161>] unregister_netdevice+0x21/0x180
> PGD abb2067 PUD 3ee9067 PMD 0 
> Oops: 0000 [1] SMP 
> CPU 1 
> Modules linked in: snd_hda_intel snd_pcm snd_page_alloc i2c_i801 sky2
> Pid: 4791, comm: modprobe Not tainted 2.6.23-git17 #2
> RIP: 0010:[<ffffffff804ae161>]  [<ffffffff804ae161>]
> unregister_netdevice+0x21/0x180
> RSP: 0018:ffff81000a9addf8  EFLAGS: 00010246
> RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00000000ffffffff
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff80639050
> RBP: ffff810003da5e80 R08: 0000000000000000 R09: 000000000000102a
> R10: 0000000000000000 R11: ffffffff8029f6a0 R12: ffff8100022c0800
> R13: ffffffff8800c440 R14: ffffffff8800c498 R15: ffffffff8800c490
> FS:  00002b16510c3b00(0000) GS:ffff810002076e40(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00000000000003b0 CR3: 000000000aaf4000 CR4: 00000000000026e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process modprobe (pid: 4791, threadinfo ffff81000a9ac000, task
> ffff810003e1a740)
> Stack:  0000000000000000 ffffffff804ae2d1 0000000000000000 ffffffff88004670
>  ffff8100022c0870 ffff8100022c0800 ffff8100022c6870 ffffffff80393a4c
>  ffffffff8800c440 ffff8100022c0870 ffffffff8800c440 ffffffff803f91c2
> Call Trace:
>  [<ffffffff804ae2d1>] unregister_netdev+0x11/0x20
>  [<ffffffff88004670>] :sky2:sky2_remove+0x40/0xf0
>  [<ffffffff80393a4c>] pci_device_remove+0x2c/0x60
>  [<ffffffff803f91c2>] __device_release_driver+0x82/0xc0
>  [<ffffffff803f9805>] driver_detach+0xf5/0x100
>  [<ffffffff803f8c2d>] bus_remove_driver+0x8d/0xb0
>  [<ffffffff80393ab8>] pci_unregister_driver+0x18/0x90
>  [<ffffffff8025e19d>] sys_delete_module+0x14d/0x1e0
>  [<ffffffff80384e82>] __up_write+0x22/0x130
>  [<ffffffff8020bc5e>] system_call+0x7e/0x83
> 
> 
> Code: 8b 83 b0 03 00 00 85 c0 75 39 48 89 da 48 89 de 48 c7 c7 20 
> RIP  [<ffffffff804ae161>] unregister_netdevice+0x21/0x180
>  RSP <ffff81000a9addf8>
> CR2: 00000000000003b0
> 
> 
> Steps to reproduce:
> rmmod sky2
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
