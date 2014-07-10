From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH net v2 2/7] net: cpmac: fix comments
Date: Thu, 10 Jul 2014 08:07:23 -0500
Message-ID: <20140710130723.GB15340@saruman.home>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
 <1404970545-26508-3-git-send-email-varkabhadram@gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IrhDeMKUP4DT/M7F"
Cc: <netdev@vger.kernel.org>, <mugunthanvnm@ti.com>,
	<linux@rainbow-software.org>, <balbi@ti.com>,
	<george.cherian@ti.com>, <davem@davemloft.net>,
	Varka Bhadram <varkab@cdac.in>
To: <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:54725 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753446AbaGJNI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2014 09:08:29 -0400
Content-Disposition: inline
In-Reply-To: <1404970545-26508-3-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--IrhDeMKUP4DT/M7F
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 10, 2014 at 11:05:40AM +0530, varkabhadram@gmail.com wrote:
> From: Varka Bhadram <varkab@cdac.in>
>=20
> This patch convert the normal comments to networking subsystem
> style comments.
>=20
> Signed-off-by: Varka Bhadram <varkab@cdac.in>

Reviewed-by: Felipe Balbi <balbi@ti.com>

> ---
>  drivers/net/ethernet/ti/cpmac.c |   40 ++++++++++++++++++++-------------=
------
>  1 file changed, 21 insertions(+), 19 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cp=
mac.c
> index 61eb691..1d8ef39 100644
> --- a/drivers/net/ethernet/ti/cpmac.c
> +++ b/drivers/net/ethernet/ti/cpmac.c
> @@ -118,8 +118,8 @@ MODULE_PARM_DESC(dumb_switch, "Assume switch is not c=
onnected to MDIO bus");
>  #define CPMAC_TX_ACK(channel)		(0x0640 + (channel) * 4)
>  #define CPMAC_RX_ACK(channel)		(0x0660 + (channel) * 4)
>  #define CPMAC_REG_END			0x0680
> -/*
> - * Rx/Tx statistics
> +
> +/* Rx/Tx statistics
>   * TODO: use some of them to fill stats in cpmac_stats()
>   */
>  #define CPMAC_STATS_RX_GOOD		0x0200
> @@ -331,8 +331,7 @@ static void cpmac_set_multicast_list(struct net_devic=
e *dev)
>  			cpmac_write(priv->regs, CPMAC_MAC_HASH_LO, 0xffffffff);
>  			cpmac_write(priv->regs, CPMAC_MAC_HASH_HI, 0xffffffff);
>  		} else {
> -			/*
> -			 * cpmac uses some strange mac address hashing
> +			/* cpmac uses some strange mac address hashing
>  			 * (not crc32)
>  			 */
>  			netdev_for_each_mc_addr(ha, dev) {
> @@ -432,10 +431,10 @@ static int cpmac_poll(struct napi_struct *napi, int=
 budget)
> =20
>  		if ((desc->dataflags & CPMAC_EOQ) !=3D 0) {
>  			/* The last update to eoq->hw_next didn't happen
> -			* soon enough, and the receiver stopped here.
> -			*Remember this descriptor so we can restart
> -			* the receiver after freeing some space.
> -			*/
> +			 * soon enough, and the receiver stopped here.
> +			 * Remember this descriptor so we can restart
> +			 * the receiver after freeing some space.
> +			 */
>  			if (unlikely(restart)) {
>  				if (netif_msg_rx_err(priv))
>  					printk(KERN_ERR "%s: poll found a"
> @@ -457,25 +456,27 @@ static int cpmac_poll(struct napi_struct *napi, int=
 budget)
> =20
>  	if (desc !=3D priv->rx_head) {
>  		/* We freed some buffers, but not the whole ring,
> -		 * add what we did free to the rx list */
> +		 * add what we did free to the rx list
> +		 */
>  		desc->prev->hw_next =3D (u32)0;
>  		priv->rx_head->prev->hw_next =3D priv->rx_head->mapping;
>  	}
> =20
>  	/* Optimization: If we did not actually process an EOQ (perhaps because
>  	 * of quota limits), check to see if the tail of the queue has EOQ set.
> -	* We should immediately restart in that case so that the receiver can
> -	* restart and run in parallel with more packet processing.
> -	* This lets us handle slightly larger bursts before running
> -	* out of ring space (assuming dev->weight < ring_size) */
> +	 * We should immediately restart in that case so that the receiver can
> +	 * restart and run in parallel with more packet processing.
> +	 * This lets us handle slightly larger bursts before running
> +	 * out of ring space (assuming dev->weight < ring_size)
> +	 */
> =20
>  	if (!restart &&
>  	     (priv->rx_head->prev->dataflags & (CPMAC_OWN|CPMAC_EOQ))
>  		    =3D=3D CPMAC_EOQ &&
>  	     (priv->rx_head->dataflags & CPMAC_OWN) !=3D 0) {
>  		/* reset EOQ so the poll loop (above) doesn't try to
> -		* restart this when it eventually gets to this descriptor.
> -		*/
> +		 * restart this when it eventually gets to this descriptor.
> +		 */
>  		priv->rx_head->prev->dataflags &=3D ~CPMAC_EOQ;
>  		restart =3D priv->rx_head;
>  	}
> @@ -506,7 +507,8 @@ static int cpmac_poll(struct napi_struct *napi, int b=
udget)
>  		       priv->dev->name, received);
>  	if (processed =3D=3D 0) {
>  		/* we ran out of packets to read,
> -		 * revert to interrupt-driven mode */
> +		 * revert to interrupt-driven mode
> +		 */
>  		napi_complete(napi);
>  		cpmac_write(priv->regs, CPMAC_RX_INT_ENABLE, 1);
>  		return 0;
> @@ -516,8 +518,8 @@ static int cpmac_poll(struct napi_struct *napi, int b=
udget)
> =20
>  fatal_error:
>  	/* Something went horribly wrong.
> -	 * Reset hardware to try to recover rather than wedging. */
> -
> +	 * Reset hardware to try to recover rather than wedging.
> +	 */
>  	if (netif_msg_drv(priv)) {
>  		printk(KERN_ERR "%s: cpmac_poll is confused. "
>  				"Resetting hardware\n", priv->dev->name);
> @@ -751,7 +753,7 @@ static void cpmac_check_status(struct net_device *dev)
>  	if (rx_code || tx_code) {
>  		if (netif_msg_drv(priv) && net_ratelimit()) {
>  			/* Can't find any documentation on what these
> -			 *error codes actually are. So just log them and hope..
> +			 * error codes actually are. So just log them and hope..
>  			 */
>  			if (rx_code)
>  				printk(KERN_WARNING "%s: host error %d on rx "
> --=20
> 1.7.9.5
>=20

--=20
balbi

--IrhDeMKUP4DT/M7F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTvpALAAoJEIaOsuA1yqREuesQAKsgXDe+F6VDQc5zXdRTW8Mi
ObTLTNWIdT1vDJeao7bWK/XElovb4vvvjculNbaWg30t0Sr3VdhRoKRPEgpaPAYe
i5sbeusj2z+Se0zgC12crplSc5t/2YOr/LHkYQaUax5AI3MTDQTFHL7OlS6W0cwC
ZdZ3826QHGs+7xCTV/PyO7xDyvKdeJPlYefXfA4lICCRvis2NKwuN6hq+YZmYnlU
+Ko7ICyTX8aHrCIS1cstcNIDIF8Uil/zZsJj6sxd30ojKrXRVdNvKWZYtb+uYolU
AWlnWIJyEhzXgnF6T3wKEns/rbC4RZI+q5sqqiKHUbBn0U6uyK36MifDJUhEVgj5
QpwIvJqHb2gXVDxEDezRsS/p5SSFFQ2RHvZXLj9ho/ECDLZ0F03eoiCp0rcZ5dyA
884u+yU9UUuLtmW+/jq0LbKZ/I4hF0gyBmz9y8v+8II4Zmm8EVOBavf9rGGQ0b/u
vSvoL78eBQ2cvSPIK/2sG7y9WVyduUnV7HVUr4ilQAMB1ydSgP8+zGEWHdvyg2uQ
XtOi9jYWnsAMo/9ba5Hwex2EzJMea2TKiECN1eUUBWFwB2+iJ7kNvkD20n96PWCO
4SSQ+FvMFr8H+czfOGCcn/jwubuz1jh0y/X+erYcArHWZ6MS7yXbpv+d6gJHDh5y
VXplCvoNtWjVAT+D/E8e
=H5V8
-----END PGP SIGNATURE-----

--IrhDeMKUP4DT/M7F--
