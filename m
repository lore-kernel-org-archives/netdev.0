From: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
Subject: Re: [PATCH net-next v1 1/3] ieee802154:
 cc2520: adds driver for TI CC2520 radio
Date: Tue, 17 Jun 2014 15:33:00 +0530 (IST)
Message-ID: <650412026.8029.1402999380844.JavaMail.open-xchange@webmail.cdac.in>
References: <1929819035.7546.1402996542810.JavaMail.open-xchange@webmail.cdac.in>
	<20140617095112.GA30654@omega>
Reply-To: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6066977974570866825=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20140617095112.GA30654@omega>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============6066977974570866825==
Content-Type: multipart/alternative;
	boundary="----=_Part_8028_1748636645.1402999380757"


------=_Part_8028_1748636645.1402999380757
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit



On June 17, 2014 at 3:21 PM Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hi,
>
> On Tue, Jun 17, 2014 at 02:45:42PM +0530, Varka Bhadram wrote:
> > On 06/17/2014 02:11 PM, Alexander Aring wrote:
> >
> > >
> > > Hi Varka,
> ...
> > > > +
> > > > +/* Generic Functions */
> > > > +static int
> > > > +cc2520_cmd_strobe(struct cc2520_private *priv, u8 cmd)
> > > > +{
> > > > + int ret;
> > > > + u8 status = 0xff;
> > > > + struct spi_message msg;
> > > > + struct spi_transfer xfer = {
> > > > + .len = 0,
> > > > + .tx_buf = priv->buf,
> > > > + .rx_buf = priv->buf,
> > > > + };
> > > > +
> > > > + spi_message_init(&msg);
> > > > + spi_message_add_tail(&xfer, &msg);
> > > > +
> > > > + mutex_lock(&priv->buffer_mutex);
> > > > + priv->buf[xfer.len++] = cmd;
> > > > + dev_vdbg(&priv->spi->dev,
> > > > + "command strobe buf[0] = %02x\n",
> > > > + priv->buf[0]);
> > > > +
> > > > + ret = spi_sync(priv->spi, &msg);
> > > > + if (!ret)
> > > > + status = priv->buf[0];
> > > > + dev_vdbg(&priv->spi->dev,
> > > > + "buf[0] = %02x\n", priv->buf[0]);
> > > > + mutex_unlock(&priv->buffer_mutex);
> > > > +
> > > > + return ret;
> > > > +}
> > > >
> > > > >
> > > What's about to drop the lowlevel spi calls and use spi helper functions?
> > >
> > >
> > Many of the people are suggesting to use spi_sync() functions instead of spi
> > helper functions.
> >
>
> The spi helper function do the same what do you there in several
> functions in this driver. Look in 'drivers/spi/spi.c'. This would
> decrease much the code count.
>
> > >
> > > > >
> > > > +
> > > > +static int
> > > > +cc2520_get_status(struct cc2520_private *priv, u8 *status)
> > > > +{
> > > > + int ret;
> > > > + struct spi_message msg;
> > > > + struct spi_transfer xfer = {
> > > > + .len = 0,
> > > > + .tx_buf = priv->buf,
> > > > + .rx_buf = priv->buf,
> > > > + };
> > > > +
> > > > + spi_message_init(&msg);
> > > > + spi_message_add_tail(&xfer, &msg);
> > > > +
> > > > + mutex_lock(&priv->buffer_mutex);
> > > > + priv->buf[xfer.len++] = CC2520_CMD_SNOP;
> > > > + dev_vdbg(&priv->spi->dev,
> > > > + "get status command buf[0] = %02x\n", priv->buf[0]);
> > > > +
> > > > + ret = spi_sync(priv->spi, &msg);
> > > > + if (!ret)
> > > > + *status = priv->buf[0];
> > > > + dev_vdbg(&priv->spi->dev,
> > > > + "buf[0] = %02x\n", priv->buf[0]);
> > > > + mutex_unlock(&priv->buffer_mutex);
> > > > +
> > > > + return ret;
> > > > +}
> > > > +
> > > > +static int
> > > > +cc2520_write_register(struct cc2520_private *priv, u8 reg, u8
> > > > value)
> > > > +{
> > > > + int status;
> > > > + struct spi_message msg;
> > > > + struct spi_transfer xfer = {
> > > > + .len = 0,
> > > > + .tx_buf = priv->buf,
> > > > + .rx_buf = priv->buf,
> > > > + };
> > > > +
> > > > + spi_message_init(&msg);
> > > > + spi_message_add_tail(&xfer, &msg);
> > > > +
> > > > + mutex_lock(&priv->buffer_mutex);
> > > > +
> > > > + if (reg <= CC2520_FREG_MASK) {
> > > > + priv->buf[xfer.len++] = CC2520_CMD_REGISTER_WRITE | reg;
> > > > + priv->buf[xfer.len++] = value;
> > > > + } else {
> > > > + priv->buf[xfer.len++] = CC2520_CMD_MEMORY_WRITE;
> > > > + priv->buf[xfer.len++] = reg;
> > > > + priv->buf[xfer.len++] = value;
> > > > + }
> > > > + status = spi_sync(priv->spi, &msg);
> > > > + if (msg.status)
> > > > + status = msg.status;
> > > > +
> > > > + mutex_unlock(&priv->buffer_mutex);
> > > > +
> > > > + return status;
> > > > +}
> > > > +
> > > > +static int
> > > > +cc2520_read_register(struct cc2520_private *priv, u8 reg, u8 *data)
> > > > +{
> > > > + int status;
> > > > + struct spi_message msg;
> > > > + struct spi_transfer xfer1 = {
> > > > + .len = 0,
> > > > + .tx_buf = priv->buf,
> > > > + .rx_buf = priv->buf,
> > > > + };
> > > > +
> > > > + struct spi_transfer xfer2 = {
> > > > + .len = 1,
> > > > + .rx_buf = data,
> > > > + };
> > > > +
> > > > + spi_message_init(&msg);
> > > > + spi_message_add_tail(&xfer1, &msg);
> > > > + spi_message_add_tail(&xfer2, &msg);
> > > > +
> > > > + mutex_lock(&priv->buffer_mutex);
> > > > + priv->buf[xfer1.len++] = CC2520_CMD_MEMORY_READ;
> > > > + priv->buf[xfer1.len++] = reg;
> > > > +
> > > > + status = spi_sync(priv->spi, &msg);
> > > > + dev_dbg(&priv->spi->dev,
> > > > + "spi status = %d\n", status);
> > > > + if (msg.status)
> > > > + status = msg.status;
> > > > +
> > > > + mutex_unlock(&priv->buffer_mutex);
> > > > +
> > > > + return status;
> > > > +}
> > > > +
> > > > +static int
> > > > +cc2520_write_txfifo(struct cc2520_private *priv, u8 *data, u8 len)
> > > > +{
> > > > + int status;
> > > > +
> > > > + /*
> > > > + *length byte must include FCS even
> > > > + *if it is calculated in the hardware
> > > > + */
> > > > + int len_byte = len + 2;
> > > > +
> > > > + struct spi_message msg;
> > > > +
> > > > + struct spi_transfer xfer_head = {
> > > > + .len = 0,
> > > > + .tx_buf = priv->buf,
> > > > + .rx_buf = priv->buf,
> > > > + };
> > > > + struct spi_transfer xfer_len = {
> > > > + .len = 1,
> > > > + .tx_buf = &len_byte,
> > > > + };
> > > > + struct spi_transfer xfer_buf = {
> > > > + .len = len,
> > > > + .tx_buf = data,
> > > > + };
> > > > +
> > > > + spi_message_init(&msg);
> > > > + spi_message_add_tail(&xfer_head, &msg);
> > > > + spi_message_add_tail(&xfer_len, &msg);
> > > > + spi_message_add_tail(&xfer_buf, &msg);
> > > > +
> > > > + mutex_lock(&priv->buffer_mutex);
> > > > + priv->buf[xfer_head.len++] = CC2520_CMD_TXBUF;
> > > > + dev_vdbg(&priv->spi->dev,
> > > > + "TX_FIFO cmd buf[0] = %02x\n", priv->buf[0]);
> > > > +
> > > > + status = spi_sync(priv->spi, &msg);
> > > > + dev_vdbg(&priv->spi->dev, "status = %d\n", status);
> > > > + if (msg.status)
> > > > + status = msg.status;
> > > > + dev_vdbg(&priv->spi->dev, "status = %d\n", status);
> > > > + dev_vdbg(&priv->spi->dev, "buf[0] = %02x\n", priv->buf[0]);
> > > > + mutex_unlock(&priv->buffer_mutex);
> > > > +
> > > > + return status;
> > > > +}
> > > > +
> > > > +static int
> > > > +cc2520_read_rxfifo(struct cc2520_private *priv, u8 *data, u8 *len,
> > > > u8 *lqi)
> > > >
> > > > >
> > > why is len a pointer here? It's never changed in this function I would
> > > prefer const u8 len.
> > >
> > Good catch. Its my mistake. Previously i updated the len pointer and i used
> > in
> > cc2520_rx().
> > Thanx
> >
> > >
> > >
> > >
> > > > >
> > > > +{
> > > > + int status;
> > > > + struct spi_message msg;
> > > > +
> > > > + struct spi_transfer xfer_head = {
> > > > + .len = 0,
> > > > + .tx_buf = priv->buf,
> > > > + .rx_buf = priv->buf,
> > > > + };
> > > > + struct spi_transfer xfer_buf = {
> > > > + .len = *len,
> > > > + .rx_buf = data,
> > > > + };
> > > > +
> > > > + spi_message_init(&msg);
> > > > + spi_message_add_tail(&xfer_head, &msg);
> > > > + spi_message_add_tail(&xfer_buf, &msg);
> > > > +
> > > > + mutex_lock(&priv->buffer_mutex);
> > > > + priv->buf[xfer_head.len++] = CC2520_CMD_RXBUF;
> > > > +
> > > > + dev_vdbg(&priv->spi->dev, "read rxfifo buf[0] = %02x\n",
> > > > priv->buf[0]);
> > > > + dev_vdbg(&priv->spi->dev, "buf[1] = %02x\n", priv->buf[1]);
> > > > +
> > > > + status = spi_sync(priv->spi, &msg);
> > > > + dev_vdbg(&priv->spi->dev, "status = %d\n", status);
> > > > + if (msg.status)
> > > > + status = msg.status;
> > > > + dev_vdbg(&priv->spi->dev, "status = %d\n", status);
> > > > + dev_vdbg(&priv->spi->dev,
> > > > + "return status buf[0] = %02x\n", priv->buf[0]);
> > > > + dev_vdbg(&priv->spi->dev, "length buf[1] = %02x\n", priv->buf[1]);
> > > > +
> > > > + *lqi = data[priv->buf[1] - 1] & 0x7f;
> > > > +
> > > > + mutex_unlock(&priv->buffer_mutex);
> > > > +
> > > > + return status;
> > > > +}
> > > > +
> > > > +static int cc2520_start(struct ieee802154_dev *dev)
> > > > +{
> > > > + return cc2520_cmd_strobe(dev->priv, CC2520_CMD_SRXON);
> > > > +}
> > > > +
> > > > +static void cc2520_stop(struct ieee802154_dev *dev)
> > > > +{
> > > > + cc2520_cmd_strobe(dev->priv, CC2520_CMD_SRFOFF);
> > > > +}
> > > > +
> > > > +static int
> > > > +cc2520_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
> > > > +{
> > > > + struct cc2520_private *priv = dev->priv;
> > > > + unsigned long flags;
> > > > + int rc;
> > > > + u8 status = 0;
> > > > +
> > > > + rc = cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHTX);
> > > > + if (rc)
> > > > + goto err_tx;
> > > > +
> > > > + rc = cc2520_write_txfifo(priv, skb->data, skb->len);
> > > > + if (rc)
> > > > + goto err_tx;
> > > > +
> > > > + rc = cc2520_get_status(priv, &status);
> > > > + if (rc)
> > > > + goto err_tx;
> > > > +
> > > > + if (status & CC2520_STATUS_TX_UNDERFLOW) {
> > > > + dev_err(&priv->spi->dev, "cc2520 tx underflow exception\n");
> > > > + goto err_tx;
> > > > + }
> > > > +
> > > > + spin_lock_irqsave(&priv->lock, flags);
> > > > + BUG_ON(priv->is_tx);
> > > > + priv->is_tx = 1;
> > > > + spin_unlock_irqrestore(&priv->lock, flags);
> > > > +
> > > > + rc = cc2520_cmd_strobe(priv, CC2520_CMD_STXONCCA);
> > > > + if (rc)
> > > > + goto err;
> > > > +
> > > > + rc = wait_for_completion_interruptible(&priv->tx_complete);
> > > > + if (rc < 0)
> > > > + goto err;
> > > >
> > > > >
> > > mhhh, I never see a reinit_completion and ask myself how the driver can
> > > ever work?
> > >
> > > We should also use a wait_for_completion_timeout here, then you need to
> > > handle the error handling with if (!rc).
> > >
> > I initialized the work completion in the cc2520_probe():
> > init_completion(&priv->tx_complete);
> >
>
> Ah, we only need a reinit_completion after a complete_all. Ok, sorry :-)
>
> > It will wait until the SFD interrupt to raise and get the completion signal
> > from
> > sfd_isr() by:
> > complete(&priv->tx_complete)
> >
> > wait_for_completion_interruptible() API will put the thread in interruptible
> > state.
> >
>
> Yes, you are right but there is also a
> wait_for_completion_interruptible_timeout. I mean for the case if you
> waiting forever and no irq hits.
>
In this case SFD irq should come while Tx and Rx.

