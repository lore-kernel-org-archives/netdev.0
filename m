From: Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>
Subject: Re: Re: [GIT PULL] bcm43xx: Update B6PHY initialization
Date: Wed, 1 Feb 2006 14:55:34 +0100
Message-ID: <200602011455.34307.mbuesch@freenet.de>
References: <43DFFB6C.9050907@gentoo.org> <20060201002101.GA8306@havoc.gtf.org> <200602011051.00973.kugelfang@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart30785045.rlVfY5hh3p";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
   bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Danny van Dyk <kugelfang-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
In-Reply-To: <200602011051.00973.kugelfang-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

--nextPart30785045.rlVfY5hh3p
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 01 February 2006 10:51, Danny van Dyk wrote:
> John, please
>=20
> git pull rsync://pitr.amd64.dev.gentoo.org/kugelfang/wireless-2.6.git
>=20
> which will provide this changeset:
>=20
> Danny van Dyk:
>       [bcm43xx] Sync bcm43xx_phy_initb6() with specs

Danny, _please_ make sure to apply patches to the softmac _and_ the dscape
branch. Otherwise patches will get lost.
It is very important to keep both branches in sync.

I know that this is annoying work, but we must stick with it, until
we have a usable 80211 stack in the kernel.
I also know that 99% of the people are not interrested in the dscape
branch, but it is important to keep it working. The only way to find
weaknesses in d80211 is to maintain drivers which use it.

Besides that, you can also request a pull from me. The git snapshots
are generated from my tree, so this is the fastest way to get your
changes into the snapshots. But that's entirely your decision.

> diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c=20
> b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
> index f5e7a6a..d90f207 100644
> --- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
> @@ -947,7 +947,7 @@ static void bcm43xx_phy_initb6(struct bc
>  	bcm43xx_radio_write16(bcm, 0x0050, 0x0020);
>  	if ((bcm->current_core->radio->manufact =3D=3D 0x17F) &&
>  	    (bcm->current_core->radio->version =3D=3D 0x2050) &&
> -	    (bcm->current_core->radio->revision =3D=3D 2)) {
> +	    (bcm->current_core->radio->revision <=3D 2)) {
>  		bcm43xx_radio_write16(bcm, 0x0050, 0x0020);
>  		bcm43xx_radio_write16(bcm, 0x005A, 0x0070);
>  		bcm43xx_radio_write16(bcm, 0x005B, 0x007B);
> @@ -984,10 +984,15 @@ static void bcm43xx_phy_initb6(struct bc
>  		bcm43xx_write16(bcm, 0x03E4, 0x0009);
>  	if (phy->type =3D=3D BCM43xx_PHYTYPE_B) {
>  		bcm43xx_write16(bcm, 0x03E6, 0x8140);
> -		bcm43xx_phy_write(bcm, 0x0016, 0x5410);
> -		bcm43xx_phy_write(bcm, 0x0017, 0xA820);
> -		bcm43xx_phy_write(bcm, 0x0007, 0x0062);
> -		TODO();//TODO: calibrate stuff.
> +		bcm43xx_phy_write(bcm, 0x0016, 0x0410);
> +		bcm43xx_phy_write(bcm, 0x0017, 0x0820);
> +		bcm43xx_phy_write(bcm, 0x0062, 0x0007);
> +		(void) bcm43xx_radio_calibrationvalue(bcm);
> +		bcm43xx_phy_lo_b_measure(bcm);
> +		if (bcm->sprom.boardflags & BCM43xx_BFL_RSSI) {
> +			bcm43xx_calc_nrssi_slope(bcm);
> +			bcm43xx_calc_nrssi_threshold(bcm);
> +		}
>  		bcm43xx_phy_init_pctl(bcm);
>  	} else
>  		bcm43xx_write16(bcm, 0x03E6, 0x0);
> diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_radio.c=20
> b/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
> index 5ce6ace..3901aa9 100644
> --- a/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
> @@ -1184,7 +1184,7 @@ int bcm43xx_radio_set_interference_mitig
>  	return 0;
>  }
> =20
> -static u16 bcm43xx_radio_calibrationvalue(struct bcm43xx_private *bcm)
> +u16 bcm43xx_radio_calibrationvalue(struct bcm43xx_private *bcm)
>  {
>  	u16 reg, index, ret;
> =20
> diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_radio.h=20
> b/drivers/net/wireless/bcm43xx/bcm43xx_radio.h
> index 89fe292..a5d2e10 100644
> --- a/drivers/net/wireless/bcm43xx/bcm43xx_radio.h
> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_radio.h
> @@ -89,5 +89,6 @@ void bcm43xx_nrssi_hw_update(struct bcm4
>  void bcm43xx_nrssi_mem_update(struct bcm43xx_private *bcm);
> =20
>  void bcm43xx_radio_set_tx_iq(struct bcm43xx_private *bcm);
> +u16 bcm43xx_radio_calibrationvalue(struct bcm43xx_private *bcm);
> =20
>  #endif /* BCM43xx_RADIO_H_ */
> --=20
> Danny van Dyk <kugelfang-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
> Gentoo/AMD64 Project, Gentoo Scientific Project
>=20

=2D-=20
Greetings Michael.

--nextPart30785045.rlVfY5hh3p
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBD4L3Wlb09HEdWDKgRAhtmAKC5rahmB7e7uHSsx6pkxooF+vX4qACeKybT
ItvOAALfP4hcb3b8ohrNAns=
=96IZ
-----END PGP SIGNATURE-----

--nextPart30785045.rlVfY5hh3p--
