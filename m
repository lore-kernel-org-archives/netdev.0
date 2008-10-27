From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 12:27:50 +0100
Message-ID: <20081027112750.GA2771@elte.hu>
References: <20081024.221653.23695396.davem@davemloft.net> <1224914333.3822.18.camel@marge.simson.net> <1224917623.4929.15.camel@marge.simson.net> <20081025.002420.82739316.davem@davemloft.net> <Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz> <1225010790.8566.22.camel@marge.simson.net> <1225011648.27415.4.camel@twins> <20081026021153.47878580.akpm@linux-foundation.org> <alpine.LNX.1.10.0810262002450.12928@jikos.suse.cz> <alpine.LNX.1.10.0810271138470.12928@jikos.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Galbraith <efault@gmx.de>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:46737 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbYJ0L2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 07:28:19 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0810271138470.12928@jikos.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jiri Kosina <jkosina@suse.cz> wrote:

> Ok, so another important datapoint:
> 
> with c1e4fe711a4 (just before CFS has been merged for 2.6.23), the dbench 
> throughput measures
> 
> 	187.7 MB/s
> 
> in our testing conditions (default config).
> 
> With c31f2e8a42c4 (just after CFS has been merged for 2.6.23), the 
> throughput measured by dbench is
> 
> 	82.3 MB/s
> 
> This is the huge drop we have been looking for. After this, the 
> performance was still going down gradually, up to ~45 MS/ we are 
> measuring for 2.6.27. But the biggest drop (more than 50%) points 
> directly to CFS merge.

that is a well-known property of dbench: it rewards unfairness in IO, 
memory management and scheduling.

The way to get the best possible dbench numbers in CPU-bound dbench 
runs, you have to throw away the scheduler completely, and do this 
instead:

 - first execute all requests of client 1
 - then execute all requests of client 2
 ....
 - execute all requests of client N

the moment the clients are allowed to overlap, the moment their requests 
are executed more fairly, the dbench numbers drop.

	Ingo
