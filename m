From: Simon Guinot <simon.guinot@sequanux.org>
Subject: Re: [PATCH v2 net 4/6] net: mvneta: fix error path for building skb
Date: Thu, 26 Nov 2015 19:38:53 +0100
Message-ID: <20151126183853.GI4665@kw.sim.vm.gnt>
References: <1448561293-16431-1-git-send-email-mw@semihalf.com>
 <1448561293-16431-5-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TWU5dZlpCh7alCLz"
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	andrew@lunn.ch, linux@arm.linux.org.uk, jason@lakedaemon.net,
	myair@marvell.com, jaz@semihalf.com, xswang@marvell.com,
	nadavh@marvell.com, alior@marvell.com, stable@vger.kernel.org,
	tn@semihalf.com, gregory.clement@free-electrons.com,
	nitroshift@yahoo.com, davem@davemloft.net,
	sebastian.hesselbarth@gmail.com
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vm1.sequanux.org ([188.165.36.56]:35180 "EHLO vm1.sequanux.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752722AbbKZSa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Nov 2015 13:30:58 -0500
Content-Disposition: inline
In-Reply-To: <1448561293-16431-5-git-send-email-mw@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--TWU5dZlpCh7alCLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 26, 2015 at 07:08:11PM +0100, Marcin Wojtas wrote:
> In the actual RX processing, there is same error path for both descriptor
> ring refilling and building skb fails. This is not correct, because after
> successful refill, the ring is already updated with newly allocated
> buffer. Then, in case of build_skb() fail, hitherto code left the original
> buffer unmapped.
>=20
> This patch fixes above situation by swapping error check of skb build with
> DMA-unmap of original buffer.
>=20
> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
> Cc: <stable@vger.kernel.org> # v4.2+
> Fixes a84e32894191 ("net: mvneta: fix refilling for Rx DMA buffers")
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>=20

Acked-by: Simon Guinot <simon.guinot@sequanux.org>

Thanks,

Simon

> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet=
/marvell/mvneta.c
> index 0c3d923..62cf971 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -1580,12 +1580,16 @@ static int mvneta_rx(struct mvneta_port *pp, int =
rx_todo,
>  		}
> =20
>  		skb =3D build_skb(data, pp->frag_size > PAGE_SIZE ? 0 : pp->frag_size);
> -		if (!skb)
> -			goto err_drop_frame;
> =20
> +		/* After refill old buffer has to be unmapped regardless
> +		 * the skb is successfully built or not.
> +		 */
>  		dma_unmap_single(dev->dev.parent, phys_addr,
>  				 MVNETA_RX_BUF_SIZE(pp->pkt_size), DMA_FROM_DEVICE);
> =20
> +		if (!skb)
> +			goto err_drop_frame;
> +
>  		rcvd_pkts++;
>  		rcvd_bytes +=3D rx_bytes;
> =20
> --=20
> 1.8.3.1
>=20
>=20
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--TWU5dZlpCh7alCLz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlZXUb0ACgkQgtp0PDeOcDpg8gCfbnLMa46vuSdpDfVDgoTqHx1v
Lt0AniNpPuaO6hAEu0Ezoapw7vWLyMKc
=vRBo
-----END PGP SIGNATURE-----

--TWU5dZlpCh7alCLz--
