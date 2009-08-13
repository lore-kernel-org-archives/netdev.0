From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix xfrm hash collisions by changing
 __xfrm4_daddr_saddr_hash to hash addresses with addition
Date: Wed, 12 Aug 2009 20:42:47 -0700 (PDT)
Message-ID: <20090812.204247.183387787.davem@davemloft.net>
References: <alpine.DEB.1.10.0908071032171.3426@sisapiiri.net.net>
	<20090813020606.GA18205@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joamaki@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41817
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751252AbZHMDmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 23:42:37 -0400
In-Reply-To: <20090813020606.GA18205@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Aug 2009 12:06:06 +1000

> Jussi Maki <joamaki@gmail.com> wrote:
>>
>> diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
>> index d401dc8..e5195c9 100644
>> --- a/net/xfrm/xfrm_hash.h
>> +++ b/net/xfrm/xfrm_hash.h
>> @@ -16,7 +16,7 @@ static inline unsigned int __xfrm6_addr_hash(xfrm_address_t *addr)
>> 
>> static inline unsigned int __xfrm4_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
>> {
>> -       return ntohl(daddr->a4 ^ saddr->a4);
>> +       return ntohl(daddr->a4 + saddr->a4);
>> }
> 
> What if the other side intentionally picks a destination addresses
> to create collisions? Actually it's even easier than that.  We
> don't include the SPI in the hash so regardless of how we hash
> it, our peer can simply continue to create SAs with the same
> descriptors and they'll all hash to the same bucket.

Isn't it fruitless to talk about exploiting SA IDs when such things
are setup using an encrypted negotiation sequence and some level of
trust?

Just wondering :-)
