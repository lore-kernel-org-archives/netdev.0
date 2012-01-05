From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6 v2] skb paged fragment destructors
Date: Thu, 05 Jan 2012 12:34:48 -0500 (EST)
Message-ID: <20120105.123448.22028378936304397.davem@davemloft.net>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	<AE90C24D6B3A694183C094C60CF0A2F6D8AF35@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian.Campbell@citrix.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754816Ab2AERe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 12:34:56 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF35@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Thu, 5 Jan 2012 17:27:31 -0000

> If you are doing that, then the network drivers must ensure they
> free such skb as soon as the transmit completes - rather than
> deferring the 'end of tx' processing until some later time.
> 
> Without that the sending code can't reuse the 'page' for another
> request - which is one of the things I presume this allows.

TCP breaks already if a driver defers indefinitely.  All drivers
absolutely must perform TX reclaim in a small, finite, amount of
time.

> (We had issues with this on SVR4 with STREAMS buffers allocated
> with esballoc()...)

This isn't the Mentat stack... so it's extremely unwise to try and
match up concerns you've had in that stack over here when evaluating
changes to Linux.
