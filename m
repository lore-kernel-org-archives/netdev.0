From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: xilinx CAN controller support.
Date: Fri, 14 Feb 2014 10:59:47 +0100
Message-ID: <52FDE913.30106@pengutronix.de>
References: <\> <0dc128ac-e5cd-47bd-9ab1-3a545c3e2043@CO9EHSMHS012.ehs.local> <52FD1B16.6020600@pengutronix.de> <ad62e4f0-fe91-4dac-9a74-ffe9c9128cb2@CH1EHSMHS024.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="8oWLaN1ltHdkBnqJaKV6s3wSEnOFtmPKa"
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
In-Reply-To: <ad62e4f0-fe91-4dac-9a74-ffe9c9128cb2@CH1EHSMHS024.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8oWLaN1ltHdkBnqJaKV6s3wSEnOFtmPKa
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/14/2014 10:36 AM, Appana Durga Kedareswara Rao wrote:
>>> +/* CAN register bit masks - XCAN_<REG>_<BIT>_MASK */
>>> +#define XCAN_SRR_CEN_MASK          0x00000002 /* CAN enable */
>>> +#define XCAN_SRR_RESET_MASK                0x00000001 /* Soft Reset =
the
>> CAN core */
>>> +#define XCAN_MSR_LBACK_MASK                0x00000002 /* Loop back
>> mode select */
>>> +#define XCAN_MSR_SLEEP_MASK                0x00000001 /* Sleep mode
>> select */
>>> +#define XCAN_BRPR_BRP_MASK         0x000000FF /* Baud rate
>> prescaler */
>>> +#define XCAN_BTR_SJW_MASK          0x00000180 /* Synchronous
>> jump width */
>>> +#define XCAN_BTR_TS2_MASK          0x00000070 /* Time segment
>> 2 */
>>> +#define XCAN_BTR_TS1_MASK          0x0000000F /* Time segment
>> 1 */
>>> +#define XCAN_ECR_REC_MASK          0x0000FF00 /* Receive error
>> counter */
>>> +#define XCAN_ECR_TEC_MASK          0x000000FF /* Transmit error
>> counter */
>>> +#define XCAN_ESR_ACKER_MASK                0x00000010 /* ACK error *=
/
>>> +#define XCAN_ESR_BERR_MASK         0x00000008 /* Bit error */
>>> +#define XCAN_ESR_STER_MASK         0x00000004 /* Stuff error */
>>> +#define XCAN_ESR_FMER_MASK         0x00000002 /* Form error */
>>> +#define XCAN_ESR_CRCER_MASK                0x00000001 /* CRC error *=
/
>>> +#define XCAN_SR_TXFLL_MASK         0x00000400 /* TX FIFO is full
>> */
>>> +#define XCAN_SR_ESTAT_MASK         0x00000180 /* Error status */
>>> +#define XCAN_SR_ERRWRN_MASK                0x00000040 /* Error warni=
ng
>> */
>>> +#define XCAN_SR_NORMAL_MASK                0x00000008 /* Normal mode=

>> */
>>> +#define XCAN_SR_LBACK_MASK         0x00000002 /* Loop back
>> mode */
>>> +#define XCAN_SR_CONFIG_MASK                0x00000001 /* Configurati=
on
>> mode */
>>> +#define XCAN_IXR_TXFEMP_MASK               0x00004000 /* TX FIFO Emp=
ty
>> */
>>> +#define XCAN_IXR_WKUP_MASK         0x00000800 /* Wake up
>> interrupt */
>>> +#define XCAN_IXR_SLP_MASK          0x00000400 /* Sleep
>> interrupt */
>>> +#define XCAN_IXR_BSOFF_MASK                0x00000200 /* Bus off
>> interrupt */
>>> +#define XCAN_IXR_ERROR_MASK                0x00000100 /* Error inter=
rupt
>> */
>>> +#define XCAN_IXR_RXNEMP_MASK               0x00000080 /* RX FIFO
>> NotEmpty intr */
>>> +#define XCAN_IXR_RXOFLW_MASK               0x00000040 /* RX FIFO
>> Overflow intr */
>>> +#define XCAN_IXR_RXOK_MASK         0x00000010 /* Message
>> received intr */
>>> +#define XCAN_IXR_TXOK_MASK         0x00000002 /* TX successful
>> intr */
>>> +#define XCAN_IXR_ARBLST_MASK               0x00000001 /* Arbitration=

