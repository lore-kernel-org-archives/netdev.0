From: Andreas Fenkart <afenkart@gmail.com>
Subject: Re: [PATCH] ARC VMAC driver.
Date: Tue, 20 Mar 2012 09:40:00 +0100
Message-ID: <CALtMJECEj7dtseSas9708L6xKs2fobS9_m3bVY_BCe6icLWRsA@mail.gmail.com>
References: <1330941585-7404-1-git-send-email-afenkart@gmail.com>
	<20120305.153004.120141018357651846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:41239 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739Ab2CTIkD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 04:40:03 -0400
Received: by wibhq7 with SMTP id hq7so4892300wib.1
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2012 01:40:00 -0700 (PDT)
In-Reply-To: <20120305.153004.120141018357651846.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Am 5. M=E4rz 2012 21:30 schrieb David Miller <davem@davemloft.net>:
> From: Andreas Fenkart <afenkart@gmail.com>
> Date: Mon, =A05 Mar 2012 10:59:45 +0100
>
>> + =A0 =A0 unsigned mac_lo, mac_hi;
>
> Please never say just "unsigned" but instead use "unsigned int"
> But in this case you're dealing with a fixed sized value so
> "u32" is most appropriate.
>
>> + =A0 =A0 unsigned mac_lo, mac_hi;
>
> Same here.
>
>> +static void vmac_mdio_xmit(struct vmac_priv *ap, unsigned val)
>
> Again. =A0So please fix this up in the entire driver.
>
>> + =A0 =A0 int report_change =3D 0;
>
> Please use 'bool' as the type and 'true' and 'false' as the values.
>
>> + =A0 =A0 ap->mii_bus =3D mdiobus_alloc();
>> + =A0 =A0 if (ap->mii_bus =3D=3D NULL)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>
> Use "if (!ap->mii_bus)" for null pointer checks.
>
>> + =A0 =A0 ap->mii_bus->irq =3D kmalloc(sizeof(int) * PHY_MAX_ADDR, G=
=46P_KERNEL);
>> + =A0 =A0 if (!ap->mii_bus->irq)
>
> Which inconsistently you do correctly here.
>
>> + =A0 =A0 struct vmac_priv *ap =3D netdev_priv(dev);
>> + =A0 =A0 dev_dbg(&ap->pdev->dev, "rx error counter overrun. status =
=3D 0x%x\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status);
>
> Please add an empty line between the function variable declarations a=
nd
> the first actual code statement.
>
>> + =A0 =A0 if (!fifo_empty(&ap->rx_ring)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ap->pdev->dev, "failed to reclaim=
 %d rx sk_buff\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fifo_used(=
&ap->rx_ring));
>> + =A0 =A0 }
>
> You don't need openning and closing braces for a single line basic
> block. =A0It just takes up an unnecessary extra line in the source.
>
>> + =A0 =A0 /* locking: fct owns rx_ring tail to current DMA read posi=
tion, alias
>> + =A0 =A0 =A0* 'received packets'. rx_refill owns area outside rx_ri=
ng, doesn't
>> + =A0 =A0 =A0* modify tail */
>
> Code comments:
>
> =A0 =A0 =A0 =A0/* Like
> =A0 =A0 =A0 =A0 * this.
> =A0 =A0 =A0 =A0 */
>
> =A0 =A0 =A0 =A0 /* Or like this. */
>
> =A0 =A0 =A0 =A0 /* But not
> =A0 =A0 =A0 =A0 =A0* like this. */
>
>
> There are other instances of this issue in the driver, please fix tho=
se
> too.
>
>> + =A0 =A0 unsigned long tmp;
>
> This is a 32-bit value not a long which is a non-fixed-sized type
> and might be 64-bit. =A0You definitely want to use "u32" for these.
>
>> +static void vmac_toggle_rxint_unlocked(struct net_device *dev, int =
enable)
>
> Use 'bool' for all the places where you do this "enable" argument in
> functions.
>
>> + =A0 =A0 if ((status & RXINT_MASK) && (vmac_readl(ap, ENABLE) && RX=
INT_MASK) &&
>
> All of these register bit tests are wrong, you're using "&&
> RXINT_MASK" instead of "& RXINT_MASK".
>
>> + =A0 =A0 if ((status & TXINT_MASK) && (vmac_readl(ap, ENABLE) && TX=
INT_MASK)) {
>
> Same bug.
>
>> +static int vmac_tx_reclaim_unlocked(struct net_device *dev, int for=
ce)
>> +{
>> + =A0 =A0 struct vmac_priv *ap =3D netdev_priv(dev);
>> + =A0 =A0 int released =3D 0;
>
> Use 'bool' and true/false for 'force' and 'released'.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb_any(skb);
>
> You only need to use the significantly more expensive dev_kfree_skb_a=
ny() if this
> code can run in a hardware interrupt handler.
>
> This is a NAPI driver and therefore it should only do reclaim from
> NAPI poll and thus software interrupt context. =A0Therefore you can u=
se
> dev_kfree_skb() which is 10 times faster than dev_kfree_skb_any()
> which results in a new software interrupt getting queued up.
>
>> + =A0 =A0 if (unlikely(skb->len < ETH_ZLEN)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *short_skb;
>> + =A0 =A0 =A0 =A0 =A0 =A0 short_skb =3D netdev_alloc_skb(dev, ETH_ZL=
EN);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!short_skb)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NETDEV_TX_LOCKED;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 memset(short_skb->data, 0, ETH_ZLEN);
>> + =A0 =A0 =A0 =A0 =A0 =A0 memcpy(skb_put(short_skb, ETH_ZLEN), skb->=
data, skb->len);
>> + =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb(skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb =3D short_skb;
>> + =A0 =A0 }
>
> Don't reinvent the wheel, use skb_pad() or similar, which is much mor=
e efficient
> than this open-coded version.
>
>> + =A0 =A0 desc->data =3D dma_map_single(&ap->pdev->dev, skb->data, s=
kb->len,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 DMA_TO_DEVICE);
>
> Align the argument up to the openning parenthesis on the previous lin=
e:
>
> =A0 =A0 =A0 =A0desc->data =3D dma_map_single(&ap->pdev->dev, skb->dat=
a, skb->len,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
DMA_TO_DEVICE);
>
>> + =A0 =A0 ap->rxbd =3D dma_alloc_coherent(&ap->pdev->dev, size,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &ap->rxbd_dma,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL);
>
> Same problem.
>
>> + =A0 =A0 if (ap->rxbd =3D=3D NULL)
>
> Test with "if (!ptr)" not "if (ptr =3D=3D NULL)"
>
>> + =A0 =A0 ap->txbd =3D dma_alloc_coherent(&ap->pdev->dev, size,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &ap->txbd_dma,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL);
>
> Argument alignment.
>
>> + =A0 =A0 dma_free_coherent(&ap->pdev->dev, sizeof(*ap->txbd) * ap->=
tx_ring.size,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ap->txbd, ap->txbd_dma);
> =A0...
>> + =A0 =A0 dma_free_coherent(&ap->pdev->dev, sizeof(*ap->rxbd) * ap->=
rx_ring.size,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ap->rxbd, ap->rxbd_dma);
>
> Again and again.
>
>> + =A0 =A0 dma_free_coherent(&ap->pdev->dev, sizeof(ap->txbd) * ap->t=
x_ring.size,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ap->txbd, ap->txbd_dma);
>> + =A0 =A0 dma_free_coherent(&ap->pdev->dev, sizeof(ap->rxbd) * ap->r=
x_ring.size,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ap->rxbd, ap->rxbd_dma);
>
> More of the same.
>
>> + =A0 =A0 if (ap =3D=3D NULL)
>
> Test "if (!ap)" instad.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ap->pdev->dev, "Unable to request=
 IRQ %d (error %d)\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->irq, =
err);
>
> Argument alignment.
>
>> + =A0 =A0 temp |=3D ERR_MASK | TXCH_MASK | MSER_MASK | RXCR_MASK | R=
XFR_MASK | \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 RXFL_MASK;
>
> There is no reason to escape the newline with a "\" here, get rid of =
that.
>
>> + =A0 =A0 dev_info(&ap->pdev->dev, "PHY driver [%s] (mii_bus:phy_add=
r=3D%s, irq=3D%d)\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0phydev->drv->name, dev_name(&phydev->dev), =
phydev->irq);
>
> Argument alignment.
>
>> + =A0 =A0 unsigned int temp;
>
> Use "u32" for the type.
>
>> +static void create_multicast_filter(struct net_device *dev,
>> + =A0 =A0 int32_t *bitmask)
>
> Argument alignment.
>
>> + =A0 =A0 int promisc, reg;
>
> Use 'bool' for 'promisc', use 'u32' for 'reg'.
>
>> + =A0 =A0 int32_t bitmask[2];
>
> Don't use int32_t in the kernel, use 'u32' instead.
>
>> + =A0 =A0 if (dma_get_mask(&pdev->dev) > DMA_BIT_MASK(32) ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdev->dev.coherent_dma_mas=
k > DMA_BIT_MASK(32)) {
>
> Align things properly:
>
> =A0 =A0 =A0 =A0if (dma_get_mask(&pdev->dev) > DMA_BIT_MASK(32) ||
> =A0 =A0 =A0 =A0 =A0 =A0pdev->dev.coherent_dma_mask > DMA_BIT_MASK(32)=
) {
>
>> + =A0 =A0 dev->flags |=3D IFF_MULTICAST;
>
> Why in the world do you need to do this? =A0The ethernet generic setu=
p takes
> care of this for you.
>
>> + =A0 =A0 if (!is_valid_ether_addr(dev->dev_addr))
>> + =A0 =A0 =A0 =A0 =A0 =A0 random_ether_addr(dev->dev_addr);
>
> Use dev_hw_addr_random() which will properly set the NET_ADDR_RANDOM =
attribute
> properly too.
>
>> + =A0 =A0 dev_info(&pdev->dev, "ARC VMAC at 0x%pP irq %d %pM\n", &me=
m->start,
>> + =A0 =A0 =A0 =A0 dev->irq, dev->dev_addr);
>
> Align the arguments properly.
>
>> +struct =A0 =A0 =A0 vmac_priv {
>
> Get rid of that ugly tab, use a single space instead.
>
>> +static inline int fifo_empty(struct dma_fifo *f)
>
> Return 'bool'.
>
>> +static inline int fifo_full(struct dma_fifo *f)
>
> Return 'bool'.
>> + =A0 =A0 pr_info("fifo: head %d, tail %d, size %d\n", fifo->head,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fifo->tail,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fifo->size);
>
> Align arguments properly.

Thanks. I fixed and I'll be sending out a rev 2 shortly.

Regards
Andi
