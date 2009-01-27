From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12552] New: held lock freed in tcp
Date: Tue, 27 Jan 2009 10:19:07 -0800
Message-ID: <20090127101907.89833157.akpm@linux-foundation.org>
References: <bug-12552-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, johannes@sipsolutions.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55770 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754201AbZA0SUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 13:20:21 -0500
In-Reply-To: <bug-12552-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 27 Jan 2009 09:59:06 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12552
> 
>            Summary: held lock freed in tcp
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.29-rc2-wl-11979-gc32422d-dirty
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: johannes@sipsolutions.net
> 
> 
> Latest working kernel version: ?
> Earliest failing kernel version: ?
> Distribution: debian/unstable
> Hardware Environment: macbook5,1
> Software Environment:
> Problem Description:
> 
> Steps to reproduce:
> 
> Not always reproducible, I was running iperf against a peer that suddenly lost
> its link due to another bug...
> 
> [  598.850133] 
> [  598.850136] =========================
> [  598.850141] [ BUG: held lock freed! ]
> [  598.850143] -------------------------
> [  598.850147] swapper/0 is freeing memory ffff88007a389300-ffff88007a389c07,
> with a lock still held there!
> [  598.850151]  (&icsk->icsk_retransmit_timer){-+..}, at: [<ffffffff80252080>]
> run_timer_softirq+0x110/0x290
> [  598.850163] 1 lock held by swapper/0:
> [  598.850165]  #0:  (&icsk->icsk_retransmit_timer){-+..}, at:
> [<ffffffff80252080>] run_timer_softirq+0x110/0x290
> [  598.850173] 
> [  598.850174] stack backtrace:
> [  598.850178] Pid: 0, comm: swapper Not tainted
> 2.6.29-rc2-wl-11979-gc32422d-dirty #24
> [  598.850180] Call Trace:
> [  598.850183]  <IRQ>  [<ffffffff8027111f>] print_freed_lock_bug+0xbf/0xd0
> [  598.850193]  [<ffffffff80272d34>] debug_check_no_locks_freed+0x74/0xc0
> [  598.850199]  [<ffffffff802d78aa>] kmem_cache_free+0x7a/0xf0
> [  598.850206]  [<ffffffff8053a4a0>] ? tcp_write_timer+0x0/0x220
> [  598.850211]  [<ffffffff804e7206>] sk_free+0x86/0x100
> [  598.850215]  [<ffffffff8053a550>] tcp_write_timer+0xb0/0x220
> [  598.850219]  [<ffffffff8025210a>] run_timer_softirq+0x19a/0x290
> [  598.850223]  [<ffffffff80252080>] ? run_timer_softirq+0x110/0x290
> [  598.850228]  [<ffffffff8024d51d>] __do_softirq+0x9d/0x190
> [  598.850234]  [<ffffffff8020cebc>] call_softirq+0x1c/0x40
> [  598.850238]  [<ffffffff8020e1a5>] do_softirq+0x75/0xc0
> [  598.850242]  [<ffffffff8024d025>] irq_exit+0x85/0xb0
> [  598.850246]  [<ffffffff8020e441>] do_IRQ+0xa1/0x150
> [  598.850250]  [<ffffffff8020c6d3>] ret_from_intr+0x0/0xf
> 
> 

