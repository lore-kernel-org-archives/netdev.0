From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] ipv6: Split from and expires field in dst_entry out
 of union [net-next]
Date: Tue, 19 Feb 2013 16:49:34 -0500
Message-ID: <20130219214934.GD31871@hmsreliant.think-freely.org>
References: <1361231718.19353.117.camel@edumazet-glaptop>
 <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com>
 <1361308665.19353.161.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>, Jiri Bohac <jbohac@suse.cz>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34970 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933891Ab3BSVtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 16:49:39 -0500
Content-Disposition: inline
In-Reply-To: <1361308665.19353.161.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 19, 2013 at 01:17:45PM -0800, Eric Dumazet wrote:
> On Tue, 2013-02-19 at 15:28 -0500, Neil Horman wrote:
> 
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
> >  
> 
> Sorry you didnt really address the problem, only reduce the race window.
> 
I kinda had a feeling you would say that, but the only other solution I see here
is to either introduce some locking to protect the from pointer, or two revert
the patch that introduced the from pointer alltogether, neither of which sounds
appealing to me.  I suppose we could use an xchng to atomically update the from
pointer, so there was only ever one context that was able to free it in
rt6_update_path.  Does that seem reasonable to you?

Neil
