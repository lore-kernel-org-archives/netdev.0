From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v10 04/22] IB/hns: Add RoCE engine reset function
Date: Fri, 24 Jun 2016 17:59:38 +0300
Message-ID: <20160624145938.GE23995@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-5-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="//IivP0gvsAy3Can"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1466087730-54856-5-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--//IivP0gvsAy3Can
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 16, 2016 at 10:35:12PM +0800, Lijun Ou wrote:
> This patch mainly added reset flow of RoCE engine in RoCE
> driver. It is necessary when RoCE is loaded and removed.
>=20
> Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
> PATCH v9/v8:
> - No change over the PATCH v7
>=20
> PATCH v7:
> This fixes the comments given by Leon Romanovsky over the PATCH v6:
>   Link: https://lkml.org/lkml/2016/5/3/733
>=20
> PATCH v6:
> - No change over the PATCH v5
>=20
> PATCH v5:
> - The initial patch which was redesigned based on the second patch
>   in PATCH v4
> ---
> ---
>  drivers/infiniband/hw/hns/hns_roce_device.h |  7 +++
>  drivers/infiniband/hw/hns/hns_roce_hw_v1.c  | 72 +++++++++++++++++++++++=
++++++
>  drivers/infiniband/hw/hns/hns_roce_hw_v1.h  | 40 ++++++++++++++++
>  drivers/infiniband/hw/hns/hns_roce_main.c   | 17 ++++++-
>  4 files changed, 135 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_hw_v1.c
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_hw_v1.h
>=20
> diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infini=
band/hw/hns/hns_roce_device.h
> index 946b470..b857c76 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_device.h
> +++ b/drivers/infiniband/hw/hns/hns_roce_device.h
> @@ -56,6 +56,10 @@ struct hns_roce_caps {
>  	u8			num_ports;
>  };
> =20
> +struct hns_roce_hw {
> +	int (*reset)(struct hns_roce_dev *hr_dev, bool enable);
> +};
> +
>  struct hns_roce_dev {
>  	struct ib_device	ib_dev;
>  	struct platform_device  *pdev;
> @@ -68,6 +72,9 @@ struct hns_roce_dev {
> =20
>  	int			cmd_mod;
>  	int			loop_idc;
> +	struct hns_roce_hw	*hw;
>  };
> =20
> +extern struct hns_roce_hw hns_roce_hw_v1;
> +
>  #endif /* _HNS_ROCE_DEVICE_H */
> diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infinib=
and/hw/hns/hns_roce_hw_v1.c
> new file mode 100644
> index 0000000..198be3b
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
> @@ -0,0 +1,72 @@
> +/*
> + * Copyright (c) 2016 Hisilicon Limited.
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * OpenIB.org BSD license below:
> + *
> + *     Redistribution and use in source and binary forms, with or
> + *     without modification, are permitted provided that the following
> + *     conditions are met:
> + *
> + *      - Redistributions of source code must retain the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer.
> + *
> + *      - Redistributions in binary form must reproduce the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer in the documentation and/or other materials
> + *        provided with the distribution.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/of.h>
> +#include <linux/of_address.h>
> +#include <linux/of_platform.h>
> +#include <linux/platform_device.h>
> +#include "hns_roce_device.h"
> +#include "hns_roce_hw_v1.h"
> +
> +/**
> + * hns_roce_v1_reset - reset roce
> + * @hr_dev: roce device struct pointer
> + * @enable: true -- drop reset, false -- reset
> + * return 0 - success , negative --fail
> + */
> +int hns_roce_v1_reset(struct hns_roce_dev *hr_dev, bool enable)
> +{
> +	struct device_node *dsaf_node;
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct device_node *np =3D dev->of_node;
> +	int ret;
> +
> +	dsaf_node =3D of_parse_phandle(np, "dsaf-handle", 0);
> +
> +	if (!enable) {
> +		ret =3D hns_dsaf_roce_reset(&dsaf_node->fwnode, false);
> +	} else {
> +		ret =3D hns_dsaf_roce_reset(&dsaf_node->fwnode, false);

Move this line out of if-else and leave "if (enable)" part only.

> +		if (ret)
> +			return ret;
> +
> +		msleep(SLEEP_TIME_INTERVAL);

Nice, here you used define and in other places just hardcoded 20
(msleep(20)). Please give meaningful definition to 20.

> +		ret =3D hns_dsaf_roce_reset(&dsaf_node->fwnode, true);
> +	}
> +
> +		return ret;

Indentation

> +}
> +
> +struct hns_roce_hw hns_roce_hw_v1 =3D {
> +	.reset =3D hns_roce_v1_reset,
> +};
> diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infinib=
and/hw/hns/hns_roce_hw_v1.h
> new file mode 100644
> index 0000000..a8c0c1d
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
> @@ -0,0 +1,40 @@
> +/*
> + * Copyright (c) 2016 Hisilicon Limited.
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * OpenIB.org BSD license below:
> + *
> + *     Redistribution and use in source and binary forms, with or
> + *     without modification, are permitted provided that the following
> + *     conditions are met:
> + *
> + *      - Redistributions of source code must retain the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer.
> + *
> + *      - Redistributions in binary form must reproduce the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer in the documentation and/or other materials
> + *        provided with the distribution.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#ifndef _HNS_ROCE_HW_V1_H
> +#define _HNS_ROCE_HW_V1_H
> +
> +#define SLEEP_TIME_INTERVAL				20
> +
> +extern int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool e=
nable);

Why did you add this extern?
You already exported this function.
drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c:EXPORT_SYMBOL(hns_dsaf_r=
oce_reset);

> +
> +#endif
> diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniba=
nd/hw/hns/hns_roce_main.c
> index 8924ce3..d5ccce2 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_main.c
> +++ b/drivers/infiniband/hw/hns/hns_roce_main.c
> @@ -71,7 +71,9 @@ static int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
>  	struct platform_device *pdev =3D NULL;
>  	struct resource *res;
> =20
> -	if (!of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
> +	if (of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
> +		hr_dev->hw =3D &hns_roce_hw_v1;
> +	} else {
>  		dev_err(dev, "device no compatible!\n");
>  		return -EINVAL;
>  	}
> @@ -118,6 +120,11 @@ static int hns_roce_get_cfg(struct hns_roce_dev *hr_=
dev)
>  	return 0;
>  }
> =20
> +static int hns_roce_engine_reset(struct hns_roce_dev *hr_dev, bool enabl=
e)
> +{
> +	return hr_dev->hw->reset(hr_dev, enable);
> +}
> +
>  /**
>  * hns_roce_probe - RoCE driver entrance
>  * @pdev: pointer to platform device
> @@ -156,6 +163,12 @@ static int hns_roce_probe(struct platform_device *pd=
ev)
>  		goto error_failed_get_cfg;
>  	}
> =20
> +	ret =3D hns_roce_engine_reset(hr_dev, true);

Do you have better solution to sense device without doing full reset of
your hardware?

> +	if (ret) {
> +		dev_err(dev, "Reset roce engine failed!\n");
> +		goto error_failed_get_cfg;
> +	}
> +
>  error_failed_get_cfg:
>  	ib_dealloc_device(&hr_dev->ib_dev);
> =20
> @@ -170,6 +183,8 @@ static int hns_roce_remove(struct platform_device *pd=
ev)
>  {
>  	struct hns_roce_dev *hr_dev =3D platform_get_drvdata(pdev);
> =20
> +	(void)hns_roce_engine_reset(hr_dev, false);

Any reason to do explicit casting?

> +
>  	ib_dealloc_device(&hr_dev->ib_dev);
> =20
>  	return 0;
> --=20
> 1.9.1
>=20

--//IivP0gvsAy3Can
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXbUraAAoJEORje4g2cline30P/1yJ33fZrligrv5jueHU4W/8
qWSSLp70et37ogbDS1gWx4RQKiosEGllic7CGBjrTrZro2zbwPpKEiYfAMUBC4Z4
AB9Xw5ye2nBfAeBVaKSYeIJvjJcbxBFWpVuUG3Bs9VHe5yI//lOJCTLDRvlo7xWE
3fYSmQ+cyJbZyRtEd/uwPMYDdNmIa/Tgn5HQ2775n2TwpXoU2E6qjZvRHBopij8c
OxUnt89eFtgTD+s3Krg0aLXEl4/aqN5/ly+7j1KMdeli/UXiWHSuvEW0hVH/9UCg
1F/neP9fOR1eKqMVXTo5kxGJxoxCcX694HVOm4WB07xerpooJKfebcVrjnpT6R3i
L1mLPlxsOTK0FbjE4F4yYdjvEBqYvzfhI37l60BJqoSGILym+Se2G4ncZj4kfWiv
GRnebPJXpqYG+enE2lmGrox1IlQrIRRxm9w2PvbetWT7IVxJja6AqYkISXBsF/rF
oMI3FtueV0cPYoiysMfQh182kLpkW7gQYx/govAOfL1BY/5diteEXsNahLEOAR4X
AKGeSewV0UqjTZdI7RAppIpfUIxV33cgAkYX+4FBpeQe4SXD18YWjXMDEMVwdjIo
B2DPLlWC0f/hK6nYr2Wwz6OMOKmmIzIo4R5YfeNHGZauf2/rBACIY2iK+nJpmqVM
OCoz262QHzbwUx37pe9E
=ezXW
-----END PGP SIGNATURE-----

--//IivP0gvsAy3Can--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
