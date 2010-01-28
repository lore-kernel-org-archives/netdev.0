From: Danny Baumann <dannybaumann@web.de>
Subject: Re: [Bugme-new] [Bug 15147] New: phylib: no re-negotiation after
 link partner abilities changed
Date: Thu, 28 Jan 2010 08:40:58 +0100
Message-ID: <1264664458.24038.26.camel@rechenknecht.peppercon.de>
References: <bug-15147-10286@http.bugzilla.kernel.org/>
	 <20100127164833.f0c96ded.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Haavard Skinnemoen <hskinnemoen@atmel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jack.hrz.tu-chemnitz.de ([134.109.132.46]:50795 "EHLO
	jack.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293Ab0A1IJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 03:09:34 -0500
In-Reply-To: <20100127164833.f0c96ded.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> >            Summary: phylib: no re-negotiation after link partner abilities
> >                     changed

[...]

> >          Component: Network
> >         AssignedTo: drivers_network@kernel-bugs.osdl.org
> >         ReportedBy: dannybaumann@web.de
> >         Regression: No
            ^^^^^^^^^^^^^^

;-)

> > E.g. with the macb driver, which uses phylib, there is no link anymore when the
> > link partner changes its abilities. This is because no autonegotiation is done
> > again on link changes and hence the LPA register is not updated.
> > 
> > Steps for reproduction:
> > - Connect a 10/100 device to a 10/100 switch, configure switch port to 100Full
> > - Enable interface, link will be present
> > - Configure device to 10Full, link will be lost
> > - Configure switch to 10Full
> > 
> > Result:
> > Link should be present at that point, but isn't ... debug messages in
> > genphy_read_status show that lpa is still at 0x4101 (100Full).
> > 
> > Note that all that is on an AT91SAM9G20 board (hence macb driver) with a
> > Dawicom 9161 PHY connected to its Ethernet port, but AFAICT all phylib enabled
> > drivers should suffer from this.
> > 
> 
> From the above it appears that this is a regression.
> 
> Can you tell us which kernel version(s) were OK and which are not?

As far as I am aware of, this is not a regression, at least not in
phylib (if any, it's a regression for drivers that were converted to
phylib). A code part that does re-negotiation when link is down after
link was up for some time has never been present in the state machine.
In the PHY_NOLINK state, all that has ever been done is doing
phy_read_status and checking the new link state calculated from there.

Unfortunately, I don't have a good idea what would be the best thing to
do there. As far as I can tell from the basic MII PHY registers, there
is no way to distinct the "no link and no carrier = no cable connected"
and the "no link, but carrier = negotiation failed" states. If there was
such a way, the fix probably would involve re-negotiating when going
from state 1 to state 2 (or regularly using a timer when staying in
state 2). But maybe I am missing something.

Regards,

Danny

