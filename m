From: =?iso-8859-1?q?J=E9r=F4me_Pouiller?= <j.pouiller@sysmic.fr>
Subject: Re: Nested function in drivers/of/of_mdio.c
Date: Thu, 8 Oct 2009 10:45:12 +0200
Message-ID: <200910081045.12590.j.pouiller@sysmic.fr>
References: <200910071715.57249.jezz@sysmic.org> <fa686aa40910070911x769d7d41u908fbcf6b0980962@mail.gmail.com> <f608b67d0910070923h54c30c2doae08550b0791ed1b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Andy Fleming <afleming@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
To: linuxppc-dev@lists.ozlabs.org,
	Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sysmic.org ([88.191.45.54]:43313 "EHLO draco.sysmic.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228AbZJHI4o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 04:56:44 -0400
In-Reply-To: <f608b67d0910070923h54c30c2doae08550b0791ed1b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did some grep on codebase. I have not found any other instances of=20
nested functions, but my regexps are not enough to be 100% sure.

On Wednesday 07 October 2009 18:23:04 vb@vsbe.com wrote:
> Guys, are there other instances of nested C functions in the codebase
> or was this the first attempt?
>=20
> On Wed, Oct 7, 2009 at 9:11 AM, Grant Likely=20
<grant.likely@secretlab.ca> wrote:
> > On Wed, Oct 7, 2009 at 9:15 AM, J=E9r=F4me Pouiller <jezz@sysmic.or=
g>=20
wrote:
> >> Dear,
> >>
> >> I have a problem with commit
> >> 8bc487d150b939e69830c39322df4ee486efe381 in file
> >> drivers/of/of_mdio.c in function of_phy_find_device.
> >>
> >> As you see, this function define match() as a nested function. My
> >> compiler (powerpc-e500-linux-gnu-gcc-3.4.1) raise an error during
> >> link due to this nested definition:
> >>  drivers/built-in.o(.text+0x5e2a4): In function
> >> `of_phy_find_device':
> >> /home/jezz/linux-next/drivers/of/of_mdio.c:107: undefined
> >> reference to `__trampoline_setup'
> >>
> >> I am sure I could solve problem by rebuilding my toolchain.
> >> Nevertheless, I think nested function definition is not perfectly
> >> supported by all compilers. Also, I suggest to place function
> >> match() outside of scope of of_phy_find_device as in following
> >> patch.
> >
> > I'm okay with that, but if you're moving code out of the file
> > scope, then please rename the function to of_phy_match() to avoid
> > global namespace conflicts.
> >
> > g.
> >
> >> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> >> index bacaa53..c7b2e26 100644
> >> --- a/drivers/of/of_mdio.c
> >> +++ b/drivers/of/of_mdio.c
> >> @@ -97,6 +97,10 @@ int of_mdiobus_register(struct mii_bus *mdio,
> >> struct device_node *np) }
> >>  EXPORT_SYMBOL(of_mdiobus_register);
> >>
> >> +static int match(struct device *dev, void *phy_np)
> >> +{
> >> +       return dev_archdata_get_node(&dev->archdata) =3D=3D phy_np=
;
> >> +}
> >>  /**
> >>  * of_phy_find_device - Give a PHY node, find the phy_device
> >>  * @phy_np: Pointer to the phy's device tree node
> >> @@ -106,11 +110,6 @@ EXPORT_SYMBOL(of_mdiobus_register);
> >>  struct phy_device *of_phy_find_device(struct device_node *phy_np)
> >>  {
> >>        struct device *d;
> >> -       int match(struct device *dev, void *phy_np)
> >> -       {
> >> -               return dev_archdata_get_node(&dev->archdata) =3D=3D
> >> phy_np; -       }
> >> -
> >>        if (!phy_np)
> >>                return NULL;
> >>
> >>
> >> What do you think about it?
> >>
> >> Best regards,
> >>
> >> --
> >> J=E9r=F4me Pouiller (jezz AT sysmic DOT org)
> >
> > --
> > Grant Likely, B.Sc., P.Eng.
> > Secret Lab Technologies Ltd.
> > _______________________________________________
> > Linuxppc-dev mailing list
> > Linuxppc-dev@lists.ozlabs.org
> > https://lists.ozlabs.org/listinfo/linuxppc-dev
>=20
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
>=20

--=20
J=E9r=F4me Pouiller (jerome AT sysmic DOT org)
Expert Linux Embarqu=E9
