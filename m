From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/2] r6040: fix multicast operations
Date: Tue, 26 Oct 2010 15:02:10 +0100
Message-ID: <20101026140209.GY13095@decadent.org.uk>
References: <201010202309.43812.florian@openwrt.org> <1287629751.20865.220.camel@localhost> <1287649654.1792.98.camel@shawn-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="aMDdG8xNveJz2ruI"
Cc: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org,
	Marc Leclerc <marc-leclerc@signaturealpha.com>,
	Albert Chen <albert.chen@rdc.com.tw>,
	David Miller <davem@davemloft.net>
To: Shawn Lin <shawn@dmp.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60545 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757937Ab0JZOCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 10:02:31 -0400
Content-Disposition: inline
In-Reply-To: <1287649654.1792.98.camel@shawn-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--aMDdG8xNveJz2ruI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 21, 2010 at 04:27:34PM +0800, Shawn Lin wrote:
[...]
> > > +	/* Use internal multicast address registers
> > > +	 * if the number of multicast addresses is not greater than MCAST_M=
AX.
> > > +	 */
> > > +	else if (netdev_mc_empty(dev)) {
> > > +		for (i =3D 0; i < MCAST_MAX ; i++) {
> > > +			iowrite16(0, ioaddr + MID_1L + 8 * i);
> > > +			iowrite16(0, ioaddr + MID_1M + 8 * i);
> > > +			iowrite16(0, ioaddr + MID_1H + 8 * i);
> > > +		}
> > > +	} else if (netdev_mc_count(dev) <=3D MCAST_MAX) {
> > > +		i =3D 0;
> > > +		netdev_for_each_mc_addr(ha, dev) {
> > > +			adrp =3D (u16 *) ha->addr;
> > > +			iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
> > > +			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
> > > +			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
> > > +			i++;
> > > +		}
> >=20
> > What about the unused exact match entries?  And why is the empty case
> > special?
>=20
> Unused exact match entries? I am not sure which entries are you
> mentioned.

If there are 1 or 2 addresses in the multicast list then some of the
exact match entries will be used and some will not.  But the loop
above does not clear the unused entries.

[...]
> 2) if (netdev_mc_count(dev) <=3D 3)
> There are two hardware features could be used to filter multicast
> frames:
[...]
> 3) if (netdev_mc_empty(dev))
> because we masked the multicast hash table flag before examine all
> conditions, we only need to clear the addresses in the three
> MAC/Multicast registers.
[...]

But why is this so different from the case of 1-3 addresses?  I would
write these two cases as:

else if (netdev_mc_count(dev) <=3D MCAST_MAX) {
	i =3D 0;
	netdev_for_each_mc_addr(ha, dev) {
		adrp =3D (u16 *) ha->addr;
		iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
		iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
		iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
		i++;
	}
	while (i < MCAST_MAX) {
		iowrite16(0, ioaddr + MID_1L + 8 * i);
		iowrite16(0, ioaddr + MID_1M + 8 * i);
		iowrite16(0, ioaddr + MID_1H + 8 * i);
		i++;
	}
}=20

Ben.

--=20
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus

--aMDdG8xNveJz2ruI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iQIVAwUBTMbfX+e/yOyVhhEJAQr8yhAAqFcaGIn2bZ1cSAi49sHaBabvzOHKEc8g
ZYsIli7MZaWZbr+YEWzTwdvetM9Rv8lcPNgTpyGP4oKNz7DHqt3zagfn9b9U9ovZ
votb4booCRd8EQ1u9HNtUQXBd1rTnuruC2xYdYwb8xXgzWu1cw0QG5hw7wRDUwWj
lWVW/V7vsMnWtuCXCvMmm2PXfzh8EsnOVDE02hcAbtU0au9KBhPM2rt/tPGY2KE5
B8tofKKGIN2G4Fwo9euGCd6FxQHIliQBkLCUUZaXdB4eViJZYCRX7/McfmPketoi
sOrCV1YpYL7ujjNRvV9NFAo4OdGgt9ln178x2+lvpF7+Bm5VzQqa15uia1ieNxd5
+Rdx42I6VXBS/KZmFnDNydiVnaC00rne9ui7rCwS5mPMRl6BtS8Qb9tpGeplMSkG
QKFChtjuHZuianQlX+0p+carxUtOMtv/tvFPiTRe6wGrY3vhSpASuCA/GeSajlE7
gAfg8q9Btmm+DZGcPPHoGrX1sRYjTkh73BrelrdRxmK8b66YRgcE6vR4W31oytCi
NlFcbgGdD3hX0iYCCAB5hhlEpmyWSZ0fHQsJFOOIM66v3YnKnjljoyv9HV0ZjdRF
jvFLGDUdCXHjYlRSvGtOLX5xu2zCeCzLYyr/93l9q1VwHlB6Hda4dbvR6sDQQQf9
74yWTgbFbzY=
=5gWI
-----END PGP SIGNATURE-----

--aMDdG8xNveJz2ruI--
