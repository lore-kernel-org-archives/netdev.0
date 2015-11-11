From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: kasan r8169 use-after-free trace.
Date: Wed, 11 Nov 2015 16:34:42 +0100
Message-ID: <20151111153442.GA10494@calimero.vinschen.de>
References: <20151111033028.GA25018@codemonkey.org.uk>
 <20151111091928.GA14531@electric-eye.fr.zoreil.com>
 <1447247781.17135.95.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="vtzGhvizbBRQ85DL"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Dave Jones <davej@codemonkey.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:60650 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbbKKQAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 11:00:54 -0500
Content-Disposition: inline
In-Reply-To: <1447247781.17135.95.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Nov 11 05:16, Eric Dumazet wrote:
> On Wed, 2015-11-11 at 10:19 +0100, Francois Romieu wrote:
> > Dave Jones <davej@codemonkey.org.uk> :
> > > This happens during boot, (and then there's a flood of traces that ha=
ppen so fast
> > > afterwards it completely overwhelms serial console; not sure if they'=
re the
> > > same/related or not).
> > >=20
> > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > BUG: KASAN: use-after-free in rtl8169_poll+0x4b6/0xb70 at addr ffff88=
01d43b3288
> > > Read of size 1 by task kworker/0:3/188
> > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
> > > BUG kmalloc-256 (Not tainted): kasan: bad access detected
> > > ---------------------------------------------------------------------=
--------
> > >=20
> > > Disabling lock debugging due to kernel taint
> > > INFO: Slab 0xffffea000750ecc0 objects=3D16 used=3D16 fp=3D0x         =
 (null) flags=3D0x8000000000000080
> > > INFO: Object 0xffff8801d43b3200 @offset=3D512 fp=3D0xffff8801d43b3800
> > >=20
> > > Bytes b4 ffff8801d43b31f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 =
00 00  ................
> > > Object ffff8801d43b3200: 00 38 3b d4 01 88 ff ff 00 00 00 00 00 00 00=
 00  .8;.............
> >=20
> > Does the patch below cure it ?
> >=20
> > diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
> > index b4f2123..79ef799 100644
> > --- a/drivers/net/ethernet/realtek/r8169.c
> > +++ b/drivers/net/ethernet/realtek/r8169.c
> > @@ -7429,15 +7429,15 @@ process_pkt:
> > =20
> >  			rtl8169_rx_vlan_tag(desc, skb);
> > =20
> > +			if (skb->pkt_type =3D=3D PACKET_MULTICAST)
> > +				dev->stats.multicast++;
> > +
> >  			napi_gro_receive(&tp->napi, skb);
> > =20
> >  			u64_stats_update_begin(&tp->rx_stats.syncp);
> >  			tp->rx_stats.packets++;
> >  			tp->rx_stats.bytes +=3D pkt_size;
> >  			u64_stats_update_end(&tp->rx_stats.syncp);
> > -
> > -			if (skb->pkt_type =3D=3D PACKET_MULTICAST)
> > -				dev->stats.multicast++;
> >  		}
> >  release_descriptor:
> >  		desc->opts2 =3D 0;
>=20
> This looks obvious indeed, please submit this formally Francois ;)

Yes, please.  Thank you Francois.


> Fixes: d7d2d89d4b0af ("r8169: Add software counter for multicast packages=
")
> Acked-by: Eric Dumazet <edumazet@google.com>

Acked-by: Corinna Vinschen <vinschen@redhat.com>


Corinna

--vtzGhvizbBRQ85DL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWQ2ASAAoJEPU2Bp2uRE+gMg8QAI/QQBttHecCrb8609ndhmyQ
i5UpswrjL1nPH8V0lz6bApd2VYOdRBSsUSzIUVrZob6xkYjh2Am3VmCLpvt66qg5
HEGDoIjerCRxcuiR2rVSqpiOU5e7wiGMxmR6bfrE99ZniZfj4zBt+5sewCFoci67
RDElzfvRXeCAoiNv/AgfE9Ahg7uCWHLkeuNYXnzs5FplpqqPzISqrX7BSK/TDqOo
ocDMLuT009vR0c7lG3vMHpy29XVZ6JBi3bBQDJwz505OghkgBDuRvOo2Wq5nAAtf
51dALWWGnbaoUJoaOSFxT8QMQwvVSB7fkaeAxS8G+BSfHV9aDCRg5wqaBJ5Dtxtb
1aReF3uNAuQkYEbHv3mvAkU1hJsPlChaEpRCCq1NSdStcSGoNGAWqkR4XRtcFtFx
d9DBCIKPqMSD34L+SwnfgbSWMQ6+NqR9FE+1MAsJjgJdvD0sMtgMobdO6CFvYva5
QxTEpDqIrRTBSEXYS1PE+nmU1nH9pVG5EFWsSIdQGzsUj7d1e37VLka9cCHr2r5Q
+Xel2joFq7lDZCTN4iW6s/mfItGFjEJ+Vx0KfoiV1qsVcYBxi53sAzE0CNfXcLyi
jy+Dze04SefmIEMzos4R69IZ6/VZ1m0P7qC1eq7d/gHPvKrR2yCY30fpozcHz2LX
pTyxxSVrW16Wxf33M6HZ
=vQVs
-----END PGP SIGNATURE-----

--vtzGhvizbBRQ85DL--
