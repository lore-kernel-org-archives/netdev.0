From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: rx_dropped count for USB ethernet interfaces
Date: Thu, 26 Sep 2013 10:32:24 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B735E@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B735B@saturn3.aculab.com> <20130925.144640.1661224048195310923.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37858 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751483Ab3IZJfI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 05:35:08 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22755-10 for <netdev@vger.kernel.org>;
 Thu, 26 Sep 2013 10:35:02 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130925.144640.1661224048195310923.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]

> > Edited slightly...
> > We are seeing the 'rx_dropped' count increasing on ethernet interfaces.
> > 
> > Now I thought that rx_dropped was a count of the number of packets
> > that the MAC driver/hardware discarded - typically because the rx
> > ring had no buffers. This could include packets dropped in the
> > receive stack due to other memory limits.
> >
> > However it looks as though Linux is also counting rx_dropped if
> > the packet can't be delivered to a protocol.
> 
> This is expected and correct behavior.

It isn't exactly useful behaviour though.
Two different things are being counted together.

Packets dropped by the hardware (or by ENOMEM errors) are packets
that haven't been delivered to the protocol stack - so cause
some kind of protocol recovery actions.
If any of these are happening there is usually something wrong
with the system/network.

Packets for which there is no protocol are largely boring.
Especially if they are multicast packets.

A compromise might be to only count packets that are directed
to the interface's MAC address.
In this case there is at least some expectation that the system
should process the packet.

	David
