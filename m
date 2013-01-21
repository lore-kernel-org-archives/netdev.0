From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] State resolution packet queue for IPsec
Date: Mon, 21 Jan 2013 16:17:16 -0500 (EST)
Message-ID: <20130121.161716.752461350033731834.davem@davemloft.net>
References: <20130121094847.GC30530@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655Ab3AUVRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 16:17:19 -0500
In-Reply-To: <20130121094847.GC30530@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 21 Jan 2013 10:48:48 +0100

> I did a implementation of a state resolution packet queue for IPsec.
> The original idea is described in git commit 14e50e57a
> ([XFRM]: Allow packet drops during larval state resolution.)
> 
> Since we don't have any notifiers for xfrm state resolution, I used
> a timer that does a relookup in given intervals. This is mainly to speed
> up the start of tcp connections, so I tried to do the relookup in a higher
> rate that tcp would resend the syn packet. However, the relookup intervals,
> the queue size and the timeout value are choosen by gut instincts, so
> could be suboptimal. If anyone has some insight on good choices of these
> values, please let me know. All other comment are welcome too, of course.

This is probably the best way to solve this problem without adding
xfrm_state resolution notifications.

But really why would notifications be so bad even if they would not
be fine grained?

Any time a state is resolved, any state, you run what you have put
currently into this new timer function.

Most of the time, defer list is empty, so no work is done.  Otherwise
quick notification is essential and worth running the list.

Then there are no time based heuristics to come up with at all.
