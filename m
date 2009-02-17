From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12698] New: bnx2_poll_work kernel panic
Date: Tue, 17 Feb 2009 14:16:02 -0800
Message-ID: <20090217141602.907e6d97.akpm@linux-foundation.org>
References: <bug-12698-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, pmjdebruijn@pcode.nl,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38164 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752796AbZBQWQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 17:16:53 -0500
In-Reply-To: <bug-12698-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 13 Feb 2009 03:10:16 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12698
> 
>            Summary: bnx2_poll_work kernel panic
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.27.15
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: pmjdebruijn@pcode.nl
> 
> 
> Latest working kernel version: 
>   2.6.22.19
> 
> Earliest failing kernel version: 
>   2.6.27.15 
>   We did not test kernel versions in between 2.6.27.15 and 2.6.22.19

Is a regression.

> Distribution: 
>   Debian GNU/Linux 4.0r6 (fully updated), with self built vanilla kernel.
> 
> Hardware Environment: 
>   HP DL360 G5, with two onboard Broadcom Corporation NetXtreme II BCM5708
> Gigabit Ethernet Controllers
> 
> Software Environment:
>   Debian GNU/Linux 4.0r6 using rsync 3.0.3
> 
> Problem Description:
>   After initializing daily (nightly) rsync backups our backup server panics
> with the following call trace (we've had this issue twice, so we downgraded our
> kernel).
> 
> The following call trace was captured using a digital camera and reproduced as
> the following text:
> 
> [24756.631365] Call Trace:
> [24756.631365]  [<c0108ba8>] nommu_map_single+0x38/0x80
> [24756.631365]  [<c0261e77>] bnx2_poll+0x67/01d0
> [24756.631365]  [<c02e9e47>] net_rx_Action+0x87/0x130
> [24756.631365]  [<c0128b82>] __do_softirq+0x82/0x100
> [24756.631365]  [<c0128da0>] ksoftirqd+0x0/0xf0
> [24756.631365]  [<c0128c37>] do_softirq+0x37/0x40
> [24756.631365]  [<c0128e12>] ksoftirqd+0x72/0xf0
> [24756.631365]  [<c01365d2>] kthread+0x42/0x70
> [24756.631365]  [<c0136590>] kthread+0x0/0x70
> [24756.631365]  [<c0103c2f>] kernel_thread_helper+0x7/0x18
> [24756,631697]  =======================
> [24756.631697] Code: 00 00 00 8b 9c 24 a8 00 00 00 48 83 ea 04 3b 84 24 8c 00
> 00
>  00 0f 45 94 24 88 00 00 00 89 24 88 00 00 00 8b 94 24 8c 00 00 00 <8b> 0e 8d
>  04 52 8b 93 8c 00 00 00 8d 04 85 10 00 00 00 01 d0 8d
> [24756.631925] EIP: [<c02613d6>] bnx2_poll_work+0xa0d/0x1010 SS:ESP
> 0068:f787fea8
> [24756.632218] Kernel panic - not syncing: Fatal exception in interrupt
> 
> Steps to reproduce:
> 1. Boot server using 2.6.27.15 kernel
> 2. Start several (about 10) simultaneous rsync processes to the server
> 3. Wait for crash
> 

There's a partial screenshot in bugzilla.  It crashed in
bnx2_poll_work().
