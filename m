From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Mon, 04 Jun 2007 13:53:59 +0200
Message-ID: <4663FD57.3020601@trash.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de> <20070530131204.10843.5@janus.isnogud.escape.de> <465DB0B6.109@trash.net> <465F2F20.6090700@hartkopp.net> <46603340.2050309@trash.net> <46613DBE.3010602@hartkopp.net> <4661CBE7.7040901@hartkopp.net> <46631396.8030004@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35495 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbXFDL4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 07:56:40 -0400
In-Reply-To: <46631396.8030004@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> 1. The needed skb->sk is preserved for the rx path (the way 'up').


I was thinking about this, don't CAN frames include the identity
of the sender? That would be the easiest way to determine whether
the frame needs to be delivered.

> 2. The loopback indication is done by using the unused skb->protocol in
> the tx path.


Actually its not unused, it needs to be set on TX frames once the
packet leaves the protocol specific code. Its used for example by
packet sockets (sk_run_filter), qdisc classification, neighbour
resolution, gso segmentation, ...

I don't get why you can't directly check the socket option on the
TX path.
