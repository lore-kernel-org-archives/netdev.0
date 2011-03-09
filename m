From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Wed, 9 Mar 2011 11:11:13 +1100
Message-ID: <20110309111113.883972ba.sfr@canb.auug.org.au>
References: <20110308140957.8a894312.sfr@canb.auug.org.au>
	<1299577473.17233.41.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__9_Mar_2011_11_11_13_+1100_+WUkRSi=TV3KgM.8"
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "Dmitry Kravkov" <dmitry@broadcom.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1299577473.17233.41.camel@lb-tlvb-dmitry>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__9_Mar_2011_11_11_13_+1100_+WUkRSi=TV3KgM.8
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dmitry,

On Tue, 8 Mar 2011 11:44:33 +0200 "Dmitry Kravkov" <dmitry@broadcom.com> wr=
ote:
>
> You are correct it's just an addition and it does not really matter
> where to do this. But the merge pushed new code in the middle
> of MAC configuration between MAC and multicast list.
> It's clearer to put it at the end of MAC/ML/UL block:
> ---
>  drivers/net/bnx2x/bnx2x_cmn.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
> index b01b622..9e37675 100644
> --- a/drivers/net/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> @@ -1498,6 +1498,11 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
>  	/* Clear UC lists configuration */
>  	bnx2x_invalidate_uc_list(bp);
> =20
> +	if (bp->pending_max) {
> +		bnx2x_update_max_mf_config(bp, bp->pending_max);
> +		bp->pending_max =3D 0;
> +	}
> +
>  	if (bp->port.pmf)
>  		bnx2x_initial_phy_init(bp, load_mode);

OK, thanks.  I have changed the conflict resolution to do that.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__9_Mar_2011_11_11_13_+1100_+WUkRSi=TV3KgM.8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNdsWhAAoJEDMEi1NhKgbs59YH/ifwsP88QypKpEWACWH2Ca8N
E0cT0cxrM6dHRcAvV0WhJbDu3PUzgcPjN9/Fum3xGkm00XfB4rgSGEsPfYh3/phX
7wdpN70O0dG+WEs3ZioFY8BGYJ4pKyDtmVw1J4d6wkdr2lVRvriUqkabbHHl+3un
LM5a1Gqs+tKlf8UjSftNGkuU8xMYuKXoVIwZwNAqpOMoxIRy/6f2gJkaAKT/tlmu
Bksig3NMTJj8ohsUHk8hMNHD/OswYK/spOEjerGY8QKLfCJZM1oQ+XTXDuRIIl0O
XDS3ZRsF1TC1K4PrqheRF1loQwGPtj08dZlVtDMiHHJgmmvjuZAvzqI6Uwba+78=
=OasS
-----END PGP SIGNATURE-----

--Signature=_Wed__9_Mar_2011_11_11_13_+1100_+WUkRSi=TV3KgM.8--
