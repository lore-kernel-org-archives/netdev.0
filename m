From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Mon, 01 Sep 2014 14:56:46 -0700 (PDT)
Message-ID: <20140901.145646.174847768842584425.davem@davemloft.net>
References: <1409190174.27664.10.camel@localhost>
	<20140829.202210.1424256004723217664.davem@davemloft.net>
	<1409601942.21965.23.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com, brouer@redhat.com,
	john.r.fastabend@intel.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbaIAV4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 17:56:47 -0400
In-Reply-To: <1409601942.21965.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 01 Sep 2014 22:05:42 +0200

> But as soon as we try to make Qdiscs absolutely lockless, we don't have
> any guard that we don't concurrently dequeue skbs from it and suddenly
> one Qdisc dequeue processing entity couldn't notify the driver that the
> end of the batching was reached. I think this could become a problem
> depending on how much of the locking is removed?

I am certain that batching will require taking the device transmit
lock over the ->ndo_start_xmit() invocations, and therefore the
deferral decisions must atomically be made inside of that context.
