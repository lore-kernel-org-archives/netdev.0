From: David Miller <davem@davemloft.net>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Tue, 04 Dec 2007 22:30:23 -0800 (PST)
Message-ID: <20071204.223023.262159049.davem@davemloft.net>
References: <4755A21F.2020407@simon.arlott.org.uk>
	<20071205001230.GA11391@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon@fire.lp0.eu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49782
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751081AbXLEGaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 01:30:23 -0500
In-Reply-To: <20071205001230.GA11391@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 5 Dec 2007 11:12:32 +1100

> [INET]: Export non-blocking flags to proto connect call
> 
> Previously we made connect(2) block on IPsec SA resolution.  This is
> good in general but not desirable for non-blocking sockets.
> 
> To fix this properly we'd need to implement the larval IPsec dst stuff
> that we talked about.  For now let's just revert to the old behaviour
> on non-blocking sockets.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

We made an explicit decision not to do things this way.

Non-blocking has a meaning dependant upon the xfrm_larval_drop sysctl
setting, and this is across the board.  If xfrm_larval_drop is zero,
non-blocking semantics do not extend to IPSEC route resolution,
otherwise it does.

If he sets this sysctl to "1" as I detailed in my reply, he'll
get the behavior he wants.
