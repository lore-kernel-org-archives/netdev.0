From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Fri, 17 Oct 2008 06:39:48 -0400
Message-ID: <20081017103948.GA23591@hmsreliant.think-freely.org>
References: <20081006225210.GA29794@hmsreliant.think-freely.org> <48EAEFF9.1000606@cosmosbay.com> <20081013182655.GA9505@hmsreliant.think-freely.org> <20081015.235556.61915120.davem@davemloft.net> <20081016114155.GA15877@hmsreliant.think-freely.org> <48F732CB.8030704@cosmosbay.com> <20081016163644.GA2933@localhost.localdomain> <20081016233517.GA21243@localhost.localdomain> <20081016220624.512a1e61@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59874 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040AbYJQKl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 06:41:57 -0400
Content-Disposition: inline
In-Reply-To: <20081016220624.512a1e61@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 16, 2008 at 10:06:24PM -0700, Stephen Hemminger wrote:
> O
> > +static inline int rt_caching(struct net *net)
> > +{
> > +	return net->ipv4.current_rt_cache_rebuild_count <=
> > +		net->ipv4.sysctl_rt_cache_rebuild_count;
> > +}
> 
> Why not?
> 
I assume that you're asking why we use these values to determine if this
namespace should use the route cache?  The answer is this thread.  Because
ideally we should never rebuild the route cache unless something is giving the
cache an uneven distribution.  The consensus is that if we rebuild too many
times, its an indicator that someone knows enough about our hashing algorithm to
maliginantly force the creation of routes in the cache on the same chain
regardless of how many times we rebuild it.  In that case the best thing to do
is skip the use of the cache entirely.

Neil

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
