From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 4/4] ethtool: support setting default Rx flow
 indirection table
Date: Sun, 13 Mar 2016 16:25:00 +0000
Message-ID: <1457886300.3331.26.camel@decadent.org.uk>
References: <1454976306-23523-1-git-send-email-jacob.e.keller@intel.com>
	 <1455657758.23620.21.camel@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-pi4heS+1Y1eyBP0OdpBA"
Cc: netdev <netdev@vger.kernel.org>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40800 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751441AbcCMQZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 12:25:14 -0400
In-Reply-To: <1455657758.23620.21.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pi4heS+1Y1eyBP0OdpBA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-02-16 at 21:22 +0000, Keller, Jacob E wrote:

> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> ---
>=20
> Not sure if there is a mailing list for this, I sent this to the netdev
> list but forgot to Cc you on the ethtool change.

I haven't been keeping up with netdev for a long time, but I have
recently set up filtering by subject so I can keep up with just the
ethtool-related messages. =C2=A0Still, patches for the ethtool command
should always be explicitly sent to me.

> Dave applied the
> network core patches, but they're more or less useless unless we
> actually have the ability to request default setting using ethtool
> (which I extended to support "default" here)

The patch was mangled (word-wrapped and modified white-space) in this
message, so I took the version in
<http://article.gmane.org/gmane.linux.network/398404/>.

[...]
> @@ -3332,7 +3335,7 @@ static int do_srxfh(struct cmd_context *ctx)
> =C2=A0	u32 entry_size =3D sizeof(rss_head.rss_config[0]);
> =C2=A0	u32 num_weights =3D 0;
> =C2=A0
> -	if (ctx->argc < 2)
> +	if (ctx->argc < 1)
> =C2=A0		exit_bad_args();
[...]

This means we might continue without having the required parameter
after "equal", "weight" or "hkey". =C2=A0But, having said that, since we're
only checking once before running the loop, we're already failing to
validate that properly.

I've applied this, but could you please send another patch that adds
checks on ctx->argc within the loop and test cases in test-cmdline.c?

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.
--=-pi4heS+1Y1eyBP0OdpBA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW5ZRcAAoJEOe/yOyVhhEJUFUP/3WiCWFwzO0Q1neZGSfkP9kr
liYrCIqLMgmphbDuY6VVjcxFzmp3r4lYFuIHHZ8In7/nOk+z1+dhXoQ+uLKTtKzm
qytNbXbg3NBJsvbOb8c5HzQ+TXMD9v+CYzOfWnnVDPcVHJj3TFeKMhvOpTmu/QX2
ipMae5GnLxhFA7q1TefscDlGjGqXK30yKISfubi4UnJAB8tMkKGnS+QzHhmSPcUb
gA29K1tOxQ42JaCHAUiI0qoUN74hG8tc5fqO+AWbgjfxljKDcWE27/9erdzY0THG
JxE4dtbWi+ziF5ghknmVCi62BBRo8k4OLdT6J0ZHLDkLalze/dfM590B82Ocf/hE
qTDSEFz+3mFj1evM0Hm1gkNayl09OnDz0DKZv0d7YqFk7NBDN3p7RnIqyh1FKtcy
89FPRc/pqfHCwehLt0N9RZe1LD8PzNEOXZuT2vsYqKfj0QZkeFJYpk8GuJu3cgKy
4VqfVOxQ06iBiImWc3zk9GpLx7wzWqSBK/OQ1Qy4Fe0AeobJ/Ru5CK425v//BjKC
NalPtoiJmmeNF4N0HSeLLa6x1W8Ew4bdNPgBW+5RS/1vg8axV87k1wQpmg6KHcS8
ZWFSnW3s5tyWVb+qqStAotS1DtRnLToI+WBVg+iy2tglWsTqT/aS9oaI2T57jA2f
z9+Ge+Zyjtn/hddgi9LG
=VQSM
-----END PGP SIGNATURE-----

--=-pi4heS+1Y1eyBP0OdpBA--
