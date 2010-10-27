From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix
	buildwarnings
Date: Wed, 27 Oct 2010 15:14:58 +0200
Message-ID: <4CC825D2.3030108@pengutronix.de>
References: <4CC61B1B.3090602@dsn.okisemi.com>	<20101026.105206.15244527.davem@davemloft.net>	<20101026.105545.200376685.davem@davemloft.net><4CC71DA4.3020600@grandegger.com>
	<4CC72360.1070608@pengutronix.de>
	<008201cb75c9$f27ff720$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0379414717114350458=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org,
	sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, chripell-VaTbYqLCNhc@public.gmane.org,
	morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <008201cb75c9$f27ff720$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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
--===============0379414717114350458==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7B537A5553CAFC1A77315BE5"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7B537A5553CAFC1A77315BE5
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/27/2010 01:27 PM, Tomoya MORINAGA wrote:
> On Wednesday, October 27, 2010 3:52 AM :  Marc Kleine-Budde and Wolfgan=
g Grandegge wrote:

>> Do I understand your code correctly? You have a big loop, but only do
>>  two different things at certain values of the loop? Smells fishy.
> Uh, I can't understand your intention.
> Please show in detail.

It's easier to talk about code when we can see it, pelase don't delete :)=


>> +static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
>> > +{
>> > +	int i;
>> > +	unsigned long flags;
>> > +
>> > +	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
>> > +
>> > +	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
>> > +		if (priv->msg_obj[i] =3D=3D MSG_OBJ_RX) {
>                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>> > +			iowrite32(CAN_CMASK_RX_TX_GET,
>> > +				&priv->regs->if1_cmask);
>> > +			pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
>> > +
>> > +			iowrite32(0x0, &priv->regs->if1_id1);
>> > +			iowrite32(0x0, &priv->regs->if1_id2);
>> > +
>> > +			pch_can_bit_set(&priv->regs->if1_mcont,
>> > +					CAN_IF_MCONT_UMASK);
>> > +
>> > +			/* Set FIFO mode set to 0 except last Rx Obj*/
>> > +			pch_can_bit_clear(&priv->regs->if1_mcont,
>> > +					  CAN_IF_MCONT_EOB);
>> > +			/* In case FIFO mode, Last EoB of Rx Obj must be 1 */
>> > +			if (i =3D=3D (PCH_RX_OBJ_NUM - 1))
>> > +				pch_can_bit_set(&priv->regs->if1_mcont,
>> > +						  CAN_IF_MCONT_EOB);
>> > +
>> > +			iowrite32(0, &priv->regs->if1_mask1);
>> > +			pch_can_bit_clear(&priv->regs->if1_mask2,
>> > +					  0x1fff | CAN_MASK2_MDIR_MXTD);
>> > +
>> > +			/* Setting CMASK for writing */
>> > +			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
>> > +				  CAN_CMASK_ARB | CAN_CMASK_CTRL,
>> > +				  &priv->regs->if1_cmask);
>> > +
>> > +			pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
>> > +		} else if (priv->msg_obj[i] =3D=3D MSG_OBJ_TX) {
>                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>=20
> Do I understand your code correctly? You have a big loop, but only do
> two different things at certain values of the loop? Smells fishy.

Looking again at the code it makes sense as it is :) Sorry for the
confusion.

>> > +			iowrite32(CAN_CMASK_RX_TX_GET,
>> > +				&priv->regs->if2_cmask);
>> > +			pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
>> > +
>> > +			/* Resetting DIR bit for reception */
>> > +			iowrite32(0x0, &priv->regs->if2_id1);
>> > +			iowrite32(0x0, &priv->regs->if2_id2);
>> > +			pch_can_bit_set(&priv->regs->if2_id2, CAN_ID2_DIR);
>> > +
>> > +			/* Setting EOB bit for transmitter */
>> > +			iowrite32(CAN_IF_MCONT_EOB, &priv->regs->if2_mcont);
>> > +
>> > +			pch_can_bit_set(&priv->regs->if2_mcont,
>> > +					CAN_IF_MCONT_UMASK);
>> > +
>> > +			iowrite32(0, &priv->regs->if2_mask1);
>> > +			pch_can_bit_clear(&priv->regs->if2_mask2, 0x1fff);
>> > +
>> > +			/* Setting CMASK for writing */
>> > +			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
>> > +				  CAN_CMASK_ARB | CAN_CMASK_CTRL,
>> > +				  &priv->regs->if2_cmask);
>> > +
>> > +			pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
>> > +		}
>> > +	}
>> > +	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
>> > +}

