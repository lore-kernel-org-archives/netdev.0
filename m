From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: at803x: Add support to control PHY LEDs
Date: Mon, 21 Mar 2016 19:13:04 +0100
Message-ID: <20160321181304.GH28582@lunn.ch>
References: <1458223147-16142-1-git-send-email-vishalthanki@gmail.com>
 <1458223147-16142-2-git-send-email-vishalthanki@gmail.com>
 <20160317145032.GB26019@lunn.ch>
 <56EAE277.4050109@gmail.com>
 <CAC3a_SD=chB8pPpdRm8scztJ4592J26_PmhbUkLmbE3=DCmX-w@mail.gmail.com>
 <20160317175152.GG26019@lunn.ch>
 <20160317180710.GA22685@c50.bag.software>
 <20160321173648.GA30581@c50.bag.software>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>, netdev@vger.kernel.org
To: Vishal Thanki <vishalthanki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51631 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756706AbcCUSNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2016 14:13:07 -0400
Content-Disposition: inline
In-Reply-To: <20160321173648.GA30581@c50.bag.software>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 21, 2016 at 06:36:50PM +0100, Vishal Thanki wrote:
> Hi,
> 
> On Thu, Mar 17, 2016 at 07:07:12PM +0100, Vishal Thanki wrote:
> > > 
> > > They might not be on/off controllable individually, but you can often
> > > set them to show Packet RX, Packet TX, Link, speed, etc, in a
> > > reasonably flexible way. So you could have LED triggers mapping to
> > > these functionalities. The user can then pick the trigger for the LED.
> > > 
> > > Actually, the data sheet says:
> > > 
> > > 2.3.4 LED Interface
> > > 
> > > The LED interface can either be controlled by the PHY or controlled
> > > manually, independent of the state of the PHY. Two status LEDs are
> > > available. These can be used to indicate operation speed, and link
> > > status. The LEDs can be programmed to different status functions from
> > > their default value. They can also be controlled directly from the MII
> > > register interface.
> > > 
> > > So maybe you can control the on/off state.
> > > 
> 
> I need some more understanding on using the LED subsystem for this task.
> Pardon my lack of knowledge, and probably silly questions too.
> 
> Here is what I understood when we decide to use the LED subsystem for
> exposing PHY LEDs.
> 
> 1) Have a generic driver under drivers/leds/, for example leds-eth-phy.c
> 2) Implement a set of phylib APIs which will be used by generic phy led
> driver to set the brightness.
> 3) The phylib APIs will depend on actual PHY driver, at803x.c for
> example, (by means of callbacks implemented in PHY driver) to control LEDs.
> 4) PHY driver can advertise its support for LEDs using the capability
> flags.
> 
> Please let me know if my understanding is correct.

LEDs are more than brightness. They can also have triggers.

It would require some rework of the LED core, but you could imagine
being able to associate triggers to specific LEDs. You could have
triggers like "eth-phy-link" and "eth-phy-activity" which the phylib and
phy driver exports. The PHY would export LEDs and say that they can be
used with these triggers. So when for example the "eth-phy-link"
trigger is activated on an LED, the PHY driver programs the hardware
to show the link status on the LED.

The key here is that the hardware is in control of the LED, when the
trigger is used. You don't want software involved when you are
transmitting a million packets per second.

	Andrew
