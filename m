From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v5 09/21] IB/hns: Add hca support
Date: Sun, 24 Apr 2016 10:54:24 +0300
Message-ID: <20160424075424.GE7974@leon.nu>
References: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
 <1461407219-72027-10-git-send-email-oulijun@huawei.com>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Uwl7UQhJk99r8jnw"
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linuxarm@huawei.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gongyangming@huawei.com,
	xiaokun@huawei.com, tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	lisheng011@huawei.com, charles.chenxin@huawei.com
To: Lijun Ou <oulijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1461407219-72027-10-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Uwl7UQhJk99r8jnw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Apr 23, 2016 at 06:26:47PM +0800, Lijun Ou wrote:
> This patch mainly setup hca for RoCE. it will do a series of
> initial works as follows:
>       1. init uar table, allocate uar resource
>       2. init pd table
>       3. init cq table
>       4. init mr table
>       5. init qp table
>=20
> Signed-off-by: Lijun Ou <oulijun@huawei.com>
> Signed-off-by: Wei Hu(Xavier) <xavier.huwei@huawei.com>
> ---
>  drivers/infiniband/hw/hns/hns_roce_alloc.c  | 104 ++++++++++++++++
>  drivers/infiniband/hw/hns/hns_roce_cq.c     |  25 ++++
>  drivers/infiniband/hw/hns/hns_roce_device.h |  69 ++++++++++
>  drivers/infiniband/hw/hns/hns_roce_eq.c     |   1 -
>  drivers/infiniband/hw/hns/hns_roce_icm.c    |  88 +++++++++++++
>  drivers/infiniband/hw/hns/hns_roce_icm.h    |   9 ++
>  drivers/infiniband/hw/hns/hns_roce_main.c   |  79 ++++++++++++
>  drivers/infiniband/hw/hns/hns_roce_mr.c     | 187 ++++++++++++++++++++++=
++++++
>  drivers/infiniband/hw/hns/hns_roce_pd.c     |  65 ++++++++++
>  drivers/infiniband/hw/hns/hns_roce_qp.c     |  30 +++++
>  10 files changed, 656 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_alloc.c
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_mr.c
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_pd.c
>=20
> diff --git a/drivers/infiniband/hw/hns/hns_roce_alloc.c b/drivers/infinib=
and/hw/hns/hns_roce_alloc.c
> new file mode 100644
> index 0000000..0c76f1b
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/hns_roce_alloc.c
> @@ -0,0 +1,104 @@
> +/*
> + * Copyright (c) 2016 Hisilicon Limited.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/bitmap.h>
> +#include <linux/dma-mapping.h>
> +#include <linux/errno.h>
> +#include <linux/mm.h>
> +#include <linux/slab.h>
> +#include <linux/vmalloc.h>
> +#include "hns_roce_device.h"
> +
> +int hns_roce_bitmap_alloc(struct hns_roce_bitmap *bitmap, u32 *obj)
> +{
> +	int ret =3D 0;
> +
> +	spin_lock(&bitmap->lock);
> +	*obj =3D find_next_zero_bit(bitmap->table, bitmap->max, bitmap->last);
> +	if (*obj >=3D bitmap->max) {
> +		bitmap->top =3D (bitmap->top + bitmap->max + bitmap->reserved_top)
> +			       & bitmap->mask;
> +		*obj =3D find_first_zero_bit(bitmap->table, bitmap->max);

find_first_zero_bit function returns "unsigned long" which may or may
not be equal to u32 on some architectures.

--Uwl7UQhJk99r8jnw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXHHuwAAoJEORje4g2clinWiMP/3ZBTrlz1Ozt3UxcT4Dq5G6W
QgoKo6ulmyOqQnFlkwCrfdf7dzHDEEwcJ9rPU3RPsPOyoCtauCIu2uXAShS8yP0d
HyNfi+QZ6f8uWFX94yUZC5a/oha4LYSdbF7/Ic730wWCoS/ZpnzBC/FkL6yvum/q
XIV5f5x5o2duOiUyN9E/Ne++sc4jgnxxX1QTMUvrvSIjPYK86WH3kRd/sRnuuI4/
8QGXpfzPoxOvcWvD//iTXnTqQ59sSaun4iJCkbNUX7w4dAg35wlv9QZSiRw+HM7O
5Su/lSMrTwijg604RmqB31RF1dW12731aBt0cfHvv0UtgQRlMT7XNVIg6q4C0EcY
lkral02hALB6JzJBKuz4Z6MPcudF4OX/zpe9P4fhfawYgaMylGHk8bNG8g07H0SO
Hggbwi/ySyrzWRacHrCSzOxMpSbXWBGHW6lJIiGZBGoNnUPzkpuVKj/WmG+Vn8kA
GpiJempS/Pkfq7nqGZGlbkxteYehovkYroz5ItipxiT2Q3ZlMjksy90YzsAnoovX
4O6LmJbg7vUjMLo0zS7SwZwY1eZLBq4skVG3PuljY0q2s4R4WeYWoL8yogRXGn7K
40+Irtt7TWOQ+H9gORr0QpbED2IgH14rOU+nxMKpWQ18BDoIggCzRTReecl0IjpE
dvv1J02hhyX+iERyQh80
=vphx
-----END PGP SIGNATURE-----

--Uwl7UQhJk99r8jnw--
