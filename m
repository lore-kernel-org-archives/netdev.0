From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] ssb: pci: Fix flipping of MAC address
Date: Wed, 13 Mar 2013 14:18:18 -0400
Message-ID: <20130313181817.GB19917@tuxdriver.com>
References: <513e40c2.MDaC+Q82iTl9PpIZ%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: b43-dev@lists.infradead.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, zajec5@gmail.com
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51882 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932346Ab3CMSae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 14:30:34 -0400
Content-Disposition: inline
In-Reply-To: <513e40c2.MDaC+Q82iTl9PpIZ%Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 11, 2013 at 03:38:26PM -0500, Larry Finger wrote:
> Since commit e565275 entitled "ssb: pci: Standardize a function to ge=
t mac
> address", the SPROM readout of the MAC has had the values flipped so =
that
> 00:11:22:33:44:55 became 11:00:33:22:55:44. The fix has been tested o=
n both
> little- and big-endian architectures.
>=20
> Reported-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>=20
> John,
>=20
> This bug was introduced in 3.9, and should be fixed there.
>=20
> Thanks,
>=20
> Larry
> ---
>=20
> Index: wireless-testing-new/drivers/ssb/pci.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- wireless-testing-new.orig/drivers/ssb/pci.c
> +++ wireless-testing-new/drivers/ssb/pci.c
> @@ -234,8 +234,8 @@ static void sprom_get_mac(char *mac, con
>  {
>  	int i;
>  	for (i =3D 0; i < 3; i++) {
> -		*mac++ =3D in[i];
>  		*mac++ =3D in[i] >> 8;
> +		*mac++ =3D in[i];
>  	}
>  }

Actually, FWIW it seems to have been introduced in commit
e5652756ff36ed9e1283121f788e6a17117efcab, which is slated for 3.10.
I'm happy to merge it in wireless-next.

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
