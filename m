From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [Patch net] wl1251: add a missing spin_lock_init()
Date: Fri, 21 Jul 2017 09:54:07 +0200
Message-ID: <20170721075407.GA21902@amd>
References: <1499378437-4971-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        Kalle Valo <kvalo@codeaurora.org>
To: Cong Wang <xiyou.wangcong@gmail.com>, davem@davemloft.net,
        Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:57460 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752811AbdGUHyJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 03:54:09 -0400
Content-Disposition: inline
In-Reply-To: <1499378437-4971-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

On Thu 2017-07-06 15:00:37, Cong Wang wrote:
> This fixes the following kernel warning:
>=20
>   [ 5668.771453] BUG: spinlock bad magic on CPU#0, kworker/u2:3/9745
>   [ 5668.771850]  lock: 0xce63ef20, .magic: 00000000, .owner: <none>/-1,
>   .owner_cpu: 0
=2E..
> by adding the missing spin_lock_init().
>=20
> Reported-by: Pavel Machek <pavel@ucw.cz>
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Ping? This is pretty trivial bugfix for an ugly problem. It would be
nice to take it in.

>  drivers/net/wireless/ti/wl1251/main.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless=
/ti/wl1251/main.c
> index bbf7604..1c539c8 100644
> --- a/drivers/net/wireless/ti/wl1251/main.c
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

--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAllxsx8ACgkQMOfwapXb+vJshQCgkLqLyYXe1Fo4Ij8SSeXRoqSj
zDoAoLtOo8VH8gUQW+awUbs76hI1W9C8
=Oj7f
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--
