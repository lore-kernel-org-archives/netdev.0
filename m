From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Wed, 29 Sep 2004 21:42:34 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929114234.GD29516@gondor.apana.org.au>
References: <20040928032321.GB10116@gondor.apana.org.au> <1096343125.8661.96.camel@jzny.localdomain> <20040928035921.GA10675@gondor.apana.org.au> <1096367787.8662.146.camel@jzny.localdomain> <20040928111159.GA18421@gondor.apana.org.au> <1096374736.8663.217.camel@jzny.localdomain> <20040929001327.GB25293@gondor.apana.org.au> <1096426324.1044.129.camel@jzny.localdomain> <20040929032724.GA26959@gondor.apana.org.au> <1096455046.1044.189.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1096455046.1044.189.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2004 at 06:50:46AM -0400, jamal wrote:
>
> Ok, You fell into my trap. I just had to say that ;-> We are even.

Fair enough :)
 
> Assume you are delivering a huge atomic multi message; lets say it
> constitutes 50 pkts.
> --> You deliver up to 15 and then overrun.
> --> The 15 pkts are a waste, really. User will have to poll
> for the info for all details to be sure i.e you dont know what was lost
> for sure if you get an overrun. In otherwise the transaction was not
> delivered to its completion.

I presume that the ifdown script you posted fits this description?
I agree this is suboptimal.  However, I don't see how the intermediate
queue can help here.

Hmm, I suspect that there is something broken here that's causing the
overruns.  Let me have a play with your script/ip monitor and get back
to you.

> I dont think 10 are a big deal but multiply by some factor and the cost
> is clear to quantify.

Agreed.  Perhaps what we need is a way to identify these messages as
related.  If you can do that then the kernel can forget about them
when an overrun occurs.

I still don't see this as a big deal though since the application can
always weather the storm by closing the socket after an overrun,
sleeping for a while and then reopen it to listen again.

> If you insist however, heres one i can visualize thats a legit get from
> a semantic view:
> A get of a table entry which itself happens to be a table (and if you
> want to be funnier maybe three level deep table). You do a get on a
> table entry, you get a _whole table_ back. 

That's easy :) Anything that's a table should use dump.  Remember that
dump can take parameters just like get.  So there's nothing wrong with
using dump to get an entry which happens to be a table.

PS We've managed to cut down the size of our emails by half.  Shows that
congestion control is certainly working on this mailing list :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
