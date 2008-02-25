From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10097] New: SMP BUG in __nf_conntrack_find
Date: Mon, 25 Feb 2008 11:11:00 -0800
Message-ID: <20080225111100.b83e9e6b.akpm@linux-foundation.org>
References: <bug-10097-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Patrick McHardy <kaber@trash.net>, casteyde.christian@free.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:47191 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754589AbYBYTM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 14:12:28 -0500
In-Reply-To: <bug-10097-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Feb 2008 10:44:08 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10097
> 
>            Summary: SMP BUG in __nf_conntrack_find
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.25-rc3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: casteyde.christian@free.fr
> 
> 
> Latest working kernel version: 2.6.24.2
> Earliest failing kernel version: 2.6.24-rc3 (not checked before)
> Distribution: Bluewhite64
> Hardware Environment: Athlon X2 4200
> 
> Software Environment:
> samba 3.0, 2.6.25-rc3 kernel + HR + tickless + kernel SMP debugging
> 
> Problem Description:
> The Samba smbd daemon triggers regularly the following BUG with 2.6.25-rc3:
> 
> BUG: using smp_processor_id() in preemptible [00000000] code: nmbd/3167
> caller is __nf_conntrack_find+0x119/0x150
> Pid: 3167, comm: nmbd Not tainted 2.6.25-rc3 #1
> 
> Call Trace:
>  [<ffffffff8038f3f4>] debug_smp_processor_id+0xc4/0xd0
>  [<ffffffff80555d79>] __nf_conntrack_find+0x119/0x150
>  [<ffffffff80555dc9>] nf_conntrack_find_get+0x19/0x80
>  [<ffffffff80556914>] nf_conntrack_in+0x1a4/0x5a0
>  [<ffffffff8020bd33>] ? restore_args+0x0/0x30
>  [<ffffffff8059d596>] ipv4_conntrack_local+0x66/0x70
>  [<ffffffff80554362>] nf_iterate+0x62/0xa0
>  [<ffffffff80567050>] ? dst_output+0x0/0x10
>  [<ffffffff80554406>] nf_hook_slow+0x66/0xe0
>  [<ffffffff80567050>] ? dst_output+0x0/0x10
>  [<ffffffff80568825>] __ip_local_out+0xa5/0xb0
>  [<ffffffff80568841>] ip_local_out+0x11/0x30
>  [<ffffffff80568ac1>] ip_push_pending_frames+0x261/0x3e0
>  [<ffffffff80587153>] udp_push_pending_frames+0x233/0x3d0
>  [<ffffffff8058860f>] udp_sendmsg+0x30f/0x710
>  [<ffffffff802328b0>] ? default_wake_function+0x0/0x10
>  [<ffffffff8058f895>] inet_sendmsg+0x45/0x80
>  [<ffffffff80531fcf>] sock_sendmsg+0xdf/0x110
>  [<ffffffff80251270>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff802374c7>] ? hrtick_resched+0x77/0x90
>  [<ffffffff8025e2b5>] ? trace_hardirqs_on+0xd5/0x160
>  [<ffffffff80531735>] ? sockfd_lookup_light+0x45/0x80
>  [<ffffffff805323da>] sys_sendto+0xea/0x120
>  [<ffffffff80626bcb>] ? _spin_unlock_irq+0x2b/0x60
>  [<ffffffff8025e2b5>] ? trace_hardirqs_on+0xd5/0x160
>  [<ffffffff80626bd6>] ? _spin_unlock_irq+0x36/0x60
>  [<ffffffff8020b6db>] system_call_after_swapgs+0x7b/0x80
> 
> Steps to reproduce:
> Start smbd with the forementionned kernel instrumented for SMP and kernel
> debugging and hr + tickless enabled.
> 

Presumably this is in NF_CT_STAT_INC().  I wonder what caused it to start
happening.

Guys, this probably means that the developers who tested this change aren't
enabling the debug options which all kernel developers _should_ be enabling
when "testing" their code!  Documentation/SubmitChecklist has a handy list.

Should NF_CT_STAT_INC() be using local_inc()?
