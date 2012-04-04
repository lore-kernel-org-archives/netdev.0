From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net-next 26/34] de2104x: stop using net_device.{base_addr, irq}.
Date: Tue, 3 Apr 2012 18:15:43 -0700
Message-ID: <CANEJEGtdwcUgu9GKg4Ba-vgM43BQ45a6jb_5cYO3yjdttGAiug@mail.gmail.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
	<15bee571dc5bdd3164718b6030d994628c7ddc62.1331814082.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:59156 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796Ab2DDBPo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 21:15:44 -0400
Received: by obbtb18 with SMTP id tb18so463659obb.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 18:15:44 -0700 (PDT)
In-Reply-To: <15bee571dc5bdd3164718b6030d994628c7ddc62.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 15, 2012 at 6:57 AM, Francois Romieu <romieu@fr.zoreil.com>=
 wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

thanks!
grant

> ---
> =C2=A0drivers/net/ethernet/dec/tulip/de2104x.c | =C2=A0 34 ++++++++++=
++++---------------
> =C2=A01 files changed, 16 insertions(+), 18 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/e=
thernet/dec/tulip/de2104x.c
> index 68f1c39..61cc093 100644
> --- a/drivers/net/ethernet/dec/tulip/de2104x.c
> +++ b/drivers/net/ethernet/dec/tulip/de2104x.c
> @@ -1380,6 +1380,7 @@ static void de_free_rings (struct de_private *d=
e)
> =C2=A0static int de_open (struct net_device *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct de_private *de =3D netdev_priv(dev)=
;
> + =C2=A0 =C2=A0 =C2=A0 const int irq =3D de->pdev->irq;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int rc;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_dbg(de, ifup, dev, "enabling interfa=
ce\n");
> @@ -1394,10 +1395,9 @@ static int de_open (struct net_device *dev)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dw32(IntrMask, 0);
>
> - =C2=A0 =C2=A0 =C2=A0 rc =3D request_irq(dev->irq, de_interrupt, IRQ=
=46_SHARED, dev->name, dev);
> + =C2=A0 =C2=A0 =C2=A0 rc =3D request_irq(irq, de_interrupt, IRQF_SHA=
RED, dev->name, dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (rc) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netdev_err(dev, "I=
RQ %d request failure, err=3D%d\n",
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0dev->irq, rc);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netdev_err(dev, "I=
RQ %d request failure, err=3D%d\n", irq, rc);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_out_f=
ree;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> @@ -1413,7 +1413,7 @@ static int de_open (struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> =C2=A0err_out_free_irq:
> - =C2=A0 =C2=A0 =C2=A0 free_irq(dev->irq, dev);
> + =C2=A0 =C2=A0 =C2=A0 free_irq(irq, dev);
> =C2=A0err_out_free:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0de_free_rings(de);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return rc;
> @@ -1434,7 +1434,7 @@ static int de_close (struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_carrier_off(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&de->lock, flags);
>
> - =C2=A0 =C2=A0 =C2=A0 free_irq(dev->irq, dev);
> + =C2=A0 =C2=A0 =C2=A0 free_irq(de->pdev->irq, dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0de_free_rings(de);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0de_adapter_sleep(de);
> @@ -1444,6 +1444,7 @@ static int de_close (struct net_device *dev)
> =C2=A0static void de_tx_timeout (struct net_device *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct de_private *de =3D netdev_priv(dev)=
;
> + =C2=A0 =C2=A0 =C2=A0 const int irq =3D de->pdev->irq;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_dbg(dev, "NIC status %08x mode %08x=
 sia %08x desc %u/%u/%u\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dr32(M=
acStatus), dr32(MacMode), dr32(SIAStatus),
> @@ -1451,7 +1452,7 @@ static void de_tx_timeout (struct net_device *d=
ev)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0del_timer_sync(&de->media_timer);
>
> - =C2=A0 =C2=A0 =C2=A0 disable_irq(dev->irq);
> + =C2=A0 =C2=A0 =C2=A0 disable_irq(irq);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irq(&de->lock);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0de_stop_hw(de);
> @@ -1459,12 +1460,12 @@ static void de_tx_timeout (struct net_device =
*dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_carrier_off(dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irq(&de->lock);
> - =C2=A0 =C2=A0 =C2=A0 enable_irq(dev->irq);
> + =C2=A0 =C2=A0 =C2=A0 enable_irq(irq);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Update the error counts. */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__de_get_stats(de);
>
> - =C2=A0 =C2=A0 =C2=A0 synchronize_irq(dev->irq);
> + =C2=A0 =C2=A0 =C2=A0 synchronize_irq(irq);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0de_clean_rings(de);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0de_init_rings(de);
> @@ -2024,8 +2025,6 @@ static int __devinit de_init_one (struct pci_de=
v *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_out_r=
es;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 dev->irq =3D pdev->irq;
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* obtain and check validity of PCI I/O ad=
dress */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pciaddr =3D pci_resource_start(pdev, 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!pciaddr) {
> @@ -2050,7 +2049,6 @@ static int __devinit de_init_one (struct pci_de=
v *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 pciaddr, pci_name(pdev));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_out_r=
es;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 dev->base_addr =3D (unsigned long) regs;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0de->regs =3D regs;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0de_adapter_wake(de);
> @@ -2078,11 +2076,9 @@ static int __devinit de_init_one (struct pci_d=
ev *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_out_i=
omap;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* print info about board and interface ju=
st registered */
> - =C2=A0 =C2=A0 =C2=A0 netdev_info(dev, "%s at 0x%lx, %pM, IRQ %d\n",
> + =C2=A0 =C2=A0 =C2=A0 netdev_info(dev, "%s at %p, %pM, IRQ %d\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
de->de21040 ? "21040" : "21041",
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev-=
>base_addr,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev-=
>dev_addr,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev-=
>irq);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 regs=
, dev->dev_addr, pdev->irq);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_drvdata(pdev, dev);
>
> @@ -2130,9 +2126,11 @@ static int de_suspend (struct pci_dev *pdev, p=
m_message_t state)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rtnl_lock();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (netif_running (dev)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const int irq =3D =
pdev->irq;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0del_timer_sync=
(&de->media_timer);
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 disable_irq(dev->i=
rq);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 disable_irq(irq);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irq(=
&de->lock);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0de_stop_hw(de)=
;
> @@ -2141,12 +2139,12 @@ static int de_suspend (struct pci_dev *pdev, =
pm_message_t state)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_carrier_=
off(dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_ir=
q(&de->lock);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enable_irq(dev->ir=
q);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enable_irq(irq);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Update the =
error counts. */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__de_get_stats=
(de);
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 synchronize_irq(de=
v->irq);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 synchronize_irq(ir=
q);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0de_clean_rings=
(de);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0de_adapter_sle=
ep(de);
> --
> 1.7.7.6
>
