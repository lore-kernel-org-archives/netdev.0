From: Andreas Gruenbacher <agruen@linbit.com>
Subject: Re: [RFC] [TCP 1/3] tcp: Add MSG_NEW_PACKET flag to indicate
 preferable packet boundaries
Date: Mon, 02 Jul 2012 13:00:56 +0200
Message-ID: <1341226856.29646.8.camel@gurkel.linbit>
References: <1340981690.25226.3.camel@gurkel.linbit>
	 <1340982666.21162.3.camel@edumazet-glaptop>
	 <1340984335.25450.24.camel@gurkel.linbit>
	 <1340990157.21162.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340990157.21162.5.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-06-29 at 19:15 +0200, Eric Dumazet wrote:
> On Fri, 2012-06-29 at 17:38 +0200, Andreas Gruenbacher wrote:
> 
> > The primary use case is fast Gigabit (10 or more) Ethernet connections
> > with jumbo frames and switches that support them.  There, frames will go
> > through unchanged and you can zero-copy receive all the time.
> > 
> > Not sure how well the approach scales to other kinds of connections; it
> > may work often enough to be worth it.  When things get distorted between
> > the sender and the receiver and tcp_recvbio() fails, the data can still
> > be copied out of the socket as before.
> 
> If you have a packet loss, receiver can and will coalesce frames.

That's alright as long as we'll get "back to normal" eventually; the
only effect will be that we'll copy data out of the socket receive
buffers for a while.  There will be extremely little packet loss on the
kinds of networks that we want to use this on.

Thanks,
Andreas
