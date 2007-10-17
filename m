From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/11] Various xfrm fixes and clean-ups
Date: Wed, 17 Oct 2007 22:29:40 +0800
Message-ID: <20071017142940.GA23879@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4945 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762077AbXJQO37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 10:29:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

This series of patches completely replaces the ones I posted
yesterday so you can delete the previous batch.

I'm still in the process of fixing up inter-family transforms
so this is mostly the patches I posted yesterday with the
offensive bits removed :)

I hadn't realised how broken inter-family transforms are on
output until I started trying to fix them.  As it is, it'll
happily send IPv4 packets into the IPv6 ICMP stack or worse,
IPv6 netfilter and vice versa.

The last patch in the series lays the foundation of my fix
to this.  My plan is to divide the work that's currently done
by x->mode->output into two parts so that the first part can
be done by the inner address family, i.e., x->inner_mode while
the rest of it will be done by x->outer_mode->output.  A similar
scheme would operate on the inbound direction.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
