From: Andreas Gruenbacher <agruen@linbit.com>
Subject: Re: [RFC] [TCP 0/3] Receive from socket into bio without copying
Date: Mon, 02 Jul 2012 13:45:32 +0200
Message-ID: <1341229532.29646.39.camel@gurkel.linbit>
References: <1340981632.25226.2.camel@gurkel.linbit>
	 <1340982523.21162.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340982523.21162.1.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-06-29 at 17:08 +0200, Eric Dumazet wrote:
> This looks like yet another zero copy, needing another couple of hundred
> of lines.

Kind of, yes.  We really want to make no copies at all though; the cpu
just passes buffers from one device to the other.

> Why splice infrastructure doesnt fit your needs ?

The pipe api that splice is based on saves a copy between the kernel and
user space, but it currently writes to files, going through the page
cache.  For that, the alignment of data in the network receive buffers
doesn't matter.

We want to go directly to the block layer instead.  This requires that
the network hardware receives the data into sector aligned buffers.
Hence the proposed MSG_NEW_PACKET flag.

With that, it might be possible to implement a pipe "sink" that goes to
a bio instead of writing to a file.  Going through the pipe
infrastructure doesn't actually help in this case though, it's just
overhead.

Thanks,
Andreas
