From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6 addrconfg warn_on hit: WARN_ON(ifp->idev->valid_ll_addr_cnt < 0);
Date: Thu, 16 Jan 2014 15:38:17 +0100
Message-ID: <20140116143817.GH7436@order.stressinduktion.org>
References: <20140116135323.GA7961@minipsycho.orion> <20140116140701.GB7961@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42683 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbaAPOiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 09:38:18 -0500
Content-Disposition: inline
In-Reply-To: <20140116140701.GB7961@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 03:07:01PM +0100, Jiri Pirko wrote:
> Thu, Jan 16, 2014 at 02:53:23PM CET, jiri@resnulli.us wrote:
> >Hi Hannes.
> >
> >WARN_ON(ifp->idev->valid_ll_addr_cnt < 0);
> >
> >We did hit once this warning during the tests. The person who hit this
> >says that it was during the setup of many macvlan devices.
> >
> >I examined the code but I'm not sure how this could happen. Looks like a
> >race condition between addrconf_dad_completed() and addrconf_ifdown(). 
> >Not sure how to easily resolve that though.

That seems to be the case. Actually we don't need to count precisiely
here, we just must precisiely identify the situation where the first
LL address comes into operational state. Maybe we can implement this
somehow differently. I'll play with the code soon.

Thanks,

  Hannes
