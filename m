From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Wed, 30 Nov 2016 17:55:00 +0100
Message-ID: <20161130165500.GH21645@lunn.ch>
References: <1480495831.3563.135.camel@infinera.com>
 <20161130135257.GC18716@lunn.ch>
 <1480516241.3563.142.camel@infinera.com>
 <20161130152503.GE21645@lunn.ch>
 <1480523716.3563.144.camel@infinera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35281 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753898AbcK3QzC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 11:55:02 -0500
Content-Disposition: inline
In-Reply-To: <1480523716.3563.144.camel@infinera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is an embedded system with several boards in a subrack.
> Each board has eth I/F connected to a switch to communicate with each other.
> One of the board will also house the actual switch device and manage the switch.
> Then the normal app just communicates over the physical eth I/F like any other board
> in the system. There is a "manage switch app" which brings the switch up and partition
> phys VLANs etc. (each phys I/F would be a a separate domain so no loop)

So you are planning on throwing away the "manage switch app", and just
use standard linux networking commands? That is what switchdev is all
about really, throwing away the vendor SDK for the switch, making a
switch just a bunch on interfaces on the host which you manage as
normal interfaces.

> I guess I could skip the phys I/F and have the switch app create a virtual eth0 I/F over PCIe

No need to create this interface. It will exist if you go the
switchdev route.

> > > And switchdev can do all this over PCIe instead? Can you have a
> > > switch tree in switchdev too?
> > 
> > Mellonex says so, but i don't think they have actually implemented it.
> 
> Not impl. any of DSAs features? What can you do with a Mellonex switch then?

They don't have a tree of switches, as far as i know. Just a single
switch. But DSA does support a tree of switches, that is what the D in
DSA means, distributed. And there are a couple of boards which have 2
to 4 switches in a tree.

I think this is partially down to market segments. Mellonex market is
top of rack switches. High port count, very high bandwidth. DSA is
more wireless access points, set top boxes, generally up to 7 ports of
1Gbps and a few custom embedded products which need more ports, so
build a tree of switches.

      Andrew
