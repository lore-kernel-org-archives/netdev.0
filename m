From: Andreas Gruenbacher <agruen@linbit.com>
Subject: Re: [RFC] [TCP 0/3] Receive from socket into bio without copying
Date: Mon, 02 Jul 2012 15:02:57 +0200
Message-ID: <1341234177.29646.69.camel@gurkel.linbit>
References: <1340981632.25226.2.camel@gurkel.linbit>
	 <1340982523.21162.1.camel@edumazet-glaptop>
	 <1341229532.29646.39.camel@gurkel.linbit>
	 <1341232568.22621.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341232568.22621.8.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-07-02 at 14:36 +0200, Eric Dumazet wrote:
> No files or page cache are needed for splice() usage, for example from
> socket to another socket.
> 
> It just works (check haproxy for an example), with 10Gb performance out
> of the box.

bio_vec's have some alignment requirements that must be met, and
anything that doesn't meet those requirements can't be passed to the
block layer (without copying it first).  Additional layers between the
network and block layers, like a pipe, won't make that problem go away.

> The pipe is only a container for buffers, in case the data fetched from
> producer cannot be fully sent to consumer. You don't want to lose this
> data.

Stuff that isn't pulled out of a socket receive buffer will stay there,
it won't magically be lost.

> > We want to go directly to the block layer instead.  This requires that
> > the network hardware receives the data into sector aligned buffers.
> > Hence the proposed MSG_NEW_PACKET flag.
> 
> This only is a hint something is wrong with the approach.

It just means that I'm trying to do something that isn't currently
supported.

> You only need proper splice() support (from pipe to bio), if not already
> there.

It's not already there, it requires the alignment issue to be addresses
first.

Andreas
