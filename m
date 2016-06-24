From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v10 03/22] IB/hns: Add initial main frame driver and get
 cfg info
Date: Fri, 24 Jun 2016 14:48:31 +0300
Message-ID: <20160624114831.GD23995@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-4-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Q0rSlbzrZN6k9QnT"
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
In-Reply-To: <1466087730-54856-4-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Q0rSlbzrZN6k9QnT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 16, 2016 at 10:35:11PM +0800, Lijun Ou wrote:
> This patch mainly added the initial bare main driver. It
> could get the relative configure information of net node.
>=20
> Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
> PATCH v9:
> This fixes comments given by Leon Romanovsky over the PATCH v8:
>   Link: https://lkml.org/lkml/2016/6/9/56
>=20
> PATCH v8/v7/v6:
> - No change over the PATCH v5
>=20
> PATCH v5:
> - The initial patch which was redesigned based on the second patch
>   in PATCH v4
> ---
> ---
>  drivers/infiniband/hw/hns/hns_roce_device.h |  73 ++++++++++
>  drivers/infiniband/hw/hns/hns_roce_main.c   | 200 ++++++++++++++++++++++=
++++++
>  2 files changed, 273 insertions(+)
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_device.h
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_main.c
>=20
> diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infini=
band/hw/hns/hns_roce_device.h
> new file mode 100644
> index 0000000..946b470
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/hns_roce_device.h
> @@ -0,0 +1,73 @@
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
> +#ifndef _HNS_ROCE_DEVICE_H
> +#define _HNS_ROCE_DEVICE_H
> +
> +#include <linux/platform_device.h>
> +#include <linux/radix-tree.h>
> +#include <linux/semaphore.h>
> +#include <rdma/ib_addr.h>
> +#include <rdma/ib_smi.h>
> +#include <rdma/ib_umem.h>
> +#include <rdma/ib_user_verbs.h>
> +#include <rdma/ib_verbs.h>
> +
> +#define DRV_NAME "hns_roce"
> +
> +#define HNS_ROCE_MAX_IRQ_NUM			34
> +#define HNS_ROCE_MAX_PORTS			6
> +
> +struct hns_roce_ib_iboe {
> +	struct net_device      *netdevs[HNS_ROCE_MAX_PORTS];
> +	u8			phy_port[HNS_ROCE_MAX_PORTS];
> +};
> +
> +struct hns_roce_caps {
> +	u8			num_ports;
> +};
> +
> +struct hns_roce_dev {
> +	struct ib_device	ib_dev;
> +	struct platform_device  *pdev;
> +	const char		*irq_names;
> +	struct hns_roce_ib_iboe iboe;
> +
> +	int			irq[HNS_ROCE_MAX_IRQ_NUM];
> +	u8 __iomem		*reg_base;
> +	struct hns_roce_caps	caps;
> +
> +	int			cmd_mod;
> +	int			loop_idc;
> +};
> +
> +#endif /* _HNS_ROCE_DEVICE_H */
> diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniba=
nd/hw/hns/hns_roce_main.c
> new file mode 100644
> index 0000000..8924ce3
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/hns_roce_main.c
> @@ -0,0 +1,200 @@
> +/*
> + * Copyright (c) 2016 Hisilicon Limited.
> + * Copyright (c) 2007, 2008 Mellanox Technologies. All rights reserved.
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
> +#include <linux/cdev.h>
> +#include <linux/delay.h>
> +#include <linux/device.h>
> +#include <linux/dma-mapping.h>
> +#include <linux/ethtool.h>
> +#include <linux/etherdevice.h>
> +#include <linux/fs.h>
> +#include <linux/init.h>
> +#include <linux/interrupt.h>
> +#include <linux/kernel.h>
> +#include <linux/list.h>
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/of.h>
> +#include <linux/of_address.h>
> +#include <linux/of_net.h>
> +#include <linux/of_platform.h>
> +#include <linux/platform_device.h>
> +#include <linux/slab.h>
> +#include <net/ipv6.h>
> +#include <net/addrconf.h>
> +#include <rdma/ib_addr.h>
> +#include <rdma/ib_smi.h>
> +#include <rdma/ib_umem.h>
> +#include <rdma/ib_user_verbs.h>
> +#include <rdma/ib_verbs.h>
> +#include "hns_roce_device.h"

Most of the headers are not needed here.
Please clean them.

> +
> +static int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
> +{
> +	int i;
> +	u8 phy_port;
> +	int port_cnt =3D 0;
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +	struct device_node *np =3D dev->of_node;
> +	struct device_node *net_node;
> +	struct net_device *netdev =3D NULL;
> +	struct platform_device *pdev =3D NULL;
> +	struct resource *res;
> +
> +	if (!of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
> +		dev_err(dev, "device no compatible!\n");
> +		return -EINVAL;
> +	}
> +
> +	res =3D platform_get_resource(hr_dev->pdev, IORESOURCE_MEM, 0);
> +	hr_dev->reg_base =3D devm_ioremap_resource(dev, res);
> +	if (!hr_dev->reg_base)
> +		return -ENOMEM;
> +
> +	for (i =3D 0; i < HNS_ROCE_MAX_PORTS; i++) {
> +		net_node =3D of_parse_phandle(np, "eth-handle", i);
> +		if (net_node) {
> +			pdev =3D of_find_device_by_node(net_node);
> +			netdev =3D platform_get_drvdata(pdev);
> +			phy_port =3D (u8)i;
> +			if (netdev) {
> +				hr_dev->iboe.netdevs[port_cnt] =3D netdev;
> +				hr_dev->iboe.phy_port[port_cnt] =3D phy_port;
> +			} else {
> +				return -ENODEV;
> +			}
> +			port_cnt++;
> +		}
> +	}

Do you want to check port_cnt value, before continue?

> +
> +	hr_dev->caps.num_ports =3D port_cnt;
> +
> +	/* Cmd issue mode: 0 is poll, 1 is event */
> +	hr_dev->cmd_mod =3D 1;
> +	hr_dev->loop_idc =3D 0;
> +
> +	for (i =3D 0; i < HNS_ROCE_MAX_IRQ_NUM; i++) {
> +		hr_dev->irq[i] =3D platform_get_irq(hr_dev->pdev, i);
> +		if (hr_dev->irq[i] <=3D 0) {
> +			dev_err(dev, "Get No.%d irq resource failed!\n", i);
> +			return -EINVAL;
> +		}
> +
> +		if (of_property_read_string_index(np, "interrupt-names", i,
> +						  &hr_dev->irq_names))
> +			return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
> +/**
> +* hns_roce_probe - RoCE driver entrance
> +* @pdev: pointer to platform device
> +* Return : int
> +*
> +*/
> +static int hns_roce_probe(struct platform_device *pdev)
> +{
> +	int ret;
> +	struct hns_roce_dev *hr_dev;
> +	struct device *dev =3D &pdev->dev;
> +
> +	hr_dev =3D (struct hns_roce_dev *)ib_alloc_device(sizeof(*hr_dev));
> +	if (!hr_dev)
> +		return -ENOMEM;
> +
> +	memset((u8 *)hr_dev + sizeof(struct ib_device), 0,
> +		sizeof(struct hns_roce_dev) - sizeof(struct ib_device));
> +
> +	hr_dev->pdev =3D pdev;
> +	platform_set_drvdata(pdev, hr_dev);
> +
> +	if (!dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64ULL)))
> +		dev_info(dev, "set mask to 64bit\n");
> +	else if (!dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32ULL)))
> +		dev_info(dev, "set mask to 32bit\n");
> +	else {
> +		dev_err(dev, "No usable DMA addressing mode\n");

Can you please use one style in your prints "set mask..." vs. "No usable
=2E."?

> +		ret =3D -EIO;
> +		goto error_failed_get_cfg;
> +	}
> +
> +	ret =3D hns_roce_get_cfg(hr_dev);
> +	if (ret) {
> +		dev_err(dev, "Get Configuration failed!\n");
> +		goto error_failed_get_cfg;
> +	}
> +
> +error_failed_get_cfg:
> +	ib_dealloc_device(&hr_dev->ib_dev);
> +
> +	return ret;
> +}
> +
> +/**
> +* hns_roce_remove - remove roce device
> +* @pdev: pointer to platform device
> +*/
> +static int hns_roce_remove(struct platform_device *pdev)
> +{
> +	struct hns_roce_dev *hr_dev =3D platform_get_drvdata(pdev);
> +
> +	ib_dealloc_device(&hr_dev->ib_dev);
> +
> +	return 0;
> +}
> +
> +static const struct of_device_id hns_roce_of_match[] =3D {
> +	{ .compatible =3D "hisilicon,hns-roce-v1",},
> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, hns_roce_of_match);
> +
> +static struct platform_driver hns_roce_driver =3D {
> +	.probe =3D hns_roce_probe,
> +	.remove =3D hns_roce_remove,
> +	.driver =3D {
> +		.name =3D DRV_NAME,
> +		.of_match_table =3D hns_roce_of_match,
> +	},
> +};
> +
> +module_platform_driver(hns_roce_driver);
> +
> +MODULE_LICENSE("GPL v2");