After completion of the Frame Tx the cc2520 will make the SFD signal is low.

please see: 20.3.1 & 20.4.1 sections in
http://www.ti.com/lit/ds/symlink/cc2520.pdf
<http://www.ti.com/lit/ds/symlink/cc2520.pdf>


> > >
> > >
> > >
> ...
> > > > +
> > > > + mutex_init(&priv->buffer_mutex);
> > > > + INIT_WORK(&priv->fifop_irqwork, cc2520_fifop_irqwork);
> > > > + spin_lock_init(&priv->lock);
> > > > + init_completion(&priv->tx_complete);
> > > > +
> > > > + /* Request all the gpio's */
> > > > + if (!gpio_is_valid(pdata->fifo)) {
> > > > + dev_err(&spi->dev, "fifo gpio is not valid\n");
> > > > + ret = -EINVAL;
> > > > + goto err_hw_init;
> > > > + } else {
> > > > + ret = devm_gpio_request_one(&spi->dev, pdata->fifo,
> > > > + GPIOF_IN, "fifo");
> > > > + if (ret)
> > > > + goto err_hw_init;
> > > > + }
> > > >
> > > > >
> > > you can drop the else branch here...
> > >
> >
> > gpio_is_valid() will only check whether the GPIO PIN number is within the
> > range
> > of GPIO numbers or not.
> > devm_gpio_request_one() request for the GPIO number. If other driver try to
> > requst for the same number
> > GPIO/Pinctrl subsytems through an error saying that 'The GPIO number is
> > already
> > used by someone else'
> >
> >
>
> I meant something like this:
>
> if (!gpio_is_valid(pdata->fifo)) {
> dev_err(&spi->dev, "fifo gpio is not valid\n");
> ret = -EINVAL;
> goto err_hw_init;
> }
>
> ret = devm_gpio_request_one(&spi->dev, pdata->fifo,
> GPIOF_IN, "fifo");
> if (ret)
> goto err_hw_init;

