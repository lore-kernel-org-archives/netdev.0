From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/16] tcp: Maintain dynamic metrics in local cache.
Date: Tue, 10 Jul 2012 18:01:37 -0700 (PDT)
Message-ID: <20120710.180137.2161994914932724530.davem@davemloft.net>
References: <1341939724.6118.145.camel@joe2Laptop>
	<20120710.172908.745359979722998717.davem@davemloft.net>
	<1341967486.13724.9.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079Ab2GKBBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 21:01:38 -0400
In-Reply-To: <1341967486.13724.9.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 10 Jul 2012 17:44:46 -0700

> I'd guess the one above is faster to execute.

It is.

> If it's not, the code in ipv6_addr_equal
> should be reverted. commit fed85383ac34d82
> ("[IPV6]: Use XOR and OR rather than mutiple ands for ipv6 address comparisons")

Not necessarily.

My version here is faster because we unconditionally test
the first word, which we need to do for both the ipv4 and
ipv6 cases.

The ipv6 routine optimization you mention exists in a
world where we know we have an ipv6 address always, which
is not the case here.

If anything, we should do XOR's on the final three words,
but we should not remove the first word optimization for
ipv4 which is the common case.
