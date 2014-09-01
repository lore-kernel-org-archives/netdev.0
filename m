From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Tue, 02 Sep 2014 00:31:09 +0200
Message-ID: <1409610669.21965.55.camel@localhost>
References: <1409190174.27664.10.camel@localhost>
	 <20140829.202210.1424256004723217664.davem@davemloft.net>
	 <1409601942.21965.23.camel@localhost>
	 <20140901.145646.174847768842584425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com, brouer@redhat.com,
	john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55853 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752031AbaIAWbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 18:31:12 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id 4840E2087F
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 18:31:12 -0400 (EDT)
In-Reply-To: <20140901.145646.174847768842584425.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2014-09-01 at 14:56 -0700, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 01 Sep 2014 22:05:42 +0200
> 
> > But as soon as we try to make Qdiscs absolutely lockless, we don't have
> > any guard that we don't concurrently dequeue skbs from it and suddenly
> > one Qdisc dequeue processing entity couldn't notify the driver that the
> > end of the batching was reached. I think this could become a problem
> > depending on how much of the locking is removed?
> 
> I am certain that batching will require taking the device transmit
> lock over the ->ndo_start_xmit() invocations, and therefore the
> deferral decisions must atomically be made inside of that context.

I'll stop to throw doubt into this discussion now. ;)

I am afraid that TX-lock is per nic-queue and it won't work out that
easy because skbs for different queues can reside in a Qdisc.

Bye,
Hannes
