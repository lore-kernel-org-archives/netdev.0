From: Paul Gortmaker <paul.gortmaker@gmail.com>
Subject: Re: [PATCH] netdev: fix compile issues for !CONFIG_PCI in 3c59x
Date: Mon, 26 Mar 2012 09:38:46 -0400
Message-ID: <CAP=VYLpOJOueFfzxFGCu5cKQ9--F8CqC5JWjBxej7u=8z3K0xQ@mail.gmail.com>
References: <1332724306-8799-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:60031 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757139Ab2CZNis convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2012 09:38:48 -0400
Received: by lahj13 with SMTP id j13so3895614lah.19
        for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 06:38:46 -0700 (PDT)
In-Reply-To: <1332724306-8799-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 25, 2012 at 9:11 PM, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
> I hate to add in more #ifdef CONFIG_PCI but there are already
> quite a few in this driver, and it seems like it hasn't been
> built with CONFIG_PCI set to off in quite some time.

Actually, please scrap this patch.  The uglyness of more ifdefs
made me look at it again.  It should be do-able in a cleaner way
with stubs, and it appears this may even be similar to an old fail
from the past:

http://lkml.indiana.edu/hypermail/linux/kernel/1107.3/00109.html

I'll dig into it some more and follow up.

Thanks,
Paul.

>=A0The
> MIPS allmodconfig (ISA/EISA based) doesn't set CONFIG_PCI
> and that is why we are here looking at this, even though any
> modern platform has had PCI since 1995 or so.
>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>
> diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet=
/3com/3c59x.c
> index e463d10..36ad150 100644
> --- a/drivers/net/ethernet/3com/3c59x.c
> +++ b/drivers/net/ethernet/3com/3c59x.c
> @@ -999,6 +999,7 @@ static int __init vortex_eisa_init(void)
> =A0 =A0 =A0 =A0return vortex_cards_found - orig_cards_found + eisa_fo=
und;
> =A0}
>
> +#ifdef CONFIG_PCI
> =A0/* returns count (>=3D 0), or negative on error */
> =A0static int __devinit vortex_init_one(struct pci_dev *pdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0const struct pci_device_id *ent)
> @@ -1045,6 +1046,7 @@ static int __devinit vortex_init_one(struct pci=
_dev *pdev,
> =A0out:
> =A0 =A0 =A0 =A0return rc;
> =A0}
> +#endif
>
> =A0static const struct net_device_ops boomrang_netdev_ops =3D {
> =A0 =A0 =A0 =A0.ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D vortex_open,
> @@ -1177,6 +1179,7 @@ static int __devinit vortex_probe1(struct devic=
e *gendev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compaq_net_device =3D dev;
> =A0 =A0 =A0 =A0}
>
> +#ifdef CONFIG_PCI
> =A0 =A0 =A0 =A0/* PCI-only startup logic */
> =A0 =A0 =A0 =A0if (pdev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* EISA resources already marked, so o=
nly PCI needs to do this here */
> @@ -1204,6 +1207,7 @@ static int __devinit vortex_probe1(struct devic=
e *gendev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> +#endif
>
> =A0 =A0 =A0 =A0spin_lock_init(&vp->lock);
> =A0 =A0 =A0 =A0spin_lock_init(&vp->mii_lock);
> @@ -1321,7 +1325,7 @@ static int __devinit vortex_probe1(struct devic=
e *gendev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0step, (eeprom[4]>>5) &=
 15, eeprom[4] & 31, eeprom[4]>>9);
> =A0 =A0 =A0 =A0}
>
> -
> +#ifdef CONFIG_PCI
> =A0 =A0 =A0 =A0if (pdev && vci->drv_flags & HAS_CB_FNS) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned short n;
>
> @@ -1348,6 +1352,7 @@ static int __devinit vortex_probe1(struct devic=
e *gendev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0window_write16(vp, 0x0=
800, 0, 0);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> +#endif
>
> =A0 =A0 =A0 =A0/* Extract our information from the EEPROM data. */
> =A0 =A0 =A0 =A0vp->info1 =3D eeprom[13];
> @@ -3222,6 +3227,7 @@ static void acpi_set_WOL(struct net_device *dev=
)
> =A0}
>
>
> +#ifdef CONFIG_PCI
> =A0static void __devexit vortex_remove_one(struct pci_dev *pdev)
> =A0{
> =A0 =A0 =A0 =A0struct net_device *dev =3D pci_get_drvdata(pdev);
> @@ -3269,6 +3275,7 @@ static struct pci_driver vortex_driver =3D {
> =A0 =A0 =A0 =A0.id_table =A0 =A0 =A0 =3D vortex_pci_tbl,
> =A0 =A0 =A0 =A0.driver.pm =A0 =A0 =A0=3D VORTEX_PM_OPS,
> =A0};
> +#endif
>
>
> =A0static int vortex_have_pci;
> @@ -3277,9 +3284,13 @@ static int vortex_have_eisa;
>
> =A0static int __init vortex_init(void)
> =A0{
> - =A0 =A0 =A0 int pci_rc, eisa_rc;
> + =A0 =A0 =A0 int eisa_rc;
> +#ifdef CONFIG_PCI
> + =A0 =A0 =A0 int pci_rc =3D pci_register_driver(&vortex_driver);
> +#else
> + =A0 =A0 =A0 int pci_rc =3D -ENODEV;
> +#endif
>
> - =A0 =A0 =A0 pci_rc =3D pci_register_driver(&vortex_driver);
> =A0 =A0 =A0 =A0eisa_rc =3D vortex_eisa_init();
>
> =A0 =A0 =A0 =A0if (pci_rc =3D=3D 0)
> @@ -3318,8 +3329,10 @@ static void __exit vortex_eisa_cleanup(void)
>
> =A0static void __exit vortex_cleanup(void)
> =A0{
> +#ifdef CONFIG_PCI
> =A0 =A0 =A0 =A0if (vortex_have_pci)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pci_unregister_driver(&vortex_driver);
> +#endif
> =A0 =A0 =A0 =A0if (vortex_have_eisa)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vortex_eisa_cleanup();
> =A0}
> --
> 1.7.9.4
>
>
