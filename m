From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#609538: r8169: long delay during resume
Date: Tue, 11 Jan 2011 05:49:12 +0000
Message-ID: <1294724952.3235.2.camel@localhost>
References: <20110110131439.GA663@rocket.almost.secure.la>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-VKg9Unw12FMS9XsCrwHJ"
Cc: Hayes Wang <hayeswang@realtek.com>, romieu@fr.zoreil.com,
	netdev <netdev@vger.kernel.org>
To: Jarek =?UTF-8?Q?Kami=C5=84ski?= <jarek@vilo.eu.org>,
	609538@bugs.debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55287 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751320Ab1AKFt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 00:49:29 -0500
In-Reply-To: <20110110131439.GA663@rocket.almost.secure.la>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VKg9Unw12FMS9XsCrwHJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-01-10 at 14:14 +0100, Jarek Kami=C5=84ski wrote:
> Package: linux-2.6
> Version: 2.6.37-1~experimental.1
> Severity: normal
> File: /lib/modules/2.6.37-trunk-amd64/kernel/drivers/net/r8169.ko
> Tags: upstream
>=20
> Hi.
>=20
> 2.6.37 introduces regression in r8169. During every resume I get ~20
> seconds delay:
> Jan 10 13:57:15 rocket kernel: [36458.257780] ata1.00: configured for UDM=
A/100
> Jan 10 13:57:15 rocket kernel: [36517.738421] r8169 0000:13:00.0: eth0: u=
nable to apply firmware patch
> Jan 10 13:57:15 rocket kernel: [36517.739859] PM: resume of devices compl=
ete after 61177.644 msecs
> Jan 10 13:57:15 rocket kernel: [36517.740258] PM: Finishing wakeup.
> Jan 10 13:57:15 rocket kernel: [36517.740259] Restarting tasks ... done.
>=20
> Bisecting leads to commit bca03d5f32c8ee9b5cfa1d32640a63fded6cb3c0
> (r8169: remove the firmware of RTL8111D.). Further debugging showed,
> that firmware.agent is not called at all, I guess that udev is not
> working before "Restarting tasks".

Right, only the kernel is running then.

> Either r8169 tries to load firmware too early, or it should keep it
> loaded in memory for use during resume.

It should.  But an earlier version of this patch was also in Debian's
2.6.36 so it would have had the same problem.

Ben.

> The problem persist no matter if I have firmware-realtek installed, or
> not.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-VKg9Unw12FMS9XsCrwHJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATSvvU+e/yOyVhhEJAQLXAA/+IscE8mFoH+vxUaS6YEtdW5+RAN/vTCr7
HRZkxpLrXHsLNPpPsWOpHJH3vdy2veQB4mwq16CniktMmSz+vJ7mt9b3dQyT/fSx
BJPPEe+kc1iyWmAugYdT8SX5w3+vHgP0dvSZkPpng0Gba6RQUFc41bQczjLkRRT1
t2N3EWLxpjLCvBIKMrcQzPjVhxKl1p+tVtFVRaHyC6TsWrc8ReYl4bqOjX3JlV7f
++xwE2rDqT9p8n2mj+eb7qHWumNBx8YgRByxYUauwztbX2kj6Yjf4QAVveTQls0O
HUTCNwy46zCdBFMCIFi5po7q1WuWbJ8m33yWFGf6UIW/l7BWolcje/k+ltfj0dmj
U6pUr0hBKkdsJfc9bDgpNKfmYu3lpkhnfvW51arkHmCzR3/tiCB/RRbyVFyQbNiV
XctAM41h1unbrgVP4stbC+HNPBrCEjFoK8tEVeVpML3yUU2USnYd+GWz1VErKLab
G8OW9jcWGxNDKnPFaXJ0J8mKYH1po+dDcyEErc/3BiA6Cu1bK8AO9SRsvyYltvpi
s7yiJ0uAIpdwG8dWomAqGXx9Cm1U3U8VajqZ7ffh0a951J0ORVhotELpfyV8xEIr
fMbCAhqbvXgqX769KqWGPw2MhmNGvrF9vuJs57pI4DhKs1Ej+yQSqSWWiJYJgK5M
fXkN/VABUQw=
=yhE+
-----END PGP SIGNATURE-----

--=-VKg9Unw12FMS9XsCrwHJ--
