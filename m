From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] net: Add support for ndo_select_queue()
 functions to cache the queue mapping
Date: Wed, 03 Feb 2010 17:47:35 -0800 (PST)
Message-ID: <20100203.174735.50359131.davem@davemloft.net>
References: <1264700317.2783.15.camel@achroite.uk.solarflarecom.com>
	<20100128100011.2b624a9e@nehalam>
	<1264703676.2783.44.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37819
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753074Ab0BDBrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 20:47:23 -0500
In-Reply-To: <1264703676.2783.44.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 28 Jan 2010 18:34:34 +0000

> On Thu, 2010-01-28 at 10:00 -0800, Stephen Hemminger wrote:
>> Therefore the transmit hash and receiver hash will be different.
> 
> The intent here is to make it worthwhile to calculate that expensive
> hash on the TX side.

I would rather something like this be implemented in a way
which is device hash agnostic.

And I believe it is possible to do this.

Anyways, why can't you just propagate the RX queue used by the flow to
the socket TX hash?  We already store the RX queue in the SKB on
receive, the socket packet receive handling can simply propagate that
to the TX queue selector.

This would avoid having to do anything special in the driver's select
queue method.  In any event, overriding the queue selection method,
while not absolutely forbidden, is very much discouraged.  And if
this new scheme of yours creates another reason drivers will start
to override it, that's another negative in my book.

But most importantly, the last thing we want to do is calculate
something insane like Toeplitz, even if it's just once per connection.
