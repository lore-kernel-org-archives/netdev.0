From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipv6: remove another useless NULL check
Date: Mon, 29 Oct 2012 17:08:15 +0800
Message-ID: <1351501695.8221.11.camel@cr0>
References: <1351491005.7394.7.camel@edumazet-glaptop>
	 <1351498585-20087-1-git-send-email-amwang@redhat.com>
	 <1351499588.7394.198.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932243Ab2J2JIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 05:08:21 -0400
In-Reply-To: <1351499588.7394.198.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-29 at 09:33 +0100, Eric Dumazet wrote:
> On Mon, 2012-10-29 at 16:16 +0800, Cong Wang wrote:
> > When 'rt' is NULL, '&rt->dst' is NULL too because >dst
> > is always the first field of 'rt'. And dst_release accepts
> > NULL.
> > 
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> > 
> > ---
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index 8f0b12a..adeb479 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -2027,8 +2027,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
> >  			addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
> >  					      dev, expires, flags);
> >  		}
> > -		if (rt)
> > -			dst_release(&rt->dst);
> > +		dst_release(&rt->dst);
> >  	}
> >  
> >  	/* Try to figure out our local address for this prefix */
> 
> 
> 
> Could you instead introduce a helper for that, like we have in IPv4.

Sure, that is better.
