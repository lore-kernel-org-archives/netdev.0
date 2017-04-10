From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCH v2 1/4] net: dsa: add support for the SMSC-LAN9303 tagging format
Date: Mon, 10 Apr 2017 09:18:02 +0200
Message-ID: <201704100918.03272.jbe@pengutronix.de>
References: <20170407081502.30172-1-jbe@pengutronix.de> <20170407081502.30172-2-jbe@pengutronix.de> <20170407130610.GD17290@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: Andrew Lunn <andrew@lunn.ch>, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
To: kernel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:54227 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751246AbdDJHSk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 03:18:40 -0400
In-Reply-To: <20170407130610.GD17290@lunn.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Friday 07 April 2017 15:06:10 Andrew Lunn wrote:
> On Fri, Apr 07, 2017 at 10:14:59AM +0200, Juergen Borleis wrote:
> > To define the outgoing port and to discover the incoming port a regular
> > VLAN tag is used by the LAN9303. But its VID meaning is 'special'.
> >
> > This tag handler/filter depends on some hardware features which must be
> > enabled in the device to provide and make use of this special VLAN tag
> > to control the destination and the source of an ethernet packet.
> >
> > +
> > +/* To define the outgoing port and to discover the incoming port a
> > regular + * VLAN tag is used by the LAN9303. But its VID meaning is
> > 'special': + *
> > + *       Dest MAC       Src MAC        TAG    Type
> > + * ...| 1 2 3 4 5 6 | 1 2 3 4 5 6 | 1 2 3 4 | 1 2 |...
> > + *                                |<------->|
> > + * TAG:
> > + *    |<------------->|
> > + *    |  1  2 | 3  4  |
> > + *      TPID    VID
> > + *     0x8100
> > + *
> > + * VID bit 3 indicates a request for an ALR lookup.
>
> Maybe on the transmit path, you should look into the packet and see if
> there is already a VLAN header, and if bit 3 is set, drop the
> packet. Somebody could configure the stack from userspace to produce
> such packets to direct them out specific ports, which is not what you
> want. Worse still, this could be packets you are getting from
> somewhere else, e.g. a L2 VPN.

Hmm. In the transmit path the driver adds four bytes of explicit data after 
the two MACs to define the outgoing port. And the hardware uses the first 
TAG after the two MACs to forward the packet to a specific port. How should 
a userspace app manipulate this behaviour?
And if the packet to sent is already VLAN tagged, the driver still adds an 
additional TAG to define the outgoing port and the port itself removes this 
additional TAG when transmitting while the intended VLAN tag still remains. 
So I think an already existing VLAN tag doesn't interfere with the special 
port defining TAG. Or do I miss something?

Juergen

-- 
Pengutronix e.K.                             | Juergen Borleis             |
Industrial Linux Solutions                   | http://www.pengutronix.de/  |
