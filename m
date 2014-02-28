From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4] can: xilinx CAN controller support.
Date: Fri, 28 Feb 2014 14:15:27 +0100
Message-ID: <53108BEF.1020308@pengutronix.de>
References: <74d607e9-ac9c-4a9b-ac49-e84ae49d20c2@TX2EHSMHS031.ehs.local> <530D0A9C.5090402@pengutronix.de> <cd00fb2d-c8a7-423d-8aa0-2b413e9ac101@CO9EHSMHS017.ehs.local> <530DEA7C.6010609@pengutronix.de> <678ca296-8687-4e7c-9014-ae69d886a068@CO9EHSMHS014.ehs.local> <530E0B92.5010903@pengutronix.de> <2e3bfd38-37d5-4102-af79-821196c6c732@CH1EHSMHS006.ehs.local> <53104995.4010305@pengutronix.de> <48409965-e214-43b7-8b6a-08bf075707e1@CO9EHSMHS001.ehs.local> <53108798.7090902@pengutronix.de> <4902b8d8-139a-4fd0-9e6e-a30ce7e6683b@CH1EHSMHS019.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="BqccfKe4b5F00xdVAJSqp3LTVQq5PE8IE"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	Michal Simek <michals@xilinx.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4902b8d8-139a-4fd0-9e6e-a30ce7e6683b@CH1EHSMHS019.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--BqccfKe4b5F00xdVAJSqp3LTVQq5PE8IE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/28/2014 02:07 PM, Appana Durga Kedareswara Rao wrote:
>>>> What happens if the interrupt handler is delayed? For example in a R=
T
>>>> enabled system the interrupt handler runs as a thread. There might b=
e
>>>> other threads with higher priority. The hardware will probably send
>>>> all CAN frames in the FIFO, so you want to reduce the overhead and
>>>> loop in the tx complete handler.
>>>>
>>> Yes I agree with your comment.
>>> It will be good to have a loop in the Tx interrupt handler I am
>>> modifying the Tx interrupt handler like below.
>>>
>>> static void xcan_tx_interrupt(struct net_device *ndev, u32 isr) {
>>>         struct xcan_priv *priv =3D netdev_priv(ndev);
>>>         struct net_device_stats *stats =3D &ndev->stats;
>>>
>>>         while (priv->tx_head - priv->tx_tail > 0) {
>>>                 if (!(isr & XCAN_IXR_TXOK_MASK)) {
>>>                         break;
>>>                 }
>>>                 can_get_echo_skb(ndev, priv->tx_tail %
>>>                                         priv->xcan_echo_skb_max_tx);
>>>                 priv->tx_tail++;
>>>                 stats->tx_packets++;
>>>                 can_led_event(ndev, CAN_LED_EVENT_TX);

Probably first clear the interrupt, because you've just handled it, then
check if it's still present. The question is, do you have to clear the
IRQ for each transmitted frame, or does one clean of the interrupt clear
the bit for more then one transmitted frame?

>>>                 isr =3D priv->read_reg(priv, XCAN_ISR_OFFSET);
>             --> clear Tx OK interrupt.

>=20
>>>         }
>>>         netif_wake_queue(ndev);
>>> }
>>>
>>> Are you Ok with this?

Were getting there :)

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--BqccfKe4b5F00xdVAJSqp3LTVQq5PE8IE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMQi+8ACgkQjTAFq1RaXHPqFwCgidLsjs4bf60MlQaZsLvSmgvE
hugAn1Et9bzUjDb07qlE8dv+dsDEfaV7
=OMGk
-----END PGP SIGNATURE-----

--BqccfKe4b5F00xdVAJSqp3LTVQq5PE8IE--
