From: David Miller <davem@davemloft.net>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Thu, 30 Apr 2009 02:24:17 -0700 (PDT)
Message-ID: <20090430.022417.07019547.davem@davemloft.net>
References: <606676310904291600u40e44187g4cfc104007b24fce@mail.gmail.com>
	<96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andrew@whydna.net, netdev@vger.kernel.org
To: jelaas@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37287
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753077AbZD3JYX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2009 05:24:23 -0400
In-Reply-To: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jens L=E5=E5s <jelaas@gmail.com>
Date: Thu, 30 Apr 2009 11:07:35 +0200

> RX-side looks good. TX-side looks like what we also got with vanilla =
linux.
>=20
> What we do is patch all drivers with a custom select_queue function
> that selects the same outgoing queue as the incoming queue. With a on=
e
> to one mapping of queues to CPUs you can also use the processor id.
>=20
> This way we get performance.

I don't understand why this can even be necessary.

With the current code, the RX queue of a packet becomes
the hash for the TX queue.

If all the TX activity is happening on one TX queue then
there is a bug somewhere.

Either the receiving device isn't invoking skb_record_rx_queue()
correctly, or there is some bug in how we compute the TX hash.

Everyone adds their own hacks, but that absolutely should not be
necessary, the kernel is essentially doing what you are adding
hacks for.

The only possible problems are bugs in the code, and we should find
those bugs instead of constantly talking about 'local select_queue
hacks we add to our cool driver for performance' :-/

