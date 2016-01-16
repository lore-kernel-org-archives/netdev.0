From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH v2 resend] b43: Fix memory leaks in b43_bus_dev_ssb_init
 and b43_bus_dev_bcma_init
Date: Sat, 16 Jan 2016 14:13:21 +0100
Message-ID: <20160116141321.6e0d5a87@wiggum>
References: <1452949690-16387-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3524865623587545751=="
Cc: johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
To: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1452949690-16387-1-git-send-email-baijiaju1990-9Onoh4P/yGk@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "b43-dev" <b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============3524865623587545751==
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/pwNbvm.p9A+nzCmrdN.7qZW"; protocol="application/pgp-signature"

--Sig_/pwNbvm.p9A+nzCmrdN.7qZW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 16 Jan 2016 21:08:10 +0800
Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org> wrote:

> The memory allocated by kzalloc in b43_bus_dev_ssb_init and
> b43_bus_dev_bcma_init is not freed.
> This patch fixes the bug by adding kfree in b43_ssb_remove,
> b43_bcma_remove and error handling code of b43_bcma_probe.
>=20
> Thanks Michael for his suggestion.
>=20
> Signed-off-by: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
> ---
>  drivers/net/wireless/b43/main.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/m=
ain.c
> index ec013fb..bbea769 100644
> --- a/drivers/net/wireless/b43/main.c
> +++ b/drivers/net/wireless/b43/main.c
> @@ -5682,11 +5682,12 @@ static int b43_bcma_probe(struct bcma_device *cor=
e)
>  	INIT_WORK(&wl->firmware_load, b43_request_firmware);
>  	schedule_work(&wl->firmware_load);
> =20
> -bcma_out:
>  	return err;
> =20
>  bcma_err_wireless_exit:
>  	ieee80211_free_hw(wl->hw);
> +bcma_out:
> +	kfree(dev);
>  	return err;
>  }
> =20
> @@ -5714,8 +5715,8 @@ static void b43_bcma_remove(struct bcma_device *cor=
e)
>  	b43_rng_exit(wl);
> =20
>  	b43_leds_unregister(wl);
> -
>  	ieee80211_free_hw(wl->hw);
> +	kfree(wldev->dev);
>  }
> =20
>  static struct bcma_driver b43_bcma_driver =3D {
> @@ -5798,6 +5799,7 @@ static void b43_ssb_remove(struct ssb_device *sdev)
> =20
>  	b43_leds_unregister(wl);
>  	b43_wireless_exit(dev, wl);
> +	kfree(dev);
>  }
> =20
>  static struct ssb_driver b43_ssb_driver =3D {


This still needs to be tested on both ssb and bcma devices. As long as
it's untested, there is no need to resend it to the maintainers.

--=20
Michael

--Sig_/pwNbvm.p9A+nzCmrdN.7qZW
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWmkHyAAoJEPUyvh2QjYsOs6IQAMT2z9tYxWHbjMA7IeUKr/E/
QQAkGd7U1Mu8tKqdNA3dq20pPywvIWUGJW7zEDq8hrEM1hLqAisG7US/O8MAbnRZ
NE4gNOXm9p7j51pAKL/jWt5xHrW6lmpzYA7uq97YattiXr44Mja0GYpKXTg7ffO6
gECH/ESaBwE0DxolH8M76CMSvuJfCB0EVe39QUKNFvhWwv4wdA7BI6HofWE+lMBF
jId0lFLNsJwNUBPLNroaD9uDZIZFyaqyv+ItTgPf3y+edr19wV6duZE6hAD2pG1B
KDUt7rv5uorcDj0YO+Wgup3QAQMsiRsUpmfGd1zdO18sz8TWG4z2QvecRlGGECej
m5KhkWVKdrAoyE319WyP+3RxMadxOi1T8FowM7fkyiaUZ1t73mpEmQiFW0Gu5hq/
WDZn7PITE1egUeSbNbp2x6hHSPIKQpGj7Gom9Y58sHbCywuyi9LInF8pEj/PeRkt
c1OnsCMQIzEsmDuIIRa+P135K1Z7irk0bccegEdU6YoeIrHwOOuUJCVyJnOX65gf
SUYnNIFEGS002ZZ3fpA1C2EVLhhAFJASKPnqac+vHsKrvTA7xigwhyzWx99fzzpl
tSnbyOGVsmBl9SwbsPDpJUWmJlUsETaHwuztov2UMTKgvbSkl7cTRKTEKn8D4002
f+fEhSWFeHWeqhdswhCb
=oP8d
-----END PGP SIGNATURE-----

--Sig_/pwNbvm.p9A+nzCmrdN.7qZW--


--===============3524865623587545751==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
b43-dev mailing list
b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
http://lists.infradead.org/mailman/listinfo/b43-dev

--===============3524865623587545751==--
