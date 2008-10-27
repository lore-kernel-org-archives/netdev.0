From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 11:33:06 +0000
Message-ID: <20081027113306.5b1d5898@lxorguk.ukuu.org.uk>
References: <20081024.221653.23695396.davem@davemloft.net>
	<1224914333.3822.18.camel@marge.simson.net>
	<1224917623.4929.15.camel@marge.simson.net>
	<20081025.002420.82739316.davem@davemloft.net>
	<Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz>
	<1225010790.8566.22.camel@marge.simson.net>
	<1225011648.27415.4.camel@twins>
	<20081026021153.47878580.akpm@linux-foundation.org>
	<alpine.LNX.1.10.0810262002450.12928@jikos.suse.cz>
	<alpine.LNX.1.10.0810271138470.12928@jikos.suse.cz>
	<20081027112750.GA2771@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jkosina@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Galbraith <efault@gmx.de>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:50507 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751689AbYJ0LeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 07:34:10 -0400
In-Reply-To: <20081027112750.GA2771@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The way to get the best possible dbench numbers in CPU-bound dbench 
> runs, you have to throw away the scheduler completely, and do this 
> instead:
> 
>  - first execute all requests of client 1
>  - then execute all requests of client 2
>  ....
>  - execute all requests of client N

Rubbish. If you do that you'll not get enough I/O in parallel to schedule
the disk well (not that most of our I/O schedulers are doing the job
well, and the vm writeback threads then mess it up and the lack of Arjans
ioprio fixes then totally screw you) </rant>

> the moment the clients are allowed to overlap, the moment their requests 
> are executed more fairly, the dbench numbers drop.

Fairness isn't everything. Dbench is a fairly good tool for studying some
real world workloads. If your fairness hurts throughput that much maybe
your scheduler algorithm is just plain *wrong* as it isn't adapting to
workload at all well.

Alan
