From: David Miller <davem@davemloft.net>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Tue, 04 Dec 2007 23:12:00 -0800 (PST)
Message-ID: <20071204.231200.117152338.davem@davemloft.net>
References: <20071205001230.GA11391@gondor.apana.org.au>
	<20071204.223023.262159049.davem@davemloft.net>
	<20071205065132.GA11476@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon@fire.lp0.eu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44771
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751745AbXLEHMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 02:12:01 -0500
In-Reply-To: <20071205065132.GA11476@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 5 Dec 2007 17:51:32 +1100

> Does anybody actually need the 0 setting? What would we break if
> the default became 1?

I bet there are UDP apps out there that would break if we
didn't do this.

Actually, consider even a case like DNS.  Let's say the timeout
is set to 2 seconds or something and you have 3 DNS servers
listed, on different IPSEC destinations, in your resolv.conf

Each IPSEC route that isn't currently resolved will cause packet loss
of the DNS lookup request with xfrm_larval_drop set to '1'.

If all 3 need to be resolved, the DNS lookup will fully fail
which defeats the purpose of listing 3 servers for redundancy
don't you think? :-)

As much as I even personally prefer the xfrm_larval_drop=1
behavior, it cases like above that keep me from jumping at
making it the default.

Arguably, potentially blocking forever (which is what can easily
happen with xfrm_larval_drop=0 if your IPSEC daemon cannot resolve the
IPSEC path for whatever reason) is worse than the above, but the
other cases are still something to consider as well.
