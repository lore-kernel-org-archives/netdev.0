From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Mon, 2 Nov 2015 21:25:47 +0100
Message-ID: <201511022125.47892.marex@denx.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <201511021916.18117.marex@denx.de> <666821254.20151102231521@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	"Marc Kleine-Budde" <mkl@pengutronix.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:46681 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbbKBUZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 15:25:51 -0500
In-Reply-To: <666821254.20151102231521@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, November 02, 2015 at 09:15:21 PM, Vostrikov Andrey wrote:
> Hi,

Hi,

> > I was thinking about this and I mostly agree with you. Obviously, copying
> > the code this way was dumb. On the other hand, ARINC and CAN are two
> > different sort of busses, so I'd propose something slightly different
> > here to avoid confusion and prevent the future extensions (or protocols)
> > from adding unrelated cruft into the CAN stack.
> 
> Another  major  difference  between  CAN and ARINC429 is that ARINC is
> simplex.  It  does  not  need  loopback  and echo. For example HOLT IC
> chip  HI-3593  has  two receivers and single transmitter, which
> should  be  instantiated as separate devices, as each channel could be
> connected to different network.

So this would effectively be three devices, correct ?  I think you can just
register a regular ARINC device for each channel and be done with it. Loopback
and echo can be configurable.

> It  would  be nice if new ARINC framework will provide means to create
> RX  or  TX  only  network device and have -rx- or -tx- as part of device
> name.

I'd say you can fail the TX if you're trying to send via an RX-only channel.
The naming can probably be also tweaked, but I don't see much value in that,
especially since you can rename those interfaces by using udev rules. Checking
if the interface supports RX/TX should be done by other means, not the name.

> Label  space in ARINC is much smaller than in CAN, is it really needed
> to  have  hash  and  masks? May be simple bitmap for 256 bits will fit
> better.  At least it could be directly provided to mentioned HOLT chip
> to do filtering in hardware.

CAN does the can_id filtering this way and I find it familiar and convenient,
so I don't see a reason not to re-use it. If the hardware has some special
support for the frame filtering, it's the driver that should convert the
filter specification into form which the hardware understands -- this sort
of configuration is done only once at the beginning of operation, so some
small overhead of the conversion of the filter setting should be acceptable,
we're talking about generating 256 entries for the hardware from ID/mask tuple,
no big deal here.

Best regards,
Marek Vasut
