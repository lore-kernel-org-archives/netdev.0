From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] TSO Reloaded
Date: Tue, 17 May 2005 22:59:44 -0700 (PDT)
Message-ID: <20050517.225944.92583479.davem@davemloft.net>
References: <0dd16bed0ea56242244bab0a7f1cf372@psc.edu>
	<20050517.200015.55506861.davem@davemloft.net>
	<03e7252e3f5541302f25675360330b1e@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jheffner@psc.edu
In-Reply-To: <03e7252e3f5541302f25675360330b1e@psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 17 May 2005 23:47:48 -0400

> On May 17, 2005, at 11:00 PM, David S. Miller wrote:
> 
> > I actually expected the new code to do better.
> > Splitting could be a little bit expensive, but
> > that only occurs at the beginning of the connection
> > as we ramp up the congestion and send window.
> > Afterwards, we should be able to release full unsplit
> > TSO frames onto the wire.
> 
> With different (larger than default) buffer sizes, I'm getting 63.4%.  
> Not surprising I guess.

Thanks for the data.

How long are your transfers?  Just curious.

I think what I need to investigate is some kind of light cwnd
prediction.  This, plus some TSO packet coalescing logic when we
undershoot, should do the trick.

But first I'll study the segmenting behavior of the current code.  It
could be simply a matter of tweaking when we wake up the user when he
sleeps on the send buffer filling up.