>> lost intr */
>>> +#define XCAN_IDR_ID1_MASK          0xFFE00000 /* Standard msg
>> identifier */
>>> +#define XCAN_IDR_SRR_MASK          0x00100000 /* Substitute
>> remote TXreq */
>>> +#define XCAN_IDR_IDE_MASK          0x00080000 /* Identifier
>> extension */
>>> +#define XCAN_IDR_ID2_MASK          0x0007FFFE /* Extended
>> message ident */
>>> +#define XCAN_IDR_RTR_MASK          0x00000001 /* Remote TX
>> request */
>>> +#define XCAN_DLCR_DLC_MASK         0xF0000000 /* Data length
>> code */
>>> +
>=20
> Need to use BIT() Macro for the Masks?

You can, but it IMHO only makes sense where only a single bit is set.

[...]

>>> +   int waiting_ech_skb_num;
>>> +   int xcan_echo_skb_max_tx;
>>> +   int xcan_echo_skb_max_rx;
>>> +   struct napi_struct napi;
>>> +   spinlock_t ech_skb_lock;
>>> +   u32 (*read_reg)(const struct xcan_priv *priv, int reg);
>>> +   void (*write_reg)(const struct xcan_priv *priv, int reg, u32 val)=
;
>>
>> Please remove read_reg, write_reg, as long as there isn't any BE suppo=
rt in
>> the driver, call them directly.
>>
>=20
>=20
> As per yours and Michal discussion I am keeping this here (endianess
> of the IP is not fixed at compile time).

Ok.

[...]

