From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/2] bgmac: Add support for ethtool statistics
Date: Fri, 03 Jun 2016 18:57:48 +0100
Message-ID: <1464976668.2847.117.camel@decadent.org.uk>
References: <1464973621-14794-1-git-send-email-f.fainelli@gmail.com>
	 <1464973621-14794-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-478KMM1WDJnmWEb8WHVy"
Cc: davem@davemloft.net, zajec5@gmail.com, nbd@nbd.name,
	hauke@hauke-m.de, jon.mason@broadcom.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53707 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752130AbcFCR6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 13:58:00 -0400
In-Reply-To: <1464973621-14794-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-478KMM1WDJnmWEb8WHVy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-06-03 at 10:07 -0700, Florian Fainelli wrote:
[...]
> +static void bgmac_get_strings(struct net_device *dev, u32 stringset,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u8 *data)
> +{
> +	int i;
> +
> +	if (stringset !=3D ETH_SS_STATS)
> +		return;
> +
> +	for (i =3D 0; i < BGMAC_STATS_LEN; i++)
> +		memcpy(data + i * ETH_GSTRING_LEN,
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0bgmac_get_strings_stats[i].n=
ame,
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0ETH_GSTRING_LEN);

These strings are null-terminated, not padded to ETH_GSTRING_LEN. =C2=A0So
here you should be using strlcpy() instead of memcpy().

> +}
> +
> +static void bgmac_get_ethtool_stats(struct net_device *dev,
> +				=C2=A0=C2=A0=C2=A0=C2=A0struct ethtool_stats *ss, uint64_t *data)
> +{
> +	struct bgmac *bgmac =3D netdev_priv(dev);
> +	const struct bgmac_stat *s;
> +	unsigned int i;
> +	u64 val;
> +
> +	if (!netif_running(dev))
> +		return;
> +
> +	for (i =3D 0; i < BGMAC_STATS_LEN; i++) {
> +		s =3D &bgmac_get_strings_stats[i];
> +		val =3D 0;
> +		if (s->size =3D=3D 8)
> +			val =3D (u64)bgmac_read(bgmac, s->offset + 4);

Isn't this missing a << 32?

Does reading the high 32 bits latch the value of the low 32 bits? =C2=A0If
not, you need to read the high bits again after the low bits and retry
if they changed.

> +		val |=3D bgmac_read(bgmac, s->offset);
> +		data[i] =3D (u64)val;

Redundant cast.

Ben.

> +	}
> +}
[...]

--=20
Ben Hutchings
Nothing is ever a complete failure; it can always serve as a bad
example.

--=-478KMM1WDJnmWEb8WHVy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXUcUcAAoJEOe/yOyVhhEJBh4QALAUbxCiYiA4LaAyY2u2zFvF
fa4z5X8+hfj9Grz5+rx2hd41TxNVtUp367X/FWfk6AboUQlLe/ip15HRtxAv6Vxr
y+M3tJvR5tQAMjxMKdvG0Mk/XilZ2fXzunsFJ2M6oUWsz5z8QkbboSiIbTdFCUxa
uU3kAeIY+plNARWLpFvbkN40wNMQkyjHRkhmWdCKMbPlljxiOgogqPpD/o0eFcdq
FyDdI+JkrIRza1iYK3qelD32nQxTnZDEt1KJDOrVWh9db6yzjy8oP6EPsDo90n3Y
yrXOeVzmHClFUpmuqXX7mxaBQohcpwqnReGC5CPWFaixO8Nsvv5g/e0tf1D6Qt3+
f9xJmJ1acJNPKlpuN7qohq2no7w3WVtx8siETScT5JQ/hu3Lpf7rf+BGmgmdVOGG
jhwShn76Nq99HSapsCU9q8epGTZUnkqXv9FER8+Zb+jpXbIaKDSWjV/EpF0IgoUP
cprRFA1ZIRC0HdfVzY1doYYx45lgNp7Dy5aduvKW6Li2OSZPgRhfqHxZeC3JdoWL
o5T99twAoUwJ5Ydr9kFyusLY92xD/fHjk3q6BpbpM2TJeB01oJQAqW46tvoag73f
KnlcVqQ0XY/PkqM39T3qJ6Jgnln9Ist0gy9yKcKP1M7rr14flVgfFReWlNdrP4X0
Ls9m2H1fEJQXUrkzCilw
=HgwY
-----END PGP SIGNATURE-----

--=-478KMM1WDJnmWEb8WHVy--
