From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 13 Jan 2009 16:16:25 -0800 (PST)
Message-ID: <20090113.161625.111759506.davem@davemloft.net>
References: <20090111160548.GA362@ioremap.net>
	<20090113.160721.68474279.davem@davemloft.net>
	<20090114001345.GB512@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, w@1wt.eu, ben@zeus.com, jarkao2@gmail.com,
	mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756895AbZANAQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 19:16:24 -0500
In-Reply-To: <20090114001345.GB512@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Wed, 14 Jan 2009 03:13:45 +0300

> What is the best solution for the data corruption bug? To copy the data
> all the time or implement own allocator to be used in alloc_skb and
> friends to allocate the head? I think it can be done transparently for
> the drivers. I can volunteer for this :)
> The first one is more appropriate for the current bugfix-only stage,
> but this will result in the whole release being too slow.

I am looking into this right now.

I wish there were some way we could make this code grab and release a
reference to the SKB data area (I mean skb_shinfo(skb)->dataref) to
accomplish it's goals.
