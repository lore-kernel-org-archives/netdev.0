From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: IPv6 xfrm GSO fragmentation bug
Date: Sun, 30 Aug 2015 16:24:32 +0800
Message-ID: <20150830082432.GA25588@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:35876 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbbH3IYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 04:24:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen:

I received a bug report regarding poor IPComp performance over
IPv6:

	https://bugzilla.redhat.com/show_bug.cgi?id=1257952

It appears to have been caused by

commit dd767856a36e00b631d65ebc4bb81b19915532d6
Author: Steffen Klassert <steffen.klassert@secunet.com>
Date:   Tue Oct 11 01:44:30 2011 +0000

    xfrm6: Don't call icmpv6_send on local error

which addded an MTU check without a GSO override.

Fixing it obviously isn't difficult, but I am wondering why I
can't find a corresponding patch for IPv4.  Do we need that check
to be present in xfrm6_output at all? If we do why isn't it needed
for IPv4 as well?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
