From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Sat, 3 Jan 2015 09:01:07 +1100
Message-ID: <20150102220107.GA28599@gondor.apana.org.au>
References: <20141231133923.GA30248@gondor.apana.org.au>
 <20141231134217.GB30248@gondor.apana.org.au>
 <1420223040.32621.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150102.153655.1853692198479011402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, thomas.jarosch@intra2net.com,
	netdev@vger.kernel.org, edumazet@google.com,
	steffen.klassert@secunet.com, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:48485 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425AbbABWBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 17:01:38 -0500
Content-Disposition: inline
In-Reply-To: <20150102.153655.1853692198479011402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 02, 2015 at 03:36:55PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 02 Jan 2015 10:24:00 -0800
>
> > Non TSO/GSO path is known to be better for devices unable to perform TX
> > checksumming, as we compute the checksum at the time we copy data from
> > user to kernel (csum_and_copy_from_user() from tcp_sendmsg())).
> 
> Non-SG capable devices suffer in this scenerio as well.

Yes I was referring to using GSO on non-SG/non-checksumming devices.
Anything that supports checksum/SG should obviously be using GSO.

IIRC when I first tested this GSO is basically on par for the non-SG
case as the overhead of the extra copying was offset by the benefit
of a larger MTU through the stack.

So has anyone actually observed worse performance with GSO on these
devices (you could even test on a GSO-capable device simply by
disabling checksumming)?

Also the fact that this bug took two years to surface means that
very few people are actually using non-GSO in the real world as
this bug is easily triggered by a PMTU event.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
