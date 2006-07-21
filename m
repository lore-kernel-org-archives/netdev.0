From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 02:46:23 -0700 (PDT)
Message-ID: <20060721.024623.112273386.davem@davemloft.net>
References: <20060721090610.GF5151@2ka.mipt.ru>
	<20060721.021955.104040230.davem@davemloft.net>
	<20060721093909.GA14290@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51145
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030430AbWGUJqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 05:46:23 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060721093909.GA14290@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 21 Jul 2006 13:39:09 +0400

> On Fri, Jul 21, 2006 at 02:19:55AM -0700, David Miller (davem@davemloft.net) wrote:
> > From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> > Date: Fri, 21 Jul 2006 13:06:11 +0400
> > 
> > > Receiving side, nor matter if it is socket or netchannel, will drop
> > > packets (socket due to queue overfull, netchannels will not drop, but
> > > will not ack (it's maximum queue len is 1mb)).
> > > 
> > > So both approaches behave _exactly_ the same.
> > > Did I miss something?
> > 
> > Socket will not drop the packets on receive because sender will not
> > violate the window which receiver advertises, therefore there is no
> > reason to drop the packets.
> 
> How come?
> sk_stream_rmem_schedule(), sk_rmem_alloc and friends...

sk_stream_rmem_schedule() allocates bytes from the global memory pool
quota for TCP sockets.  It is not something will trigger when, for
example, application blocks on a disk write.

In fact it will rarely trigger once size of window is known, since
sk_forward_alloc will grow to fill that size, then statically stay
at the value being able to service all allocation requests in the
future.

Only when there is severe global TCP memory pressure will it be
decreased.

And again this isn't something which happens when a user simply
blocks on some non-TCP operation.
