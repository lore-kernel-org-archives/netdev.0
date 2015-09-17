From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [linux-next] oops in ip_route_input_noref
Date: Thu, 17 Sep 2015 10:58:52 +0200
Message-ID: <20150917085850.GA7953@ulmo>
References: <20150916092447.GA945@swordfish>
 <CAOMZO5CTgq_Sd81=XWEHv5oe1WyVpaydNzUXz_EbY2BWR6xF7g@mail.gmail.com>
 <55F984EF.4040503@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="r5Pyd7+fXNt84Ff3"
Cc: Fabio Estevam <festevam@gmail.com>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	richard.alpe@ericsson.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55F984EF.4040503@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 16, 2015 at 09:04:15AM -0600, David Ahern wrote:
> On 9/16/15 9:00 AM, Fabio Estevam wrote:
> >On Wed, Sep 16, 2015 at 6:24 AM, Sergey Senozhatsky
> ><sergey.senozhatsky.work@gmail.com> wrote:
> >
> >>added by b7503e0cdb5dbec5d201aa69d8888c14679b5ae8
> >>
> >>     net: Add FIB table id to rtable
> >>
> >>     Add the FIB table id to rtable to make the information available f=
or
> >>     IPv4 as it is for IPv6.
> >
> >I see the same issue here when booting a mx25 ARM processor via NFS.
> >
> >defconfig is arch/arm/configs/imx_v4_v5_defconfig.
> >
>=20
> I am still not able to reproduce. While I work on a full Cumulus image for
> other test cases here's a patch to try; eagle eye Nikolay noted a potenti=
al
> use without init in the maze of goto's.
>=20
> Thanks,
> David

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index da427a4a33fe..80f7c5b7b832 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1712,6 +1712,7 @@ static int ip_route_input_slow(struct sk_buff *skb,=
 __be32 daddr, __be32 saddr,
>  		goto martian_source;
> =20
>  	res.fi =3D NULL;
> +	res.table =3D NULL;
>  	if (ipv4_is_lbcast(daddr) || (saddr =3D=3D 0 && daddr =3D=3D 0))
>  		goto brd_input;
> =20
> @@ -1834,6 +1835,7 @@ out:	return err;
>  	RT_CACHE_STAT_INC(in_no_route);
>  	res.type =3D RTN_UNREACHABLE;
>  	res.fi =3D NULL;
> +	res.table =3D NULL;
>  	goto local_input;
> =20
>  	/*

I was seeing the same oops as Fabio (except that the faulting address
was 0xb instead of 0x7) and after applying this patch I no longer see
it:

Tested-by: Thierry Reding <treding@nvidia.com>

--r5Pyd7+fXNt84Ff3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJV+oDHAAoJEN0jrNd/PrOh66sP/R/CI8HEkrBAuZgSdMK9/fYc
VYFxwxxso3OiMDwb3HTFpGvSf3LGcou3edHCyieA3h+9eSe+anKOVZQHTRvZ14r1
e7TQLnfKO7ZT5NVAxHjnA4DprX2t/KA+WwNnPY+8Snuhi1rBUvOcCsdnLXXh2ebx
fuXsye3Og3VghgOI/3Oniz1Mhriv73M3kZQ46qIchezKy7n+KBIfybqMwECcqcGP
SCJ1L36C4qu55uhaMJFKUg1/MZQegdsQgtxidH/dPJKgCsjgflIkH48fPIHaG5oS
InKJsI7v1y/TH8okvR8KIMVY/ZT3nJyQwengVORpGAglHyhLAsThgbYj61NMXaMa
8TgMKtr2kVEpoa+Oc9jONgszGp+QorfhBwM1/gRuG3vkvn+9XuuPyCKUZlR0ndVl
LGImmYUPTU7IEf4zwsWxvnBADBria+PTV6omATwu5T4keeH4u8GbxlazlBjI6giZ
2IvKWFTxCNVdgnE/od13bghsJYbbpQLGrJB6wDxZwVOAy0CZ64xs7cC99j9+eRlp
pnkWu9RYOW1LXEf+pD4TCRPiMvKT8l0CBj6KosgzHnTo2SOWJtpJIcatuPGdeNxy
wobcyYNA9M+8hdeL1ratVtjn433cJRlyMDhVC6BjiKtbRB9BjWyQaOzPJsksv3Ug
skMI6cQehVDlRk0Utuu2
=YDM6
-----END PGP SIGNATURE-----

--r5Pyd7+fXNt84Ff3--
