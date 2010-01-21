From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Thu, 21 Jan 2010 22:41:57 +1300
Message-ID: <20100121094157.GA15262@gondor.apana.org.au>
References: <20100121.012520.254679483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: krkumar2@in.ibm.com, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58504 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752175Ab0AUJmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 04:42:10 -0500
Content-Disposition: inline
In-Reply-To: <20100121.012520.254679483.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Krishna Kumar2 <krkumar2@in.ibm.com>
> Date: Wed, 20 Jan 2010 17:49:18 +0530
> 
>> I had to remove the F_SG flag from cxgb3 driver (using ethtool
>> didn't show any difference in performance since GSO was enabled
>> on the device due to register_netdev setting it). Testing show a
>> drop of 25% in performance with this patch for non-SG device,
>> the extra alloc/memcpy is showing up.
>> 
>> For the SG driver, I get a good performace gain (not anywhere
>> close to 25% though). What do you suggest?
> 
> I don't think we can add your change if it hurts non-SG
> devices that much.

Wait, we need to be careful when testing this.  Non-SG devices
do actually benefit from TSO which they otherwise cannot access.

If you unset the F_SG bit, then that would disable TSO too.  So
you need to enable GSO to compensate.  So Krishna, did you check
with tcpdump to see if GSO was really enabled with SG off?

IIRC when I did a similar test with e1000 back when I wrote this
the performance of GSO with SG off was pretty much the same as
no GSO with SG off.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
