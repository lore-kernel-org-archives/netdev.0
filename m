From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/9] DSA port configuration and status
Date: Sun, 23 Aug 2015 11:58:50 -0700
Message-ID: <55DA17EA.1040806@gmail.com>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33646 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbbHWS6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 14:58:52 -0400
Received: by oio137 with SMTP id 137so68771807oio.0
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 11:58:52 -0700 (PDT)
In-Reply-To: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/23/15 02:46, Andrew Lunn a =C3=A9crit :
> This patchset allows various switch port settings to be configured an=
d
> port status to be sampled. Some of these patches have been posted
> before.
>=20
> The first three patches provide infrastructure for configuring a
> switch ports link speed and duplex from a fixed_link phy.
>=20
> Patch four then uses this infrastructure to allow the CPU and DSA
> ports of a switch to be configured using a fixed-link property in the
> device tree.

Your changes look very clean and neat!

Since we keep seeing changes around the fixed PHY driver, I am starting
to wonder whether we need something more lightweight than a full fledge=
d
fixed PHY to retrieve link parameters and manage them outside of the PH=
Y
library.

One of the promises of the PHY library is that you will get a number of
things for free, whether you deal with a real PHY device or a fixed PHY
one: ethtool reporting, adjust_link to configure the Ethernet MAC with
detected/hardcoded link settings, automatic carrier settings etc...
Which would have to be repeated in individual drivers utilizing a more
lightweight fixed link code...

>=20
> Patches five and six allow a phy-mode property to be specified in the
> device tree, and allow this to be used for configuring RGMII delays.
>=20
> Patches seven through nine allow link status, for example that of an
> SFP module, to be read from a gpio.
>=20
> Please don't merge these patches until Florian Fainelli has reviewed
> them.
>=20
> Andrew Lunn (8):
>   dsa: mv88e6xxx: Allow speed/duplex of port to be configured
>   phy: fixed_phy: Set supported speed in phydev
>   net: dsa: Allow configuration of CPU & DSA port speeds/duplex
>   net: dsa: Allow DSA and CPU ports to have a phy-mode property
>   dsa: mv88e6xxx: Set the RGMII delay based on phy interface
>   dsa: mv88e6xxx: Don't poll forced interfaces for state changes
>   phy: fixed_phy: Add gpio to determine link up/down.
>   phy: fixed_phy: Set phy capabilities even when link is down
>=20
> Florian Fainelli (1):
>   net: phy: Allow PHY devices to identify themselves as Ethernet
>     switches, etc.
>=20
>  .../devicetree/bindings/net/fixed-link.txt         | 14 ++++-
>  Documentation/networking/stmmac.txt                |  2 +-
>  arch/m68k/coldfire/m5272.c                         |  2 +-
>  arch/mips/ar7/platform.c                           |  5 +-
>  arch/mips/bcm47xx/setup.c                          |  2 +-
>  drivers/net/dsa/mv88e6123_61_65.c                  |  1 +
>  drivers/net/dsa/mv88e6131.c                        |  1 +
>  drivers/net/dsa/mv88e6171.c                        |  1 +
>  drivers/net/dsa/mv88e6352.c                        |  1 +
>  drivers/net/dsa/mv88e6xxx.c                        | 73 ++++++++++++=
++++++++++
>  drivers/net/dsa/mv88e6xxx.h                        |  4 ++
>  drivers/net/ethernet/broadcom/genet/bcmmii.c       |  2 +-
>  drivers/net/phy/fixed_phy.c                        | 45 ++++++++++--=
-
>  drivers/of/of_mdio.c                               | 13 +++-
>  include/linux/phy.h                                | 12 ++++
>  include/linux/phy_fixed.h                          |  8 ++-
>  net/dsa/dsa.c                                      | 43 ++++++++++++=
+
>  17 files changed, 210 insertions(+), 19 deletions(-)
>=20


--=20
=46lorian
