From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] netlink: Use random autobind rover
Date: Sun, 17 May 2015 23:44:07 -0400 (EDT)
Message-ID: <20150517.234407.1144377163556453362.davem@davemloft.net>
References: <20150516134007.GA1152@gondor.apana.org.au>
	<20150516.170819.1082459707799000658.davem@davemloft.net>
	<20150517024534.GA5570@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org,
	ying.xue@windriver.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbbERDoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:44:09 -0400
In-Reply-To: <20150517024534.GA5570@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 17 May 2015 10:45:34 +0800

> On Sat, May 16, 2015 at 05:08:19PM -0400, David Miller wrote:
>>
>> As far as I can tell, this ought to be fine as-is.
> 
> OK what about dropping the global rover altogether? Let's just
> start randomly like UDP.
> 
> ---8<---
> Currently we use a global rover to select a port ID that is unique.
> This used to work consistently when it was protected with a global
> lock.  However as we're now lockless, the global rover can exhibit
> pathological behaviour should multiple threads all stomp on it at
> the same time.
> 
> Granted this will eventually resolve itself but the process is
> suboptimal.
> 
> This patch replaces the global rover with a pseudorandom starting
> point to avoid this issue.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Yep, this is fine, applied.

Thanks!
