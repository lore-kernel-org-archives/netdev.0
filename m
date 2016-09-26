From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v5 13/16] IB/pvrdma: Add the main driver module for PVRDMA
Date: Mon, 26 Sep 2016 09:03:42 +0300
Message-ID: <20160926060342.GG4088@leon.nu>
References: <cover.1474759181.git.aditr@vmware.com>
 <8db982c37a0a96b37df02826564474a216922f25.1474759181.git.aditr@vmware.com>
 <20160925075703.GX4088@leon.nu>
 <da4a09fc-bef1-60ea-f9af-7c505a9af6d6@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="fqSO13Wp+IaiYtoI"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org,
        georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org, bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org
To: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <da4a09fc-bef1-60ea-f9af-7c505a9af6d6-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--fqSO13Wp+IaiYtoI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Sep 25, 2016 at 10:10:43PM -0700, Adit Ranadive wrote:
> On sun, Sep 25 2016 at 10:57:03AM +0300, Leon Romanovsky wrote:
> > On Sat, Sep 24, 2016 at 04:21:37PM -0700, Adit Ranadive wrote:
> > > This patch adds the support to register a RDMA device with the kernel RDMA
> > > stack as well as a kernel module. This also initializes the underlying
> > > virtual PCI device.
> > >
> > > Reviewed-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> > > Reviewed-by: Jorgen Hansen <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> > > Reviewed-by: George Zhang <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> > > Reviewed-by: Aditya Sarwade <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> > > Reviewed-by: Bryan Tan <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
> > > Signed-off-by: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
>
> <...>
>
> > > +
> > > +#include <linux/errno.h>
> > > +#include <linux/inetdevice.h>
> > > +#include <linux/init.h>
> > > +#include <linux/module.h>
> > > +#include <linux/slab.h>
> > > +#include <rdma/ib_addr.h>
> > > +#include <rdma/ib_smi.h>
> > > +#include <rdma/ib_user_verbs.h>
> > > +#include <net/addrconf.h>
> > > +#include <rdma/pvrdma-abi.h>
> > > +
> > > +#include "pvrdma.h"
> > > +
> > > +#define DRV_NAME	"pvrdma"
> > > +#define DRV_VERSION	"1.0"
> > > +#define DRV_RELDATE	"January 1, 2013"
> > > +
> > > +static const char pvrdma_version[] =
> > > +	DRV_NAME ": PVRDMA InfiniBand driver v"
> > > +	DRV_VERSION " (" DRV_RELDATE ")\n";
> >
> > This is a good example why driver version and reldate are useless in
> > kernel. We are in 2016 and not in 2013. All these data are forgotten to
> > update right after the developer copied it from other pre-historic driver
> > (very common practice in netdev). It is worth to stop to use this totally
> > useless defines.
> >
>
> Sorry, in our case it was the Mellanox mlx4 driver :). Yeah, I can remove
> DRV_VERSION and DRV_RELDATE. I'll keep the MODULE_VERSION since we keep
> track of our virtual driver versions that way. So when there are any changes
> to our driver we typically bump up the version. Not sure if that's a netdev
> or misc device practice and if thats followed here.

They always promise to do it, but after year or two they are stopping.
The funny thing starts when they start debug customer issues in specific
distro with mix of backported fixes/features from old and new kernels.

>
> <...>
>
> > > +static void pvrdma_get_fw_ver_str(struct ib_device *device, char *str,
> > > +				  size_t str_len)
> > > +{
> > > +	struct pvrdma_dev *dev =
> > > +		container_of(device, struct pvrdma_dev, ib_dev);
> > > +	snprintf(str, str_len, "%d.%d.%d\n",
> > > +		 (int) (dev->dsr->caps.fw_ver >> 32),
> > > +		 (int) (dev->dsr->caps.fw_ver >> 16) & 0xffff,
> > > +		 (int) dev->dsr->caps.fw_ver & 0xffff);
> > > +}
> >
> > Yuval already pointed it to you.
> > Thanks to Ira, we have general function in core to print FW version.
> > Please use them.
> >
>
> If you are referring to commit 5fa76c20458518ed6181adddef2e31c5afc0745c
> then isnt this is exactly what Ira did for the other providers?
> Here, the pvrdma_get_fw_ver_str function is registered as a callback for
> the get_dev_fw_str API. Please our pvrdma_register_device function where
> we register our callbacks with ib_core:
> https://patchwork.kernel.org/patch/9349357/
>
> > > +	dev->ib_dev.get_dev_fw_str = pvrdma_get_fw_ver_str;

You are right,
Sorry for that.

>
>

--fqSO13Wp+IaiYtoI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX6Lo+AAoJEORje4g2clinvVEP/j1rYd32uSEJE8qHkcJeGgqg
XnFwoMTm0Iy7aPETlCAWw688aVi1aaBWrxdnuJ7xf5W9nvmzamCfKSjvNprMgxVl
jsReWSCnLzeXywIPbrd4kCfbsBlde0F0fBaeEWlChHa5z+m8lVjY5lPTQN2gSFP7
/Rq9INhqtuIR/c3YUMoPsOMtEJZHYmOzOXCX21l72lgBBz/9KSHoQHoUBTpZsm+i
obwtyD3N3tie0oq+/njleFL8EZiIcT4nFqOgEjnEfmAlGNWYrqHXEdKw9VtO+zMQ
epf8WinFSuzPhP9xlbNKntOrXOkjEiwt/IDUkyONtm6A5BpMGL+ZoPZdf6F0J24R
B8WGJrfY/DwfeQBJG/Vw4osH/fIxRdUzyHJLClkP+WdebCfkBA6mVRVcRf3zytcE
mQdzs4SSZymeDxOM07qjEZdLsjwc1racD3sl/XxN6oUv0fndyu7xE4in4JCCrjq8
ylbjSz1NG/+UljlJBECkvjrnTTO6LaTuuqipF6+zxFcJtb9pJFFAw23HMeqq9NxA
cr9p5xdwrTNj52ONjq3EwH1d4buxIcvoGrsnW71kcPoBSrn1xfoZE73J3FIGlgEW
E8OVdPn1Fp9/8MEdbih3p2Cf4ONMvvXnmj0L2CR22BmMWe/hTLwuCl1J4jin2+9k
/YwNeayAJZlVwMQrpNXk
=ApJE
-----END PGP SIGNATURE-----

--fqSO13Wp+IaiYtoI--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
