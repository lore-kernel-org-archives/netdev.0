From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Enforce minimum size on initial hash table
Date: Wed, 16 Dec 2015 10:45:08 -0500 (EST)
Message-ID: <20151216.104508.256133184136757332.davem@davemloft.net>
References: <567113CA.8030108@canonical.com>
	<20151216101314.GA24928@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: william.hua@canonical.com, netdev@vger.kernel.org, tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933962AbbLPPpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 10:45:12 -0500
In-Reply-To: <20151216101314.GA24928@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 16 Dec 2015 18:13:14 +0800

> William Hua <william.hua@canonical.com> wrote:
>>
>> I wasn't aware there was an enforced minimum size. I simply set the 
>> nelem_hint in the rhastable_params struct to 1, expecting it to grow as
>> needed. This caused a segfault afterwards when trying to insert an
>> element.
> 
> OK we're doing the size computation before we enforce the limit
> on min_size.
> 
> ---8<---
> We need to do the initial hash table size computation after we
> have obtained the correct min_size/max_size parameters.  Otherwise
> we may end up with a hash table whose size is outside the allowed
> envelope.
> 
> Fixes: a998f712f77e ("rhashtable: Round up/down min/max_size to...")
> Reported-by: William Hua <william.hua@canonical.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks!
