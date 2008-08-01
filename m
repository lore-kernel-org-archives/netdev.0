From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: _xmit_ETHER lockdep warning. (-git8)
Date: Fri, 01 Aug 2008 22:06:02 +0200
Message-ID: <48936CAA.8080504@gmail.com>
References: <20080801192947.GA26210@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:26732 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbYHAUG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 16:06:29 -0400
Received: by nf-out-0910.google.com with SMTP id d3so497768nfc.21
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2008 13:06:27 -0700 (PDT)
In-Reply-To: <20080801192947.GA26210@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones wrote, On 08/01/2008 09:29 PM:

> A week or so old, but possibly still valid..


Just fixed in net-2.6:

commit c3f26a269c2421f97f10cf8ed05d5099b573af4d
Author: David S. Miller <davem@davemloft.net>
Date:   Thu Jul 31 16:58:50 2008 -0700

    netdev: Fix lockdep warnings in multiqueue configurations.


Jarek P.

> 
> https://bugzilla.redhat.com/show_bug.cgi?id=456521
> 
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> 2.6.27-0.166.rc0.git8.fc10.x86_64 #1
> ---------------------------------------------
> swapper/0 is trying to acquire lock:
>  (_xmit_ETHER){-+..}, at: [<ffffffff812828a3>] dev_watchdog+0x41/0x1a7
> 
> but task is already holding lock:
>  (_xmit_ETHER){-+..}, at: [<ffffffff812828a3>] dev_watchdog+0x41/0x1a7
> 
> other info that might help us debug this:
> 1 lock held by swapper/0:
>  #0:  (_xmit_ETHER){-+..}, at: [<ffffffff812828a3>] dev_watchdog+0x41/0x1a7
> 
> stack backtrace:
> Pid: 0, comm: swapper Not tainted 2.6.27-0.166.rc0.git8.fc10.x86_64 #1
> 
> Call Trace:
>  <IRQ>  [<ffffffff81061b46>] __lock_acquire+0x790/0xaa7
>  [<ffffffff81060d80>] ? trace_hardirqs_on+0xd/0xf
>  [<ffffffff812828a3>] ? dev_watchdog+0x41/0x1a7
>  [<ffffffff81061ef3>] lock_acquire+0x96/0xc3
>  [<ffffffff812828a3>] ? dev_watchdog+0x41/0x1a7
>  [<ffffffff812f5eb8>] _spin_lock+0x2b/0x58
>  [<ffffffff812828a3>] dev_watchdog+0x41/0x1a7
>  [<ffffffff81282862>] ? dev_watchdog+0x0/0x1a7
>  [<ffffffff81048ba6>] run_timer_softirq+0x17f/0x1f7
>  [<ffffffff810450eb>] __do_softirq+0x83/0x110
>  [<ffffffff8100dcbc>] call_softirq+0x1c/0x28
>  [<ffffffff8100ef81>] do_softirq+0x52/0xb5
>  [<ffffffff81044c95>] irq_exit+0x53/0xa0
>  [<ffffffff8101d160>] smp_apic_timer_interrupt+0x94/0xad
>  [<ffffffff8100d4c8>] apic_timer_interrupt+0x88/0x90
>  <EOI>  [<ffffffff81022880>] ? native_safe_halt+0x6/0x8
>  [<ffffffff81060d80>] ? trace_hardirqs_on+0xd/0xf
>  [<ffffffff81013537>] ? default_idle+0x2f/0x51
>  [<ffffffff81013661>] ? c1e_idle+0x108/0x10f
>  [<ffffffff812f9204>] ? atomic_notifier_call_chain+0x14/0x16
>  [<ffffffff8100b2d6>] ? cpu_idle+0x92/0xeb
>  [<ffffffff812efbef>] ? start_secondary+0x1a1/0x1a3
> 


