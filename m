From: Akshay Bhat <akshay.bhat@timesys.com>
Subject: Re: [PATCH 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Tue, 17 Jan 2017 14:11:33 -0500
Message-ID: <13690f53-98d6-db22-ec12-5323ca1ad106@timesys.com>
References: <1479146144-29143-1-git-send-email-akshay.bhat@timesys.com>
 <1479146144-29143-2-git-send-email-akshay.bhat@timesys.com>
 <7ad30b57-b97f-466e-3792-a433e4a2a2ca@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="tC1OOt0fscRSkBfwSaDgBh1kRvKiQ9ewU"
Cc: mark.rutland@arm.com, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, Akshay Bhat <nodeax@gmail.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>, wg@grandegger.com,
        robh+dt@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:34416 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751176AbdAQTSU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:18:20 -0500
Received: by mail-qt0-f171.google.com with SMTP id l7so175118249qtd.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 11:18:20 -0800 (PST)
In-Reply-To: <7ad30b57-b97f-466e-3792-a433e4a2a2ca@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--tC1OOt0fscRSkBfwSaDgBh1kRvKiQ9ewU
Content-Type: multipart/mixed; boundary="hILNXPPHD4JdQwmWT7SExs1Nn0JvL1SF8"
From: Akshay Bhat <akshay.bhat@timesys.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>, wg@grandegger.com,
 robh+dt@kernel.org
Cc: mark.rutland@arm.com, linux-can@vger.kernel.org, netdev@vger.kernel.org,
 devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
 Akshay Bhat <nodeax@gmail.com>
Message-ID: <13690f53-98d6-db22-ec12-5323ca1ad106@timesys.com>
Subject: Re: [PATCH 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
References: <1479146144-29143-1-git-send-email-akshay.bhat@timesys.com>
 <1479146144-29143-2-git-send-email-akshay.bhat@timesys.com>
 <7ad30b57-b97f-466e-3792-a433e4a2a2ca@pengutronix.de>
In-Reply-To: <7ad30b57-b97f-466e-3792-a433e4a2a2ca@pengutronix.de>

--hILNXPPHD4JdQwmWT7SExs1Nn0JvL1SF8
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Marc,

On 01/03/2017 10:31 AM, Marc Kleine-Budde wrote:
> On 11/14/2016 06:55 PM, Akshay Bhat wrote:
>> This patch adds support for the Holt HI-311x CAN controller. The HI311=
x
>> CAN controller is capable of transmitting and receiving standard data
>> frames, extended data frames and remote frames. The HI311x interfaces
>> with the host over SPI.
>=20
> Don't use uint8_t and similar in the kernel, please use u8 instead.
>=20

Will fix in V2

>>
>> Datasheet: www.holtic.com/documents/371-hi-3110_v-rev-jpdf.do
>>
>> Signed-off-by: Akshay Bhat <nodeax@gmail.com>
>> ---
>>  drivers/net/can/spi/Kconfig  |    6 +
>>  drivers/net/can/spi/Makefile |    1 +
>>  drivers/net/can/spi/hi311x.c | 1071 +++++++++++++++++++++++++++++++++=
+++++++++
>>  3 files changed, 1078 insertions(+)
>>  create mode 100644 drivers/net/can/spi/hi311x.c
>>
>> diff --git a/drivers/net/can/spi/Kconfig b/drivers/net/can/spi/Kconfig=

>> index 148cae5..9eb1bb1 100644
>> --- a/drivers/net/can/spi/Kconfig
>> +++ b/drivers/net/can/spi/Kconfig
>> @@ -7,4 +7,10 @@ config CAN_MCP251X
>>  	---help---
>>  	  Driver for the Microchip MCP251x SPI CAN controllers.
>> =20
>> +config CAN_HI311X
>> +	tristate "Holt HI311x SPI CAN controllers"
>> +	depends on CAN_DEV && SPI && HAS_DMA
>> +	---help---
>> +	  Driver for the Holt HI311x SPI CAN controllers.
>> +
>>  endmenu
>> diff --git a/drivers/net/can/spi/Makefile b/drivers/net/can/spi/Makefi=
le
>> index 0e86040..eac7c3a 100644
>> --- a/drivers/net/can/spi/Makefile
>> +++ b/drivers/net/can/spi/Makefile
>> @@ -4,3 +4,4 @@
>> =20
>> =20
>>  obj-$(CONFIG_CAN_MCP251X)	+=3D mcp251x.o
>> +obj-$(CONFIG_CAN_HI311X)	+=3D hi311x.o
>=20
> Please keep sorted alphabetically. Same for the Kconfig.
>=20

Will fix in V2

>> diff --git a/drivers/net/can/spi/hi311x.c b/drivers/net/can/spi/hi311x=
=2Ec
>> new file mode 100644
>> index 0000000..1020166
>> --- /dev/null
>> +++ b/drivers/net/can/spi/hi311x.c
>> @@ -0,0 +1,1071 @@
>> +/* CAN bus driver for Holt HI3110 CAN Controller with SPI Interface
>> + *
>> + * Based on Microchip 251x CAN Controller (mcp251x) Linux kernel driv=
er
>=20
> You might want to add the copyright of the mcp authors.
>=20

Will add in V2

>> + *
>> + * Copyright(C) Timesys Corporation 2016
>> + *
>> + * This program is free software; you can redistribute it and/or modi=
fy
>> + * it under the terms of the GNU General Public License version 2 as
>> + * published by the Free Software Foundation.
>> + */
>> +
>> +#include <linux/can/core.h>
>> +#include <linux/can/dev.h>
>> +#include <linux/can/led.h>
>> +#include <linux/clk.h>
>> +#include <linux/completion.h>
>> +#include <linux/delay.h>
>> +#include <linux/device.h>
>> +#include <linux/dma-mapping.h>
>> +#include <linux/freezer.h>
>> +#include <linux/interrupt.h>
>> +#include <linux/io.h>
>> +#include <linux/kernel.h>
>> +#include <linux/module.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/of.h>
>> +#include <linux/of_device.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/regulator/consumer.h>
>> +#include <linux/slab.h>
>> +#include <linux/spi/spi.h>
>> +#include <linux/uaccess.h>
>> +
>=20
> Please use just a single space after each macro.
>=20
>                               VVVVVVVV

Will fix in V2.

>> +#define HI3110_MASTER_RESET        0x56
>> +#define HI3110_READ_CTRL0          0xD2
>> +#define HI3110_READ_CTRL1          0xD4
>> +#define HI3110_READ_STATF          0xE2
>> +#define HI3110_WRITE_CTRL0         0x14
>> +#define HI3110_WRITE_CTRL1         0x16
>> +#define HI3110_WRITE_INTE          0x1C
>> +#define HI3110_WRITE_BTR0          0x18
>> +#define HI3110_WRITE_BTR1          0x1A
>> +#define HI3110_READ_BTR0           0xD6
>> +#define HI3110_READ_BTR1           0xD8
>> +#define HI3110_READ_INTF           0xDE
>> +#define HI3110_READ_ERR            0xDC
>> +#define HI3110_READ_FIFO_WOTIME    0x48
>> +#define HI3110_WRITE_FIFO          0x12
>> +#define HI3110_READ_MESSTAT        0xDA
>> +#define HI3110_READ_TEC            0xEC
>> +
>> +#define HI3110_CTRL0_MODE_MASK     (7 << 5)
>> +#define HI3110_CTRL0_NORMAL_MODE   (0 << 5)
>> +#define HI3110_CTRL0_LOOPBACK_MODE (1 << 5)
>> +#define HI3110_CTRL0_MONITOR_MODE  (2 << 5)
>> +#define HI3110_CTRL0_SLEEP_MODE    (3 << 5)
>> +#define HI3110_CTRL0_INIT_MODE     (4 << 5)
>> +
>> +#define HI3110_CTRL1_TXEN          BIT(7)
>> +
>> +#define HI3110_INT_RXTMP           BIT(7)
>> +#define HI3110_INT_RXFIFO          BIT(6)
>> +#define HI3110_INT_TXCPLT          BIT(5)
>> +#define HI3110_INT_BUSERR          BIT(4)
>> +#define HI3110_INT_MCHG            BIT(3)
>> +#define HI3110_INT_WAKEUP          BIT(2)
>> +#define HI3110_INT_F1MESS          BIT(1)
>> +#define HI3110_INT_F0MESS          BIT(0)
>> +
>> +#define HI3110_ERR_BUSOFF          BIT(7)
>> +#define HI3110_ERR_TXERRP          BIT(6)
>> +#define HI3110_ERR_RXERRP          BIT(5)
>> +#define HI3110_ERR_BITERR          BIT(4)
>> +#define HI3110_ERR_FRMERR          BIT(3)
>> +#define HI3110_ERR_CRCERR          BIT(2)
>> +#define HI3110_ERR_ACKERR          BIT(1)
>> +#define HI3110_ERR_STUFERR         BIT(0)
>> +#define HI3110_ERR_PROTOCOL_MASK   (0x1F)
>> +
>> +#define HI3110_STAT_RXFMTY         BIT(1)
>> +
>> +#define HI3110_BTR0_SJW_SHIFT      6
>> +#define HI3110_BTR0_BRP_SHIFT      0
>> +
>> +#define HI3110_BTR1_SAMP_3PERBIT   (1 << 7)
>> +#define HI3110_BTR1_SAMP_1PERBIT   (0 << 7)
>> +#define HI3110_BTR1_TSEG2_SHIFT    4
>> +#define HI3110_BTR1_TSEG1_SHIFT    0
>> +
>> +#define HI3110_FIFO_WOTIME_TAG_OFF 0
>> +#define HI3110_FIFO_WOTIME_ID_OFF  1
>> +#define HI3110_FIFO_WOTIME_DLC_OFF 5
>> +#define HI3110_FIFO_WOTIME_DAT_OFF 6
>> +
>> +#define HI3110_FIFO_WOTIME_TAG_IDE BIT(7)
>> +#define HI3110_FIFO_WOTIME_ID_RTR  BIT(0)
>> +
>> +#define HI3110_FIFO_TAG_OFF        0
>> +#define HI3110_FIFO_ID_OFF         1
>> +#define HI3110_FIFO_STD_DLC_OFF    3
>> +#define HI3110_FIFO_STD_DATA_OFF   4
>> +#define HI3110_FIFO_EXT_DLC_OFF    5
>> +#define HI3110_FIFO_EXT_DATA_OFF   6
>> +
>=20
> Please add the already used HI3110_ namespace to these defines, too.
>=20

Will fix in V2.

>> +#define CAN_FRAME_MAX_DATA_LEN 8
>> +#define RX_BUF_LEN             15
>> +#define TX_STD_BUF_LEN         12
>> +#define TX_EXT_BUF_LEN         14
>> +#define CAN_FRAME_MAX_BITS     128
>> +
>> +#define TX_ECHO_SKB_MAX	1
>> +
>> +#define HI3110_OST_DELAY_MS (10)
>> +
>> +#define DEVICE_NAME "hi3110"
>> +
>> +static int hi3110_enable_dma =3D 1; /* Enable SPI DMA. Default: 1 (On=
) */
>> +module_param(hi3110_enable_dma, int, 0444);
>> +MODULE_PARM_DESC(hi3110_enable_dma, "Enable SPI DMA. Default: 1 (On)"=
);
>> +
>> +static const struct can_bittiming_const hi3110_bittiming_const =3D {
>> +	.name =3D DEVICE_NAME,
>> +	.tseg1_min =3D 2,
>> +	.tseg1_max =3D 16,
>> +	.tseg2_min =3D 2,
>> +	.tseg2_max =3D 8,
>> +	.sjw_max =3D 4,
>> +	.brp_min =3D 1,
>> +	.brp_max =3D 64,
>> +	.brp_inc =3D 1,
>> +};
>> +
>> +enum hi3110_model {
>> +	CAN_HI3110_HI3110	=3D 0x3110,
>                          ^^^^^^^
> single space here, too

Will fix in V2

>> +};
>> +
>> +struct hi3110_priv {
>> +	struct can_priv	   can;
>                        ^^^^
> here too

Will fix in V2

>> +	struct net_device *net;
>> +	struct spi_device *spi;
>> +	enum hi3110_model model;
>> +
>> +	struct mutex hi3110_lock; /* SPI device lock */
>> +
>> +	u8 *spi_tx_buf;
>> +	u8 *spi_rx_buf;
>> +	dma_addr_t spi_tx_dma;
>> +	dma_addr_t spi_rx_dma;
>> +
>> +	struct sk_buff *tx_skb;
>> +	int tx_len;
>> +
>> +	struct workqueue_struct *wq;
>> +	struct work_struct tx_work;
>> +	struct work_struct restart_work;
>> +
>> +	int force_quit;
>> +	int after_suspend;
>=20
> Please add the already used HI3110_ namespace to these defines, too.
>=20

Will fix in V2

>> +#define AFTER_SUSPEND_UP 1
>> +#define AFTER_SUSPEND_DOWN 2
>> +#define AFTER_SUSPEND_POWER 4
>> +#define AFTER_SUSPEND_RESTART 8
>=20
>> +	int restart_tx;
>> +	struct regulator *power;
>> +	struct regulator *transceiver;
>> +	struct clk *clk;
>> +};
>> +
>> +static void hi3110_clean(struct net_device *net)
>> +{
>> +	struct hi3110_priv *priv =3D netdev_priv(net);
>> +
>> +	if (priv->tx_skb || priv->tx_len)
>> +		net->stats.tx_errors++;
>> +	if (priv->tx_skb)
>> +		dev_kfree_skb(priv->tx_skb);
>> +	if (priv->tx_len)
>> +		can_free_echo_skb(priv->net, 0);
>> +	priv->tx_skb =3D NULL;
>> +	priv->tx_len =3D 0;
>> +}
>> +
>> +/* Note about handling of error return of hi3110_spi_trans: accessing=

>> + * registers via SPI is not really different conceptually than using
>> + * normal I/O assembler instructions, although it's much more
>> + * complicated from a practical POV. So it's not advisable to always
>> + * check the return value of this function. Imagine that every
>> + * read{b,l}, write{b,l} and friends would be bracketed in "if ( < 0)=

>> + * error();", it would be a great mess (well there are some situation=

>> + * when exception handling C++ like could be useful after all). So we=

>> + * just check that transfers are OK at the beginning of our
>> + * conversation with the chip and to avoid doing really nasty things
>> + * (like injecting bogus packets in the network stack).
>> + */
>> +static int hi3110_spi_trans(struct spi_device *spi, int len)
>> +{
>> +	struct hi3110_priv *priv =3D spi_get_drvdata(spi);
>> +	struct spi_transfer t =3D {
>> +		.tx_buf =3D priv->spi_tx_buf,
>> +		.rx_buf =3D priv->spi_rx_buf,
>> +		.len =3D len,
>> +		.cs_change =3D 0,
>> +	};
>> +	struct spi_message m;
>> +	int ret;
>> +
>> +	spi_message_init(&m);
>> +
>> +	if (hi3110_enable_dma) {
>> +		t.tx_dma =3D priv->spi_tx_dma;
>> +		t.rx_dma =3D priv->spi_rx_dma;
>> +		m.is_dma_mapped =3D 1;
>> +	}
>> +
>> +	spi_message_add_tail(&t, &m);
>> +
>> +	ret =3D spi_sync(spi, &m);
>> +
>> +	if (ret)
>> +		dev_err(&spi->dev, "spi transfer failed: ret =3D %d\n", ret);
>> +	return ret;
>> +}
>> +
>> +static u8 hi3110_cmd(struct spi_device *spi, uint8_t command)
>> +{
>> +	struct hi3110_priv *priv =3D spi_get_drvdata(spi);
>> +
>> +	priv->spi_tx_buf[0] =3D command;
>> +	dev_dbg(&spi->dev, "hi3110_cmd: %02X\n", command);
>> +
>> +	return hi3110_spi_trans(spi, 1);
>> +}
>> +
>> +static u8 hi3110_read(struct spi_device *spi, uint8_t command)
>> +{
>> +	struct hi3110_priv *priv =3D spi_get_drvdata(spi);
>> +	u8 val =3D 0;
>> +
>> +	priv->spi_tx_buf[0] =3D command;
>> +	hi3110_spi_trans(spi, 2);
>> +	val =3D priv->spi_rx_buf[1];
>> +	dev_dbg(&spi->dev, "hi3110_read: %02X, %02X\n", command, val);
>> +
>> +	return val;
>> +}
>> +
>> +static void hi3110_write(struct spi_device *spi, u8 reg, uint8_t val)=

>> +{
>> +	struct hi3110_priv *priv =3D spi_get_drvdata(spi);
>> +
>> +	priv->spi_tx_buf[0] =3D reg;
>> +	priv->spi_tx_buf[1] =3D val;
>> +	dev_dbg(&spi->dev, "hi3110_write: %02X, %02X\n", reg, val);
>> +
>> +	hi3110_spi_trans(spi, 2);
>> +}
>> +
>> +static void hi3110_hw_tx_frame(struct spi_device *spi, u8 *buf, int l=
en)
>> +{
>> +	struct hi3110_priv *priv =3D spi_get_drvdata(spi);
>> +
>> +	priv->spi_tx_buf[0] =3D HI3110_WRITE_FIFO;
>> +	memcpy(priv->spi_tx_buf + 1, buf, len);
>> +	hi3110_spi_trans(spi, len + 1);
>> +}
>> +
>> +static void hi3110_hw_tx(struct spi_device *spi, struct can_frame *fr=
ame)
>> +{
>> +	u8 buf[TX_EXT_BUF_LEN];
>> +
>> +	buf[HI3110_FIFO_TAG_OFF] =3D 0;
>> +
>> +	if (frame->can_id & CAN_EFF_FLAG) {
>> +		/* Extended frame */
>> +		buf[HI3110_FIFO_ID_OFF] =3D (frame->can_id & CAN_EFF_MASK) >> 21;
>> +		buf[HI3110_FIFO_ID_OFF + 1] =3D
>> +			((((frame->can_id & CAN_EFF_MASK) >> 18) & 0x07) << 5) |
>=20
> Why do you first shift down then up?
>=20

Simplified the logic in V2, shift down then up not needed

>> +			0x18 | /* Recessive SRR and IDE */
>=20
> Can you add a define for the 0x18?
>=20

Will add a define in V2

>> +			(((frame->can_id & CAN_EFF_MASK) >> 15) & 0x07);
>> +		buf[HI3110_FIFO_ID_OFF + 2] =3D
>> +			(frame->can_id & CAN_EFF_MASK) >> 7;
>> +		buf[HI3110_FIFO_ID_OFF + 3] =3D
>> +			((frame->can_id & CAN_EFF_MASK) << 1) |
>> +			((frame->can_id & CAN_RTR_FLAG) ? 1 : 0);
>> +
>> +		buf[HI3110_FIFO_EXT_DLC_OFF] =3D frame->can_dlc;
>> +
>> +		memcpy(buf + HI3110_FIFO_EXT_DATA_OFF,
>> +		       frame->data, frame->can_dlc);
>> +
>> +		hi3110_hw_tx_frame(spi, buf, TX_EXT_BUF_LEN -
>> +				   (CAN_FRAME_MAX_DATA_LEN - frame->can_dlc));
>> +	} else {
>> +		/* Standard frame */
>> +		buf[HI3110_FIFO_ID_OFF] =3D   (frame->can_id & CAN_SFF_MASK) >> 3;
>> +		buf[HI3110_FIFO_ID_OFF + 1] =3D
>> +			((frame->can_id & CAN_SFF_MASK) << 5) |
>> +			((frame->can_id & CAN_RTR_FLAG) ? (1 << 4) : 0);
>> +
>> +		buf[HI3110_FIFO_STD_DLC_OFF] =3D frame->can_dlc;
>> +
>> +		memcpy(buf + HI3110_FIFO_STD_DATA_OFF,
>> +		       frame->data, frame->can_dlc);
>> +
>> +		hi3110_hw_tx_frame(spi, buf, TX_STD_BUF_LEN -
>> +				   (CAN_FRAME_MAX_DATA_LEN - frame->can_dlc));
>> +	}
>> +}
>> +
>> +static void hi3110_hw_rx_frame(struct spi_device *spi, u8 *buf)
>> +{
>> +	struct hi3110_priv *priv =3D spi_get_drvdata(spi);
>> +
>> +	priv->spi_tx_buf[0] =3D HI3110_READ_FIFO_WOTIME;
>> +	hi3110_spi_trans(spi, RX_BUF_LEN);
>> +	memcpy(buf, priv->spi_rx_buf + 1, RX_BUF_LEN - 1);
>> +}
>> +
>> +static void hi3110_hw_rx(struct spi_device *spi)
>> +{
>> +	struct hi3110_priv *priv =3D spi_get_drvdata(spi);
>> +	struct sk_buff *skb;
>> +	struct can_frame *frame;
>> +	u8 buf[RX_BUF_LEN - 1];
>> +
>> +	skb =3D alloc_can_skb(priv->net, &frame);
>> +	if (!skb) {
>> +		dev_err(&spi->dev, "cannot allocate RX skb\n");
>> +		priv->net->stats.rx_dropped++;
>> +		return;
>> +	}
>> +
>> +	hi3110_hw_rx_frame(spi, buf);
>> +	if (buf[HI3110_FIFO_WOTIME_TAG_OFF] & HI3110_FIFO_WOTIME_TAG_IDE) {
>> +		/* IDE is recessive (1), indicating extended 29-bit frame */
>> +		frame->can_id =3D CAN_EFF_FLAG;
>> +		frame->can_id |=3D
>> +		 (buf[HI3110_FIFO_WOTIME_ID_OFF] << 21) |
>> +		 (((buf[HI3110_FIFO_WOTIME_ID_OFF + 1] & 0xE0) >> 5) << 18) |
>> +		 ((buf[HI3110_FIFO_WOTIME_ID_OFF + 1] & 0x07) << 15) |
>> +		 (buf[HI3110_FIFO_WOTIME_ID_OFF + 2] << 7) |
>> +		 (buf[HI3110_FIFO_WOTIME_ID_OFF + 3] >> 1);
>> +	} else {
>> +		/* IDE is dominant (0), frame indicating standard 11-bit */
>> +		frame->can_id =3D
>> +			(buf[HI3110_FIFO_WOTIME_ID_OFF] << 3) |
>> +			((buf[HI3110_FIFO_WOTIME_ID_OFF + 1] & 0xE0) >> 5);
>> +	}
>> +
>> +	if (buf[HI3110_FIFO_WOTIME_ID_OFF + 3] & HI3110_FIFO_WOTIME_ID_RTR) =
{
>> +		/* RTR is recessive (1), indicating remote request frame */
>> +		frame->can_id |=3D CAN_RTR_FLAG;
>> +	}
>> +
>> +	/* Data length */
>> +	frame->can_dlc =3D get_can_dlc(buf[HI3110_FIFO_WOTIME_DLC_OFF] & 0x0=
F);
>> +	memcpy(frame->data, buf + HI3110_FIFO_WOTIME_DAT_OFF, frame->can_dlc=
);
>> +
>> +	priv->net->stats.rx_packets++;
>> +	priv->net->stats.rx_bytes +=3D frame->can_dlc;
>> +
>> +	can_led_event(priv->net, CAN_LED_EVENT_RX);
>> +
>> +	netif_rx_ni(skb);
>> +}
>> +
>> +static void hi3110_hw_sleep(struct spi_device *spi)
>> +{
>> +	hi3110_write(spi, HI3110_WRITE_CTRL0, HI3110_CTRL0_SLEEP_MODE);
>> +}
>> +
>> +static netdev_tx_t hi3110_hard_start_xmit(struct sk_buff *skb,
>> +					  struct net_device *net)
>> +{
>> +	struct hi3110_priv *priv =3D netdev_priv(net);
>> +	struct spi_device *spi =3D priv->spi;
>> +
>> +	if (priv->tx_skb || priv->tx_len) {
>> +		dev_warn(&spi->dev, "hard_xmit called while tx busy\n");
>> +		return NETDEV_TX_BUSY;
>> +	}
>> +
>> +	if (can_dropped_invalid_skb(net, skb))
>> +		return NETDEV_TX_OK;
>> +
>> +	netif_stop_queue(net);
>> +	priv->tx_skb =3D skb;
>> +	queue_work(priv->wq, &priv->tx_work);
>> +
>> +	return NETDEV_TX_OK;
>> +}
>> +
>> +static int hi3110_do_set_mode(struct net_device *net, enum can_mode m=
ode)
>> +{
>> +	struct hi3110_priv *priv =3D netdev_priv(net);
>> +
>> +	switch (mode) {
>> +	case CAN_MODE_START:
>> +		hi3110_clean(net);
>> +		/* We have to delay work since SPI I/O may sleep */
>> +		priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>> +		priv->restart_tx =3D 1;
>> +		if (priv->can.restart_ms =3D=3D 0)
>> +			priv->after_suspend =3D AFTER_SUSPEND_RESTART;
>> +		queue_work(priv->wq, &priv->restart_work);
>> +		break;
>> +	default:
>> +		return -EOPNOTSUPP;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static int hi3110_set_normal_mode(struct spi_device *spi)
>> +{
>> +	struct hi3110_priv *priv =3D spi_get_drvdata(spi);
>> +	u8 reg;
>> +
>> +	hi3110_write(spi, HI3110_WRITE_INTE, HI3110_INT_BUSERR |
>> +		     HI3110_INT_RXFIFO | HI3110_INT_TXCPLT);
>> +
>> +	/* Enable TX */
>> +	hi3110_write(spi, HI3110_WRITE_CTRL1, HI3110_CTRL1_TXEN);
>> +
>> +	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
>> +		/* Put device into loopback mode */
>> +		hi3110_write(spi, HI3110_WRITE_CTRL0,
>> +			     HI3110_CTRL0_LOOPBACK_MODE);
>> +	} else if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) {
>> +		/* Put device into listen-only mode */
>> +		hi3110_write(spi, HI3110_WRITE_CTRL0,
>> +			     HI3110_CTRL0_MONITOR_MODE);
>> +	} else {
>> +		/* Put device into normal mode */
>> +		hi3110_write(spi, HI3110_WRITE_CTRL0,
>> +			     HI3110_CTRL0_NORMAL_MODE);
>> +
>> +		/* Wait for the device to enter normal mode */
>> +		mdelay(HI3110_OST_DELAY_MS);
>> +		reg =3D hi3110_read(spi, HI3110_READ_CTRL0);
>> +		if ((reg & HI3110_CTRL0_MODE_MASK) !=3D HI3110_CTRL0_NORMAL_MODE)
>> +			return -EBUSY;
>> +	}
>> +	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>> +	return 0;
>> +}
>> +
>> +static int hi3110_do_set_bittiming(struct net_device *net)
>> +{
>> +	struct hi3110_priv *priv =3D netdev_priv(net);
>> +	struct can_bittiming *bt =3D &priv->can.bittiming;
>> +	struct spi_device *spi =3D priv->spi;
>> +
>> +	hi3110_write(spi, HI3110_WRITE_BTR0,
>> +		     ((bt->sjw - 1) << HI3110_BTR0_SJW_SHIFT) |
>> +		     ((bt->brp - 1) << HI3110_BTR0_BRP_SHIFT));
>> +
>> +	hi3110_write(spi, HI3110_WRITE_BTR1,
>> +		     (priv->can.ctrlmode &
>> +		     CAN_CTRLMODE_3_SAMPLES ?
>> +		     HI3110_BTR1_SAMP_3PERBIT : HI3110_BTR1_SAMP_1PERBIT) |
>> +		     ((bt->phase_seg1 + bt->prop_seg - 1)
>> +		     << HI3110_BTR1_TSEG1_SHIFT) |
>> +		     ((bt->phase_seg2 - 1) << HI3110_BTR1_TSEG2_SHIFT));
>> +
>> +	dev_dbg(&spi->dev, "BT: 0x%02x 0x%02x\n",
>> +		hi3110_read(spi, HI3110_READ_BTR0),
>> +		hi3110_read(spi, HI3110_READ_BTR1));
>> +
>> +	return 0;
>> +}
>> +
>> +static int hi3110_setup(struct net_device *net, struct hi3110_priv *p=
riv,
>> +			struct spi_device *spi)
>=20
> onlt the first parameter is used.
>=20

Will remove the unused parameters in V2

>> +{
>> +	hi3110_do_set_bittiming(net);
>> +	return 0;
>> +}
>> +
>> +static int hi3110_hw_reset(struct spi_device *spi)
>> +{
>> +	u8 reg;
>> +	int ret;
>> +
>> +	/* Wait for oscillator startup timer after power up */
>> +	mdelay(HI3110_OST_DELAY_MS);
>> +
>> +	ret =3D hi3110_cmd(spi, HI3110_MASTER_RESET);
>> +	if (ret)
>> +		return ret;
>> +
>> +	/* Wait for oscillator startup timer after reset */
>> +	mdelay(HI3110_OST_DELAY_MS);
>> +
>> +	reg =3D hi3110_read(spi, HI3110_READ_CTRL0);
>> +	if ((reg & HI3110_CTRL0_MODE_MASK) !=3D HI3110_CTRL0_INIT_MODE)
>> +		return -ENODEV;
>> +
>> +	/* As per the datasheet it appears the error flags are
>> +	 * not cleared on reset. Explicitly clear them by performing a read
>> +	 */
>> +	hi3110_read(spi, HI3110_READ_ERR);
>> +
>> +	return 0;
>> +}
>> +
>> +static int hi3110_hw_probe(struct spi_device *spi)
>> +{
>> +	u8 statf;
>> +
>> +	hi3110_hw_reset(spi);
>> +
>> +	/* Confirm correct operation by checking against reset values
>> +	 * in datasheet
>> +	 */
>> +	statf =3D hi3110_read(spi, HI3110_READ_STATF);
>> +
>> +	dev_dbg(&spi->dev, "statf: %02X\n", statf);
>> +
>> +	if (statf !=3D 0x82)
>> +		return -ENODEV;
>> +
>> +	return 0;
>> +}
>> +
>> +static int hi3110_power_enable(struct regulator *reg, int enable)
>> +{
>> +	if (IS_ERR_OR_NULL(reg))
>> +		return 0;
>> +
>> +	if (enable)
>> +		return regulator_enable(reg);
>> +	else
>> +		return regulator_disable(reg);
>> +}
>> +
>> +static void hi3110_open_clean(struct net_device *net)
>> +{
>> +	struct hi3110_priv *priv =3D netdev_priv(net);
>> +	struct spi_device *spi =3D priv->spi;
>> +
>> +	free_irq(spi->irq, priv);
>> +	hi3110_hw_sleep(spi);
>> +	hi3110_power_enable(priv->transceiver, 0);
>> +	close_candev(net);
>> +}
>> +
>> +static int hi3110_stop(struct net_device *net)
>> +{
>> +	struct hi3110_priv *priv =3D netdev_priv(net);
>> +	struct spi_device *spi =3D priv->spi;
>> +
>> +	close_candev(net);
>> +
>> +	priv->force_quit =3D 1;
>> +	free_irq(spi->irq, priv);
>> +	destroy_workqueue(priv->wq);
>> +	priv->wq =3D NULL;
>> +
>> +	mutex_lock(&priv->hi3110_lock);
>> +
>> +	/* Disable transmit, interrupts and clear flags */
>> +	hi3110_write(spi, HI3110_WRITE_CTRL1, 0x0);
>> +	hi3110_write(spi, HI3110_WRITE_INTE, 0x0);
>> +	hi3110_read(spi, HI3110_READ_INTF);
>> +
>> +	hi3110_clean(net);
>> +
>> +	hi3110_hw_sleep(spi);
>> +
>> +	hi3110_power_enable(priv->transceiver, 0);
>> +
>> +	priv->can.state =3D CAN_STATE_STOPPED;
>> +
>> +	mutex_unlock(&priv->hi3110_lock);
>> +
>> +	can_led_event(net, CAN_LED_EVENT_STOP);
>> +
>> +	return 0;
>> +}
>> +
>> +static void hi3110_error_skb(struct net_device *net, int can_id,
>> +			     int data1, int data2)
>> +{
>> +	struct sk_buff *skb;
>> +	struct can_frame *frame;
>> +
>> +	skb =3D alloc_can_err_skb(net, &frame);
>> +	if (skb) {
>> +		frame->can_id |=3D can_id;
>> +		frame->data[1] =3D data1;
>> +		frame->data[2] =3D data2;
>> +		netif_rx_ni(skb);
>> +	} else {
>> +		netdev_err(net, "cannot allocate error skb\n");
>> +	}
>> +}
>> +
>> +static void hi3110_tx_work_handler(struct work_struct *ws)
>> +{
>> +	struct hi3110_priv *priv =3D container_of(ws, struct hi3110_priv,
>> +						 tx_work);
>> +	struct spi_device *spi =3D priv->spi;
>> +	struct net_device *net =3D priv->net;
>> +	struct can_frame *frame;
>> +
>> +	mutex_lock(&priv->hi3110_lock);
>> +	if (priv->tx_skb) {
>> +		if (priv->can.state =3D=3D CAN_STATE_BUS_OFF) {
>> +			hi3110_clean(net);
>> +		} else {
>> +			frame =3D (struct can_frame *)priv->tx_skb->data;
>> +
>> +			if (frame->can_dlc > CAN_FRAME_MAX_DATA_LEN)
>> +				frame->can_dlc =3D CAN_FRAME_MAX_DATA_LEN;
>=20
> this has already been checked
>=20

Will remove the check in V2

>> +			hi3110_hw_tx(spi, frame);
>> +			priv->tx_len =3D 1 + frame->can_dlc;
>> +			can_put_echo_skb(priv->tx_skb, net, 0);
>> +			priv->tx_skb =3D NULL;
>> +		}
>> +	}
>> +	mutex_unlock(&priv->hi3110_lock);
>> +}
>> +
>> +static void hi3110_restart_work_handler(struct work_struct *ws)
>> +{
>> +	struct hi3110_priv *priv =3D container_of(ws, struct hi3110_priv,
>> +						 restart_work);
>> +	struct spi_device *spi =3D priv->spi;
>> +	struct net_device *net =3D priv->net;
>> +
>> +	mutex_lock(&priv->hi3110_lock);
>> +	if (priv->after_suspend) {
>> +		hi3110_hw_reset(spi);
>> +		hi3110_setup(net, priv, spi);
>> +		if (priv->after_suspend & AFTER_SUSPEND_RESTART) {
>> +			hi3110_set_normal_mode(spi);
>> +		} else if (priv->after_suspend & AFTER_SUSPEND_UP) {
>> +			netif_device_attach(net);
>> +			hi3110_clean(net);
>> +			hi3110_set_normal_mode(spi);
>> +			netif_wake_queue(net);
>> +		} else {
>> +			hi3110_hw_sleep(spi);
>> +		}
>> +		priv->after_suspend =3D 0;
>> +		priv->force_quit =3D 0;
>> +	}
>> +
>> +	if (priv->restart_tx) {
>> +		priv->restart_tx =3D 0;
>> +		hi3110_clean(net);
>> +		netif_wake_queue(net);
>> +		hi3110_error_skb(net, CAN_ERR_RESTARTED, 0, 0);
>> +	}
>> +	mutex_unlock(&priv->hi3110_lock);
>> +}
>> +
>> +static irqreturn_t hi3110_can_ist(int irq, void *dev_id)
>> +{
>> +	struct hi3110_priv *priv =3D dev_id;
>> +	struct spi_device *spi =3D priv->spi;
>> +	struct net_device *net =3D priv->net;
>> +
>> +	mutex_lock(&priv->hi3110_lock);
>> +
>> +	while (!priv->force_quit) {
>> +		enum can_state new_state;
>> +		u8 intf;
>> +		u8 eflag;
>> +		int can_id =3D 0, data1 =3D 0, data2 =3D 0;
>> +
>> +		while (!(HI3110_STAT_RXFMTY &
>> +			hi3110_read(spi, HI3110_READ_STATF))) {
>> +			hi3110_hw_rx(spi);
>> +		};
>> +
>> +		intf =3D hi3110_read(spi, HI3110_READ_INTF);
>> +		eflag =3D hi3110_read(spi, HI3110_READ_ERR);
>=20
> does the hardware supports multiple reads with a single transfer? If so=

> make use of it, for performance reasons.
>=20

Looking at the datasheet it does not seem possible, would be nice if it
was supported.

>> +		/* Update can state */
>> +		if (eflag & HI3110_ERR_BUSOFF) {
>> +			new_state =3D CAN_STATE_BUS_OFF;
>> +			can_id |=3D CAN_ERR_BUSOFF;
>> +		} else if (eflag & HI3110_ERR_TXERRP) {
>> +			new_state =3D CAN_STATE_ERROR_PASSIVE;
>> +			can_id |=3D CAN_ERR_CRTL;
>> +			data1 |=3D CAN_ERR_CRTL_TX_PASSIVE;
>> +		} else if (eflag & HI3110_ERR_RXERRP) {
>> +			new_state =3D CAN_STATE_ERROR_PASSIVE;
>> +			can_id |=3D CAN_ERR_CRTL;
>> +			data1 |=3D CAN_ERR_CRTL_RX_PASSIVE;
>> +		} else {
>> +			new_state =3D CAN_STATE_ERROR_ACTIVE;
>> +		}
>> +
>> +		/* Check for protocol errors */
>> +		if (eflag & HI3110_ERR_PROTOCOL_MASK) {
>> +			can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>> +			priv->can.can_stats.bus_error++;
>> +			priv->net->stats.rx_errors++;
>> +			if (eflag & HI3110_ERR_BITERR)
>> +				data2 |=3D CAN_ERR_PROT_BIT;
>> +			else if (eflag & HI3110_ERR_FRMERR)
>> +				data2 |=3D CAN_ERR_PROT_FORM;
>> +			else if (eflag & HI3110_ERR_STUFERR)
>> +				data2 |=3D CAN_ERR_PROT_STUFF;
>> +			else
>> +				data2 |=3D CAN_ERR_PROT_UNSPEC;
>> +		}
>> +
>> +		/* Update can state statistics */
>> +		switch (priv->can.state) {
>> +		case CAN_STATE_ERROR_ACTIVE:
>> +			if (new_state >=3D CAN_STATE_ERROR_WARNING &&
>> +			    new_state <=3D CAN_STATE_BUS_OFF)
>> +				priv->can.can_stats.error_warning++;
>> +		/* fallthrough */
>> +		case CAN_STATE_ERROR_WARNING:
>> +			if (new_state >=3D CAN_STATE_ERROR_PASSIVE &&
>> +			    new_state <=3D CAN_STATE_BUS_OFF)
>> +				priv->can.can_stats.error_passive++;
>> +			break;
>> +		default:
>> +			break;
>> +		}
>> +		priv->can.state =3D new_state;
>> +
>> +		if (intf & HI3110_INT_BUSERR) {
>> +			/* Note: HI3110 Does report overflow errors */
>> +			hi3110_error_skb(net, can_id, data1, data2);
>> +		}
>> +
>> +		if (priv->can.state =3D=3D CAN_STATE_BUS_OFF) {
>> +			if (priv->can.restart_ms =3D=3D 0) {
>> +				priv->force_quit =3D 1;
>> +				priv->can.can_stats.bus_off++;
>> +				can_bus_off(net);
>> +				hi3110_hw_sleep(spi);
>> +				break;
>> +			}
>> +		}
>> +
>> +		if (intf =3D=3D 0)
>> +			break;
>> +
>> +		if (intf & HI3110_INT_TXCPLT) {
>> +			net->stats.tx_packets++;
>> +			net->stats.tx_bytes +=3D priv->tx_len - 1;
>> +			can_led_event(net, CAN_LED_EVENT_TX);
>> +			if (priv->tx_len) {
>> +				can_get_echo_skb(net, 0);
>> +				priv->tx_len =3D 0;
>> +			}
>> +			netif_wake_queue(net);
>> +		}
>> +	}
>> +	mutex_unlock(&priv->hi3110_lock);
>> +	return IRQ_HANDLED;
>> +}
>> +
>> +static int hi3110_open(struct net_device *net)
>> +{
>> +	struct hi3110_priv *priv =3D netdev_priv(net);
>> +	struct spi_device *spi =3D priv->spi;
>> +	unsigned long flags =3D IRQF_ONESHOT | IRQF_TRIGGER_RISING;
>> +	int ret;
>> +
>> +	ret =3D open_candev(net);
>> +	if (ret) {
>> +		dev_err(&spi->dev, "unable to set initial baudrate!\n");
>> +		return ret;
>> +	}
>> +
>> +	mutex_lock(&priv->hi3110_lock);
>> +	hi3110_power_enable(priv->transceiver, 1);
>> +
>> +	priv->force_quit =3D 0;
>> +	priv->tx_skb =3D NULL;
>> +	priv->tx_len =3D 0;
>> +
>> +	ret =3D request_threaded_irq(spi->irq, NULL, hi3110_can_ist,
>> +				   flags, DEVICE_NAME, priv);
>> +	if (ret) {
>> +		dev_err(&spi->dev, "failed to acquire irq %d\n", spi->irq);
>=20
> add propoer goto targets at the and of this function, for easier error
> handling cleanup. This mean basically get rid of hi3110_open_clean(net)=
=2E
>=20

Will fix in V2

>> +		hi3110_power_enable(priv->transceiver, 0);
>> +		close_candev(net);
>> +		goto open_unlock;
>> +	}
>> +
>> +	priv->wq =3D alloc_workqueue("hi3110_wq", WQ_FREEZABLE | WQ_MEM_RECL=
AIM,
>> +			   0);
>> +	INIT_WORK(&priv->tx_work, hi3110_tx_work_handler);
>> +	INIT_WORK(&priv->restart_work, hi3110_restart_work_handler);
>> +
>> +	ret =3D hi3110_hw_reset(spi);
>> +	if (ret) {
>> +		hi3110_open_clean(net);
>> +		goto open_unlock;
>> +	}
>> +	ret =3D hi3110_setup(net, priv, spi);
>> +	if (ret) {
>> +		hi3110_open_clean(net);
>> +		goto open_unlock;
>> +	}
>> +	ret =3D hi3110_set_normal_mode(spi);
>> +	if (ret) {
>> +		hi3110_open_clean(net);
>> +		goto open_unlock;
>> +	}
>> +	can_led_event(net, CAN_LED_EVENT_OPEN);
>> +	netif_wake_queue(net);
>> +
>> +open_unlock:
>> +	mutex_unlock(&priv->hi3110_lock);
>> +	return ret;
>> +}
>> +
>> +static const struct net_device_ops hi3110_netdev_ops =3D {
>> +	.ndo_open =3D hi3110_open,
>> +	.ndo_stop =3D hi3110_stop,
>> +	.ndo_start_xmit =3D hi3110_hard_start_xmit,
>> +};
>> +
>> +static const struct of_device_id hi3110_of_match[] =3D {
>> +	{
>> +		.compatible	=3D "holt,hi3110",
>> +		.data		=3D (void *)CAN_HI3110_HI3110,
>> +	},
>> +	{ }
>> +};
>> +MODULE_DEVICE_TABLE(of, hi3110_of_match);
>> +
>> +static const struct spi_device_id hi3110_id_table[] =3D {
>> +	{
>> +		.name		=3D "hi3110",
>> +		.driver_data	=3D (kernel_ulong_t)CAN_HI3110_HI3110,
>> +	},
>> +	{ }
>> +};
>> +MODULE_DEVICE_TABLE(spi, hi3110_id_table);
>> +
>> +static int hi3110_can_probe(struct spi_device *spi)
>> +{
>> +	const struct of_device_id *of_id =3D of_match_device(hi3110_of_match=
,
>> +							   &spi->dev);
>> +	struct net_device *net;
>> +	struct hi3110_priv *priv;
>> +	struct clk *clk;
>> +	int freq, ret;
>> +
>> +	clk =3D devm_clk_get(&spi->dev, NULL);
>> +	if (IS_ERR(clk)) {
>> +		dev_err(&spi->dev, "no CAN clock source defined\n");
>> +		return PTR_ERR(clk);
>> +	}
>> +	freq =3D clk_get_rate(clk);
>> +
>> +	/* Sanity check */
>> +	if (freq > 40000000)
>> +		return -ERANGE;
>> +
>> +	/* Allocate can/net device */
>> +	net =3D alloc_candev(sizeof(struct hi3110_priv), TX_ECHO_SKB_MAX);
>> +	if (!net)
>> +		return -ENOMEM;
>> +
>> +	if (!IS_ERR(clk)) {
>> +		ret =3D clk_prepare_enable(clk);
>> +		if (ret)
>> +			goto out_free;
>> +	}
>> +
>> +	net->netdev_ops =3D &hi3110_netdev_ops;
>> +	net->flags |=3D IFF_ECHO;
>> +
>> +	priv =3D netdev_priv(net);
>> +	priv->can.bittiming_const =3D &hi3110_bittiming_const;
>> +	priv->can.do_set_mode =3D hi3110_do_set_mode;
>> +	priv->can.clock.freq =3D freq / 2;
>> +	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_3_SAMPLES |
>> +		CAN_CTRLMODE_LOOPBACK | CAN_CTRLMODE_LISTENONLY;
>> +	if (of_id)
>> +		priv->model =3D (enum hi3110_model)of_id->data;
>> +	else
>> +		priv->model =3D spi_get_device_id(spi)->driver_data;
>> +	priv->net =3D net;
>> +	priv->clk =3D clk;
>> +
>> +	spi_set_drvdata(spi, priv);
>> +
>> +	/* Configure the SPI bus */
>> +	spi->bits_per_word =3D 8;
>> +	ret =3D spi_setup(spi);
>> +	if (ret)
>> +		goto out_clk;
>> +
>> +	priv->power =3D devm_regulator_get_optional(&spi->dev, "vdd");
>> +	priv->transceiver =3D devm_regulator_get_optional(&spi->dev, "xceive=
r");
>> +	if ((PTR_ERR(priv->power) =3D=3D -EPROBE_DEFER) ||
>> +	    (PTR_ERR(priv->transceiver) =3D=3D -EPROBE_DEFER)) {
>> +		ret =3D -EPROBE_DEFER;
>> +		goto out_clk;
>> +	}
>> +
>> +	ret =3D hi3110_power_enable(priv->power, 1);
>> +	if (ret)
>> +		goto out_clk;
>> +
>> +	priv->spi =3D spi;
>> +	mutex_init(&priv->hi3110_lock);
>> +
>> +	/* If requested, allocate DMA buffers */
>> +	if (hi3110_enable_dma) {
>> +		spi->dev.coherent_dma_mask =3D ~0;
>> +
>> +		/* Minimum coherent DMA allocation is PAGE_SIZE, so allocate
>> +		 * that much and share it between Tx and Rx DMA buffers.
>> +		 */
>> +		priv->spi_tx_buf =3D dmam_alloc_coherent(&spi->dev,
>> +						      PAGE_SIZE,
>> +						      &priv->spi_tx_dma,
>> +						      GFP_DMA);
>> +
>> +		if (priv->spi_tx_buf) {
>> +			priv->spi_rx_buf =3D (priv->spi_tx_buf + (PAGE_SIZE / 2));
>> +			priv->spi_rx_dma =3D (dma_addr_t)(priv->spi_tx_dma +
>> +							(PAGE_SIZE / 2));
>> +		} else {
>> +			/* Fall back to non-DMA */
>> +			hi3110_enable_dma =3D 0;
>> +		}
>> +	}
>> +
>> +	/* Allocate non-DMA buffers */
>> +	if (!hi3110_enable_dma) {
>> +		priv->spi_tx_buf =3D devm_kzalloc(&spi->dev, RX_BUF_LEN,
>> +				GFP_KERNEL);
>> +		if (!priv->spi_tx_buf) {
>> +			ret =3D -ENOMEM;
>> +			goto error_probe;
>> +		}
>> +		priv->spi_rx_buf =3D devm_kzalloc(&spi->dev, RX_BUF_LEN,
>> +				GFP_KERNEL);
>> +
>> +		if (!priv->spi_rx_buf) {
>> +			ret =3D -ENOMEM;
>> +			goto error_probe;
>> +		}
>> +	}
>> +
>> +	SET_NETDEV_DEV(net, &spi->dev);
>> +
>> +	ret =3D hi3110_hw_probe(spi);
>> +	if (ret) {
>> +		if (ret =3D=3D -ENODEV)
>> +			dev_err(&spi->dev, "Cannot initialize %x. Wrong wiring?\n",
>> +				priv->model);
>> +		goto error_probe;
>> +	}
>> +	hi3110_hw_sleep(spi);
>> +
>> +	ret =3D register_candev(net);
>> +	if (ret)
>> +		goto error_probe;
>> +
>> +	devm_can_led_init(net);
>> +	netdev_info(net, "%x successfully initialized.\n", priv->model);
>> +
>> +	return 0;
>> +
>> +error_probe:
>> +	hi3110_power_enable(priv->power, 0);
>> +
>> +out_clk:
>> +	if (!IS_ERR(clk))
>> +		clk_disable_unprepare(clk);
>> +
>> +out_free:
>> +	free_candev(net);
>> +
>> +	dev_err(&spi->dev, "Probe failed, err=3D%d\n", -ret);
>> +	return ret;
>> +}
>> +
>> +static int hi3110_can_remove(struct spi_device *spi)
>> +{
>> +	struct hi3110_priv *priv =3D spi_get_drvdata(spi);
>> +	struct net_device *net =3D priv->net;
>> +
>> +	unregister_candev(net);
>> +
>> +	hi3110_power_enable(priv->power, 0);
>> +
>> +	if (!IS_ERR(priv->clk))
>> +		clk_disable_unprepare(priv->clk);
>> +
>> +	free_candev(net);
>> +
>> +	return 0;
>> +}
>> +
>> +static int __maybe_unused hi3110_can_suspend(struct device *dev)
>> +{
>> +	struct spi_device *spi =3D to_spi_device(dev);
>> +	struct hi3110_priv *priv =3D spi_get_drvdata(spi);
>> +	struct net_device *net =3D priv->net;
>> +
>> +	priv->force_quit =3D 1;
>> +	disable_irq(spi->irq);
>> +
>> +	/* Note: at this point neither IST nor workqueues are running.
>> +	 * open/stop cannot be called anyway so locking is not needed
>> +	 */
>> +	if (netif_running(net)) {
>> +		netif_device_detach(net);
>> +
>> +		hi3110_hw_sleep(spi);
>> +		hi3110_power_enable(priv->transceiver, 0);
>> +		priv->after_suspend =3D AFTER_SUSPEND_UP;
>> +	} else {
>> +		priv->after_suspend =3D AFTER_SUSPEND_DOWN;
>> +	}
>> +
>> +	if (!IS_ERR_OR_NULL(priv->power)) {
>> +		regulator_disable(priv->power);
>> +		priv->after_suspend |=3D AFTER_SUSPEND_POWER;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static int __maybe_unused hi3110_can_resume(struct device *dev)
>> +{
>> +	struct spi_device *spi =3D to_spi_device(dev);
>> +	struct hi3110_priv *priv =3D spi_get_drvdata(spi);
>> +
>> +	if (priv->after_suspend & AFTER_SUSPEND_POWER)
>> +		hi3110_power_enable(priv->power, 1);
>> +
>> +	if (priv->after_suspend & AFTER_SUSPEND_UP) {
>> +		hi3110_power_enable(priv->transceiver, 1);
>> +		queue_work(priv->wq, &priv->restart_work);
>> +	} else {
>> +		priv->after_suspend =3D 0;
>> +	}
>> +
>> +	priv->force_quit =3D 0;
>> +	enable_irq(spi->irq);
>> +	return 0;
>> +}
>> +
>> +static SIMPLE_DEV_PM_OPS(hi3110_can_pm_ops, hi3110_can_suspend,
>> +	hi3110_can_resume);
>> +
>> +static struct spi_driver hi3110_can_driver =3D {
>> +	.driver =3D {
>> +		.name =3D DEVICE_NAME,
>> +		.of_match_table =3D hi3110_of_match,
>> +		.pm =3D &hi3110_can_pm_ops,
>> +	},
>> +	.id_table =3D hi3110_id_table,
>> +	.probe =3D hi3110_can_probe,
>> +	.remove =3D hi3110_can_remove,
>> +};
>> +
>> +module_spi_driver(hi3110_can_driver);
>> +
>> +MODULE_AUTHOR("Akshay Bhat <akshay.bhat@timesys.com>");
>> +MODULE_AUTHOR("Casey Fitzpatrick <casey.fitzpatrick@timesys.com>");
>> +MODULE_DESCRIPTION("Holt HI-3110 CAN driver");
>> +MODULE_LICENSE("GPL v2");
>>
>=20
> Marc
>=20

Thanks for all the feedback.
Akshay


--hILNXPPHD4JdQwmWT7SExs1Nn0JvL1SF8--

--tC1OOt0fscRSkBfwSaDgBh1kRvKiQ9ewU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYfmxlAAoJEFeJceI6faXZfY4P/1kHtp9F2roSpnZoVSxApkg9
WWAcjmPcMXS3ffKkGh25P6P8+NnWsj4dVbcizdLTVPLQwGCUal5Il+uqaWyPXF+9
mkejtm4I7/zexM3w1ZyCG+kYSwM0WiwJwsGk/0mg7a2dtS5eOwvZDx/hyxUlEyQX
Wzf3bcFmO/fWIOf2JqO8sOZa1jMY2FdMu0XZJcDHUWwnvsE+uAuum3eC1I5DrBi2
YYKpVrcQuV/gqVj3sAj5wwlxaQOJgQY4Scl1ipW1mKfpEt/VPs9bd3PmTAI0mz+X
kgg5VGFN6ith/iirWrhW/xd1J+0uuSHlKIqB25HtdqVn3QKiOfpFsyCZpdybtJU+
MvuoNhp+Mg9XCRuDG/cMXQUu9jO1OcmHUQCaErVSrWA4Hd1XnTMmXelLRVa714CB
bC855+b4mPhJwDFfur1n6s8qkKxL1HK3wwa5wcS/uOSejYDzkb91RNi2uEntHeJa
win/BBeS3aIT046bgF0bV8WOnwUoYui5NNZUWAEVh6Akr9CWblVROFutS/AB8Zgi
3KvHUfMOcD5+X0JBszzprweXshcHgXHdW6hGAvjvSVRXHQ65s05kqRtFmp2mp2oC
/pPFvMkfCs2UM5pzc/K63zZuY4KM/UVKBfl3uACqKrB+u9mKpZbEccA8bLGTw0wz
NtDT4YbouYymOC2VKzKM
=9u13
-----END PGP SIGNATURE-----

--tC1OOt0fscRSkBfwSaDgBh1kRvKiQ9ewU--
