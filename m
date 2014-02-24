From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] sfc: check for NULL efx->ptp_data in efx_ptp_event
Date: Mon, 24 Feb 2014 23:40:10 +0000
Message-ID: <1393285210.6823.109.camel@deadeye.wl.decadent.org.uk>
References: <530BA00D.8000109@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-K2uTpJXO/8r6dILwH9q0"
Cc: netdev@vger.kernel.org, Shradha Shah <sshah@solarflare.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36393 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752727AbaBXXkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 18:40:12 -0500
In-Reply-To: <530BA00D.8000109@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-K2uTpJXO/8r6dILwH9q0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-02-24 at 19:39 +0000, Edward Cree wrote:
> If we receive a PTP event from the NIC when we haven't set up PTP state
> in the driver, we attempt to read through a NULL pointer efx->ptp_data,
> triggering a panic.
>=20
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
> While this shouldn't happen with existing released firmware, future
> sfn7322f firmware is planned to enable PPS irrespective of whether
> timestamping (and thus PTP) is enabled.  We are considering workarounds,
> but this defensive patch seemed like a good idea anyway in case the
> firmware gets in a muddle.
> Also, in principle this shouldn't happen on 3.14+ kernels as the driver
> should always set up PTP state at probe time (though there might still
> be a race against the firmware sending its first PPS), however 3.12 and
> 3.13 both supported EF10 but not PTP-on-EF10 and thus they never set up
> the PTP state; hence this fix should also be backported to those series.

Good thinking.

> --- linux-3.13/drivers/net/ethernet/sfc/ptp.c.orig	2014-01-20
> 02:40:07.000000000 +0000
> +++ linux-3.13/drivers/net/ethernet/sfc/ptp.c	2014-02-24
> 17:46:31.753497000 +0000

This patch has been word-wrapped and can't be applied; see
Documentation/email-clients.txt

Ben.

> @@ -1360,6 +1360,13 @@ void efx_ptp_event(struct efx_nic *efx,
>  	struct efx_ptp_data *ptp =3D efx->ptp_data;
>  	int code =3D EFX_QWORD_FIELD(*ev, MCDI_EVENT_CODE);
>=20
> +	if (!ptp) {
> +		if (net_ratelimit())
> +			netif_warn(efx, drv, efx->net_dev,
> +				   "Received PTP event but PTP not set up\n");
> +		return;
> +	}
> +
>  	if (!ptp->enabled)
>  		return;
>=20

--=20
Ben Hutchings
Beware of bugs in the above code;
I have only proved it correct, not tried it. - Donald Knuth

--=-K2uTpJXO/8r6dILwH9q0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwvYWue/yOyVhhEJAQp3UQ/+MBzSkD9D02rax34j3mHofOiKFIWXPRSS
VX+XsHpPcaKD9gu8voFsMpmwLbmTjlRZc9Lblscs5gIALUbPRs55/CcRFqiE+BLf
k5NDtnW2QO43xH6B7UYHyymwi+/1Tksmh5WOgxjQCqkWmVSEWlH7o6p2HF3o98oV
+N7S/xJhRJWlWVu71VgGEOxnGnZ9rwhkqI6V/x5Yru4I0eJJx3cKUkHga+/YCaUG
PNoE3WztlfObfqwW3pIHpqiuXARkKjK3oT0yDoxB5u03hNGLTTRW9ZysUNxxcUxt
nrxqt9vb44dxISdgIQOJAxyGIFuwOsVfak1omeSXGQFt8sXeUJzlFClW7hui0HVT
HEqMuXnCjY4fAjPT4J6PReoBl1CkG9lLafCNkPvlkiqV5SLV9cc67x/2u+Z88cRb
4J7vddNpVaZ5SjJynEwCw7ra4y8YyDw6OILzuoCqhtIkhhM0p9WnIEP5ZU1v95XV
B31SmKrBvHpVd62SNLJuFvgx5lXGKYrkxTiOv33iYTCg/zzaGzhj57hTEB5wMH3E
HGJxnGcuiKnEPVR0YfqO0oneaJMkwfoIGkj2eDKf05VKLCQBp7fDh9ScTwk2UP2O
MjEbt6ikiJUF91pT79521fOH+XfWYLkaSTtAXGuWMESD5+3WYq9EPDZ1gBIDOeCT
PBNdYs1nfb4=
=zrpP
-----END PGP SIGNATURE-----

--=-K2uTpJXO/8r6dILwH9q0--
