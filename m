From: Ingo Molnar <mingo@elte.hu>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user
	with the same regression
Date: Wed, 20 Aug 2008 11:15:13 +0200
Message-ID: <20080820091513.GA23865@elte.hu>
References: <109483.89278.qm@web82104.mail.mud.yahoo.com> <86802c440808192221s3ada5443qc3b9d8e26f252d03@mail.gmail.com> <20080820035130.38426b00.billfink@mindspring.com> <86802c440808200102n6487ae17ud790991b8ea30d16@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>,
	David Witbrodt <dawitbro@sbcglobal.net>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:41677 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473AbYHTJPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2008 05:15:38 -0400
Content-Disposition: inline
In-Reply-To: <86802c440808200102n6487ae17ud790991b8ea30d16@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Yinghai Lu <yhlu.kernel@gmail.com> wrote:

> > This is true if he reverted just the 3def3d6d... commit, but if he 
> > also reverts the similar, and immediately following, 1e934dda... 
> > commit, then his 2.6.26 kernel runs fine.
> 
> interesting,
> 
> David, can you try only comment out
> 
> late_initcall(lapic_insert_resource);

i.e. the patch below?

what's your theory, what could be the reason for David's lockups?

	Ingo

--------------->
Index: linux/arch/x86/kernel/apic_32.c
===================================================================
--- linux.orig/arch/x86/kernel/apic_32.c
+++ linux/arch/x86/kernel/apic_32.c
@@ -1740,4 +1740,4 @@ static int __init lapic_insert_resource(
  * need call insert after e820_reserve_resources()
  * that is using request_resource
  */
-late_initcall(lapic_insert_resource);
+//late_initcall(lapic_insert_resource);
Index: linux/arch/x86/kernel/apic_64.c
===================================================================
--- linux.orig/arch/x86/kernel/apic_64.c
+++ linux/arch/x86/kernel/apic_64.c
@@ -1614,4 +1614,4 @@ static int __init lapic_insert_resource(
  * need call insert after e820_reserve_resources()
  * that is using request_resource
  */
-late_initcall(lapic_insert_resource);
+//late_initcall(lapic_insert_resource);

