From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 27 Jan 2009 10:42:10 -0800 (PST)
Message-ID: <20090127.104210.136585415.davem@davemloft.net>
References: <20090126082036.GB4183@ff.dom.local>
	<20090126212130.GA4338@ioremap.net>
	<20090126.221056.174077798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, herbert@gondor.apana.org.au, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54832
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755920AbZA0SmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 13:42:12 -0500
In-Reply-To: <20090126.221056.174077798.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 26 Jan 2009 22:10:56 -0800 (PST)

> Even for drivers like NIU and myri10ge that do this, they only
> use heuristics or some fixed minimum to decide how much to
> move to the linear area.
> 
> Result?  Some data payload bits end up there because it overshoots.
 ...
> I did test this with the NIU driver at one point, and it did not
> change TCP latency nor throughput at all even at 10g speeds.

As a followup, it turns out that NIU right now does this properly.

It only pulls a maximum of ETH_HLEN into the linear area before giving
the SKB to netif_receive_skb().
