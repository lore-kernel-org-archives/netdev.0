From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Fri, 6 Apr 2007 12:37:46 +0200
Message-ID: <20070406103746.GA24596@elte.hu>
References: <4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com> <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com> <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com> <20070404212103.GA19026@elte.hu> <1175728768.12230.593.camel@localhost.localdomain> <20070405093033.GC25448@elte.hu> <4615086C.9060306@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	kvm-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: Anthony Liguori <aliguori@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:47309 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280AbXDFKiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 06:38:15 -0400
Content-Disposition: inline
In-Reply-To: <4615086C.9060306@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Anthony Liguori <aliguori@us.ibm.com> wrote:

> [...] Did Linux have extremely high quality code in 1994?

yes! It was crutial to strive for extremely high quality code all the 
time. That was the only way to grow Linux's codebase, which was ~300,000 
lines of code in 1994, to the current 7.2+ million lines of code, 
without losing maintainability. Code quality is more important than any 
feature. 99% of feature patches sent to lkml get rejected in the first 
review round on quality/design grounds, it always takes at least a 
couple of iterations to make it nice and clean. Look at Apache, it's 
evolving along the same lines. Or Samba. Or any of the really large and 
important OSS projects. (even X, after years of struggle and stagnation, 
seems to have gotten this point now.) In the past 10 years the OSS 
community wrote more than 1 billion lines of new code (!), and all the 
successful projects have a clean codebase. _It cannot be done any other 
way_, because cleanliness and pride over good code is what keeps 
developers and it is what attracts new developers.

now this doesnt mean that Linux's code quality is good in every spot - 
it's an eternal fight. But the core subsystems are pretty damn clean. 
When i prepare patches for the Linux kernel more than 50% of the work i 
do is related to making the changes clean, or cleaning up some existing 
aspect of the kernel that the new code triggers. Often it's 90% of the 
work!

the 'get functionality now, clean up later' mentality is what leads to 
throwaway, use-once codebases that the majority of closed-source 
projects do. Once the cruft level reaches a certain threshold it's 
cheaper to just throw away old code and just rewrite the whole thing 
(users and costs be damned). Cleanups must not be an afterthought, code 
cleanliness and gradual code evolution is _the_ most valuable property 
of OSS codebases.

i guess my negative Qemu experience is dominated by my recent failure of 
trying to untangle its timer code, so that qemu properly adopts to 
changes in PIT/lapic programming and maps that correctly to OS timers. 
(so that a dynticks/NO_HZ guest's reduced irq rate becomes visible on 
the host too) I'll be a happy camper if that's fixed ;-)

	Ingo
