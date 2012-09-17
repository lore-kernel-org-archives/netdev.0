From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Mon, 17 Sep 2012 13:07:32 -0400 (EDT)
Message-ID: <20120917.130732.1894375657044880827.davem@davemloft.net>
References: <20120917.121243.1665284878800146060.davem@davemloft.net>
	<1347901326.26523.149.camel@edumazet-glaptop>
	<1347901493.26523.151.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754761Ab2IQRHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 13:07:35 -0400
In-Reply-To: <1347901493.26523.151.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 17 Sep 2012 19:04:53 +0200

> On Mon, 2012-09-17 at 19:02 +0200, Eric Dumazet wrote:
> 
>> A driver already exports a dev->gso_max_size, dev->gso_max_segs, I guess
>> it could export a dev->max_seg_order (default to 0)
> 
> Oh well, if we use a per thread order-3 page, a driver wont define an
> order, but the max size of a segment (dev->max_seg_size).

Since you said that your audit showed that most can handle arbitrary
segment sizes, it's better to default to infinity or similar.

Otherwise we'll have to annotate almost every single driver with a
non-zero value, that's not an efficient way to handle this and
deploy the higher performance quickly.
