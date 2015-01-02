From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] drivers:net:wireless: Add proper locking for the
 function, b43_op_beacon_set_tim in main.c
Date: Fri, 2 Jan 2015 10:27:27 +0100
Message-ID: <20150102102727.3918a684@wiggum>
References: <1420184041-6788-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/4=3cVwV.+4XCgS2Xp2Vl//c"; protocol="application/pgp-signature"
Cc: stefano.brivio@polimi.it, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	kvalo@codeaurora.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420184041-6788-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/4=3cVwV.+4XCgS2Xp2Vl//c
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri,  2 Jan 2015 02:34:01 -0500
Nicholas Krause <xerofoify@gmail.com> wrote:

> This adds proper locking for the function, b43_op_beacon_set_tim in main.=
c by using the mutex lock
> in the structure pointer wl, as embedded into this pointer as a mutex in =
order to protect against
> multiple access to the pointer wl when updating the templates for this po=
inter in the function,
> b43_update_templates internally in the function, b43_op_beacon_set_tim.
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/wireless/b43/main.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/m=
ain.c
> index 47731cb..d568fc8 100644
> --- a/drivers/net/wireless/b43/main.c
> +++ b/drivers/net/wireless/b43/main.c
> @@ -5094,8 +5094,9 @@ static int b43_op_beacon_set_tim(struct ieee80211_h=
w *hw,
>  {
>  	struct b43_wl *wl =3D hw_to_b43_wl(hw);
> =20
> -	/* FIXME: add locking */
> +	mutex_lock(&wl->mutex);
>  	b43_update_templates(wl);
> +	mutex_unlock(&wl->mutex);
> =20
>  	return 0;
>  }

Thanks for the patch.

However, this does not work. We are in atomic context here.
Please see the b43-dev mailing list archives for a recent thread about that.
I'm also pretty sure that this is safe without lock, due to the higher leve=
l locks in mac80211.

--=20
Michael

--Sig_/4=3cVwV.+4XCgS2Xp2Vl//c
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUpmR/AAoJEPUyvh2QjYsO9HMP/1grj8MIOkjcTxNQzX5aAiY4
zjYNw3NRpUq8s874oflk5gZ2Lnahg57fyjvN3uRyG+1wIlSgwi5dz+tw1+Z+RbEf
fq+cNMbsbYTRIaQ2wIdzDi49iwuMcSshkYstxcuJIqDjYM90hkSCLE8hzkNFVeHL
rqCqYTacbv8cnLyY9s+vr3/fNUfq+AtSphgb+DgwPzZMHr4xYNZHA7W+jwn+B2D+
4PDMBptkY0lnMzsWwdmfJ+/wR1QGTgxkBPMmiH+FtJv9XNTOW4XL6ziIWZzCzqXJ
GhMDNHraNAenUweClnFfAikBJao5YTn8bHiwpAZy1VUDAxIsygcc+E6q58Lzh66F
oUEC0ORpnN9Y7IIR8lAr5BokoREuNODrckABUts+g/f5alq+75KsvK4NZYdypqOH
e7no7waxTtEyb3cYObFZzXsIZUR+wwruILflSWYsXXimovtJEGXCNYDeC1txS4s7
c0lD/tmIUNNljo8nr7Uo0JxEl30WzZaAgpeQNhzChXKDj/oP/Erotnn1ok3Jk2Sr
3z4cn2PgEQAHqO9XwK+GAsO8lN6Uflmpbbi4ZHd1IhcrdvJELseOgbX7TffuJsTg
uEANa/7kHM9lBhgCMo4R/OzXRV2P6j8m5eh5q9YMbZo0ueYCHNKud0LIfFEzbcBm
tOgsxphhcUUPbU2ItbzG
=Pn1c
-----END PGP SIGNATURE-----

--Sig_/4=3cVwV.+4XCgS2Xp2Vl//c--
