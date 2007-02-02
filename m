From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Fri, 2 Feb 2007 15:13:56 -0500
Message-ID: <20070202201356.GA29652@hmsreliant.homelinux.net>
References: <20070131.011629.84005028.yoshfuji@linux-ipv6.org> <20070131205443.GA12237@hmsreliant.homelinux.net> <20070202190634.GA29001@hmsreliant.homelinux.net> <20070202.114608.59498910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, vladislav.yasevich@hp.com, sri@us.ibm.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2653 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946048AbXBBUSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 15:18:46 -0500
Content-Disposition: inline
In-Reply-To: <20070202.114608.59498910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 02, 2007 at 11:46:08AM -0800, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Fri, 2 Feb 2007 14:06:34 -0500
> 
> > Ok, I'm still testing it, but heres a new patch for review.
> > Significant changes include the addition of a
> > CONFIG_IPV6_OPTIMISTIC_DAD option that is dependent on the inclusion
> > of both IPPV6 and EXPERIMENTAL options, as well as a new method for
> > redirecting packets from optimistic sources to incomplete neighbors
> > by instead looking up a default router in ip6_dst_lookup_tail, as I
> > described in my previous note.
> 
> This looks largely fine to me, but I wonder about one bit:
> 
> +
> +	/*
> +	 * Optimistic nodes need to join the anycast address
> +	 * right away
> +	 */
> +	if (ifp->flags & IFA_F_OPTIMISTIC)
> +		addrconf_join_anycast(ifp);
> +
> 
> If something can clear that bit during the DAD, we won't
> call addrconf_leave_anycast() later.  Can that happen?
The only way the flag should get cleared once we've started DAD is when it
completes or fails.  In the failure case, we destroy the ifaddr structure, which
I think should force a leave_anycast, while the completed condition calls
addrconf_leave_anycast as part of the completion process before it clears the
flags, so I think we should be ok.  If anyone sees anything to the contrary,
please let me know and I'll be sure to  plug the hole.

Thanks & Regards
Neil

> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
