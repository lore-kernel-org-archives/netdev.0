From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Tue, 21 Sep 2004 22:09:37 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C9jSj-0002qH-00@gondolin.me.apana.org.au>
References: <1095767265.1049.58.camel@jzny.localdomain>
Cc: herbert@gondor.apana.org.au, pablo@eurodev.net, davem@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095767265.1049.58.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> wrote:
> 
> A get which results in a huge response (cant think of anything that
> fits there - I have some stuff i havent released yet which applies) will
> also have the same. Note by "large" implies it will overflow socket
> buffer (and a setsock to increase the size will delay the problem from
> happening).

But congestion control doesn't help you there.  We have no concept
of fragmentation for netlink so the queue size has to accomodate the
biggest response packet.  Seriously if a single response is going to
overflow your entire queue there's gotta be something wrong :)

> Note, that an overrun in a dump results in lost messages. Maybe we can
> detect that and reset the cb pointers appropriately? Have to look at the
> code.

Dumping should never result in overruns unless the application is buggy.
We always allocate a one-page skb and fill it up before sending it to
the user.  We never start filling in the next one until the user has
received the first skb and that the receive queue is less than half full.

So I'm intrigued about this problem that Pablo is seeing.  Let me have
a play with it first.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
