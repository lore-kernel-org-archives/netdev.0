From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] b43: fix memory leak
Date: Thu, 18 Feb 2016 17:32:12 +0100
Message-ID: <20160218173212.03670d97@wiggum>
References: <1455798876-32186-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/N+AMpw_YurTwNNl3eaDOEP0"; protocol="application/pgp-signature"
Cc: Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	b43-dev@lists.infradead.org, Jia-Ju Bai <baijiaju1990@163.com>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455798876-32186-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/N+AMpw_YurTwNNl3eaDOEP0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 18 Feb 2016 18:04:36 +0530
Sudip Mukherjee <sudipm.mukherjee@gmail.com> wrote:

> From: Sudip Mukherjee <sudip@vectorindia.org>
>=20
> On error we jumped to the label bcma_out and returned the error code but
> we missed freeing dev.
>=20
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---
>  drivers/net/wireless/broadcom/b43/main.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/wireless/broadcom/b43/main.c b/drivers/net/wirel=
ess/broadcom/b43/main.c
> index c279211..78f670a 100644
> --- a/drivers/net/wireless/broadcom/b43/main.c
> +++ b/drivers/net/wireless/broadcom/b43/main.c
> @@ -5671,6 +5671,7 @@ static int b43_bcma_probe(struct bcma_device *core)
>  	wl =3D b43_wireless_init(dev);
>  	if (IS_ERR(wl)) {
>  		err =3D PTR_ERR(wl);
> +		kfree(dev);
>  		goto bcma_out;
>  	}
> =20

We recently had a patch that fixes this, among more leaks. Subject:
[PATCH v2 resend] b43: Fix memory leaks in b43_bus_dev_ssb_init and
b43_bus_dev_bcma_init

Please test that patch instead, so we can finally apply it.

It needs to be tested on both ssb and bcma. Come on. This isn't too
hard. :) Please somebody with any hardware test it. (I currently don't
have any b43 hardware)

--=20
Michael

--Sig_/N+AMpw_YurTwNNl3eaDOEP0
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWxfIMAAoJEPUyvh2QjYsOnjoQAJi1ySB/xUc+f1kQXy4LjfjZ
A4GSt/U3ZQzZyZORq6zqCdUTZRUZXq1KerEdeTox9KGu1T13XtKc59PI2b2kYK3C
PwxgtPhpZ2woJ/hnMtDyDNBy8uUTET3zyr2FQ8s8kXeqSrm4Aaj6OVv/t5csmrQd
xlHQ2XuAFc8rzWaJWOqF+T/+sunv9hj2juPCrcI2Onn7MalcHaxPQRzIIuvN9POB
E7ABC9doWzNfI3vJheH9EUoCkDPJua5+J8XVW2ogTsaC2Ao/1J5mhAo3WyTebUyV
40S0ZeyzK8l+6+uhW+NJ2tasMwofK2jRg21BCRwMORbSgRZsjn9eIhqT3k3JwuB4
UGmUz2m6xgQiKX+Wi5wF7CQMTZk4EDC+MVWSM8evgolZPrbNenYO1Bs32ViUSIn7
Hf7+gsMOoJFYNEyzZaANDcfwnoOiumxy/0llAn1bCXuMSd2mlIISFfwb2x2IhqUm
t41k0l65h6t8z/xgh5MVQfDkVI13bmSMGLnfc5qbZF8bUTygsu3bNwR73vZ/wqH4
i3axYq01l3bJ7qlIJhu87H6kl1t18xeQT1VJQt9daoXMnQuTA4YNBBLhBayVsrom
UuvWDGwZh4hBA0u/I/9lh5bvW8DbzIgbSiQ3fRQBcfA9rDafLWkLXuZl3l1xB1bt
bBSqA8EYqZOw8W2CIHum
=Ll4K
-----END PGP SIGNATURE-----

--Sig_/N+AMpw_YurTwNNl3eaDOEP0--
