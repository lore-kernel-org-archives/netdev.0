From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Tue, 28 Sep 2010 21:41:32 -0700 (PDT)
Message-ID: <20100928.214132.226782961.davem@davemloft.net>
References: <1285733911.22570.20.camel@edumazet-laptop>
	<1285734295.22570.25.camel@edumazet-laptop>
	<20100929043642.GA3660@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46248
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750769Ab0I2ElM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 00:41:12 -0400
In-Reply-To: <20100929043642.GA3660@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 29 Sep 2010 13:36:42 +0900

> On Wed, Sep 29, 2010 at 06:24:55AM +0200, Eric Dumazet wrote:
>>
>> Well, we all know icmpv6_cleanup() is not really called (or can we
>> really unload ipv6 ?).
>> 
>> But unregister_icmpv6_send() should be the first call in it.
> 
> Do we really need to support IPV6=m and GRE=y? It might be simpler
> to just behave as if IPv6 is off when this combination is given.

I think we should make it so that the Kconfig rule only allows
"m" or "n" for IP_GRE when IPV6=m

That's how we handle this kind of situation elsewhere, f.e. see
bonding.

Eric, please cook up a patch which does this, I think the
magic Kconfig dependency formula for this is:

	depends on IPV6 || IPV6=n

Thanks!
