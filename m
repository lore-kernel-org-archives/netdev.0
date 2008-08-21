From: Timothy J Fontaine <tjfontaine@atxconsulting.com>
Subject: Re: r8169 MTU greater than 1500 causes corruption for other
	controllers
Date: Thu, 21 Aug 2008 11:20:27 -0400
Message-ID: <20080821152025.GA29610@tophat.atxconsulting.com>
References: <20080820170951.GA1771@tophat.atxconsulting.com> <Pine.LNX.4.64.0808202053510.24321@wrl-59.cs.helsinki.fi> <20080820214350.GA18747@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IS0zKkzwUGydFO0o"
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760683AbYHUPUr@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080820214350.GA18747@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 20, 2008 at 11:43:50PM +0200, Francois Romieu wrote:
> Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> :
> [...]
> > Hmm, there was no explanation why the tp->rx_buf_sz to pkt_size change
> > was made in that commit (I have no idea whether those sizes have to mat=
ch=20
> > to other places that use tp->rx_buf_sz)...
>=20
> Because there is no need to sync data that has not been used ?
>=20
> Timothy, could you check if the patch below does the job too ? It should
> fix at least one pci_map / pci_unmap unbalance.
>=20
> @@ -2789,10 +2789,10 @@ static int rtl8169_rx_interrupt(struct net_device=
 *dev,
> =20
>  			if (rtl8169_try_rx_copy(&skb, tp, pkt_size, addr)) {
>  				pci_dma_sync_single_for_device(pdev, addr,
>  					pkt_size, PCI_DMA_FROMDEVICE);
>  				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
>  			} else {
> -				pci_unmap_single(pdev, addr, pkt_size,
> +				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
>  						 PCI_DMA_FROMDEVICE);
>  				tp->Rx_skbuff[entry] =3D NULL;
>  			}
>=20
> --=20
> Ueimor

Yup, this patch also works.

tjfontaine

--IS0zKkzwUGydFO0o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkith7cACgkQfTP/nQJGQG368gCfThk2/AYxy4eokxL2waGMVdOh
V28AnRo7+OavSHWbK6ZzK6TIT0ujABkK
=laHS
-----END PGP SIGNATURE-----

--IS0zKkzwUGydFO0o--
