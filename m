From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 13:57:35 -0700 (PDT)
Message-ID: <20100331.135735.00480230.davem@davemloft.net>
References: <20100331135505.GC14082@gondor.apana.org.au>
	<1270044768.26743.58.camel@bigi>
	<20100331141525.GA14331@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59177
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932141Ab0CaU5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 16:57:34 -0400
In-Reply-To: <20100331141525.GA14331@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 31 Mar 2010 22:15:25 +0800

> Dave can keep or revert this as he likes.

Herbert, if it doesn't break anything, I feel the gains are very
worthwhile.

When we have a breakage report, I will undo this or fix it
immediately.  Until then, we have to be cognizant of what positives we
get out of this.

Have you actually tried to monitor the IPSEC netlink socket events
when a daemon is running?  It's way too painful before Jamal's
changes, and we already emit way too many semantically empty events in
netlink.

Minimization of the noise is a good thing, if it can legally be done,
which I believe is the case here.  And this applies to pfkey events
too, because processing those is even more expensive on the
application side.
