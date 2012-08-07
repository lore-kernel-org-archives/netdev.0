From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib: use __fls() on non null argument
Date: Tue, 07 Aug 2012 16:27:50 -0700 (PDT)
Message-ID: <20120807.162750.17030231759163542.davem@davemloft.net>
References: <1344346253.28967.93.camel@edumazet-glaptop>
	<1344369904.2688.53.camel@bwh-desktop.uk.solarflarecom.com>
	<1344372347.28967.154.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030214Ab2HGX1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 19:27:50 -0400
In-Reply-To: <1344372347.28967.154.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Aug 2012 22:45:47 +0200

> [PATCH v2 net-next] fib: use __fls() on non null argument
> 
> __fls(x) is a bit faster than fls(x), granted we know x is non null.
> 
> As Ben Hutchings pointed out, fls(x) = __fls(x) + 1
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>

Applied.

This is, btw, the most expensive part of fib_trie on sparc64 since we
really don't have a universal way to do this in a hardware instruction
and therefore we end up with the branch-heavy software implementation :-/

So if anyone can come up with a way to eliminate this fls() entirely,
you will be my hero.
