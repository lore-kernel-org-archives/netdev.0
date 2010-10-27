From: David Miller <davem@davemloft.net>
Subject: Re: [Security] TIPC security issues
Date: Wed, 27 Oct 2010 10:29:40 -0700 (PDT)
Message-ID: <20101027.102940.112580564.davem@davemloft.net>
References: <1287704752.11051.79.camel@Dan>
	<AANLkTi=V93A660+YS8C2TvC13kGUcJpFgjPHUvONd_WW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drosenberg@vsecurity.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, netdev@vger.kernel.org,
	security@kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56697
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752331Ab0J0R3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 13:29:17 -0400
In-Reply-To: <AANLkTi=V93A660+YS8C2TvC13kGUcJpFgjPHUvONd_WW@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 21 Oct 2010 17:31:12 -0700

> Something like the appended UNTESTED patch. NOTE! it actually makes
> "verify_iovec()" *change* the iovec if it grows too big.

Ok I thought a bit about this patch.

How we can behave here depends upon the socket type.

For example, for a stream socket such as TCP a partial write is OK and
we could truncate the iovec like this.  That's fine.

But for a datagram socket, we have to have a one-to-one correspondance
between write() calls and packets on the wire.  So we'd either need to
accept the entire write() length or fail it with an error.

verify_iovec() (currently) doesn't have the socket type information
available, so it's not able to key off of that right now.

I agree that cutting off these cases at a high level would be the
thing to do long term, but right now verify_iovec() isn't positioned
such that we can do it just yet.

For now I'm going to look into specifically fixing the TIPC case and
also think longer term about another way to address this at a high
level.

