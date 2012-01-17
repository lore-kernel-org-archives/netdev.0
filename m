From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net: WARN if skb_checksum_help() is called on
 skb requiring segmentation
Date: Tue, 17 Jan 2012 10:32:39 -0500 (EST)
Message-ID: <20120117.103239.724200729662879608.davem@davemloft.net>
References: <1326753539.3065.31.camel@bwh-desktop>
	<1326753818.3065.35.camel@bwh-desktop>
	<20120117061115.GA14918@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754915Ab2AQPco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 10:32:44 -0500
In-Reply-To: <20120117061115.GA14918@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Tue, 17 Jan 2012 17:11:15 +1100

> On Mon, Jan 16, 2012 at 10:43:38PM +0000, Ben Hutchings wrote:
>> skb_checksum_help() has never done anything useful with skbs that
>> require segmentation.  Setting skb->ip_summed = CHECKSUM_NONE makes
>> them invalid and provokes a later WARNing in skb_gso_segment().
>> 
>> Passing such an skb to skb_checksum_help() indicates a bug, so we
>> should warn about it immediately.  Move the warning from
>> skb_gso_segment() into a shared function, and add the calling function
>> name, gso_type and gso_size to it.
>> 
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>> ---
>> The price for writing the warning format only once is having to pass in
>> the calling function name.  Not sure whether it's a good trade-off.
> 
> Do we really need the name since we should get a back trace?

Agreed.
