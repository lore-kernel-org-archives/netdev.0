From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/3] bridge: Do not send multicast queries by default
Date: Fri, 13 Apr 2012 20:36:41 +0800
Message-ID: <20120413123641.GA758@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:33590 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754102Ab2DMMgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 08:36:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This series of patches is aimed to change the default multicast
snooping behaviour to one that is safer to deploy in the wild.

There have been numerous reports of switches misbehaving with
our current behaviour of sending general queries, presumably
because we're using a zero source IP address which is unavoidable
as using anything else would interfere with multicast querier
elections (incidentally, I noticed that our IPv6 code has been
"fixed" to not use zero source addresses, which is wrong as we
may end up being THE MLD querier in a network).

Since our queries aren't actually required for multicast snooping
to function, but is merely an optimisation mostly for faster
start-up convergence, I think we should disable this by default.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
