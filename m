From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v6 05/21] net-next: stmmac: Add dwmac-sun8i
Date: Tue, 27 Jun 2017 10:05:29 +0200
Message-ID: <20170627080529.GA2468@Red>
References: <20170531071852.12422-1-clabbe.montjoie@gmail.com>
 <20170531071852.12422-6-clabbe.montjoie@gmail.com>
 <8e3d73a7-e9ff-d3e2-4bce-bcc79cdf86db@arm.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
To: =?iso-8859-1?Q?Andr=E9?= Przywara <andre.przywara-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-sunxi+bncBD7YLCN32UNBBTVDZDFAKGQEZIP25TA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <8e3d73a7-e9ff-d3e2-4bce-bcc79cdf86db-5wv7dgnIgG8@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Mon, Jun 26, 2017 at 01:18:23AM +0100, Andr=C3=A9 Przywara wrote:
> On 31/05/17 08:18, Corentin Labbe wrote:
> > The dwmac-sun8i is a heavy hacked version of stmmac hardware by
> > allwinner.
> > In fact the only common part is the descriptor management and the first
> > register function.
>=20
> Hi,
>=20
> I know I am a bit late with this, but while adapting the U-Boot driver
> to the new binding I was wondering about the internal PHY detection:
>=20
>=20
> So here you seem to deduce the usage of the internal PHY by the PHY
> interface specified in the DT (MII =3D internal, RGMII =3D external).
> I think I raised this question before, but isn't it perfectly legal for
> a board to use MII with an external PHY even on those SoCs that feature
> an internal PHY?
> On the first glance that does not make too much sense, but apart from
> not being the correct binding to describe all of the SoCs features I see
> two scenarios:
> 1) A board vendor might choose to not use the internal PHY because it
> has bugs, lacks features (configurability) or has other issues. For
> instance I have heard reports that the internal PHY makes the SoC go
> rather hot, possibly limiting the CPU frequency. By using an external
> MII PHY (which are still cheaper than RGMII PHYs) this can be avoided.
> 2) A PHY does not necessarily need to be directly connected to
> magnetics. Indeed quite some boards use (RG)MII to connect to a switch
> IC or some other network circuitry, for instance fibre connectors.
>=20
> So I was wondering if we would need an explicit:
> 	allwinner,use-internal-phy;
> boolean DT property to signal the usage of the internal PHY?
> Alternatively we could go with the negative version:
> 	allwinner,disable-internal-phy;
>=20
> Or what about introducing a new "allwinner,internal-mii-phy" compatible
> string for the *PHY* node and use that?
>=20
> I just want to avoid that we introduce a binding that causes us
> headaches later. I think we can still fix this with a followup patch
> before the driver and its binding hit a release kernel.
>=20
> Cheers,
> Andre.
>=20

I just see some patch, where "phy-mode =3D internal" is valid.
I will try to find a way to use it

Regards

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
