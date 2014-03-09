From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC 1/2] net: Add support to configure SR-IOV VF minimum and
 maximum Tx rate through ip tool.
Date: Sun, 09 Mar 2014 17:23:29 +0000
Message-ID: <1394385809.2861.168.camel@deadeye.wl.decadent.org.uk>
References: <1394004816-23436-1-git-send-email-sucheta.chakraborty@qlogic.com>
	 <1394004816-23436-2-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-eJpDuQLfc/9lYecE4XUW"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept-HSGLinuxNICDev@qlogic.com
To: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51007 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751231AbaCIRXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 13:23:36 -0400
In-Reply-To: <1394004816-23436-2-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-eJpDuQLfc/9lYecE4XUW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-05 at 02:33 -0500, Sucheta Chakraborty wrote:
> o A new handler set_vf_rate for attr IFLA_VF_RATE has been introduced
>   which takes 4 arguments:
>   netdev, VF number, min_tx_rate, max_tx_rate
>=20
> o min_tx_rate puts lower limit on the VF bandwidth. VF is guaranteed
>   to have a bandwidth of at least this value.
>   max_tx_rate puts cap on the VF bandwidth. VF can have a bandwidth
>   of up to this value.

Supposing I only want to set a minimum, how would I specify that there
is no maximum?

> o Idea is to deprecate IFLA_VF_TX_RATE and ndo_set_vf_tx_rate in future.
>   And to have consistent display of rate values to user.
[...]

You can't deprecate the userland interface, but the driver operation
should be replaced at the same time.

- The rtnetlink core should combine userland settings from
  IFLA_VF_TX_RATE and IFLA_VF_RATE.  If both are specified, I think
  IFLA_VF_RATE should override.
- If only IFLA_VF_TX_RATE is specified, the core should get the current
  minimum before calling ndo_set_vf_rate.
- Drivers that currently implement ndo_set_vf_tx_rate should be
  converted to implement ndo_set_vf_rate and reject attempts to set a
  minimum bandwidth greater than 0.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-eJpDuQLfc/9lYecE4XUW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxyjkee/yOyVhhEJAQrH/A/+OFSG0kKc/S1TwCed3jDkF4ncCtiDigZd
qn2ylDsJMUUgGm4hOw95F1z0RR0WC8taTa9rX/1v2qeCqU5hmQse5wgeKfT8cT8S
sC6qUbam3ALYDtM/tZX34yNIrI4XDaan6JWtR9zN3t339rQE5lQj8wPeht1v1RNO
k7zf0nhYnKQEQTTa9CVBhyFgdj7vn3QdnKU8HyL8CZ0A52rFfFlSMI+7cxGKgMKM
lcjO8XSjAi1ZdXDapMnn1me4bZrVUmUZFCYd3Bz6has9gs4YAVTXBwzbNpNjAWvY
YrX6rGWHkZwFsZfoqQ8f1q5w71KIin+uRl3+ECprZIEjTVB5w0ZBhUvB7iyIHJy8
NcRPWceldePBJGuERtTk2iXVDjxW1qzo/+l0Rk51dENV60eNzUAh+pGwN1W0dT2r
C7ffnpH47N+xi4R0rvh4ryFnfseFjNPSTKH1mSbEE1ZD4PTtlPgO8S7O50Zovrka
k7MtZgpKEsASGGqjNtOdYm+B6AKPfwQ5VCCrN1g3RmSfKkExtUYgT70jgXce5lPF
cvXcsGHOk9txlXNqQyLuWNACPm66G3VQjruJOHHy//Aao6TssZt1o+qcSk1s4iod
tHuO9QvMyDmUKCUKMmXU4scXFNzBZjdnE6EVeIfxRpiOGq+xhRB8Svp1uiJ0JAZP
xiF3elYFF+w=
=pSxi
-----END PGP SIGNATURE-----

--=-eJpDuQLfc/9lYecE4XUW--
