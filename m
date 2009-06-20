From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix NULL pointer + success return in route lookup path
Date: Sat, 20 Jun 2009 01:15:43 -0700 (PDT)
Message-ID: <20090620.011543.74198631.davem@davemloft.net>
References: <20090619171814.GE18237@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mbizon@freebox.fr, dada1@cosmosbay.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50937
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751271AbZFTIPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 04:15:39 -0400
In-Reply-To: <20090619171814.GE18237@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 19 Jun 2009 13:18:14 -0400

> Don't drop route if we're not caching	
> 
> 	I recently got a report of an oops on a route lookup.  Maxime was
> testing what would happen if route caching was turned off (doing so by setting
> making rt_caching always return 0), and found that it triggered an oops.  I
> looked at it and found that the problem stemmed from the fact that the route
> lookup routines were returning success from their lookup paths (which is good),
> but never set the **rp pointer to anything (which is bad).  This happens because
> in rt_intern_hash, if rt_caching returns false, we call rt_drop and return 0.
> This almost emulates slient success.  What we should be doing is assigning *rp =
> rt and _not_ dropping the route.  This way, during slow path lookups, when we
> create a new route cache entry, we don't immediately discard it, rather we just
> don't add it into the cache hash table, but we let this one lookup use it for
> the purpose of this route request.  Maxime has tested and reports it prevents
> the oops.  There is still a subsequent routing issue that I'm looking into
> further, but I'm confident that, even if its related to this same path, this
> patch makes sense to take.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied and queued up for -stable, thanks.
