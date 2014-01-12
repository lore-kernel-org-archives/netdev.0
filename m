From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/3] b43: Fix oops if firmware is not available
Date: Sun, 12 Jan 2014 03:27:31 +0000
Message-ID: <1389497251.3720.40.camel@deadeye.wl.decadent.org.uk>
References: <1389469714-13040-1-git-send-email-Larry.Finger@lwfinger.net>
	 <1389469714-13040-3-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-h5E30VfmgxRtEynJS4Zt"
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39480 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751198AbaALD2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 22:28:08 -0500
In-Reply-To: <1389469714-13040-3-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-h5E30VfmgxRtEynJS4Zt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-01-11 at 13:48 -0600, Larry Finger wrote:
> On openSUSE systems, the script that installs the firmware for b43 also
> unloads and reloads the driver. When the firmware was not previously
> available, the driver has stalled at a wait_for_completion(). When the
> unload routine releases that hold, the driver encounters structures
> that have already been deleted and generates a fatal condition. When
> the user does a manual restart, the file system cleanup frequently
> results in the firmware files being deleted and the user is never able
> to install the firmware. The fix is to change the wait_for_completion()
> with a wait_for_completion_timeout() with a 60 second wait period.
>=20
> There is a potential race condition; however, the chances that less
> than a minute has elapsed between the initial driver load and a
> subsequent unload is very unlikely.

A minute-long race is 'unlikely' to be hit?  Seriously?!

Ben.

> This patch also fixes a typo in a comment.
>=20
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org>
> ---
>  drivers/net/wireless/b43/main.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/m=
ain.c
> index 86b2030..5ce9ecb 100644
> --- a/drivers/net/wireless/b43/main.c
> +++ b/drivers/net/wireless/b43/main.c
> @@ -2150,12 +2150,13 @@ int b43_do_request_fw(struct b43_request_fw_conte=
xt *ctx,
>  			pr_err("Unable to load firmware\n");
>  			return err;
>  		}
> -		/* stall here until fw ready */
> -		wait_for_completion(&ctx->fw_load_complete);
> +		/* stall here until fw ready or 60 sec elapses */
> +		wait_for_completion_timeout(&ctx->fw_load_complete,
> +					    msecs_to_jiffies(60000));
>  		if (ctx->blob)
>  			goto fw_ready;
>  	/* On some ARM systems, the async request will fail, but the next sync
> -	 * request works. For this reason, we dall through here
> +	 * request works. For this reason, we fall through here
>  	 */
>  	}
>  	err =3D request_firmware(&ctx->blob, ctx->fwname,

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-h5E30VfmgxRtEynJS4Zt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUtILo+e/yOyVhhEJAQoqnQ/8CFqzxECNCg3DCMFUW/qySLJfYjaR6v0/
OUYcQB8a8QPi7h2HG8YSpcTPD5SX1Kg67ARbaI1I/0bLcLJQbmyItQ6ISdYtkiAs
PrCCSjTdEKLxbubgaQzIoH7jaD8yf1SbEPKZlb9cByNnWqIwZhib6oHhG+oYphC8
Hysb6LHx71iKbB+mcfO/nBZ2vRLbJAbdv2n0OJhO24DKR5CVXDM6MRqAalvNcFz9
ObYg5LvDlsYXiXgxHp5I8LSjVqcLk7Opw6JZeP/HcUhmTIsSl6kG50AH70jHr+Vl
jkvvC5gjk+fpvTmnC/NSmW14pwinsTT/T9tWaB7apugxllPP4TocqhoxyXtJDsPi
JBAw0RS+kangAKYdvRWgebQeCorfARkWq1ov/69a6vubm6m+IVxBqRQy6JLApMHL
FdWhERb50ftQ5r1J10rUCBr/bGWVrSVxaqS9IgoG/t+E6dAFH+2TFy6C0Uk3OfQO
/agCet4eUrc4azoNrvISQiJgB1A8GhXI0ZBFxekfwXoSCgR6/JxsDDqQrH91X+Ts
zKE7KIM/e3uuUX+sqCMEOp8mJjAqIEW5orekcK2mI2D4w2pm0OExSc86uO4Gl3R8
3uMBdhH7Lpiz7YIEcob0QRMFUCkZK+oHJ4u6HA7ol43s+dODtB1+o79PW4Dr3+Ly
UnH2MIz0nvM=
=s/K6
-----END PGP SIGNATURE-----

--=-h5E30VfmgxRtEynJS4Zt--
