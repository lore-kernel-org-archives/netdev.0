From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Thu, 23 Sep 2004 22:05:20 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923120520.GA32624@gondor.apana.org.au>
References: <20040919231734.GA10124@gondor.apana.org.au> <1095647944.1046.206.camel@jzny.localdomain> <20040920025802.GA11567@gondor.apana.org.au> <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net> <1095821624.1045.6.camel@jzny.localdomain> <20040922034634.GA14928@gondor.apana.org.au> <1095852956.1048.47.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1095852956.1048.47.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2004 at 07:35:57AM -0400, jamal wrote:
> On Tue, 2004-09-21 at 23:46, Herbert Xu wrote:
> > 
> > Well I haven't seen any with IPsec.  Can you please provide a strace
> > of a failed tc dump so that I know what I'm looking for?
> 
> Try explicitly reducing the socket buffer size and see what happens

What's wrong with the default sizes? If you decrease it far enough
of course it's going to overflow.
 
> set i to 10000 or a little more

You might want to optimise your add path.  It was painful with 20000 :)

> to dump: tc actions ls action drop

That was much faster, no overflows at all:

angband:~# time tc action ls action gact > out

real    0m0.943s
user    0m0.075s
sys     0m0.867s
angband:~# wc -l out
80000 out
angband:~#

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
