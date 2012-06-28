From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: tcp: dont cache unconfirmed intput dst
Date: Wed, 27 Jun 2012 17:01:01 -0700 (PDT)
Message-ID: <20120627.170101.99084491660488389.davem@davemloft.net>
References: <1340788455.26242.67.camel@edumazet-glaptop>
	<20120627.153454.30398632011109264.davem@davemloft.net>
	<20120627.164418.1928194990434756968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hans.schillstrom@ericsson.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013Ab2F1ABC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 20:01:02 -0400
In-Reply-To: <20120627.164418.1928194990434756968.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 27 Jun 2012 16:44:18 -0700 (PDT)

> What happens now is that legitimate traffic is harmed too.  If we
> really go to established state, we'll cache the DST_NOCACHE route
> in sk->sk_rx_dst.

This change also means that all routed TCP traffic will use
DST_NOCACHE routes as well.

It's not a requirement to turn off early demux on a router, and I very
much wanted to avoid the knob altogether.  So this side effect is not
acceptable.

There are quite a number of unwanted side effects from this change, so
I think we'll have to revert unless you can fix up all of the relevant
cases quickly.
