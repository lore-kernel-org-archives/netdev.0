From: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
Subject: Re: [PATCH net-next v1 1/3] ieee802154:
 cc2520: adds driver for TI CC2520 radio
Date: Tue, 17 Jun 2014 14:45:42 +0530 (IST)
Message-ID: <1929819035.7546.1402996542810.JavaMail.open-xchange@webmail.cdac.in>
Reply-To: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2066798181761481918=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============2066798181761481918==
Content-Type: multipart/alternative;
	boundary="----=_Part_7545_1931534041.1402996542714"


------=_Part_7545_1931534041.1402996542714
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 06/17/2014 02:11 PM, Alexander Aring wrote:

> 
>     Hi Varka,
> 
>     you are on v2 not v1. :-)
> 

> 
>     On Tue, Jun 17, 2014 at 12:44:56PM +0530, Varka Bhadram wrote:
> 
>         > > 
> >         This patch adds the driver support for TI cc2520 radio.
> > 
> >         Few points about CC2520:
> >          - The CC2520 is TI's second generation IEEE 802.15.4 RF transceiver
> >          for the 2.4 GHz unlicensed ISM band.
> >          - DSSS baseband modem with 250 kbps data rate
> >          - Programmable output power up to +5 dBm
> >          - Excellent receiver sensitivity (-98 dBm)
> > 
> > 
> >     > 
>     I meant here more what the driver supports... not what the Transceiver
>     hardware supports.
> 
> 
>         > > 
> >         Signed-off-by: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
> > <mailto:varkab-If5XQcfNmg0@public.gmane.org>
> >         ---
> >          drivers/net/ieee802154/cc2520.c |  966
> > +++++++++++++++++++++++++++++++++++++++
> >          include/linux/spi/cc2520.h      |   26 ++
> >          2 files changed, 992 insertions(+)
> >          create mode 100644 drivers/net/ieee802154/cc2520.c
> >          create mode 100644 include/linux/spi/cc2520.h
> > 
> >         diff --git a/drivers/net/ieee802154/cc2520.c
> > b/drivers/net/ieee802154/cc2520.c
> >         new file mode 100644
> >         index 0000000..7e6afe3
> >         --- /dev/null
> >         +++ b/drivers/net/ieee802154/cc2520.c
> >         @@ -0,0 +1,966 @@
> >         +/* Driver for TI CC2520 802.15.4 Wireless-PAN Networking controller
> >         + *
> >         + * Copyright (C) 2014 Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
> > <mailto:varkab-If5XQcfNmg0@public.gmane.org>
> >         + *        Md.Jamal Mohiuddin <mjmohiuddin-If5XQcfNmg0@public.gmane.org>
> > <mailto:mjmohiuddin-If5XQcfNmg0@public.gmane.org>
> >         + *        P Sowjanya <sowjanyap-If5XQcfNmg0@public.gmane.org> <mailto:sowjanyap-If5XQcfNmg0@public.gmane.org>
> >         + *
> >         + * This program is free software; you can redistribute it and/or
> > modify
> >         + * it under the terms of the GNU General Public License as
> > published by
> >         + * the Free Software Foundation; either version 2 of the License,
> > or
> >         + * (at your option) any later version.
> >         + *
> >         + */
> >         +
> >         +#include <linux/kernel.h>
> >         +#include <linux/module.h>
> >         +#include <linux/gpio.h>
> >         +#include <linux/delay.h>
> >         +#include <linux/spi/spi.h>
> >         +#include <linux/spi/cc2520.h>
> >         +#include <linux/workqueue.h>
> >         +#include <linux/interrupt.h>
> >         +
> >         +#include <linux/skbuff.h>
> >         +
> >         +#include <linux/pinctrl/consumer.h>
> >         +
> >         +#include <linux/of_device.h>
> >         +#include <linux/of_platform.h>
> >         +#include <linux/of_gpio.h>
> >         +
> >         +#include <net/mac802154.h>
> >         +#include <net/wpan-phy.h>
> >         +
> >         +#define SPI_COMMAND_BUFFER 3
> >         +#define HIGH   1
> >         +#define LOW   0
> >         +#define STATE_IDLE  0
> >         +#define RSSI_VALID  0
> >         +#define RSSI_OFFSET  78
> >         +
> >         +#define CC2520_RAM_SIZE  640
> >         +#define CC2520_FIFO_SIZE 128
> >         +
> >         +#define CC2520RAM_TXFIFO 0x100,
> >         +#define CC2520RAM_RXFIFO 0x180,
> >         +#define CC2520RAM_IEEEADDR 0x3EA,
> >         +#define CC2520RAM_PANID  0x3F2,
> >         +#define CC2520RAM_SHORTADDR 0x3F4,
> >         +
> >         +#define CC2520_FREG_MASK 0x3F
> >         +
> >         +/*status byte values */
> >         +#define CC2520_STATUS_XOSC32M_STABLE (1 << 7)
> >         +#define CC2520_STATUS_RSSI_VALID (1 << 6)
> >         +#define CC2520_STATUS_TX_UNDERFLOW (1 << 3)
> >         +
> >         +/*IEEE 802.15.4 defined constants (2.4 GHz logical channels) */
> >         +#define CC2520_MINCHANNEL  11
> >         +#define CC2520_MAXCHANNEL  26
> >         +#define CC2520_CHANNEL_SPACING  5
> >         +
> >         +/*command strobes*/
> >         +#define CC2520_CMD_SNOP   0x00
> >         +#define CC2520_CMD_IBUFLD  0x02
> >         +#define CC2520_CMD_SIBUFEX  0x03
> >         +#define CC2520_CMD_SSAMPLECCA  0x04
> >         +#define CC2520_CMD_SRES   0x0f
> >         +#define CC2520_CMD_MEMORY_MASK  0x0f
> >         +#define CC2520_CMD_MEMORY_READ  0x10
> >         +#define CC2520_CMD_MEMORY_WRITE  0x20
> >         +#define CC2520_CMD_RXBUF  0x30
> >         +#define CC2520_CMD_RXBUFCP  0x38
> >         +#define CC2520_CMD_RXBUFMOV  0x32
> >         +#define CC2520_CMD_TXBUF  0x3A
> >         +#define CC2520_CMD_TXBUFCP  0x3E
> >         +#define CC2520_CMD_RANDOM  0x3C
> >         +#define CC2520_CMD_SXOSCON  0x40
> >         +#define CC2520_CMD_STXCAL  0x41
> >         +#define CC2520_CMD_SRXON  0x42
> >         +#define CC2520_CMD_STXON  0x43
> >         +#define CC2520_CMD_STXONCCA  0x44
> >         +#define CC2520_CMD_SRFOFF  0x45
> >         +#define CC2520_CMD_SXOSCOFF  0x46
> >         +#define CC2520_CMD_SFLUSHRX  0x47
> >         +#define CC2520_CMD_SFLUSHTX  0x48
> >         +#define CC2520_CMD_SACK   0x49
> >         +#define CC2520_CMD_SACKPEND  0x4A
> >         +#define CC2520_CMD_SNACK  0x4B
> >         +#define CC2520_CMD_SRXMASKBITSET 0x4C
> >         +#define CC2520_CMD_SRXMASKBITCLR 0x4D
> >         +#define CC2520_CMD_RXMASKAND  0x4E
> >         +#define CC2520_CMD_RXMASKOR  0x4F
> >         +#define CC2520_CMD_MEMCP  0x50
> >         +#define CC2520_CMD_MEMCPR  0x52
> >         +#define CC2520_CMD_MEMXCP  0x54
> >         +#define CC2520_CMD_MEMXWR  0x56
> >         +#define CC2520_CMD_BCLR   0x58
> >         +#define CC2520_CMD_BSET   0x59
> >         +#define CC2520_CMD_CTR_UCTR  0x60
> >         +#define CC2520_CMD_CBCMAC  0x64
> >         +#define CC2520_CMD_UCBCMAC  0x66
> >         +#define CC2520_CMD_CCM   0x68
> >         +#define CC2520_CMD_UCCM   0x6A
> >         +#define CC2520_CMD_ECB   0x70
> >         +#define CC2520_CMD_ECBO   0x72
> >         +#define CC2520_CMD_ECBX   0x74
> >         +#define CC2520_CMD_INC   0x78
> >         +#define CC2520_CMD_ABORT  0x7F
> >         +#define CC2520_CMD_REGISTER_READ 0x80
> >         +#define CC2520_CMD_REGISTER_WRITE 0xC0
> >         +
> >         +/* status registers */
> >         +#define CC2520_CHIPID   0x40
> >         +#define CC2520_VERSION   0x42
> >         +#define CC2520_EXTCLOCK   0x44
> >         +#define CC2520_MDMCTRL0   0x46
> >         +#define CC2520_MDMCTRL1   0x47
> >         +#define CC2520_FREQEST   0x48
> >         +#define CC2520_RXCTRL   0x4A
> >         +#define CC2520_FSCTRL   0x4C
> >         +#define CC2520_FSCAL0   0x4E
> >         +#define CC2520_FSCAL1   0x4F
> >         +#define CC2520_FSCAL2   0x50
> >         +#define CC2520_FSCAL3   0x51
> >         +#define CC2520_AGCCTRL0   0x52
> >         +#define CC2520_AGCCTRL1   0x53
> >         +#define CC2520_AGCCTRL2   0x54
> >         +#define CC2520_AGCCTRL3   0x55
> >         +#define CC2520_ADCTEST0   0x56
> >         +#define CC2520_ADCTEST1   0x57
> >         +#define CC2520_ADCTEST2   0x58
> >         +#define CC2520_MDMTEST0   0x5A
> >         +#define CC2520_MDMTEST1   0x5B
> >         +#define CC2520_DACTEST0   0x5C
> >         +#define CC2520_DACTEST1   0x5D
> >         +#define CC2520_ATEST   0x5E
> >         +#define CC2520_DACTEST2   0x5F
> >         +#define CC2520_PTEST0   0x60
> >         +#define CC2520_PTEST1   0x61
> >         +#define CC2520_RESERVED   0x62
> >         +#define CC2520_DPUBIST   0x7A
> >         +#define CC2520_ACTBIST   0x7C
> >         +#define CC2520_RAMBIST   0x7E
> >         +
> >         +/*frame registers*/
> >         +#define CC2520_FRMFILT0   0x00
> >         +#define CC2520_FRMFILT1   0x01
> >         +#define CC2520_SRCMATCH   0x02
> >         +#define CC2520_SRCSHORTEN0  0x04
> >         +#define CC2520_SRCSHORTEN1  0x05
> >         +#define CC2520_SRCSHORTEN2  0x06
> >         +#define CC2520_SRCEXTEN0  0x08
> >         +#define CC2520_SRCEXTEN1  0x09
> >         +#define CC2520_SRCEXTEN2  0x0A
> >         +#define CC2520_FRMCTRL0   0x0C
> >         +#define CC2520_FRMCTRL1   0x0D
> >         +#define CC2520_RXENABLE0  0x0E
> >         +#define CC2520_RXENABLE1  0x0F
> >         +#define CC2520_EXCFLAG0   0x10
> >         +#define CC2520_EXCFLAG1   0x11
> >         +#define CC2520_EXCFLAG2   0x12
> >         +#define CC2520_EXCMASKA0  0x14
> >         +#define CC2520_EXCMASKA1  0x15
> >         +#define CC2520_EXCMASKA2  0x16
> >         +#define CC2520_EXCMASKB0  0x18
> >         +#define CC2520_EXCMASKB1  0x19
> >         +#define CC2520_EXCMASKB2  0x1A
> >         +#define CC2520_EXCBINDX0  0x1C
> >         +#define CC2520_EXCBINDX1  0x1D
> >         +#define CC2520_EXCBINDY0  0x1E
> >         +#define CC2520_EXCBINDY1  0x1F
> >         +#define CC2520_GPIOCTRL0  0x20
> >         +#define CC2520_GPIOCTRL1  0x21
> >         +#define CC2520_GPIOCTRL2  0x22
> >         +#define CC2520_GPIOCTRL3  0x23
> >         +#define CC2520_GPIOCTRL4  0x24
> >         +#define CC2520_GPIOCTRL5  0x25
> >         +#define CC2520_GPIOPOLARITY  0x26
> >         +#define CC2520_GPIOCTRL   0x28
> >         +#define CC2520_DPUCON   0x2A
> >         +#define CC2520_DPUSTAT   0x2C
> >         +#define CC2520_FREQCTRL   0x2E
> >         +#define CC2520_FREQTUNE   0x2F
> >         +#define CC2520_TXPOWER   0x30
> >         +#define CC2520_TXCTRL   0x31
> >         +#define CC2520_FSMSTAT0   0x32
> >         +#define CC2520_FSMSTAT1   0x33
> >         +#define CC2520_FIFOPCTRL  0x34
> >         +#define CC2520_FSMCTRL   0x35
> >         +#define CC2520_CCACTRL0   0x36
> >         +#define CC2520_CCACTRL1   0x37
> >         +#define CC2520_RSSI   0x38
> >         +#define CC2520_RSSISTAT   0x39
> >         +#define CC2520_RXFIRST   0x3C
> >         +#define CC2520_RXFIFOCNT  0x3E
> >         +#define CC2520_TXFIFOCNT  0x3F
> >         +
> >         +/* Driver private information */
> >         +struct cc2520_private {
> >         + struct spi_device *spi;  /* spi device structure */
> >         + struct ieee802154_dev *dev; /* Ieee802.15.4 device */
> >         + u8 *buf;   /* SPI TX/Rx data buffer */
> >         + struct mutex buffer_mutex; /* SPI buffer mutex */
> >         + unsigned is_tx:1;  /* Flag for sync b/w Tx and Rx */
> >         + int fifo_pin;   /* FIFO GPIO pin number */
> >         + struct work_struct fifop_irqwork;/* Workqueue for FIFOP */
> >         + spinlock_t lock;  /* Spin lock */
> >         + struct completion tx_complete; /* Work completion for Tx */
> >         +};
> >         +
> >         +/* Generic Functions */
> >         +static int
> >         +cc2520_cmd_strobe(struct cc2520_private *priv, u8 cmd)
> >         +{
> >         + int ret;
> >         + u8 status = 0xff;
> >         + struct spi_message msg;
> >         + struct spi_transfer xfer = {
> >         +  .len = 0,
> >         +  .tx_buf = priv->buf,
> >         +  .rx_buf = priv->buf,
> >         + };
> >         +
> >         + spi_message_init(&msg);
> >         + spi_message_add_tail(&xfer, &msg);
> >         +
> >         + mutex_lock(&priv->buffer_mutex);
> >         + priv->buf[xfer.len++] = cmd;
> >         + dev_vdbg(&priv->spi->dev,
> >         +   "command strobe buf[0] = %02x\n",
> >         +   priv->buf[0]);
> >         +
> >         + ret = spi_sync(priv->spi, &msg);
> >         + if (!ret)
> >         +  status = priv->buf[0];
> >         + dev_vdbg(&priv->spi->dev,
> >         +   "buf[0] = %02x\n", priv->buf[0]);
> >         + mutex_unlock(&priv->buffer_mutex);
> >         +
> >         + return ret;
> >         +}
> > 
> >     > 
>     What's about to drop the lowlevel spi calls and use spi helper functions?
> 
> 
Many of the people are suggesting to use spi_sync() functions instead of spi
helper functions.

