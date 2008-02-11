From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9937] New: Bug in bonding driver - Kernel oops
 whenever driver is loaded with max_bonds parameter
Date: Mon, 11 Feb 2008 15:56:08 -0800
Message-ID: <20080211155608.b60858d7.akpm@linux-foundation.org>
References: <bug-9937-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, kantica@gmail.com
To: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50806 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752281AbYBKX4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 18:56:25 -0500
In-Reply-To: <bug-9937-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Feb 2008 15:04:03 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9937
> 
>            Summary: Bug in bonding driver - Kernel oops whenever driver is
>                     loaded with max_bonds parameter
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: kantica@gmail.com
> 
> 
> Latest working kernel version:
> Earliest failing kernel version: 2.6.24.2
> Distribution: Slackware / Debian GNU/Linux
> Hardware Environment: HP ProLiant DL380 G5 (Debian), Slackware Acer TravelMate
> 4001 Laptop
> Software Environment: 
> Problem Description: Kernel oops whenever bonding driver with max_bonds=2 (or >
> 2) is loaded ...
> 
> Steps to reproduce:
> 
> modprobe bonding mode=0 miimon=100 max_bonds=2 
> or
> modprobe bonding max_bonds=2 
> 
> 
> dmesg output (from slackware laptop / x86):
> 
> BUG: unable to handle kernel NULL pointer dereference at virtual address
> 00000000
> printing eip: c028eeaf *pde = 00000000
> Oops: 0000 [#1] SMP
> Modules linked in: bonding snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq
> snd_seq_device snd_pcm_oss snd_mixer_oss ntfs pcmcia yenta_socket
> rsrc_nonstatic tifm_7xx1 tifm_core pcmcia_core snd_intel8x0 snd_ac97_codec
> ac97_bus snd_pcm i2c_i801 snd_timer snd i2c_core shpchp snd_page_alloc ehci_hcd
> uhci_hcd pci_hotplug
> 
> Pid: 2729, comm: modprobe Not tainted (2.6.24.2 #2)
> EIP: 0060:[<c028eeaf>] EFLAGS: 00010282 CPU: 0
> EIP is at strnicmp+0x17/0x61
> EAX: d8162800 EBX: 00000000 ECX: 00000010 EDX: 00000062
> ESI: 00000010 EDI: 00000000 EBP: d8162801 ESP: d82c9f60
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process modprobe (pid: 2729, ti=d82c8000 task=df926550 task.ti=d82c8000)
> Stack: d8162c80 00000000 e0c76814 00000000 e0c67170 00000001 df80b700 e0c77180
>        00000001 00000000 0000000c d82c8000 e0afe05e e0c6ed14 e0c6ce70 e0c76c00
>        0805c098 0000000c c014e355 b7e7a008 0805c098 c0106f12 b7e7a008 00019477
> Call Trace:
>  [<e0c67170>] bond_create+0x4a/0x162 [bonding]
>  [<e0afe05e>] bonding_init+0x5e/0xf0 [bonding]
>  [<c014e355>] sys_init_module+0x91/0x11b
>  [<c0106f12>] syscall_call+0x7/0xb
>  [<c0470000>] sctp_setsockopt_bindx+0xe8/0x127
>  =======================
> Code: 08 fe dc ba 98 c7 40 0c 76 54 32 10 c7 40 10 f0 e1 d2 c3 c3 55 89 c5 57
> 89 d7 31 d2 56 89 ce 53 31 db 85 c9 74 42 0f b6 55 00 45 <0f> b6 1f 47 84 d2 74
> 35 84 db 74 31 38 da 74 2a 0f b6 c2 88 d1
> EIP: [<c028eeaf>] strnicmp+0x17/0x61 SS:ESP 0068:d82c9f60
> ---[ end trace 75761717808bf4ee ]---
> 
> dmesg output (from Debian x86_64 - HP ProLiant DL380):
> 
> Unable to handle kernel NULL pointer dereference at 0000000000000000 RIP:
>  [<ffffffff8030271e>] strnicmp+0x12/0x5f
> PGD 223005067 PUD 223b22067 PMD 0
> Oops: 0000 [1] SMP
> CPU 7
> Modules linked in: bonding mptctl mptbase fan ac battery ipv6 dm_snapshot
> dm_mirror dm_mod loop usbhid ide_cd cdrom bnx2 generic thermal ipmi_si piix
> serio_raw evdev shpchp
> psmouse pci_hotplug container pcspkr ide_core ipmi_msghandler uhci_hcd button
> processor ehci_hcd e1000 ext3 jbd mbcache reiserfs cciss
> Pid: 12469, comm: modprobe Not tainted 2.6.24.2 #1
> RIP: 0010:[<ffffffff8030271e>]  [<ffffffff8030271e>] strnicmp+0x12/0x5f
> RSP: 0018:ffff81022339fe00  EFLAGS: 00010202
> RAX: ffff81022307e6c0 RBX: ffffffff88233918 RCX: 00000000000020e7
> RDX: 0000000000000010 RSI: 0000000000000000 RDI: ffff81022307e000
> RBP: 0000000000000000 R08: ffff810223b90362 R09: 0000000000000010
> R10: ffffffff8822d60b R11: 0000000000000001 R12: 0000000000000000
> R13: ffffffff88234b00 R14: ffff81022307e7c8 R15: 0000000000000000
> FS:  00002b07aa3166e0(0000) GS:ffff81022743bd00(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000000 CR3: 000000022339c000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process modprobe (pid: 12469, threadinfo ffff81022339e000, task
> ffff8102239aa000)
> Stack:  ffffffff882200ce ffff8102239ad000 0000000000000001 ffff8102274273c0
>  0000000000000000 0000000000000001 ffffc20011bef960 ffff810225c88540
>  ffffffff8809f7bf ffffffff882340c0 ffffffff882340c0 ffff8102263f7f00
> Call Trace:
>  [<ffffffff882200ce>] :bonding:bond_create+0x4e/0x30e
>  [<ffffffff8809f7bf>] :bonding:bonding_init+0x7bf/0x85d
>  [<ffffffff8024f752>] sys_init_module+0x176d/0x183f
>  [<ffffffff8020be8e>] system_call+0x7e/0x83
> 
> 
> Code: 8a 0e 48 ff c7 48 ff c6 45 84 c0 74 36 84 c9 74 32 41 38 c8
> RIP  [<ffffffff8030271e>] strnicmp+0x12/0x5f
>  RSP <ffff81022339fe00>
> CR2: 0000000000000000
> ---[ end trace ba3d7089e7da64fa ]---
> 

