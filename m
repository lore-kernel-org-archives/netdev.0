From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Wed, 22 Sep 2004 14:52:39 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922045239.GA19573@gondor.apana.org.au>
References: <414DF11C.1080505@eurodev.net> <20040919215915.GB9573@gondor.apana.org.au> <1095633569.1047.107.camel@jzny.localdomain> <20040919231734.GA10124@gondor.apana.org.au> <1095647944.1046.206.camel@jzny.localdomain> <20040920025802.GA11567@gondor.apana.org.au> <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <4150E7E5.2000001@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2004 at 04:48:05AM +0200, Pablo Neira wrote:
> 
> b) I'm thinking about netlink sockets as a method to generate event 
> notifications. My benchmark tool just want to emulate that N events 
> happen in a *very* short period of time (worst case), that implies 
> sending N messages. So, forget that my tool sends previously a message 
> to generate those N messages.

That's what I thought you wanted too, something like ip_queue.

You've got to remember that for ip_queue netlink is inherently
*unreliable*.  Your application must be able to cope with dropped
packets and recover in a sane way.  The kernel makes it slightly
easier for you in that it'll tell you if messages have been dropped.
But in the end it's up to the application to deal with it.

The only knob that you can tweak is the receive queue length.  You
might think that making the kernel wait/back off is going solve the
problem.  But it's just another way of extending the receive queue
length.
 
> Jamal, you're getting an overrun dumping ipsec policies. If I'm not 
> wrong, that tool is doing that as dump operation, but that this 
> shouldn't happen by using dump. Am I missing something?

I've never seen any overruns with IPsec.  Perhaps there is a bug
somewhere.

> I would like to have a way to send notifications via netlink sockets 
> without losing congestion control ability, that is, without losing 
> messages because of an overrun.

Congestion control similar to the way dumping works may work for you.
But you need to tell us more about what you're actually using this for.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
