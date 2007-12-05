From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] don't allow netfilter --setmss to increase mss
Date: Wed, 05 Dec 2007 09:20:52 +0100
Message-ID: <47565F64.2000907@trash.net>
References: <20071204224535.GY27007@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55267 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbXLEIVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 03:21:06 -0500
In-Reply-To: <20071204224535.GY27007@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please send netfilter-related patches to netfilter-devel.

Benjamin LaHaise wrote:
> When terminating DSL connections for an assortment of random customers, I've 
> found it necessary to use iptables to clamp the MSS used for connections to 
> work around the various ICMP blackholes in the greater net.  Unfortunately, 
> the current behaviour in Linux is imperfect and actually make things worse, 
> so I'm proposing the following: increasing the MSS in a packet can never be 
> a good thing, so make --set-mss only lower the MSS in a packet.
> 
> Yes, I am aware of --clamp-mss-to-pmtu, but it doesn't work for outgoing 
> connections from clients (ie web traffic), as it only looks at the PMTU on 
> the destination route, not the source of the packet (the DSL interfaces in 
> question have a 1442 byte MTU while the destination ethernet interface is 
> 1500 -- there are problematic hosts which use a 1300 byte MTU).  Reworking 
> that is probably a good idea at some point, but it's more work than this is.

Yes, this has always annoyed me too as it doesn't really work for me
in a similar setup where traffic first goes through an IPsec tunnel,
then through a MSS mangling gateway and then over a DSL line. I'll
add a patch on top of yours to take the MSS in reverse direction
into account.

> Thoughts?  Would it be better to add a new flag?

No, this is obviously a good idea, I actually thought we'd already
prevent increasing it in all cases. I've applied your patch, thanks.
