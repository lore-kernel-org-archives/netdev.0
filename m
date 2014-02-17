From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: xilinx CAN controller support.
Date: Mon, 17 Feb 2014 10:37:07 +0100
Message-ID: <5301D843.2080203@pengutronix.de>
References: <93c7272e-d8bf-43af-b39b-aaa0e0b70b6f@TX2EHSMHS036.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="UsaskUTf9erEdo2oRF9JlsSduPjDf82ad"
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <93c7272e-d8bf-43af-b39b-aaa0e0b70b6f@TX2EHSMHS036.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--UsaskUTf9erEdo2oRF9JlsSduPjDf82ad
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/17/2014 10:23 AM, Kedareswara rao Appana wrote:
> This patch adds xilinx CAN controller support.
> This driver supports both ZYNQ CANPS and Soft IP
> AXI CAN controller.

I just had a quick look at the driver:

[...]

> +/**
> + * xcan_tx_interrupt - Tx Done Isr
> + * @ndev:	net_device pointer
> + */
> +static void xcan_tx_interrupt(struct net_device *ndev)
> +{
> +	struct xcan_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +
> +	stats->tx_packets++;
> +	while (priv->tx_head - priv->tx_tail > 0) {

Note, there might be still CAN frames in the TX FIFO that have not been
transmitted yet. You have to check your hardware! What to do depends on
how you FIFO is organized.

> +		can_get_echo_skb(ndev, priv->tx_tail %
> +					priv->xcan_echo_skb_max_tx);
> +		priv->tx_tail++;
> +	}
> +
> +	netif_wake_queue(ndev);
> +	can_led_event(ndev, CAN_LED_EVENT_TX);
> +}

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--UsaskUTf9erEdo2oRF9JlsSduPjDf82ad
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMB2EMACgkQjTAFq1RaXHNptACfT2egg0cYFMkxwuIAyeejFvdo
wusAn12WE2FLiigL9dC3gNBZtN1oarKm
=Z+zE
-----END PGP SIGNATURE-----

--UsaskUTf9erEdo2oRF9JlsSduPjDf82ad--
