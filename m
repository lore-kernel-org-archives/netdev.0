From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/7] net: stmmac: Check for DMA mapping errors
Date: Thu, 9 Mar 2017 20:29:09 +0100
Message-ID: <20170309192909.GA5554@ulmo.ba.sec>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-4-thierry.reding@gmail.com>
 <35dec9cd-65db-c62b-f35f-c90cf35b27f2@kapsi.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mikko Perttunen <cyndis-/1wQRMveznE@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <35dec9cd-65db-c62b-f35f-c90cf35b27f2-/1wQRMveznE@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 27, 2017 at 11:37:24AM +0200, Mikko Perttunen wrote:
> On 23.02.2017 19:24, Thierry Reding wrote:
> > From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> >=20
> > When DMA mapping an SKB fragment, the mapping must be checked for
> > errors, otherwise the DMA debug code will complain upon unmap.
> >=20
> > Signed-off-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> > ---
> >  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 ++
> >  1 file changed, 2 insertions(+)
> >=20
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_main.c
> > index 6b7a5ce19589..d7387919bdb6 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > @@ -2072,6 +2072,8 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff=
 *skb, struct net_device *dev)
> >  		des =3D skb_frag_dma_map(priv->device, frag, 0,
> >  				       skb_frag_size(frag),
> >  				       DMA_TO_DEVICE);
> > +		if (dma_mapping_error(priv->device, des))
> > +			goto dma_map_err;
>=20
> If this map fails, we should also unmap the previously mapped fragments a=
nd
> the separate mapping made using dma_map_single.

That's already taken care of via the dma_map_err label:

	dev_kfree_skb()
	  consume_skb()
	    __kfree_skb()
	      skb_release_all()
	        skb_release_data()

Thierry

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljBrQEACgkQ3SOs138+
s6EeSA//UyeGWyF4f8qBLQSLffuXkjyLFBYy8/NLZ7K1kozF6oWntbTZvnOv1nfZ
tq8ECo28/fKGS/yUai67+GLcpI6ws7fw85A+Xj10YAtShpIcy7j4DK8F20JlfgdG
DzRcXUJrQlN7uF2LkbDAgwnX0oqXgfJg+D8fVGrQOjQIDkAMXOzeeYysumnCufua
wVC6f3FdpanLF5QzsDqxs/tYgsPn9aTSuc1Tyeg2uvS7iZvm+AQmkGpslPVQGBS6
d5pteSs5KH4VRsvtYTFjmvBNK1e1r3YuneaKwIRedIs54O0MI15XSM8Zh3wpcSn/
+u0hMNoWmveK635kRC1/aFvni5Q3tFfpDXCB5ITaPkwLDvjr5iItnVNqbNiieNRV
iRJtdSOKGbqe5PKDNELEvhJRprq/Vq6vhis6O4qWeCGxgFdWU3k0sYlhc68xN1sv
VGgQLXfBhozYt3B9Th6VDqJfrF/oPWN8DeWadI7rvUoMJcA8LS3DFNab7D55JnL6
vnC/YK04W/mswVrN8MhpsOC3mFvU2hYUwTMaEQpS5svJginyOSRO9ew+jfkpTjUE
TitRz36zWlO+f2Xb0P8N8pUm7rA1WC0fMQFblPqNAtJtJ2Wi1jYwyJdnB3kJcvzM
kzooRFmMR/4B3U7EHxKaoRFQ5P96z7es8i4NdOrA/bLBbDVW8RA=
=eZMU
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--
