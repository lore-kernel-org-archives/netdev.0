From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 1/4] net: dsa: add support for the SMSC-LAN9303
 tagging format
Date: Fri, 7 Apr 2017 15:06:10 +0200
Message-ID: <20170407130610.GD17290@lunn.ch>
References: <20170407081502.30172-1-jbe@pengutronix.de>
 <20170407081502.30172-2-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170407081502.30172-2-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 07, 2017 at 10:14:59AM +0200, Juergen Borleis wrote:
> To define the outgoing port and to discover the incoming port a regular
> VLAN tag is used by the LAN9303. But its VID meaning is 'special'.
> 
> This tag handler/filter depends on some hardware features which must be
> enabled in the device to provide and make use of this special VLAN tag
> to control the destination and the source of an ethernet packet.
> 
> +
> +/* To define the outgoing port and to discover the incoming port a regular
> + * VLAN tag is used by the LAN9303. But its VID meaning is 'special':
> + *
> + *       Dest MAC       Src MAC        TAG    Type
> + * ...| 1 2 3 4 5 6 | 1 2 3 4 5 6 | 1 2 3 4 | 1 2 |...
> + *                                |<------->|
> + * TAG:
> + *    |<------------->|
> + *    |  1  2 | 3  4  |
> + *      TPID    VID
> + *     0x8100
> + *
> + * VID bit 3 indicates a request for an ALR lookup.

Hi Juergen

Maybe on the transmit path, you should look into the packet and see if
there is already a VLAN header, and if bit 3 is set, drop the
packet. Somebody could configure the stack from userspace to produce
such packets to direct them out specific ports, which is not what you
want. Worse still, this could be packets you are getting from
somewhere else, e.g. a L2 VPN.

	  Andrew