> 
>         > > 
> >         +
> >         +static int
> >         +cc2520_get_status(struct cc2520_private *priv, u8 *status)
> >         +{
> >         + int ret;
> >         + struct spi_message msg;
> >         + struct spi_transfer xfer = {
> >         +  .len = 0,
> >         +  .tx_buf = priv->buf,
> >         +  .rx_buf = priv->buf,
> >         + };
> >         +
> >         + spi_message_init(&msg);
> >         + spi_message_add_tail(&xfer, &msg);
> >         +
> >         + mutex_lock(&priv->buffer_mutex);
> >         + priv->buf[xfer.len++] = CC2520_CMD_SNOP;
> >         + dev_vdbg(&priv->spi->dev,
> >         +   "get status command buf[0] = %02x\n", priv->buf[0]);
> >         +
> >         + ret = spi_sync(priv->spi, &msg);
> >         + if (!ret)
> >         +  *status = priv->buf[0];
> >         + dev_vdbg(&priv->spi->dev,
> >         +   "buf[0] = %02x\n", priv->buf[0]);
> >         + mutex_unlock(&priv->buffer_mutex);
> >         +
> >         + return ret;
> >         +}
> >         +
> >         +static int
> >         +cc2520_write_register(struct cc2520_private *priv, u8 reg, u8
> > value)
> >         +{
> >         + int status;
> >         + struct spi_message msg;
> >         + struct spi_transfer xfer = {
> >         +  .len = 0,
> >         +  .tx_buf = priv->buf,
> >         +  .rx_buf = priv->buf,
> >         + };
> >         +
> >         + spi_message_init(&msg);
> >         + spi_message_add_tail(&xfer, &msg);
> >         +
> >         + mutex_lock(&priv->buffer_mutex);
> >         +
> >         + if (reg <= CC2520_FREG_MASK) {
> >         +  priv->buf[xfer.len++] = CC2520_CMD_REGISTER_WRITE | reg;
> >         +  priv->buf[xfer.len++] = value;
> >         + } else {
> >         +  priv->buf[xfer.len++] = CC2520_CMD_MEMORY_WRITE;
> >         +  priv->buf[xfer.len++] = reg;
> >         +  priv->buf[xfer.len++] = value;
> >         + }
> >         + status = spi_sync(priv->spi, &msg);
> >         + if (msg.status)
> >         +  status = msg.status;
> >         +
> >         + mutex_unlock(&priv->buffer_mutex);
> >         +
> >         + return status;
> >         +}
> >         +
> >         +static int
> >         +cc2520_read_register(struct cc2520_private *priv, u8 reg, u8 *data)
> >         +{
> >         + int status;
> >         + struct spi_message msg;
> >         + struct spi_transfer xfer1 = {
> >         +  .len = 0,
> >         +  .tx_buf = priv->buf,
> >         +  .rx_buf = priv->buf,
> >         + };
> >         +
> >         + struct spi_transfer xfer2 = {
> >         +  .len = 1,
> >         +  .rx_buf = data,
> >         + };
> >         +
> >         + spi_message_init(&msg);
> >         + spi_message_add_tail(&xfer1, &msg);
> >         + spi_message_add_tail(&xfer2, &msg);
> >         +
> >         + mutex_lock(&priv->buffer_mutex);
> >         + priv->buf[xfer1.len++] = CC2520_CMD_MEMORY_READ;
> >         + priv->buf[xfer1.len++] = reg;
> >         +
> >         + status = spi_sync(priv->spi, &msg);
> >         + dev_dbg(&priv->spi->dev,
> >         +  "spi status = %d\n", status);
> >         + if (msg.status)
> >         +  status = msg.status;
> >         +
> >         + mutex_unlock(&priv->buffer_mutex);
> >         +
> >         + return status;
> >         +}
> >         +
> >         +static int
> >         +cc2520_write_txfifo(struct cc2520_private *priv, u8 *data, u8 len)
> >         +{
> >         + int status;
> >         +
> >         + /*
> >         +  *length byte must include FCS even
> >         +  *if it is calculated in the hardware
> >         +  */
> >         + int len_byte = len + 2;
> >         +
> >         + struct spi_message msg;
> >         +
> >         + struct spi_transfer xfer_head = {
> >         +  .len = 0,
> >         +  .tx_buf = priv->buf,
> >         +  .rx_buf = priv->buf,
> >         + };
> >         + struct spi_transfer xfer_len = {
> >         +  .len = 1,
> >         +  .tx_buf = &len_byte,
> >         + };
> >         + struct spi_transfer xfer_buf = {
> >         +  .len = len,
> >         +  .tx_buf = data,
> >         + };
> >         +
> >         + spi_message_init(&msg);
> >         + spi_message_add_tail(&xfer_head, &msg);
> >         + spi_message_add_tail(&xfer_len, &msg);
> >         + spi_message_add_tail(&xfer_buf, &msg);
> >         +
> >         + mutex_lock(&priv->buffer_mutex);
> >         + priv->buf[xfer_head.len++] = CC2520_CMD_TXBUF;
> >         + dev_vdbg(&priv->spi->dev,
> >         +   "TX_FIFO cmd buf[0] = %02x\n", priv->buf[0]);
> >         +
> >         + status = spi_sync(priv->spi, &msg);
> >         + dev_vdbg(&priv->spi->dev, "status = %d\n", status);
> >         + if (msg.status)
> >         +  status = msg.status;
> >         + dev_vdbg(&priv->spi->dev, "status = %d\n", status);
> >         + dev_vdbg(&priv->spi->dev, "buf[0] = %02x\n", priv->buf[0]);
> >         + mutex_unlock(&priv->buffer_mutex);
> >         +
> >         + return status;
> >         +}
> >         +
> >         +static int
> >         +cc2520_read_rxfifo(struct cc2520_private *priv, u8 *data, u8 *len,
> > u8 *lqi)
> > 
> >     > 
>     why is len a pointer here? It's never changed in this function I would
>     prefer const u8 len.
> 
Good catch. Its my mistake. Previously i updated the len pointer and i used in
cc2520_rx().
Thanx

