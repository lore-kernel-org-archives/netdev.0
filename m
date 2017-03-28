From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH 2/3] net: stmmac: Always use the number of configured TX
 queues
Date: Tue, 28 Mar 2017 16:29:15 +0200
Message-ID: <20170328142915.GB3523@ulmo.ba.sec>
References: <71d841cd-b07b-2635-c2cf-f7af5f5ed2c9@axis.com>
 <20170328135706.7605-1-thierry.reding@gmail.com>
 <20170328135706.7605-2-thierry.reding@gmail.com>
 <ee068d94-9a4e-404e-1348-c8e412c58ec9@axis.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="vGgW1X5XWziG23Ko"
Cc: Joao Pinto <Joao.Pinto@synopsys.com>,
        David Miller <davem@davemloft.net>, clabbe.montjoie@gmail.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35448 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752012AbdC1O3x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:29:53 -0400
Received: by mail-wr0-f193.google.com with SMTP id p52so20330551wrc.2
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:29:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ee068d94-9a4e-404e-1348-c8e412c58ec9@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vGgW1X5XWziG23Ko
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 28, 2017 at 04:10:43PM +0200, Niklas Cassel wrote:
>=20
>=20
> On 03/28/2017 03:57 PM, Thierry Reding wrote:
> > From: Thierry Reding <treding@nvidia.com>
> >=20
> > Even if hardware supports multiple queues, software can choose to only
> > use a subset of them. Make sure we never try to access uninitialized
> > queues.
> >=20
> > Signed-off-by: Thierry Reding <treding@nvidia.com>
> > ---
> >  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_main.c
> > index 106ace3781b3..ec5bba85c529 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > @@ -3423,7 +3423,7 @@ static int stmmac_poll(struct napi_struct *napi, =
int budget)
> >  	struct stmmac_rx_queue *rx_q =3D
> >  		container_of(napi, struct stmmac_rx_queue, napi);
> >  	struct stmmac_priv *priv =3D rx_q->priv_data;
> > -	u32 tx_count =3D priv->dma_cap.number_tx_queues;
> > +	u32 tx_count =3D priv->plat->tx_queues_to_use;
> >  	u32 chan =3D rx_q->queue_index;
> >  	u32 work_done =3D 0;
> >  	u32 queue =3D 0;
> >=20
>=20
> Thanks Thierry,
> but this look like an equivalent patch to Joao's
> "net: stmmac: fix number of tx queues in stmmac_poll"
> which I already used during bisecting to avoid random
> crashes in stmmac_tx_clean.

Yeah, patch 3/3 is the important one in this batch. I just sent out the
complete set of 3 because it's what I use on top of linux-next to make
stmmac work again on my setup.

> Have you noticed random RX brokenness after boot in
> recent linux-next tags?

Yes, I was seeing about 8 in 10 bad boots and 2 in 10 good ones.

> It feels like it might trigger more often after a
> cold boot, but that could just be my brain seeing
> patterns that aren't really there :)

It'd be good if you could try applying patch 3/3 since that got me back
to 10/10 successful boots. It's somewhat surprising because I had gone
through the code looking for uninitialized data that would explain why
kcalloc() instead of kmalloc_array() would fix things but didn't find
anything.

Still, that patch works for me, so maybe I was just overlooking
something.

Thierry

--vGgW1X5XWziG23Ko
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljaczkACgkQ3SOs138+
s6EZlQ/+OGvlPpt+jEtOrkg2JpcwHEw1TslvXexPRzZSqDkupKOU4OhifmHqR3nU
u9OvTkvJXs7/fBlpgegKTwWUgCidNT7SwW8LnD4825Z+ANgcZFSbmm2weThAO/sG
JhJdpsoWZy8vYPV+MyV7yY9KLV3VxAR7gt/SAGG5r8DD4vno/WO5CxYAnqv23xya
SrSmRA+FxCIGaieVL0ntWR3Vas02/VaSCYOTdDGPpTf/X6vNWIKB8sBWPK8WWWzk
aRoetzZlWJEON6ylzW6R3sBRUS1KnbEL+zz0JIl44VdnJ3rvEfIgHUIpA07D56dn
kYyPo3kCa1h1KNWW13Rs5vFMDarm3tlyBQ58QktlCIO2KR56txg2dZDm18/LI/m3
+HswFwJ3uM2GAfrdgjfm1e52e3ssUpRSEU0UPHMXOvzWS21/3GNaB8xcx2XjKq4O
45Mde4cg+PDeYBt5N2SQKBpkqqhB7Ht4qXSqYmI7zZVSWr84Rt/YIZdvS1zKFOB6
tO66KpC0qZzUTbYVlPICXJTJO0f3u+Q3aS9tGmV9uIHQ5lC1aDqJGXXFJq7u9ADw
8ADJd8OU1NJ3QPPBNdI/cVxz+kg5vpbZojF5YqTrRi7c1rV5of8Z9g0YCS86RFvx
I1SF3RkLieHAXem6L0MMr/hp/fKTP3R9qp+bfnWxI4Lsn91Iirg=
=n3Ob
-----END PGP SIGNATURE-----

--vGgW1X5XWziG23Ko--
