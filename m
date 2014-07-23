From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 2/2] net: phy: Ensure the MDIO bus module is held
Date: Wed, 23 Jul 2014 15:40:41 -0300
Message-ID: <20140723184041.GA24850@arch.cereza>
References: <1406074570-13246-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1406074570-13246-3-git-send-email-ezequiel.garcia@free-electrons.com>
 <CAGVrzcarnqLRnr97FRB-GVKwQLebpYtV7DXHp2ZTmm1gVfY30Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:43066 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932697AbaGWSll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 14:41:41 -0400
Content-Disposition: inline
In-Reply-To: <CAGVrzcarnqLRnr97FRB-GVKwQLebpYtV7DXHp2ZTmm1gVfY30Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23 Jul 11:22 AM, Florian Fainelli wrote:
> 2014-07-22 17:16 GMT-07:00 Ezequiel Garcia <ezequiel.garcia@free-elec=
trons.com>:
> > @@ -614,10 +623,14 @@ int phy_attach_direct(struct net_device *dev,=
 struct phy_device *phydev,
> >          */
> >         err =3D phy_init_hw(phydev);
> >         if (err)
> > -               phy_detach(phydev);
> > -       else
> > -               phy_resume(phydev);
> > +               goto err_module_put;
> >
> > +       phy_resume(phydev);
> > +       return err;
> > +
> > +err_module_put:
> > +       module_put(bus_module);
> > +       phy_detach(phydev);
>=20
> Since we are calling phy_detach() which is also attempting to do a
> module_put(), does not that result in one too many calls to
> module_put() on error path?
>=20

As far as I can see all that module_get() and module_put() do
is increment and decrement refcounters. Therefore, I think you can
have as many module_{get,put}() calls as you want on a path.
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
