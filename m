From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 23 Sep 2004 22:56:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095994597.1045.26.camel@jzny.localdomain>
References: <20040919231734.GA10124@gondor.apana.org.au>
	 <1095647944.1046.206.camel@jzny.localdomain>
	 <20040920025802.GA11567@gondor.apana.org.au>
	 <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net>
	 <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net>
	 <1095821624.1045.6.camel@jzny.localdomain>
	 <20040922034634.GA14928@gondor.apana.org.au>
	 <1095852956.1048.47.camel@jzny.localdomain>
	 <20040923120520.GA32624@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040923120520.GA32624@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-09-23 at 08:05, Herbert Xu wrote:

> > Try explicitly reducing the socket buffer size and see what happens
> 
> What's wrong with the default sizes? If you decrease it far enough
> of course it's going to overflow.

The idea is to reproduce the overun ;->

> > set i to 10000 or a little more
> 
> You might want to optimise your add path.  It was painful with 20000 :)

Probably debug prints slowing things; you could of course do some
batching like so:

$TC actions add \
 action drop index 1
 action drop index 2 
 action drop index 3 ...

Do 10 a time in the for loop and should be roughly 10 times as fast

> > to dump: tc actions ls action drop
> 
> That was much faster, no overflows at all:

I apologize i dont have time right now to chase it and experiment; my
test machine can be made to reproduce it. Maybe this weekend

cheers,
jamal
