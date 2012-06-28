From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: tcp: dont cache unconfirmed intput dst
Date: Wed, 27 Jun 2012 17:08:30 -0700 (PDT)
Message-ID: <20120627.170830.811332455348620174.davem@davemloft.net>
References: <20120627.153454.30398632011109264.davem@davemloft.net>
	<20120627.164418.1928194990434756968.davem@davemloft.net>
	<20120627.170101.99084491660488389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hans.schillstrom@ericsson.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427Ab2F1AIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 20:08:31 -0400
In-Reply-To: <20120627.170101.99084491660488389.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 27 Jun 2012 17:01:01 -0700 (PDT)

> There are quite a number of unwanted side effects from this change, so
> I think we'll have to revert unless you can fix up all of the relevant
> cases quickly.

Actually I've decided to revert it now.

Whilst this was a swell idea, there is no way for you to know if
we should really create a cached route or not.

Even if you could, there is a lot of logic you'll need to code up
so that, f.e., once we determine that we've got a DST_NOCACHE route
when we move to established state, we can insert it into the routing
cache and not mark it DST_NOCACHE any longer.

But even if we did that, we're going to eat 2 uncached route lookups
for every new incoming legitimate connection.
