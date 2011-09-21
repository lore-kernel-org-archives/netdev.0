From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Perform a replay check after return from async
 codepaths
Date: Wed, 21 Sep 2011 15:21:17 -0400 (EDT)
Message-ID: <20110921.152117.752680402461232454.davem@davemloft.net>
References: <20110921112158.GB18648@gondor.apana.org.au>
	<20110921115727.GX1808@secunet.com>
	<20110921122442.GA19162@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567Ab1IUTVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 15:21:41 -0400
In-Reply-To: <20110921122442.GA19162@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Wed, 21 Sep 2011 22:24:42 +1000

> On Wed, Sep 21, 2011 at 01:57:27PM +0200, Steffen Klassert wrote:
>>
>> Well, I've got pretty reproduceable crashes when the sender of
>> the IPsec packets introduces reorder, that's why I noticed this.
>> 
>> The problem is, that the replay check function is called before
>> the asynchronous crypto processing and the replay advance function
>> is called after resume from the asynchronous processing. So
>> we can submit multiple packets to the crypto layer without
>> updating the replay window. This means that the replay check
>> function accepts packets that should have been dropped, because
>> they are reordered and more than 'replay window size' packets
>> to late. This leads to a crash as we try to update the replay
>> window beyond the allocated bounds.
> 
> OK I see what you mean now.
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone.
