From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 1/4] netfilter: ipset: fix timeout value overflow bug
Date: Mon, 14 May 2012 19:45:07 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1205141943240.28291@blackhole.kfki.hu>
References: <1336996023-20249-2-git-send-email-pablo@netfilter.org>  <AE90C24D6B3A694183C094C60CF0A2F6026B6F0B@saturn3.aculab.com>  <20120514143635.GA12992@1984> <1337006844.8512.491.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Laight <David.Laight@ACULAB.COM>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1337006844.8512.491.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 May 2012, Eric Dumazet wrote:

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
> 
> (All occurrences should be changed in this file)

Yes, exactly. Pablo, shall I produce a little patch or could you change 
1000 to MSEC_PER_SEC?

Best regards, 
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
