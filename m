From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
	RCU.
Date: Sun, 20 Jul 2008 22:20:38 -0400
Message-ID: <1216606839.4847.159.camel@localhost>
References: <1216566963.4847.81.camel@localhost>
	 <20080720.102534.246150854.davem@davemloft.net>
	 <1216593170.4847.137.camel@localhost>
	 <20080720.165911.86437240.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:29904 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758927AbYGUCUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 22:20:41 -0400
Received: by py-out-1112.google.com with SMTP id p76so909306pyb.10
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2008 19:20:41 -0700 (PDT)
In-Reply-To: <20080720.165911.86437240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-20-07 at 16:59 -0700, David Miller wrote:

> Every time this topic comes up, you insist on them having to match.
> And I have no idea why.

I dont insist on them matching, just on correctness. i.e if you say you
have RR, then the scheduling needs to meet those requirements not an
estimate - thats all.

> The problem is that the bottleneck is the qdisc itself since all those
> cpus synchonize on it's lock.  We can't have a shared qdisc for the
> device and get full parallelization.
> 
> That's why we're having one qdisc per TX queue, so that they all don't
> bunch up on the qdisc lock.

That last sentence i have no issues with - it is what i thought wasnt
happening;-> i misunderstood it to be a single fifo shared by all
hardware tx queues from the begining (otherwise i wouldnt be posting).
We are in sync i think, a single pfifo per TX queue is the way to go. I
was suggesting it goes in the driver, but this is cleaner: In the
future, one could could actually replace the pfifo with another qdisc
since the single virtual wire becomes equivalent to a single virtual
netdevice

> Otherwise, there is zero point in all of these TX multiqueue features
> in the hardware if we can't parallelize things fully.

parallelization is achieveable in the ideal case.

cheers,
jamal

