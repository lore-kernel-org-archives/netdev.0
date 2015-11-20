From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 00/15] net: The beginning of the end for
 NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM
Date: Fri, 20 Nov 2015 16:42:34 -0500 (EST)
Message-ID: <20151120.164234.575970217961631756.davem@davemloft.net>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759815AbbKTVmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 16:42:37 -0500
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 19 Nov 2015 11:55:46 -0800

> Goals of this patch set:
> 
> We propose that drivers advertise NETIF_F_HW_CSUM instead of protocol
> specific values of NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM.  If the
> driver's device is constrained (for instance it can only offlaod simple
> IPv4 and IPv6 packets) then these constraints can be checked in the
> transmit path and skb_checksum_help would be called for packets that the
> driver is unable to offload. In order to facilitate this, we add some
> helper functions that takes a specification argument indicating the
> type of packets a device is able to offload. If a packet does not match
> the specification, the helper function calls skb_checksum_help.

I very much like the direction this is taking things.  And I do sincerely
hope that this does in fact actually encourage HW vendors to drop all of
the protocol specific offloading, and just support 2's complement sums.

They can turn that _trivially_ into whatever the Windows et al. driver
interfaces want in their respective drivers.

There is absolutely no reason to implement protocol specific checksum
offloads in silicon in this day and age.

Absolutely none.

So driver folks tell your hardware buddies to just stop doing it now
and get with the program.  Even your marketing department shouldn't
care, they can list support for every protocol on the planet in their
specs and packaging if they want, and it might even look impressive...

Thanks.
