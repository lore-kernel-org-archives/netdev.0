From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net v2] sfc: fix calling of free_irq with already free
 vector
Date: Fri, 09 May 2014 02:04:07 +0100
Message-ID: <1399597447.11946.34.camel@deadeye.wl.decadent.org.uk>
References: <1399545893-25563-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7JgV9UbiZEaNQpPmF50t"
Cc: netdev@vger.kernel.org, Zenghui Shi <zshi@redhat.com>,
	linux-net-drivers@solarflare.com,
	Shradha Shah <sshah@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52979 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753492AbaEIBET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 21:04:19 -0400
In-Reply-To: <1399545893-25563-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7JgV9UbiZEaNQpPmF50t
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-05-08 at 12:44 +0200, Nikolay Aleksandrov wrote:
> If the sfc driver is in legacy interrupt mode (either explicitly by
> using interrupt_mode module param or by falling back to it) it will
> hit a warning at kernel/irq/manage.c because it will try to free an irq
> which wasn't allocated by it in the first place because the MSI(X) irqs a=
re
> zero and it'll try to free them unconditionally. So fix it by checking if
> we're in legacy mode and freeing the appropriate irqs.

Oops, I think we had given up regular testing legacy interrupts by this
point as there seemed to be no real need for them.

> CC: Zenghui Shi <zshi@redhat.com>
> CC: Ben Hutchings <ben@decadent.org.uk>
> CC: <linux-net-drivers@solarflare.com>
> CC: Shradha Shah <sshah@solarflare.com>
> CC: David S. Miller <davem@davemloft.net>
>=20
> Fixes: 1899c111a535 ("sfc: Fix IRQ cleanup in case of a probe failure")
> Reported-by: Zenghui Shi <zshi@redhat.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
> v2: Change the fix to check for the interrupt mode and adjust the
> commit message.
>=20
>  drivers/net/ethernet/sfc/nic.c | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/ni=
c.c
> index 32d969e857f7..43761d3b8651 100644
> --- a/drivers/net/ethernet/sfc/nic.c
> +++ b/drivers/net/ethernet/sfc/nic.c
> @@ -156,13 +156,15 @@ void efx_nic_fini_interrupt(struct efx_nic *efx)
>  	efx->net_dev->rx_cpu_rmap =3D NULL;
>  #endif
> =20
> -	/* Disable MSI/MSI-X interrupts */
> -	efx_for_each_channel(channel, efx)
> -		free_irq(channel->irq, &efx->msi_context[channel->channel]);
> -
> -	/* Disable legacy interrupt */
> -	if (efx->legacy_irq)
> +	if (efx->interrupt_mode !=3D EFX_INT_MODE_LEGACY) {

Minor nit: this could use EFX_INT_MODE_USE_MSI(efx), same as in
efx_nic_init_interrupt().

> +		/* Disable MSI/MSI-X interrupts */
> +		efx_for_each_channel(channel, efx)
> +			free_irq(channel->irq,
> +				 &efx->msi_context[channel->channel]);
> +	} else {
> +		/* Disable legacy interrupt */
>  		free_irq(efx->legacy_irq, efx);
> +	}
>  }
> =20
>  /* Register dump */

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-7JgV9UbiZEaNQpPmF50t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU2wpjOe/yOyVhhEJAQrwgA//WkfBGCD5RIBME6YUC52n/9EZJEJpMeZi
IEGWuzKuX2tDoB7X5MBVrSNeIxd9yBPcZrY2NAishiUVXB1XY+kTVO5WBLvZJd5i
HgCfjouYKpv+Kll7UC1VkHz9quEJcOpD82RaG4soOb1E9l0eWPeIrL4fzNsuU8mr
1JbuXTBx+yGFSfX3YzccYTmQXbOvgjTiNhdiqWe5swKtzCFxJLAaZeFusV6p0NtY
bMnWIAR/RA5dn7y8owFYOUcV/eI42oD/HL4wsIYWYA0GNtSbSlYW57SAnQT1s9RV
VazVrdramewlPX5VINqu7zHDk1khRcWQwaBoxjo7Auwtc+IjwWUt95GDSc+E24+Z
5sjtxUsRTFH5ge15PkezCHaHAWTMtQ/LLYXEmpaEcMbcZeyWRo7FKZts49kv8uAz
KsWH0Pp9CJCqqS17ceUbl3kW765xwRw3qwFEM2AmDXIZ/EtgOxybmxPcRP6F583S
ueQAqHplUnk0V1sdKsdzdDDkL7Ify9LGHxLk6ZHp594GlupOFyaCNdPWWGKzRxEj
ZhAEMq7vyhqitKeYs4tny4Mk390QNf0cahEVfMWM5PxB4W/4V0uj7VHvVQrOjqUe
mq8BtNxjahmjjhgqaVYxgjRKSsTr+FSMgknqpRg6yCk29/iCsX5Zl/xd+5LoF+kE
fSXsjw4MWn8=
=4D8u
-----END PGP SIGNATURE-----

--=-7JgV9UbiZEaNQpPmF50t--
