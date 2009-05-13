From: David Miller <davem@davemloft.net>
Subject: Re: question about softirqs
Date: Tue, 12 May 2009 21:44:27 -0700 (PDT)
Message-ID: <20090512.214427.193728136.davem@davemloft.net>
References: <20090512081237.GA16403@elte.hu>
	<1242119578.11251.321.camel@twins>
	<20090512092348.GA29796@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, cfriesen@nortel.com, tglx@linutronix.de,
	rostedt@goodmis.org, linuxppc-dev@ozlabs.org, paulus@samba.org,
	netdev@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57123
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751110AbZEMEob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 00:44:31 -0400
In-Reply-To: <20090512092348.GA29796@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 12 May 2009 11:23:48 +0200

>> Wouldn't the even better solution be to get rid of softirqs 
>> all-together?
>> 
>> I see the recent work by Thomas to get threaded interrupts 
>> upstream as a good first step towards that goal, once the RX 
>> processing is moved to a thread (or multiple threads) one can 
>> priorize them in the regular sys_sched_setscheduler() way and its 
>> obvious that a FIFO task above the priority of the network tasks 
>> will have network starvation issues.
> 
> Yeah, that would be "nice". A single IRQ thread plus the process 
> context(s) doing networking might perform well.

Nice for -rt goals, but not for latency.

So we're going to regress in this area again?  I can't see how
that's so desirable, to be honest with you.

The fact that this discussion started about a task with a certain
priority not being able to make forward progress, even though it
was correct coded, just because softirqs are being processed in
a thread context, should be a big red flag that this is a buggered up
design.

I fully expected us to be, at this point, talking about putting the
pending softirq check back into the trap return path :-/
