From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] CAN: Add Flexcan CAN controller driver
Date: Thu, 22 Jul 2010 11:33:24 +0200
Message-ID: <4C481064.8090809@pengutronix.de>
References: <1279144811-12251-1-git-send-email-mkl@pengutronix.de>	<4C3F55A9.8030307@grandegger.com>	<4C405CEC.3000701@pengutronix.de>
	<4C475BA6.3030505@pengutronix.de> <4C480E7E.70607@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5480349695091614268=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C480E7E.70607-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============5480349695091614268==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9884F7C86BE83203C3CF8C5A"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9884F7C86BE83203C3CF8C5A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Wolfgang Grandegger wrote:
> On 07/21/2010 10:42 PM, Marc Kleine-Budde wrote:
>> Marc Kleine-Budde wrote:
>>> Wolfgang Grandegger wrote:
>>>> I realized a few issues. You can add my "acked-by" when they are fix=
ed.
>>> thanks for the review.
>> [...]
>>
>>>>> +static void flexcan_poll_err_frame(struct net_device *dev,
>>>>> +				   struct can_frame *cf, u32 reg_esr)
>>>>> +{
>>>>> +	struct flexcan_priv *priv =3D netdev_priv(dev);
>>>>> +	int error_warning =3D 0, rx_errors =3D 0, tx_errors =3D 0;
>>>>> +
>>>>> +	if (reg_esr & FLEXCAN_ESR_BIT1_ERR) {
>>>>> +		rx_errors =3D 1;
>>>>> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>>>> +		cf->data[2] |=3D CAN_ERR_PROT_BIT1;
>>>>> +	}
>>>>> +
>>>>> +	if (reg_esr & FLEXCAN_ESR_BIT0_ERR) {
>>>>> +		rx_errors =3D 1;
>>>>> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>>>> +		cf->data[2] |=3D CAN_ERR_PROT_BIT0;
>>>>> +	}
>>>>> +
>>>>> +	if (reg_esr & FLEXCAN_ESR_FRM_ERR) {
>>>>> +		rx_errors =3D 1;
>>>>> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>>>> +		cf->data[2] |=3D CAN_ERR_PROT_FORM;
>>>>> +	}
>>>>> +
>>>>> +	if (reg_esr & FLEXCAN_ESR_STF_ERR) {
>>>>> +		rx_errors =3D 1;
>>>>> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>>>> +		cf->data[2] |=3D CAN_ERR_PROT_STUFF;
>>>>> +	}
>>>>> +
>>>>> +
>>>>> +	if (reg_esr & FLEXCAN_ESR_ACK_ERR) {
>>>>> +		tx_errors =3D 1;
>>>>> +		cf->can_id |=3D CAN_ERR_ACK;
>>>> This is a bus-error as well. Therefore I think it should be:
>>>>
>>>> 	if (reg_esr & FLEXCAN_ESR_ACK_ERR) {
>>>> 		tx_errors =3D 1;
>>>> 		cf->can_id |=3D CAN_ERR_ACK;
>>>> 		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>>> 		cf->data[3] |=3D CAN_ERR_PROT_LOC_ACK; /* ACK slot */
>>>> 	}
>>>>
>>>> I need to check what CAN_ERR_ACK is intended for. Then, cf->can_id c=
ould
>>>> be preset with "CAN_ERR_PROT | CAN_ERR_BUSERROR" at the beginning.
>> This controller issues an ACK error if there are no other nodes on the=

>> CAN bus to send a ACK that the message has been received. Or all
>> remaining Nodes are in bus off state.
>=20
> Mainly this bus error can cause the infamous IRQ and message flooding
> when no cable is connected.

No cable connected can (if your node doesn't have an activated on baord
termination) result in no termination at all, and this may result in a
different error.

At least it does on the at91. I haven't checked with the flexcan.

The subtile difference is that the CAN controller isn't allowed to go
into bus-off with a proper terminated bus when it recevies no ACKs, but
going to bus off on a not terminated bus is okay.

>> From the datasheet:
>> "This bit indicates that an acknowledge (ACK) error has been detected =
by
>> the transmitter node; that is, a dominant bit has not been detected
>> during the ACK SLOT."
>=20
> That's what the above error describes, like on the SJA1000, apart from
> setting CAN_ERR_ACK. Setting CAN_ERR_ACK is somehow bogus, but just
> leave it for the time being. I will fix it globally when time permits.

Now I'm confused. What's the meaning of CAN_ERR_ACK? When should it be us=
ed?

Cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig9884F7C86BE83203C3CF8C5A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkxIEGgACgkQjTAFq1RaXHPhTwCfWcOuHr8g8oerDEe1VCaKrSub
Lq4AnjwqZ84BoQhRE8/o2JVK3kxpQYuj
=YmVn
-----END PGP SIGNATURE-----

--------------enig9884F7C86BE83203C3CF8C5A--

--===============5480349695091614268==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============5480349695091614268==--
