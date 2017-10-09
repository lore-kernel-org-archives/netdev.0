From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v1 RFC 6/7] Add MIB counter reading support
Date: Mon, 9 Oct 2017 21:54:43 +0200
Message-ID: <20171009195443.GF9866@amd>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
 <1507321985-15097-7-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="XIiC+We3v3zHqZ6Z"
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>,
        muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507321985-15097-7-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--XIiC+We3v3zHqZ6Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> From: Tristram Ha <Tristram.Ha@microchip.com>
>=20
> Add MIB counter reading support.
> Rename ksz_9477_reg.h to ksz9477_reg.h for consistency as the product
> name is always KSZ####.
> Header file ksz_priv.h no longer contains any chip specific data.

Nothing obviously wrong here, but if you are doing another iteration,
it would be nice to separate "Rename ksz_9477_reg.h to ksz9477_reg.h"
=66rom the code changes.

Best regards,

> +	timeout =3D 1000;
> +	do {
> +		ksz_pread32(dev, port, REG_PORT_MIB_CTRL_STAT__4,
> +			    &data);
> +		usleep_range(1, 10);
> +		if (!(data & MIB_COUNTER_READ))
> +			break;
> +	} while (timeout-- > 0);

1000 iterations, 1usec each, so 1msec, but you allow up to 10 msec. Interes=
ting.

> +	/* failed to read MIB. get out of loop */
> +	if (!timeout) {
> +		dev_dbg(dev->dev, "Failed to get MIB\n");
> +		return;
> +	}

Are you sure this works? AFAICT "timeout" will underflow, so !timeout
will not trigger.


> -static void ksz_get_ethtool_stats(struct dsa_switch *ds, int port,
> -				  uint64_t *buf)
> -{
> -	struct ksz_device *dev =3D ds->priv;
> -	int i;
> -	u32 data;
> -	int timeout;
> -
> -	mutex_lock(&dev->stats_mutex);
> -
> -	for (i =3D 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
> -		data =3D MIB_COUNTER_READ;
> -		data |=3D ((mib_names[i].index & 0xFF) << MIB_COUNTER_INDEX_S);
> -		ksz_pwrite32(dev, port, REG_PORT_MIB_CTRL_STAT__4, data);
> -
> -		timeout =3D 1000;
> -		do {
> -			ksz_pread32(dev, port, REG_PORT_MIB_CTRL_STAT__4,
> -				    &data);
> -			usleep_range(1, 10);
> -			if (!(data & MIB_COUNTER_READ))
> -				break;
> -		} while (timeout-- > 0);
> -
> -		/* failed to read MIB. get out of loop */
> -		if (!timeout) {
> -			dev_dbg(dev->dev, "Failed to get MIB\n");
> -			break;
> -		}

Hmm. Bug was there already...
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--XIiC+We3v3zHqZ6Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnb1AMACgkQMOfwapXb+vJixwCfWl0/5e/tow6w4ix5k62Ik26E
ox0An0eOOn3++32geT6CqYMrVMVDeyhA
=t3/T
-----END PGP SIGNATURE-----

--XIiC+We3v3zHqZ6Z--
