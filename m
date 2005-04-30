From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost
Date: Sat, 30 Apr 2005 14:59:54 +0200
Message-ID: <4273814A.50106@tpack.net>
References: <E1DQlsn-0005yd-00@gondolin.me.apana.org.au> <426FDF8B.1030808@tpack.net> <20050427214224.GA25325@gondor.apana.org.au> <42701FFD.5000505@tpack.net> <20050427234359.GB22238@gondor.apana.org.au> <1114768308.4695.1487.camel@tsc-6.cph.tpack.net> <20050429101836.GA2237@gondor.apana.org.au> <1114777355.4695.1598.camel@tsc-6.cph.tpack.net> <20050429234512.GA22699@gondor.apana.org.au> <20050430004638.GA23386@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050430004638.GA23386@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> What if we take a more direct approach and just drop the packets before
> it hits hard_start_xmit? This also makes it easy for the drivers to do
> TX ring flushing if it's necessary since we're guaranteeing (for drivers
> that are not lockless anyway) that once carrier goes off while the xmit
> lock is held hard_start_xmit will not be called again.

Something like this has been considered already. It's simple and obvious,
but has it's drawbacks as well:

  - it adds a slight overhead to the TX path (some people are rather
    sensitive about this)
  - it impacts all sorts of drivers, including those that don't need fixing
  - it doesn't work as intended! qdisc_run checks for queue_stopped before
    calling qdisc_restart

-Tommy
