From: "Denis V. Lunev" <den@parallels.com>
Subject: Re: [PATCH 2/2] netns: Add network namespace argument in
	rt6_fill_node() and ipv6_dev_get_saddr()
Date: Fri, 15 Aug 2008 00:18:44 +0400
Message-ID: <1218745124.16589.73.camel@iris.sw.ru>
References: <48A48722.3050509@hp.com>  <48A48FC9.4020805@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	containers <containers@lists.osdl.org>,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:45492 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753324AbYHNUST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 16:18:19 -0400
In-Reply-To: <48A48FC9.4020805@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-08-14 at 16:04 -0400, Vlad Yasevich wrote:
> Hi Brian
> 
> Brian Haley wrote:
> > ---
> > 
> > diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> > index 483a01d..e0945d4 100644
> > --- a/net/sctp/ipv6.c
> > +++ b/net/sctp/ipv6.c
> > @@ -319,7 +319,8 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
> >  			  __func__, asoc, dst, NIP6(daddr->v6.sin6_addr));
> >  
> >  	if (!asoc) {
> > -		ipv6_dev_get_saddr(dst ? ip6_dst_idev(dst)->dev : NULL,
> > +		ipv6_dev_get_saddr(NULL,
> > +				   dst ? ip6_dst_idev(dst)->dev : NULL,
> >  				   &daddr->v6.sin6_addr,
> >  				   inet6_sk(&sk->inet.sk)->srcprefs,
> >  				   &saddr->v6.sin6_addr);
> 
> 
> I think this needs to use sock_net(sctp_opt2s(sk)) instead of NULL.

this looks safe to me

