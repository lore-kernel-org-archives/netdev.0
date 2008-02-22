From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10061] New: Hang in md5_resync
Date: Thu, 21 Feb 2008 17:07:37 -0800
Message-ID: <20080221170737.94ad17cb.akpm@linux-foundation.org>
References: <bug-10061-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: sgunderson@bigfoot.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:52779 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751438AbYBVBRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 20:17:50 -0500
In-Reply-To: <bug-10061-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(please respond via emailed reply-to-all, not via the bugzilla web
interface, thanks)

On Thu, 21 Feb 2008 13:13:13 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10061
> 
>            Summary: Hang in md5_resync
>            Product: IO/Storage
>            Version: 2.5
>      KernelVersion: 2.6.25-rc2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: MD
>         AssignedTo: io_md@kernel-bugs.osdl.org
>         ReportedBy: sgunderson@bigfoot.com
> 
> 
> Latest working kernel version: 2.6.23
> Earliest failing kernel version: 2.6.25-rc2
> Distribution: Debian unstable
> Hardware Environment: sata_nv, ext3, Seagate SATA disks 
> Software Environment: N/A
> Problem Description: After upgrading to 2.6.25, I did some light I/O (basically
> a tab-complete in my home directory), and the whole machine promptly hung.
> After a while, the serial console spat out:
> 
> [  548.684064] BUG: soft lockup - CPU#1 stuck for]
> [  548.684065] CPU 1:
> [  548.684065] Modules linked in: tun eeprom ide_generic ide_disk ide_cd_mod
> cdx
> [  548.684065] Pid: 3599, comm: md4_resync Not tainted 2.6.25-rc2 #1
> [  548.684065] RIP: 0010:[<ffffffff802fee07>]  [<ffffffff802fee07>]
> __write_loc0
> [  548.684065] RSP: 0018:ffff81011fcffc18  EFLAGS: 00000287
> [  548.684065] RAX: ffff81011c14dfd8 RBX: ffff8100d42d30c0 RCX:
> ffff8100d42d30c0
> [  548.684065] RDX: 0000000000000000 RSI: ffff8100d4cd0d90 RDI:
> ffff8100d4cd0d00
> [  548.684065] RBP: ffff81011fcffb90 R08: 00000000fe538a93 R09:
> 0000000000000000
> [  548.684065] R10: 00000000000000c0 R11: ffffffff803ad3e1 R12:
> ffffffff8020bcb6
> [  548.684065] R13: ffff81011fcffb90 R14: ffff8100d4cd0d00 R15:
> 0000000000000000
> [  548.684065] FS:  00007f8748e0c6e0(0000) GS:ffff81011fcb5dc0(0000)
> knlGS:00000
> [  548.684065] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> [  548.684066] CR2: 00007f8748e076f3 CR3: 00000000d296b000 CR4:
> 00000000000006e0
> [  548.684066] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [  548.684066] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [  548.684066]
> [  548.684066] Call Trace:
> [  548.684066]  <IRQ>  [<ffffffff80446fe4>] ? _write_lock_bh+0x1a/0x1c
> [  548.684066]  [<ffffffff803ad49e>] ? neigh_resolve_output+0xbd/0x281
> [  548.684066]  [<ffffffff80407ab5>] ? ip6_output+0xc5c/0xc71
> [  548.684066]  [<ffffffff8039d414>] ? sock_alloc_send_skb+0x93/0x1e1
> [  548.684066]  [<ffffffff8041685b>] ? __ndisc_send+0x3c6/0x4fb
> [  548.684066]  [<ffffffff880a431a>] ? :sd_mod:sd_prep_fn+0x74/0x6fb
> [  548.684066]  [<ffffffff8041725b>] ? ndisc_send_ns+0x71/0x7e
> [  548.684066]  [<ffffffff80363c3c>] ? scsi_request_fn+0x339/0x3a5
> [  548.684066]  [<ffffffff804181df>] ? ndisc_solicit+0x159/0x166
> [  548.684066]  [<ffffffff80235673>] ? __mod_timer+0xb0/0xbf
> [  548.684066]  [<ffffffff803adc72>] ? neigh_timer_handler+0x292/0x2d0
> [  548.684066]  [<ffffffff803ad9e0>] ? neigh_timer_handler+0x0/0x2d0
> [  548.684066]  [<ffffffff8023521b>] ? run_timer_softirq+0x151/0x1bf
> [  548.684066]  [<ffffffff80231f40>] ? __do_softirq+0x65/0xcf
> [  548.684066]  [<ffffffff8020c20c>] ? call_softirq+0x1c/0x28
> [  548.684066]  [<ffffffff8020d8b4>] ? do_softirq+0x2c/0x68
> [  548.684066]  [<ffffffff8021919d>] ? smp_apic_timer_interrupt+0x8a/0xa5
> [  548.684066]  [<ffffffff8020bcb6>] ? apic_timer_interrupt+0x66/0x70
> [  548.684066]  <EOI>  [<ffffffff880d549c>] ?
> :raid456:raid5_compute_sector+0x19
> [  548.684066]  [<ffffffff880d5511>] ? :raid456:stripe_to_pdidx+0x48/0x51
> [  548.684066]  [<ffffffff880db728>] ? :raid456:sync_request+0x7d3/0x8a1
> [  548.684066]  [<ffffffff802edf17>] ? generic_unplug_device+0x18/0x24
> [  548.684066]  [<ffffffff802ecdef>] ? blk_unplug+0x5a/0x60
> [  548.684066]  [<ffffffff880d51af>] ? :raid456:unplug_slaves+0x55/0x91
> [  548.684066]  [<ffffffff880b0884>] ? :md_mod:md_do_sync+0x54e/0x96c
> [  548.684066]  [<ffffffff802429a7>] ? getnstimeofday+0x2f/0x83
> [  548.684066]  [<ffffffff802263e0>] ? try_to_wake_up+0xfd/0x10e
> [  548.684066]  [<ffffffff880b2ff6>] ? :md_mod:md_thread+0xde/0xfa
> [  548.684066]  [<ffffffff880b2f18>] ? :md_mod:md_thread+0x0/0xfa
> [  548.684066]  [<ffffffff8023e741>] ? kthread+0x47/0x76
> [  548.684066]  [<ffffffff80228ebd>] ? schedule_tail+0x28/0x5c
> [  548.684066]  [<ffffffff8020be98>] ? child_rip+0xa/0x12
> [  548.684066]  [<ffffffff8023e6fa>] ? kthread+0x0/0x76
> [  548.684066]  [<ffffffff8020be8e>] ? child_rip+0x0/0x12
> [  548.684066]
> 
> and the machine continued hanging.
> 
> Downgraded to 2.6.23 again, seems to work fine. Will try 2.6.24.2 shortly.

This looks like a networking regression, not a RAID regression.

We did have a big locking bug in netlink in 2.6.25-rc2, although your trace
doesn't appear to point at that particular bug.

It would be good if you could test the latest Linux snapshot please, see if
we've already fixed this, thanks.
