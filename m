From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: Add support for the LXT973 phy.
Date: Mon, 07 Jun 2010 01:18:35 -0700 (PDT)
Message-ID: <20100607.011835.55846752.davem@davemloft.net>
References: <20100602.065017.139108801.davem@davemloft.net>
	<AANLkTinR9_VoWX8zZu93MeohHvCbCy_P5XWHH3rxlPuH@mail.gmail.com>
	<20100605140017.GA2750@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@gmail.com, netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54668
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756508Ab0FGISY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 04:18:24 -0400
In-Reply-To: <20100605140017.GA2750@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sat, 5 Jun 2010 16:00:17 +0200

> On Wed, Jun 02, 2010 at 02:32:11PM -0500, Andy Fleming wrote:
>> Yeah, I was clearly not thinking clearly.  dev_flags will be
>> overwritten, and is not meant for this.  I believe, what we should do
>> is add a "port" field to the PHY device, and if PCR_FIBER_SELECT is
>> set, then set the port field to PORT_FIBRE.  I'm not entirely clear on
>> the semantics of that field in the ethtool cmd, but it seems like the
>> right idea.
> 
> Here is another try. Is that more like it?

I think this is overkill.

One, and only one, PHY driver wants to maintain a boolean state and
we're adding a full 32-bit flags member to the generic PHY device
struct to accomodate this?

Andy if you have ideas to use that state via ethtool or whatever in
the future, you come back to us when the future arrives and you've
implemented the code in the generic PHY lib code to do that stuff.

As it stands right now, that code doesn't exist so accomodating it is
just silly.

I also think worrying about the phy_dev->priv pointer being misused in
the future inside of this driver is a completely bogus argument by any
measure.

We have many cases all over the kernel tree, in drivers and elsewhere,
where we encode integer states in what are normally pointer values
when we need to maintain a small piece of state and don't need to do a
full blown memory allocation to allocate a piece of extra memory to
hold that state.

Richard, please just resubmit your original patch and I will apply it.

Thanks.

