From: David Miller <davem@davemloft.net>
Subject: Re: rx_dropped count for USB ethernet interfaces
Date: Wed, 25 Sep 2013 14:46:40 -0400 (EDT)
Message-ID: <20130925.144640.1661224048195310923.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B735B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34235 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309Ab3IYSqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 14:46:42 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B735B@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Wed, 25 Sep 2013 17:22:38 +0100

> However it looks as though Linux is also counting rx_dropped if the packet
> can't be delivered to a protocol (at the end of __netif_receive_skb).

This is expected and correct behavior.

> I suspect that DHCP is getting a copy of every packet (that can't
> help network performance?)

This is a long standing and well known issue.

The problem is that it used to be the case that before you put an IP
address on an interface, you couldn't even receive broadcast UDP
frames on a UDP socket.

So all DHCP implementations use AF_PACKET sockets in promiscuous mode
to deal with this.

These days you can actually receive broadcast frames on an interface
which hasn't had an IP assigned to it yet, due to some routing check
changes that were made a few years ago, but this support obviously not
present in older kernels.

Compound this with the pain that it would take to adjust all the
various DHCP implementations to not only support this, but have
the fallback code too.
