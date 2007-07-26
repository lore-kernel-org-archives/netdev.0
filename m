From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/6] Allow registration/change name notifications to fail
Date: Thu, 26 Jul 2007 17:07:25 +0800
Message-ID: <20070726090725.GA510@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1293 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755982AbXGZJHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 05:07:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

This series of patches adds support to let netdev registration
and change name events to fail.  Failures of the former kind
prevents the device from registered while the latter attempts
to roll back the change (which unfortunately can also fail).

If the failure occurs while a netdev is being registered,
then the registration as a whole will fail.  If it occurs
when a protocol is being registered, then that protocol
will fail to register instead.

Having this allows us to flag allocations failures in a 
meaningful way rather than letting the next action that
requires what is allocated to flag the failure.

In particular, this allows the reporting of failures to
allocate the IPv4/IPv6 device objects.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