> 
> 
> 
>         > > 
> >         +{
> >         + int status;
> >         + struct spi_message msg;
> >         +
> >         + struct spi_transfer xfer_head = {
> >         +  .len = 0,
> >         +  .tx_buf = priv->buf,
> >         +  .rx_buf = priv->buf,
> >         + };
> >         + struct spi_transfer xfer_buf = {
> >         +  .len = *len,
> >         +  .rx_buf = data,
> >         + };
> >         +
> >         + spi_message_init(&msg);
> >         + spi_message_add_tail(&xfer_head, &msg);
> >         + spi_message_add_tail(&xfer_buf, &msg);
> >         +
> >         + mutex_lock(&priv->buffer_mutex);
> >         + priv->buf[xfer_head.len++] = CC2520_CMD_RXBUF;
> >         +
> >         + dev_vdbg(&priv->spi->dev, "read rxfifo buf[0] = %02x\n",
> > priv->buf[0]);
> >         + dev_vdbg(&priv->spi->dev, "buf[1] = %02x\n", priv->buf[1]);
> >         +
> >         + status = spi_sync(priv->spi, &msg);
> >         + dev_vdbg(&priv->spi->dev, "status = %d\n", status);
> >         + if (msg.status)
> >         +  status = msg.status;
> >         + dev_vdbg(&priv->spi->dev, "status = %d\n", status);
> >         + dev_vdbg(&priv->spi->dev,
> >         +   "return status buf[0] = %02x\n", priv->buf[0]);
> >         + dev_vdbg(&priv->spi->dev, "length buf[1] = %02x\n", priv->buf[1]);
> >         +
> >         + *lqi = data[priv->buf[1] - 1] & 0x7f;
> >         +
> >         + mutex_unlock(&priv->buffer_mutex);
> >         +
> >         + return status;
> >         +}
> >         +
> >         +static int cc2520_start(struct ieee802154_dev *dev)
> >         +{
> >         + return cc2520_cmd_strobe(dev->priv, CC2520_CMD_SRXON);
> >         +}
> >         +
> >         +static void cc2520_stop(struct ieee802154_dev *dev)
> >         +{
> >         + cc2520_cmd_strobe(dev->priv, CC2520_CMD_SRFOFF);
> >         +}
> >         +
> >         +static int
> >         +cc2520_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
> >         +{
> >         + struct cc2520_private *priv = dev->priv;
> >         + unsigned long flags;
> >         + int rc;
> >         + u8 status = 0;
> >         +
> >         + rc = cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHTX);
> >         + if (rc)
> >         +  goto err_tx;
> >         +
> >         + rc = cc2520_write_txfifo(priv, skb->data, skb->len);
> >         + if (rc)
> >         +  goto err_tx;
> >         +
> >         + rc = cc2520_get_status(priv, &status);
> >         + if (rc)
> >         +  goto err_tx;
> >         +
> >         + if (status & CC2520_STATUS_TX_UNDERFLOW) {
> >         +  dev_err(&priv->spi->dev, "cc2520 tx underflow exception\n");
> >         +  goto err_tx;
> >         + }
> >         +
> >         + spin_lock_irqsave(&priv->lock, flags);
> >         + BUG_ON(priv->is_tx);
> >         + priv->is_tx = 1;
> >         + spin_unlock_irqrestore(&priv->lock, flags);
> >         +
> >         + rc = cc2520_cmd_strobe(priv, CC2520_CMD_STXONCCA);
> >         + if (rc)
> >         +  goto err;
> >         +
> >         + rc = wait_for_completion_interruptible(&priv->tx_complete);
> >         + if (rc < 0)
> >         +  goto err;
> > 
> >     > 
>     mhhh, I never see a reinit_completion and ask myself how the driver can
>     ever work?
> 
>     We should also use a wait_for_completion_timeout here, then you need to
>     handle the error handling with if (!rc).
> 
I initialized the work completion in the cc2520_probe():
                          init_completion(&priv->tx_complete);

It will wait until the SFD interrupt to raise and get the completion signal from
sfd_isr() by:
                          complete(&priv->tx_complete)

wait_for_completion_interruptible() API will put the thread in interruptible
state.

