From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 18:37:39 +0100
Message-ID: <201511031837.39726.marex@denx.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <201511031619.43802.marex@denx.de> <CAAP7uc+AkYaMv26JXUZXw6Qo_UYjmXCf_sKxe3CzwD2mMUOkXA@mail.gmail.com>
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
Received: from mail-out.m-online.net ([212.18.0.9]:50126 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbKCRhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 12:37:43 -0500
In-Reply-To: <CAAP7uc+AkYaMv26JXUZXw6Qo_UYjmXCf_sKxe3CzwD2mMUOkXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, November 03, 2015 at 05:47:54 PM, Aleksander Morgado wrote:
> On Tue, Nov 3, 2015 at 4:19 PM, Marek Vasut <marex@denx.de> wrote:
> >> >>>>> I was thinking about this and I mostly agree with you. Obviously,
> >> >>>>> copying the code this way was dumb. On the other hand, ARINC and
> >> >>>>> CAN are two different sort of busses, so I'd propose something
> >> >>>>> slightly different here to avoid confusion and prevent the future
> >> >>>>> extensions (or protocols) from adding unrelated cruft into the
> >> >>>>> CAN stack.
> >> >> 
> >> >> I'd keep them separate not because ARINC may add unrelated cruft into
> >> >> the CAN stack, but because ARINC is much simpler than CAN already...
> >> > 
> >> > What about maintainability? Why take care of two almost identical
> >> > subsystems? With making one stack "simpler" you increase, from my
> >> > point of view, the costs of maintaining even more. If you fix
> >> > problems in one stack you have to adopt the other, too.
> >> 
> >> If they can share common code, that's fine, that probably can be
> >> worked around if needed. My main issues are actually with all the
> >> behavior that CAN supports and doesn't make much sense in ARINC, like
> >> the complex ID filtering scheme for example (ARINC just requires 256
> >> bits for a minimum filter)
> > 
> > So does CAN, I don't see a problem re-using the filtering infrastructure
> > here.
> 
> Aren't CAN IDs more than 8-bit long?

11bit for CAN, but that's a minor detail.

> Also, ARINC429 labels are logically identifying the data type of the
> value being sent, not a given "node" as CAN IDs are (If I'm not
> mistaken, correct me if wrong). A single system (e.g. IRS) will send
> multiple different labels (e.g. 310 for Latitude, 311 for
> Longitude...) to different consumers (e.g. IFE will read all those).

In that case, filter those LABELs which you want to receive and decide
on their datatype in your application based on the LABEL. This works
just fine in my opinion.

On the other hand, you cansend those LABELs which you want to transmit
as well, again the logic for determining which LABEL to send is in your
application.

> The way a receiver identifies what system generated a given word (as
> the same label may have different meaning if sent by different
> systems) is usually by mapping in which RX port the word was received
> (or also through the special 377 label which may be used as equipment
> ID).

Well that's fine, isn't it ?

Best regards,
Marek Vasut
