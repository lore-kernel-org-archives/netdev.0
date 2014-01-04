From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: do not increase the rcv window when the
 FIN has been received
Date: Fri, 03 Jan 2014 19:58:10 -0500 (EST)
Message-ID: <20140103.195810.465225289648295955.davem@davemloft.net>
References: <20140102224021.GA20358@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196AbaADA6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:58:12 -0500
In-Reply-To: <20140102224021.GA20358@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Thu, 2 Jan 2014 23:40:21 +0100

> In HTTP performance tests it appeared that my client was always sending
> an ACK immediately after receiving the FIN from the server and that the
> sole purpose of this ACK was to advertise a larger window.

I guess the question is what behavior do we want here.

Frankly, I think we should always immediately ACK a FIN _unless_ we
already have data pending on the send queue on which to piggyback that
ACK.

The reason is that since we know there will be no more data, delaying
the ACK has none of the useful characteristics.  In fact, sending the
ACK immediately will allow the closing side to release the data in it's
retransmit queue, and thus reclaim memory, more quickly.

I'm not so sure about this change, so I'm marking it deferred.

Thanks.