I didn't find any difference but it looks good.

>
> ...
>
> - Alex
>

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


------=_Part_8028_1748636645.1402999380757
MIME-Version: 1.0
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
 </head><body style="">
 
 
  <div>
   &#160;
  </div> 
  <div>
   <br/>On June 17, 2014 at 3:21 PM Alexander Aring &#60;alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org&#62; wrote:
   <br/>&#62; Hi,
   <br/>&#62; 
   <br/>&#62; On Tue, Jun 17, 2014 at 02:45:42PM +0530, Varka Bhadram wrote:
   <br/>&#62; &#62; On 06/17/2014 02:11 PM, Alexander Aring wrote:
   <br/>&#62; &#62; 
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; Hi Varka,
   <br/>&#62; ...
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; +/* Generic Functions */
   <br/>&#62; &#62; &#62; &#62; +static int
   <br/>&#62; &#62; &#62; &#62; +cc2520_cmd_strobe(struct cc2520_private *priv, u8 cmd)
   <br/>&#62; &#62; &#62; &#62; +{
   <br/>&#62; &#62; &#62; &#62; + int ret;
   <br/>&#62; &#62; &#62; &#62; + u8 status = 0xff;
   <br/>&#62; &#62; &#62; &#62; + struct spi_message msg;
   <br/>&#62; &#62; &#62; &#62; + struct spi_transfer xfer = {
   <br/>&#62; &#62; &#62; &#62; + .len = 0,
   <br/>&#62; &#62; &#62; &#62; + .tx_buf = priv-&#62;buf,
   <br/>&#62; &#62; &#62; &#62; + .rx_buf = priv-&#62;buf,
   <br/>&#62; &#62; &#62; &#62; + };
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + spi_message_init(&#38;msg);
   <br/>&#62; &#62; &#62; &#62; + spi_message_add_tail(&#38;xfer, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + mutex_lock(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;buf[xfer.len++] = cmd;
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev,
   <br/>&#62; &#62; &#62; &#62; + &#34;command strobe buf[0] = %02x\n&#34;,
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;buf[0]);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + ret = spi_sync(priv-&#62;spi, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; + if (!ret)
   <br/>&#62; &#62; &#62; &#62; + status = priv-&#62;buf[0];
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev,
   <br/>&#62; &#62; &#62; &#62; + &#34;buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
   <br/>&#62; &#62; &#62; &#62; + mutex_unlock(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + return ret;
   <br/>&#62; &#62; &#62; &#62; +}
   <br/>&#62; &#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; What&#39;s about to drop the lowlevel spi calls and use spi helper functions?
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; Many of the people are suggesting to use spi_sync() functions instead of spi
   <br/>&#62; &#62; helper functions.
   <br/>&#62; &#62; 
   <br/>&#62; 
   <br/>&#62; The spi helper function do the same what do you there in several
   <br/>&#62; functions in this driver. Look in &#39;drivers/spi/spi.c&#39;. This would
   <br/>&#62; decrease much the code count.
   <br/>&#62; 
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; +static int
   <br/>&#62; &#62; &#62; &#62; +cc2520_get_status(struct cc2520_private *priv, u8 *status)
   <br/>&#62; &#62; &#62; &#62; +{
   <br/>&#62; &#62; &#62; &#62; + int ret;
   <br/>&#62; &#62; &#62; &#62; + struct spi_message msg;
   <br/>&#62; &#62; &#62; &#62; + struct spi_transfer xfer = {
   <br/>&#62; &#62; &#62; &#62; + .len = 0,
   <br/>&#62; &#62; &#62; &#62; + .tx_buf = priv-&#62;buf,
   <br/>&#62; &#62; &#62; &#62; + .rx_buf = priv-&#62;buf,
   <br/>&#62; &#62; &#62; &#62; + };
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + spi_message_init(&#38;msg);
   <br/>&#62; &#62; &#62; &#62; + spi_message_add_tail(&#38;xfer, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + mutex_lock(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;buf[xfer.len++] = CC2520_CMD_SNOP;
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev,
   <br/>&#62; &#62; &#62; &#62; + &#34;get status command buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + ret = spi_sync(priv-&#62;spi, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; + if (!ret)
   <br/>&#62; &#62; &#62; &#62; + *status = priv-&#62;buf[0];
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev,
   <br/>&#62; &#62; &#62; &#62; + &#34;buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
   <br/>&#62; &#62; &#62; &#62; + mutex_unlock(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + return ret;
   <br/>&#62; &#62; &#62; &#62; +}
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; +static int
   <br/>&#62; &#62; &#62; &#62; +cc2520_write_register(struct cc2520_private *priv, u8 reg, u8
   <br/>&#62; &#62; &#62; &#62; value)
   <br/>&#62; &#62; &#62; &#62; +{
   <br/>&#62; &#62; &#62; &#62; + int status;
   <br/>&#62; &#62; &#62; &#62; + struct spi_message msg;
   <br/>&#62; &#62; &#62; &#62; + struct spi_transfer xfer = {
   <br/>&#62; &#62; &#62; &#62; + .len = 0,
   <br/>&#62; &#62; &#62; &#62; + .tx_buf = priv-&#62;buf,
   <br/>&#62; &#62; &#62; &#62; + .rx_buf = priv-&#62;buf,
   <br/>&#62; &#62; &#62; &#62; + };
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + spi_message_init(&#38;msg);
   <br/>&#62; &#62; &#62; &#62; + spi_message_add_tail(&#38;xfer, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + mutex_lock(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + if (reg &#60;= CC2520_FREG_MASK) {
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;buf[xfer.len++] = CC2520_CMD_REGISTER_WRITE | reg;
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;buf[xfer.len++] = value;
   <br/>&#62; &#62; &#62; &#62; + } else {
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;buf[xfer.len++] = CC2520_CMD_MEMORY_WRITE;
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;buf[xfer.len++] = reg;
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;buf[xfer.len++] = value;
   <br/>&#62; &#62; &#62; &#62; + }
   <br/>&#62; &#62; &#62; &#62; + status = spi_sync(priv-&#62;spi, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; + if (msg.status)
   <br/>&#62; &#62; &#62; &#62; + status = msg.status;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + mutex_unlock(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + return status;
   <br/>&#62; &#62; &#62; &#62; +}
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; +static int
   <br/>&#62; &#62; &#62; &#62; +cc2520_read_register(struct cc2520_private *priv, u8 reg, u8 *data)
   <br/>&#62; &#62; &#62; &#62; +{
   <br/>&#62; &#62; &#62; &#62; + int status;
   <br/>&#62; &#62; &#62; &#62; + struct spi_message msg;
   <br/>&#62; &#62; &#62; &#62; + struct spi_transfer xfer1 = {
   <br/>&#62; &#62; &#62; &#62; + .len = 0,
   <br/>&#62; &#62; &#62; &#62; + .tx_buf = priv-&#62;buf,
   <br/>&#62; &#62; &#62; &#62; + .rx_buf = priv-&#62;buf,
   <br/>&#62; &#62; &#62; &#62; + };
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + struct spi_transfer xfer2 = {
   <br/>&#62; &#62; &#62; &#62; + .len = 1,
   <br/>&#62; &#62; &#62; &#62; + .rx_buf = data,
   <br/>&#62; &#62; &#62; &#62; + };
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + spi_message_init(&#38;msg);
   <br/>&#62; &#62; &#62; &#62; + spi_message_add_tail(&#38;xfer1, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; + spi_message_add_tail(&#38;xfer2, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + mutex_lock(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;buf[xfer1.len++] = CC2520_CMD_MEMORY_READ;
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;buf[xfer1.len++] = reg;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + status = spi_sync(priv-&#62;spi, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; + dev_dbg(&#38;priv-&#62;spi-&#62;dev,
   <br/>&#62; &#62; &#62; &#62; + &#34;spi status = %d\n&#34;, status);
   <br/>&#62; &#62; &#62; &#62; + if (msg.status)
   <br/>&#62; &#62; &#62; &#62; + status = msg.status;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + mutex_unlock(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + return status;
   <br/>&#62; &#62; &#62; &#62; +}
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; +static int
   <br/>&#62; &#62; &#62; &#62; +cc2520_write_txfifo(struct cc2520_private *priv, u8 *data, u8 len)
   <br/>&#62; &#62; &#62; &#62; +{
   <br/>&#62; &#62; &#62; &#62; + int status;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + /*
   <br/>&#62; &#62; &#62; &#62; + *length byte must include FCS even
   <br/>&#62; &#62; &#62; &#62; + *if it is calculated in the hardware
   <br/>&#62; &#62; &#62; &#62; + */
   <br/>&#62; &#62; &#62; &#62; + int len_byte = len + 2;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + struct spi_message msg;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + struct spi_transfer xfer_head = {
   <br/>&#62; &#62; &#62; &#62; + .len = 0,
   <br/>&#62; &#62; &#62; &#62; + .tx_buf = priv-&#62;buf,
   <br/>&#62; &#62; &#62; &#62; + .rx_buf = priv-&#62;buf,
   <br/>&#62; &#62; &#62; &#62; + };
   <br/>&#62; &#62; &#62; &#62; + struct spi_transfer xfer_len = {
   <br/>&#62; &#62; &#62; &#62; + .len = 1,
   <br/>&#62; &#62; &#62; &#62; + .tx_buf = &#38;len_byte,
   <br/>&#62; &#62; &#62; &#62; + };
   <br/>&#62; &#62; &#62; &#62; + struct spi_transfer xfer_buf = {
   <br/>&#62; &#62; &#62; &#62; + .len = len,
   <br/>&#62; &#62; &#62; &#62; + .tx_buf = data,
   <br/>&#62; &#62; &#62; &#62; + };
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + spi_message_init(&#38;msg);
   <br/>&#62; &#62; &#62; &#62; + spi_message_add_tail(&#38;xfer_head, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; + spi_message_add_tail(&#38;xfer_len, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; + spi_message_add_tail(&#38;xfer_buf, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + mutex_lock(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;buf[xfer_head.len++] = CC2520_CMD_TXBUF;
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev,
   <br/>&#62; &#62; &#62; &#62; + &#34;TX_FIFO cmd buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + status = spi_sync(priv-&#62;spi, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;status = %d\n&#34;, status);
   <br/>&#62; &#62; &#62; &#62; + if (msg.status)
   <br/>&#62; &#62; &#62; &#62; + status = msg.status;
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;status = %d\n&#34;, status);
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
   <br/>&#62; &#62; &#62; &#62; + mutex_unlock(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + return status;
   <br/>&#62; &#62; &#62; &#62; +}
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; +static int
   <br/>&#62; &#62; &#62; &#62; +cc2520_read_rxfifo(struct cc2520_private *priv, u8 *data, u8 *len,
   <br/>&#62; &#62; &#62; &#62; u8 *lqi)
   <br/>&#62; &#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; why is len a pointer here? It&#39;s never changed in this function I would
   <br/>&#62; &#62; &#62; prefer const u8 len.
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; Good catch. Its my mistake. Previously i updated the len pointer and i used in
   <br/>&#62; &#62; cc2520_rx().
   <br/>&#62; &#62; Thanx
   <br/>&#62; &#62; 
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; &#62; +{
   <br/>&#62; &#62; &#62; &#62; + int status;
   <br/>&#62; &#62; &#62; &#62; + struct spi_message msg;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + struct spi_transfer xfer_head = {
   <br/>&#62; &#62; &#62; &#62; + .len = 0,
   <br/>&#62; &#62; &#62; &#62; + .tx_buf = priv-&#62;buf,
   <br/>&#62; &#62; &#62; &#62; + .rx_buf = priv-&#62;buf,
   <br/>&#62; &#62; &#62; &#62; + };
   <br/>&#62; &#62; &#62; &#62; + struct spi_transfer xfer_buf = {
   <br/>&#62; &#62; &#62; &#62; + .len = *len,
   <br/>&#62; &#62; &#62; &#62; + .rx_buf = data,
   <br/>&#62; &#62; &#62; &#62; + };
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + spi_message_init(&#38;msg);
   <br/>&#62; &#62; &#62; &#62; + spi_message_add_tail(&#38;xfer_head, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; + spi_message_add_tail(&#38;xfer_buf, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + mutex_lock(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;buf[xfer_head.len++] = CC2520_CMD_RXBUF;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;read rxfifo buf[0] = %02x\n&#34;,
   <br/>&#62; &#62; &#62; &#62; priv-&#62;buf[0]);
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;buf[1] = %02x\n&#34;, priv-&#62;buf[1]);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + status = spi_sync(priv-&#62;spi, &#38;msg);
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;status = %d\n&#34;, status);
   <br/>&#62; &#62; &#62; &#62; + if (msg.status)
   <br/>&#62; &#62; &#62; &#62; + status = msg.status;
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;status = %d\n&#34;, status);
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev,
   <br/>&#62; &#62; &#62; &#62; + &#34;return status buf[0] = %02x\n&#34;, priv-&#62;buf[0]);
   <br/>&#62; &#62; &#62; &#62; + dev_vdbg(&#38;priv-&#62;spi-&#62;dev, &#34;length buf[1] = %02x\n&#34;, priv-&#62;buf[1]);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + *lqi = data[priv-&#62;buf[1] - 1] &#38; 0x7f;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + mutex_unlock(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + return status;
   <br/>&#62; &#62; &#62; &#62; +}
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; +static int cc2520_start(struct ieee802154_dev *dev)
   <br/>&#62; &#62; &#62; &#62; +{
   <br/>&#62; &#62; &#62; &#62; + return cc2520_cmd_strobe(dev-&#62;priv, CC2520_CMD_SRXON);
   <br/>&#62; &#62; &#62; &#62; +}
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; +static void cc2520_stop(struct ieee802154_dev *dev)
   <br/>&#62; &#62; &#62; &#62; +{
   <br/>&#62; &#62; &#62; &#62; + cc2520_cmd_strobe(dev-&#62;priv, CC2520_CMD_SRFOFF);
   <br/>&#62; &#62; &#62; &#62; +}
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; +static int
   <br/>&#62; &#62; &#62; &#62; +cc2520_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
   <br/>&#62; &#62; &#62; &#62; +{
   <br/>&#62; &#62; &#62; &#62; + struct cc2520_private *priv = dev-&#62;priv;
   <br/>&#62; &#62; &#62; &#62; + unsigned long flags;
   <br/>&#62; &#62; &#62; &#62; + int rc;
   <br/>&#62; &#62; &#62; &#62; + u8 status = 0;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + rc = cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHTX);
   <br/>&#62; &#62; &#62; &#62; + if (rc)
   <br/>&#62; &#62; &#62; &#62; + goto err_tx;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + rc = cc2520_write_txfifo(priv, skb-&#62;data, skb-&#62;len);
   <br/>&#62; &#62; &#62; &#62; + if (rc)
   <br/>&#62; &#62; &#62; &#62; + goto err_tx;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + rc = cc2520_get_status(priv, &#38;status);
   <br/>&#62; &#62; &#62; &#62; + if (rc)
   <br/>&#62; &#62; &#62; &#62; + goto err_tx;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + if (status &#38; CC2520_STATUS_TX_UNDERFLOW) {
   <br/>&#62; &#62; &#62; &#62; + dev_err(&#38;priv-&#62;spi-&#62;dev, &#34;cc2520 tx underflow exception\n&#34;);
   <br/>&#62; &#62; &#62; &#62; + goto err_tx;
   <br/>&#62; &#62; &#62; &#62; + }
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + spin_lock_irqsave(&#38;priv-&#62;lock, flags);
   <br/>&#62; &#62; &#62; &#62; + BUG_ON(priv-&#62;is_tx);
   <br/>&#62; &#62; &#62; &#62; + priv-&#62;is_tx = 1;
   <br/>&#62; &#62; &#62; &#62; + spin_unlock_irqrestore(&#38;priv-&#62;lock, flags);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + rc = cc2520_cmd_strobe(priv, CC2520_CMD_STXONCCA);
   <br/>&#62; &#62; &#62; &#62; + if (rc)
   <br/>&#62; &#62; &#62; &#62; + goto err;
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + rc = wait_for_completion_interruptible(&#38;priv-&#62;tx_complete);
   <br/>&#62; &#62; &#62; &#62; + if (rc &#60; 0)
   <br/>&#62; &#62; &#62; &#62; + goto err;
   <br/>&#62; &#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; mhhh, I never see a reinit_completion and ask myself how the driver can
   <br/>&#62; &#62; &#62; ever work?
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; We should also use a wait_for_completion_timeout here, then you need to
   <br/>&#62; &#62; &#62; handle the error handling with if (!rc).
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; I initialized the work completion in the cc2520_probe():
   <br/>&#62; &#62; init_completion(&#38;priv-&#62;tx_complete);
   <br/>&#62; &#62; 
   <br/>&#62; 
   <br/>&#62; Ah, we only need a reinit_completion after a complete_all. Ok, sorry :-)
   <br/>&#62; 
   <br/>&#62; &#62; It will wait until the SFD interrupt to raise and get the completion signal from
   <br/>&#62; &#62; sfd_isr() by:
   <br/>&#62; &#62; complete(&#38;priv-&#62;tx_complete)
   <br/>&#62; &#62; 
   <br/>&#62; &#62; wait_for_completion_interruptible() API will put the thread in interruptible
   <br/>&#62; &#62; state.
   <br/>&#62; &#62; 
   <br/>&#62; 
   <br/>&#62; Yes, you are right but there is also a
   <br/>&#62; wait_for_completion_interruptible_timeout. I mean for the case if you
   <br/>&#62; waiting forever and no irq hits.
   <br/>&#62;
  </div> 
  <div>
   In this case SFD irq should come while Tx and Rx.
  </div> 
  <div>
   &#160;
  </div> 
  <div>
   After completion of the Frame Tx the cc2520 will make the SFD signal is low.
  </div> 
  <div>
   &#160;
  </div> 
  <div>
   please see: 20.3.1 &#38; 20.4.1 sections in 
   <a href="http://www.ti.com/lit/ds/symlink/cc2520.pdf">http://www.ti.com/lit/ds/symlink/cc2520.pdf</a>
  </div> 
  <div>
   &#160;
  </div> 
  <div>
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; 
   <br/>&#62; ...
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + mutex_init(&#38;priv-&#62;buffer_mutex);
   <br/>&#62; &#62; &#62; &#62; + INIT_WORK(&#38;priv-&#62;fifop_irqwork, cc2520_fifop_irqwork);
   <br/>&#62; &#62; &#62; &#62; + spin_lock_init(&#38;priv-&#62;lock);
   <br/>&#62; &#62; &#62; &#62; + init_completion(&#38;priv-&#62;tx_complete);
   <br/>&#62; &#62; &#62; &#62; +
   <br/>&#62; &#62; &#62; &#62; + /* Request all the gpio&#39;s */
   <br/>&#62; &#62; &#62; &#62; + if (!gpio_is_valid(pdata-&#62;fifo)) {
   <br/>&#62; &#62; &#62; &#62; + dev_err(&#38;spi-&#62;dev, &#34;fifo gpio is not valid\n&#34;);
   <br/>&#62; &#62; &#62; &#62; + ret = -EINVAL;
   <br/>&#62; &#62; &#62; &#62; + goto err_hw_init;
   <br/>&#62; &#62; &#62; &#62; + } else {
   <br/>&#62; &#62; &#62; &#62; + ret = devm_gpio_request_one(&#38;spi-&#62;dev, pdata-&#62;fifo,
   <br/>&#62; &#62; &#62; &#62; + GPIOF_IN, &#34;fifo&#34;);
   <br/>&#62; &#62; &#62; &#62; + if (ret)
   <br/>&#62; &#62; &#62; &#62; + goto err_hw_init;
   <br/>&#62; &#62; &#62; &#62; + }
   <br/>&#62; &#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; &#62; &#62; 
   <br/>&#62; &#62; &#62; you can drop the else branch here...
   <br/>&#62; &#62; &#62; 
   <br/>&#62; &#62; 
   <br/>&#62; &#62; gpio_is_valid() will only check whether the GPIO PIN number is within the range
   <br/>&#62; &#62; of GPIO numbers or not.
   <br/>&#62; &#62; devm_gpio_request_one() request for the GPIO number. If other driver try to
   <br/>&#62; &#62; requst for the same number
   <br/>&#62; &#62; GPIO/Pinctrl subsytems through an error saying that &#39;The GPIO number is already
   <br/>&#62; &#62; used by someone else&#39;
   <br/>&#62; &#62; 
   <br/>&#62; &#62; 
   <br/>&#62; 
   <br/>&#62; I meant something like this:
   <br/>&#62; 
   <br/>&#62; if (!gpio_is_valid(pdata-&#62;fifo)) {
   <br/>&#62; dev_err(&#38;spi-&#62;dev, &#34;fifo gpio is not valid\n&#34;);
   <br/>&#62; ret = -EINVAL;
   <br/>&#62; goto err_hw_init;
   <br/>&#62; }
   <br/>&#62; 
   <br/>&#62; ret = devm_gpio_request_one(&#38;spi-&#62;dev, pdata-&#62;fifo,
   <br/>&#62; GPIOF_IN, &#34;fifo&#34;);
   <br/>&#62; if (ret)
   <br/>&#62; goto err_hw_init;
  </div> 
  <div>
   &#160;
  </div> 
  <div>
   I didn&#39;t find any difference but it looks good.
  </div> 
  <div>
   <br/>&#62; 
   <br/>&#62; ...
   <br/>&#62; 
   <br/>&#62; - Alex
   <br/>&#62; 
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

------=_Part_8028_1748636645.1402999380757--


--===============6066977974570866825==
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
--===============6066977974570866825==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-zigbee-devel mailing list
Linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel

--===============6066977974570866825==--