I'm not a lawyer and don't know if relicensing is possible, but original
code (mlx4) was licensed under GPL/BSD.

> +MODULE_AUTHOR("Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>");
> +MODULE_AUTHOR("Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>");
> +MODULE_AUTHOR("Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>");
> +MODULE_DESCRIPTION("HISILICON RoCE driver");
> +MODULE_ALIAS("platform:" DRV_NAME);

Is this alias needed? Did you check it? Will it concatenate strings?

> --=20
> 1.9.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--Q0rSlbzrZN6k9QnT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXbR4PAAoJEORje4g2clinoJYQAJoHKsQngpxEzDqBo7GvklT0
aJgZjDP2q4C+vlGuE35U+Zlwjp8Ivjan3HSyHpzDrfBBx6lZzbJ0vLAeUTcVV4Ra
fRpGWKW5YBnUk4FLjbufCbeOzOqgZ7EfBPljpnUxpWtv+NxLlcMcFHMKZy+oXJW4
CQidL5cYPJfVzCJ+KsSP9LswTUQcWxN9+Z5J9KHAigYdcdYeyEB0RIyYdtmtCEuN
mPNJLUu8IdMiLi75H7sfEU5fOwVLuBCTQMD6A1JLkjko2ob9f8htXBZTeOjYJnFI
Eyh9nLJupVBg59JpwHtTRn/yv82r5OAmqyR0Itbqr6o3kjRimHpXLgjb4hGUY/bF
TNp1/5QAGpMrfFXa8+zlnOECt4ML0fPxydsNi8yhEJ4XwmJiH0gVqOsAlWMN9dIu
NTDUM2C5n37kvrikF6GHaThz/KR9yrJc4kTpEGptjs4FNDhwwWEGBb2MOKxxTVt0
B80SK1I9uVO9+dTCVBS0aYn26adx+oWqVJ6mQkAX8+n/vpcUAaNeEDeyLrRVbl12
k/hR4UFHiJnG/k7S7pglmaMUNf6VRM5k5zqYVBGQwcNUsqNqB1jYfBpG8xhZrWsR
7AOTnioGN/HNbDZwpysguPMdmxysoyrGmSpbQ6wLfq+93vLSUERtKDcAnqgXq2FA
HWPg7I0qiZKmTut5kcNB
=JBlH
-----END PGP SIGNATURE-----

--Q0rSlbzrZN6k9QnT--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
