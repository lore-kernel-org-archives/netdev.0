From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sungem: PHY updates & pause fixes
Date: Tue, 02 Jan 2007 21:11:58 -0800 (PST)
Message-ID: <20070102.211158.35016452.davem@davemloft.net>
References: <1167800285.6165.105.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51921
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752581AbXACFL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 00:11:59 -0500
To: benh@kernel.crashing.org
In-Reply-To: <1167800285.6165.105.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 03 Jan 2007 15:58:05 +1100

> This patch adds support for a few more PHYs used by Apple and fixes
> advertising and detecting of Pause (we were missing setting the bit in
> MII_ADVERTISE and weren't testing in LPA for all PHYs). I only do it for
> gigabit capable PHYs for now.
> 
> Note that I currently only advertise pause, not asymetric pause. I don't
> know for sure the details there, I suppose I should read a bit more
> 802.3 references, and I don't now what sungem is capable of, but I
> noticed the PCS code (originated from you) does the same.
> 
> Unfortunately, whatever switches we have here also seem to only support
> asym. pause, so while I did a quick test to verify that pause is
> properly enabled on a cross-over cable to another machine, I still get
> occasional RX fifo overflows due to pause support lacking on our
> internal network.
> 
> So let me know if asym. pause is something we can support with sungem.
> In which case, it shouldn't be very hard to add in a subsequent patch.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Thanks for finding these bugs, although that's really strange pause
behavior you are seeing on your switches.

By default, we advertise PAUSE but not ASYM PAUSE in the tg3 driver,
and I get flow control on every switch I have here.

You should try to use flow control, even slower than 1000Mbit links.
That's the only problem I can see, would you mind fixing that and
I'll put your change into my net-2.6 tree and perhaps play around
with PAUSE on my switches here?

Thanks!

