From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v9 03/22] IB/hns: Add initial main frame driver and get
 cfg info
Date: Thu, 9 Jun 2016 09:39:59 +0300
Message-ID: <20160609063959.GO3663@leon.nu>
References: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
 <1464795484-77395-4-git-send-email-oulijun@huawei.com>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="AKkMM/tm2Mk6Yn/s"
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	charles.chenxin@huawei.com, linuxarm@huawei.com
To: Lijun Ou <oulijun@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:51098 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932205AbcFIGkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 02:40:21 -0400
Content-Disposition: inline
In-Reply-To: <1464795484-77395-4-git-send-email-oulijun@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--AKkMM/tm2Mk6Yn/s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 01, 2016 at 11:37:45PM +0800, Lijun Ou wrote:
> This patch mainly added the initial bare main driver. It
> could get the relative configure information of net node.
>=20
> Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
> Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
> Signed-off-by: Lijun Ou <oulijun@huawei.com>
> ---
>  drivers/infiniband/hw/hns/hns_roce_device.h |  72 ++++++++++
>  drivers/infiniband/hw/hns/hns_roce_main.c   | 197 ++++++++++++++++++++++=
++++++
>  2 files changed, 269 insertions(+)
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_device.h
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_main.c
>=20
> diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infini=
band/hw/hns/hns_roce_device.h
> new file mode 100644
> index 0000000..f9de8e4
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/hns_roce_device.h
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
> index 0000000..21c5e8e
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/hns_roce_main.c
> @@ -0,0 +1,197 @@
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
> +#include <linux/netdevice.h>

You added this include (netdevice.h) 7 lines above.


--AKkMM/tm2Mk6Yn/s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXWQ8/AAoJEORje4g2clinM9wP/jRjCVNt6cN3xgK4LTUiamIO
T0xVnL6AQh2x7Ct0xlD4GwMqIAbXVanPinwNqQHjn0LCJayq7/RWPL2G8zwAiIoT
9oqvejP+d2KB3RlH714WrTGLBJ8O6q04rfuUNAEkmJzvdXH7v+ajOfmWfcTNcdlp
inOkWb/DrPB/bcfWXzgQnLXs6HP2QsjOxytxRTLeb8GrsCQ7yAbzKsn7j/EnJ6+E
moKSPvc9ovtCpwYx6xjdJA6DxlpJ/rCTxak5qINkN9Qv8U1RIYUSJz1L0xaAyaw7
pNMLNnOW5W2QBAqo0/Nvh/x1IVNcgSs6eaRc6XnIZ32oKDKvNmXvSGw+UT8gm0W/
z39rulWdCfMmm1NXSo2uo9VlaZ1dySqvd4WHk1P/ObmXV+RwDBcgjD2oFm9ucQ4Z
teNMut2HASZ2+AwawmU/bSiK7x/ygWvZkUNa3y3e1l/J7FRVqIH7vdODuU13PuXU
V1rzQWCLyCr8UdYQcmt+Gv8nu7lgzrDQHeS5VHGfUU2U0NMkj8jcv8pcxDff4OUM
Uc/sq6XX/DGsb85JPMTVeCRQXBG9fvkT/X3mf8K7IRzrm5xKmEjKFNbzC5Q5SHvl
HecRUz199NgWHqGuDUuHr7Fac4v1VHJmUD2B/xtka41brLQlDpQ5O4hw25tXn+SW
CMCsSrKBMjpLEzbJFpwC
=s0nI
-----END PGP SIGNATURE-----

--AKkMM/tm2Mk6Yn/s--
