From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Fri, 24 Sep 2004 10:58:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924105855.0e1aecd0.davem@davemloft.net>
References: <414F1E12.6010808@eurodev.net>
	<20040922000503.GA13218@gondor.apana.org.au>
	<4150E7E5.2000001@eurodev.net>
	<20040922045239.GA19573@gondor.apana.org.au>
	<1095854920.1047.64.camel@jzny.localdomain>
	<20040922105221.59a67d4b.davem@davemloft.net>
	<4152EE68.4030803@eurodev.net>
	<20040923121651.51a58cf2.davem@davemloft.net>
	<20040924032830.GC6384@gondor.apana.org.au>
	<20040923223909.6f4da27f.davem@davemloft.net>
	<20040924062604.GA7393@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@eurodev.net, hadi@cyberus.ca, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040924062604.GA7393@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Sep 2004 16:26:04 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> It also means those responders that can calculate the correct size
> of the reply doesn't need to go through this copy process.

This is the crux of the problem, you don't know how big
the response will be until you look at the whole object
you are returning.

This is because there are usually an unknown number of
attributes that will be returned.

This is why I suggested the PAGE_SIZE scratchpad, you build
the response fully into there, then you know the exact size
SKB you need so you allocate it and copy into it from the
scratch pad.

It's just a response build up area, and the goal is to have
the minimum sized SKB necessary to represent the response.
