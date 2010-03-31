From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 13:52:39 -0700 (PDT)
Message-ID: <20100331.135239.170044408.davem@davemloft.net>
References: <20100331131131.GA13793@gondor.apana.org.au>
	<1270042092.26743.26.camel@bigi>
	<20100331135331.GB14082@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41120
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932107Ab0CaUwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 16:52:40 -0400
In-Reply-To: <20100331135331.GB14082@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 31 Mar 2010 21:53:31 +0800

> Dave, please revert this patch.

Herbert I actually don't agree with you on this one, sorry :-)

If no semantic change occurred to the policy or state databases,
there is zero reason to report the flush event, it's noise.

Like Jamal, I too am pretty frustrated with how noisy and unusable the
netlink messages are to watch when trying to debug something and this
behavior change should break no applications whatsoever.

When you have evidence of a real existing case failing because of
Jamal's changes (not some case you crafted specifically to show that
an empty flush doesn't get reported), I'll consider a revert or ask
Jamal to fix that case up.

Until then, Jamal's change is staying in the tree.
