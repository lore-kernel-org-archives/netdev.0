From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 28 Jun 2006 16:34:23 +0200
Message-ID: <200606281634.24160.mb@bu3sch.de>
References: <20060626212547.GE30706@tuxdriver.com> <200606272223.19928.mb@bu3sch.de> <44A19712.40702@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:39098
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1423364AbWF1Oeu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 10:34:50 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44A19712.40702@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 June 2006 22:37, Larry Finger wrote:
> Michael Buesch wrote:
> > On Tuesday 27 June 2006 22:06, Larry Finger wrote:
> >> John,
> >>
> >> I would like to find a diplomatic solution to this impasse between Michael and Jeff, which is why 
> >> I'm writing to you privately. Michael is correct in that the loop in question will not usually delay 
> > 
> > private?
> 
> I meant it to be private, but screwed up.
> 
> >> long; however, on some hardware it takes longer than on his. On mine, I have seen delays as long as 
> >> 550 usec.
> > 
> > What's the chip?
> 
> bcm43xx: Chip ID 0x4306, rev 0x2
> bcm43xx: Number of cores: 6
> bcm43xx: Core 0: ID 0x800, rev 0x2, vendor 0x4243, enabled
> bcm43xx: Core 1: ID 0x812, rev 0x4, vendor 0x4243, disabled
> bcm43xx: Core 2: ID 0x80d, rev 0x1, vendor 0x4243, enabled
> bcm43xx: Core 3: ID 0x807, rev 0x1, vendor 0x4243, disabled
> bcm43xx: Core 4: ID 0x804, rev 0x7, vendor 0x4243, enabled
> bcm43xx: Core 5: ID 0x812, rev 0x4, vendor 0x4243, disabled
> bcm43xx: Ignoring additional 802.11 core.
> bcm43xx: Detected PHY: Version: 1, Type 2, Revision 1
> bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)

It appears to be an older card. There are quite some
special codepaths for this, I think.

> >> This would make the worst-case delay be 5 msec, but would provide a cushion of 10X the longest I 
> >> have seen and should be safe.
> >>
> >> Do you have any suggestions on what should be done next?
> > 
> > Leave it as is and find out why it takes so long for your strange card. ;)
> 
> I once offered you my second, duplicate card for testing, but never heard back. Do you have any 
> ideas regarding diagnostics to see why it takes so long? Remember, this card used to time-out on the 
> 1 second delay before the periodic work was restructured.

Well, we did not want to have the card, because at this point
it did not make sense. We all have 4306 cards.
But now it appears that this card seems to have some special
things (because it is older than ours).

Well, how to debug.
We are waiting for the IRQ Reason register there.
Actually, we are waiting for the "no IRQ pending, but READY signal"
state. Your card does not completely (?) clear the bits after MAC
shutdown. So very helpful would be to print out in the loop the
value. We know, that the card generates silly IRQs, that we did
not ask for. That may happen here, too. So it _may_ help to
mask out unwanted IRQs before the if-check. But I would first
like to see a log of the reason-value on each iteration until it succeeds.

-- 
Greetings Michael.
