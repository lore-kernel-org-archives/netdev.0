From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 1/3] net: ipv6: Unduplicate
 {raw,udp}v6_sendmsg code
Date: Sat, 26 Apr 2014 00:04:51 -0400 (EDT)
Message-ID: <20140426.000451.2200416383822191927.davem@davemloft.net>
References: <20140425171909.GB7050@order.stressinduktion.org>
	<20140425.133303.375967970436600096.davem@davemloft.net>
	<20140425212642.GD7050@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, lorenzo@google.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbaDZEEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 00:04:55 -0400
In-Reply-To: <20140425212642.GD7050@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 25 Apr 2014 23:26:42 +0200

> On Fri, Apr 25, 2014 at 01:33:03PM -0400, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Fri, 25 Apr 2014 19:19:09 +0200
>> 
>> > Maybe we can put all those hlimit, tclass, dontfrag vars into a struct
>> > and just pass one pointer.
>> 
>> It's still an unnecessary memory dereference.
> 
> True, true.
> 
>> The compiler can potentially optimize the accesses to those variables
>> into a local register with the existing code, with this consolidation
>> it no longer can.
> 
> We could hack up the function in a local header file in net/ipv6 and
> __always_inline it. If the resulting assembly looks good would this
> be acceptable for you? Maybe we could switch to something like struct
> ipv6_output_opts where we gather all those state variables common to
> the code paths.

I think the consolidation attempts seen so far generally look like
crap because we haven't found the right abstraction yet.

Once a good fit is found I don't think there will be any reason for
me to consider the result ugly.
