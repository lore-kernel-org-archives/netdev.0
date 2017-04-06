From: Thierry Reding <treding@nvidia.com>
Subject: Re: [PATCH 2/4 v3 net-next] net: stmmac: adding multiple buffers for
 rx
Date: Thu, 6 Apr 2017 14:32:17 +0200
Message-ID: <20170406123217.GB5115@ulmo.ba.sec>
References: <cover.1491467980.git.jpinto@synopsys.com>
 <05dcbd78e826eb2874cdce699e24274d0af680a0.1491467980.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="i0/AhcQY5QxfSsSZ"
Cc: <davem@davemloft.net>, <clabbe.montjoie@gmail.com>,
        <niklas.cassel@axis.com>, <julia.lawall@lip6.fr>,
        <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate15.nvidia.com ([216.228.121.64]:6521 "EHLO
        hqemgate15.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756806AbdDFMc1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:32:27 -0400
In-Reply-To: <05dcbd78e826eb2874cdce699e24274d0af680a0.1491467980.git.jpinto@synopsys.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Apr 06, 2017 at 09:49:09AM +0100, Joao Pinto wrote:
[...]
>  err_init_rx_buffers:
> -	while (--i >= 0)
> -		stmmac_free_rx_buffer(priv, i);
> +	while (queue >= 0) {

I /think/ this could simply be:

	while (queue--) {
		...
	}

That evaluates before the decrement and hence properly deals with the
case of 0. The difference to your code is that it will skip the first
iteration, but I think that's fine because stmmac_init_rx_buffers()
already cleans up properly, so the queue'th element doesn't have to
be freed again.

Anyway, I think your version will work just as well.

Thierry

--i0/AhcQY5QxfSsSZ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljmNVEACgkQ3SOs138+
s6E8ng//UXrQCfpmdBfVrR95Pbrp3d7YCe14WiZXmPcRM8GfRJrApl/Wr0Ym4FI3
0FQxV3O4Lsqj+es2GE3gLh/SWMOOtoqsbOt7wX7HLO5Ch0NgXlQApp2fRnB5Wnxp
LnMxnOf6r9myXTpOhwFjZj0izZWCOQHz08W5xtf6eLqx372GkKZNyGxGwPg3O6HF
/dUF6gunPvbHlms/aXfnLtWKqQpMN1b++2jzFd30mXft91bi/FR0jfd31OZvszv9
7GnoK1QA4zB3DE5mJ+jkL3Vv/XLHbwBo0A8B64wB53QRZ1yQGVug0J3T1fA06Gwh
8WHWOgXNtf2B7ET4Dp8iFPS3n2ye/Uq32G3PJUwNxUYOFxiID5bRZ0aKYlaDhw3K
YFpDM09ymbb/aCy7zkvyyrBRlRn9zuioWdNu05LIrK9r4NjYo0cAIMeLWHVWgjqU
id47P8elpGoVUk3wVuLzPcOn9F4LZBCHLTujL4Hc6x3BinJFLajhTEp/UvECtKG4
tUdZfS2S/9K/DsJnVZ4uT03s/jt5WC1h6KhGNc5Br0zMP36ZfkAJZ4F0f7Chiqcn
RWW7Of1cmCICX8sMedlYeZNczTEomf85/xB4oB4aLyKKbDWaKegvNV1vNhbO+v/a
2Vhy2m9/Rg37BLiQeTX/Oz7VeNslZr+GskcUVpvb40BDaA+svqI=
=iFDe
-----END PGP SIGNATURE-----

--i0/AhcQY5QxfSsSZ--
