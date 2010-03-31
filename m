From: Glen Turner <gdt@gdt.id.au>
Subject: Re: UDP path MTU discovery
Date: Thu, 01 Apr 2010 10:13:04 +1030
Message-ID: <1270078984.2389.33.camel@ilion>
References: <1269561751.2891.8.camel@ilion>
	 <877how25kx.fsf@basil.nowhere.org>  <4BB0DCF6.9020401@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:36029 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754139Ab0CaXl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 19:41:58 -0400
In-Reply-To: <4BB0DCF6.9020401@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-03-29 at 10:01 -0700, Rick Jones wrote:

> But which of the last N datagrams sent by the application should be retained for 
> retransmission?  It could be scores if not hundreds of datagrams depending on 
> the behaviour of the application and the latency to the narrow part of the network.

We don't need that sort of exotica from the kernel.  The applications
have to be prepared to retransmit lost packets in any case.

What we need is an API for an instant notification that a ICMP Packet
Too Big message has arrived concerning the socket.

Then the application simply retransmits immediately, without adding
to the exponential backoff penalty which the application maintains.
The application maintain a overall packet-transmitted limit to prevent
a DoS.

>From this application behaviour the kernel sees a stream of packets
it can use for UDP Path MTU Discovery (paced at the RTT, so not
contributing to congestion collapse). That stream halts when the
first packet makes it to the end system.

As for David Miller's rant, the applications currently have no choice
but to "do it stupidly" as the kernel doesn't pass enough information
for user space to do it intelligently.  If the kernel passed user space
the same indication as TCP gets, then we could -- and would -- do it
right.

Re-writing the applications to take advantage of the API is no great
shakes -- there aren't many of them, they are written by people with
a good knowledge of networking, but unfortunately they tend to do
important stuff (allocate addresses, serve names, authenticate link
layer access).

It would be nice if the API had some commonality between platforms.
But there's no shortage of #ifdefs already, and one more to make
these applications work well for IPv6 on jumbo frames on the platform
of choice for networking infrastructure would be seen by application
authors as well worthwhile.

Thanks for your consideration,
Glen

-- 
 Glen Turner
 www.gdt.id.au/~gdt

