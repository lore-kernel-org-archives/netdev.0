From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Tue, 28 Sep 2004 13:23:21 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928032321.GB10116@gondor.apana.org.au>
References: <20040922045239.GA19573@gondor.apana.org.au> <1095854920.1047.64.camel@jzny.localdomain> <20040923120707.GB32624@gondor.apana.org.au> <1095995042.1044.34.camel@jzny.localdomain> <20040924032440.GB6384@gondor.apana.org.au> <1096289189.1075.37.camel@jzny.localdomain> <20040927213607.GD7243@gondor.apana.org.au> <1096339407.8660.33.camel@jzny.localdomain> <20040928024614.GA9911@gondor.apana.org.au> <1096340772.8659.51.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1096340772.8659.51.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 11:06:12PM -0400, jamal wrote:
> 
> Ok, heres a sample testcase i created just now following those same
> instructions i gave you ;->
> 
> ---
> #!/bin/sh
> 
> ifconfig dummy0 1.2.1.1 netmask 255.255.255.0 broadcast 1.2.1.255 up
> ifconfig dummy0:0 1.2.1.1
> for ((i = 1 ; i <= $1 ; i++))
> do
>         ifconfig dummy0:$i 1.2.1.$i
> done
> ---
> 
> pass 100 to it to create 100 aliases; you may not need to setsock to
> 4096, but thats what i did. 
> 
> down dummy0:0 and see the overrun.

But ifconfig doesn't use netlink.  So I presume you're referring to
some other application that's listening for interface/address/route
events.

Firstly thanks this is exactly what I've been asking for -- a real
world scenario :)

Now that we know where the events are coming from and what they are,
we can decide on the solution.  In this particular case, there is
nothing you can do on the sending side.  Stopping people from operating
on networking objects just because some netlink listener can't keep up
isn't going to work.  So congestion control is out of the question.

That leaves two options AFAICS.  The easy way out is to increase the
receive buffer size.  Of course after a while this is not going to
work.

The second option which is the one I prefer: If so many events are
occuring and you can't keep up, it's time to give up :)

So just bite the bullet and reread the system state by issuing dump
operations.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
