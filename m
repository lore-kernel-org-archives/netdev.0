From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Mon, 01 Sep 2014 22:05:42 +0200
Message-ID: <1409601942.21965.23.camel@localhost>
References: <1409142672.26515.24.camel@localhost>
	 <20140827.134510.2172564669938048576.davem@davemloft.net>
	 <1409190174.27664.10.camel@localhost>
	 <20140829.202210.1424256004723217664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com, brouer@redhat.com,
	john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39638 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751082AbaIAUFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 16:05:46 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id E7F63208D0
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 16:05:45 -0400 (EDT)
In-Reply-To: <20140829.202210.1424256004723217664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-08-29 at 20:22 -0700, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 28 Aug 2014 03:42:54 +0200
> 
> > I wonder if we still might need a separate call for tx_flush, e.g. for
> > af_packet if one wants to allow user space control of batching, MSG_MORE
> > with tx hangcheck (also in case user space has control over it) or
> > implement TCP_CORK alike option in af_packet.
> 
> I disagree with allowing the user to hold a device TX queue hostage
> across system calls, therefore the user should provide the entire
> batch in such a case.

Ok, granted. In regards to syscall latency this also is a stupid idea.
mmaped tx approaches won't even pass these functions, so we don't care
here.

But as soon as we try to make Qdiscs absolutely lockless, we don't have
any guard that we don't concurrently dequeue skbs from it and suddenly
one Qdisc dequeue processing entity couldn't notify the driver that the
end of the batching was reached. I think this could become a problem
depending on how much of the locking is removed?

Bye,
Hannes
