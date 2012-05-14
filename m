From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/4] netfilter: ipset: fix timeout value overflow bug
Date: Mon, 14 May 2012 21:00:15 +0200
Message-ID: <20120514190015.GB14897@1984>
References: <1336996023-20249-2-git-send-email-pablo@netfilter.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6F0B@saturn3.aculab.com>
 <20120514143635.GA12992@1984>
 <1337006844.8512.491.camel@edumazet-glaptop>
 <alpine.DEB.2.00.1205141943240.28291@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43414 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757426Ab2ENTAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 15:00:18 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1205141943240.28291@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 14, 2012 at 07:45:07PM +0200, Jozsef Kadlecsik wrote:
> On Mon, 14 May 2012, Eric Dumazet wrote:
> 
> > On Mon, 2012-05-14 at 16:36 +0200, Pablo Neira Ayuso wrote:
> > > On Mon, May 14, 2012 at 03:19:49PM +0100, David Laight wrote:
> > > >  
> > > > > --- a/include/linux/netfilter/ipset/ip_set_timeout.h
> > > > > +++ b/include/linux/netfilter/ipset/ip_set_timeout.h
> > > > > @@ -30,6 +30,10 @@ ip_set_timeout_uget(struct nlattr *tb)
> > > > >  {
> > > > >  	unsigned int timeout = ip_set_get_h32(tb);
> > > > >  
> > > > > +	/* Normalize to fit into jiffies */
> > > > > +	if (timeout > UINT_MAX/1000)
> > > > > +		timeout = UINT_MAX/1000;
> > > > > +
> > > > 
> > > > Doesn't that rather assume that HZ is 1000 ?
> > > 
> > > Indeed. I overlooked that. Thanks David.
> > 
> > I dont think so.
> > 
> > 1000 here is really MSEC_PER_SEC
> > 
> > (All occurrences should be changed in this file)
> 
> Yes, exactly. Pablo, shall I produce a little patch or could you change 
> 1000 to MSEC_PER_SEC?

I'll mangle this myself. No need to send a new patch.
