From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Thu, 1 Jan 2015 00:42:17 +1100
Message-ID: <20141231134217.GB30248@gondor.apana.org.au>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
 <20141201102522.GA16579@gondor.apana.org.au>
 <20141231133923.GA30248@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:52365 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbaLaNmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 08:42:20 -0500
Content-Disposition: inline
In-Reply-To: <20141231133923.GA30248@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 01, 2015 at 12:39:23AM +1100, Herbert Xu wrote:
>
> Thomas Jarosch reported IPsec TCP stalls when a PMTU event occurs.
> 
> In fact the problem was completely unrelated to IPsec.  The bug is
> also reproducible if you just disable TSO/GSO.

This raises two interesting questions.

Firstly not many people test non-TSO code paths anymore so bugs
are likely to persist for a long time there.  Perhaps it's time
to remove the non-TSO code path altogether? The GSO code path
should provide enough speed-up in terms of boosting the effective
MTU to offset the cost of copying.

Secondly why are we dealing with hardware TSO segment limits
by limiting the size of the TSO packet in the TCP stack? Surely
in this case GSO is free since there won't be any copying?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
