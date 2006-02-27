From: Ian Kumlien <pomac@vapor.com>
Subject: Re: [PATCH] Revert sky2 to 0.13a
Date: Mon, 27 Feb 2006 19:27:21 +0100
Message-ID: <1141064841.23375.36.camel@localhost>
References: <4400FC28.1060705@gmx.net> <200602270003.46353.woho@woho.de>
	 <20060227080042.0cf3f05d@localhost.localdomain>
	 <200602271738.38675.woho@woho.de>
	 <20060227091837.3c214435@localhost.localdomain>
Reply-To: pomac@vapor.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-abOhmutKglUVrWgsVTtL"
Cc: woho@woho.de,
	Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Pavel Volkovitskiy <int@mtx.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751439AbWB0S1L@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060227091837.3c214435@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-abOhmutKglUVrWgsVTtL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-02-27 at 09:18 -0800, Stephen Hemminger wrote:
> On Mon, 27 Feb 2006 17:38:38 +0100
> Wolfgang Hoffmann <woho@woho.de> wrote:
> > On Monday 27 February 2006 17:00, Stephen Hemminger wrote:
> > 2.6.16-rc5 with disable_msi=3D1 works for me, no hangs seen so far. I r=
synced 80=20
> > GB of data, thats about 5-10 times more than I typically need to reprod=
uce a=20
> > hang, so it seems to be solid. For the record: 2.6.16-rc5 with disable_=
msi=3D0=20
> > does hang.
> >=20
> > I have not seen the memory trashing others reported, with no version I =
tested=20
> > so far. Maybe my scenario is not likely to trigger this, so I can't tel=
l.
> >=20
> > Unless a fix for msi is at hand, may I suggest for 2.6.16 to revert the=
 msi=20
> > commit or switch the default to disable_msi=3D1?
> >=20
> > I've updated bugzilla #6084 accordingly.
>=20
> Okay, then what I need is lspci -v of all systems that have the problem, =
I'll make
> a blacklist (or update PCI quirks). I suspect that MSI doesn't work for a=
ny devices
> on these systems, or MSI changes the timing enough to expose existing rac=
es.

Am i just tired from trying to make XSLT to do something unnatural or is
there something odd going on in msi.c?

static void msi_set_mask_bit(unsigned int vector, int flag)
{
        struct msi_desc *entry;

        entry =3D (struct msi_desc *)msi_desc[vector];
        if (!entry || !entry->dev || !entry->mask_base)
                return;
        switch (entry->msi_attrib.type) {
        case PCI_CAP_ID_MSI:
        {
                int             pos;		<=3D=3D
                u32             mask_bits;

                pos =3D (long)entry->mask_base;	<=3D=3D
...

Doesn't that mean that we, a: read 64 bit from memory. b: save it in a
32 bit area?

(esp since it seems to be a address pointer, which could also be using
higher memory areas... but then i dunno what a void __iomem * is, but i
assume that it will be 64 bits here =3D))

--=20
Ian Kumlien <pomac () vapor ! com> -- http://pomac.netswarm.net

--=-abOhmutKglUVrWgsVTtL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.1-ecc0.1.6 (GNU/Linux)

iD8DBQBEA0SJ7F3Euyc51N8RArYzAKCWSgcdnJ+sAP/+0+itzllaOFI3SQCgrW/1
C7DwGr6NIZnK/AoX1x7e4x0=
=2ZhW
-----END PGP SIGNATURE-----

--=-abOhmutKglUVrWgsVTtL--
