From: "David S. Miller" <davem@davemloft.net>
Subject: Re: issue with new TCP TSO stuff
Date: Thu, 12 May 2005 15:52:30 -0700 (PDT)
Message-ID: <20050512.155230.132927874.davem@davemloft.net>
References: <20050512.131349.32715242.davem@davemloft.net>
	<20050512214744.GA21958@gondor.apana.org.au>
	<20050512221046.GA22136@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050512221046.GA22136@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: issue with new TCP TSO stuff
Date: Fri, 13 May 2005 08:10:46 +1000

> Nevermind, you're comparing to the existing TSO implementation.
> So how big exactly is the slowdown?

The "scp largefile dest:" test case went down from 4.6MB/sec
to 4.3MB/sec when I enable TSO on the tg3 device with the
new TSO code.

So that drop is relative to non-TSO.  That's how I knew there
was some trouble.  TSO should definitely not have more overhead
that non-TSO.

For a clean transfer bulk transfer which is not application
limited like scp is, we get full line rate.  But that doesn't
show how expensive TSO is, since the link is the bottleneck
not the cpu.

> This just occured to me, what about NETIF_F_SKBLIST?

Sounds ok.
