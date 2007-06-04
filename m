From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: 04 Jun 2007 14:17:25 +0200
Message-ID: <ygfejkrrk16.fsf@janus.isnogud.escape.de>
References: <20070530131123.10843.0@janus.isnogud.escape.de>
	<20070530131204.10843.5@janus.isnogud.escape.de>
	<465DB0B6.109@trash.net> <465F2F20.6090700@hartkopp.net>
	<46603340.2050309@trash.net> <46613DBE.3010602@hartkopp.net>
	<4661CBE7.7040901@hartkopp.net> <46631396.8030004@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:44299 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752052AbXFDMZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 08:25:42 -0400
In-Reply-To: <46631396.8030004@hartkopp.net>; from Oliver Hartkopp on Sun, 03 Jun 2007 21:16:38 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp <socketcan@hartkopp.net> writes:

> 2. The loopback indication is done by using the unused skb->protocol in
> the tx path.

I don't think we should (mis-)use skb->protocol as a loopback flag.
As the name says, it's the protocol number and not a flag whether
loopback is to be done by the driver.  Even if it's not used otherwise
in tx path (haven't checked this), in my experience it is asking for
future trouble to use variables other than for it's intended purpose.

IMO it would be better to skb->pkt_type.  This is used to indicate
packet type to rcv functions registered by dev_add_pack().  It is set
by netdevice drivers to PACKET_{MULTICAST,BROADCAST,HOST,OTHER} for
received packets.  In the send path it is set to PACKET_OUTGOING on
the copy of the skbuff that is delivered to the sockets registered on
ptype_all (typically packet sockets from tcpdump or other sniffers).
AFAICS, pkt_type is not used otherwise in the send path.

We could set skb->pkt_type = PACKET_LOOPBACK to flag to the CAN
netdevice driver whether to loop back the packet.

Any objections?

urs
