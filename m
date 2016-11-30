From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Wed, 30 Nov 2016 16:25:03 +0100
Message-ID: <20161130152503.GE21645@lunn.ch>
References: <1480495831.3563.135.camel@infinera.com>
 <20161130135257.GC18716@lunn.ch>
 <1480516241.3563.142.camel@infinera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35121 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756000AbcK3PZE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 10:25:04 -0500
Content-Disposition: inline
In-Reply-To: <1480516241.3563.142.camel@infinera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 02:30:43PM +0000, Joakim Tjernlund wrote:
> On Wed, 2016-11-30 at 14:52 +0100, Andrew Lunn wrote:
> > On Wed, Nov 30, 2016 at 08:50:34AM +0000, Joakim Tjernlund wrote:
> > > I am trying to wrap my head around these two "devices" and have a hard time telling them apart.
> > > We are looking att adding a faily large switch(over PCIe) to our board and from what I can tell
> > > switchdev is the new way to do it but DSA is still there. Is it possible to just list
> > > how they differ?
> > 
> > Hi Joakim
> 
> Hi Andrew, thanks for answering
> 
> > 
> > If the interface you use to send frames from the host to the switch is
> > PCIe, you probably want to use switchdev directly.
> 
> OK, we will have a few ethernet I/F's connected too but I these should be used
> as normal interfaces just interfacing a switch.

That does not make much sense.

Maybe time to backtrack a bit. The Linux concept for switch/router
chips is that they are just hardware accelerators for what Linux can
already do in software. Each port of the switch is just a normal Linux
interface.  ip link show will list each port. ip addr add can be used
to add an IP address to the interface.  You want to switch frames
between two ports: Create a linux bridge and put the interfaces into
it. Via switchdev you get a call into the hardware to accelerate
this. If the hardware cannot accelerate it, it is done in software as
normal.  Want to combine two ports into a trunk: Add a team interface
and make the port interfaces slaves of the team interface. Via
switchdev, you ask the hardware to accelerate this. If it cannot, it
is done in software.

So back your connecting a few host interfaces to the switch. This is
logically putting a cable between two interfaces on the same host. You
are making a loopback. Why do that? Sure it is possible, but it is an
odd architecture.

> And switchdev can do all this over PCIe instead? Can you have a
> switch tree in switchdev too?

Mellonex says so, but i don't think they have actually implemented it.

	 Andrew
