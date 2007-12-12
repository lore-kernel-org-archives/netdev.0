From: Rik van Riel <riel@redhat.com>
Subject: Re: 2.6.24-rc4-mm1
Date: Tue, 11 Dec 2007 23:16:18 -0500
Message-ID: <20071211231618.4cf0460b@bree.surriel.com>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60000 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751892AbXLLEQY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 23:16:24 -0500
In-Reply-To: <20071204211701.994dfce6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Dec 2007 21:17:01 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> Changes since 2.6.24-rc3-mm2:

2.6.24-rc4-mm1 brought a nice TCP oops on my x86_64 system, while I
was stress-testing the VM and watching via ssh:

general protection fault: 0000 [1] SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:1c.5/0000:04:00.0/irq
CPU 1 
Modules linked in: nfs lockd nfs_acl rfcomm l2cap bluetooth autofs4 sunrpc ipv6 acpi_cpufreq dm_multipath parport_pc e1000e parport firewire_ohci button i2c_i801 i2c_core i82975x_edac pcspkr firewire_core serio_raw edac_core rtc_cmos floppy crc_itu_t sg sr_mod cdrom pata_marvell ata_piix dm_snapshot dm_zero dm_mirror dm_mod ahci libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd
Pid: 2946, comm: sshd Not tainted 2.6.24-rc4-mm1 #1
RIP: 0010:[<ffffffff81227add>]  [<ffffffff81227add>] __tcp_rb_insert+0x1a/0x67
RSP: 0018:ffff810066401c88  EFLAGS: 00010202
RAX: 6b6b6b6b6b6b6b6b RBX: ffff810076e9f000 RCX: ffff81003ddc9900
RDX: 6b6b6b6b6b6b6bab RSI: ffff81006ed1b148 RDI: 6b6b6b6b6b6b6b5b
RBP: ffff81006ed1aa00 R08: ffff810076e9f010 R09: 00000000bef8d64e
R10: ffffffff81228926 R11: ffffffff8110b2aa R12: ffff810066401de8
R13: 00000000000000e0 R14: ffff810066401ee8 R15: 0000000000000001
FS:  00007f1c2c10d780(0000) GS:ffff81007f801578(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000002aabfd3 CR3: 00000000665e3000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process sshd (pid: 2946, threadinfo ffff810066400000, task ffff8100665ce000)
Stack:  ffff81003ddc9900 ffffffff81228b26 0000000000000000 0000000100000000
 ffff810066401ee8 00000000810574da 000004e000000040 000000e0000004e0
 00007f1c2c797620 0000000000000246 0000000066401d60 0000000000000000
Call Trace:
 [<ffffffff81228b26>] tcp_sendmsg+0x21f/0xb00
 [<ffffffff811f0435>] sock_aio_write+0xf8/0x110
 [<ffffffff810a9451>] do_sync_write+0xc9/0x10c
 [<ffffffff811071d3>] file_has_perm+0x9a/0xa9
 [<ffffffff8104e29a>] autoremove_wake_function+0x0/0x2e
 [<ffffffff81059db6>] __lock_acquire+0x50f/0xc8e
 [<ffffffff810574da>] lock_release_holdtime+0x27/0x48
 [<ffffffff810a9c53>] vfs_write+0xd9/0x16f
 [<ffffffff810aa1fd>] sys_write+0x45/0x6e
 [<ffffffff8100c0ba>] tracesys+0xdc/0xe1


Code: 44 3b 4a 1c 79 10 44 3b 4a 18 78 04 0f 0b eb fe 48 8d 50 10 
RIP  [<ffffffff81227add>] __tcp_rb_insert+0x1a/0x67
 RSP <ffff810066401c88>


-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
