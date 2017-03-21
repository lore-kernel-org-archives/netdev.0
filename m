From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH 1/3] net: stmmac: Always enable MAC RX queues
Date: Tue, 21 Mar 2017 17:38:50 +0100
Message-ID: <20170321163850.GA31875@ulmo.ba.sec>
References: <20170321151211.31841-1-thierry.reding@gmail.com>
 <970fc0aa-33f9-3eca-45e7-36df38d16e84@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="9amGYk9869ThD9tj"
Cc: "David S . Miller" <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        LABBE Corentin <clabbe.montjoie@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <970fc0aa-33f9-3eca-45e7-36df38d16e84@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 21, 2017 at 03:18:20PM +0000, Joao Pinto wrote:
> =C3=80s 3:12 PM de 3/21/2017, Thierry Reding escreveu:
> > From: Thierry Reding <treding@nvidia.com>
> >=20
> > The MAC RX queues always need to be enabled in order to receive network
> > packets. Remove the condition that this only needs to be done for multi-
> > queue configurations.
> >=20
> > Signed-off-by: Thierry Reding <treding@nvidia.com>
> > ---
> >  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_main.c
> > index d3a21519e4c0..298956032098 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > @@ -1943,7 +1943,7 @@ static void stmmac_mtl_configuration(struct stmma=
c_priv *priv)
> >  		stmmac_rx_queue_dma_chan_map(priv);
> > =20
> >  	/* Enable MAC RX Queues */
> > -	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
> > +	if (priv->hw->mac->rx_queue_enable)
> >  		stmmac_mac_enable_rx_queues(priv);
> > =20
> >  	/* Set the HW DMA mode and the COE */
> >=20
>=20
> This text is from the Databook:
>=20
> "In multiple Rx queues configuration, all the queues are disabled by defa=
ult.
> Enable the Rx queue by programming the corresponding field in this regist=
er."
>=20
> So by theory, only multiple queue configured cores needs the enable opera=
tion.

But that's related to multiple queues configured in the core when it was
instantiated (i.e. the capabilities). rx_queues_count reflects the
number of queues enabled in the driver, so it can be 1 even if the core
itself supports more than one queue.

In that case, we still want to enable the MAC RX queue because it will
otherwise remain disabled.

>=20
> >>> But came to my attention a setup that has 1 RX queue and 2 TX queues,=
 which
> enables multiple queues mechanism inside the core (even with 1 RX) and so=
 RX
> needs to be enabled. Because of that I agree with this patch.
>=20
> Acked-By: Joao Pinto <jpinto@synopsys.com>

Yeah, that case would also require this patch.

Thierry

--9amGYk9869ThD9tj
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljRVxcACgkQ3SOs138+
s6ELLg//fSXcCmAlW9RZg84qluzTi2TpIGronl0dXKxZ7eghbexmKzdO429LYQWd
khjKdqbc7l5L0DuvxjslRvN+eWmU1sqoJ2/hiW3oft5RumcuGfJ7hYCQYi7ETd2k
Dpl5xn/8wjduMK2HS2EScJbhDnHtgIaP9AmNz6z225GTsnRKScv/Bx3M1sJT0oyp
Yf6xdQFfB4nEAwPnHgTUtLBTl+xnRM4M9Uzj8+dFfBatOatoNyqL6ELPX5SNp6o8
GtxmG07mtevSItFcJvWVaMne5qwnHKOAgMnode/kDPYaHLiTOYX99pzyMZ/ankT7
jsAcq/vrZKb5nHiKcTe1raSvU5G/gwmPcM6Q5t2w99bs1OAY/KOzd78Ljl4uZnYp
ZhdvUAPP+zOulYnPidNOdmZdL1CmMkyHNQwfG098Zsp0EKEcQTlp50zPl7E7BGjR
fUJYCF+PHMC7KdWDTDJ8XORuW8aLZzlgw3t2N043JhB7hVD2MUpCqK6YHT4w8wM7
2p/nirJor8Yd5sdQU5frYtoV0N4OW4rVr4jx9KwAc87xEIO9rYC24EypYNuqN4AK
5s1kvvbrjFsdPbHXkGXbukCEY9Z+IjcatjvlroPw2PZ42V26O4w4xVZPSAVqMZcV
pxc11aJuMPOq9WuPOtjJF6oOz6JbzEJ+3MRM/MQ4SRJS7B4UvfQ=
=GGAg
-----END PGP SIGNATURE-----

--9amGYk9869ThD9tj--
