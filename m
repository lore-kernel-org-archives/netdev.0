From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (results with
 IRQ affinity)
Date: Mon, 20 Apr 2009 13:29:54 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904201305360.1585@qirst.com>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net> <alpine.DEB.1.10.0904171238550.20049@qirst.com> <49EA2D7F.3080405@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:36943 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbZDTRhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 13:37:42 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B0E9582C5DC
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 13:48:00 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fDdMjwJdclLP for <netdev@vger.kernel.org>;
	Mon, 20 Apr 2009 13:48:00 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8797382C5EE
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 13:47:54 -0400 (EDT)
In-Reply-To: <49EA2D7F.3080405@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 18 Apr 2009, Eric Dumazet wrote:

> I did my tests with 3 machines, trying to reproduce your results and failed.

Ow.... Where are the results? Seems that you only included the results of
traces? The numbers would be much higher with udpping since it measures
the full round trip time from user space of one machine to the other and
back. The code segment that you are tracing may not be relevant.

> I only took traces on receivers to rule out different coalescing delays
> of NIC that could depend on firmware or version

Hmmm... Okay there could be a firmware influence....

> bnx2 driver statically included in vmlinux.
> (on newkernel, its "disable_msi" set to 1 (because this is the only way my BCM5708S can
>  have interrupt affinities set by the admin used by the hardware on 2.6.28+)

Here bnx2 is a module and MSI is enabled after it became available
(2.6.27+). Affinities seem to be effective after resetting the driver.

> If I force udpping to same cpu than IRQS (CPU0) I get : 7us, 8us, 7us, 7us
> And yes, this is very good and expected IMHO :)

Sounds very good. If I just knew what you are measuring.

> In conclusion, something might be wrong in your methodology, or your hardware, or...

Cannot really say since the results are not published? We can retry this
by making sure that udpping runs on the same processor as the IRQ.

> Please Christoph, would you mind posting more information on your config ?

Sure.

Dell PowerEdge 1950
http://www1.ap.dell.com/content/products/productdetails.aspx/pedge_1950?c=au&cs=aubsd1&l=en&s=bsd

> Any chance you have CONFIG_PREEMT enabled or any expensive kernel debug thing ?

Nope. Even if so: Would that not be offset by running the same kernel
version?

CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_NR_CPUS=32
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
# CONFIG_PREEMPT_BKL is not set
CONFIG_X86_LOCAL_APIC=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
# CONFIG_PRINTK_TIME is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_UNUSED_SYMBOLS=y
# CONFIG_DEBUG_FS is not set
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
CONFIG_DETECT_SOFTLOCKUP=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set
# CONFIG_DEBUG_SLAB is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_HIGHMEM is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_INFO is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_LIST is not set
# CONFIG_FRAME_POINTER is not set
# CONFIG_FORCED_INLINING is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_LKDTM is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_EARLY_PRINTK=y
CONFIG_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_RODATA is not set
# CONFIG_4KSTACKS is not set
CONFIG_X86_FIND_SMP_CONFIG=y
CONFIG_X86_MPPARSE=y
CONFIG_DOUBLEFAULT=y


