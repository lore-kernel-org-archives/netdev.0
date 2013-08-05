From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: changing dev->needed_headroom/needed_tailroom?
Date: Mon, 05 Aug 2013 16:00:40 +0200
Message-ID: <1375711240.8120.11.camel@jlt4.sipsolutions.net>
References: <1374850210.8248.59.camel@jlt4.sipsolutions.net>
	 <1375433758.24371.20.camel@deadeye.wl.decadent.org.uk>
	 <1375449082.3927.5.camel@edumazet-glaptop>
	 (sfid-20130802_151126_631897_9E569FA7)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:51397 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645Ab3HEOAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 10:00:45 -0400
In-Reply-To: <1375449082.3927.5.camel@edumazet-glaptop> (sfid-20130802_151126_631897_9E569FA7)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-02 at 06:11 -0700, Eric Dumazet wrote:
> On Fri, 2013-08-02 at 10:55 +0200, Ben Hutchings wrote:
> 
> > I don't think this is safe when the interface is running (even if
> > carrier is off).  Some functions may read dev->needed_headroom twice and
> > rely on getting the same value each time.
> 
> It should be no problem. Remaining unsafe places should be fixed.

Most interesting would be stack devs, which I hadn't even considered. In
any case, since I can't completely _rely_ on it, it's an optimisation,
the only bugs would be around the double-access and then running
over/under the SKB or so?

> We already had this discussion in the past, and some patches were
> issued. Check commit ae641949df01b85117845bec45328eab6d6fada1
> ("net: Remove all uses of LL_ALLOCATED_SPACE")

That would have addressed some of that, I guess.


I'm asking because some of the crypto stuff we do has fairly large
head/tailroom requirements and it seems I may need to add more. But if
you don't have crypto, it would be much smaller, so I figured we could
switch it.

johannes
