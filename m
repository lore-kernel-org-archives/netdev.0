From: Richard Underwood <richard@aspectgroup.co.uk>
Subject: RE: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 18:56:18 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <353568DCBAE06148B70767C1B1A93E625EAB5C@post.pc.aspectgroup.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: skraw@ithnet.com, willy@w.ods.org, alan@lxorguk.ukuu.org.uk,
	carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
	bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "'David S. Miller'" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> > 	When a HOST sends out an ARP request, it's NOT associated with a
> > single connection, it's associated with the host. Why 
> should it pick a
> > "random" IP number to send as the source address?
> 
> It's not "random", it is using the IP address it intends
> to use as the source in packets it will output once the
> ARP completes.
> 
> In fact, if you look at the code in arp_solicit(), the source address
> is coming directly from the packet we are trying to output.
> 
	Which nicely sums up the bug, really.

1) The ARP response (or lack thereof) will be used for more than that
connection, using a single packet's source IP address is meaningless and
just a little aribtrary.

2) Depending on which ARP request or reply gets seen first, packets may get
routed over different interfaces or not sent out at all.

3) The code is over-complex. There must already be perfectly good code to
pick up the interface's IP address as this would HAVE to be the case when a
packet has been routed from another host.

	This sort of randomness is not acceptable in a reliable network.

		Richard