>>> +/**
>>> + * xcan_start_xmit - Starts the transmission
>>> + * @skb:   sk_buff pointer that contains data to be Txed
>>> + * @ndev:  Pointer to net_device structure
>>> + *
>>> + * This function is invoked from upper layers to initiate
>>> +transmission. This
>>> + * function uses the next available free txbuff and populates their
>>> +fields to
>>> + * start the transmission.
>>> + *
>>> + * Return: 0 on success and failure value on error  */ static int
>>> +xcan_start_xmit(struct sk_buff *skb, struct net_device *ndev) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   struct net_device_stats *stats =3D &ndev->stats;
>>> +   struct can_frame *cf =3D (struct can_frame *)skb->data;
>>> +   u32 id, dlc, data[2] =3D {0, 0}, rtr =3D 0;
>>
>> I think you can drop the rtr varibale and use cf->can_id & CAN_RTR_FLA=
G
>> instead.
>>
>=20
> OK
>>> +   unsigned long flags;
>>> +
>>> +   if (can_dropped_invalid_skb(ndev, skb))
>>> +           return NETDEV_TX_OK;
>>> +
>>> +   /* Watch carefully on the bit sequence */
>>> +   if (cf->can_id & CAN_EFF_FLAG) {
>>> +           /* Extended CAN ID format */
>>> +           id =3D ((cf->can_id & CAN_EFF_MASK) << XCAN_IDR_ID2_SHIFT=
)
>> &
>>> +                   XCAN_IDR_ID2_MASK;
>>> +           id |=3D (((cf->can_id & CAN_EFF_MASK) >>
>>> +                   (CAN_EFF_ID_BITS-CAN_SFF_ID_BITS)) <<
>>> +                   XCAN_IDR_ID1_SHIFT) & XCAN_IDR_ID1_MASK;
>>> +
>>> +           /* The substibute remote TX request bit should be "1"
>>> +            * for extended frames as in the Xilinx CAN datasheet
>>> +            */
>>> +           id |=3D XCAN_IDR_IDE_MASK | XCAN_IDR_SRR_MASK;
>>> +
>>> +           if (cf->can_id & CAN_RTR_FLAG) {
>>> +                   /* Extended frames remote TX request */
>>> +                   id |=3D XCAN_IDR_RTR_MASK;
>>> +                   rtr =3D 1;
>>> +           }
>>> +   } else {
>>> +           /* Standard CAN ID format */
>>> +           id =3D ((cf->can_id & CAN_SFF_MASK) << XCAN_IDR_ID1_SHIFT=
)
>> &
>>> +                   XCAN_IDR_ID1_MASK;
>>> +
>>> +           if (cf->can_id & CAN_RTR_FLAG) {
>>> +                   /* Extended frames remote TX request */
>>> +                   id |=3D XCAN_IDR_SRR_MASK;
>>> +                   rtr =3D 1;
>>> +           }
>>> +   }
>>> +
>>> +   dlc =3D (cf->can_dlc & 0xf) << XCAN_DLCR_DLC_SHIFT;
>>
>> No need to mask dlc, it's valid.
>>
> OK
>=20
>>> +
>>> +   if (dlc > 0)
>>
>> You've copied my speudo code :)
>> But you have to use (cf->can_dlc > 0) here, as dlc is the shifted valu=
e.
>=20
> Yes :) I missed it will change
>=20
>>
>>> +           data[0] =3D be32_to_cpup((__be32 *)(cf->data + 0));
>>> +   if (dlc > 4)
>>> +           data[1] =3D be32_to_cpup((__be32 *)(cf->data + 4));
>>> +
>>> +   can_put_echo_skb(skb, ndev, priv->ech_skb_next);
>>
>>       can_put_echo_skb(skb, ndev,
>>               priv->tx_head % priv->xcan_echo_skb_max_tx);
>>
>>       priv->tx_head++;
>>
>=20
> Ok
>>> +
>>> +   /* Write the Frame to Xilinx CAN TX FIFO */
>>> +   priv->write_reg(priv, XCAN_TXFIFO_ID_OFFSET, id);
>>> +   priv->write_reg(priv, XCAN_TXFIFO_DLC_OFFSET, dlc);
>>> +   if (!rtr) {
>>> +           priv->write_reg(priv, XCAN_TXFIFO_DW1_OFFSET, data[0]);
>>> +           priv->write_reg(priv, XCAN_TXFIFO_DW2_OFFSET, data[1]);
>>> +           stats->tx_bytes +=3D cf->can_dlc;
>>
>> Please add a comment which write triggers the tx. What in case of the =
rtr?
>> Which write triggers the tx then?
>>
>=20
> Ok  Will Add
>=20
>  In RTR Case  the below write triggers the trasmission
> priv->write_reg(priv, XCAN_TXFIFO_DLC_OFFSET, dlc);
> In Normal case  this write
> priv->write_reg(priv, XCAN_TXFIFO_DW2_OFFSET, data[1]);
> Triggers the transmission.
>=20
> In Btw: Due to the limitations in the IP( Tx DLC register is a write on=
ly Register)
> I can't put this stats->tx_bytes +=3D cf->can_dlc; in the tx interrupt =
routine.

No problem.

[...]

>>> +   if (work_done < quota) {
>>> +           napi_complete(napi);
>>> +           ier =3D priv->read_reg(priv, XCAN_IER_OFFSET);
>>> +           ier |=3D (XCAN_IXR_RXOK_MASK |
>> XCAN_IXR_RXNEMP_MASK);
>>> +           priv->write_reg(priv, XCAN_IER_OFFSET, ier);
>>
>> Is this a read-modify-write register? I mean will an interrupt get dis=
abled, if
>> you write a 0-bit in the IER register? What does the ICR register?
>=20
> ISR- Interrupt Status Register (Read only register)
> IER- Interrupt Enable Register(R/w register)
> ICR- Interrupt Clear Register.(write only register)
>=20
>=20
> The Interrupt Status Register (ISR) contains bits that are set when a p=
articular interrupt condition occurs. If
> the corresponding mask bit in the Interrupt Enable Register is set, an =
interrupt is generated.
> Interrupt bits in the ISR can be cleared by writing to the Interrupt Cl=
ear Register

Thanks.

[...]

>>> +/**
>>> + * xcan_open - Driver open routine
>>> + * @ndev:  Pointer to net_device structure
>>> + *
>>> + * This is the driver open routine.
>>> + * Return: 0 on success and failure value on error  */ static int
>>> +xcan_open(struct net_device *ndev) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   int ret;
>>> +
>>> +   ret =3D request_irq(ndev->irq, xcan_interrupt, priv->irq_flags,
>>> +                   ndev->name, (void *)ndev);
>>> +   if (ret < 0) {
>>> +           netdev_err(ndev, "Irq allocation for CAN failed\n");
>>> +           return ret;
>>> +   }
>>> +
>>> +   /* Set chip into reset mode */
>>> +   ret =3D set_reset_mode(ndev);
>>> +   if (ret < 0)
>>> +           netdev_err(ndev, "mode resetting failed failed!\n");
>>
>> Is this critical?
>=20
> This condition usually won't fail.
> But if the controller has a problems at the h/w level in that case putt=
ed this err print.
> If you want me to change it as a warning will do

If there is a hardware level problem, is it better to return here with
an error (and free the IRQ)?

[...]

>>> +/**
>>> + * xcan_probe - Platform registration call
>>> + * @pdev:  Handle to the platform device structure
>>> + *
>>> + * This function does all the memory allocation and registration for=

>>> +the CAN
>>> + * device.
>>> + *
>>> + * Return: 0 on success and failure value on error  */ static int
>>> +xcan_probe(struct platform_device *pdev) {
>>> +   struct resource *res; /* IO mem resources */
>>> +   struct net_device *ndev;
>>> +   struct xcan_priv *priv;
>>> +   int ret, fifodep;
>>> +
>>> +   /* Create a CAN device instance */
>>> +   ndev =3D alloc_candev(sizeof(struct xcan_priv),
>> XCAN_ECHO_SKB_MAX);
>>> +   if (!ndev)
>>> +           return -ENOMEM;
>>> +
>>> +   priv =3D netdev_priv(ndev);
>>> +   priv->dev =3D ndev;
>>> +   priv->can.bittiming_const =3D &xcan_bittiming_const;
>>> +   priv->can.do_set_bittiming =3D xcan_set_bittiming;
>>> +   priv->can.do_set_mode =3D xcan_do_set_mode;
>>> +   priv->can.do_get_berr_counter =3D xcan_get_berr_counter;
>>> +   priv->can.ctrlmode_supported =3D CAN_CTRLMODE_LOOPBACK |
>>> +                                   CAN_CTRLMODE_BERR_REPORTING;
>>> +
>>> +   /* Get IRQ for the device */
>>> +   ndev->irq =3D platform_get_irq(pdev, 0);
>>> +
>>> +   spin_lock_init(&priv->ech_skb_lock);
>>> +   ndev->flags |=3D IFF_ECHO;        /* We support local echo */
>>> +
>>> +   platform_set_drvdata(pdev, ndev);
>>> +   SET_NETDEV_DEV(ndev, &pdev->dev);
>>> +   ndev->netdev_ops =3D &xcan_netdev_ops;
>>> +
>>> +   /* Get the virtual base address for the device */
>>> +   res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>> +   priv->reg_base =3D devm_ioremap_resource(&pdev->dev, res);
>>> +   if (IS_ERR(priv->reg_base)) {
>>> +           ret =3D PTR_ERR(priv->reg_base);
>>> +           goto err_free;
>>> +   }
>>> +   ndev->mem_start =3D res->start;
>>> +   ndev->mem_end =3D res->end;
>>> +
>>> +   priv->write_reg =3D xcan_write_reg;
>>> +   priv->read_reg =3D xcan_read_reg;
>>> +
>>> +   ret =3D of_property_read_u32(pdev->dev.of_node, "tx-fifo-depth",
>>> +                           &fifodep);
>>> +   if (ret < 0)
>>> +           goto err_free;
>>> +   priv->xcan_echo_skb_max_tx =3D fifodep;
>>> +
>>> +   ret =3D of_property_read_u32(pdev->dev.of_node, "rx-fifo-depth",
>>> +                           &fifodep);
>>> +   if (ret < 0)
>>> +           goto err_free;
>>> +   priv->xcan_echo_skb_max_rx =3D fifodep;
>>> +
>>> +   /* Getting the CAN devclk info */
>>> +   priv->devclk =3D devm_clk_get(&pdev->dev, "ref_clk");
>>> +   if (IS_ERR(priv->devclk)) {
>>> +           dev_err(&pdev->dev, "Device clock not found.\n");
>>> +           ret =3D PTR_ERR(priv->devclk);
>>> +           goto err_free;
>>> +   }
>>> +
>>> +   /* Check for type of CAN device */
>>> +   if (of_device_is_compatible(pdev->dev.of_node,
>>> +                               "xlnx,zynq-can-1.00.a")) {
>>> +           priv->aperclk =3D devm_clk_get(&pdev->dev, "aper_clk");
>>> +           if (IS_ERR(priv->aperclk)) {
>>> +                   dev_err(&pdev->dev, "aper clock not found\n");
>>> +                   ret =3D PTR_ERR(priv->aperclk);
>>> +                   goto err_free;
>>> +           }
>>> +   } else {
>>> +           priv->aperclk =3D priv->devclk;
>>> +   }
>>> +
>>> +   ret =3D clk_prepare_enable(priv->devclk);
>>> +   if (ret) {
>>> +           dev_err(&pdev->dev, "unable to enable device clock\n");
>>> +           goto err_free;
>>> +   }
>>> +
>>> +   ret =3D clk_prepare_enable(priv->aperclk);
>>> +   if (ret) {
>>> +           dev_err(&pdev->dev, "unable to enable aper clock\n");
>>> +           goto err_unprepar_disabledev;
>>> +   }
>>
>> Can you keep your clocks disaled if the interface is not up?
>=20
> I didn't get it will you please explain?

This feature s optional, but a a good practice.

This function gets called when the driver is loaded, i.e. during boot.
So the complete CAN core will be enabled and powered, even if the
interface is down. To reduce power consumption it's better to enable the
clocks in the open() function and disable in close(). If you access some
CAN registers during probe you have to enable the clock and you probably
have to enable it in the do_get_berr_counter callback, as it may be
called if the interface is still down.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--8oWLaN1ltHdkBnqJaKV6s3wSEnOFtmPKa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlL96RMACgkQjTAFq1RaXHP6tACfToORlMnusDyxxT07+wUD6Mgw
m24AoJMllHtcDNX3YBtIyD2Vq7pyHGXk
=l2f8
-----END PGP SIGNATURE-----

--8oWLaN1ltHdkBnqJaKV6s3wSEnOFtmPKa--
