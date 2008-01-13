From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_semantics: prevent long hash chains in access
 server config
Date: Sat, 12 Jan 2008 21:38:57 -0800 (PST)
Message-ID: <20080112.213857.68003780.davem@davemloft.net>
References: <20080112185819.GA12775@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58071
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751235AbYAMFi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 00:38:57 -0500
In-Reply-To: <20080112185819.GA12775@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Sat, 12 Jan 2008 13:58:19 -0500

> This is a patch from a while ago that I'm resending.  Basically, in
> access server configurations, a lot of routes have the same local ip
> address but on different devices.  This fixes the long chains that
> result from not including the device index in the hash.

I'm not applying this for the same reason I didn't apply it last time.

Please listen to the reason this time, and do not resubmit this until
the problem with this patch is resolved.

The fib_dev is an attribute of the first nexthop, ie. the
fib_info->fib_nh[0] member.

There can be multiple nexthops.

It is pointless to salt the hash with one of the nexthop
device indexes if you do not also compare the index in the
hash lookup comparisons.

And guess why we don't do this?  Because it's not part of
the key.  Other aspects of the base fib_info and nexthops
provide the uniqueness, not the devindex of the first hop.

So you'll need to find another way to do this.
