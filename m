From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 -next 1/2] tcp: syncookies: reduce cookie lifetime
 to 128 seconds
Date: Tue, 24 Sep 2013 10:40:12 -0400 (EDT)
Message-ID: <20130924.104012.113351985998037405.davem@davemloft.net>
References: <1379709176-1625-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467Ab3IXOkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 10:40:15 -0400
In-Reply-To: <1379709176-1625-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 20 Sep 2013 22:32:55 +0200

> We currently accept cookies that were created less than 4 minutes ago
> (ie, cookies with counter delta 0-3).  Combined with the 8 mss table
> values, this yields 32 possible values (out of 2**32) that will be valid.
> 
> Reducing the lifetime to < 2 minutes halves the guessing chance while
> still providing a large enough period.
> 
> While at it, get rid of jiffies value -- they overflow too quickly on
> 32 bit platforms.
> 
> getnstimeofday is used to create a counter that increments every 64s.
> perf shows getnstimeofday cost is negible compared to sha_transform;
> normal tcp initial sequence number generation uses getnstimeofday, too.
> 
> Reported-by: Jakob Lell <jakob@jakoblell.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
