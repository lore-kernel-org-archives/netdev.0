From: Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>
Subject: Re: [PATCH 12/14] i2c-parport: return proper error values from attach
Date: Thu, 9 Apr 2015 09:13:07 +0200
Message-ID: <20150409071307.GA1166@katana>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
 <1428492040-5581-13-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Nq2Wo0NMKNjxTN9z"
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jean Delvare <jdelvare-l3A5Bk7waGM@public.gmane.org>,
	Rodolfo Giometti <giometti-AVVDYK/kqiJWk0Htik3J/w@public.gmane.org>,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Willy Tarreau <willy-859RlTSWH48dnm+yROfE0A@public.gmane.org>,
	Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>, Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
To: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1428492040-5581-13-git-send-email-sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 08, 2015 at 04:50:38PM +0530, Sudip Mukherjee wrote:
> now that we are monitoring the return value from attach, make the
> required changes to return proper value from its attach function.
>=20
> Signed-off-by: Sudip Mukherjee <sudip-ofJRbWXBVFamYgehrs7/Lw@public.gmane.org>
> ---
>  drivers/i2c/busses/i2c-parport.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/i2c/busses/i2c-parport.c b/drivers/i2c/busses/i2c-pa=
rport.c
> index a1fac5a..761a775 100644
> --- a/drivers/i2c/busses/i2c-parport.c
> +++ b/drivers/i2c/busses/i2c-parport.c
> @@ -160,14 +160,14 @@ static void i2c_parport_irq(void *data)
>  			"SMBus alert received but no ARA client!\n");
>  }
> =20
> -static void i2c_parport_attach(struct parport *port)
> +static int i2c_parport_attach(struct parport *port)
>  {
>  	struct i2c_par *adapter;
> =20
>  	adapter =3D kzalloc(sizeof(struct i2c_par), GFP_KERNEL);
>  	if (adapter =3D=3D NULL) {
>  		printk(KERN_ERR "i2c-parport: Failed to kzalloc\n");
> -		return;
> +		return -ENOMEM;

ENOMEM does not need printout. Please remove printk while we are here.

> =20
>  	pr_debug("i2c-parport: attaching to %s\n", port->name);
> @@ -230,13 +230,14 @@ static void i2c_parport_attach(struct parport *port)
>  	mutex_lock(&adapter_list_lock);
>  	list_add_tail(&adapter->node, &adapter_list);
>  	mutex_unlock(&adapter_list_lock);
> -	return;
> +	return 0;
> =20
>   err_unregister:
>  	parport_release(adapter->pdev);
>  	parport_unregister_device(adapter->pdev);
>   err_free:
>  	kfree(adapter);
> +	return -ENODEV;

Ideally, we would return different -Esomething for each failing case. We
can leave that for someone who is acutally using the driver. However, I
wonder if ENODEV is a proper catch-all case because the driver core will
not report failures.


--Nq2Wo0NMKNjxTN9z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVJiaDAAoJEBQN5MwUoCm2iRwP/ijI5Z76EKO0xyEKIMZmx0kU
Q/gdzLbAVd+ifa+aJub2Lv9xyEa4MssHm0yn4982Dmt1jTxT0QTkPoSAhmxUmkpP
5DGvJH3Yp+DCawSy6+RPCsujtmoQPz8xNLjaHMCx7V8kBz2BTIKiUeDeQu574zr/
Nv7R9q77W9ZUHFP+1ui8RwZylYnX/frwI1Xgli71dY3xuo7eh/6UntTRCVeRIw+h
rsIurGoC78AfxW3FSzxSPVxSuK/upAmwgB5ECRo7l5itaKmATW4KFLBdp0wl1Myt
jhL1HjQRH4BcFpiFDxAlemcmWQXeIpnimVsMRk9alLIEJlnfivVPTR2sh38cHYTV
Bm0kasy34LwJZsTnGImdCYACKbzv4mKDSXt+Kzc+iHxgsmf8PzZ2yTXJxAJd8+l8
AMVMXMRVoW7oXGzAkLTZaRZvFlfPhUgfVCo8/P33PHcyJ6BRzKeXK+XXs9UgUkt/
/u5N3pk4Wy47/JZSQlB8EZVW+x5ODBUVXFkMh7rPmgm19p5CwXqizC2wXXgdPQlv
A/QtciA8ZAwGdkO5qa+mVcPGhoH77WGN5CQIZxITvCyy7phRLUK9zWv2vLpTpv3h
7MTzn5Oldf5OATEeO9ygiUXgnb6/szYNI94W/rKC2oGaGfSN6XKltyGVkciSTllI
y4uJB1rGeX8LLg+hAzjd
=2iEF
-----END PGP SIGNATURE-----

--Nq2Wo0NMKNjxTN9z--
