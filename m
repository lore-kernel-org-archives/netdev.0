From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Problem with IPSEC tunnel mode
Date: Fri, 22 Apr 2005 11:04:45 +1000
Message-ID: <20050422010445.GA10918@gondor.apana.org.au>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au> <200504211640.16742.wolfgang.walter@studentenwerk.mhn.de> <20050421214618.GA29991@gondor.apana.org.au> <200504220240.31280.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Content-Disposition: inline
In-Reply-To: <200504220240.31280.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 22, 2005 at 02:40:31AM +0200, Wolfgang Walter wrote:
>
> > Although you probably have rp_filter turned, but please check
> >
> > cat /proc/sys/net/ipv4/conf/eth3/rp_filter
> >
> > anway.

Please do this check.

> > > src 10.148.0.0/23 dst 10.0.25.210/32
> > >  dir fwd priority 0
> >
> > There you go.  This policy trumps your other policy.  This one
> > says that forwarded traffic matching it must carry no tunnel
> > IPsec transforms.  Therefore all IPsec packets matching it will
> > be dropped.
> 
> I don't understand that. 10.148.0.0/23 is 10.148.0.0-10.148.1.255, isn't it? 
> But 10.148.4.0/28 (is 10.148.4.0-10.148.4.15) is not within it.

Sorry, I misread the netmask.  I was right about the problem though :)
Further down it says

src 0.0.0.0/0 dst 10.0.25.210/32
	dir fwd priority 0

which still trumps your IPsec policy.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
