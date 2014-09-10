From: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2 4/8] net: pxa168_eth: fix Ethernet flow control status
Date: Wed, 10 Sep 2014 19:44:52 +0200
Message-ID: <20140910174452.GB27983@kwain>
References: <1410273848-24663-1-git-send-email-antoine.tenart@free-electrons.com>
 <1410273848-24663-5-git-send-email-antoine.tenart@free-electrons.com>
 <20140910153902.GE13342@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, zmxu-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140910153902.GE13342-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andrew,

On Wed, Sep 10, 2014 at 05:39:02PM +0200, Andrew Lunn wrote:
> On Tue, Sep 09, 2014 at 04:44:04PM +0200, Antoine Tenart wrote:
> > IEEE 802.3x Ethernet flow control is disabled when bit (1 << 2) is =
set
> > in the port status register. Fix the flow control detection in the =
link
> > event handling function which was relying on the opposite assumptio=
n.
> >=20
> > Signed-off-by: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> > ---
> >  drivers/net/ethernet/marvell/pxa168_eth.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/ne=
t/ethernet/marvell/pxa168_eth.c
> > index 953112f87c5f..10422f2df6cc 100644
> > --- a/drivers/net/ethernet/marvell/pxa168_eth.c
> > +++ b/drivers/net/ethernet/marvell/pxa168_eth.c
> > @@ -163,7 +163,7 @@
> >  /* Bit definitions for Port status */
> >  #define PORT_SPEED_100		(1 << 0)
> >  #define FULL_DUPLEX		(1 << 1)
> > -#define FLOW_CONTROL_ENABLED	(1 << 2)
> > +#define FLOW_CONTROL_DISABLED	(1 << 2)
> >  #define LINK_UP			(1 << 3)
> > =20
> >  /* Bit definitions for work to be done */
> > @@ -885,7 +885,7 @@ static void handle_link_event(struct pxa168_eth=
_private *pep)
> >  		speed =3D 10;
> > =20
> >  	duplex =3D (port_status & FULL_DUPLEX) ? 1 : 0;
> > -	fc =3D (port_status & FLOW_CONTROL_ENABLED) ? 1 : 0;
> > +	fc =3D (port_status & FLOW_CONTROL_DISABLED) ? 0 : 1;
> >  	netdev_info(dev, "link up, %d Mb/s, %s duplex, flow control %sabl=
ed\n",
> >  		    speed, duplex ? "full" : "half", fc ? "en" : "dis");
> >  	if (!netif_carrier_ok(dev))
>=20
> Could this be a hardware bug which has been fixed in a newer version
> of the IP? It would be good to have this tested on an old platform
> using this driver.

This driver seems to be used by the pxa168 GuruPlug board, and accordin=
g
to the pxa168 datasheet the flow control status is reported as above (I
checked before sending this patch). I used the software manual
referenced in Documentation/arm/Marvell/README.

This is also the case for the Ethernet controller of the Berlin SoCs.

I could only test on the Berlin BG2Q. I can't be sure this was not a
hardware bug, but at least this is consistent with the pxa168 platform
using the driver. All other registers controlling this flow control
capability also enable on 0.

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
