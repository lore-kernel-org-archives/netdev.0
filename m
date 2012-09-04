From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Workaround incompatibility of ESN and async
 crypto
Date: Tue, 04 Sep 2012 14:10:28 -0400 (EDT)
Message-ID: <20120904.141028.756171698435424565.davem@davemloft.net>
References: <20120904100329.GA13023@secunet.com>
	<20120904123155.GA3152@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757425Ab2IDSKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 14:10:35 -0400
In-Reply-To: <20120904123155.GA3152@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 4 Sep 2012 05:31:55 -0700

> On Tue, Sep 04, 2012 at 12:03:29PM +0200, Steffen Klassert wrote:
>> ESN for esp is defined in RFC 4303. This RFC assumes that the
>> sequence number counters are always up to date. However,
>> this is not true if an async crypto algorithm is employed.
>> 
>> If the sequence number counters are not up to date on sequence
>> number check, we may incorrectly update the upper 32 bit of
>> the sequence number. This leads to a DOS.
>> 
>> We workaround this by comparing the upper sequence number,
>> (used for authentication) with the upper sequence number
>> computed after the async processing. We drop the packet
>> if these numbers are different.
>> 
>> To do this, we introduce a recheck function that does this
>> check in the ESN case.
>> 
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> It took me a while to understand the problem but Steffen was
> correct again as usual.

Applied, thanks everyone.
