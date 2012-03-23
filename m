From: David Miller <davem@davemloft.net>
Subject: Re: [STRAW MAN PATCH] sch_teql doesn't load-balance ppp(oatm)
 slaves
Date: Thu, 22 Mar 2012 23:03:31 -0400 (EDT)
Message-ID: <20120322.230331.1623101647193498167.davem@davemloft.net>
References: <1332450218.32446.79.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753725Ab2CWDEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 23:04:43 -0400
In-Reply-To: <1332450218.32446.79.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 22 Mar 2012 21:03:38 +0000

> teql_dequeue() will *always* give up a skb when it's called, if there is
> one. If there's *not*, and the tx queue becomes empty, then the device
> for which teql_dequeue() was called is 'promoted' to the front of the
> line (master->slaves). That device will receive the next packet that
> comes in, even if there are other devices which are *also* idle and
> waiting for packets. Whenever a new packet comes in, the *last* device
> to call teql_dequeue() gets it.

The teql master ->ndo_start_xmit() method is where the slave iteration
occurs, and it occurs on every successful transmit of a single packet.

But this cannot, and is documented not to, work when device stacking
is involved.

If you're dealing with (what amounts to) virtual devices, you cannot
use TEQL and must use something like drivers/net/eql.c
