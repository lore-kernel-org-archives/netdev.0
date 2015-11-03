From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 16:19:43 +0100
Message-ID: <201511031619.43802.marex@denx.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <56389C38.4080508@pengutronix.de> <CAAP7ucLhzqh8+QxYJwx-8-DqSb6YqV0ZXXVGqY=OUUnzAu5EVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Marc Kleine-Budde" <mkl@pengutronix.de>,
	Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:57589 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182AbbKCPbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 10:31:43 -0500
In-Reply-To: <CAAP7ucLhzqh8+QxYJwx-8-DqSb6YqV0ZXXVGqY=OUUnzAu5EVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, November 03, 2015 at 04:06:05 PM, Aleksander Morgado wrote:
> On Tue, Nov 3, 2015 at 12:36 PM, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
> > On 11/03/2015 11:36 AM, Aleksander Morgado wrote:
> >> On Mon, Nov 2, 2015 at 9:25 PM, Marek Vasut <marex@denx.de> wrote:
> >>>>> I was thinking about this and I mostly agree with you. Obviously,
> >>>>> copying the code this way was dumb. On the other hand, ARINC and CAN
> >>>>> are two different sort of busses, so I'd propose something slightly
> >>>>> different here to avoid confusion and prevent the future extensions
> >>>>> (or protocols) from adding unrelated cruft into the CAN stack.
> >> 
> >> I'd keep them separate not because ARINC may add unrelated cruft into
> >> the CAN stack, but because ARINC is much simpler than CAN already...
> > 
> > What about maintainability? Why take care of two almost identical
> > subsystems? With making one stack "simpler" you increase, from my point
> > of view, the costs of maintaining even more. If you fix problems in one
> > stack you have to adopt the other, too.
> 
> If they can share common code, that's fine, that probably can be
> worked around if needed. My main issues are actually with all the
> behavior that CAN supports and doesn't make much sense in ARINC, like
> the complex ID filtering scheme for example (ARINC just requires 256
> bits for a minimum filter)

So does CAN, I don't see a problem re-using the filtering infrastructure here.

> , or the duplex TX/RX setup for channels
> (channels are either RX or TX, not both), or the local
> echoing/loopback (which wouldn't make much sense for TX-only
> channels).

Aren't the RX-only/TX-only channels rather a special case ? In that case, you
can register a device per each such channel and be done with it, no ?

> The minimum subset of features required by an ARINC driver
> is actually very small. Trying to "fit" ARINC as a subset of CAN may
> actually be harder than keeping it separate maintainability wise.
> Maybe the issue here is that the original patch is too CAN-like while
> it shouldn't be, don't know.

Best regards,
Marek Vasut
