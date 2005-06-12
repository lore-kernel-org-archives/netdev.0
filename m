From: Willy Tarreau <willy@w.ods.org>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 10:34:09 +0200
Message-ID: <20050612083409.GA8220__37403.5001885661$1118565125$gmane$org@alpha.home.local>
References: <20050611074350.GD28759@alpha.home.local> <E1DhBic-0005dp-00@gondolin.me.apana.org.au> <20050611195144.GF28759@alpha.home.local> <20050612081327.GA24384@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050612081327.GA24384@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 12, 2005 at 06:13:27PM +1000, Herbert Xu wrote:
> On Sat, Jun 11, 2005 at 09:51:44PM +0200, Willy Tarreau wrote:
> > 
> > Please note that if I only called it "small DoS", it's clearly because
> > I don't consider this critical, but I think that most people involved
> > in security will find that DoSes based on port guessing should be
> > addressed when possible.
> 
> Sorry but this patch is pointless.  If I wanted to prevent you from
> connecting to www.kernel.org 80 and I knew your source port number
> I'd be directly sending you fake SYN-ACK packets which will kill
> your connection immediately.

Only if your ACK was within my SEQ window, which adds about 20 bits of
random when my initial window is 5840. You would then need to send one
million times more packets to achieve the same goal.

> If you want reliability and security you really should be using IPsec.
> There is no other way.

I agree with you on the fact that people who need security must use
secure protocols. I had the same words last year when people discovered
that a TCP RST could kill a BGP session, and the end of the internet was
announced. Hey, if someone needs secure BGP, he must use MD5 sums from
the start.

I'm not meaning to make TCP as secure as IPsec, but I think that when
supporting a feature (simultaneous connect) that nobody uses and many
OSes do not even support introduces a weakness, we could at least make
it optional. It could also rely on a #if CONFIG_TCP_SIMULT which will
slightly reduce kernel size for people who know they don't want it.

Cheers,
Willy
