From: David Miller <davem@davemloft.net>
Subject: Re: csum offload and af_packet
Date: Tue, 12 Aug 2008 17:55:32 -0700 (PDT)
Message-ID: <20080812.175532.137434164.davem@davemloft.net>
References: <20080812005839.GC18547@gondor.apana.org.au>
	<200808121817.19662.netdev@axxeo.de>
	<20080812233753.GA29155@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, rusty@rustcorp.com.au, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40881
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755018AbYHMAzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 20:55:31 -0400
In-Reply-To: <20080812233753.GA29155@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 13 Aug 2008 09:37:53 +1000

> Oh I totally agree that there are lots of scenarios where you
> want to have an unmolested guest image.  My point was that if
> you're going to touch the guest kernel anyway you might as well
> fix the guest user-space instead.
> 
> This is also why I've argued that the default should be to disable
> TX checksums until the guest enables it so that old guests that
> know nothing about this can continue to work.

However, I think Rusty may have a point.

The whole point of the auxdata thing was that if your tool is smart
you can get the notification that the checksum is going to be HW
computed and therefore keep capturing at a very low cost.

But for a stupid AF_PACKET user, like dhclient currently is, there is
no harm in COW'ing the packet header area and calculating the checksum
for them in this case.

I kind of hope that libpcap/tcpdump has been taught about auxdata
by now, has it? :-/

