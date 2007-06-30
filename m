From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sun, 1 Jul 2007 00:24:40 +0200
Message-ID: <200707010024.40649.mb@bu3sch.de>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com> <200706302353.25426.mb@bu3sch.de> <20070630220301.GD2553@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: =?iso-8859-1?q?T=F6r=F6k_Edvin?= <edwintorok@gmail.com>,
	zambrano@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, power@bughost.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:46264
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbXF3WZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 18:25:22 -0400
In-Reply-To: <20070630220301.GD2553@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 01 July 2007 00:03:01 Lennert Buytenhek wrote:
> On Sat, Jun 30, 2007 at 11:53:25PM +0200, Michael Buesch wrote:
> 
> > > When the interface is down (or driver removed), the BroadCom 44xx card remains
> > > powered on, and both its MAC and PHY is using up power.
> > > This patch makes the driver issue a MAC_CTRL_PHY_PDOWN when the interface
> > > is halted, and does a partial chip reset turns off the activity LEDs too.
> > > 
> > > Applies to 2.6.22-rc6, or current git head.
> > > 
> > > Tested on a Broadcom BCM4401-B0 card, it saves ~0.5W (measured using powertop).
> > 
> > Hm, I was going to measure the real power advantage with a
> > PCI-extender card. But my B44B0 card doesn't seem to work in
> > that extender card. It works perfectly fine sticked directly into
> > the motherboard, though, and other cards like a BCM4318 work in
> > the extender, too.
> > Not sure what this is.
> > The extender has an application note about nonworking cards in the
> > extender and a too big resistor on the board IDSEL pin being the
> > cause of this.
> 
> Does the card show up in lspci at all?

No it doesn't.

> IDSEL drive strength 
> issues should only affect config space accesses.

Yeah.

> Does the extender board have a PCI-PCI bridge on it?  (If not,
> there's not really any reason to resistively couple the IDSEL
> line to the host, since the host should take care of that.)

There's no bridge. It just decouples all voltage lines, so you can
drive it from external supply and/or measure voltages and current.
On the PCB it looks like the the IDSEL line is rather directly
routed to the host IDSEL. It just goes through one of the bus
isolation chips. So I guess (just my guess) that this chip has some
resistance and if the total resistance of the chip + the IDSEL
resistor on the mainboard goes above some threshold it doesn't work
anymore for some cards. In the application note they write
about trouble for IDSEL resistors >51ohms.

> > Maybe I can try with another machine tomorrow.
> 
> That would only make a difference if there is no PCI-PCI bridge on
> the extender board.

Well, they suggest it in the application note as a possible fix. ;)


-- 
Greetings Michael.
