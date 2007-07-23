From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8797] New: WARNING from skb_gso_segment
Date: Mon, 23 Jul 2007 12:49:12 -0700
Message-ID: <20070723124912.f43c53bb.akpm@linux-foundation.org>
References: <bug-8797-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, hmkash@arl.army.mil
To: netdev@vger.kernel.org, wensong@linux-vs.org, horms@verge.net.au,
	ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47572 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933951AbXGWTtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 15:49:51 -0400
In-Reply-To: <bug-8797-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Jul 2007 09:36:08 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8797
> 
>            Summary: WARNING from skb_gso_segment
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@osdl.org
>         ReportedBy: hmkash@arl.army.mil
>                 CC: herbert@gondor.apana.org.au
> 
> 
> Most recent kernel where this bug did not occur: 2.6.20.4
> 
> Distribution: kernel.org
> 
> Hardware Environment: x86, dual-core Xeon, tg3, e1000
> 
> Software Environment: ip_vs, bonding
> 
> Problem Description: After upgrading kernels from 2.6.20.4 to 2.6.22.1, I
> started getting tons (27,000+ a day) of the warning messages below resulting
> from this change:
> 
> http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.22.y.git;a=commitdiff;h=f9d106a6d53b57b78eae5544f9582c643343a764
> 
> This is on a system that uses ip_vs to load balance DNS traffic. Other than
> these warnings, everything appears to be normal with the load balanced DNS
> traffic.
> 
> Jul 17 09:29:40 hlb1 kernel: WARNING: at net/core/dev.c:1286 skb_gso_segment()
> Jul 17 09:29:40 hlb1 kernel:  [<c024d0c8>] skb_gso_segment+0x92/0x184
> Jul 17 09:29:40 hlb1 kernel:  [<c024d224>] dev_gso_segment+0x10/0x34
> Jul 17 09:29:40 hlb1 kernel:  [<c024d293>] dev_hard_start_xmit+0x4b/0xb1
> Jul 17 09:29:40 hlb1 kernel:  [<c024d46b>] dev_queue_xmit+0x172/0x1fd
> Jul 17 09:29:40 hlb1 kernel:  [<c0267828>] ip_output+0x274/0x2ad
> Jul 17 09:29:40 hlb1 kernel:  [<c02673a7>] ip_finish_output+0x0/0x20d
> Jul 17 09:29:40 hlb1 kernel:  [<c0267bbf>] ip_queue_xmit+0x35e/0x3a6
> Jul 17 09:29:40 hlb1 kernel:  [<e0a2550c>] do_ip_vs_get_ctl+0x6f5/0x704 [ip_vs]
> Jul 17 09:29:40 hlb1 kernel:  [<c0267828>] ip_output+0x274/0x2ad
> Jul 17 09:29:40 hlb1 kernel:  [<e0a2687f>] ip_vs_dr_xmit+0x345/0x37b [ip_vs]
> Jul 17 09:29:40 hlb1 kernel:  [<c02a336a>] _spin_lock_bh+0x8/0x10
> Jul 17 09:29:40 hlb1 kernel:  [<c0276547>] tcp_cwnd_restart+0x17/0xad
> Jul 17 09:29:40 hlb1 kernel:  [<c0276cbe>] tcp_transmit_skb+0x3e0/0x402
> Jul 17 09:29:40 hlb1 kernel:  [<c0277846>] tso_fragment+0x15a/0x194
> Jul 17 09:29:40 hlb1 kernel:  [<c0277f91>] tcp_write_xmit+0x1cc/0x22e
> Jul 17 09:29:40 hlb1 kernel:  [<c0278004>] __tcp_push_pending_frames+0x11/0x60
> Jul 17 09:29:40 hlb1 kernel:  [<c026e430>] tcp_sendmsg+0x9df/0xa95
> Jul 17 09:29:40 hlb1 kernel:  [<c0287133>] inet_sendmsg+0x39/0x43
> Jul 17 09:29:40 hlb1 kernel:  [<c0243be2>] do_sock_write+0xab/0xb2
> Jul 17 09:29:40 hlb1 kernel:  [<c0243c39>] sock_aio_write+0x50/0x5c
> Jul 17 09:29:40 hlb1 kernel:  [<c015c008>] do_sync_write+0xbf/0xfc
> Jul 17 09:29:40 hlb1 kernel:  [<c02a2b70>] mutex_lock+0x13/0x22
> Jul 17 09:29:40 hlb1 kernel:  [<c0129232>] autoremove_wake_function+0x0/0x33
> Jul 17 09:29:40 hlb1 kernel:  [<c02472ad>] sock_common_getsockopt+0x1c/0x21
> Jul 17 09:29:40 hlb1 kernel:  [<c0244c49>] sys_getsockopt+0x7d/0x9c
> Jul 17 09:29:40 hlb1 kernel:  [<c015c10e>] vfs_write+0xc9/0x133
> Jul 17 09:29:40 hlb1 kernel:  [<c015c220>] sys_write+0x41/0x67
> Jul 17 09:29:40 hlb1 kernel:  [<c0103002>] sysenter_past_esp+0x5f/0x85
> Jul 17 09:29:40 hlb1 kernel:  =======================
> 
> 
> Steps to reproduce: Unsure
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
