From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 3/4] ethtool: Support for configurable RSS hash
 key.
Date: Mon, 20 Jan 2014 13:20:28 +0000
Message-ID: <1390224028.3651.72.camel@deadeye.wl.decadent.org.uk>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8E5@CMEXMB1.ad.emulex.com>
	 <1390156048.16433.114.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C84C327@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BzparRQawzhAwDDCssXO"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34186 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752838AbaATNUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 08:20:35 -0500
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C84C327@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BzparRQawzhAwDDCssXO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-01-20 at 12:23 +0000, Venkata Duvvuru wrote:
[...]
> > > +/* RSS Hash key */
> > > +struct ethtool_rss_hkey {
> > > +	__u32   cmd;            /* ETHTOOL_SET/GET_RSS_HKEY */
> > > +	__u8    data[RSS_HASH_KEY_LEN];
> > > +	__u32	data_len;
> > > +};
> > [...]
> >=20
> > How about putting data after the data_len and giving it a length of 0, =
so this is
> > extensible to an arbitrary length key?
> >=20
> > If we're extending the RSS configuration interface, there are a few oth=
er
> > things that might be worth doing at the same time:
> >=20
> > - Single commands to get/set both the key and the indirection table at =
the
> > same time
> > - Add a field to distinguish multiple RSS contexts (some hardware can u=
se RSS
> > contexts together with filters, though RX NFC does not support that yet=
)
> Are you referring to the filter-id that is created at the time of config-=
nfc? Pls clarify.

No, what I mean is:

1. An RX flow steering filter can specify use of RSS, in which case the
value looked up in the indirection is added to the queue number
specified in the filter.  This is not yet controllable through RX NFC
though there is room for extension there.

2. Multi-function controllers need multiple RSS contexts (key +
indirection table) to support independent use of RSS on each function.
But it may also be possible to allocate multiple contexts to a single
function.  This could be useful in conjunction with 1.  But there would
need to be a way to allocate and configure extra contexts first.

Ben.

--=20
Ben Hutchings
One of the nice things about standards is that there are so many of them.

--=-BzparRQawzhAwDDCssXO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUt0inOe/yOyVhhEJAQpQ2A//YxvKE7UZpuOKrOtm+7E2Q/8rDKWU/qmK
yYPCrdyZ5r1Q5CceU504OD/t+zv67LBFjji61uIg34Krt1PpncYeDtLCHfniDEXj
+fYXHPFXJLt9nB9TJZp4pbiwShTZ/6gFCD+SsjlQJs85w/7/jynqDQEG1usAF2Om
56DkllTyHHhOARSTloizFMGLHh4eKRkZZ/bMzuje/eaN13qkFVDl15nwFuRizAIT
VcuhZjKHt2nGng7YjEdFL0w3Aeox2ZilQfyqkq0QOjuc+zo0Gs37GagP6KOLDZ49
MH3241IrijlI81nWWnE8FFWsfxqNhIZ1uqUGlGCEwScuEe9Uh3cYkH9nfSzQE9RG
/W70WqGn7glx9cHPG9pab/eAuNErHB0yvWp1EPgP29y77VvOrsabsRPTH5BBYTNO
pit4Jn337oR6NwO5a8ouLntksi+xW+Anb70WUmomcDaqZVZS4GQ2vxB3QJ1BVH1t
0S/darkaoTm23izzxfUxYQBSAY6ztApVlhtLrLogQqkmWeK5Y+xAjR0gxlaz/ELU
ihzw2DmgKQ+6mmh+viRDpZZZ3azPQB8MZUyHL8Z2w0YLZaS2PORW2cSRIXSCCblw
Qjevf0htqXMIb5IjC1sVGNhW5YMupiy0HvnUNjBq0RqOer0LzXjpsWEprevSDyj6
2zgIL7cTMH8=
=z+lf
-----END PGP SIGNATURE-----

--=-BzparRQawzhAwDDCssXO--
