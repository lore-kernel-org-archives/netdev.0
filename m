From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [Patch net] wl1251: add a missing spin_lock_init()
Date: Fri, 7 Jul 2017 18:59:17 +0200
Message-ID: <20170707165917.GA14179@amd>
References: <1499378437-4971-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="5mCyUwZo2JvN/JJP"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1499378437-4971-1-git-send-email-xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> This fixes the following kernel warning:
>=20
>   [ 5668.771453] BUG: spinlock bad magic on CPU#0, kworker/u2:3/9745
=2E..
>   [ 5668.777343] [<c06a4f94>] (ieee80211_subif_start_xmit) from
>   [<c0578848>] (dev_hard_start_xmit+0x80/0x118)
>   ...
>=20
> by adding the missing spin_lock_init().
>=20
> Reported-by: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
> Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> Signed-off-by: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Looks very reasonable.

Acked-by: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>

I tried testing it, and resulting kernel works, but even going back to
broken kernel I can't reproduce the problem on demand...

Best regards,
								Pavel

> +++ b/drivers/net/wireless/ti/wl1251/main.c
> @@ -1571,6 +1571,7 @@ struct ieee80211_hw *wl1251_alloc_hw(void)
> =20
>  	wl->state =3D WL1251_STATE_OFF;
>  	mutex_init(&wl->mutex);
> +	spin_lock_init(&wl->wl_lock);
> =20
>  	wl->tx_mgmt_frm_rate =3D DEFAULT_HW_GEN_TX_RATE;
>  	wl->tx_mgmt_frm_mod =3D DEFAULT_HW_GEN_MODULATION_TYPE;

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAllfveUACgkQMOfwapXb+vLW7gCfdyCsZKPRytciLgFwu8s800n6
mXIAoJsQFneQIERNXrID507oRP3hGCV4
=OJa0
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--
