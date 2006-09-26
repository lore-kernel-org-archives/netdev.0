From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 11/11] forcedeth: hardirq lockdep warning
Date: Mon, 25 Sep 2006 20:03:25 -0400
Message-ID: <45186E4D.3020406@garzik.org>
References: <200609252339.k8PNdQKG002661@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a.p.zijlstra@chello.nl,
	aabdulla@nvidia.com, arjan@linux.intel.com, davej@redhat.com,
	mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37592 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751812AbWIZADa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 20:03:30 -0400
To: akpm@osdl.org
In-Reply-To: <200609252339.k8PNdQKG002661@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> BUG: warning at kernel/lockdep.c:1816/trace_hardirqs_on() (Not tainted)
> 
> Call Trace:
>  show_trace
>  dump_stack
>  trace_hardirqs_on
>  :forcedeth:nv_nic_irq_other
>  handle_IRQ_event
>  __do_IRQ
>  do_IRQ
>  ret_from_intr
> DWARF2 barf
>  default_idle
>  cpu_idle
>  rest_init
>  start_kernel
>  _sinittext
> 
> These 3 functions nv_nic_irq_tx(), nv_nic_irq_rx() and nv_nic_irq_other()
> are reachable from IRQ context and process context. Make use of the
> irq-save/restore spinlock variant.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Arjan van de Ven <arjan@linux.intel.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

ACK + HOLD, must analyze locking before applying.  It still looks 
strange, even after this patch.


