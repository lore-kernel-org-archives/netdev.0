From: "David Laight" <David.Laight@ACULAB.COM>
Subject: rx_dropped count for USB ethernet interfaces
Date: Wed, 25 Sep 2013 17:22:38 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B735B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37845 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750814Ab3IYQgE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 12:36:04 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13230-06 for <netdev@vger.kernel.org>;
 Wed, 25 Sep 2013 17:35:58 +0100 (BST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing the 'rx_dropped' count increasing on an USB ethernet interfaces
smsc95xx, but not on the e1000 interface connected to the same LAN.

Now I thought that rx_dropped was a count of the number of packets that the
MAC driver/hardware discarded - typically because the rx ring had no buffers.
This could include packets dropped in the receive stack due to other memory
limits.

However it looks as though Linux is also counting rx_dropped if the packet
can't be delivered to a protocol (at the end of __netif_receive_skb).

The LAN definitely has broadcast packets with an unknown 'ethertype',
I'd expect these to be silently discarded not counted as rx_dropped.

If I run tcpdump on the interface (even with a filter that passes nothing)
then rx_dropped doesn't change.

I think I've just worked out why I don't see these error counts
on the e1000 interface. I suspect that DHCP is getting a copy of every
packet (that can't help network performance?)

	David
