From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 14:26:52 -0700 (PDT)
Message-ID: <20120620.142652.1381681483918504053.davem@davemloft.net>
References: <20120620.140121.1603737472432326278.davem@davemloft.net>
	<20120620140454.36847c65@s6510.linuxnetplumber.net>
	<1340227076.4604.1905.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754629Ab2FTV0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 17:26:52 -0400
In-Reply-To: <1340227076.4604.1905.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jun 2012 23:17:56 +0200

> In most routers setups I used, I had to disable GRO, because 64Kbytes
> packets on output path broke the tc setups (SFQ)

Then you speak of bugs and mis-features, rather than real fundamental
disadvantages of using GRO on a router :-)

> netfilter cost was hardly a problem, once correctly done.

But cost is not zero, and if you can divide it by N then you do it.
And GRO is what allows this.

Every demux, lookup, etc. is transaction cost.

Even routing cache lookup with no dst reference, which is _very_
cheap, takes up a serious amount of cpu cycles.  Enough that we think
early demux is worth it, right?

And such a routing cache lookup is significantly cheaper than a trip
down into netfilter.
