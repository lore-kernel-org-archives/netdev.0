From: Thierry Reding <treding@nvidia.com>
Subject: Re: [PATCH 2/4] net: stmmac: adding multiple buffers for rx
Date: Tue, 4 Apr 2017 21:14:53 +0200
Message-ID: <20170404191453.GB24271@ulmo.ba.sec>
References: <433505e9e631db632be7a37a316a03ace802863c.1491328304.git.jpinto@synopsys.com>
 <4f35e9a73521ba4ab4868c75950166fb757b5f8a.1491328304.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="tsOsTdHNUZQcU9Ye"
Cc: <davem@davemloft.net>, <clabbe.montjoie@gmail.com>,
        <niklas.cassel@axis.com>, <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate16.nvidia.com ([216.228.121.65]:7843 "EHLO
        hqemgate16.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754976AbdDDTPA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 15:15:00 -0400
In-Reply-To: <4f35e9a73521ba4ab4868c75950166fb757b5f8a.1491328304.git.jpinto@synopsys.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--tsOsTdHNUZQcU9Ye
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 04, 2017 at 06:54:25PM +0100, Joao Pinto wrote:
[...]
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/=
net/ethernet/stmicro/stmmac/stmmac_main.c
[...]
>  static void stmmac_display_rx_rings(struct stmmac_priv *priv)
>  {
> +	u32 rx_cnt =3D priv->plat->rx_queues_to_use;
>  	void *head_rx;
> +	u32 queue;
> =20
> -	if (priv->extend_desc)
> -		head_rx =3D (void *)priv->dma_erx;
> -	else
> -		head_rx =3D (void *)priv->dma_rx;
> +	/* Display RX rings */
> +	for (queue =3D 0; queue < rx_cnt; queue++) {
> +		struct stmmac_rx_queue *rx_q =3D &priv->rx_queue[queue];
> =20
> -	/* Display RX ring */
> -	priv->hw->desc->display_ring(head_rx, DMA_RX_SIZE, true);
> +		pr_info("\tRX Queue %d rings\n", queue);

Nit: %u is the right specifier for unsigned integers.

> @@ -1107,46 +1135,65 @@ static int init_dma_rx_desc_rings(struct net_devi=
ce *dev, gfp_t flags)
[...]
>  err_init_rx_buffers:
> -	while (--i >=3D 0)
> -		stmmac_free_rx_buffers(priv, i);
> +	while (queue-- >=3D 0) {

Why are you switching to postfix decrement here? Not only is it
inconsistent with the prefix decrement below, I think this also gives
you a wrong result. Consider what happens if queue =3D=3D 0. The condition
evaluates to true, but within the loop the queue variable will wrap to
~0 and probably crash stmmac_free_rx_buffers().

Other than that, this looks fine, so with the above fixed:

Reviewed-by: Thierry Reding <treding@nvidia.com>

Also works on Tegra186, so:

Tested-by: Thierry Reding <treding@nvidia.com>

--tsOsTdHNUZQcU9Ye
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljj8KoACgkQ3SOs138+
s6FLFA/7BmIMjjYU1EuZ64kZ6GVr5/ooQAn15vd/XfbwLlTAxeFLDfKPw1Pw1k0n
6m1309uta6qJ+UbwxCzs2NDCKrzxe3zEeeDYr2hTXFDr7/39yIhbh9XcmOWipBXo
IdDB4BwECYCTR984HsA76lOTaUNzVjusycCuTT2pgHhSNjvu56tF/D2XzqHA1Xkg
o0TO0RqQVrH00mq0FNO1hIkLn81kcwdOqm7DHhpxuOq4F/7V7XcmQg72S7wrhzgT
JgWCv5ELbGTLcf3VHzFe3oUrlV9ADHCb25pwzqMhen7VgxOduhse7gv1RsQ11gNh
X0CS1BV3yZUBFOqSjwZWqdwfLVQ7etk0Pvwu72P0YNXqVmtVajQoe/gpzPHR7jW7
MkeLkVs/2aeFH8sUxu7DRHlKQLd6FmcLzb93X2PREbf/BEjLAqlSP9lTpb/DbztC
T5I88driDkR7PjgC4fwTNeaT5c+6+ofiIQoDblcIhzM2yQRrsP3C2NXm4cj9okkX
QcBEyi4TSiE5Skt+4WrOm3+T9hE19jAjPoxQa/SsXzBx5djKDdqCY++skw/PKPK9
c4n923JDL/lyICRzZxKD2wiuVXof+kSlOOrL8y5rMviM1MFO7bqk3S2XEMv9ZJTb
X08HGrpgHb4pX5vL2SM8Ndknmn+OwsrcRdmBsZ9pKa//ChMzG8A=
=1ksj
-----END PGP SIGNATURE-----

--tsOsTdHNUZQcU9Ye--
