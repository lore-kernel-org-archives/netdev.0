From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Wed, 18 Nov 2015 17:41:31 +0100
Message-ID: <201511181741.31744.marex@denx.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <201511101715.39253.marex@denx.de> <CAAP7ucKpH5LTV1pw-JBJ=mD4_QFBwKYU9tLANkM4s40c+Oc0Hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Marc Kleine-Budde" <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:59864 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756242AbbKRQll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 11:41:41 -0500
In-Reply-To: <CAAP7ucKpH5LTV1pw-JBJ=mD4_QFBwKYU9tLANkM4s40c+Oc0Hg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, November 18, 2015 at 05:38:02 PM, Aleksander Morgado wrote:
> On Tue, Nov 10, 2015 at 5:15 PM, Marek Vasut <marex@denx.de> wrote:
> >> >> >>> > About the parity -- can we add some flag into the datagram to
> >> >> >>> > indicate we want hardware to calculate the parity for that
> >> >> >>> > particular datagram for us? And we'd also need to indicate what
> >> >> >>> > type of parity. I dunno if this is worth the hassle.
> >> >> >>> 
> >> >> >>> This  is HW configuration property, it does not belong to 
> >> >> >>> datagram. Also for TX channels,  parity could  be  two  kinds: 
> >> >> >>> odd and even, for RX it is only on/off.
> >> >> >> 
> >> >> >> There are datagrams which do contain parity and ones which do not
> >> >> >> contain it, correct ? Thus, it's a property of that particular
> >> >> >> datagram.
> >> >> 
> >> >> All ARINC words have bit #31 as parity bit; whether it's used or not
> >> >> depends on the setup as Andrey says below.
> >> > 
> >> > Can bit 31 be ever used for DATA instead of parity ? Or is this just
> >> > me not understanding the parlance of the specification, where "DATA"
> >> > actually means "DATA with parity" ?
> >> 
> >> Well, as far as I know bit 31 is always parity bit, never used for
> >> actual data contents. Which is the spec section that got you confused?
> >> Maybe I'm the one which didn't read it well?
> > 
> > Sorry for being so late into the discussion.
> > 
> > I got confused by hi-3585_v-rev-l.pdf page 7 right, CR4 lets you treat
> > bit 32 as either data or parity. But I guess this is not the general
> > case.
> > 
> > So I wonder, does it make sense to treat the P bit as data always and do
> > parity in software or not ?
> 
> I don't have an strong opinion on this, truth be told. It really
> depends on whether we can tell the HW "go compute the parity
> yourself". If we can ask for that, maybe we should allow configuring
> that in the API with some flag. But anyway, treating P as data (i.e.
> software should set parity bit to whatever is needed) is the most
> generic thing you could do for a start, that shouldn't be wrong.

OK, let's treat it as data.

Since RC1 is out, I should start reworking the framework into more sensible
shape and repost before I miss the opportunity.

Best regards,
Marek Vasut
