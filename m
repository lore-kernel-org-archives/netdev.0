From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 12:58:02 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920025802.GA11567@gondor.apana.org.au>
References: <414D0CCD.90209@eurodev.net> <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net> <20040919215915.GB9573@gondor.apana.org.au> <1095633569.1047.107.camel@jzny.localdomain> <20040919231734.GA10124@gondor.apana.org.au> <1095647944.1046.206.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1095647944.1046.206.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 19, 2004 at 10:39:04PM -0400, jamal wrote:
>  
> > However, in the scenarios that's been cited so far I can't see how it can
> > work.  For example, in the ip_queue context, the kernel really doesn't
> > have any alternative to dropping the packet, right?
> 
> I havent paid a lot of attention to ip_queue workings. But something

Well the ip_queue thing is simply a pipe that redirects packets going
into netfilter to user space.  So we can't really stop that pipe when
there is congestion.

AFAICT the problem Pablo is trying to solve is packet loss due to
netlink congestion.

There might actually be a problem with the kernel not waking up the
the user process when we tell it to.  It might even be a scheduling
problem.  But we'll need a test-case to assess that.

> that will get the kernel to backoff when a certain socket threshold gets
> exceeded then get it going again when a below a low watermak. Dumps
> already have markers stored in the callbacks, maybe something a long the
> same line of thinking. You may have to tell user space "theres more
> coming". Not sure how to achieve this, just brainstorming.
> Essentially this is where the improvements over std overun signaling is,
> IMO.

This might work.  But we really need to look at something concrete to
see what the implications are.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
