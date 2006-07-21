From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 13:55:55 +0400
Message-ID: <20060721095555.GA13331@2ka.mipt.ru>
References: <20060721090610.GF5151@2ka.mipt.ru> <20060721.021955.104040230.davem@davemloft.net> <20060721093909.GA14290@2ka.mipt.ru> <20060721.024623.112273386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:27114 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1161019AbWGUJ4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 05:56:03 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060721.024623.112273386.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 21, 2006 at 02:46:23AM -0700, David Miller (davem@davemloft.net) wrote:
> > sk_stream_rmem_schedule(), sk_rmem_alloc and friends...
> 
> sk_stream_rmem_schedule() allocates bytes from the global memory pool
> quota for TCP sockets.  It is not something will trigger when, for
> example, application blocks on a disk write.
> 
> In fact it will rarely trigger once size of window is known, since
> sk_forward_alloc will grow to fill that size, then statically stay
> at the value being able to service all allocation requests in the
> future.
> 
> Only when there is severe global TCP memory pressure will it be
> decreased.
> 
> And again this isn't something which happens when a user simply
> blocks on some non-TCP operation.

Of course it is not, but something that breaks header prediction will
fall into memory check and so on.
Blocking on write will not trigger memory limits overcommit from the
first packet, as long as it will not trigger timeout retransmit if no
acks are sent. If there will be a lot of them, then troubles start.
We saw already, that speed decreased to the write speed in both 
implementations without connection collapsing.

-- 
	Evgeniy Polyakov
