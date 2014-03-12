From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next v3 6/9] Altera TSE: Add main and header file for
 Altera Ethernet Driver
Date: Wed, 12 Mar 2014 10:25:26 -0500
Message-ID: <CAOwfj2Png8mY1duQ6ewUMOCqO37UZD85Q6ptpLVzuoanvrJ1RA@mail.gmail.com>
References: <1394577791-6547-1-git-send-email-vbridgers2013@gmail.com>
	<1394577791-6547-7-git-send-email-vbridgers2013@gmail.com>
	<1394585144.28839.32.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1394585144.28839.32.camel@joe-AO722>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 11, 2014 at 7:45 PM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2014-03-11 at 17:43 -0500, Vince Bridgers wrote:
>> This patch adds the main driver and header file for the Altera Triple
>> Speed Ethernet driver.
>
> trivial notes about message logging:
>
>> diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
> []
>> +static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
>> +                                     NETIF_MSG_LINK | NETIF_MSG_IFUP |
>> +                                     NETIF_MSG_IFDOWN);
> []
>> +static int altera_tse_mdio_create(struct net_device *dev, unsigned int id)
>> +{
> []
>> +     mdio->irq = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
>> +     if (mdio->irq == NULL) {
>> +             dev_err(priv->device, "%s: Cannot allocate memory\n", __func__);
>
> OOM messages aren't necessary as all allocs have
> a generic OOM message as well as a dump_stack();
> (well, any alloc without GFP_NOWARN)
>
>> +     ret = of_mdiobus_register(mdio, mdio_node);
>> +     if (ret != 0) {
>> +             dev_err(priv->device, "Cannot register MDIO bus %s\n",
>> +                     mdio->id);
>
> Because you have a struct net_device * available,
> you should probably use that.
>
>                 netdev_err(dev, "Cannot register MDIO bus %s\n", mdio->id);
>
>> +             goto out_free_mdio_irq;
>> +     }
>> +
>> +     if (netif_msg_drv(priv))
>> +             dev_info(priv->device, "MDIO bus %s: created\n", mdio->id);
>
> There are generic functions for this with the struct net_device *
>
>         netif_info(priv, drv, dev, "MDIO bus %s: created\n", mdio->id);
>
>> +static void altera_tse_mdio_destroy(struct net_device *dev)
>> +{
> []
>> +     if (netif_msg_drv(priv))
>> +             dev_info(priv->device, "MDIO bus %s: removed\n",
>> +                      priv->mdio->id);
>
>         netif_info(priv, drv, dev, "MDIO bus %s: removed\n, priv->mdio->id);
>
> []
>
>> +static int tse_init_rx_buffer(struct altera_tse_private *priv,
>> +                           struct tse_buffer *rxbuffer, int len)
>> +{
>> +     rxbuffer->skb = netdev_alloc_skb_ip_align(priv->dev, len);
>> +     if (!rxbuffer->skb) {
>> +             dev_err(priv->device, "%s: Rx init fails; skb is NULL\n",
>> +                     __func__);
>
>                 netdev_err(priv->dev, "%s: etc...)
>
> but this is also a generic alloc and will get the same generic OOM.
>
>> +     if (dma_mapping_error(priv->device, rxbuffer->dma_addr)) {
>> +             dev_err(priv->device, "%s: DMA mapping error\n", __func__);
>
>                 netdev_err(priv->dev, etc...)
>
> etc...
>
Thank you for taking the time to review and provide constructive
comments. I'll address the comments and respin.

All the best,

Vince
