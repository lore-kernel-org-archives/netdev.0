From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Tue, 28 Sep 2004 13:59:21 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928035921.GA10675@gondor.apana.org.au>
References: <20040923120707.GB32624@gondor.apana.org.au> <1095995042.1044.34.camel@jzny.localdomain> <20040924032440.GB6384@gondor.apana.org.au> <1096289189.1075.37.camel@jzny.localdomain> <20040927213607.GD7243@gondor.apana.org.au> <1096339407.8660.33.camel@jzny.localdomain> <20040928024614.GA9911@gondor.apana.org.au> <1096340772.8659.51.camel@jzny.localdomain> <20040928032321.GB10116@gondor.apana.org.au> <1096343125.8661.96.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1096343125.8661.96.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 11:45:25PM -0400, jamal wrote:
> 
> > Now that we know where the events are coming from and what they are,
> > we can decide on the solution.  In this particular case, there is
> > nothing you can do on the sending side.  Stopping people from operating
> > on networking objects just because some netlink listener can't keep up
> > isn't going to work.  So congestion control is out of the question.
> 
> fixing the NLM_GOODSIZE issue is a very good first step.

Well I'm afraid that it doesn't help in your interface address example
because rtmsg_ifa() already allocates a buffer of (approximately) the
right size.  That is, it doesn't use NLM_GOODSIZE at all.

> Adding congestion control would be harder but not out of question.

But the question is who are you going to throttle? If you throttle
the source of the messages then you're going to stop people from adding
or deleting IP addresses which can't be right.

If you move the netlink sender into a different execution context and
throttle that then that's just extending the receive queue length by
stealth.

So I'm afraid I don't see how congestion control could be applied in
*this* particular context.
 
> > So just bite the bullet and reread the system state by issuing dump
> > operations.
> 
> We may as well choose to document it as being this mostly because of the
> issue i described above. We shouldnt give up so easily though ;->

Well IMHO this is not giving up at all.

Think of it another way.  Monitoring routes is like maintaining a
program.  Normally you just fix the bugs as they come.  But if the
bug reports are coming in so fast that you can't keep up, perhaps
it's time to throw it away and rewrite it from scratch :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
