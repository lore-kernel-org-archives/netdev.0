From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tcp: syncookies: reduce cookie lifetime to 128
 seconds
Date: Wed, 28 Aug 2013 18:20:48 -0400 (EDT)
Message-ID: <20130828.182048.371311612380335945.davem@davemloft.net>
References: <1377453242-4773-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbohac@suse.cz
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069Ab3H1WUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 18:20:52 -0400
In-Reply-To: <1377453242-4773-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 25 Aug 2013 19:54:01 +0200

> We currently accept cookies that were created less than 4 minutes ago
> (ie, cookies with counter delta 0-3).  Combined with the 8 mss table
> values, this yields 32 possible values (out of 2**32) that will be valid.
> 
> Reducing the lifetime to < 2 minutes halves the guessing chance while
> still providing a large enough period (possible cookies are
> only validated if last synqueue overflow was less than 3 seconds ago).
> 
> While at it, get rid of jiffies value -- they overflow too quickly on
> 32 bit platforms.
> 
> getnstimeofday is used to create a counter that increments every 64s.
> 
> Reported-by: Jakob Lell <jakob@jakoblell.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Moving from jiffies as a time seed to getnstimeofday() obviously will
have some performance impact, can you talk a little bit about that?


> +#define MAX_SYNCOOKIE_AGE 2 /* 128 seconds */

I'm sure you understand how 2 translates into 128 seconds in this syncookie
code, but I sure don't and the next person who reads this patch or this
code after I apply it may not either.

Could you in some way expose the calculation?  Thanks.
