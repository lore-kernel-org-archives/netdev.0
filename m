From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4] can: xilinx CAN controller support.
Date: Fri, 28 Feb 2014 09:32:21 +0100
Message-ID: <53104995.4010305@pengutronix.de>
References: <74d607e9-ac9c-4a9b-ac49-e84ae49d20c2@TX2EHSMHS031.ehs.local> <530D0A9C.5090402@pengutronix.de> <cd00fb2d-c8a7-423d-8aa0-2b413e9ac101@CO9EHSMHS017.ehs.local> <530DEA7C.6010609@pengutronix.de> <678ca296-8687-4e7c-9014-ae69d886a068@CO9EHSMHS014.ehs.local> <530E0B92.5010903@pengutronix.de> <2e3bfd38-37d5-4102-af79-821196c6c732@CH1EHSMHS006.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="IpTqo8h1sB8Vf4LgmFBEVJfosj21M4m88"
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
In-Reply-To: <2e3bfd38-37d5-4102-af79-821196c6c732@CH1EHSMHS006.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IpTqo8h1sB8Vf4LgmFBEVJfosj21M4m88
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/28/2014 06:50 AM, Appana Durga Kedareswara Rao wrote:
> Hi Marc,
>=20
>=20
>> -----Original Message-----
>> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
>> Sent: Wednesday, February 26, 2014 9:13 PM
>> To: Appana Durga Kedareswara Rao; wg@grandegger.com; Michal Simek;
>> grant.likely@linaro.org; robh+dt@kernel.org; linux-can@vger.kernel.org=

>> Cc: netdev@vger.kernel.org; linux-arm-kernel@lists.infradead.org; linu=
x-
>> kernel@vger.kernel.org; devicetree@vger.kernel.org
>> Subject: Re: [PATCH v4] can: xilinx CAN controller support.
>>
>> On 02/26/2014 03:46 PM, Appana Durga Kedareswara Rao wrote:
>>> Hi Marc,
>>>
>>>
>>>> -----Original Message-----
>>>> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
>>>> Sent: Wednesday, February 26, 2014 6:52 PM
>>>> To: Appana Durga Kedareswara Rao; wg@grandegger.com; Michal Simek;
>>>> grant.likely@linaro.org; robh+dt@kernel.org;
>>>> linux-can@vger.kernel.org
>>>> Cc: netdev@vger.kernel.org; linux-arm-kernel@lists.infradead.org;
>>>> linux- kernel@vger.kernel.org; devicetree@vger.kernel.org
>>>> Subject: Re: [PATCH v4] can: xilinx CAN controller support.
>>>>
>>>> On 02/26/2014 02:07 PM, Appana Durga Kedareswara Rao wrote:
>>>>>> This loop looks broken. Can you explain how it works.
>>>>>>
>>>>>> What it shoud do is:
>>>>>> We have put (priv->tx_head - priv->tx_tail) CAN frames into the FI=
FO.
>>>>>> This means at maximum there could be this amount of CAN frames
>>>>>> which have been successfully transmitted. For every cycle in this
>>>>>> while loop you
>>>>>> should:
>>>>>> a) check if a CAN frame has successfully been transmitted
>>>>>>    (as this CAN core uses a FIFO it should be "oldest")
>>>>>>    A read_reg() of some kind is missing in your loop.
>>>>>> b) if needed, remove this event from the FIFO or
>>>>>>    mark the interrupt as done. Whatever you hardware needs.
>>>>>> c) update your statistics
>>>>>> d) Use can_get_echo_skb to push this frame into the networking
>>>>>> stack
>>>>>> e) As a CAN frame has been transmitted successfully, wake the
>> tx_queue.
>>>>>>
>>>>>>> +   while (priv->tx_head - priv->tx_tail > 0) {
>>>>>>> +           if (isr & XCAN_IXR_TXFLL_MASK) {
>>>>>>> +                   priv->write_reg(priv, XCAN_ICR_OFFSET,
>>>>>>> +                                   XCAN_IXR_TXFLL_MASK);
>>>>>>> +                   netif_stop_queue(ndev);
>>>>>>
>>>>>> Why do you stop the queue here? A CAN frame has successfully been
>>>>>> transmitted, there should be room in the FIFO.
>>>>>>
>>>>>>> +                   break;
>>>>>>> +           }
>>>>>>> +           can_get_echo_skb(ndev, priv->tx_tail %
>>>>>>> +                                   priv->xcan_echo_skb_max_tx);
>>>>>>> +           priv->tx_tail++;
>>>>>>> +   }
>>>>>>> +
>>>>>
>>>>> The below are the bit fields available for the Transmit FIFO.
>>>>> 1) In the ISR(interrupt status register)  Tx Ok interrupt and Tx
>>>>> fifo full
>>>> interrupt.
>>>>> 2) in the SR(Status Register) Tx fifo full condition.
>>>>>
>>>>>
>>>>> I am modifying the entire tx interrupt logic to like below.
>>>>>
>>>>> static void xcan_tx_interrupt(struct net_device *ndev, u32 isr) {
>>>>>         struct xcan_priv *priv =3D netdev_priv(ndev);
>>>>>         struct net_device_stats *stats =3D &ndev->stats;
>>>>>
>>>>>             while (priv->tx_head - priv->tx_tail > 0) {
>>>>>                 if (isr & XCAN_IXR_TXFLL_MASK) {
>>>>>                         priv->write_reg(priv, XCAN_ICR_OFFSET,
>>>>>                                         XCAN_IXR_TXFLL_MASK);
>>>>>                           break;
>>>>>                 }
>>>>>                 can_get_echo_skb(ndev, priv->tx_tail %
>>>>>                                         priv->xcan_echo_skb_max_tx)=
;
>>>>>                 priv->tx_tail++;
>>>>>          stats->tx_packets++;
>>>>>         netif_wake_queue(ndev);
>>>>>               can_led_event(ndev, CAN_LED_EVENT_TX);
>>>>>
>>>>>         }
>>>>
>>>> You just need to wake the queue once.
>>>
>>> Ok
>>>>
>>>>> }
>>>>>
>>>>>
>>>>> Are you Ok with the above logic?
>>>>
>>>> No, how can you tell how many frames have been transmitted?
>>>
>>> There is no register to read how many can frames are transmitted.
>>> The only way to know Is by reading this parameter
>>> (stats->tx_packets++;) through ip command
>>
>> stats->tx_packets is calculated in the above loop and the loop is
>> broken. Let me illustrate the problem:
>>
>> - xmit is called 10 times in a row
>> - this means you have 10 CAN frames in the TX FIFO
>> - a single CAN frame gets transmitted
>> - you get an interrupt
>> - you enter the above routine and loop 10 times and echo the CAN frame=

