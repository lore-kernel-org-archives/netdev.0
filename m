From: Christoph Lameter <cl@linux.com>
Subject: Re: udp ping pong measurements from 2.6.22 to .30 with various cpu
 affinities
Date: Wed, 22 Apr 2009 17:09:28 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904221700030.32682@qirst.com>
References: <alpine.DEB.1.10.0904221604480.18138@qirst.com> <49EF85E3.8060703@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:57476 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275AbZDVV0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 17:26:47 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 84A7F82C8D1
	for <netdev@vger.kernel.org>; Wed, 22 Apr 2009 17:37:17 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id o9pr8o4iRDvz for <netdev@vger.kernel.org>;
	Wed, 22 Apr 2009 17:37:17 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4257282C8D5
	for <netdev@vger.kernel.org>; Wed, 22 Apr 2009 17:37:17 -0400 (EDT)
In-Reply-To: <49EF85E3.8060703@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Apr 2009, Eric Dumazet wrote:

> Check /proc/cpuinfo, and check it doesnt change between kernel version.

Hmmm.... It does not since it depends on the way that the machine is
configured by the firmware.

> > Results follow (a nice diagram is available from
> > http://gentwo.org/results/udpping-tests-2.pdf
>
> Nice graphs, but lack of documentation of test conditions.

What would you like to know?

> > Observations:
> > - Pinning to the same cpu yields almost 8 usecs vs. another cpu sharing
> >   the same L2.
> > - Strangely the cpu not sharing the l2 is better than a cpu with the same
> >   L2.
>
> When I see strange results like that, I ask to myself :
> Is the problem located at the looked-at system, or at the observer ?

And that means?

> We already pointed it was probably scheduling. Since ICMP pings dont use
> processes and no regression here. Patching kernel to implement udpping
> at softirq level should be quite easy if you really want to check UDP stack.
>
> Last network improvements focused on scalability more than latencies.
> (multi-flows, not single flow !)

Latencies have priority here. Multi-flows are secondary.

So I guess this means that you are okay with the network stacks latency
creep? Even if its only 1.5usec: In practice you tune the NIC to perform
much better and this is a latency increase likely occurring in every
packet transmission.
