From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] ipv6: Split from and expires field in dst_entry out
 of union [net-next]
Date: Wed, 20 Feb 2013 07:02:25 -0500
Message-ID: <20130220120225.GA14501@hmsreliant.think-freely.org>
References: <1361231718.19353.117.camel@edumazet-glaptop>
 <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7157@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	David Miller <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>, Jiri Bohac <jbohac@suse.cz>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42565 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935110Ab3BTMCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 07:02:44 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7157@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 20, 2013 at 10:55:35AM -0000, David Laight wrote:
> >  static inline void rt6_clean_expires(struct rt6_info *rt)
> >  {
> > -	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
> > +	if (!rt->rt6i_flags & RTF_EXPIRES)
> >  		dst_release(rt->dst.from);
> > 
> >  	rt->rt6i_flags &= ~RTF_EXPIRES;
> >  	rt->dst.from = NULL;
> > +	rt->dst.expires = 0;
> >  }
> > 
> >  static inline void rt6_set_expires(struct rt6_info *rt, unsigned long expires)
> >  {
> > -	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
> > +	if (!rt->rt6i_flags & RTF_EXPIRES)
> >  		dst_release(rt->dst.from);
> > 
> >  	rt->rt6i_flags |= RTF_EXPIRES;
> > +	rt->dst.from = NULL;
> >  	rt->dst.expires = expires;
> >  }
> > 
> >  static inline void rt6_update_expires(struct rt6_info *rt, int timeout)
> >  {
> >  	if (!(rt->rt6i_flags & RTF_EXPIRES)) {
> > -		if (rt->dst.from)
> > -			dst_release(rt->dst.from);
> > +		dst_release(rt->dst.from);
> >  		/* dst_set_expires relies on expires == 0
> >  		 * if it has not been set previously.
> >  		 */
> >  		rt->dst.expires = 0;
> > +		rt6->dst.from = NULL;
> >  	}
> 
> Aren't there also problems with setting and clearing RTF_EXPIRES?
> Since that flag looks as though it was the descriminant for the union
> it probably isn't needed - provided dst.expires is never 0 when valid.
> 
> 	David
The use of RTF_EXPIRES is weak at this point, if there are multiple accessors,
but I think the point is moot, in that the only thing we ever do when we change
the flag is release dst.from, which is safe.
Neil
