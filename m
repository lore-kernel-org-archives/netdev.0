From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 23 Sep 2004 23:04:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095995042.1044.34.camel@jzny.localdomain>
References: <1095633569.1047.107.camel@jzny.localdomain>
	 <20040919231734.GA10124@gondor.apana.org.au>
	 <1095647944.1046.206.camel@jzny.localdomain>
	 <20040920025802.GA11567@gondor.apana.org.au>
	 <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net>
	 <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net>
	 <20040922045239.GA19573@gondor.apana.org.au>
	 <1095854920.1047.64.camel@jzny.localdomain>
	 <20040923120707.GB32624@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040923120707.GB32624@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-09-23 at 08:07, Herbert Xu wrote:
> On Wed, Sep 22, 2004 at 08:08:40AM -0400, jamal wrote:
> >
> > Since netlink is being used for a lot of things now, it may be time to
> > obsolete those assumptions. 
> 
> I'm not against changes.  But so far I haven't seen anything concrete
> about what these new things are yet :)

So lets start by using the following logic:
1) If you made the socket buffers small enough compared to message
size/arrival rate, then an overrun will happen
corrollary:
2) If you made the message size/arrival fast enough relative to socket
size, an overrun will happen

If you agree that #1 is equivalent to #2, then you can experiment by #1
to see the issue.

> > Note also, theres a lot of wastage of that scarce sock buffer via page
> > sized skbs - its not as trivial to fix, but would go some way to improve
> > overrunning of the socket.
> 
> I wasn't aware of this scarcity problem.  Can you elaborate?

The NLM_GOODSIZE allocation done for each netlink skb,
In the case of the dump you dont apriori know how much space you need,
so it is fair. 

cheers,
jamal