> 
> 
> 
>         > > 
> >         +
> >         + cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHTX);
> >         + cc2520_cmd_strobe(priv, CC2520_CMD_SRXON);
> >         +
> >         + return rc;
> >         +err:
> >         + spin_lock_irqsave(&priv->lock, flags);
> >         + priv->is_tx = 0;
> >         + spin_unlock_irqrestore(&priv->lock, flags);
> >         +err_tx:
> >         + return rc;
> >         +}
> >         +
> >         +
> >         +static int cc2520_rx(struct cc2520_private *priv)
> >         +{
> >         + u8 len = 0, lqi = 0, bytes = 1;
> >         + struct sk_buff *skb;
> >         +
> >         + cc2520_read_rxfifo(priv, &len, &bytes, &lqi);
> >         +
> >         + skb = alloc_skb(len, GFP_KERNEL);
> >         + if (!skb)
> >         +  return -ENOMEM;
> >         +
> >         + cc2520_read_rxfifo(priv, skb_put(skb, len), &len, &lqi);
> >         + if (len < 2) {
> >         +  kfree_skb(skb);
> >         +  return -EINVAL;
> >         + }
> >         +
> >         + skb_trim(skb, skb->len - 2);
> >         +
> >         + ieee802154_rx_irqsafe(priv->dev, skb, lqi);
> >         +
> >         + dev_vdbg(&priv->spi->dev, "RXFIFO: %x %x\n", len, lqi);
> >         +
> >         + return 0;
> >         +}
> >         +
> >         +static int
> >         +cc2520_ed(struct ieee802154_dev *dev, u8 *level)
> >         +{
> >         + struct cc2520_private *priv = dev->priv;
> >         + u8 status = 0xff;
> >         + u8 rssi;
> >         + int ret;
> >         +
> >         + ret = cc2520_read_register(priv , CC2520_RSSISTAT, &status);
> >         + if (ret)
> >         +  return ret;
> >         +
> >         + if (status != RSSI_VALID) {
> >         +  ret = -EINVAL;
> >         +  return ret;
> >         + }
> >         +
> >         + ret = cc2520_read_register(priv , CC2520_RSSI, &rssi);
> >         + if (ret)
> >         +  return ret;
> >         +
> >         + /* level = RSSI(rssi) - OFFSET [dBm] : offset is 76dBm*/
> >         + *level = rssi - RSSI_OFFSET;
> >         +
> >         + return ret;
> >         +}
> >         +
> >         +static int
> >         +cc2520_set_channel(struct ieee802154_dev *dev, int page, int
> > channel)
> >         +{
> >         + struct cc2520_private *priv = dev->priv;
> >         + int ret;
> >         +
> >         + might_sleep();
> >         + dev_dbg(&priv->spi->dev, "trying to set channel\n");
> >         +
> >         + BUG_ON(page != 0);
> >         + BUG_ON(channel < CC2520_MINCHANNEL);
> >         + BUG_ON(channel > CC2520_MAXCHANNEL);
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_FREQCTRL,
> >         +        11 + 5*(channel - 11));
> >         +
> >         + return ret;
> >         +}
> >         +
> >         +static struct ieee802154_ops cc2520_ops = {
> >         + .owner = THIS_MODULE,
> >         + .start = cc2520_start,
> >         + .stop = cc2520_stop,
> >         + .xmit = cc2520_tx,
> >         + .ed = cc2520_ed,
> >         + .set_channel = cc2520_set_channel,
> >         +};
> >         +
> >         +static int cc2520_register(struct cc2520_private *priv)
> >         +{
> >         + int ret = -ENOMEM;
> >         +
> >         + priv->dev = ieee802154_alloc_device(sizeof(*priv), &cc2520_ops);
> >         + if (!priv->dev)
> >         +  goto err_ret;
> >         +
> >         + priv->dev->priv = priv;
> >         + priv->dev->parent = &priv->spi->dev;
> >         + priv->dev->extra_tx_headroom = 0;
> >         +
> >         + /* We do support only 2.4 Ghz */
> >         + priv->dev->phy->channels_supported[0] = 0x7FFF800;
> >         + priv->dev->flags = IEEE802154_HW_OMIT_CKSUM;
> >         +
> >         + dev_vdbg(&priv->spi->dev, "registered cc2520\n");
> >         + ret = ieee802154_register_device(priv->dev);
> >         + if (ret)
> >         +  goto err_free_device;
> >         +
> >         + return 0;
> >         +
> >         +err_free_device:
> >         + ieee802154_free_device(priv->dev);
> >         +err_ret:
> >         + return ret;
> >         +}
> >         +
> >         +static void cc2520_fifop_irqwork(struct work_struct *work)
> >         +{
> >         + struct cc2520_private *priv
> >         +  = container_of(work, struct cc2520_private, fifop_irqwork);
> >         +
> >         + dev_dbg(&priv->spi->dev, "fifop interrupt received\n");
> >         +
> >         + if (gpio_get_value(priv->fifo_pin))
> >         +  cc2520_rx(priv);
> >         + else
> >         +  dev_err(&priv->spi->dev, "rxfifo overflow\n");
> >         +
> >         + cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHRX);
> >         + cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHRX);
> >         +}
> >         +
> >         +static irqreturn_t cc2520_fifop_isr(int irq, void *data)
> >         +{
> >         + struct cc2520_private *priv = data;
> >         +
> >         + schedule_work(&priv->fifop_irqwork);
> >         +
> >         + return IRQ_HANDLED;
> >         +}
> >         +
> >         +static irqreturn_t cc2520_sfd_isr(int irq, void *data)
> >         +{
> >         + struct cc2520_private *priv = data;
> >         + unsigned long flags;
> >         +
> >         + spin_lock_irqsave(&priv->lock, flags);
> >         + if (priv->is_tx) {
> >         +  priv->is_tx = 0;
> >         +  spin_unlock_irqrestore(&priv->lock, flags);
> >         +  dev_dbg(&priv->spi->dev, "SFD for TX\n");
> >         +  complete(&priv->tx_complete);
> >         + } else {
> >         +  spin_unlock_irqrestore(&priv->lock, flags);
> >         +  dev_dbg(&priv->spi->dev, "SFD for RX\n");
> >         + }
> >         +
> >         + return IRQ_HANDLED;
> >         +}
> >         +
> >         +static int cc2520_hw_init(struct cc2520_private *priv)
> >         +{
> >         + u8 status = 0, state = 0xff;
> >         + int ret;
> >         + int timeout = 100;
> >         +
> >         + ret = cc2520_read_register(priv, CC2520_FSMSTAT1, &state);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + if (state != STATE_IDLE)
> >         +  return -EINVAL;
> >         +
> >         + do {
> >         +  ret = cc2520_get_status(priv, &status);
> >         +  if (ret)
> >         +   goto err_ret;
> >         +
> >         +  if (timeout-- <= 0) {
> >         +   dev_err(&priv->spi->dev, "oscillator start failed!\n");
> >         +   return ret;
> >         +  }
> >         +  udelay(1);
> >         + } while (!(status & CC2520_STATUS_XOSC32M_STABLE));
> >         +
> >         + dev_vdbg(&priv->spi->dev, "oscillator successfully brought up\n");
> >         +
> >         + /*Registers default value: section 28.1 in Datasheet*/
> >         + ret = cc2520_write_register(priv, CC2520_TXPOWER, 0xF7);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_CCACTRL0, 0x1A);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_MDMCTRL0, 0x85);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_MDMCTRL1, 0x14);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_RXCTRL, 0x3f);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_FSCTRL, 0x5a);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_FSCAL1, 0x2b);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_AGCCTRL1, 0x11);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_ADCTEST0, 0x10);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_ADCTEST1, 0x0e);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_ADCTEST2, 0x03);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_FRMCTRL0, 0x60);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_FRMCTRL1, 0x03);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_FRMFILT0, 0x00);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + ret = cc2520_write_register(priv, CC2520_FIFOPCTRL, 127);
> >         + if (ret)
> >         +  goto err_ret;
> >         +
> >         + return 0;
> >         +
> >         +err_ret:
> >         + return ret;
> >         +}
> >         +
> >         +static struct cc2520_platform_data *
> >         +cc2520_get_platform_data(struct spi_device *spi)
> >         +{
> >         + struct cc2520_platform_data *pdata;
> >         + struct device_node __maybe_unused *np = spi->dev.of_node;
> >         + struct cc2520_private *priv = spi_get_drvdata(spi);
> >         +
> >         + if (!IS_ENABLED(CONFIG_OF) || !np)
> >         +  return spi->dev.platform_data;
> >         +
> >         + pdata = devm_kzalloc(&spi->dev, sizeof(*pdata), GFP_KERNEL);
> >         + if (!pdata)
> >         +  goto done;
> >         +
> >         + pdata->fifo = of_get_named_gpio(np, "fifo-gpio", 0);
> >         + priv->fifo_pin = pdata->fifo;
> >         +
> >         + pdata->fifop = of_get_named_gpio(np, "fifop-gpio", 0);
> >         +
> >         + pdata->sfd = of_get_named_gpio(np, "sfd-gpio", 0);
> >         + pdata->cca = of_get_named_gpio(np, "cca-gpio", 0);
> >         + pdata->vreg = of_get_named_gpio(np, "vreg-gpio", 0);
> >         + pdata->reset = of_get_named_gpio(np, "reset-gpio", 0);
> >         +
> >         + spi->dev.platform_data = pdata;
> >         +
> >         +done:
> >         + return pdata;
> >         +}
> >         +
> >         +static int cc2520_probe(struct spi_device *spi)
> >         +{
> >         + struct cc2520_private *priv;
> >         + struct pinctrl *pinctrl;
> >         + struct cc2520_platform_data *pdata;
> >         + struct device_node __maybe_unused *np = spi->dev.of_node;
> >         + int ret;
> >         +
> >         + priv = devm_kzalloc(&spi->dev,
> >         +       sizeof(struct cc2520_private), GFP_KERNEL);
> >         + if (!priv) {
> >         +  ret = -ENOMEM;
> >         +  goto err_ret;
> >         + }
> >         +
> >         + spi_set_drvdata(spi, priv);
> >         +
> >         + pinctrl = devm_pinctrl_get_select_default(&spi->dev);
> >         + if (IS_ERR(pinctrl))
> >         +  dev_warn(&spi->dev,
> >         +    "pinctrl pins are not configured from the driver");
> >         +
> >         + pdata = cc2520_get_platform_data(spi);
> >         + if (!pdata) {
> >         +  dev_err(&spi->dev, "no platform data\n");
> >         +  return -EINVAL;
> >         + }
> >         +
> >         + priv->spi = spi;
> >         +
> >         + priv->buf = devm_kzalloc(&spi->dev,
> >         +     SPI_COMMAND_BUFFER, GFP_KERNEL);
> >         + if (!priv->buf) {
> >         +  ret = -ENOMEM;
> >         +  goto err_ret;
> >         + }
> >         +
> >         + mutex_init(&priv->buffer_mutex);
> >         + INIT_WORK(&priv->fifop_irqwork, cc2520_fifop_irqwork);
> >         + spin_lock_init(&priv->lock);
> >         + init_completion(&priv->tx_complete);
> >         +
> >         + /* Request all the gpio's */
> >         + if (!gpio_is_valid(pdata->fifo)) {
> >         +  dev_err(&spi->dev, "fifo gpio is not valid\n");
> >         +  ret = -EINVAL;
> >         +  goto err_hw_init;
> >         + } else {
> >         +  ret = devm_gpio_request_one(&spi->dev, pdata->fifo,
> >         +         GPIOF_IN, "fifo");
> >         +  if (ret)
> >         +   goto err_hw_init;
> >         + }
> > 
> >     > 
>     you can drop the else branch here...
> 

gpio_is_valid() will only check whether the GPIO PIN number is within the range
of GPIO numbers or not.
devm_gpio_request_one() request for the GPIO number. If other driver try to
requst for the same number
GPIO/Pinctrl subsytems through an error saying that 'The GPIO number is already
used by someone else'



-Varka Bhadram
-------------------------------------------------------------------------------------------------------------------------------
[ C-DAC is on Social-Media too. Kindly follow us at:
Facebook: https://www.facebook.com/CDACINDIA & Twitter: @cdacindia ]

This e-mail is for the sole use of the intended recipient(s) and may
contain confidential and privileged information. If you are not the
intended recipient, please contact the sender by reply e-mail and destroy
all copies and the original message. Any unauthorized review, use,
disclosure, dissemination, forwarding, printing or copying of this email
is strictly prohibited and appropriate legal action will be taken.
-------------------------------------------------------------------------------------------------------------------------------


------=_Part_7545_1931534041.1402996542714
MIME-Version: 1.0
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
 </head><body style="">
 
 
  <div class="moz-cite-prefix">
   On 06/17/2014 02:11 PM, Alexander Aring wrote:
  </div> 
  <blockquote type="cite"> 
   <pre>Hi Varka,

you are on v2 not v1. :-)</pre> 
  </blockquote> 
  <blockquote type="cite"> 
   <pre>On Tue, Jun 17, 2014 at 12:44:56PM +0530, Varka Bhadram wrote:
</pre> 
   <blockquote type="cite"> 
    <pre>This patch adds the driver support for TI cc2520 radio.

Few points about CC2520:
 - The CC2520 is TI&#39;s second generation IEEE 802.15.4 RF transceiver 
 for the 2.4 GHz unlicensed ISM band.
 - DSSS baseband modem with 250 kbps data rate
 - Programmable output power up to +5 dBm
 - Excellent receiver sensitivity (-98 dBm)

</pre> 
   </blockquote> 
   <pre>I meant here more what the driver supports... not what the Transceiver
hardware supports.

</pre> 
   <blockquote type="cite"> 
    <pre>Signed-off-by: Varka Bhadram <a href="mailto:varkab-If5XQcfNmg0@public.gmane.org">&#60;varkab-If5XQcfNmg0@public.gmane.org&#62;</a>
---
 drivers/net/ieee802154/cc2520.c |  966 +++++++++++++++++++++++++++++++++++++++
 include/linux/spi/cc2520.h      |   26 ++
 2 files changed, 992 insertions(+)
 create mode 100644 drivers/net/ieee802154/cc2520.c
 create mode 100644 include/linux/spi/cc2520.h

diff --git a/drivers/net/ieee802154/cc2520.c b/drivers/net/ieee802154/cc2520.c
new file mode 100644
index 0000000..7e6afe3
--- /dev/null
+++ b/drivers/net/ieee802154/cc2520.c
@@ -0,0 +1,966 @@
+/* Driver for TI CC2520 802.15.4 Wireless-PAN Networking controller
+ *
+ * Copyright (C) 2014 Varka Bhadram <a href="mailto:varkab-If5XQcfNmg0@public.gmane.org">&#60;varkab-If5XQcfNmg0@public.gmane.org&#62;</a>
+ *        Md.Jamal Mohiuddin <a href="mailto:mjmohiuddin-If5XQcfNmg0@public.gmane.org">&#60;mjmohiuddin-If5XQcfNmg0@public.gmane.org&#62;</a>
+ *        P Sowjanya <a href="mailto:sowjanyap-If5XQcfNmg0@public.gmane.org">&#60;sowjanyap-If5XQcfNmg0@public.gmane.org&#62;</a>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+
+#include &#60;linux/kernel.h&#62;
+#include &#60;linux/module.h&#62;
+#include &#60;linux/gpio.h&#62;
+#include &#60;linux/delay.h&#62;
+#include &#60;linux/spi/spi.h&#62;
+#include &#60;linux/spi/cc2520.h&#62;
+#include &#60;linux/workqueue.h&#62;
+#include &#60;linux/interrupt.h&#62;
+
+#include &#60;linux/skbuff.h&#62;
+
+#include &#60;linux/pinctrl/consumer.h&#62;
+
+#include &#60;linux/of_device.h&#62;
+#include &#60;linux/of_platform.h&#62;
+#include &#60;linux/of_gpio.h&#62;
+
+#include &#60;net/mac802154.h&#62;
+#include &#60;net/wpan-phy.h&#62;
+
+#define SPI_COMMAND_BUFFER 3
+#define HIGH   1
+#define LOW   0
+#define STATE_IDLE  0
+#define RSSI_VALID  0
+#define RSSI_OFFSET  78
+
+#define CC2520_RAM_SIZE  640
+#define CC2520_FIFO_SIZE 128
+
+#define CC2520RAM_TXFIFO 0x100,
+#define CC2520RAM_RXFIFO 0x180,
+#define CC2520RAM_IEEEADDR 0x3EA,
+#define CC2520RAM_PANID  0x3F2,
+#define CC2520RAM_SHORTADDR 0x3F4,
+
+#define CC2520_FREG_MASK 0x3F
+
+/*status byte values */
+#define CC2520_STATUS_XOSC32M_STABLE (1 &#60;&#60; 7)
+#define CC2520_STATUS_RSSI_VALID (1 &#60;&#60; 6)
+#define CC2520_STATUS_TX_UNDERFLOW (1 &#60;&#60; 3)
+
+/*IEEE 802.15.4 defined constants (2.4 GHz logical channels) */
+#define CC2520_MINCHANNEL  11
+#define CC2520_MAXCHANNEL  26
+#define CC2520_CHANNEL_SPACING  5
+
+/*command strobes*/
+#define CC2520_CMD_SNOP   0x00
+#define CC2520_CMD_IBUFLD  0x02
+#define CC2520_CMD_SIBUFEX  0x03
+#define CC2520_CMD_SSAMPLECCA  0x04
+#define CC2520_CMD_SRES   0x0f
+#define CC2520_CMD_MEMORY_MASK  0x0f
+#define CC2520_CMD_MEMORY_READ  0x10
+#define CC2520_CMD_MEMORY_WRITE  0x20
+#define CC2520_CMD_RXBUF  0x30
+#define CC2520_CMD_RXBUFCP  0x38
+#define CC2520_CMD_RXBUFMOV  0x32
+#define CC2520_CMD_TXBUF  0x3A
+#define CC2520_CMD_TXBUFCP  0x3E
+#define CC2520_CMD_RANDOM  0x3C
+#define CC2520_CMD_SXOSCON  0x40
+#define CC2520_CMD_STXCAL  0x41
+#define CC2520_CMD_SRXON  0x42
+#define CC2520_CMD_STXON  0x43
+#define CC2520_CMD_STXONCCA  0x44
+#define CC2520_CMD_SRFOFF  0x45
+#define CC2520_CMD_SXOSCOFF  0x46
+#define CC2520_CMD_SFLUSHRX  0x47
+#define CC2520_CMD_SFLUSHTX  0x48
+#define CC2520_CMD_SACK   0x49
+#define CC2520_CMD_SACKPEND  0x4A
+#define CC2520_CMD_SNACK  0x4B
+#define CC2520_CMD_SRXMASKBITSET 0x4C
+#define CC2520_CMD_SRXMASKBITCLR 0x4D
+#define CC2520_CMD_RXMASKAND  0x4E
+#define CC2520_CMD_RXMASKOR  0x4F
+#define CC2520_CMD_MEMCP  0x50
+#define CC2520_CMD_MEMCPR  0x52
+#define CC2520_CMD_MEMXCP  0x54
+#define CC2520_CMD_MEMXWR  0x56
+#define CC2520_CMD_BCLR   0x58
+#define CC2520_CMD_BSET   0x59
+#define CC2520_CMD_CTR_UCTR  0x60
+#define CC2520_CMD_CBCMAC  0x64
+#define CC2520_CMD_UCBCMAC  0x66
+#define CC2520_CMD_CCM   0x68
+#define CC2520_CMD_UCCM   0x6A
+#define CC2520_CMD_ECB   0x70
+#define CC2520_CMD_ECBO   0x72
+#define CC2520_CMD_ECBX   0x74
+#define CC2520_CMD_INC   0x78
+#define CC2520_CMD_ABORT  0x7F
+#define CC2520_CMD_REGISTER_READ 0x80
+#define CC2520_CMD_REGISTER_WRITE 0xC0
+
+/* status registers */
+#define CC2520_CHIPID   0x40
+#define CC2520_VERSION   0x42
+#define CC2520_EXTCLOCK   0x44
+#define CC2520_MDMCTRL0   0x46
+#define CC2520_MDMCTRL1   0x47
+#define CC2520_FREQEST   0x48
+#define CC2520_RXCTRL   0x4A
+#define CC2520_FSCTRL   0x4C
+#define CC2520_FSCAL0   0x4E
+#define CC2520_FSCAL1   0x4F
+#define CC2520_FSCAL2   0x50
+#define CC2520_FSCAL3   0x51
+#define CC2520_AGCCTRL0   0x52
+#define CC2520_AGCCTRL1   0x53
+#define CC2520_AGCCTRL2   0x54
+#define CC2520_AGCCTRL3   0x55
+#define CC2520_ADCTEST0   0x56
+#define CC2520_ADCTEST1   0x57
+#define CC2520_ADCTEST2   0x58
+#define CC2520_MDMTEST0   0x5A
+#define CC2520_MDMTEST1   0x5B
+#define CC2520_DACTEST0   0x5C
+#define CC2520_DACTEST1   0x5D
+#define CC2520_ATEST   0x5E
+#define CC2520_DACTEST2   0x5F
+#define CC2520_PTEST0   0x60
+#define CC2520_PTEST1   0x61
+#define CC2520_RESERVED   0x62
+#define CC2520_DPUBIST   0x7A
+#define CC2520_ACTBIST   0x7C
+#define CC2520_RAMBIST   0x7E
+
+/*frame registers*/
+#define CC2520_FRMFILT0   0x00
+#define CC2520_FRMFILT1   0x01
+#define CC2520_SRCMATCH   0x02
+#define CC2520_SRCSHORTEN0  0x04
+#define CC2520_SRCSHORTEN1  0x05
+#define CC2520_SRCSHORTEN2  0x06
+#define CC2520_SRCEXTEN0  0x08
+#define CC2520_SRCEXTEN1  0x09
+#define CC2520_SRCEXTEN2  0x0A
+#define CC2520_FRMCTRL0   0x0C
+#define CC2520_FRMCTRL1   0x0D
+#define CC2520_RXENABLE0  0x0E
+#define CC2520_RXENABLE1  0x0F
+#define CC2520_EXCFLAG0   0x10
+#define CC2520_EXCFLAG1   0x11
+#define CC2520_EXCFLAG2   0x12
+#define CC2520_EXCMASKA0  0x14
+#define CC2520_EXCMASKA1  0x15
+#define CC2520_EXCMASKA2  0x16
+#define CC2520_EXCMASKB0  0x18
+#define CC2520_EXCMASKB1  0x19
+#define CC2520_EXCMASKB2  0x1A
+#define CC2520_EXCBINDX0  0x1C
+#define CC2520_EXCBINDX1  0x1D
+#define CC2520_EXCBINDY0  0x1E
+#define CC2520_EXCBINDY1  0x1F
+#define CC2520_GPIOCTRL0  0x20
+#define CC2520_GPIOCTRL1  0x21
+#define CC2520_GPIOCTRL2  0x22
+#define CC2520_GPIOCTRL3  0x23
+#define CC2520_GPIOCTRL4  0x24
+#define CC2520_GPIOCTRL5  0x25
+#define CC2520_GPIOPOLARITY  0x26
+#define CC2520_GPIOCTRL   0x28
+#define CC2520_DPUCON   0x2A
+#define CC2520_DPUSTAT   0x2C
+#define CC2520_FREQCTRL   0x2E
+#define CC2520_FREQTUNE   0x2F
+#define CC2520_TXPOWER   0x30
+#define CC2520_TXCTRL   0x31
+#define CC2520_FSMSTAT0   0x32
+#define CC2520_FSMSTAT1   0x33
+#define CC2520_FIFOPCTRL  0x34
+#define CC2520_FSMCTRL   0x35
+#define CC2520_CCACTRL0   0x36
+#define CC2520_CCACTRL1   0x37
+#define CC2520_RSSI   0x38
+#define CC2520_RSSISTAT   0x39
+#define CC2520_RXFIRST   0x3C
+#define CC2520_RXFIFOCNT  0x3E
+#define CC2520_TXFIFOCNT  0x3F
+
+/* Driver private information */
+struct cc2520_private {
+ struct spi_device *spi;  /* spi device structure */
+ struct ieee802154_dev *dev; /* Ieee802.15.4 device */
+ u8 *buf;   /* SPI TX/Rx data buffer */
+ struct mutex buffer_mutex; /* SPI buffer mutex */
+ unsigned is_tx:1;  /* Flag for sync b/w Tx and Rx */
+ int fifo_pin;   /* FIFO GPIO pin number */
+ struct work_struct fifop_irqwork;/* Workqueue for FIFOP */
+ spinlock_t lock;  /* Spin lock */
+ struct completion tx_complete; /* Work completion for Tx */
+};
+
+/* Generic Functions */
+static int
+cc2520_cmd_strobe(struct cc2520_private *priv, u8 cmd)
+{
+ int ret;
+ u8 status = 0xff;
+ struct spi_message msg;
+ struct spi_transfer xfer = {
+  .len = 0,
+  .tx_buf = priv-&#62;buf,
+  .rx_buf = priv-&#62;buf,
+ };
+
+ spi_message_init(&#38;msg);
+ spi_message_add_tail(&#38;xfer, &#38;msg);
+
+ mutex_lock(&#38;priv-&#62;buffer_mutex);
+ priv-&#62;buf[xfer.len++] = cmd;
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev,
+   &#34;command strobe buf[0] = %02x\n&#34;,
+   priv-&#62;buf[0]);
+
+ ret = spi_sync(priv-&#62;spi, &#38;msg);
+ if (!ret)
+  status = priv-&#62;buf[0];
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev,
+   &#34;buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
+ mutex_unlock(&#38;priv-&#62;buffer_mutex);
+
+ return ret;
+}
</pre> 
   </blockquote> 
   <pre>What&#39;s about to drop the lowlevel spi calls and use spi helper functions?

</pre> 
  </blockquote> 
  <div>
   Many of the people are suggesting to use spi_sync() functions instead of spi helper functions.
   <br/> 
  </div> 
  <blockquote type="cite"> 
   <blockquote type="cite"> 
    <pre>+
+static int
+cc2520_get_status(struct cc2520_private *priv, u8 *status)
+{
+ int ret;
+ struct spi_message msg;
+ struct spi_transfer xfer = {
+  .len = 0,
+  .tx_buf = priv-&#62;buf,
+  .rx_buf = priv-&#62;buf,
+ };
+
+ spi_message_init(&#38;msg);
+ spi_message_add_tail(&#38;xfer, &#38;msg);
+
+ mutex_lock(&#38;priv-&#62;buffer_mutex);
+ priv-&#62;buf[xfer.len++] = CC2520_CMD_SNOP;
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev,
+   &#34;get status command buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
+
+ ret = spi_sync(priv-&#62;spi, &#38;msg);
+ if (!ret)
+  *status = priv-&#62;buf[0];
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev,
+   &#34;buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
+ mutex_unlock(&#38;priv-&#62;buffer_mutex);
+
+ return ret;
+}
+
+static int
+cc2520_write_register(struct cc2520_private *priv, u8 reg, u8 value)
+{
+ int status;
+ struct spi_message msg;
+ struct spi_transfer xfer = {
+  .len = 0,
+  .tx_buf = priv-&#62;buf,
+  .rx_buf = priv-&#62;buf,
+ };
+
+ spi_message_init(&#38;msg);
+ spi_message_add_tail(&#38;xfer, &#38;msg);
+
+ mutex_lock(&#38;priv-&#62;buffer_mutex);
+
+ if (reg &#60;= CC2520_FREG_MASK) {
+  priv-&#62;buf[xfer.len++] = CC2520_CMD_REGISTER_WRITE | reg;
+  priv-&#62;buf[xfer.len++] = value;
+ } else {
+  priv-&#62;buf[xfer.len++] = CC2520_CMD_MEMORY_WRITE;
+  priv-&#62;buf[xfer.len++] = reg;
+  priv-&#62;buf[xfer.len++] = value;
+ }
+ status = spi_sync(priv-&#62;spi, &#38;msg);
+ if (msg.status)
+  status = msg.status;
+
+ mutex_unlock(&#38;priv-&#62;buffer_mutex);
+
+ return status;
+}
+
+static int
+cc2520_read_register(struct cc2520_private *priv, u8 reg, u8 *data)
+{
+ int status;
+ struct spi_message msg;
+ struct spi_transfer xfer1 = {
+  .len = 0,
+  .tx_buf = priv-&#62;buf,
+  .rx_buf = priv-&#62;buf,
+ };
+
+ struct spi_transfer xfer2 = {
+  .len = 1,
+  .rx_buf = data,
+ };
+
+ spi_message_init(&#38;msg);
+ spi_message_add_tail(&#38;xfer1, &#38;msg);
+ spi_message_add_tail(&#38;xfer2, &#38;msg);
+
+ mutex_lock(&#38;priv-&#62;buffer_mutex);
+ priv-&#62;buf[xfer1.len++] = CC2520_CMD_MEMORY_READ;
+ priv-&#62;buf[xfer1.len++] = reg;
+
+ status = spi_sync(priv-&#62;spi, &#38;msg);
+ dev_dbg(&#38;priv-&#62;spi-&#62;dev,
+  &#34;spi status = %d\n&#34;, status);
+ if (msg.status)
+  status = msg.status;
+
+ mutex_unlock(&#38;priv-&#62;buffer_mutex);
+
+ return status;
+}
+
+static int
+cc2520_write_txfifo(struct cc2520_private *priv, u8 *data, u8 len)
+{
+ int status;
+
+ /*
+  *length byte must include FCS even
+  *if it is calculated in the hardware
+  */
+ int len_byte = len + 2;
+
+ struct spi_message msg;
+
+ struct spi_transfer xfer_head = {
+  .len = 0,
+  .tx_buf = priv-&#62;buf,
+  .rx_buf = priv-&#62;buf,
+ };
+ struct spi_transfer xfer_len = {
+  .len = 1,
+  .tx_buf = &#38;len_byte,
+ };
+ struct spi_transfer xfer_buf = {
+  .len = len,
+  .tx_buf = data,
+ };
+
+ spi_message_init(&#38;msg);
+ spi_message_add_tail(&#38;xfer_head, &#38;msg);
+ spi_message_add_tail(&#38;xfer_len, &#38;msg);
+ spi_message_add_tail(&#38;xfer_buf, &#38;msg);
+
+ mutex_lock(&#38;priv-&#62;buffer_mutex);
+ priv-&#62;buf[xfer_head.len++] = CC2520_CMD_TXBUF;
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev,
+   &#34;TX_FIFO cmd buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
+
+ status = spi_sync(priv-&#62;spi, &#38;msg);
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;status = %d\n&#34;, status);
+ if (msg.status)
+  status = msg.status;
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;status = %d\n&#34;, status);
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
+ mutex_unlock(&#38;priv-&#62;buffer_mutex);
+
+ return status;
+}
+
+static int
+cc2520_read_rxfifo(struct cc2520_private *priv, u8 *data, u8 *len, u8 *lqi)
</pre> 
   </blockquote> 
   <pre>why is len a pointer here? It&#39;s never changed in this function I would
prefer const u8 len. 
</pre> 
  </blockquote> 
  <div>
   Good catch. Its my mistake. Previously i updated the len pointer and i used in cc2520_rx().
   <br/> Thanx 
  </div> 
  <blockquote type="cite"> 
   <pre>&#160;</pre> 
   <blockquote type="cite"> 
    <pre>+{
+ int status;
+ struct spi_message msg;
+
+ struct spi_transfer xfer_head = {
+  .len = 0,
+  .tx_buf = priv-&#62;buf,
+  .rx_buf = priv-&#62;buf,
+ };
+ struct spi_transfer xfer_buf = {
+  .len = *len,
+  .rx_buf = data,
+ };
+
+ spi_message_init(&#38;msg);
+ spi_message_add_tail(&#38;xfer_head, &#38;msg);
+ spi_message_add_tail(&#38;xfer_buf, &#38;msg);
+
+ mutex_lock(&#38;priv-&#62;buffer_mutex);
+ priv-&#62;buf[xfer_head.len++] = CC2520_CMD_RXBUF;
+
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;read rxfifo buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;buf[1] = %02x\n&#34;, priv-&#62;buf[1]);
+
+ status = spi_sync(priv-&#62;spi, &#38;msg);
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;status = %d\n&#34;, status);
+ if (msg.status)
+  status = msg.status;
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;status = %d\n&#34;, status);
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev,
+   &#34;return status buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;length buf[1] = %02x\n&#34;, priv-&#62;buf[1]);
+
+ *lqi = data[priv-&#62;buf[1] - 1] &#38; 0x7f;
+
+ mutex_unlock(&#38;priv-&#62;buffer_mutex);
+
+ return status;
+}
+
+static int cc2520_start(struct ieee802154_dev *dev)
+{
+ return cc2520_cmd_strobe(dev-&#62;priv, CC2520_CMD_SRXON);
+}
+
+static void cc2520_stop(struct ieee802154_dev *dev)
+{
+ cc2520_cmd_strobe(dev-&#62;priv, CC2520_CMD_SRFOFF);
+}
+
+static int
+cc2520_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
+{
+ struct cc2520_private *priv = dev-&#62;priv;
+ unsigned long flags;
+ int rc;
+ u8 status = 0;
+
+ rc = cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHTX);
+ if (rc)
+  goto err_tx;
+
+ rc = cc2520_write_txfifo(priv, skb-&#62;data, skb-&#62;len);
+ if (rc)
+  goto err_tx;
+
+ rc = cc2520_get_status(priv, &#38;status);
+ if (rc)
+  goto err_tx;
+
+ if (status &#38; CC2520_STATUS_TX_UNDERFLOW) {
+  dev_err(&#38;priv-&#62;spi-&#62;dev, &#34;cc2520 tx underflow exception\n&#34;);
+  goto err_tx;
+ }
+
+ spin_lock_irqsave(&#38;priv-&#62;lock, flags);
+ BUG_ON(priv-&#62;is_tx);
+ priv-&#62;is_tx = 1;
+ spin_unlock_irqrestore(&#38;priv-&#62;lock, flags);
+
+ rc = cc2520_cmd_strobe(priv, CC2520_CMD_STXONCCA);
+ if (rc)
+  goto err;
+
+ rc = wait_for_completion_interruptible(&#38;priv-&#62;tx_complete);
+ if (rc &#60; 0)
+  goto err;
</pre> 
   </blockquote> 
   <pre>mhhh, I never see a reinit_completion and ask myself how the driver can
ever work?

We should also use a wait_for_completion_timeout here, then you need to
handle the error handling with if (!rc).
</pre> 
  </blockquote> 
  <div>
   I initialized the work completion in the cc2520_probe():&#160; 
   <br/> &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160; init_completion(&#38;priv-&#62;tx_complete);
   <br/> 
   <br/> It will wait until the SFD interrupt to raise and get the completion signal from sfd_isr() by:
   <br/> &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160; complete(&#38;priv-&#62;tx_complete)
   <br/> 
   <br/> wait_for_completion_interruptible() API will put the thread in interruptible state.
  </div> 
  <blockquote type="cite"> 
   <pre>&#160;</pre> 
   <blockquote type="cite"> 
    <pre>+
+ cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHTX);
+ cc2520_cmd_strobe(priv, CC2520_CMD_SRXON);
+
+ return rc;
+err:
+ spin_lock_irqsave(&#38;priv-&#62;lock, flags);
+ priv-&#62;is_tx = 0;
+ spin_unlock_irqrestore(&#38;priv-&#62;lock, flags);
+err_tx:
+ return rc;
+}
+
+
+static int cc2520_rx(struct cc2520_private *priv)
+{
+ u8 len = 0, lqi = 0, bytes = 1;
+ struct sk_buff *skb;
+
+ cc2520_read_rxfifo(priv, &#38;len, &#38;bytes, &#38;lqi);
+
+ skb = alloc_skb(len, GFP_KERNEL);
+ if (!skb)
+  return -ENOMEM;
+
+ cc2520_read_rxfifo(priv, skb_put(skb, len), &#38;len, &#38;lqi);
+ if (len &#60; 2) {
+  kfree_skb(skb);
+  return -EINVAL;
+ }
+
+ skb_trim(skb, skb-&#62;len - 2);
+
+ ieee802154_rx_irqsafe(priv-&#62;dev, skb, lqi);
+
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;RXFIFO: %x %x\n&#34;, len, lqi);
+
+ return 0;
+}
+
+static int
+cc2520_ed(struct ieee802154_dev *dev, u8 *level)
+{
+ struct cc2520_private *priv = dev-&#62;priv;
+ u8 status = 0xff;
+ u8 rssi;
+ int ret;
+
+ ret = cc2520_read_register(priv , CC2520_RSSISTAT, &#38;status);
+ if (ret)
+  return ret;
+
+ if (status != RSSI_VALID) {
+  ret = -EINVAL;
+  return ret;
+ }
+
+ ret = cc2520_read_register(priv , CC2520_RSSI, &#38;rssi);
+ if (ret)
+  return ret;
+
+ /* level = RSSI(rssi) - OFFSET [dBm] : offset is 76dBm*/
+ *level = rssi - RSSI_OFFSET;
+
+ return ret;
+}
+
+static int
+cc2520_set_channel(struct ieee802154_dev *dev, int page, int channel)
+{
+ struct cc2520_private *priv = dev-&#62;priv;
+ int ret;
+
+ might_sleep();
+ dev_dbg(&#38;priv-&#62;spi-&#62;dev, &#34;trying to set channel\n&#34;);
+
+ BUG_ON(page != 0);
+ BUG_ON(channel &#60; CC2520_MINCHANNEL);
+ BUG_ON(channel &#62; CC2520_MAXCHANNEL);
+
+ ret = cc2520_write_register(priv, CC2520_FREQCTRL,
+        11 + 5*(channel - 11));
+
+ return ret;
+}
+
+static struct ieee802154_ops cc2520_ops = {
+ .owner = THIS_MODULE,
+ .start = cc2520_start,
+ .stop = cc2520_stop,
+ .xmit = cc2520_tx,
+ .ed = cc2520_ed,
+ .set_channel = cc2520_set_channel,
+};
+
+static int cc2520_register(struct cc2520_private *priv)
+{
+ int ret = -ENOMEM;
+
+ priv-&#62;dev = ieee802154_alloc_device(sizeof(*priv), &#38;cc2520_ops);
+ if (!priv-&#62;dev)
+  goto err_ret;
+
+ priv-&#62;dev-&#62;priv = priv;
+ priv-&#62;dev-&#62;parent = &#38;priv-&#62;spi-&#62;dev;
+ priv-&#62;dev-&#62;extra_tx_headroom = 0;
+
+ /* We do support only 2.4 Ghz */
+ priv-&#62;dev-&#62;phy-&#62;channels_supported[0] = 0x7FFF800;
+ priv-&#62;dev-&#62;flags = IEEE802154_HW_OMIT_CKSUM;
+
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;registered cc2520\n&#34;);
+ ret = ieee802154_register_device(priv-&#62;dev);
+ if (ret)
+  goto err_free_device;
+
+ return 0;
+
+err_free_device:
+ ieee802154_free_device(priv-&#62;dev);
+err_ret:
+ return ret;
+}
+
+static void cc2520_fifop_irqwork(struct work_struct *work)
+{
+ struct cc2520_private *priv
+  = container_of(work, struct cc2520_private, fifop_irqwork);
+
+ dev_dbg(&#38;priv-&#62;spi-&#62;dev, &#34;fifop interrupt received\n&#34;);
+
+ if (gpio_get_value(priv-&#62;fifo_pin))
+  cc2520_rx(priv);
+ else
+  dev_err(&#38;priv-&#62;spi-&#62;dev, &#34;rxfifo overflow\n&#34;);
+
+ cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHRX);
+ cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHRX);
+}
+
+static irqreturn_t cc2520_fifop_isr(int irq, void *data)
+{
+ struct cc2520_private *priv = data;
+
+ schedule_work(&#38;priv-&#62;fifop_irqwork);
+
+ return IRQ_HANDLED;
+}
+
+static irqreturn_t cc2520_sfd_isr(int irq, void *data)
+{
+ struct cc2520_private *priv = data;
+ unsigned long flags;
+
+ spin_lock_irqsave(&#38;priv-&#62;lock, flags);
+ if (priv-&#62;is_tx) {
+  priv-&#62;is_tx = 0;
+  spin_unlock_irqrestore(&#38;priv-&#62;lock, flags);
+  dev_dbg(&#38;priv-&#62;spi-&#62;dev, &#34;SFD for TX\n&#34;);
+  complete(&#38;priv-&#62;tx_complete);
+ } else {
+  spin_unlock_irqrestore(&#38;priv-&#62;lock, flags);
+  dev_dbg(&#38;priv-&#62;spi-&#62;dev, &#34;SFD for RX\n&#34;);
+ }
+
+ return IRQ_HANDLED;
+}
+
+static int cc2520_hw_init(struct cc2520_private *priv)
+{
+ u8 status = 0, state = 0xff;
+ int ret;
+ int timeout = 100;
+
+ ret = cc2520_read_register(priv, CC2520_FSMSTAT1, &#38;state);
+ if (ret)
+  goto err_ret;
+
+ if (state != STATE_IDLE)
+  return -EINVAL;
+
+ do {
+  ret = cc2520_get_status(priv, &#38;status);
+  if (ret)
+   goto err_ret;
+
+  if (timeout-- &#60;= 0) {
+   dev_err(&#38;priv-&#62;spi-&#62;dev, &#34;oscillator start failed!\n&#34;);
+   return ret;
+  }
+  udelay(1);
+ } while (!(status &#38; CC2520_STATUS_XOSC32M_STABLE));
+
+ dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;oscillator successfully brought up\n&#34;);
+
+ /*Registers default value: section 28.1 in Datasheet*/
+ ret = cc2520_write_register(priv, CC2520_TXPOWER, 0xF7);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_CCACTRL0, 0x1A);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_MDMCTRL0, 0x85);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_MDMCTRL1, 0x14);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_RXCTRL, 0x3f);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_FSCTRL, 0x5a);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_FSCAL1, 0x2b);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_AGCCTRL1, 0x11);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_ADCTEST0, 0x10);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_ADCTEST1, 0x0e);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_ADCTEST2, 0x03);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_FRMCTRL0, 0x60);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_FRMCTRL1, 0x03);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_FRMFILT0, 0x00);
+ if (ret)
+  goto err_ret;
+
+ ret = cc2520_write_register(priv, CC2520_FIFOPCTRL, 127);
+ if (ret)
+  goto err_ret;
+
+ return 0;
+
+err_ret:
+ return ret;
+}
+
+static struct cc2520_platform_data *
+cc2520_get_platform_data(struct spi_device *spi)
+{
+ struct cc2520_platform_data *pdata;
+ struct device_node __maybe_unused *np = spi-&#62;dev.of_node;
+ struct cc2520_private *priv = spi_get_drvdata(spi);
+
+ if (!IS_ENABLED(CONFIG_OF) || !np)
+  return spi-&#62;dev.platform_data;
+
+ pdata = devm_kzalloc(&#38;spi-&#62;dev, sizeof(*pdata), GFP_KERNEL);
+ if (!pdata)
+  goto done;
+
+ pdata-&#62;fifo = of_get_named_gpio(np, &#34;fifo-gpio&#34;, 0);
+ priv-&#62;fifo_pin = pdata-&#62;fifo;
+
+ pdata-&#62;fifop = of_get_named_gpio(np, &#34;fifop-gpio&#34;, 0);
+
+ pdata-&#62;sfd = of_get_named_gpio(np, &#34;sfd-gpio&#34;, 0);
+ pdata-&#62;cca = of_get_named_gpio(np, &#34;cca-gpio&#34;, 0);
+ pdata-&#62;vreg = of_get_named_gpio(np, &#34;vreg-gpio&#34;, 0);
+ pdata-&#62;reset = of_get_named_gpio(np, &#34;reset-gpio&#34;, 0);
+
+ spi-&#62;dev.platform_data = pdata;
+
+done:
+ return pdata;
+}
+
+static int cc2520_probe(struct spi_device *spi)
+{
+ struct cc2520_private *priv;
+ struct pinctrl *pinctrl;
+ struct cc2520_platform_data *pdata;
+ struct device_node __maybe_unused *np = spi-&#62;dev.of_node;
+ int ret;
+
+ priv = devm_kzalloc(&#38;spi-&#62;dev,
+       sizeof(struct cc2520_private), GFP_KERNEL);
+ if (!priv) {
+  ret = -ENOMEM;
+  goto err_ret;
+ }
+
+ spi_set_drvdata(spi, priv);
+
+ pinctrl = devm_pinctrl_get_select_default(&#38;spi-&#62;dev);
+ if (IS_ERR(pinctrl))
+  dev_warn(&#38;spi-&#62;dev,
+    &#34;pinctrl pins are not configured from the driver&#34;);
+
+ pdata = cc2520_get_platform_data(spi);
+ if (!pdata) {
+  dev_err(&#38;spi-&#62;dev, &#34;no platform data\n&#34;);
+  return -EINVAL;
+ }
+
+ priv-&#62;spi = spi;
+
+ priv-&#62;buf = devm_kzalloc(&#38;spi-&#62;dev,
+     SPI_COMMAND_BUFFER, GFP_KERNEL);
+ if (!priv-&#62;buf) {
+  ret = -ENOMEM;
+  goto err_ret;
+ }
+
+ mutex_init(&#38;priv-&#62;buffer_mutex);
+ INIT_WORK(&#38;priv-&#62;fifop_irqwork, cc2520_fifop_irqwork);
+ spin_lock_init(&#38;priv-&#62;lock);
+ init_completion(&#38;priv-&#62;tx_complete);
+
+ /* Request all the gpio&#39;s */
+ if (!gpio_is_valid(pdata-&#62;fifo)) {
+  dev_err(&#38;spi-&#62;dev, &#34;fifo gpio is not valid\n&#34;);
+  ret = -EINVAL;
+  goto err_hw_init;
+ } else {
+  ret = devm_gpio_request_one(&#38;spi-&#62;dev, pdata-&#62;fifo,
+         GPIOF_IN, &#34;fifo&#34;);
+  if (ret)
+   goto err_hw_init;
+ }
</pre> 
   </blockquote> 
   <pre>you can drop the else branch here...
</pre> 
  </blockquote> 
  <pre>gpio_is_valid() will only check whether the GPIO PIN number is within the range of GPIO numbers or not.
devm_gpio_request_one() request for the GPIO number. If other driver try to requst for the same number 
GPIO/Pinctrl subsytems through an error saying that &#39;The GPIO number is already used by someone else&#39;
</pre> 
  <div>
   &#160;
  </div> 
  <div>
   &#160;
  </div> 
  <div>
   -Varka Bhadram
  </div>
 
<br />-------------------------------------------------------------------------------------------------------------------------------
<br />[ C-DAC is on Social-Media too. Kindly follow us at: 
<br />Facebook: https://www.facebook.com/CDACINDIA & Twitter: @cdacindia ]
<br />
<br />This e-mail is for the sole use of the intended recipient(s) and may
<br />contain confidential and privileged information. If you are not the
<br />intended recipient, please contact the sender by reply e-mail and destroy
<br />all copies and the original message. Any unauthorized review, use,
<br />disclosure, dissemination, forwarding, printing or copying of this email
<br />is strictly prohibited and appropriate legal action will be taken.
<br />-------------------------------------------------------------------------------------------------------------------------------
</body></html>

------=_Part_7545_1931534041.1402996542714--


--===============2066798181761481918==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
HPCC Systems Open Source Big Data Platform from LexisNexis Risk Solutions
Find What Matters Most in Your Big Data with HPCC Systems
Open Source. Fast. Scalable. Simple. Ideal for Dirty Data.
Leverages Graph Analysis for Fast Processing & Easy Data Exploration
http://p.sf.net/sfu/hpccsystems
--===============2066798181761481918==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-zigbee-devel mailing list
Linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel

--===============2066798181761481918==--
