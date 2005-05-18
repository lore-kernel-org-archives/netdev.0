From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] TSO Reloaded
Date: Tue, 17 May 2005 20:00:15 -0700 (PDT)
Message-ID: <20050517.200015.55506861.davem@davemloft.net>
References: <46332e5aa197db91aaf012cf140282b4@psc.edu>
	<20050517.192829.71087792.davem@davemloft.net>
	<0dd16bed0ea56242244bab0a7f1cf372@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jheffner@psc.edu
In-Reply-To: <0dd16bed0ea56242244bab0a7f1cf372@psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 17 May 2005 22:51:53 -0400

> On May 17, 2005, at 10:28 PM, David S. Miller wrote:
> 
> > From: John Heffner <jheffner@psc.edu>
> > Date: Tue, 17 May 2005 22:26:09 -0400
> >
> >> No TSO:  86.6%
> >> Old TSO: 61.0%
> >> New TSO: 88.5%
> >
> > Yeah, TSO Reloaded really stinks. :-)
> >
> > Try the "Super TSO" patch I just posted instead.
> 
> Interesting timing. :)
> With the new patch I'm getting 78.0%.

Thanks for testing.

I actually expected the new code to do better.
Splitting could be a little bit expensive, but
that only occurs at the beginning of the connection
as we ramp up the congestion and send window.
Afterwards, we should be able to release full unsplit
TSO frames onto the wire.
