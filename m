From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2 net-next] net: fec: Ensure clocks are enabled while
 using mdio bus
Date: Sun, 21 Jun 2015 22:15:02 +0200
Message-ID: <20150621201502.GD12665@lunn.ch>
References: <1434816914-9816-1-git-send-email-andrew@lunn.ch>
 <55860CED.2070307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Duan Andy <fugang.duan@freescale.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56237 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752538AbbFUUU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2015 16:20:59 -0400
Content-Disposition: inline
In-Reply-To: <55860CED.2070307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 20, 2015 at 06:01:33PM -0700, Florian Fainelli wrote:
> Le 06/20/15 09:15, Andrew Lunn a =E9crit :
> > When a switch is attached to the mdio bus, the mdio bus can be used
> > while the interface is not open. If the IPG clock are not enabled,
> > MDIO reads/writes will simply time out. So enable the clock before
> > starting a transaction, and disable it afterwards. The CCF performs
> > reference counting so the clock will only be disabled if there are =
no
> > other users.
> >=20
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > ---
> > v2:
> >   Only enable/disable the IPG clock.
> >=20
> > drivers/net/ethernet/freescale/fec_main.c | 21 +++++++++++++++++++-=
-
> >  1 file changed, 19 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/ne=
t/ethernet/freescale/fec_main.c
> > index bf4cf3fbb5f2..2b8a043a573c 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -65,6 +65,7 @@
> > =20
> >  static void set_multicast_list(struct net_device *ndev);
> >  static void fec_enet_itr_coal_init(struct net_device *ndev);
> > +static int fec_enet_clk_enable(struct net_device *ndev, bool enabl=
e);
>=20
> You do not seem to be using this, unrelated change?

Hi Florian

Left over from v1, where i did call this function to enable/disable
the clocks. It can be removed now that i use the common clock
framework directly to enable only a single clock.

	  Andrew
