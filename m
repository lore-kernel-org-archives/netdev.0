From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] ipv6_fib limit spinlock hold times for
 /proc/net/ipv6_route
Date: Sat, 26 Apr 2014 00:06:55 -0400 (EDT)
Message-ID: <20140426.000655.2286393147313574001.davem@davemloft.net>
References: <20140424142030.GD1960@order.stressinduktion.org>
	<53592287.2050902@fb.com>
	<20140425213140.GE7050@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clm@fb.com, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbaDZEG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 00:06:56 -0400
In-Reply-To: <20140425213140.GE7050@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 25 Apr 2014 23:31:40 +0200

> On Thu, Apr 24, 2014 at 10:41:11AM -0400, Chris Mason wrote:
>> I was going to discuss the cache exclusion on a separate thread, but the 
>> short version is that I don't have any clue of how many people we'd 
>> upset by unconditionally leaving out the cached entries.
> 
> In my opinion this would be ok.
> 
> We definitely must reduce number of entries in the fib and I don't think it is
> wise to synthesize them thereafter, especially if we don't need to track state
> at all, e.g. forwarding.

I think this is a dangerous idea, to limit what is shown in the dumps.

We must always output the entry that would actually be used by a
lookup otherwise you are asking for impossible to debug scenerios.

On the other side, once we change ipv6 to work like ipv4, those cached
entries simply won't be there at all and then automatically this huge
dump issue just goes away.
