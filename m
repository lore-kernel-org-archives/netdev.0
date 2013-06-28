From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: Check the argument for listen(2)
Date: Fri, 28 Jun 2013 18:32:34 +0200
Message-ID: <20130628163234.GA651@order.stressinduktion.org>
References: <1372436076-61436-1-git-send-email-xiaosuo@gmail.com> <1372436942.3301.286.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:43859 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226Ab3F1Qcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 12:32:35 -0400
Content-Disposition: inline
In-Reply-To: <1372436942.3301.286.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 28, 2013 at 09:29:02AM -0700, Eric Dumazet wrote:
> On Sat, 2013-06-29 at 00:14 +0800, Changli Gao wrote:
> > --- a/net/ipv4/af_inet.c
> > +++ b/net/ipv4/af_inet.c
> > @@ -198,6 +198,9 @@ int inet_listen(struct socket *sock, int backlog)
> >  	unsigned char old_state;
> >  	int err;
> >  
> > +	if (backlog >= (1 << 16))
> > +		return EINVAL;
> > +
> >  	lock_sock(sk);
> >  
> >  	err = -EINVAL;
> 
> This seems pretty buggy to me.
> 
> 1) EINVAL is not -EINVAL
> 
> 2) This might break existing applications.

Yes, we should clamp the value to netdev_max_backlog.

Greetings,

  Hannes
