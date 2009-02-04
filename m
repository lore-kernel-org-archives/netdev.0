From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/3] tun: Add packet accounting
Date: Wed, 4 Feb 2009 21:48:25 +1100
Message-ID: <20090204104825.GA21257@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59757 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751239AbZBDKs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 05:48:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

Remember that UDP packet loss issue with virtulisation that one of
the Japanese guys menteioned at Plumbers'? Well it's back.

My initial reaction was obviously to suggest a different protocol,
however, that didn't get very far because we do such a great job
at handling it on baremetal.  That has created an unhealthy
dependency on the part of the users :)

Since no one has been brave enough to suggest removing the truesize
accounting for UDP, I've bitten the bullet and implemented the
same thing for the tuntap device.  This essentially brings UDP
in virtualisation to a par with UDP on baremetal as far as pushback
by the physical NIC is concerned.

On the plus side, we can spin this as a security feature :) It
stops the tun users from potentially pinning down unlimited amounts
of kernel memory (the entity creating the tun device is not
necessarily the one pushing traffic through it).

And I've got to say that it's not as ugly as I feared initially,
with just two lines changed in the core code.  The performance
impact should also be small, as only one conditional is added
on the fast path.

Of course the solution is not perfect in that it only handles
bridging right now.  But as bridging represents 99% of our current
virtualisation user base, it should be good enough.  Making this
work for routing isn't all that hard but requires more surgery
in the protocol (IP) stacks.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
