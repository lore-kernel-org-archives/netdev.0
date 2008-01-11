From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rp_filter and ip rule break ipsec policy
Date: Sat, 12 Jan 2008 09:34:36 +1100
Message-ID: <E1JDSSS-0008Ph-00@gondolin.me.apana.org.au>
References: <BAY103-DAV74C2164B1205BADF62C17B24B0@phx.gbl>
Cc: netdev@vger.kernel.org
To: pupilla@hotmail.com (Marco Berizzi)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1055 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762872AbYAKWxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 17:53:08 -0500
In-Reply-To: <BAY103-DAV74C2164B1205BADF62C17B24B0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi <pupilla@hotmail.com> wrote:
>
> When I insert the rule number #601 packets to
> x.y.z.214 aren't ate by xfrm anymore. This
> happens when rp_filter is set to 1 on eth0.
> Disabling rp_filter on eth0 resolve the problem:
> xfrm eat the packets.
> Is this the expected behaviour? Why should

Absolutely.  While on local output, IPsec lookup does override
routing lookup (however there we do the route lookup first and
use that as the key for the IPsec lookup).  On forwarding this
is not the case.  We decapsulate and check policy first (if
encrypted), and then do a route lookup, at which point rp_filter
can eat your packet, and only after that do we perform the output
IPsec lookup.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
