From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Wed, 20 Aug 2008 07:32:20 -0700 (PDT)
Message-ID: <958447.6297.qm@web82101.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82101.mail.mud.yahoo.com ([209.191.84.214]:41108 "HELO
	web82101.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752715AbYHTOcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 10:32:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > > This is true if he reverted just the 3def3d6d... commit, but if he 
> > > also reverts the similar, and immediately following, 1e934dda... 
> > > commit, then his 2.6.26 kernel runs fine.
> > 
> > interesting,
> > 
> > David, can you try only comment out
> > 
> > late_initcall(lapic_insert_resource);
> 
> i.e. the patch below?
> 
> what's your theory, what could be the reason for David's lockups?
> 
>     Ingo
> 
> --------------->
> Index: linux/arch/x86/kernel/apic_32.c
> ===================================================================
> --- linux.orig/arch/x86/kernel/apic_32.c
> +++ linux/arch/x86/kernel/apic_32.c
> @@ -1740,4 +1740,4 @@ static int __init lapic_insert_resource(
>   * need call insert after e820_reserve_resources()
>   * that is using request_resource
>   */
> -late_initcall(lapic_insert_resource);
> +//late_initcall(lapic_insert_resource);
> Index: linux/arch/x86/kernel/apic_64.c
> ===================================================================
> --- linux.orig/arch/x86/kernel/apic_64.c
> +++ linux/arch/x86/kernel/apic_64.c
> @@ -1614,4 +1614,4 @@ static int __init lapic_insert_resource(
>   * need call insert after e820_reserve_resources()
>   * that is using request_resource
>   */
> -late_initcall(lapic_insert_resource);
> +//late_initcall(lapic_insert_resource);


Brain Damage Alert:  I have only been experimenting with files for
64-bit architecture -- like e820_64.c, e820_64.h, setup_64.c, apic_64.c
-- and not their 32-bit counterparts.  The 3def3d6d commit only touched
64-bit files (before they merged with the 32-bit versions later).

I'm sure that is correct, but can you folks verify that?  A file like
apic_32.c (in Ingo's patch above) cannot affect me if I am running a
64-bit architecture, right?

Running this sanity check:
$ make  arch/x86/kernel/apic_32.o

just gives me loads of errors, presumably because of my .config settings:
============
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
# CONFIG_ARCH_HAS_ILOG2_U64 is not set
CONFIG_X86_64_SMP=y
CONFIG_X86_L1_CACHE_BYTES=64
CONFIG_X86_INTERNODE_CACHE_BYTES=64
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_RESOURCES_64BIT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
[...]
============

Sorry for my confusion,
Dave W.

PS:  Why didn't anyone tell me for 2 weeks that I was breaking standard
operating procedure by changing the subject line frequently?  Now I'm
in trouble with the bosses, you bums!  ;)
