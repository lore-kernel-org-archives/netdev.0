From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next] tcp: do not increase the rcv window when the FIN has been received
Date: Sat, 4 Jan 2014 09:22:45 +0100
Message-ID: <20140104082245.GA23837@1wt.eu>
References: <20140102224021.GA20358@1wt.eu> <20140103.195810.465225289648295955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:54748 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751015AbaADIWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 03:22:50 -0500
Content-Disposition: inline
In-Reply-To: <20140103.195810.465225289648295955.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Fri, Jan 03, 2014 at 07:58:10PM -0500, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Thu, 2 Jan 2014 23:40:21 +0100
> 
> > In HTTP performance tests it appeared that my client was always sending
> > an ACK immediately after receiving the FIN from the server and that the
> > sole purpose of this ACK was to advertise a larger window.
> 
> I guess the question is what behavior do we want here.
> 
> Frankly, I think we should always immediately ACK a FIN _unless_ we
> already have data pending on the send queue on which to piggyback that
> ACK.
> 
> The reason is that since we know there will be no more data, delaying
> the ACK has none of the useful characteristics.  In fact, sending the
> ACK immediately will allow the closing side to release the data in it's
> retransmit queue, and thus reclaim memory, more quickly.

Yes but on the other hand, most often when we receive a FIN, there is
immediate local action. Either data are pending and will serve as an
ACK, or the local endpoint will immediately close as well. Currently,
if the application doesn't react fast enough, the ACK is emitted after
40 ms anyway. So a properly designed application has an opportunity of
40 ms to react quickly and save this ACK. Currently it works only when
the data accompanying the FIN is less than 536 bytes, and my point was
to ensure that larger responses were covered by the same possibility
as well.

> I'm not so sure about this change, so I'm marking it deferred.

OK no problem.

Thanks,
Willy
