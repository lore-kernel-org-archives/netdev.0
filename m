From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 27 Sep 2004 23:45:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096343125.8661.96.camel@jzny.localdomain>
References: <20040922045239.GA19573@gondor.apana.org.au>
	 <1095854920.1047.64.camel@jzny.localdomain>
	 <20040923120707.GB32624@gondor.apana.org.au>
	 <1095995042.1044.34.camel@jzny.localdomain>
	 <20040924032440.GB6384@gondor.apana.org.au>
	 <1096289189.1075.37.camel@jzny.localdomain>
	 <20040927213607.GD7243@gondor.apana.org.au>
	 <1096339407.8660.33.camel@jzny.localdomain>
	 <20040928024614.GA9911@gondor.apana.org.au>
	 <1096340772.8659.51.camel@jzny.localdomain>
	 <20040928032321.GB10116@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040928032321.GB10116@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-09-27 at 23:23, Herbert Xu wrote:

> But ifconfig doesn't use netlink.  So I presume you're referring to
> some other application that's listening for interface/address/route
> events.

Thats right. 
I think you should be able to run ip monitor to see the overrun.

> Firstly thanks this is exactly what I've been asking for -- a real
> world scenario :)

I can assure you theres many more like this;->
My remote app is not this btw.

> Now that we know where the events are coming from and what they are,
> we can decide on the solution.  In this particular case, there is
> nothing you can do on the sending side.  Stopping people from operating
> on networking objects just because some netlink listener can't keep up
> isn't going to work.  So congestion control is out of the question.

fixing the NLM_GOODSIZE issue is a very good first step.
Adding congestion control would be harder but not out of question.
The hard part is not in the maintaing state part (as the case of dump)
its rather how you start getting slowed down (in a broadcast) by one
slow (or buggy) app thats also decided its gonna have very low socket
buffer sizes. 

> That leaves two options AFAICS.  The easy way out is to increase the
> receive buffer size.  Of course after a while this is not going to
> work.

Indeed. It just postpones the overrun.

> The second option which is the one I prefer: If so many events are
> occuring and you can't keep up, it's time to give up :)
> 
> So just bite the bullet and reread the system state by issuing dump
> operations.

We may as well choose to document it as being this mostly because of the
issue i described above. We shouldnt give up so easily though ;->

cheers,
jamal
