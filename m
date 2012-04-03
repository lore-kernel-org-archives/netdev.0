From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Mon, 02 Apr 2012 21:59:11 -0400 (EDT)
Message-ID: <20120402.215911.1929019308299701014.davem@davemloft.net>
References: <201204022201.41808.remi@remlab.net>
	<20120402.174006.70116829696492189.davem@davemloft.net>
	<1333417997.18626.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: remi@remlab.net, levinsasha928@gmail.com,
	remi.denis-courmont@nokia.com, davej@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57149 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374Ab2DCCAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 22:00:22 -0400
In-Reply-To: <1333417997.18626.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Apr 2012 03:53:17 +0200

> Not that AF_UNIX does nothing in this respect, it can use order-XX pages
> for large datagrams.
> 
> (I beleve I sent a patch some time ago to address this point)

Yes, on the datagram side it's a problem.

For stream AF_UNIX sockets the allocation is capped at SKB_MAX_ALLOC
which evaluates to an order 2 page.

Overall, AF_UNIX ought to be easy to deal with since all of the
routines that copy data between userspace and SKBs can handle
segmented SKBs and thus most of the work is converting over to
sock_alloc_send_pskb() and setting data_len how we set the normal
length of sock_alloc_skb_skb() currently.

Anyways, feel free to resubmit your patch.
