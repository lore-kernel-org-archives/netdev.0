From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 3/4] ethtool: Support for configurable RSS hash
 key.
Date: Sun, 19 Jan 2014 18:27:28 +0000
Message-ID: <1390156048.16433.114.camel@deadeye.wl.decadent.org.uk>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8E5@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6kcKPZaY1r0FrrlNqxn2"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60026 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751538AbaASS1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 13:27:44 -0500
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8E5@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6kcKPZaY1r0FrrlNqxn2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-01-17 at 13:02 +0000, Venkata Duvvuru wrote:
> This ethtool patch primarily copies the ioctl command data structures fro=
m/to the User space and invokes the driver hook.
[...]
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -678,6 +678,22 @@ struct ethtool_rx_ntuple {
>  	struct ethtool_rx_ntuple_flow_spec	fs;
>  };
> =20
> +
> +/**
> + * struct ethtool_rss_hkey - command to set/get RSS hash key of the devi=
ce.
> + * @cmd: Command number - %ETHTOOL_SET_RSS_HKEY/ETHTOOL_GET_RSS_HKEY
> + * @data: 40 or 16 byte rss hash key
> + * @data_len: rss hash key length
> + */
> +
> +#define RSS_HASH_KEY_LEN	40

This should have an 'ETHTOOL_' or 'ETH_' prefix.  But I wonder whether
there should actually be a static maximum length.

> +/* RSS Hash key */
> +struct ethtool_rss_hkey {
> +	__u32   cmd;            /* ETHTOOL_SET/GET_RSS_HKEY */
> +	__u8    data[RSS_HASH_KEY_LEN];
> +	__u32	data_len;
> +};
[...]

How about putting data after the data_len and giving it a length of 0,
so this is extensible to an arbitrary length key?

If we're extending the RSS configuration interface, there are a few
other things that might be worth doing at the same time:

- Single commands to get/set both the key and the indirection table at
the same time
- Add a field to distinguish multiple RSS contexts (some hardware can
use RSS contexts together with filters, though RX NFC does not support
that yet)

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.

--=-6kcKPZaY1r0FrrlNqxn2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUtwZEOe/yOyVhhEJAQoDRA/9EUK+R08jQmnAYh0jAKlDtWiHj0UnIMCq
ofhiHdwATq5Pjcr2pUK0Fddmk6FVAa8dD4H2lH8Q42DX39wa0Zl8YrZpfqbuFG6M
oS6S5jm6RLPi/RDe2PTUNKC8tUspUtrwYWOrBJjeyzmha32OZ06ZoX7kdrmGHizB
+cBGVkymgt8V6bGnOH0UV/SPy+EaGfFlHrw2g101Chi32qqxBJUu8M9XXG9qxx6B
+d6QQy6CYJzSO1HI4Fw/C1RUjhSiZ2khXtgd4OU05EYENKGNWG3XiTTiCWoiBCTh
y1cbZ7427FX7fepUTxl+VlNA52CTkSb7K+gyprhghbIgCby5U0rEiDJxAn4Aw2vw
i4QH6mk4CJZRSVcDxc2HTDNt64QSHoj2SFsOwslazYRLuBcXBa4VF7A84/PYb6l4
Y7fPci0xsS8zuJtVvLcfTZ6QIsiWSW6O78TEytJFHqVodfKn6U/vzuUOn2X1L1a+
uDA7fOx7rcNBNDDFGG7Qql3vO4vi6gE80S3Cj8Y0QQH7EYNV49EXbYe0x0S21ENv
jx7w6d7W0kQcLpBRMwpWAbJGbr26rjlO2m6KjOdDrrzUuQCZZYfeJYNAO9WSaqAZ
l43lK3mMKVlD/DGhC94FOZBYCQfnv0vwBHqEjNDaELLYOAzXr4/m31ldZbNrNttJ
Ay/jOo/IBCM=
=LJoU
-----END PGP SIGNATURE-----

--=-6kcKPZaY1r0FrrlNqxn2--
