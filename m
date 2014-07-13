From: Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] cxgb4/iw_cxgb4: use firmware ord/ird resource limits
Date: Sun, 13 Jul 2014 13:59:24 +0200
Message-ID: <1405252764.32637.21.camel@localhost.localdomain>
References: <1405091662-5270-1-git-send-email-hariprasad@chelsio.com>
	 <1405091662-5270-3-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405091662-5270-3-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Le vendredi 11 juillet 2014 =C3=A0 20:44 +0530, Hariprasad Shenai a =C3=
=A9crit :
> diff --git a/drivers/infiniband/hw/cxgb4/qp.c
> b/drivers/infiniband/hw/cxgb4/qp.c
> index 6f74e0e..c911e96 100644
> --- a/drivers/infiniband/hw/cxgb4/qp.c
> +++ b/drivers/infiniband/hw/cxgb4/qp.c
> @@ -58,6 +58,30 @@ static int max_fr_immd =3D T4_MAX_FR_IMMD;
>  module_param(max_fr_immd, int, 0644);
>  MODULE_PARM_DESC(max_fr_immd, "fastreg threshold for using DSGL
> instead of immedate");
> =20
> +static int alloc_ird(struct c4iw_dev *dev, u32 ird)
> +{
> +       int ret;
> +
> +       spin_lock_irq(&dev->lock);
> +       if (ird <=3D dev->avail_ird) {
> +               dev->avail_ird -=3D ird;
> +               ret =3D 0;
> +       } else {
> +               ret =3D -ENOMEM;
> +               pr_info("%s: device IRD resources exhausted\n",
> +                       pci_name(dev->rdev.lldi.pdev));
> +       }
> +       spin_unlock_irq(&dev->lock);
> +       return ret;
> +}
> +

I would have written this function has:

static int alloc_ird(struct c4iw_dev *dev, u32 ird)
{
	int ret =3D 0

	spin_lock_irq(&dev->lock);
	if (ird <=3D dev->avail_ird)
		dev->avail_ird -=3D ird;
	else
		ret =3D -ENOMEM;
	spin_unlock_irq(&dev->lock);

	if (ret)
		dev_warn(dev->rdev.lldi.pdev,
			 "device IRD resources exhausted\n");

	return ret;
}

Regards.

--=20
Yann Droneaud
OPTEYA


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
