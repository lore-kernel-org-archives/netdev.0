From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net-next #2 21/39] tulip_core: stop using
 net_device.{base_addr, irq}.
Date: Fri, 6 Apr 2012 09:57:59 -0700
Message-ID: <CANEJEGtebwmhLYouh-gE4EtgAOWQkTaeitXi7WWUkSvLAUVJ=g@mail.gmail.com>
References: <1333704408.git.romieu@fr.zoreil.com>
	<43487f61a41077ec5cf8587248eb502f5d9be785.1333704409.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:63197 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756483Ab2DFQ6A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 12:58:00 -0400
Received: by obbtb18 with SMTP id tb18so3301604obb.19
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 09:58:00 -0700 (PDT)
In-Reply-To: <43487f61a41077ec5cf8587248eb502f5d9be785.1333704409.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 6, 2012 at 3:06 AM, Francois Romieu <romieu@fr.zoreil.com> =
wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>

Ack-by: Grant Grundler <grundler@parisc-linux.org>

thanks,
grant

> ---
> =C2=A0drivers/net/ethernet/dec/tulip/tulip_core.c | =C2=A0 27 +++++++=
+++++++++-----------
> =C2=A01 files changed, 16 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/ne=
t/ethernet/dec/tulip/tulip_core.c
> index fea3641..25fe117 100644
> --- a/drivers/net/ethernet/dec/tulip/tulip_core.c
> +++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
> @@ -328,7 +328,7 @@ static void tulip_up(struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(100);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (tulip_debug > 1)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netdev_dbg(dev, "t=
ulip_up(), irq=3D=3D%d\n", dev->irq);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netdev_dbg(dev, "t=
ulip_up(), irq=3D=3D%d\n", tp->pdev->irq);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0iowrite32(tp->rx_ring_dma, ioaddr + CSR3);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0iowrite32(tp->tx_ring_dma, ioaddr + CSR4);
> @@ -515,11 +515,13 @@ media_picked:
> =C2=A0static int
> =C2=A0tulip_open(struct net_device *dev)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 struct tulip_private *tp =3D netdev_priv(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int retval;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tulip_init_ring (dev);
>
> - =C2=A0 =C2=A0 =C2=A0 retval =3D request_irq(dev->irq, tulip_interru=
pt, IRQF_SHARED, dev->name, dev);
> + =C2=A0 =C2=A0 =C2=A0 retval =3D request_irq(tp->pdev->irq, tulip_in=
terrupt, IRQF_SHARED,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->name, dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (retval)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto free_ring=
;
>
> @@ -841,7 +843,7 @@ static int tulip_close (struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_dbg(dev=
, "Shutting down ethercard, status was %02x\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 ioread32 (ioaddr + CSR5));
>
> - =C2=A0 =C2=A0 =C2=A0 free_irq (dev->irq, dev);
> + =C2=A0 =C2=A0 =C2=A0 free_irq (tp->pdev->irq, dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tulip_free_ring (dev);
>
> @@ -1489,8 +1491,6 @@ static int __devinit tulip_init_one (struct pci=
_dev *pdev,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_WORK(&tp->media_work, tulip_tbl[tp->c=
hip_id].media_task);
>
> - =C2=A0 =C2=A0 =C2=A0 dev->base_addr =3D (unsigned long)ioaddr;
> -
> =C2=A0#ifdef CONFIG_TULIP_MWI
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!force_csr0 && (tp->flags & HAS_PCI_MW=
I))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tulip_mwi_conf=
ig (pdev, dev);
> @@ -1650,7 +1650,6 @@ static int __devinit tulip_init_one (struct pci=
_dev *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < 6; i++)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0last_phys_addr=
[i] =3D dev->dev_addr[i];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0last_irq =3D irq;
> - =C2=A0 =C2=A0 =C2=A0 dev->irq =3D irq;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* The lower four bits are the media type.=
 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (board_idx >=3D 0 =C2=A0&& =C2=A0board_=
idx < MAX_UNITS) {
> @@ -1858,7 +1857,8 @@ static int tulip_suspend (struct pci_dev *pdev,=
 pm_message_t state)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tulip_down(dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_device_detach(dev);
> - =C2=A0 =C2=A0 =C2=A0 free_irq(dev->irq, dev);
> + =C2=A0 =C2=A0 =C2=A0 /* FIXME: it needlessly adds an error path. */
> + =C2=A0 =C2=A0 =C2=A0 free_irq(tp->pdev->irq, dev);
>
> =C2=A0save_state:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_save_state(pdev);
> @@ -1900,7 +1900,9 @@ static int tulip_resume(struct pci_dev *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return retval;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 if ((retval =3D request_irq(dev->irq, tulip_in=
terrupt, IRQF_SHARED, dev->name, dev))) {
> + =C2=A0 =C2=A0 =C2=A0 retval =3D request_irq(pdev->irq, tulip_interr=
upt, IRQF_SHARED,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->name, dev);
> + =C2=A0 =C2=A0 =C2=A0 if (retval < 0) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err("reques=
t_irq failed in resume\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return retval;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> @@ -1960,11 +1962,14 @@ static void __devexit tulip_remove_one (struc=
t pci_dev *pdev)
>
> =C2=A0static void poll_tulip (struct net_device *dev)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 struct tulip_private *tp =3D netdev_priv(dev);
> + =C2=A0 =C2=A0 =C2=A0 const int irq =3D tp->pdev->irq;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* disable_irq here is not very nice, but =
with the lockless
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 interrupt handler we have no other=
 choice. */
> - =C2=A0 =C2=A0 =C2=A0 disable_irq(dev->irq);
> - =C2=A0 =C2=A0 =C2=A0 tulip_interrupt (dev->irq, dev);
> - =C2=A0 =C2=A0 =C2=A0 enable_irq(dev->irq);
> + =C2=A0 =C2=A0 =C2=A0 disable_irq(irq);
> + =C2=A0 =C2=A0 =C2=A0 tulip_interrupt (irq, dev);
> + =C2=A0 =C2=A0 =C2=A0 enable_irq(irq);
> =C2=A0}
> =C2=A0#endif
>
> --
> 1.7.7.6
>
