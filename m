From: Andi Kleen <andi@firstfloor.org>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 16:24:23 +0200
Message-ID: <87my9hkrmw.fsf@basil.nowhere.org>
References: <18948.63755.279732.294842@cargo.ozlabs.ibm.com>
	<20090508.234815.127227651.davem@davemloft.net>
	<4A086DB2.8040703@nortel.com>
	<20090511.162436.193717082.davem@davemloft.net>
	<4A08C62F.1050105@nortel.com> <20090512081237.GA16403@elte.hu>
	<4A09933B.8010606@nortel.com> <874ovpmmdq.fsf@basil.nowhere.org>
	<4A0AC9EC.6070908@nortel.com>
	<20090513141532.GT19296@one.firstfloor.org>
	<alpine.LFD.2.00.0905131612180.3561@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Friesen <cfriesen@nortel.com>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52909 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbZEMOYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 10:24:25 -0400
In-Reply-To: <alpine.LFD.2.00.0905131612180.3561@localhost.localdomain> (Thomas Gleixner's message of "Wed, 13 May 2009 16:17:08 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Gleixner <tglx@linutronix.de> writes:


> Err, no. Chris is completely correct:
>
>         if (!in_interrupt())
> 		wakeup_softirqd();

Yes you have to wake it up just in case, but it doesn't normally
process the data because a normal softirq comes in faster. It's
just a safety policy. 

You can check this by checking the accumulated CPU time on your
ksoftirqs.  Mine are all 0 even on long running systems.

The reason Andrea originally added the softirqds was just that
if you have very softirq intensive workloads they would tie
up too much CPU time or not make enough process with the default
"don't loop too often" heuristics. 

> We can not rely on irqs coming in when the softirq is raised from

You can't rely on it, but it happens in near all cases.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
