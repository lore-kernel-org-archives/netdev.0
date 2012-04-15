From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/3] bridge: Do not send multicast queries by default
Date: Sun, 15 Apr 2012 19:13:00 +0800
Message-ID: <20120415111300.GA14147@gondor.apana.org.au>
References: <20120413123641.GA758@gondor.apana.org.au>
 <20120413.105345.319552552748408545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:38566 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751534Ab2DOLNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 07:13:08 -0400
Content-Disposition: inline
In-Reply-To: <20120413.105345.319552552748408545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 13, 2012 at 10:53:45AM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.hengli.com.au>
> Date: Fri, 13 Apr 2012 20:36:41 +0800
> 
> > (incidentally, I noticed that our IPv6 code has been "fixed" to not
> > use zero source addresses, which is wrong as we may end up being THE
> > MLD querier in a network).
> 
> I seem to recall it was explicitly changed to be this way and that
> there was a good reason for this, see the history.

Right, the reason given is that RFC2710 (for MLD) requires the
source address to be a link-local address.

However, we're not implementing an RFC2710 node here.  What we're
doing is better described by RFC4541 (IGMP/MLD snooping), which calls
for the use of a zero source address for both IPv4 and IPv6.

The reason is precisely because it's invalid for normal querier
nodes and as such they would ignore us (rather than elect us
and potentially disrupt things).

Now granted we may also end up having other nodes ignoring our
queries where we'd rather that they answered us with reports.
However, this isn't as bad because the whole querying mechanism
in the snooping code is merely an optimisation to speed up
convergence primarily during start-up.  So if we don't see the
reports straight away it's not a deal-breaker.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
