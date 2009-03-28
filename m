From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12960] New: BUG using smp_processor_id() in
 preemptible [00000000] code: rndc/4018
Date: Sat, 28 Mar 2009 12:47:28 -0700
Message-ID: <20090328124728.bba9069b.akpm@linux-foundation.org>
References: <bug-12960-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, jean.luc.coulon@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36943 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753291AbZC1TtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 15:49:06 -0400
In-Reply-To: <bug-12960-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 28 Mar 2009 16:34:29 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12960
> 
>            Summary: BUG using smp_processor_id() in preemptible [00000000]
>                     code: rndc/4018
>            Product: Process Management
>            Version: 2.5
>     Kernel Version: 2.6.29-git[23]
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Preemption
>         AssignedTo: rlove@rlove.org
>         ReportedBy: jean.luc.coulon@gmail.com
>         Regression: Yes
> 
> 
> Created an attachment (id=20717)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=20717)
> .config file
> 
> Hi,
> 
> Since 2.6.29-git2, I've many BUG messages.
> I have not them with 2.6.29 vanilla and I've not tested git1
> 
> BUG: using smp_processor_id() in preemptible [00000000] code: rndc/4018
> Mar 28 09:56:52 tangerine kernel: caller is ipt_do_table+0xfe/0x5a4 [ip_tables]
> Mar 28 09:56:52 tangerine kernel: Pid: 4018, comm: rndc Not tainted
> 2.6.29-git2-k8-1 #1
> Mar 28 09:56:52 tangerine kernel: Call Trace:
> Mar 28 09:56:52 tangerine kernel: [<ffffffff8034f0c0>]
> debug_smp_processor_id+0xe0/0xf0
> Mar 28 09:56:52 tangerine kernel: [<ffffffffa0493cee>] ipt_do_table+0xfe/0x5a4
> [ip_tables]
> Mar 28 09:56:52 tangerine kernel: [<ffffffffa049e8a8>] ?
> __nf_ct_ext_add+0x68/0x220 [nf_conntrack]
> Mar 28 09:56:52 tangerine kernel: [<ffffffffa0307109>] ipt_local_hook+0x89/0xec
> [iptable_mangle]
> Mar 28 09:56:52 tangerine kernel: [<ffffffff80428a17>] nf_iterate+0x67/0xa0
> Mar 28 09:56:52 tangerine kernel: [<ffffffff80432e30>] ? dst_output+0x0/0x10
> Mar 28 09:56:52 tangerine kernel: [<ffffffff80428b05>] nf_hook_slow+0xb5/0x100
> Mar 28 09:56:52 tangerine kernel: [<ffffffff80432e30>] ? dst_output+0x0/0x10
> Mar 28 09:56:52 tangerine kernel: [<ffffffff80434c0f>] __ip_local_out+0x9f/0xb0
> Mar 28 09:56:52 tangerine kernel: [<ffffffff80434c31>] ip_local_out+0x11/0x30
> Mar 28 09:56:52 tangerine kernel: [<ffffffff80435524>]
> ip_queue_xmit+0x214/0x410
> Mar 28 09:56:52 tangerine kernel: [<ffffffff802a8ec4>] ?
> __slab_alloc+0x154/0x730
> Mar 28 09:56:52 tangerine kernel: [<ffffffff80409f04>] ? __alloc_skb+0x44/0x160
> Mar 28 09:56:52 tangerine kernel: [<ffffffff804495f5>]
> tcp_transmit_skb+0x505/0x7c0
> Mar 28 09:56:52 tangerine kernel: [<ffffffff8044a176>] tcp_connect+0x3c6/0x4a0
> Mar 28 09:56:52 tangerine kernel: [<ffffffff804507e3>]
> tcp_v4_connect+0x423/0x510
> Mar 28 09:56:52 tangerine kernel: [<ffffffff8045dd07>]
> inet_stream_connect+0x217/0x2b0
> Mar 28 09:56:52 tangerine kernel: [<ffffffff802ae4fe>] ? fget_light+0xce/0xe0
> Mar 28 09:56:52 tangerine kernel: [<ffffffff804008f0>] sys_connect+0xb0/0xd0
> Mar 28 09:56:52 tangerine kernel: [<ffffffff8026841e>] ? sys_futex+0xbe/0x170
> Mar 28 09:56:52 tangerine kernel: [<ffffffff80495842>] ?
> _spin_lock_irqsave+0x22/0x50
> Mar 28 09:56:52 tangerine kernel: [<ffffffff80495ab2>] ?
> _spin_unlock_irqrestore+0x12/0x40
> Mar 28 09:56:52 tangerine kernel: [<ffffffff8020bb1b>]
> system_call_fastpath+0x16/0x1b
> 
> 
> It occurs with various processes but the first two lines are always the same:
> 
> [<ffffffff8034f030>] debug_smp_processor_id+0xe0/0xf0
> Mar 28 16:32:25 tangerine kernel: [<ffffffffa049ad0e>] ipt_do_table+0xfe/0x5a4
> [ip_tables]
> 
> I've reported it on preemtion because of the header line of the trace but maybe
> it is related to iptables.
> 
> Attached: my .config.
> 
> System is: Debian sid
> Architecture: X86_64 on an amd64 x2 4200+
> 