>>   back into the stack
>>
>> Now every application sees 10 transmitted packages, but there is only =
one
>> transmitted. Every time you loop you have to check if the CAN frame ha=
s
>> already been transmitted or not. Is that possible with the hardware?
>=20
>         The only way to know whether the TX packet is transmitted succe=
ssfully or not is by using the Tx Ok interrupt from the ISR.
> This interrupt will come for every Tx Packet.
> So I am thinking of there is no loop required in the TX interrupt routi=
ne. As it is called for each and every packet.

What happens if the interrupt handler is delayed? For example in a RT
enabled system the interrupt handler runs as a thread. There might be
other threads with higher priority. The hardware will probably send all
CAN frames in the FIFO, so you want to reduce the overhead and loop in
the tx complete handler.

>=20
> static void xcan_tx_interrupt(struct net_device *ndev, u32 isr)
> {
>         struct xcan_priv *priv =3D netdev_priv(ndev);
>         struct net_device_stats *stats =3D &ndev->stats;
>=20
>=20
>         can_get_echo_skb(ndev, priv->tx_tail %
>                                 priv->xcan_echo_skb_max_tx);
>         priv->tx_tail++;
>         stats->tx_packets++;
>         can_led_event(ndev, CAN_LED_EVENT_TX);
>         netif_wake_queue(ndev);
> }
>=20
> If you want me to put some locks for this Will put some spin_locks in t=
he _xmit and in the tx interrupt routine (for the tx_head and tx_tail).

There is no need for locking regarding tx_{head,tail}. As the tx
complete handler only increments tx_tail and the xmit routine increments
tx_head.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--IpTqo8h1sB8Vf4LgmFBEVJfosj21M4m88
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMQSZYACgkQjTAFq1RaXHNREgCfbyE5Y8ZffmMbDZZDPr4QyOn7
XRsAnRil2Ea8B9VjQIeqU+7UiQP+rINo
=/hqT
-----END PGP SIGNATURE-----

--IpTqo8h1sB8Vf4LgmFBEVJfosj21M4m88--
