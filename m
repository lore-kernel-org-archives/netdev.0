From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Tue, 17 Jul 2012 06:46:33 -0700 (PDT)
Message-ID: <20120717.064633.1533728304261811367.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F8B@saturn3.aculab.com>
	<20120717.055005.1912765690890797652.davem@davemloft.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6F8D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, cascardo@linux.vnet.ibm.com,
	netdev@vger.kernel.org, yevgenyp@mellanox.co.il,
	ogerlitz@mellanox.com, amirv@mellanox.com,
	brking@linux.vnet.ibm.com, leitao@linux.vnet.ibm.com,
	klebers@linux.vnet.ibm.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532Ab2GQNqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 09:46:36 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F8D@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Tue, 17 Jul 2012 14:36:11 +0100

> The driver will already have to cope with 'too many segments'
> (I remember being passed a full sized frame made of a list
> of 1-byte message blocks...)

Baring driver hardware bug workarounds, no it does not have to cope
with that.  The code is extremely simple now.

All the driver has to do is assume that a new TX packet can never
consume more than MAX_SKB_FRAGS.

Therefore it simply stops the queue if less than MAX_SKB_FRAGS
segments remain after queueing a transmit.

Your suggestion will significantly complicate driver TX paths.

If you're going to suggest a solution, it has to be completely
general enough to work in the current state of affairs, and
your idea absolutely does not.