> This processing does configuration for all message objects.

Yeah, got it. However I think you can get rid of the priv->msg_obj
variable altogether. Let me recapitulate:
- you setup priv->msg_obj[] in the probe function, which defines if a
  msg_obj is a rx or tx
- this definition is never changed
- all objects of one kind are in a row

So you can identify the purpose of a msg_obj by simply looking at it's
number. If you need to loop over them you can even define helper
functions like, for_each_rx_obj().

>> what does this loop do? why is it nessecarry? I don't like delay loops=

>>   in the hot path of a driver.
> This loop is for waiting for all tx Message Object completion.
> This is Topcliff CAN HW specification.

Can you give us a pointer into intel's documentation?
I think Wolfgang already suggested to check if the chip is busy _before_
accessing it instead of waiting the chip to finish after accessing.

>> If you figured out how to use the endianess conversion functions from
>> the cpu_to_{le,be}-{le,to}_to_cpup family use them here, too.
> Uh,le32_to_cpu have been used already here.

Let's look at the code:

>> +		for (i =3D 0, j =3D 0; i < cf->can_dlc; j++) {
>> > +			reg =3D ioread32(&priv->regs->if1_dataa1 + j*4);
>> > +			cf->data[i++] =3D cpu_to_le32(reg & 0xff);
>> > +			if (i =3D=3D cf->can_dlc)
>> > +				break;
>> > +			cf->data[i++] =3D cpu_to_le32((reg >> 8) & 0xff);
>> > +		}

What does the code do? It swaps bytes because the data bytes in the can
core is arranged differently compared to the data in the struct can_frame=
=2E

According to the datasheet if_dataa1 holds 1st byte in bits 07:00 and
2nd byte in 15:08. (The rest is reserved.) So in the memory it looks
like this:

  xx xx byte1 byte0

The can_frame has a different layout:

	__u8    data[8] __attribute__((aligned(8)));

which is in memory:

  byte0 byte1 byte2 byte3  byte4 byte5 byte6 byte7

This is why you swap. However in Linux no need to do this by hand.

The if_dataXX have a little endian layout, while the can frame has a big
endian layout. Further if_dataXX has only 16 bit of can data.

I think it should look like this:

	for (i =3D 0; i < cf->can_dlc; i +=3D 2) {
		reg =3D ioread32(&priv->regs->if1_data[i >> 1]);
		*(__be16 *)cf->data[i] =3D cpu_to_be16(reg);
	}

You have to change the definition of the regs struct a bit:

>	u32 if1_mcont;
>	u32 if1_data[4];
>	u32 reserve2;

Totally untested, though.
BTW: Where can I get this Intel Hardware to improve and test the driver?

> I can't understand your intention.
> Please show in detail.

Above we have the RX-Path, the TX-path would probably use a
"be16_to_cpup", have a look at the flexcan driver. It uses the whole 32
bit for candata, though.

>>> All these check if busy in the code make me a bit nervous, can you
>>> please explain why they are needed. A pointer to the manual is okay, =
too.
>> Me too. I already ask in my previous mail how long that functions
>> usually blocks.
> When accessing read/write from/to Message RAM,
> Since it takes much time for transferring between Register and Message =
RAM,
> SW must check busy flag of CAN register.
> This is a Topcliff HW specification.

see above.

>> is there some pdev->name instead of KBUILD_MODNAME that can be used?
> I can't understand your intention.
> pdev(struct pci_dev) doesn't have "name" member.=20

I was just asking :) As it doesn't have a name, KBUILD_MODNAME is fine.

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig7B537A5553CAFC1A77315BE5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzIJdcACgkQjTAFq1RaXHOjTQCgjjk72Ycc4HbCDpFkmvKeJjEs
YxIAoJMDmPalUWFvs0U9y3rpwUS+EGnY
=/TPY
-----END PGP SIGNATURE-----

--------------enig7B537A5553CAFC1A77315BE5--

--===============0379414717114350458==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0379414717114350458==--
