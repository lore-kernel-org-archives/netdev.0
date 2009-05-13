From: David Miller <davem@davemloft.net>
Subject: Re: question about softirqs
Date: Tue, 12 May 2009 22:28:48 -0700 (PDT)
Message-ID: <20090512.222848.152842353.davem@davemloft.net>
References: <20090512092348.GA29796@elte.hu>
	<20090512.214427.193728136.davem@davemloft.net>
	<18954.22390.754419.803434@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, a.p.zijlstra@chello.nl, cfriesen@nortel.com,
	tglx@linutronix.de, rostedt@goodmis.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47226
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751202AbZEMF2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 01:28:51 -0400
In-Reply-To: <18954.22390.754419.803434@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Mackerras <paulus@samba.org>
Date: Wed, 13 May 2009 15:15:34 +1000

> David Miller writes:
> 
>> I fully expected us to be, at this point, talking about putting the
>> pending softirq check back into the trap return path :-/
> 
> Would that actually do any good, in the case where the system has
> decided that ksoftirqd is handling soft irqs at the moment?

Even if ksoftirqd is running, we check and run pending softirqs from
trap return.

Sure, I imagine we could re-enter this "ksoftirq blocked by highprio
thread" situation if we get flooded every single time over and over
again.
