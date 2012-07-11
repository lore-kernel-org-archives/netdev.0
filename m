From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/16] tcp: Maintain dynamic metrics in local cache.
Date: Tue, 10 Jul 2012 20:59:14 -0700 (PDT)
Message-ID: <20120710.205914.1537069998261422164.davem@davemloft.net>
References: <20120710.080714.2272376193166978850.davem@davemloft.net>
	<1341939724.6118.145.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43641 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754202Ab2GKD7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 23:59:15 -0400
In-Reply-To: <1341939724.6118.145.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 10 Jul 2012 10:02:04 -0700

> On Tue, 2012-07-10 at 08:07 -0700, David Miller wrote:
>> +	return (tm ? tm : (depth > TCP_METRICS_RECLAIM_DEPTH ?
>> +			   TCP_METRICS_RECLAIM_PTR :
>> +			   NULL));
> 
> Using multiple ?: in a single return can be a bit hard to read.

Ok I made a special function to implement this encoding.

>> +	case AF_INET:
>> +		hash = addr.addr.a4 = inet_rsk(req)->rmt_addr;
> 
> Is this a sparse error?  __be32 to unsigned int?
> Maybe it needs a __force?

Yep, the ipv6 hash calculation needs the same __force'ing.
