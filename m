From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/4] netfilter: ipset: fix timeout value overflow bug
Date: Tue, 15 May 2012 09:21:04 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F0C@saturn3.aculab.com>
References: <1337006844.8512.491.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netfilter-devel@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	"Jozsef Kadlecsik" <kadlec@blackhole.kfki.hu>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1337006844.8512.491.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com] 
> Sent: 14 May 2012 15:47
> To: Pablo Neira Ayuso
> Cc: David Laight; netfilter-devel@vger.kernel.org; 
> davem@davemloft.net; netdev@vger.kernel.org; Jozsef Kadlecsik
> Subject: Re: [PATCH 1/4] netfilter: ipset: fix timeout value 
> overflow bug
> 
> On Mon, 2012-05-14 at 16:36 +0200, Pablo Neira Ayuso wrote:
> > On Mon, May 14, 2012 at 03:19:49PM +0100, David Laight wrote:
> > >  
> > > > --- a/include/linux/netfilter/ipset/ip_set_timeout.h
> > > > +++ b/include/linux/netfilter/ipset/ip_set_timeout.h
> > > > @@ -30,6 +30,10 @@ ip_set_timeout_uget(struct nlattr *tb)
> > > >  {
> > > >  	unsigned int timeout = ip_set_get_h32(tb);
> > > >  
> > > > +	/* Normalize to fit into jiffies */
> > > > +	if (timeout > UINT_MAX/1000)
> > > > +		timeout = UINT_MAX/1000;
> > > > +
> > > 
> > > Doesn't that rather assume that HZ is 1000 ?
> > 
> > Indeed. I overlooked that. Thanks David.
> 
> I dont think so.
> 
> 1000 here is really MSEC_PER_SEC

I was just reading the comment above - which seemed to imply
the purpose of the code was to ensure the timeout wouldn't
exceeded 2^32 jiffies.

I tend to use variable names for timeouts/timestamps that
include the units - can make it more obvious when a divisor
is absent - and makes it more obvious what the literal
constants are converying beween.
After all, the number of milliseconds in a second isn't
subject to change :-)

	David


