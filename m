From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: Wed, 30 Mar 2005 22:23:21 +1000
Message-ID: <20050330122321.GA10602@gondor.apana.org.au>
References: <1111864971.1092.904.camel@jzny.localdomain> <20050326194707.GA9872@gondor.apana.org.au> <1111867875.1089.915.camel@jzny.localdomain> <20050327081848.GA13428@gondor.apana.org.au> <1111950449.1089.938.camel@jzny.localdomain> <20050330004903.GA3399@gondor.apana.org.au> <1112184572.1089.80.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112184572.1089.80.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal:

On Wed, Mar 30, 2005 at 07:09:32AM -0500, jamal wrote:
> 
> In the case you flush you dont wanna send multiple DELETEs. Just one 
> FLUSH at the end when flushing is done. At least this is behavior
> of PFKEY (at least on the RFC). I think its a good thing.

You're right.

> > > +/* callback structure passed from either netlink or pfkey */
> > > +struct xfrm_sa_cb
> > > +{
> > > +	u32	type; /* the type of caller netlink/pfkey/other */
> > > +	u32	data; /* callee to caller */
> > > +	void *hdr;
> > > +	struct sk_buff *skb;
> > 
> > I don't think we need to carry the original hdr and skb around.
> > I see below that you're using it to fill in the pid/seq when
> > sending netlink messages.  Since these are multicast messages
> > resent by the kernel they should not inherit those values from
> > the original skb.
> > 
> 
> Thinking ... thinking .. Good point.
> 
> I defineteley need at least:
> a) case original message sent via netlink: pid of the original process
> so when i multicast in netlink i dont echo back to it.

I don't think you need to do that.  RFC 2367 says that the kernel should
send that message to all listening processes.  It doesn't put an exception
on the sending process.

This makes sense also because the echoed message is really a new packet
sent by the kernel.  It's not necessarily equal to the original packet.

In fact checking the socket pid is not enough to avoid sending the
message back to the originator.  For instance, if the originator
used a different socket for receiving multicast messages then this
wouldn't work anyway.

For netlink it is important to use a different socket for receiving
multicast messages since otherwise you run the risk of losing unicast
messages when it overruns.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
